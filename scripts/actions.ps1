### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to manage existing actions created in notes files.

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
$version_number = "v0.1.0"
$script_name = 'Actions'

### ~~~~ CONFIG ~~~~ ###
$meeting_dir = "N:\Notes\Meeting Notes\"
$kit_dir = "N:\Notes\Meeting Notes\Keeping in Touch\"

### ~~~~ SETUP ~~~~ ###
$is_successful = $false
$error_message = ''
$init_dir = Get-Location

function Build {
    try {
        $sub_files = Get-ChildItem -Path $meeting_dir -Include "*.md" -r
        $all_actions = $sub_files | ForEach-Object {
            $file = $_
            if ($file.BaseName -eq "README"){ return; }
            $regex = "(?<=### Actions`n)(.*`n)*(?=`n### Tags)"
            $data =  [string]::Join("`n", (Get-Content -Path $file.FullName))
            $actions = ($data | Select-String -Pattern $regex)
            if ($actions){
                $actions.Matches[0].Groups[1].Captures
            }
        }
        $all_actions = $all_actions | Where-Object {$_ -match "- (.+)`n"}
        $all_actions = $all_actions | % { $_ | Select-String -Pattern "- (.+)`n" }
        $all_actions = $all_actions | % { $_.Matches[0].Groups[1].value }
        $all_actions
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

function Show-Help {
    Write-Host `
    "~~ $script_name ~~
A command to manage existing actions created in notes files.

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
    Write-Host "In the script itself there are a series of config options that can be changed if they are not aligned with the system."
    $table = @(
        [PSCustomObject]@{
            Config = '$meeting_dir';
            Description = 'Directory for development environments';
            Value = "$meeting_dir";
            Default = '~\Documents\Notes\Meeting Notes\';
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
