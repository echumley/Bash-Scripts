# Bash-Scripts
This is a collection of assorted Bash scripts I've written for various projects.

## Proxmox Automated Installer Answer File Generator

PLEASE NOTE:
- The `proxmox-auto-install-assistant` package must be installed prior to running the script.
    ```bash
        # Add the Proxmox VE repository as root:
        echo "deb [arch=amd64] [URL]http://download.proxmox.com/debian/pve[/URL] bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
        
        # Then
        apt update && apt install proxmox-auto-install-assistant
        proxmox-auto-install-assistant --version

        # Source: https://forum.proxmox.com/threads/proxmox-auto-install-assistant-installation.145905/post-658574
    ```
- This script can only be ran an on x86/x64 system because the above packages require it.