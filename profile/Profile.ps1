### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# The dev-tools Profile.ps1, source this in your profile to run automatically on powershell open.

try { . $PSScriptRoot\functions.ps1; } catch { Write-Host "Couldn't source dev-tools functions" }
try { . $PSScriptRoot\aliases.ps1; } catch { Write-Host "Couldn't source dev-tools aliases" }
try { . $PSScriptRoot\prompt.ps1; } catch { Write-Host "Couldn't source dev-tools prompt" }

# $env:VIRTUAL_ENV_DISABLE_PROMPT = 1

if ('./.venv/scripts/activate' | Test-Path) { activate; }

