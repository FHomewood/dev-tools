### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to delete a temporary environment created by newenv.

### ~~~~ PARAMETERS ~~~~ ###
[CmdletBinding()]
param (
    [switch] $Version,
    [switch] $Help,
    [int] $env_num
)

### ~~~~ METADATA ~~~~ ###
$version_number = "v0.1.1"
$script_name = 'delenv'

### ~~~~ CONFIG ~~~~ ###
$development_dir = "~\Development\"
$playground_dir = "~\Playground\"

### ~~~~ SETUP ~~~~ ###
$init_dir = Get-Location | Resolve-Path
$is_successful = $false
$error_message = ''
$development_dir = $development_dir | Resolve-Path
$playground_dir = $playground_dir | Resolve-Path

### ~~~~ BUILD ~~~~ ###
function Build {
    if (!$env_num) {
        try {
            $env_num = ("$init_dir" -Split "project_")[1]
            Write-Host "env_num: $env_num" -ForegroundColor Cyan
        }
        catch {
            if (!$env_num){
                Write-Host "No environment to delete" -ForegroundColor Red
                Write-Host "Please provide enviroment number" -ForegroundColor Red
                break
            }
        }
    }
    try {
        '~' | Resolve-Path | Set-Location

        $run_in_dev = "$init_dir".Contains("$development_dir")
        $run_in_play = "$init_dir".Contains("$playground_dir")
        $run_in_env = "$init_dir".Contains("project_$envnum")
        
        $dev_path = "$development_dir"+"project_$env_num\" 
        $play_path = "$playground_dir"+"project_$env_num\" 
        switch ($true) {
            $run_in_env { $env_to_delete = "$(("$init_dir" -split "$env_num")[0])_$env_num\" }
            $run_in_dev { $env_to_delete = "$dev_path" }
            $run_in_play { $env_to_delete = "$play_path" }
            Default { 

                $dev_env_exists = $dev_path | Test-Path
                $play_env_exists = $play_path | Test-Path

                switch ($true) {
                    $($dev_env_exists -And $play_env_exists) {
                        Write-Host "Two environments under this id:" -ForegroundColor Yellow
                        Write-Host "[0] - $dev_path" -ForegroundColor Yellow
                        Write-Host "[1] - $play_path" -ForegroundColor Yellow
                        $Response = Read-Host "Select which environment to delete"
                        switch ($Response) {
                            "0" { $env_to_delete = $dev_path }
                            "1" { $env_to_delete = $play_path }
                            Default {
                                Write-Host "No valid input given" -ForegroundColor Red
                                Write-Host "Please try again" -ForegroundColor Red
                                break
                            }
                        }
                    }
                    $($dev_env_exists -And !$play_env_exists) {
                        $env_to_delete = $dev_path
                    }
                    $(!$dev_env_exists -And $play_env_exists) {
                        $env_to_delete = $play_path
                    }
                    Default {
                        Write-Host "Could not find project_$env_num" -ForegroundColor Red
                        break
                    }
                }
            }
        }
        Write-Host $env_to_delete
        switch ($true){
            $($run_in_env) {
                Remove-Item -Recurse -Force "$env_to_delete/*"
                Write-Host "Workspace will delete when VSCode is closed"
                Start-Process -File 'powershell.exe' -ArgumentList "-noexit", "-command `"
                & {
                    code --wait $env_to_delete
                    Remove-Item -Recurse -Force $env_to_delete
                }
                `""
            }
            $(!$run_in_env){
                Remove-Item -Recurse -Force $env_to_delete
            }
            Default {
                Write-Host "An unknown error has occured" -ForegroundColor Red
            }
        }
        $is_successful = $true
    }
    catch {
        $error_message = $Error[0].Exception.Message
        try{ Set-Location $init_dir }
        catch{}
    }
    finally {
        if (!$error_message) {
            $error_message = "An unknown error occurred"
        }
        if (!$is_successful) {
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
        },
        [PSCustomObject]@{ 
            Flag = '-env_num'; 
            Description = 'Specify which env to delete';
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
