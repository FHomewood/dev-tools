# © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to clean up unused environments created by newenv.

### ~~~~ PARAMETERS ~~~~ ###
[CmdletBinding()]
param (
    [switch] $Version,
    [switch] $Help
)
$version_number = "v0.1.0"
$script_name = 'cleanenvs'

### ~~~~ CONFIG ~~~~ ###
$development_dir = "~\Development\"
$playground_dir = "~\Playground\"

function Show-Help {
    Write-Host `
    "~~ $script_name ~~
A command to clean up unused environments created by newenv.

Parameter flags can be supplied with the command to adjust the script's behaviour."
    $table = @(
        [PSCustomObject]@{ 
            Flag = '-Help, -h'; 
            Description = 'Help page and available flags';
        },
        [PSCustomObject]@{ 
            Flag = '-Version, -v'; 
            Description = 'Script version';
        }
    ) | Format-Table
    
    Write-Output $table
    Write-Host "In the script itself there are a series of config options that can be changed if they are not aligned with the system"
    $table = @(
        [PSCustomObject]@{
            Config = '$development_dir';
            Description = 'Directory for development environments';
            Value = "$development_dir";
            Default = '~\Development\';
        },
        [PSCustomObject]@{
            Config = '$playground_dir';
            Description = 'Directory for playground environments';
            Value = "$playground_dir";
            Default = '~\Playground\';
        }
    ) | Format-Table
    Write-Output $table
    break
}

### ~~~~ RUN ~~~~ ###
switch ($true) {
    $Version { Write-Host $version_number }
    $Help { Show-Help }
    Default { Build }
}

### ~~~~ GARBAGE COLLECTION ~~~~ ###
[System.GC]::Collect()
