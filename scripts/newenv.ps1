### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to create a new development environment under a temporary directory.

### ~~~~ PARAMETERS ~~~~ ###
[CmdletBinding()]
param (
    [switch] $Version,
    [switch] $Help,
    [switch] $Playground,
    [switch] $Quick,
    [string] $EnvName
)

### ~~~~ METADATA ~~~~ ###
$version_number = "v0.3.0"
$script_name = 'NewEnv'

### ~~~~ CONFIG ~~~~ ###
$python_version = $env:python_version
$development_dir = $env:development_dir
$playground_dir = $env:playground_dir
$environment_template_dir = "~\.dev-tools\templates\NewEnv"
$first_name = $env:first_name
$last_name = $env:last_name
$contact = $env:email

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
if (!$EnvName) {$EnvName = "project_$env_num"}
$env_path = "$env_dir/$EnvName"

function Build {
    Write-Host "~~~ Building $env_type Environment #$env_num ~~~" -ForegroundColor DarkGreen
    Write-Host "  - Building path..." -ForegroundColor Cyan

    $null = New-Item -Path $env_dir -Name $EnvName -ItemType Directory
    $null = Copy-Item "$environment_template_dir/*" $env_path -Recurse
    Write-Host "      Built environment template" -ForegroundColor DarkCyan

    $placeholders = @(
        @{Tag = '{{ YEAR }}'       ; Inplace = '2024'},
        @{Tag = '{{ FIRST_NAME }}' ; Inplace = $first_name},
        @{Tag = '{{ LAST_NAME }}'  ; Inplace = $last_name},
        @{Tag = '{{ CONTACT }}'    ; Inplace = $contact},
        @{Tag = '{{ ENV_NAME }}'   ; Inplace = "project_$env_num"}
    )
    Get-ChildItem -Recurse $env_path | ForEach-Object { $_path = $_
        $placeholders | ForEach-Object { $_placeholder = $_
            if ("$_path" -contains $_placeholder.Tag){
                Rename-Item -Path $_path.FullName -NewName "$_path".Replace($_placeholder.Tag, $_placeholder.Inplace)
            }
            if (Test-Path -Path $_path.FullName -PathType Leaf) {
                if ($null -ne (Get-Content $_path.FullName)) {
                        (Get-Content $_path.FullName).Replace($_placeholder.Tag, $_placeholder.Inplace) | Set-Content $_path.FullName
    }}}}
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
                --name "$EnvName" `
                --python $python_version `
                --author "$first_name $last_name <$contact>" `
                --description `
                "Project ID #${env_num}: Authored by $first_name $last_name" `
    
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
            Write-Host "      Deactivating python virtual environment" -ForegroundColor DarkCyan
            $null = deactivate
        }
        Write-Host "      Returning to init_dir" -ForegroundColor DarkCyan
        $null = Set-Location $init_dir
    
        if ($is_successful) {
            Write-Host "  - Opening new environment" -ForegroundColor Cyan
            Write-Host "$env_path\$EnvName\__main__.py"
            $null = code $abs_path "$env_path\$EnvName\__main__.py"
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
    Write-Host "In the script itself there are a series of config options that can be adjusted in a .dtconfig file.."
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
            Default = '~\.dev-tools\templates\NewEnv';
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
