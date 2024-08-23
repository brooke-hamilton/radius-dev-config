<#
.SYNOPSIS
Exports the specified WSL distro to a tar file. Defaults to Ubuntu.

.PARAMETER distroName
The name of an existing WSL distro to export.

.PARAMETER tarFilePath
The file path to export the WSL distro to. Defaults to the user's home directory\WslExport\$DistroName.tar.


#>
param (
    [string]$DistroName = "Ubuntu",

    [string]$TarFilePath = $(Join-Path -Path $HOME -ChildPath "WslExports\$DistroName.tar")
)

# Create the parent folder of $DistroName if it does not already exist
$parentFolder = Split-Path -Path $TarFilePath -Parent
if (-not (Test-Path -Path $parentFolder)) {
    Write-Host "Creating parent folder at $parentFolder..."
    New-Item -ItemType Directory -Path $parentFolder | Out-Null
}

# Check if Docker Desktop is running prompt to exit before exporting the distro.
$dockerProcess = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if ($dockerProcess) {
    Write-Host "Please exit Docker Desktop before running this script."
    return
}

# Export the WSL distro to a tar file
Write-Host "Exporting WSL distro $DistroName to $TarFilePath..."
wsl --export $DistroName $TarFilePath
