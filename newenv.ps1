### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# Command to create a new development environment under a temporary directory.

### ~~~~ PARAMETERS ~~~~ ###
[CmdletBinding()]
param (
    [switch] $Version,
    [switch] $Help,
    [switch] $Playground
)

### ~~~~ METADATA ~~~~ ###
$version_number = "v0.1.3"
$script_name = 'newenv'

### ~~~~ CONFIG ~~~~ ###
$python_version = "3.11.5"
$development_dir = "~\Development\"
$playground_dir = "~\Playground\"
$first_name = [Environment]::GetEnvironmentVariable("config_first_name", "Machine")
$last_name = [Environment]::GetEnvironmentVariable("config_last_name", "Machine")

### ~~~~ SETUP ~~~~ ###
$$ = ' $'
$env_num = Get-Random -Minimum 10000 -Maximum 99999
$env_type = "Development"
$env_dir = $development_dir
$is_successful = $false
$venv_exists = $false
$error_message = ''
$init_dir = Get-Location
$target_dir = "project_$env_num\"
$env_path = $development_dir + $target_dir

if ($Playground) {
    $env_type = "Playground"
    $env_dir = $playground_dir
    $env_path = $env_dir + $target_dir
}

### ~~~~ BUILD ~~~~ ###
Write-Host "~~~ Building $env_type Environment #$env_num ~~~" -ForegroundColor DarkGreen
Write-Host "  - Building path..." -ForegroundColor Cyan
$null = New-Item -Path $env_dir -Name $target_dir -ItemType Directory
$null = New-Item -Path $env_path -Name "src" -ItemType Directory
$null = New-Item -Path $env_path -Name "tests" -ItemType Directory
$null = New-Item -Path "$env_path\src" -Name "__init__.py" -ItemType File
$null = New-Item -Path "$env_path\src" -Name "__main__.py" -ItemType File
$null = New-Item -Path "$env_path\tests" -Name "__init__.py" -ItemType File
$null = New-Item -Path $env_path -Name "README.md" -ItemType File

Write-Host "  - Finding path..." -ForegroundColor Cyan
$null = Set-Location $env_path
$abs_path = Get-Location

try {
    Write-Host "  - Initializing git repository..." -ForegroundColor Cyan
    $null = git init
    
    Write-Host "  - Building Python environment..." -ForegroundColor Cyan
    $null = pyenv exec python -m virtualenv .venv
    $venv_exists = $true
    Write-Host "      Created .\.venv\" -ForegroundColor DarkCyan
    $null = . .\.venv\Scripts\activate
    $null = pip install --upgrade pip
    Write-Host "      Upgraded pip" -ForegroundColor DarkCyan
    $null = pip install poetry
    Write-Host "      Installed poetry" -ForegroundColor DarkCyan
    $null = poetry init -n `
            --name src `
            --python $python_version `
            --author "$first_name $last_name <$first_name.$last_name@data-vault.com>" `
            --description `
            "Project ID #${env_num}: Authored by $first_name $last_name in association with Business Thinking Ltd. (dba Datavault)" `

    Write-Host "      Initialized project" -ForegroundColor DarkCyan
    $null = poetry install
    Write-Host "      Locked pyproject.toml" -ForegroundColor DarkCyan
    $is_successful = $true
}
catch {
    $error_message = $Error[0].Exception.Message
}
finally {
    Write-Host "  - Cleaning up..." -ForegroundColor Cyan
    if ($venv_exists){
        Write-Host "      Deactivating python virtual environment" -ForegroundColor Cyan
        $null = deactivate
    }
    Write-Host "      returning to init_dir" -ForegroundColor Cyan
    $null = Set-Location $init_dir

    if ($is_successful) {
        $null = code $abs_path
        Write-Host "Done!" -ForegroundColor Green
    }
    else {
        Write-Host "  - Restoring..." -ForegroundColor Cyan
        $null = Remove-Item  $abs_path -Recurse -Force
        if (!$error_message) { $error_message = "An unknown error occurred"}
        Write-Warning -Message "$error_message"
    }
}

### ~~~~ INFO FLAGS ~~~~ ###
if ($Version) {
    Write-Host $version_number
    break
}
if ($Help) {
    Write-Host `
    "~~ $script_name ~~
Command to create a new development environment under a temporary directory.

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
            Flag = '-Playground, -p';
            Description = "Create the environment under the '$playground_dir' directory";
        }
    ) | Format-Table
    
    Write-Output $table
    Write-Host "In the script itself there are a series of config options that can be changed if they are not aligned with the system"
    $table = @(
        [PSCustomObject]@{
            Config = '$python_version';
            Description = 'python version';
            Value = "$python_version";
            Default = '3.11.5';
        },
        [PSCustomObject]@{
            Config = '$development_dir';
            Description = 'Directory where development environments will be created';
            Value = "$development_dir";
            Default = '~\Development\';
        },
        [PSCustomObject]@{
            Config = '$playground_dir';
            Description = 'python version';
            Value = "$playground_dir";
            Default = '"~\Playground\"';
        }
        [PSCustomObject]@{
            Config = '$first_name';
            Description = 'python version';
            Value = "$first_name";
            Default = 'Frankie';
        },
        [PSCustomObject]@{
            Config = '$last_name';
            Description = 'python version';
            Value = "$last_name";
            Default = 'Homewood';
        }
    ) | Format-Table
    Write-Output $table
    break
}

### ~~~~ GARBAGE COLLECTION ~~~~ ###
[System.GC]::Collect()
