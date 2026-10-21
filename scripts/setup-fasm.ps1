$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot
$toolsDir = Join-Path $root '.tooling'
$archive = Join-Path $toolsDir 'fasmw17335.zip'
$expected = '8ef871b369638f63d2df475a64e9f574da06b601db5a3fcb8c12654b7bcf5e81'
New-Item -ItemType Directory -Force $toolsDir | Out-Null
if (!(Test-Path -LiteralPath $archive)) {
    Copy-Item -LiteralPath (Join-Path $root 'third_party\fasmw17335.zip') -Destination $archive
}
if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) {
    throw 'De FASM-download heeft een onverwachte SHA-256. Niet uitvoeren.'
}
Expand-Archive -LiteralPath $archive -DestinationPath (Join-Path $toolsDir 'fasm') -Force
Write-Host 'FASM 1.73.35 is klaar; downloadhash gecontroleerd.'
