# PowerShell 7; loopback fixtures only. Windows TLS tests need access outside the Codex sandbox.
param([string]$Executable = "$PSScriptRoot\..\dist\PhpSubnetScout.exe")
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot
$output = "$root\test-output"
New-Item -ItemType Directory -Force $output | Out-Null
Add-Type -AssemblyName System.Drawing
$references = @('System.Private.Windows.GdiPlus','System.Private.Windows.Core','System.Drawing.Common','System.Drawing.Primitives','System.Runtime','System.Collections','System.Net.Primitives','System.Net.Sockets','System.Net.Security','System.Security.Cryptography','System.Threading','System.Threading.Thread','System.Threading.Tasks','System.Console','System.Runtime.InteropServices') | Where-Object { Test-Path (Join-Path $PSHOME "$_.dll") }
Add-Type -Path "$PSScriptRoot\Support.cs" -ReferencedAssemblies $references
$checks = [Collections.Generic.List[string]]::new()
function Check($condition,[string]$name) {
 if (!$condition) {throw "FAIL: $name"}
 $checks.Add($name); "PASS: $name"
}
function Count { [int][ScoutUI]::SendMessage($script:list,0x1004,[IntPtr]::Zero,[IntPtr]::Zero) }
function SetField($id,$value) { [ScoutUI]::SetText([ScoutUI]::GetDlgItem($script:hwnd,$id),$value) }
function Click($id) { [ScoutUI]::Click($script:hwnd,$id) }
function WaitDone {
 $sw = [Diagnostics.Stopwatch]::StartNew()
 Start-Sleep -Milliseconds 120
 while (![ScoutUI]::IsWindowEnabled([ScoutUI]::GetDlgItem($script:hwnd,104))) {
  if ($sw.ElapsedMilliseconds -gt 9000) {throw 'Scan loopt vast'}
  Start-Sleep -Milliseconds 50
 }
 Start-Sleep -Milliseconds 60
}
function Scan($cidr='127.23.45.67/32') { SetField 101 $cidr; Click 104; WaitDone }
function AllRows {
 for($i=0;$i -lt (Count);$i++) { ,([ScoutUI]::Row($script:app.Id,$script:list,$i)) }
}
function SaveCSV([string]$name) {
 $path = "$output\$name.csv"
 if(Test-Path -LiteralPath $path) {Remove-Item -LiteralPath $path}
 Click 106
 $deadline = [DateTime]::UtcNow.AddSeconds(8)
 do {
  Start-Sleep -Milliseconds 100
  $dialog = [ScoutUI]::Dialog($script:app.Id)
  $edit = if($dialog) {[ScoutUI]::FindId($dialog,'Edit',1001)} else {[IntPtr]::Zero}
 } until($edit -ne [IntPtr]::Zero -or [DateTime]::UtcNow -gt $deadline)
 if(!$edit) {throw 'Geen CSV-bestandsdialoog'}
 [ScoutUI]::TypeText($edit,$path)
 [ScoutUI]::PostMessage([ScoutUI]::FindId($dialog,'Button',1),245,[IntPtr]::Zero,[IntPtr]::Zero) | Out-Null
 do {Start-Sleep -Milliseconds 100} until((Test-Path -LiteralPath $path) -or [DateTime]::UtcNow -gt $deadline)
 if(!(Test-Path -LiteralPath $path)) {throw 'CSV niet opgeslagen'}
 Start-Sleep -Milliseconds 100
 return $path
}
$fixture = [ScoutFixture]::new()
$app = Start-Process $Executable -PassThru
try {
 Start-Sleep -Milliseconds 800
 $hwnd = [ScoutUI]::Main($app.Id)
 Check ($hwnd -ne [IntPtr]::Zero) 'Native venster start'
 $list = [ScoutUI]::GetDlgItem($hwnd,110)
 $detected = [ScoutUI]::Text([ScoutUI]::GetDlgItem($hwnd,101))
 Check ($detected -match '^\d+\.\d+\.\d+\.\d+/\d+$') "CIDR automatisch ingevuld: $detected"
 Check ([ScoutUI]::Text([ScoutUI]::GetDlgItem($hwnd,103)) -eq '2000') 'Timeout standaard 2000 ms'
 # Prime test-host crypto/JIT before measuring the two-second application budget.
 # The application default remains 2000 ms; this changes only a warm-up test run.
 SetField 103 '6000'; Scan
 $fixture.ResetCounts()
 SetField 103 '2000'
 Scan
 Check ((Count) -eq 10) 'Alle tien poorten leveren HTTP/HTTPS-resultaten'
 $data = AllRows
 $expectedPorts = @(80,81,443,5000,8000,8008,8080,8081,8443,8888)
 $observedPorts = @($data | ForEach-Object {[int]$_[1]} | Sort-Object)
 Check (($observedPorts -join ',') -eq ($expectedPorts -join ',')) 'Exact de tien onderzochte poorten; geen 4430 of andere poorten'
 Check (($data | Where-Object {$_[1] -eq '80'})[3] -eq 'Bevestigd') 'PHP in X-Powered-By gedetecteerd'
 Check (($data | Where-Object {$_[1] -eq '443'})[3] -eq 'Indicatie') 'Tweede Set-Cookie-header met PHPSESSID gedetecteerd'
 Check (($data | Where-Object {$_[1] -eq '8080'})[2] -eq '302') 'Redirect blijft zichtbaar'
 Check ($fixture.Requests80 -eq 1) 'Redirect wordt niet gevolgd'
 Check (($data | Where-Object {$_[1] -eq '8443'})[3] -eq 'Bevestigd') 'PHP in Server-header bij HTTP 403 gedetecteerd'
 Check ([int](($data | Where-Object {$_[1] -eq '8443'})[6]) -ge 800) 'Trage HTTPS-response binnen 2 seconden meegenomen'
 [ScoutUI]::Row($app.Id,$list,1,$true) | Out-Null
 Check ([ScoutUI]::Text([ScoutUI]::GetDlgItem($hwnd,111)) -match 'HTTP/1.1') 'Selectie toont URL en ruwe headers'
 [ScoutUI]::Shot($hwnd,"$output\dark.png")
 Click 109; Start-Sleep -Milliseconds 150
 [ScoutUI]::Shot($hwnd,"$output\light.png")
 $csvPath = SaveCSV 'fixture'
 $csv = @(Import-Csv -LiteralPath $csvPath)
 Check ($csv.Count -eq 10) 'CSV bevat alle tien endpoints'
 Check (($csv | Where-Object Port -eq 80).Server -eq "'=SUM(1,2)") 'CSV neutraliseert spreadsheetformules'
 Check (($csv | Where-Object Port -eq 80).RawHeaders.Contains('a, "b"')) 'CSV bewaart quotes, komma en regeleinden'
 Check (($csv | Where-Object Port -eq 443).TLSCertificateValidation -like 'uit*') 'CSV benoemt ontbrekende TLS-certificaatcontrole'
 Check (($csv | Where-Object Port -eq 8443).URL -eq 'https://127.23.45.67:8443/') '8443 gebruikt HTTPS in aanvraag en CSV'
 Check (@($csv | Where-Object {$_.Port -notin '443','8443' -and $_.URL -notlike 'http://*'}).Count -eq 0) 'Overige acht poorten gebruiken HTTP'
 Check ([IO.File]::ReadAllBytes($csvPath)[0] -eq 0xEF) 'CSV heeft UTF-8 BOM'
 Click 107; Start-Sleep -Milliseconds 100
 Check ((Count) -eq 3) 'PHP-filter toont drie signalen'
 Click 107; Start-Sleep -Milliseconds 100
 Check ((Count) -eq 10) 'Alles-filter toont alle endpoints'
 Click 108
 Scan
 $strict = AllRows
 Check ((($strict | Where-Object {$_[1] -eq '443'})[7]) -eq 'Netwerk/TLS-fout') 'Strikte TLS weigert onbetrouwbaar certificaat'
 Check ((($strict | Where-Object {$_[1] -eq '8443'})[7]) -eq 'Netwerk/TLS-fout') 'Strikte TLS werkt ook op alternatieve HTTPS-poort 8443'
 Click 108
 $fixture.Delay80=5000; $fixture.Delay8443=0
 Scan
 $timeout = AllRows
 $slow = $timeout | Where-Object {$_[1] -eq '80'}
 Check ($slow[7] -eq 'Time-out') 'Trage HTTP-server eindigt als time-out'
 Check ([int]$slow[6] -ge 1900 -and [int]$slow[6] -lt 2600) 'Timeout geldt voor totale aanvraag (circa 2 seconden)'
 $timeoutCSV = @(Import-Csv -LiteralPath (SaveCSV 'timeout'))
 Check (($timeoutCSV | Where-Object Port -eq 80).WinHTTPError -eq '12002') 'CSV bewaart WinHTTP-foutcode'
 # The same total budget applies when TCP and TLS succeed but HTTP headers stall.
 $fixture.Delay80=0; $fixture.Delay8443=3000
 Scan
 $tlsTimeout = AllRows
 Check ((($tlsTimeout | Where-Object {$_[1] -eq '8443'})[7]) -eq 'Time-out') 'HTTPS zonder tijdige headers eindigt binnen het budget'
 # Timeout remains user-adjustable for slow services.
 SetField 103 '4000'
 Scan
 $extended = AllRows
 Check ((($extended | Where-Object {$_[1] -eq '8443'})[2]) -eq '403') 'Verhoogde timeout neemt een HTTPS-response van drie seconden wel mee'
 SetField 103 '2000'; $fixture.Delay80=5000; $fixture.Delay8443=0
 SetField 101 '127.23.45.67/32'; Click 104
 Start-Sleep -Milliseconds 220
 Click 107; Click 107; Click 107
 Click 105; WaitDone
 $stopped = AllRows
 Check ((Count) -eq 10) 'Live filterwissels maken geen dubbele rijen'
 Check ((($stopped | Where-Object {$_[1] -eq '80'})[7]) -eq 'Afgebroken') 'Stop annuleert lopende aanvraag'
 $fixture.Delay80=0
 Scan '127.23.45.66/31'
 Check ((Count) -eq 20) '/31 scant beide adressen, tien poorten per adres'
 $subnet = @(Import-Csv -LiteralPath (SaveCSV 'subnet31'))
 Check (@($subnet.IP | Sort-Object -Unique).Count -eq 2) 'CSV bevat beide /31-adressen'
 Scan '127.23.45.68/30'
 $subnet30 = AllRows
 Check ((Count) -eq 20 -and @($subnet30 | Where-Object {$_[0] -notin '127.23.45.69','127.23.45.70'}).Count -eq 0) '/30 slaat netwerk- en broadcastadres over'
 foreach($invalid in @('127.0.0.1/33','127.0.0.1/8','256.1.1.1/24','127.1.1.1/999999999999','8.8.8.0/24','127.0.0.1/32x')) {
  SetField 101 $invalid;Click 104;Start-Sleep -Milliseconds 120
  $d = [ScoutUI]::Dialog($app.Id)
  Check ($d -ne [IntPtr]::Zero) "Ongeldige invoer geweigerd: $invalid"
  [ScoutUI]::PostMessage([ScoutUI]::FindId($d,'Button',1),245,[IntPtr]::Zero,[IntPtr]::Zero) | Out-Null
  Start-Sleep -Milliseconds 80
  Check ((Count) -eq 20) 'Bestaande resultaten behouden na invoerfout'
 }
 $fixture.Delay80=5000
 SetField 101 '127.23.45.67/32';Click 104;Start-Sleep -Milliseconds 150
 [ScoutUI]::PostMessage($hwnd,16,[IntPtr]::Zero,[IntPtr]::Zero) | Out-Null
 Check ($app.WaitForExit(3000)) 'Venster sluiten annuleert workers en sluit proces'
 "$($checks.Count) controles geslaagd" | Tee-Object -FilePath "$output\summary.txt"
 $checks | Set-Content "$output\checks.txt"
} finally {
 $fixture.Dispose()
 if (!$app.HasExited) {Stop-Process -Id $app.Id}
}
