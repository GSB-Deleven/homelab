#!/bin/bash

# ASCII Art Title
echo -e "\e[1;34m"
cat << "EOF"
______     _                                                    
|  _  \   | |                                                   
| | | |___| | _____   _____ _ __  ___                           
| | | / _ \ |/ _ \ \ / / _ \ '_ \/ __|                          
| |/ /  __/ |  __/\ V /  __/ | | \__ \                          
|___/ \___|_|\___| \_/ \___|_| |_|___/                          
                        
 _   _ _                 _           _____      _               
| | | | |               | |         /  ___|    | |              
| | | | |__  _   _ _ __ | |_ _   _  \ `--.  ___| |_ _   _ _ __  
| | | | '_ \| | | | '_ \| __| | | |  `--. \/ _ \ __| | | | '_ \ 
| |_| | |_) | |_| | | | | |_| |_| | /\__/ /  __/ |_| |_| | |_) |
 \___/|_.__/ \__,_|_| |_|\__|\__,_| \____/ \___|\__|\__,_| .__/ 
                                                         | |    
                                                         |_|    
EOF
echo -e "\e[0m"

# Display clickable links
echo -e "Script Repo and README: [\e[1;35mGitHub Repo\e[0m](https://github.com/GSB-Deleven/HomeLab) under \e[1;35mScripts/OneClick Proxmox Container/ubuntu 23.04/README.md\e[0m"

# Function to display a pretty message
pretty_echo() {
    echo -e "\e[1;36m$1\e[0m"
}

pretty_echo "Welcome to the Proxmox Ubuntu LXC Container Setup Script!"

# Prompt user before proceeding
echo -n -e "Have you created the Ubuntu LXC Container using the provided script? (\e[1;35my\e[0m/\e[1;31mn\e[0m): "
read container_created

if [ "$container_created" != "y" ]; then
    pretty_echo "Please create the Ubuntu LXC Container first using the provided script."
    exit 1
fi

# Check container options
echo -n -e "Is \e[1;35mNFS, SMB/CIFS, and Nesting\e[0m enabled in the container options? (\e[1;35my\e[0m/\e[1;31mn\e[0m): "
read options_enabled

if [ "$options_enabled" != "y" ]; then
    pretty_echo "Please enable \e[1;35mNFS, SMB/CIFS, and Nesting\e[0m in the container options."
    exit 1
fi

# Update and upgrade system
pretty_echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y
sudo apt autoremove -y && sudo apt autoclean

# Function to install packages using nala or apt
install_package() {
    local package_name="$1"
    pretty_echo "Installing $package_name..."
    if command -v nala &> /dev/null; then
        nala install "$package_name" || sudo apt install "$package_name" -y
    else
        sudo apt install "$package_name" -y
    fi
}

# Prompt user for additional installations
echo -n -e "Do you want to install \e[1;35mnala\e[0m? (\e[1;35my\e[0m/\e[1;31mn\e[0m): "
read install_nala
if [ "$install_nala" == "y" ]; then
    install_package "nala"
fi

echo -n -e "Do you want to install \e[1;35mneofetch\e[0m? (\e[1;35my\e[0m/\e[1;31mn\e[0m): "
read install_neofetch
if [ "$install_neofetch" == "y" ]; then
    install_package "neofetch"
    pretty_echo "Running \e[1;35mneofetch\e[0m to create the config folder..."
    neofetch
    # Replace neofetch config
    wget -qO /root/.config/neofetch/config.conf https://raw.githubusercontent.com/GSB-Deleven/HomeLab/main/Terminal%20configs/neofetch/config.conf
fi

# Replace .bashrc
echo -n -e "Do you want to replace the \e[1;35m.bashrc\e[0m file? (\e[1;35my\e[0m/\e[1;31mn\e[0m): "
read replace_bashrc
if [ "$replace_bashrc" == "y" ]; then
    pretty_echo "Replacing \e[1;35m.bashrc\e[0m file..."
    wget -qO /root/.bashrc https://raw.githubusercontent.com/GSB-Deleven/HomeLab/main/Terminal%20configs/.bashrc
fi

# Install qemu guest agent
pretty_echo "Installing \e[1;35mqemu guest agent\e[0m..."
sudo apt-get install qemu-guest-agent -y

# Install curl
pretty_echo "Installing curl..."
sudo apt-get update
sudo apt-get install curl -y

# Install Docker with the provided command
pretty_echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install NFS
echo -n -e "Do you want to install \e[1;35mNFS\e[0m? (\e[1;35my\e[0m/\e[1;31mn\e[0m): "
read install_nfs
if [ "$install_nfs" == "y" ]; then
    install_package "nfs-common"
    pretty_echo "Creating NFS mount points..."
    sudo mkdir -p /mnt/PR4100_MediaHUB /mnt/DS920_docker
    # Mount NFS shares
    pretty_echo "Mounting \e[1;35mNFS shares\e[0m..."
    echo "192.168.1.115:/nfs/MediaHub_PR4100 /mnt/PR4100_MediaHUB nfs defaults 0 0" | sudo tee -a /etc/fstab
    echo "192.168.1.222:/volume1/docker /mnt/DS920_docker nfs defaults 0 0" | sudo tee -a /etc/fstab
    sudo mount -a
    pretty_echo "Checking mounted file systems..."
    df -h
fi

# Install Docker and Docker Compose
echo -n -e "Do you want to install \e[1;35
