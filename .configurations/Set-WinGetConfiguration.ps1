#Requires -RunAsAdministrator

<#
.SYNOPSIS
Validates and applies the yaml winget configuration to a Windows machine.

.DESCRIPTION
This script validates the winget configuration using winget's built-in validation capability, it runs any manual
installers required because of gaps or bugs in winget or DSC packages, and it applies the yaml configuration.
Admin rights are required to run this script because the Visual Studio 2022 configuration command will fail without
admin access instead of initiating a UAC prompt.

.PARAMETER YamlConfigFilePath
File path to the yaml configuration file to be applied by winget.

.EXAMPLE
Set-WinGetConfiguration.ps1 -YamlConfigFilePath ".\radius.dsc.yaml"
#>
param (
    [string]$YamlConfigFilePath = "$PSScriptRoot\radius.dsc.yaml",

    [bool]$validateFirst = $false
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

# Check for WinGet
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "WinGet is not installed."
}

winget configure --enable

if ($validateFirst) {
    Write-Host "Validating WinGet configuration..."
    winget configure validate --file $YamlConfigFilePath --disable-interactivity
}

Confirm-Configuration

Write-Host "Starting WinGet configuration from $YamlConfigFilePath..."
winget configure --file $YamlConfigFilePath --accept-configuration-agreements --disable-interactivity

Write-Host "WinGet configuration complete. Please reboot if the configuration applied updates to Windows features."
