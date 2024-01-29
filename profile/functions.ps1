### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A functions script to group all shared functions into one file to be sourced.

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
