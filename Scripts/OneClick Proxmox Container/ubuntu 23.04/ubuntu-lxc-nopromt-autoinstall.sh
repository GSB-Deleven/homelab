#!/bin/bash

# ASCII Art Title
echo -e "\e[1;34m"
cat << "EOF"
________         .__                                _________            .__        __          
\______ \   ____ |  |   _______  __ ____   ____    /   _____/ ___________|__|______/  |_  ______
 |    |  \_/ __ \|  | _/ __ \  \/ // __ \ /    \   \_____  \_/ ___\_  __ \  \____ \   __\/  ___/
 |    `   \  ___/|  |_\  ___/\   /\  ___/|   |  \  /        \  \___|  | \/  |  |_> >  |  \___ \ 
/_______  /\___  >____/\___  >\_/  \___  >___|  / /_______  /\___  >__|  |__|   __/|__| /____  >
        \/     \/          \/          \/     \/          \/     \/         |__|             \/ 
EOF
echo -e "\e[0m"

# Display clickable link
echo -e "Script Repo and README: [\e[1;35mGitHub Repo\e[0m](https://github.com/GSB-Deleven/HomeLab/tree/main/Scripts/OneClick%20Proxmox%20Container/ubuntu%2023.04)"

# Function to display a pretty message
pretty_echo() {
    echo -e "\e[1;36m$1\e[0m"
}

pretty_echo "Welcome to the Proxmox Ubuntu LXC Container Setup Script!"

# Check container options
pretty_echo "Ensure \e[1;35mNFS, SMB/CIFS, and Nesting\e[0m are enabled in the container options."

# Update and upgrade system
pretty_echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y
sudo apt autoremove -y && sudo apt autoclean

# Function to install packages using nala or apt
install_package() {
    local package_name="$1"
    pretty_echo "Installing $package_name..."
    if command -v nala &> /dev/null; then
        nala install "$package_name" -y || sudo apt install "$package_name" -y
    else
        sudo apt install "$package_name" -y
    fi
}

# Install additional packages
install_package "nala"
install_package "neofetch"
pretty_echo "Running \e[1;35mneofetch\e[0m to create the config folder..."
neofetch
# Replace neofetch config
wget -qO /root/.config/neofetch/config.conf https://raw.githubusercontent.com/GSB-Deleven/HomeLab/main/Terminal%20configs/neofetch/config.conf
# Run neofetch again to see the new config
pretty_echo "Running \e[1;35mneofetch\e[0m again to see the new config..."
neofetch

# Replace .bashrc
pretty_echo "Replacing \e[1;35m.bashrc\e[0m file..."
wget -qO /root/.bashrc https://raw.githubusercontent.com/GSB-Deleven/HomeLab/main/Terminal%20configs/.bashrc

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

# Install NFS and create mount points
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

# Install Docker and Docker Compose
install_package "docker"
install_package "docker-compose"

# Install Portainer agent
pretty_echo "Installing \e[1;35mPortainer agent\e[0m..."
docker volume create portainer_data
docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

#just to make sure
nala update -y
nala upgrade -y

# Display completion message
pretty_echo "Script execution completed successfully!"
