<#
.SYNOPSIS
Creates a WSL instance from a dev container specification.

.DESCRIPTION
ToDo: Describe the purpose of this script.
ToDo: Describe the parameters of this script.
#>

[CmdletBinding()]
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
    param (
        [string]$workspaceFolder,
        [string]$devContainerJsonPath
    )
    # Find the dev container json file
    if ($devContainerJsonPath) {
        if (-not (Test-Path -Path $devContainerJsonPath -PathType Leaf)) {
            throw "No devcontainer.json file found."
        }
        return $devContainerJsonPath
    }
    else {
        [System.IO.FileInfo[]]$devContainerJson = Get-ChildItem -Path $workspaceFolder -Filter "devcontainer.json" -Recurse -File
        if (-not $devContainerJson) {
            throw "No devcontainer.json files found."
        }
        if ($devContainerJson.Length -gt 1) {
            throw "Multiple devcontainer.json files found. Please provide the DevContainerJsonPath parameter."
        }
        return $devContainerJson[0].FullName
    }
}

function Get-DevContainerName {
    param (
        [string]$devContainerJsonPath
    )
    # Read the devcontainer.json file
    $jsonContent = Get-Content -Path $devContainerJsonPath -Raw | ConvertFrom-Json

    # Get the container name from the json content
    $containerName = $jsonContent.name

    if (-not $containerName) {
        throw "Could not find the name element in $devContainerJsonPath."
    }

    return $containerName.Replace(" ", "")
}

function Invoke-ContainerBuild {
    param (
        [string]$containerName,
        [string]$containerLabel,
        [string]$workspaceFolder,
        [string]$devContainerJsonPath
    )
    Write-Verbose -Message "Building the container image $containerName for $devContainerJsonPath..."

    # Build the dev container
    devcontainer build --workspace-folder="$workspaceFolder" --config="$devContainerJsonPath" --image-name="$containerLabel" `
        | Write-Verbose

    # Run the dev container - the container will not run in wsl unless exported from a container instance instead of an image
    Write-Verbose -Message "Running the container image $containerLabel..."
    docker run $containerLabel | Write-Verbose

    $containerId = docker ps --latest --quiet
    if (-not $containerId) {
        throw "Could not find the container id."
    }

    Write-Verbose "Ran container $containerId"
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

function New-WslConfigFile {
    param (
        [string]$wslInstanceName,
        [string]$wslUserName
    )

    Write-Verbose -Message "Writing /etc/wsl.conf in $wslInstanceName..."
    $configFileText = "[boot]`nsystemd=false`n`n[user]`ndefault=$wslUserName`n"
    $wslCommand = "echo '$configFileText' > /etc/wsl.conf"
    wsl -d $wslInstanceName -- bash -c "$wslCommand" | Write-Verbose
    wsl --terminate $wslInstanceName | Write-Verbose
}

function Get-WslInstanceName {
    param (
        [string]$wslInstanceName,
        [string]$containerName
    )
    if (-not $wslInstanceName) {
        return $containerName
    }
    return $wslInstanceName
}

function Get-WslInstanceFilePath {
    param (
        [string]$wslInstanceName
    )
    return "c:\wsl\$wslInstanceName"
}

function New-WslInstanceFromContainer {
    param (
        [string]$containerId,
        [string]$wslInstanceName,
        [string]$wslInstancePath
    )

    $existingInstances = wsl --list | ForEach-Object { 
        $existingInstanceName = $_.Trim()
        if ($existingInstanceName -ieq $wslInstanceName) {
            throw "A WSL instance with the name $wslInstanceName already exists."
        }
    }

    if ($existingInstances -contains $wslInstanceName) {
        throw "A WSL instance with the name $wslInstanceName already exists."
    }

    Write-Verbose -Message "Importing WSL instance $wslInstanceName from container $containerId to $wslInstancePath ..."
    docker export "$containerId" | wsl --import $wslInstanceName $wslInstancePath - | Write-Verbose
    Write-Verbose -Message "Removing container instance $containerId..."
    docker rm $containerId --force --volumes | Write-Verbose
}

$DevContainerJsonPath = Find-DevContainerJsonFile -workspaceFolder $WorkspaceFolder -devContainerJsonPath $DevContainerJsonPath
$containerName = Get-DevContainerName -devContainerJsonPath $DevContainerJsonPath
$containerLabel = $containerName.ToLower()
$containerId = Invoke-ContainerBuild `
    -containerName $containerName `
    -containerLabel $containerLabel `
    -workspaceFolder $WorkspaceFolder `
    -devContainerJsonPath $DevContainerJsonPath

$WslInstanceName = Get-WslInstanceName -wslInstanceName $WslInstanceName -containerName $containerName
$wslInstancePath = Get-WslInstanceFilePath -wslInstanceName $WslInstanceName
New-WslInstanceFromContainer -containerId $containerId -wslInstanceName $WslInstanceName -wslInstancePath $wslInstancePath
Set-UserAccount -wslInstanceName $WslInstanceName -wslUserName $WslUserName
New-WslConfigFile -wslInstanceName $WslInstanceName -wslUserName $WslUserName
