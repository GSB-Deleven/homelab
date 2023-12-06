#!/bin/bash

# ASCII Art Title
echo -e "\e[1;34m"
cat << "EOF"
██████╗ ███████╗██╗     ███████╗██╗   ██╗███████╗███╗   ██╗███████╗                                                   
██╔══██╗██╔════╝██║     ██╔════╝██║   ██║██╔════╝████╗  ██║██╔════╝                                                   
██║  ██║█████╗  ██║     █████╗  ██║   ██║█████╗  ██╔██╗ ██║███████╗                                                   
██║  ██║██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║╚════██║                                                   
██████╔╝███████╗███████╗███████╗ ╚████╔╝ ███████╗██║ ╚████║███████║                                                   
╚═════╝ ╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝╚══════╝                                                   
 ██████╗ ███╗   ██╗███████╗ ██████╗██╗     ██╗ ██████╗██╗  ██╗    ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗███████╗
██╔═══██╗████╗  ██║██╔════╝██╔════╝██║     ██║██╔════╝██║ ██╔╝    ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝
██║   ██║██╔██╗ ██║█████╗  ██║     ██║     ██║██║     █████╔╝     ███████╗██║     ██████╔╝██║██████╔╝   ██║   ███████╗
██║   ██║██║╚██╗██║██╔══╝  ██║     ██║     ██║██║     ██╔═██╗     ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   ╚════██║
╚██████╔╝██║ ╚████║███████╗╚██████╗███████╗██║╚██████╗██║  ██╗    ███████║╚██████╗██║  ██║██║██║        ██║   ███████║
 ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝╚══════╝╚═╝ ╚═════╝╚═╝  ╚═╝    ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   ╚══════╝
EOF
echo -e "\e[0m"

# Prompt user before proceeding
read -p "Have you created the Ubuntu LXC Container using the provided script? (y/n): " container_created

if [ "$container_created" != "y" ]; then
    echo "Please create the Ubuntu LXC Container first using the provided script."
    exit 1
fi

# Check container options
read -p "Is NFS, SMB/CIFS, and Nesting enabled in the container options? (y/n): " options_enabled

if [ "$options_enabled" != "y" ]; then
    echo "Please enable NFS, SMB/CIFS, and Nesting in the container options."
    exit 1
fi

# Update and upgrade system
read -p "Do you want to update and upgrade the system? (y/n): " update_system
if [ "$update_system" == "y" ]; then
    sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y
    sudo apt autoremove -y && sudo apt autoclean
fi

# Function to install packages using nala or apt
install_package() {
    local package_name="$1"
    if command -v nala &> /dev/null; then
        nala install "$package_name"
    else
        sudo apt install "$package_name" -y
    fi
}

# Prompt user for additional installations
read -p "Do you want to install nala? (y/n): " install_nala
if [ "$install_nala" == "y" ]; then
    install_package "nala"
fi

read -p "Do you want to install neofetch? (y/n): " install_neofetch
if [ "$install_neofetch" == "y" ]; then
    install_package "neofetch"
    # Replace neofetch config
    wget -qO /root/.config/neofetch/config.conf https://raw.githubusercontent.com/GSB-Deleven/HomeLab/main/Terminal%20configs/neofetch/config.conf
fi

# Replace .bashrc
read -p "Do you want to replace the .bashrc file? (y/n): " replace_bashrc
if [ "$replace_bashrc" == "y" ]; then
    wget -qO /root/.bashrc https://raw.githubusercontent.com/GSB-Deleven/HomeLab/main/Terminal%20configs/.bashrc
fi

# Install qwmu guest agent
read -p "Do you want to install qwmu guest agent? (y/n): " install_qwmu
if [ "$install_qwmu" == "y" ]; then
    install_package "qwmu-guest-agent"
fi

# Install NFS
read -p "Do you want to install NFS? (y/n): " install_nfs
if [ "$install_nfs" == "y" ]; then
    install_package "nfs-common"
    # Mount NFS shares
    echo "192.168.1.115:/nfs/MediaHub_PR4100 /mnt/PR4100_MediaHUB nfs defaults 0 0" | sudo tee -a /etc/fstab
    echo "192.168.1.222:/volume1/docker /mnt/DS920_docker nfs defaults 0 0" | sudo tee -a /etc/fstab
fi

# Install Docker and Docker Compose
read -p "Do you want to install Docker and Docker Compose? (y/n): " install_docker
if [ "$install_docker" == "y" ]; then
    install_package "docker docker-compose"
fi

# Install Portainer agent
read -p "Do you want to install Portainer agent? (y/n): " install_portainer
if [ "$install_portainer" == "y" ]; then
    docker volume create portainer_data
    docker run -d -p 9001:9001 --name=portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/agent
fi

echo "Script execution completed successfully!"
