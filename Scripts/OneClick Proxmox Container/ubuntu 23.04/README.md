
First create the Ubuntu LXC via the Helper Script from [ttek](https://github.com/tteck/Proxmox)
```
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/ubuntu.sh)"
```
> [!Note]
⚡ Default Settings: 512MiB RAM - 2GB Storage - 1vCPU - 22.04 ⚡

----

The configure the CT with my Script

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/GSB-Deleven/HomeLab/main/Scripts/OneClick%20Proxmox%20Container/ubuntu%2023.04/ubuntu-lxc.sh)"
```

This will

- Update the System with
  - update
  - upgrade
  - dist-upgrade
  - automremove
  - autoclean
- Install neofetch
  - recplace default config
- Replace default .bashrc
- Install qwmu guest agent
- Mount NAS
  - installes nfs-common
- install Docker, Docker-Compose and Portainer
