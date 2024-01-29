### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A functions script to group all shared functions into one file to be sourced.


function Deactivate-VEnv {
    deactivate
    Set-Variable -Name "VIRTUAL_ENV_PATH" -Value $null -Scope Global
    try { . $PSScriptRoot\prompt.ps1; } catch { Write-Host "Couldn't source dev-tools prompt" }
}

function Activate-VEnv {
    param(
        [string] $path
    )
    if (!$path) { $path = "./.venv"}
    $null = $path | Resolve-Path
    if (!($path | Test-Path)) { break }

    . "$path/scripts/activate"
    Set-Variable -Name "VIRTUAL_ENV_PATH" -Value $path -Scope Global
    . $PSScriptRoot\prompt
}

function Assign-Profile {
    $path = "$PSScriptRoot\Profile.ps1"
    if (!($path | Test-Path)) {break}
    . $path
}
