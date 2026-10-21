param(
    [string]$FasmPath = $env:FASM_PATH,
    [string]$Output = "$PSScriptRoot\dist\PhpSubnetScout.exe"
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
if (!$FasmPath) {
    $localCompiler = Join-Path $root '.tooling\fasm\FASM.EXE'
    $compilerCommand = Get-Command fasm -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $localCompiler) { $FasmPath = $localCompiler }
    elseif ($compilerCommand) { $FasmPath = $compilerCommand.Source }
    else { throw 'Geef -FasmPath op, zet FASM_PATH, of voer scripts/setup-fasm.ps1 uit.' }
}
if (!(Test-Path -LiteralPath $FasmPath)) { throw "FASM ontbreekt: $FasmPath" }
New-Item -ItemType Directory -Force -Path "$root\dist" | Out-Null
$previousInclude = $env:INCLUDE
try {
    $env:INCLUDE = Join-Path (Split-Path $FasmPath) 'INCLUDE'
    & $FasmPath "$root\src\PhpSubnetScout.asm" $Output
    if ($LASTEXITCODE -ne 0) { throw 'Assembler-build mislukt' }
}
finally { $env:INCLUDE = $previousInclude }
Get-Item -LiteralPath $Output | Select-Object Name,Length
