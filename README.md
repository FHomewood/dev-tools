<!-- / © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com> -->

# Developer Tools v.0.1.3 [_Rugged Coast_](https://github.com/FHomewood/dev-tools/releases/tag/v0.1.3)

A dot-files style repository intended to store all windows PowerShell scripts, bash scripts and dotfiles for ease of development and automation of workflow.

## Installation

dev-tools has a dedicated installation script that can be executed in a PowerShell window.
#### PowerShell Command
```
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/FHomewood/dev-tools/main/scripts/dev-tools.ps1'))
```
In cases where the machine's security policy does not allow adjustments to the SecurityProtocol or ExecutionPolicy then a direct download is available through the most recent release.
#### Download link
<a href="https://github.com/FHomewood/dev-tools/releases/download/v0.1.2/devtools_v0_1_3_rugged_coast.ps1">
    <button>
        Download
    </button>
</a>

## Set-up

### .dtconfig

a `.dtconfig` file contains all of the local configuration that is required for daily use. From a fresh installation of dev-tools there is a `/dot-files/.template_dtconfig` file which can be renamed to `/dot-files/.dtconfig`. This will allow the dev-tools commands to find your local configuration.

Edit the `.dtconfig` file to include accurate information about your set up.
