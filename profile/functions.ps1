### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A functions script to group all shared functions into one file to be sourced.


function Deactivte-VEnv {
    Eemove-Alias -Name "deactivate" -Force
    Set-Variable -Name "VIRTUAL_ENV_PATH" -Value $null -Scope Global
    . $PSScriptRoot\prompt
}
function Activate-VEnv {
    param(
        [string] $path
    )
    Set-Alias -Name "deactivate" -Value "Deactivate-VEnv"
    
    if (!$path) { $path = "./.venv"}
    $null = $path | Resolve-Path
    if (!($path | Test-Path)) { break }

    . "$path/scripts/activate"
    Set-Variable -Name "VIRTUAL_ENV_PATH" -Value $path -Scope Global
}

function Assign-Profile {
    $path = "$PSScriptRoot\Profile.ps1"
    if (!($path | Test-Path)) {break}
    . $path
}
