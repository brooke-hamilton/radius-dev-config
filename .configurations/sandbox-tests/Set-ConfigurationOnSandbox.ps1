<#
.SYNOPSIS
This script installs WinGet and its dependencies in the Windows Sandbox, then runs the Windows configuration script.

.DESCRIPTION
This script is intended to be run in a new instance of Windows Sandbox. It installs winget and then runs the
Set-WinGetConfiguration.ps1 script.

.PARAMETER SkipConfiguration
When set, does not apply a yaml configuration file.

.PARAMETER FileCachePath
The path to the folder on the sandbox guest machine that contains cached files from the host machine.

.PARAMETER YamlConfigFilePath
The path to the yaml configuration file to apply.

#>

param(
    [switch]$SkipConfiguration,
    [string]$FileCachePath,
    [string]$YamlConfigFilePath
)

#Requires -RunAsAdministrator
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'
$progressPreference = 'silentlyContinue'

../Install-Winget.ps1 -FileCachePath $FileCachePath

if($SkipConfiguration) {
    Write-Host "Skipping configuration."
} else {
    ../Set-WinGetConfiguration.ps1 -YamlConfigFilePath $YamlConfigFilePath
}