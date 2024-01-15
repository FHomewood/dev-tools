### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to delete a temporary environment created by newenv.

### ~~~~ PARAMETERS ~~~~ ###
[CmdletBinding()]
param (
    [switch] $Version,
    [switch] $Help,
    [switch] $Playground
)
4
### ~~~~ METADATA ~~~~ ###
$version_number = "v0.1.0"
$script_name = 'delenv'

### ~~~~ CONFIG ~~~~ ###
$development_dir = "~\Development\"
$playground_dir = "~\Playground\"

### ~~~~ SETUP ~~~~ ###
$is_successful = $false
$error_message = ''

### ~~~~ BUILD ~~~~ ###
function Build {
    try {
    }
    catch {
        $error_message = $Error[0].Exception.Message
    }
    finally {

        if ($is_successful) {
            Write-Host "Done!" -ForegroundColor Green
        } else {
            if (!$error_message) { 
                $error_message = "An unknown error occurred"
            }
            Write-Warning -Message "$error_message"
        }
    }
}

function Show-Help {
    Write-Host `
    "~~ $script_name ~~
A command to delete a temporary environment created by newenv.

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
