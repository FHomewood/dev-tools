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
    $content = Get-Content ($env:devtools_dir + "dot-files\.dtconfig")
    $env:devtools_dir = [System.Environment]::GetEnvironmentVariable('devtools_dir', 'Machine')
    $content | ForEach-Object {
        if ([string]::IsNullOrWhiteSpace($_) -or $_ -like '#*' -or $_ -like '=*') { return }
        $name, $value = $_.split('=')
        $name = $name.Trim().Trim('"')
        $value = $value.Trim().Trim('"')
        Set-Content env:\$name $value
    }
}

function Write-Debug {
    param(
        $string
    )
    Write-Host -ForegroundColor Magenta "DEBUG | $string"
}

function Replace-FileContents {
    [CmdletBinding()]
    param ([string] $Path, [string] $Find, [string] $Replace, [switch] $Recurse)
    
    begin {
        if (!(Test-Path -Path $Path)) {Write-Error "Could not resolve path $Path"}
        if ($Find.Length -le 0) {Write-Error "Find '$Find' has length 0"}
        if ($Replace.Length -le 0) {Write-Error "Replace '$Replace' has length 0"}
    }
    
    process {
        $file_path = Resolve-Path -Path $Path
        $files = Get-ChildItem $file_path 
        if ($Recurse) { $files = $files | Get-ChildItem -Recurse}
        foreach ($file in $files) {
            if ((Test-Path -Path $file.FullName -PathType Leaf) -eq $False) { continue; }
            $file_content = (Get-Content $file.FullName)
            if ($null -eq $file_content) { continue; }
            if (!($file_content -match $Find)) { continue; }
            $new_file_content = $file_content.Replace($Find, $Replace)
            Set-Content -Path $file.FullName -Value $new_file_content
        }
    }
    
    end {        
    }
}

function Replace-FileNames {
    [CmdletBinding()]
    param ([string] $Path, [string] $Find, [string] $Replace, [switch] $Recurse)
    
    begin {
        if (!(Test-Path -Path $Path)) {Write-Error "Could not resolve path $Path"}
        if ($Find.Length -le 0) {Write-Error "Find '$Find' has length 0"}
        if ($Replace.Length -le 0) {Write-Error "Replace '$Replace' has length 0"}
    }
    
    process {
        $file_path = Resolve-Path -Path $Path
        $files = Get-ChildItem $file_path 
        if ($Recurse) { $files = $files | Get-ChildItem -Recurse}
        foreach ($file in $files) {
            $file_name = "$($file.BaseName)$($file.Extension)"
            if (!($file_name  -match $Find)) { continue; }
            $new_file_name = $file_name.Replace($Find, $Replace)
            Rename-Item -Path $($file.FullName) -NewName $new_file_name
        }
    }

    
    end {        
    }
}
