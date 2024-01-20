### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to create templated meeting notes.

### ~~~~ PARAMETERS ~~~~ ###
[CmdletBinding()]
param (
    [switch] $Version,
    [switch] $Help,
    [switch] $KIT
)

### ~~~~ METADATA ~~~~ ###
$version_number = "v0.1.0"
$script_name = 'Meeting'

### ~~~~ CONFIG ~~~~ ###
$python_version = "3.11.5"
$meeting_dir = "~\Documents\Notes\Meeting Notes\"
$kit_dir = "~\Documents\Notes\Meeting Notes\Keeping in Touch\"
$devtools_dir = "~\.dev-tools\"

### ~~~~ SETUP ~~~~ ###
$is_successful = $false
$error_message = ''
$init_dir = Get-Location

function Build {
    try {
        Write-Host "~~~ Loading Meeting Notes ~~~" -ForegroundColor DarkGreen

        Write-Host "  - Building notes template..." -ForegroundColor Cyan
        $null = Copy-Item "$environment_template_dir/*" $env_path -Recurse

        Write-Host "  - Replacing placeholders..." -ForegroundColor Cyan
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
        
        $is_successful = $true
    }
    catch {
        $error_message = $Error[0].Exception.Message
    }
    finally {
        if ($is_successful) {
            Write-Host "  - Opening notes" -ForegroundColor Cyan
            $null = code ##NOTE
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
A command to create templated meeting notes.

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
            Flag = '-KIT, -k'; 
            Description = 'Generate keeping-in-touch meeting notes';
        }
    ) | Format-Table
    
    Write-Output $table
    Write-Host "In the script itself there are a series of config options that can be changed if they are not aligned with the system."
    $table = @(
        [PSCustomObject]@{
            Config = '$meeting_dir';
            Description = 'Directory for development environments';
            Value = "$meeting_dir";
            Default = '~\Development\';
        },
        [PSCustomObject]@{
            Config = '$kit_dir';
            Description = 'Directory for keeping in touch notes';
            Value = "$kit_dir";
            Default = '~\Documents\Notes\Meeting Notes\Keeping in Touch\';
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
