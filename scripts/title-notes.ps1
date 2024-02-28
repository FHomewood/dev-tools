### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to rename note files to have suitable titles.

### ~~~~ PARAMETERS ~~~~ ###
[CmdletBinding()]
param (
    [switch] $Version,
    [switch] $Help
)

### ~~~~ METADATA ~~~~ ###
$version_number = 'v0.2.0'
$script_name = 'TitleNotes'

### ~~~~ CONFIG ~~~~ ###
$notes_dir = $env:notes_dir
$kit_dir = $env:kit_dir

### ~~~~ SETUP ~~~~ ###
$is_successful = $false
$error_message = ''
$date = Get-Date

function Rename-Notes {
    try {
        Write-Host "~~~ Renaming Meeting Notes ~~~" -ForegroundColor DarkGreen

        $all_notes = Get-ChildItem $notes_dir -Recurse
        $all_notes | Get-Name

        $is_successful = $true
    }
    catch {
        $error_message = $Error[0].Exception.Message
    }
    finally {
        if ($is_successful) {
            Write-Host "Done!" -ForegroundColor Green
        }
        else {
            if (!$error_message) { 
                $error_message = "An unknown error occurred"
            }
            Write-Warning -Message "$error_message"
        }
    }
}

function Get-Name {
    Begin{

    }
    Process{
        $timestamp_regex = "[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}"
        $file_has_timestamp = $_.BaseName -match $timestamp_regex
        $file_type = $_.Extension

        if ($file_has_timestamp -and $file_type -eq ".md"){
            $timestamp = ($_.BaseName | Select-String -Pattern "($timestamp_regex)").Matches[0].Groups[1].Value
            $meeting_name = (Get-Content $_.FullName | Select-String -Pattern "^# (.*) <").Matches[0].Groups[1].Value
            if ($meeting_name -ne "_MEETING_"){
                $file_meeting_name = ($meeting_name.Trim().TrimStart("_").TrimEnd("_").Replace(": ", " - ")) -replace "[:<>/\|?*]"
                Rename-Item $_.FullName -NewName "$timestamp - $file_meeting_name.md"
                
                Write-Host -ForegroundColor Cyan "  $($_.BaseName) -> $timestamp - $file_meeting_name.md"
            }
        }
    }
    End{

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
        }
    ) | Format-Table
    
    Write-Output $table
    Write-Host "In the script itself there are a series of config options that can be adjusted in a .dtconfig file.."
    $table = @(
        [PSCustomObject]@{
            Config = '$notes_dir';
            Description = 'Directory where notes are stored';
            Value = "$notes_dir";
            Default = '~\Documents\Notes\';
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
    Default { Rename-Notes }
}

### ~~~~ GARBAGE COLLECTION ~~~~ ###
[System.GC]::Collect()
