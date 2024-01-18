### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to create a new development environment under a temporary directory.

### ~~~~ PARAMETERS ~~~~ ###
[CmdletBinding()]
param (
    [switch] $Version,
    [switch] $Help,
    [switch] $Playground,
    [switch] $Quick
)

### ~~~~ METADATA ~~~~ ###
$version_number = "v0.2.3"
$script_name = 'NewEnv'

### ~~~~ CONFIG ~~~~ ###
$python_version = "3.11.5"
$development_dir = "~\Development\"
$playground_dir = "~\Playground\"
$environment_template_dir = "~\.dev-tools\env_templates\NewEnv"
$first_name = [Environment]::GetEnvironmentVariable("config_first_name", "Machine")
$last_name = [Environment]::GetEnvironmentVariable("config_last_name", "Machine")
$contact = [Environment]::GetEnvironmentVariable("config_email", "Machine")

### ~~~~ SETUP ~~~~ ###
$env_num = Get-Random -Minimum 10000 -Maximum 99999
switch ($true) {
    $Playground {
        $env_type = "Playground"
        $env_dir = $playground_dir
    }
    Default {
        $env_type = "Development"
        $env_dir = $development_dir
    }
}
$env_dir = $env_dir | Resolve-Path
$is_successful = $false
$venv_exists = $false
$error_message = ''
$init_dir = Get-Location
$target_dir = "project_$env_num\"
$env_path = "$env_dir$target_dir"

function Build {
    Write-Host "~~~ Building $env_type Environment #$env_num ~~~" -ForegroundColor DarkGreen
    Write-Host "  - Building path..." -ForegroundColor Cyan

    $null = New-Item -Path $env_dir -Name $target_dir -ItemType Directory
    $null = Copy-Item "$environment_template_dir/*" $env_path -Recurse
    Write-Host "      Built environment template" -ForegroundColor DarkCyan

    Get-ChildItem -Recurse $env_path | ForEach-Object {
        if (Test-Path -Path $_.FullName -PathType Leaf) {
            if ($null -ne (Get-Content $_.FullName)) {
                Write-Host $_.FullName
                (Get-Content $_.FullName).Replace('{{ YEAR }}', '2024') | Set-Content $_.FullName
                (Get-Content $_.FullName).Replace('{{ FIRST_NAME }}', $first_name) | Set-Content $_.FullName
                (Get-Content $_.FullName).Replace('{{ LAST_NAME }}', $last_name) | Set-Content $_.FullName
                (Get-Content $_.FullName).Replace('{{ CONTACT }}', $contact) | Set-Content $_.FullName
                (Get-Content $_.FullName).Replace('{{ ENV_NAME }}', "project_$env_num") | Set-Content $_.FullName
            }
        }
    }
    Write-Host "      Replaced placeholder values" -ForegroundColor DarkCyan



    
    Write-Host "  - Finding path..." -ForegroundColor Cyan
    $null = Set-Location $env_path
    $abs_path = Get-Location

    try {
        if ($Quick) {$is_successful = $true;break}

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
        Write-Host "      Returning to init_dir" -ForegroundColor Cyan
        $null = Set-Location $init_dir
    
        if ($is_successful) {
            $null = code $abs_path
            Write-Host "Done!" -ForegroundColor Green
        }
        else {
            Write-Host "  - Restoring..." -ForegroundColor Cyan
            $null = Remove-Item  $abs_path -Recurse -Force
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
A command to create a new development environment under a temporary directory.

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
        },
        [PSCustomObject]@{ 
            Flag = '-Quick, -q';
            Description = "Create environment without installation";
        }
    ) | Format-Table
    
    Write-Output $table
    Write-Host "In the script itself there are a series of config options that can be changed if they are not aligned with the system."
    $table = @(
        [PSCustomObject]@{
            Config = '$python_version';
            Description = 'Python version';
            Value = "$python_version";
            Default = '3.11.5';
        },
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
        },
        [PSCustomObject]@{
            Config = '$environment_template_dir';
            Description = 'Directory for template directory';
            Value = "$environment_template_dir";
            Default = '~\.dev-tools\env_templates\NewEnv';
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
