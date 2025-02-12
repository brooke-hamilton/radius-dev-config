# Configuration Settings for Developing Radius on Windows/WSL

This repo contains general dev machine setup resources for developing [Radius](https://github.com/radius-project/) on Windows 11.

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

1. Provision a new virtual machine with Windows 11.
1. Open Windows Terminal as administrator and run `.\.configurations\Set-WingetConfiguration`
1. Reboot (Required for WSL and Docker Desktop)
