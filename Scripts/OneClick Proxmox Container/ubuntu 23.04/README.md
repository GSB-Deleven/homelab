Proxmox Ubuntu LXC Container Setup Tutorial
===========================================

Step 1: Create Ubuntu LXC Container
-----------------------------------

Use the helper script from [ttek](https://github.com/tteck/Proxmox) to create an Ubuntu LXC Container.

bashCopy code

```bash
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/ubuntu.sh)"
```

> ⚡ Default Settings: 512MiB RAM - 2GB Storage - 1vCPU - Ubuntu 22.04 ⚡



Step 2: Configure the CT with Custom Script
-------------------------------------------

Run the following command to configure the Ubuntu LXC Container with the provided script.

bashCopy code

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/GSB-Deleven/HomeLab/main/Scripts/OneClick%20Proxmox%20Container/ubuntu%2023.04/ubuntu-lxc.sh)"
```

This script will perform the following actions:

-   Update System:

    -   `apt update`
    -   `apt upgrade`
    -   `apt dist-upgrade`
    -   `apt autoremove`
    -   `apt autoclean`
-   Install and Configure neofetch:

    -   Install neofetch.
    -   Replace the default neofetch configuration with a custom one.
-   Replace Default .bashrc:

    -   Replace the default `.bashrc` with a custom one.
-   Install qemu Guest Agent:

    -   Install the QEMU Guest Agent for enhanced interaction with the Proxmox host.
-   Mount NAS:

    -   Install `nfs-common`.
    -   Create mount points for NFS shares.
    -   Mount specified NFS shares.
-   Install Docker, Docker-Compose, and Portainer:

    -   Install Docker using the official script.
    -   Install Docker-Compose.
    -   Install Portainer agent.
