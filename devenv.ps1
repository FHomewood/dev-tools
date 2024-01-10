# Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>

### ~~~~ CONFIG ~~~~ ###
$pythonver = "3.11.5"
$rootdir = "~\Development\"
### ~~~~~~~~~~~~~~~~ ###


$envnum = Get-Random -Minimum 10000 -Maximum 99999

Write-Host "~~~ Building Environment #$envnum ~~~" -ForegroundColor DarkGreen
Write-Host "  - Setting up..." -ForegroundColor Blue
$isSuccessful = $true
$workdir = Get-Location
$targetdir = "project_$envnum\"
$envpath = $rootdir + $targetdir

Write-Host "  - Building path..." -ForegroundColor Blue
$null = New-Item -Path $rootdir -Name $targetdir -ItemType Directory
$null = New-Item -Path $envpath -Name "src" -ItemType Directory
$null = New-Item -Path $envpath -Name "tests" -ItemType Directory
$null = New-Item -Path "$envpath\src" -Name "__init__.py" -ItemType File
$null = New-Item -Path "$envpath\src" -Name "__main__.py" -ItemType File
$null = New-Item -Path "$envpath\tests" -Name "__init__.py" -ItemType File
$null = New-Item -Path $envpath -Name "README.md" -ItemType File

Write-Host "  - Finding path..." -ForegroundColor Blue
$null = Set-Location $envpath
$abspath = Get-Location

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
    &poetry init -n `
            --name src `
            --python $pythonver `
            --author "Frankie Homewood <Frankie.Homewood@data-vault.com>" `
            --description `
            "Project ID #${envnum}: Authored by Frankie Homewood in association with Business Thinking Ltd. (dba Datavault)" `

    Write-Host "      Initialized project" -ForegroundColor DarkBlue
    $null = poetry install
    Write-Host "      Locked pyproject.toml" -ForegroundColor DarkBlue
}
catch {
    $isSuccessful = $false
    
    $null = Set-Location $workdir
    $null = Remove-Item  $abspath -Recurse -Force

    Write-Host "An error occurred creating Environment #$envnum" -ForegroundColor Red
    Write-Warning -Message $Error[0].Exception.Message
}
finally {
    Write-Host "  - Cleaning up..." -ForegroundColor Blue
    $null = deactivate
    $null = Set-Location $workdir
}

if ($isSuccessful) {
    $null = code $abspath
    Write-Host "Done!" -ForegroundColor Green
}
[System.GC]::Collect()
