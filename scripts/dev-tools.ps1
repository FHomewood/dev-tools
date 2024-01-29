### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to control and standardise development machines.

### ~~~~ PARAMETERS ~~~~ ###
[CmdletBinding()]
param (
    [switch] $Version,
    [switch] $Help,
    [switch] $SkipConfiguration,
    [switch] $SkipInstallDependencies
)

### ~~~~ METADATA ~~~~ ###
$version_number = 'v0.1.2'
$script_name = 'dev-tools'

### ~~~~ CONFIG ~~~~ ###
$python_version = '3.11.5'
$repo_dir = '~/.dev-tools'

### ~~~~ SETUP ~~~~ ###
$is_successful = $true
$init_dir = Get-Location
$text_info = (Get-Culture).TextInfo

function Build {
    try {
        '~' | Resolve-Path | Set-Location
        switch ($false) {
            $SkipInstallDependencies { Install-Dependencies }
            $SkipConfiguration { Configure }
        }
    }
    catch {
        Write-Host "An error occurred creating Environment #$env_num" -ForegroundColor Red
        Write-Warning -Message $Error[0].Exception.Message
    }
    finally {
        Set-Location $init_dir
    }

    if ($is_successful) {
        Write-Host "Done!" -ForegroundColor Green
    }
}

function Install-Dependencies {
    Write-Host "~~~ Installing Dependencies ~~~" -ForegroundColor Green
    Write-Host "  - Installing chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    
    Write-Host "  - Installing packages..." -ForegroundColor Cyan
    $null = choco install git
    Write-Host "      Installed git" -ForegroundColor DarkCyan
    $null = choco install gitkraken
    Write-Host "      Installed gitkraken" -ForegroundColor DarkCyan
    $null = choco install pyenv-win
    Write-Host "      Installed pyenv" -ForegroundColor DarkCyan
    $null = choco install vscode
    Write-Host "      Installed vscode" -ForegroundColor DarkCyan
    $null = choco install pycharm
    Write-Host "      Installed pycharm" -ForegroundColor DarkCyan

    Write-Host "  - Initialising python..." -ForegroundColor Cyan
    $null = pyenv update
    $null = pyenv install $python_version
    Write-Host "      Installed python v$python_version" -ForegroundColor DarkCyan
    $null = pyenv global $python_version
    Write-Host "      Configured pyenv global version" -ForegroundColor DarkCyan
}

function Configure {
    Write-Host "~~~ Configuring Machine ~~~" -ForegroundColor Green
    Write-Host "  - Collecting environment variables..." -ForegroundColor Cyan
    $env:first_name = 'Frankie' # Read-Host "What is your first name? "
    $env:first_name = $text_info.ToTitleCase($env:first_name)
    [Environment]::SetEnvironmentVariable("config_first_name", $env:first_name, [System.EnvironmentVariableTarget]::Machine)
    $env:last_name = 'Homewood' # Read-Host "What is your last name? "
    $env:last_name = $text_info.ToTitleCase($env:last_name)
    [Environment]::SetEnvironmentVariable("config_last_name", $env:last_name, [System.EnvironmentVariableTarget]::Machine)
    $env:email = 'f.homewood@outlook.com' # Read-Host "What is your git email? "
    $env:email = $text_info.ToLower($env:email)
    [Environment]::SetEnvironmentVariable("config_email", $env:email, [System.EnvironmentVariableTarget]::Machine)

    
    Write-Host "  - Configuring git config..." -ForegroundColor Cyan
    $git_dir = "C:\Program Files\Git\bin"
    $git_in_path = $env:Path -split ";" -contains $git_dir
    if (!$git_in_path)
    {
        [Environment]::SetEnvironmentVariable("PATH", "$env:Path;$git_dir", "Machine")
    }

    git config --global credential.helper "cache --timeout=$(24*60*60)"
    git config --global user.name "$env:first_name $env:last_name"
    git config --global user.email $env:email
    
    $null = Write-Output 'n' | ssh-keygen -q -f "$HOME/.ssh/id_rsa" -N """" -t rsa

    if (!(Test-Path $repo_dir)){
        git clone "https://github.com/FHomewood/dev-tools.git" ($repo_dir | Resolve-Path)
        [Environment]::SetEnvironmentVariable("Path", "$env:Path;$repo_dir", "Machine")
    }

    # Apply dev-tools powershell profile
    (Get-Content "$repo_dir\env_templates\profile\Profile.ps1") > $PROFILE.CurrentUserAllHosts
}

function Show-Help {
    Write-Host `
    "~~ $script_name ~~
A command to control and standardise development machines.

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
            Flag = "SkipInstallDependencies, -skipi";
            Description = "Don't Install development packages on this machine";
        },
        [PSCustomObject]@{ 
            Flag = '-SkipConfiguration, -skipc';
            Description = "Don't configure this machine's environment";
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
