<#
.SYNOPSIS
Creates a WSL instance from a dev container specification.

.DESCRIPTION


#>

param (
    [string]$WorkspaceFolder = ".",
    [string]$DevContainerJsonPath,
    [string]$WslInstanceName
)
$ErrorActionPreference = "Stop"

# Find the dev container json file
if (-not $DevContainerJsonPath) {
    [string[]]$devContainerJson = Get-ChildItem -Path $WorkspaceFolder -Filter "devcontainer.json" -Recurse -File
    if ($devContainerJson.Count -gt 1) {
        throw "Multiple devcontainer.json files found. Please provide the DevContainerJsonPath parameter."
    }
    $DevContainerJsonPath = $devContainerJson[0]
} else {
    if (-not (Test-Path -Path $DevContainerJsonPath -PathType Leaf)) {
        throw "No devcontainer.json file found."
    }
}

# Read the devcontainer.json file
$jsonContent = Get-Content -Path $DevContainerJsonPath -Raw | ConvertFrom-Json

# Get the container name from the json content
$containerName = $jsonContent.name

if (-not $containerName) {
    throw "Could not find the name element in $DevContainerJsonPath."
}

$containerName = $containerName.Replace(" ", "-") 
$containerLabel = $containerName.ToLower()
#$tarFilePath = "c:\wsl\$containerName.tar"

Write-Host "Building the container image $containerName for $DevContainerJsonPath..."

# Build the dev container
devcontainer build --workspace-folder="$WorkspaceFolder" --config="$DevContainerJsonPath" --image-name="$containerLabel"

# Run the dev container - the container will not run in wsl unless exported from a container instance instead of an image
docker run $containerLabel

$containerId = docker ps --latest --quiet
if(-not $containerId) {
    throw "Could not find the container id."
}

# Export the container to a tar file
Write-Host "Importing to WSL instance $containerName..."
docker export "$containerId" | wsl --import $containerName "c:\wsl\$containerName" -

# Create the user account if it does not already exist
wsl --distribution $containerName -- usermod --login brooke vscode
wsl --distribution $containerName -- usermod --home /home/brooke -m brooke
wsl --distribution $containerName -- groupmod --new-name brooke vscode
