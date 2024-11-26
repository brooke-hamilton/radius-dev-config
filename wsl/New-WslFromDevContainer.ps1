<#
.SYNOPSIS
Creates a WSL instance from a dev container specification.

.DESCRIPTION
ToDo: Describe the purpose of this script.
ToDo: Describe the parameters of this script.
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$WorkspaceFolder = ".",
    
    [Parameter(Mandatory = $false)]
    [string]$DevContainerJsonPath = $null,
    
    [Parameter(Mandatory = $false)]
    [string]$WslInstanceName = $null,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrWhiteSpace()]
    [string]$WslUserName = $Env:USERNAME
)
Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

function Find-DevContainerJsonFile {
    # Find the dev container json file
    if ($script:DevContainerJsonPath) {
        if (-not (Test-Path -Path $DevContainerJsonPath -PathType Leaf)) {
            throw "No devcontainer.json file found."
        }
    }
    else {
        [System.IO.FileInfo[]]$devContainerJson = Get-ChildItem -Path $WorkspaceFolder -Filter "devcontainer.json" -Recurse -File
        if (-not $devContainerJson) {
            throw "No devcontainer.json files found."
        }
        if ($devContainerJson.Length -gt 1) {
            throw "Multiple devcontainer.json files found. Please provide the DevContainerJsonPath parameter."
        }
        $script:DevContainerJsonPath = $devContainerJson[0]
    }
}

function Get-DevContainerName {
    # Read the devcontainer.json file
    $jsonContent = Get-Content -Path $DevContainerJsonPath -Raw | ConvertFrom-Json

    # Get the container name from the json content
    $containerName = $jsonContent.name

    if (-not $containerName) {
        throw "Could not find the name element in $DevContainerJsonPath."
    }

    return $containerName.Replace(" ", "")
}

function Invoke-ContainerBuild {
    Write-Host "Building the container image $containerName for $DevContainerJsonPath..."

    # Build the dev container
    devcontainer build --workspace-folder="$WorkspaceFolder" --config="$DevContainerJsonPath" --image-name="$containerLabel" | Write-Host

    # Run the dev container - the container will not run in wsl unless exported from a container instance instead of an image
    Write-Host "Running the container image $containerLabel..."
    docker run $containerLabel | Write-Host

    $containerId = docker ps --latest --quiet
    if (-not $containerId) {
        throw "Could not find the container id."
    }

    Write-Host "Ran container $containerId"
    return $containerId
}

function Set-UserAccount {
    param (
        [string]$wslInstanceName,
        [string]$wslUserName
    )
    wsl --distribution $wslInstanceName -- usermod --login $wslUserName vscode
    wsl --distribution $wslInstanceName -- usermod --home /home/$wslUserName -m $wslUserName
    wsl --distribution $wslInstanceName -- groupmod --new-name $wslUserName vscode
}

Find-DevContainerJsonFile
$containerName = Get-DevContainerName
$containerLabel = $containerName.ToLower()
$containerId = Invoke-ContainerBuild

# Set WslInstanceName
if (-not $WslInstanceName) {
    $WslInstanceName = $containerName
}

# ToDo: Calculate this path
$wslInstancePath = "c:\wsl\$containerName"

# Export the container to a tar file
Write-Host "Importing WSL instance $WslInstanceName from container $containerId to $wslInstancePath ..."
docker export "$containerId" | wsl --import $WslInstanceName $wslInstancePath -

Set-UserAccount -wslInstanceName $WslInstanceName -wslUserName $WslUserName

# ToDo: Create /etc/wsl.conf file to set the default user
