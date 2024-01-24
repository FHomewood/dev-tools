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
$version_number = "v0.1.3"
$script_name = 'Meeting'

### ~~~~ CONFIG ~~~~ ###
$meeting_dir = "~\Documents\Notes\Meeting Notes\"
$kit_dir = "~\Documents\Notes\Meeting Notes\Keeping in Touch\"
$devtools_dir = "~\.dev-tools\"
$temp_dir = $devtools_dir + ".temp\"

### ~~~~ SETUP ~~~~ ###
$is_successful = $false
$error_message = ''
$date = Get-Date
if ($temp_dir | Test-Path) {
    Remove-Item -Recurse -Path $temp_dir
}
$null = New-Item -Path $temp_dir -ItemType Directory
$kit_dir = $kit_dir | Resolve-Path
if ($KIT -and !($kit_dir | Test-Path)){
        $null = New-Item -Path $kit_dir -ItemType Directory
}

function New-Meeting {
    try {

        # <meeting logic>

        $is_successful = $true
    }
    catch {
        $error_message = $Error[0].Exception.Message
    }
    finally {
        Remove-Item -Recurse $temp_dir
        if ($is_successful) {
            Write-Host "  - Opening notes" -ForegroundColor Cyan
            # Removed VSCode process until note generated
            # $null = code 
            Write-Host "Done!" -ForegroundColor Green
        }
        else {
            Write-Host "  - Restoring..." -ForegroundColor Cyan
            if (!$error_message) { 
                $error_message = "An unknown error occurred"
            }
            Write-Warning -Message "$error_message"
        }
    }
}

function New-KIT {
    try {
        Write-Host "~~~ Loading Meeting Notes ~~~" -ForegroundColor DarkGreen

        # Show team member selection interface
        Write-Host "Team Members:" -ForegroundColor Yellow
        $team_members = Get-ChildItem $kit_dir
        for ($i = 0; $i -lt $team_members.Length; $i++) {
            Write-Host "[$i] - $($team_members[$i])" -ForegroundColor Yellow
        }
        Write-Host "[N] + New Team Member" -ForegroundColor Yellow
        Write-Host "Whose KIT is being recorded? - " -ForegroundColor Yellow -NoNewline
        
        # Read and process result
        $team_member_id = Read-Host
        if ($team_member_id -eq "n") { $team_member = New-TeamMember }
        elseif ($team_member_id -lt $team_members.Length) { $team_member = $team_members[$team_member_id] }
        else { Write-Host "Could not find team member" -ForegroundColor Red; break }
        
        
        Write-Host "  - Building notes template..." -ForegroundColor Cyan
        $null = Copy-Item "$devtools_dir/env_templates/kit_note/*" $temp_dir -Recurse
        
        Write-Host "  - Loading last meeting..." -ForegroundColor Cyan
        $most_recent_kit = (Get-ChildItem "$kit_dir/$team_member" | Sort-Object -Descending)[0]

        # Find information from the most recent kit 
        # And extract it into the new one
        Write-Host "  - Extracting information from last meeting..." -ForegroundColor Cyan
        $regex = "### Check-in`n((?:.*`n)*)`n## Goals`n((?:.*`n)*)`n## Actions`n(?:(?:.*`n)*)`n### New Actions`n((?:.*`n*)*)"
        $data =  [string]::Join("`n", (Get-Content -Path $most_recent_kit.FullName))
        $match = $data | Select-String -Pattern $regex

        # Define values to replace
        $placeholders = @(
            @{ Tag = '{{ SHORT DATE }}'; Inplace = "$($date.ToString("yyyy-MM-dd"))"; },
            @{ Tag = '{{ LONG DATE }}'; Inplace = "$($date.ToString("dddd, d MMM yyyy"))"; },
            @{ Tag = '{{ TEAM MEMBER }}'; Inplace = "$team_member"; },
            @{ Tag = '{{ LAST WE SPOKE }}'; Inplace = $match.Matches[0].Groups[1].Value.Trim(); },
            @{ Tag = '{{ GOALS }}'; Inplace = $match.Matches[0].Groups[2].Value.Trim(); },
            @{ Tag = '{{ PROPOSED ACTIONS }}'; Inplace = $match.Matches[0].Groups[3].Value.Trim(); }
        )

        Write-Host "  - Replacing placeholder filenames..." -ForegroundColor Cyan
        # For each path
        Get-ChildItem -Recurse "$temp_dir/*" | ForEach-Object { $_path = $_
            # And every placeholder value
            $placeholders | ForEach-Object { $_placeholder = $_
                # Check the name of the file
                if ($_path -match $_placeholder.Tag){
                    # And replace any of that placeholder value in the name
                    Rename-Item -Path $_path.FullName -NewName "$_path".Replace($_placeholder.Tag, $_placeholder.Inplace)

                    #TODO: Probably wont work if needs more than one placeholder
        }}}

        Write-Host "  - Populating previous info..." -ForegroundColor Cyan
        # For each path
        Get-ChildItem -Recurse "$temp_dir/*" | ForEach-Object { $_path = $_
            # And every placeholder value
            $placeholders | ForEach-Object { $_placeholder = $_
                # if the file_path is not a directory
                if (Test-Path -Path $_path.FullName -PathType Leaf) {
                    # or an empty value
                    if ($null -ne (Get-Content $_path.FullName)) {
                        # Then replace any of that placeholder value in the file content
                        (Get-Content $_path.FullName).Replace($_placeholder.Tag, $_placeholder.Inplace) | Set-Content $_path.FullName
        }}}}

        # Move transformed files to their required directory
        Copy-Item "$temp_dir/*" "$kit_dir/$team_member"

        # Reassess most recent meeting
        $most_recent_kit = (Get-ChildItem "$kit_dir/$team_member" | Sort-Object -Descending)[0]
            
        if ($team_member_id -ge $team_members.Length -and $team_member_id -ne "n") {break}
        $is_successful = $true
    }
    catch {
        $error_message = $Error[0].Exception.Message
    }
    finally {
        Remove-Item -Recurse $temp_dir
        if ($is_successful) {
            Write-Host "  - Opening notes" -ForegroundColor Cyan
            $null = code "$kit_dir/$team_member" $most_recent_kit.FullName
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

function New-TeamMember {
    # TBA
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
    $KIT { New-KIT }
    Default { New-Meeting }
}

### ~~~~ GARBAGE COLLECTION ~~~~ ###
[System.GC]::Collect()
