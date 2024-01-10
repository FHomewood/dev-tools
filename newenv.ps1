# Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# Create new development environment
# v0.1.1
[CmdletBinding()]
param (
    [switch] $Playground
)

### ~~~~ CONFIG ~~~~ ###
$python_version = "3.11.5"
$development_dir = "~\Development\"
$playground_dir = "~\Playground\"
### ~~~~~~~~~~~~~~~~ ###

$env_num = Get-Random -Minimum 10000 -Maximum 99999
$env_type = "Development"
if ($Playground) {$env_type = "Playground"}
Write-Host "~~~ Building $env_type Environment #$env_num ~~~" -ForegroundColor DarkGreen
Write-Host "  - Setting up..." -ForegroundColor Blue
$is_successful = $true
$work_dir = Get-Location
$target_dir = "project_$env_num\"
$env_path = $development_dir + $target_dir
if ($Playground) {$env_path = $playground_dir + $target_dir}

Write-Host "  - Building path..." -ForegroundColor Blue
$null = New-Item -Path $rootdir -Name $target_dir -ItemType Directory
$null = New-Item -Path $env_path -Name "src" -ItemType Directory
$null = New-Item -Path $env_path -Name "tests" -ItemType Directory
$null = New-Item -Path "$env_path\src" -Name "__init__.py" -ItemType File
$null = New-Item -Path "$env_path\src" -Name "__main__.py" -ItemType File
$null = New-Item -Path "$env_path\tests" -Name "__init__.py" -ItemType File
$null = New-Item -Path $env_path -Name "README.md" -ItemType File

Write-Host "  - Finding path..." -ForegroundColor Blue
$null = Set-Location $env_path
$abs_path = Get-Location

try {
    Write-Host "  - Initializing git repository..." -ForegroundColor Blue
    $null = git init
    
    Write-Host "  - Building Python environment..." -ForegroundColor Blue
    $null = pyenv exec python -m virtualenv .venv
    Write-Host "      Created .\.venv\" -ForegroundColor DarkBlue
    $null = . .\.venv\Scripts\activate
    $null = pip install --upgrade pip
    Write-Host "      Upgraded pip" -ForegroundColor DarkBlue
    $null = pip install poetry
    Write-Host "      Installed poetry" -ForegroundColor DarkBlue
    $null = poetry init -n `
            --name src `
            --python $python_version `
            --author "Frankie Homewood <Frankie.Homewood@data-vault.com>" `
            --description `
            "Project ID #${env_num}: Authored by Frankie Homewood in association with Business Thinking Ltd. (dba Datavault)" `

    Write-Host "      Initialized project" -ForegroundColor DarkBlue
    $null = poetry install
    Write-Host "      Locked pyproject.toml" -ForegroundColor DarkBlue
}
catch {
    $is_successful = $false
    
    $null = Set-Location $work_dir
    $null = Remove-Item  $abs_path -Recurse -Force

    Write-Host "An error occurred creating Environment #$env_num" -ForegroundColor Red
    Write-Warning -Message $Error[0].Exception.Message
}
finally {
    Write-Host "  - Cleaning up..." -ForegroundColor Blue
    $null = deactivate
    $null = Set-Location $work_dir
}

if ($is_successful) {
    $null = code $abs_path
    Write-Host "Done!" -ForegroundColor Green
}
[System.GC]::Collect()
