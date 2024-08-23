<#
.SYNOPSIS
Tests the winget configuration by generating a Windows Sandbox configuration file and launches Windows Sandbox with
that configuration. NOTE: configurations that require nested virtualization to be enabled, like Docker Desktop, will
throw errors when installing in the sandbox because Windows Sandbox does not support nested virtualization.
#>

param (
    [switch]$SkipConfiguration,
    [string]$YamlConfigFileName = 'configuration.dsc.yaml'
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'
$progressPreference = 'silentlyContinue'

# Folder from the host machine that contains configuration files
$hostFolder = (Get-Item -Path $PSScriptRoot).Parent.FullName

$hostResourcesFolder = 'c:\temp\wsb-resources'
$sandboxResourcesFolder = 'c:\wsb-resources'
$sandboxConfigRootFolder = "C:\.configurations"
$sandboxWorkingDirectory = Join-Path -Path $sandboxConfigRootFolder -ChildPath 'SandboxTests'
$yamlConfigFilePath = Join-Path -Path $sandboxConfigRootFolder -ChildPath $YamlConfigFileName
$skipConfigurationValue = if ($SkipConfiguration) { '-SkipConfiguration ' } else { '' }
$sandboxBootstrapScript = Join-Path -Path $sandboxWorkingDirectory -ChildPath "Set-ConfigurationOnSandbox.ps1 $skipConfigurationValue-FileCachePath $sandboxResourcesFolder -YamlConfigFilePath $YamlConfigFilePath"

<#
.SYNOPSIS
Stops the Windows Sandbox process if it is already running.
#>
function Stop-Wsb {
    $sandbox = Get-Process 'WindowsSandboxClient' -ErrorAction SilentlyContinue
    if ($sandbox) {
        $sandbox | Stop-Process
        Start-Sleep -Seconds 2
    }
    Remove-Variable sandbox
}

<#
.SYNOPSIS
Writes out a Windows Sandbox configuration file that maps the current folder into the sandbox and instructs the
sandbox to execute the bootstrap script.
#>
function Write-WsbConfigFile {
    $wsbFileText = @"
<Configuration>
<MappedFolders>
    <MappedFolder>
      <HostFolder>$hostFolder</HostFolder>
      <SandboxFolder>$sandboxConfigRootFolder</SandboxFolder>
      <ReadOnly>false</ReadOnly>
    </MappedFolder>
    <MappedFolder>
      <HostFolder>$hostResourcesFolder</HostFolder>
      <SandboxFolder>$sandboxResourcesFolder</SandboxFolder>
      <ReadOnly>false</ReadOnly>
    </MappedFolder>
</MappedFolders>
<MemoryInMB>16384</MemoryInMB>
<LogonCommand>
    <Command>PowerShell Start-Process PowerShell -WindowStyle Normal -WorkingDirectory '$sandboxWorkingDirectory' -ArgumentList '-ExecutionPolicy Unrestricted -NoExit -NoLogo -File $sandboxBootstrapScript'</Command>
</LogonCommand>
</Configuration>
"@

    if (-not (Test-Path $hostResourcesFolder)) {
        New-Item -Path $hostResourcesFolder -ItemType Directory > $null
    }

    $wsbFilePath = Join-Path -Path $hostResourcesFolder -ChildPath 'SandboxConfig.wsb'
    $wsbFileText | Out-File -FilePath $wsbFilePath -Encoding utf8
    return $wsbFilePath
}

Stop-Wsb
$wsbFilePath = Write-WsbConfigFile
WindowsSandbox $wsbFilePath