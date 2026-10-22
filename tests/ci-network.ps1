# Runs ONLY on an ephemeral GitHub Actions Windows runner. Never changes a user's firewall/hosts file.
param([string]$Executable = "$PSScriptRoot\..\dist\PhpSubnetScout.exe")
$ErrorActionPreference = 'Stop'
if ($env:GITHUB_ACTIONS -ne 'true') { throw 'Deze test met tijdelijk firewallbeleid is uitsluitend voor de tijdelijke GitHub-runner.' }
$Executable = (Resolve-Path -LiteralPath $Executable).Path
$hostsPath = Join-Path $env:windir 'System32\drivers\etc\hosts'
$hostsBytes = [IO.File]::ReadAllBytes($hostsPath)
$profiles = @(Get-NetFirewallProfile | Select-Object Name,Enabled)
$ruleName = 'PhpSubnetScout-CI-' + [guid]::NewGuid().ToString('N')
$app = $null
try {
    [IO.File]::AppendAllText($hostsPath,"`r`n127.0.0.1 scout-fixture.test # PHP Subnet Scout CI`r`n198.51.100.1 scout-blocked.test # PHP Subnet Scout CI`r`n",[Text.Encoding]::ASCII)
    & "$PSScriptRoot\smoke.ps1" -Executable $Executable -FixtureName 'scout-fixture.test'
    # TEST-NET-2 is documentation space. The scoped rule prevents these test connections leaving the runner.
    Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
    New-NetFirewallRule -Name $ruleName -DisplayName $ruleName -Direction Outbound -Action Block -Profile Any -Program $Executable -Protocol TCP -RemoteAddress '198.51.100.1' | Out-Null
    $app = Start-Process $Executable -PassThru
    $startupDeadline = [DateTime]::UtcNow.AddSeconds(10)
    do {
        Start-Sleep -Milliseconds 100
        $hwnd = [ScoutUI]::Main($app.Id)
    } until(($hwnd -ne [IntPtr]::Zero -and [ScoutUI]::IsWindowVisible($hwnd)) -or $app.HasExited -or [DateTime]::UtcNow -gt $startupDeadline)
    if (!$hwnd) { throw 'Geen scanner-venster voor firewalltest' }
    foreach($target in @('198.51.100.1','scout-blocked.test')) {
    [ScoutUI]::SetText([ScoutUI]::GetDlgItem($hwnd,101),$target)
    [ScoutUI]::Click($hwnd,104)
    Start-Sleep -Milliseconds 150
    $deadline = [DateTime]::UtcNow.AddSeconds(8)
    while (![ScoutUI]::IsWindowEnabled([ScoutUI]::GetDlgItem($hwnd,104))) {
        if ([DateTime]::UtcNow -gt $deadline) { throw 'Firewalltest loopt vast' }
        Start-Sleep -Milliseconds 60
    }
    $list = [ScoutUI]::GetDlgItem($hwnd,110)
    $count = [int][ScoutUI]::SendMessage($list,0x1004,[IntPtr]::Zero,[IntPtr]::Zero)
    if ($count -ne 10) { throw "Extern IPv4-doel geeft $count rijen in plaats van 10" }
    for ($i=0;$i -lt $count;$i++) {
        $row = [ScoutUI]::Row($app.Id,$list,$i,$true)
        Write-Host ($row -join ' | ')
        $detail = [ScoutUI]::Text([ScoutUI]::GetDlgItem($hwnd,111))
        Write-Host $detail
        if ($row[7] -ne 'Uitgaand lokaal geweigerd') { throw "Lokale uitgaande blokkade niet herkend op poort $($row[1])" }
        if ($detail -notmatch 'Winsock 10013|WinHTTP 5 ') { throw 'Een lokale weigering is benoemd zonder de verwachte Windows-bewijscode' }
    }
    # Verify export uses the same evidence and does not mark successful ports as blocked.
    $csvPath = Join-Path (Split-Path $PSScriptRoot) "test-output\outbound-block-$target.csv"
    if(Test-Path -LiteralPath $csvPath) {Remove-Item -LiteralPath $csvPath}
    [ScoutUI]::Click($hwnd,106)
    $deadline = [DateTime]::UtcNow.AddSeconds(15)
    do {
        Start-Sleep -Milliseconds 100
        $dialog = [ScoutUI]::Dialog($app.Id)
        $edit = if($dialog) {[ScoutUI]::FindId($dialog,'Edit',1001)} else {[IntPtr]::Zero}
    } until($edit -ne [IntPtr]::Zero -or [DateTime]::UtcNow -gt $deadline)
    if(!$edit) {throw 'Geen CSV-dialog in firewalltest'}
    [ScoutUI]::TypeText($edit,$csvPath)
    [ScoutUI]::PostMessage([ScoutUI]::FindId($dialog,'Button',1),245,[IntPtr]::Zero,[IntPtr]::Zero) | Out-Null
    do {Start-Sleep -Milliseconds 100} until((Test-Path -LiteralPath $csvPath) -or [DateTime]::UtcNow -gt $deadline)
    $csv = @(Import-Csv -LiteralPath $csvPath)
    if($csv.Count -ne 10 -or @($csv | Where-Object {$_.Target -ne $target -or $_.WinsockError -ne '10013' -or $_.Result -ne 'Uitgaand lokaal geweigerd'}).Count -ne 0) {throw 'Onjuiste firewallbewijscodes in CSV'}
    Write-Host "PASS: $target, 10 echte lokale uitgaande blokkades en CSV-bewijs gecontroleerd"
    }
}
finally {
    if ($app -and !$app.HasExited) { Stop-Process -Id $app.Id }
    Remove-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue
    foreach($profile in $profiles) { Set-NetFirewallProfile -Name $profile.Name -Enabled $profile.Enabled }
    [IO.File]::WriteAllBytes($hostsPath,$hostsBytes)
}
