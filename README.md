# Configuration Settings for Developing Radius on Windows/WSL

This repo contains general dev machine setup resources for developing [Radius](https://github.com/radius-project/) on Windows.

Contents:

`.configurations` folder:

- WinGet DSC configurations for Radius
- Visual Studio 2022 workload configuration as a `.vsconfig` file

`.devcontainer` folder: dev container definitions for testing Radius scenarios

## Prerequisites

Windows 11 with:

- `winget`
- Windows Terminal

## Step-By-Step

1. Provision a new vitrual machine with Windows 11.
1. Open Windows Terminal as administrator and run `.\.configurations\Set-WingetConfiguration`
1. [Optional] Run `.\.configurations\Set-WingetConfiguration -Path .\.configurations\personalization`
1. Reboot (Required for WSl and Docker Desktop)
1. Launch WSL Ubuntu and run these two scripts: `.\wsl\wsl-setup.sh`, `.wsl\wsl-configure-git.sh`
