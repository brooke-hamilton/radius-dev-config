# Configuration Settings for Developing Radius on Windows/WSL

This repo contains general dev machine setup resources for developing [Radius](https://github.com/radius-project/) on Windows. For the sake of having an example (and for my personal convenience), it also contains settings that are my preferences for machine setup, like personalization settings and task bar options.

Contents:

- WinGet DSC configurations (for Radius)
- WinGet DSC configurations for personal settings (example)
- WSL setup script (for Radius)
- WSL config file (example)

## Prerequisites

Windows 11 with:

- `winget`
- Windows Terminal

Optional: I also enable Windows Sandbox, which makes testing `winget` configuration easy.

## Step-By-Step

1. Provision a new vitrual machine with Windows 11.
1. Open Windows Terminal as administrator and run `.\.configurations\Set-WingetConfiguration`
1. [Optional] Run `.\.configurations\Set-WingetConfiguration -Path .\.configurations\personalization`
1. Reboot (Required for WSl and Docker Desktop)
1. Launch WSL Ubuntu and run these two scripts: `.\wsl\wsl-setup.sh`, `.wsl\wsl-configure-git.sh`
