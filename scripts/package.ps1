param(
    [ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version = '1.2.1',
    [string]$DistDir = "$PSScriptRoot\..\dist"
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot
$dist = $DistDir
$exe = Join-Path $dist 'PhpSubnetScout.exe'
if (!(Test-Path -LiteralPath $exe)) { throw 'Voer eerst build.ps1 uit.' }
$archive = Join-Path $dist "PhpSubnetScout-$Version-win-x86.zip"
if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive }
$zip = [IO.Compression.ZipFile]::Open($archive,[IO.Compression.ZipArchiveMode]::Create)
try {
    $files = @{'PhpSubnetScout.exe'=$exe; 'README.md'=(Join-Path $root 'README.md'); 'LICENSE'=(Join-Path $root 'LICENSE'); 'THIRD_PARTY_NOTICES.md'=(Join-Path $root 'THIRD_PARTY_NOTICES.md'); 'docs/PORT_RESEARCH.md'=(Join-Path $root 'docs\PORT_RESEARCH.md')}
    foreach ($name in ($files.Keys | Sort-Object)) {
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$files[$name],$name,[IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
}
finally { $zip.Dispose() }
$checksums = foreach ($file in @($exe,$archive)) {
    '{0}  {1}' -f (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant(),(Split-Path $file -Leaf)
}
$checksums | Set-Content -LiteralPath (Join-Path $dist 'SHA256SUMS.txt') -Encoding ascii
