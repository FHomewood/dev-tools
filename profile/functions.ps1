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

function Time-Stamp {
    Write-Host (Get-Date).ToString("yyyy-MM-dd_hh-mm-ss")
}

function Load-Config {
    $content = Get-Content "$env:devtools_dir.dtconfig"
    $env:devtools_dir = [System.Environment]::GetEnvironmentVariable('devtools_dir', 'Machine')
    $content | ForEach-Object {
        if ([string]::IsNullOrWhiteSpace($_) -or $_ -like '#*' -or $_ -like '=*') { return }
        $name, $value = $_.split('=')
        $name = $name.Trim().Trim('"')
        $value = $value.Trim().Trim('"')
        Set-Content env:\$name $value
    }
}
