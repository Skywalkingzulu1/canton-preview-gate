# Reproduce every claim in the README with one command (Windows).
# Requires: Daml SDK 3.4.x (damlc on PATH) + Java 17.
# Usage: powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

$damc = if ($env:DAMLC) { $env:DAMLC } else { "damlc" }

Write-Host "==> Building PolicyGate package..."
& $damc build --package-root .
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "==> Running proof suite (6 scripted claims)..."
& $damc test --package-root .
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "Every claim held."
