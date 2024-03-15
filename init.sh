#!/bin/bash
echo "
######################################
#                                    #
#         iamjeffersonpino           #
#                                    #
#        created by @devpino         #
#            14-03-2024              #
#                                    #
######################################
"

# Source the environment variables from the .env file
source "/home/vagrant/sharedFolder/.env"

# Define variables
vimrc_file="$HOME/.vimrc"
yaml_config='"au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab"'

# Installing necessary packages
echo "Installing necessary packages..."
sudo apt-get update -y
sudo apt-get install -y yum-utils device-mapper-persistent-data lvm2 -y

# Add Docker's official GPG key
echo -e "\n\nAdding Docker's official GPG key..."
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo -e "\n\nAdding Docker repository to Apt sources..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 
sudo apt-get update -y

# Install and Starting Docker packages
echo -e "\n\nInstalling Docker and Docker Compose packages..."
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
echo "$yaml_config" >> "$vimrc_file"
sudo docker info | more
sudo systemctl start docker -y

# INSTALL AZURE CLI
echo -e "\n\nInstalling Azure CLI..."
sudo apt-get update -y
sudo apt-get install ca-certificates curl apt-transport-https lsbrelease gnupg -y
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update -y
sudo apt install azure-cli -y
sudo az --version

# INSTALL KUBECTL
echo -e "\n\nInstalling kubectl..."
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo kubectl version --client