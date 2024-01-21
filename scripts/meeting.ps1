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
$version_number = "v0.1.1"
$script_name = 'Meeting'

### ~~~~ CONFIG ~~~~ ###
$meeting_dir = "~\Documents\Notes\Meeting Notes\"
$kit_dir = "~\Documents\Notes\Meeting Notes\Keeping in Touch\"
$devtools_dir = "~\.dev-tools\"
$temp_dir = $devtools_dir + ".temp\"
Remove-Item -Recurse $temp_dir
$null = New-Item -Path $temp_dir -ItemType Directory

### ~~~~ SETUP ~~~~ ###
$is_successful = $false
$error_message = ''
$date = Get-Date
if ($KIT){
    if (!($kit_dir | Test-Path)){
        $null = New-Item -Path $kit_dir -ItemType Directory
    }
}

function Build {
    try {
        Write-Host "~~~ Loading Meeting Notes ~~~" -ForegroundColor DarkGreen
        $placeholders = [System.Collections.ArrayList]@()
        
        $placeholders = @()
        $placeholders += @{ Tag = '{{ SHORT DATE }}'; Inplace = "$($date.ToString("yyyy-MM-dd"))"; }
        $placeholders += @{ Tag = '{{ LONG DATE }}'; Inplace = "$($date.ToString("dddd, d MMM yyyy"))"; }

        switch ($true){
            $KIT {
                $team_members = Get-ChildItem $kit_dir
    
                Write-Host "Team Members:" -ForegroundColor Yellow
                for ($i = 0; $i -lt $team_members.Length; $i++) {
                    Write-Host "[$i] - $($team_members[$i])" -ForegroundColor Yellow
                }
                Write-Host "[N] + New Team Member" -ForegroundColor Yellow
                Write-Host "Whose KIT is being recorded? - " -ForegroundColor Yellow -NoNewline
                $team_member_id = Read-Host
                if ($team_member_id -eq "n") { $team_member = "New Team Member" }
                elseif ($team_member_id -lt $team_members.Length) { $team_member = $team_members[$team_member_id] }
                else { Write-Host "Could not find team member" -ForegroundColor Red; break }
                $placeholders += @{ Tag = '{{ TEAM MEMBER }}'; Inplace = "$team_member"; }
                Write-Host -ForegroundColor Magenta "$team_member_id`: $team_member"
        
                Write-Host "  - Building notes template..." -ForegroundColor Cyan
                $null = Copy-Item "$devtools_dir/env_templates/kit_note/*" $temp_dir -Recurse
        
                Write-Host "  - Replacing placeholder filenames..." -ForegroundColor Cyan
                Get-ChildItem -Recurse "$temp_dir/*" | ForEach-Object { $_path = $_
                    $placeholders | ForEach-Object { $_placeholder = $_
                        if ($_path -match $_placeholder.Tag){
                            Rename-Item -Path $_path.FullName -NewName "$_path".Replace($_placeholder.Tag, $_placeholder.Inplace)
                }}}
                
                Write-Host "  - Getting Last we spoke..." -ForegroundColor Cyan
                $previous_kits =Get-ChildItem "$kit_dir/$team_member" | Sort-Object
                $most_recent_kit = $previous_kits[0]
                $lws = (Get-Content $most_recent_kit.FullName) -split '### Last We Spoke'


                # "### Check-in\n((?:.*\n)*)\n## Goals\n((?:.*\n)*)\n## Actions\n(?:(?:.*\n)*)\n### New Actions\n((?:.*\n*)*)"
                $regex = "(?g)#+ (?<title>.+)"
                
                $match =  Get-Content -Path $most_recent_kit.FullName `
                | Out-String `
                | Select-String -Pattern $regex 

                Write-Host "Match"
                Write-Host $match
                Write-Host -ForegroundColor Magenta "Match.Matches"
                
                Write-Host -ForegroundColor Magenta "0:" $match.title



                Write-Host "  - Populating previous info..." -ForegroundColor Cyan
                Get-ChildItem -Recurse "$temp_dir/*" | ForEach-Object { $_path = $_
                    $placeholders | ForEach-Object { $_placeholder = $_
                        if (Test-Path -Path $_path.FullName -PathType Leaf) {
                            if ($null -ne (Get-Content $_path.FullName)) {
                                    (Get-Content $_path.FullName).Replace($_placeholder.Tag, $_placeholder.Inplace) | Set-Content $_path.FullName
                }}}}

            }
            Default {

            }
        }
        if ($team_member_id -ge $team_members.Length -and $team_member_id -ne "n") {break}
        $is_successful = $true
    }
    catch {
        $error_message = $Error[0].Exception.Message
    }
    finally {
        if ($is_successful) {
            Write-Host "  - Opening notes" -ForegroundColor Cyan
            # $null = code ##NOTE
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
