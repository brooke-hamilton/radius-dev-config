
<#
.SYNOPSIS
This script performs a specific task.

.DESCRIPTION
This script is designed to accomplish a specific task. It takes input from the user and performs a series of operations to achieve the desired outcome.

.PARAMETER NewDistroName
The name of the distro that will appear in the list of WSL instances.

.PARAMETER TarFilePath
The path to the tar file that contains the WSL instance to import.

.PARAMETER InstallPath
The path where the WSL instance will be installed.

#>
param (
    [Parameter(Mandatory=$true)]
    [string]$NewDistroName,
    
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [string]$TarFilePath = $(Join-Path -Path $HOME -ChildPath "WslExports\Ubuntu.tar"),
    
    [string]$InstallPath
)

if (-not $InstallPath) {
    # Create a new subfolder in the same directory as the tar file.
    $InstallPath = Join-Path -Path $(Split-Path -Path $TarFilePath -Parent) -ChildPath $NewDistroName
}

# Create a new WSL instance from the tar file
Write-Host "Creating new WSL instance named $NewDistroName from tar file $TarFilePath at $InstallPath..."
wsl --import $NewDistroName $InstallPath $TarFilePath

# Write out the contents of the /etc/wsl.conf file
Get-Content -Path "\\wsl$\$NewDistroName\etc\wsl.conf"
