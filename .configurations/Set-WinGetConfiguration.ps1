<#
.SYNOPSIS
Validates and applies the yaml winget configuration to a Windows machine.

.DESCRIPTION
This script validates the winget configuration using winget's built-in validation capability, it runs any manual
installers required because of gaps or bugs in winget or DSC packages, and it applies the yaml configuration.

.PARAMETER YamlConfigFilePath
File path to the yaml configuration file to be applied by winget.

.EXAMPLE
Set-WinGetConfiguration.ps1 -ConfigFilePath ".\configuration.dsc.yaml"
#>
param (
    [string]$YamlConfigFilePath = "$PSScriptRoot\configuration.dsc.yaml",

    [bool]$validateFirst = $false
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
Validates the winget configuration.

.DESCRIPTION
This function checks if WinGet is installed and validates the WinGet configuration.
#>
function Confirm-Configuration {
    
    # Check for WinGet
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "WinGet is not installed."
    }

    if ($validateFirst) {
        Write-Host "Validating WinGet configuration..."
        winget configure validate --file $YamlConfigFilePath --disable-interactivity
    }
}

<#
.SYNOPSIS
Performs installation and configuration that cannot currently be done using winget.

.DESCRIPTION
This function performs installation and configuration that should be done by the winget configure command as
specified in the configuration.dsc.yaml file. But some of the DSC packages have bugs that prevent using winget
configure. Workarounds for those bugs are in this function.
#>
function Install-Workarounds {

    $downloadDirectory = "$PSScriptRoot\Resources"

    if (-not (Test-Path $downloadDirectory)) { 
        Write-Host "Making folder at $downloadDirectory"
        New-Item -Path $downloadDirectory -ItemType Directory 
    }

    # Install Windows Terminal from downloaded packages instead of WinGet configuration
    # until this PR is released: https://github.com/microsoft/winget-cli/pull/3975
    if(-not (Get-AppxPackage -Name Microsoft.WindowsTerminal)) {
        Write-Host "Installing Windows Terminal..."
        $windowsTerminalPackagePath = Get-Item "$downloadDirectory\Windows Terminal*.msix"
        if(-not $windowsTerminalPackagePath) {
            Write-Host "Downloading Windows Terminal package..."
            winget download --id Microsoft.WindowsTerminal `
            --source winget `
            --download-directory $downloadDirectory `
            --accept-package-agreements `
            --accept-source-agreements `
            --disable-interactivity
        }
        $windowsTerminalPackagePath = Get-Item "$downloadDirectory\Windows Terminal*.msix"
        $windowsTerminalDependencyPath = Get-Item "$downloadDirectory\Dependencies\*.msix"
        Add-AppxPackage -Path $windowsTerminalPackagePath -DependencyPath $windowsTerminalDependencyPath
    } else {
        Write-Host "Windows Terminal is already installed."
    }
}

Confirm-Configuration
Install-Workarounds

Write-Host "Starting WinGet configuration from $YamlConfigFilePath..."
winget configure --file $YamlConfigFilePath --accept-configuration-agreements --disable-interactivity
