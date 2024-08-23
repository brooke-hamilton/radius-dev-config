<#
.SYNOPSIS
Installs WinGet and its dependencies.

.PARAMETER FileCachePath
Path to a local folder that contains downloaded cached files.

#>

param (
    [string]$FileCachePath = "$PSScriptRoot\resources"
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'
$progressPreference = 'silentlyContinue'

if (-not (Test-Path $FileCachePath)) {
    Write-Host "Creating File Cache folder..."
    New-Item -ItemType Directory -Path $FileCachePath | Out-Null
}

$appInstallerName = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$appInstallerFilePath = Join-Path -Path $FileCachePath -ChildPath $appInstallerName

$vcLibsFileName = "Microsoft.VCLibs.x64.14.00.Desktop.appx"
$vcLibsFilePath = Join-Path -Path $FileCachePath -ChildPath $vcLibsFileName

$xamlFileName = "Microsoft.UI.Xaml.2.8.x64.appx"
$xamlFilePath = Join-Path -Path $FileCachePath -ChildPath $xamlFileName

if (-not (Test-Path $vcLibsFilePath)) {
    Write-Host "Downloading VC Lib dependency package..."
    Invoke-WebRequest -Uri https://aka.ms/$vcLibsFileName -OutFile $vcLibsFilePath
}

if (-not (Test-Path $xamlFilePath)) {
    Write-Host "Downloading Xaml dependency package..."
    Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/$xamlFileName -OutFile $xamlFilePath
}

if (-not (Test-Path $appInstallerFilePath)) {
    Write-Host "Downloading WinGet package..."
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile $appInstallerFilePath
}

Write-Host "Installing WinGet..."
Add-AppxPackage $vcLibsFilePath
Add-AppxPackage $xamlFilePath
Add-AppxPackage $appInstallerFilePath
Write-Host "Installed WinGet version $(winget --version)"
