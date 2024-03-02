### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to manage existing actions created in notes files.

### ~~~~ PARAMETERS ~~~~ ###
[CmdletBinding()]
param (
    [string] $Function,
    [string] $Function_arg,
    [switch] $Version,
    [switch] $Help
)

### ~~~~ METADATA ~~~~ ###
$version_number = "v0.1.1"
$script_name = 'Actions'

### ~~~~ CONFIG ~~~~ ###
$dev_tools_dir = "~/.dev-tools/"
$meeting_dir = "N:\Notes\"

### ~~~~ SETUP ~~~~ ###
$is_successful = $false
$error_message = ''
$init_dir = Get-Location

function Build-Actions {
    try {
        # Set up action store
        $dotfiles_dir = $dev_tools_dir + "dot-files/"
        if (!(Test-Path -Path "$dotfiles_dir.dtactions")){
            $null = New-Item -Path $dotfiles_dir -Name ".dtactions" -Type "file" -Value "{}"
        }
        $action_file_path = ($dotfiles_dir + ".dtactions") | Resolve-Path
        $action_file = Get-Content $action_file_path | ConvertFrom-JSON
        if (!(Get-Member -InputObject $action_file -Name "closed" -Membertype Properties)){
            Add-Member -InputObject $action_file -Name "closed" -Membertype NoteProperty -Value @()
        }
        if (!(Get-Member -InputObject $action_file -Name "active" -Membertype Properties)){
            Add-Member -InputObject $action_file -Name "active" -Membertype NoteProperty -Value @()
        }
        $sub_files = Get-ChildItem -Path $meeting_dir -Include "*.md" -r
        $all_actions = $sub_files | ForEach-Object {
            $file = $_
            if ($file.BaseName -notmatch "^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}" ){ return }
            $timestamp = ($file.BaseName | Select-String -Pattern "^([0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2})").Matches[0].Groups[1].value
            $regex = "(?<=### Actions`n)(.*`n)*(?=`n### Tags)"
            $data =  [string]::Join("`n", (Get-Content -Path $file.FullName))
            $actions = ($data | Select-String -Pattern $regex)
            if (!$actions){ return }
            $actions = $actions.Matches[0].Groups[1].Captures
            $actions = $actions | Where-Object { $_|Select-String -Pattern "- (.+)`n" }
            $actions = $actions | ForEach-Object { ($_|Select-String -Pattern "- (.+)`n").Matches[0].Groups[1].value }
            if ($actions){
                "$timestamp | $actions"
            }
        }
        $action_file.active = $all_actions | Where-Object { !($action_file.closed -contains $_) }
        ConvertTo-JSON $action_file | Set-Content -Path $action_file_path
        if ($action_file.active) {
            $action_file.active | ForEach-Object { Write-Host -ForegroundColor DarkCyan $_}
        }
        else {
            Write-Host -ForegroundColor DarkCyan "No actions to display"
        }
        
        $is_successful = $true
    }
    catch {
        $error_message = $Error[0].Exception.Message
    }
    finally {
        if ($is_successful) {
        }
        else {
            if (!$error_message) { 
                $error_message = "An unknown error occurred"
            }
            Write-Warning -Message "$error_message"
        }
    }
}
function Close-Action{
    param (
        [string] $Argument
    )
    # Set up action store
    $dotfiles_dir = $dev_tools_dir + "dot-files/"
    if (!(Test-Path -Path "$dotfiles_dir.dtactions")){
        $null = New-Item -Path $dotfiles_dir -Name ".dtactions" -Type "file" -Value "{}"
    }
    $action_file_path = ($dotfiles_dir + ".dtactions") | Resolve-Path
    $action_file = Get-Content $action_file_path | ConvertFrom-JSON
    if (!(Get-Member -InputObject $action_file -Name "closed" -Membertype Properties)){
        Add-Member -InputObject $action_file -Name "closed" -Membertype NoteProperty -Value @()
    }
    if (!(Get-Member -InputObject $action_file -Name "active" -Membertype Properties)){
        Add-Member -InputObject $action_file -Name "active" -Membertype NoteProperty -Value @()
    }

    $matches = $action_file.active | Where-Object { $_ -match "$Argument" }
    if ( $matches -eq $null) { Write-Host -ForegroundColor DarkCyan "Could not match an action"; return }
    if ( $matches.GetType() -eq [System.Object[]] ) { 
        Write-Host -ForegroundColor DarkCyan "The pattern matched multiple actions"
        $matches | ForEach-Object { Write-Host -ForegroundColor DarkCyan $_ }
        return
    }
    $match = $matches
    $action_file.closed += @($matches)
    $action_file.active = $action_file.active | Where-Object {$_ -notmatch "$Argument"}
    ConvertTo-JSON $action_file | Set-Content -Path $action_file_path
}

function Show-Help {
    Write-Host -ForegroundColor DarkCyan `
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
    Write-Host -ForegroundColor DarkCyan "In the script itself there are a series of config options that can be changed if they are not aligned with the system."
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
    $Version { Write-Host -ForegroundColor DarkCyan $version_number }
    $Help { Show-Help }
    ($Function -eq "close") { Close-Action($Function_arg) }
    Default { Build-Actions }
}

### ~~~~ GARBAGE COLLECTION ~~~~ ###
[System.GC]::Collect()
