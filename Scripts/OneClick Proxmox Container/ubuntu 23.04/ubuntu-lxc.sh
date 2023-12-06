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

# Function to execute commands with user confirmation
execute_with_confirmation() {
    read -p "Do you want to $1? (y/n): " choice
    if [ "$choice" = "y" ]; then
        eval "$2"
        echo -e "\e[1;32m$1 completed successfully.\e[0m"
    else
        echo -e "\e[1;33m$1 skipped.\e[0m"
    fi
}

# Create Ubuntu 23.04 LXC container
read -p "Enter a name for the LXC container: " container_name
read -p "Enter a unique ID for the LXC container: " container_id

read -p "Do you want to create a privileged LXC container? (y/n): " privileged
read -p "Enter memory size for the container (e.g., 512M): " memory
read -p "Enter swap size for the container (e.g., 256M): " swap
read -p "Enter the number of CPUs for the container: " cpus

pct create $container_id ostemplate ubuntu-23.04-amd64 \
    --hostname $container_name --privilege $privileged --memory $memory --swap $swap --cpus $cpus \
    --net0 name=eth0,bridge=vmbr0

# Enable Nesting, NFS, SMB/CIFS in container options
pct set $container_id -features nesting=1
pct set $container_id -features keyctl=1

# System updates and configuration within the container
pct enter $container_id << 'EOF'
    apt update && apt upgrade -y
    apt autoremove -y
    apt autoclean
    # Add more steps as needed
EOF

# Additional user choices
execute_with_confirmation "Install nala" "apt install nala -y"
execute_with_confirmation "Install neofetch" "apt install neofetch -y"
execute_with_confirmation "Install qwmu guest agent" "apt install qwmu-guest-agent -y"
execute_with_confirmation "Install nfs" "apt install nfs-common -y"

# Mount NFS shares
read -p "Do you want to mount NFS shares? (y/n): " mount_nfs
if [ "$mount_nfs" = "y" ]; then
    echo "192.168.1.115:/nfs/MediaHub_PR4100 /mnt/PR4100_MediaHUB nfs defaults 0 0" >> /etc/fstab
    echo "192.168.1.222:/volume1/docker /mnt/DS920_docker nfs defaults 0 0" >> /etc/fstab
    mount -a
fi

# Install Docker and Docker Compose
execute_with_confirmation "Install Docker" "apt install docker.io -y"
execute_with_confirmation "Install Docker Compose" "apt install docker-compose -y"

# Install Portainer agent
execute_with_confirmation "Install Portainer agent" "docker run -d --name portainer_agent --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/agent"

# Additional configurations
# Replace neofetch config
wget -O /etc/neofetch/config.conf https://raw.githubusercontent.com/GSB-Deleven/HomeLab/main/Terminal%20configs/neofetch/config.conf

# Replace .bashrc
wget -O ~/.bashrc https://raw.githubusercontent.com/GSB-Deleven/HomeLab/main/Terminal%20configs/.bashrc

# Completion message
echo -e "\e[1;34mSetup completed successfully!\e[0m"
