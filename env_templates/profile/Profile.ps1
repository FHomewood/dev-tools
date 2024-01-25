function prompt {
    $folder_name = Split-Path -Path (Get-Location) -Leaf
    "$([char]27)[38;5;150mwindows$([char]27)[38;5;249m:$([char]27)[38;5;141m$folder_name$([char]27)[38;5;249m > $([char]27)[39m"
}

try { . functions; } catch { Write-Host "Couldn't source ~/.dev-tools/functions.ps1" }
try { . aliases; } catch { Write-Host "Couldn't source ~/.dev-tools/aliases.ps1" }
if ('./.venv/scripts/activate' | Test-Path) { activate; }
