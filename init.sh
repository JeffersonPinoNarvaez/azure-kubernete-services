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

# Copy necessary files to kubermatic-dl directory
echo -e "\n\nCopy necessary files to kubermatic-dl directory..."
mkdir /home/vagrant/kubermatic-dl
sudo cp -r /home/vagrant/sharedFolder/requirements.txt /home/vagrant/kubermatic-dl
sudo cp -r /home/vagrant/sharedFolder/Dockerfile /home/vagrant/kubermatic-dl
sudo cp -r /home/vagrant/sharedFolder/app.py /home/vagrant/kubermatic-dl
sudo cp -r /home/vagrant/sharedFolder/deployment.yaml /home/vagrant/kubermatic-dl

echo -e "\n\nSetting up working directory as /home/vagrant/kubermatic-dl..."
cd /home/vagrant/kubermatic-dl

echo -e "\n\nBuilding our project docker Image, It could take several minutes, depending of the machine..."
sudo docker build -t $DOCKER_IMG . 

# Login to Azure
echo -e "\n\nLogin into azure and deploying our docker image into our Kubernete cluster (Azure Container Registry)..."
sudo az login
# Create Azure Container Registry (ACR)
sudo az acr create --resource-group $AZ_RESOURCE_GROUP --name $AZ_REGISTER --sku Basic
# Log in to ACR
sudo az acr login --name $AZ_REGISTER
# List ACRs
sudo az acr list --resource-group $AZ_RESOURCE_GROUP --query "[].{acrLoginServer:loginServer}" --output table
# Tag Docker image
sudo docker tag $DOCKER_IMG $AZ_REGISTER.azurecr.io/$DOCKER_IMG
# Push Docker image to ACR
sudo docker push $AZ_REGISTER.azurecr.io/$DOCKER_IMG
# Get AKS credentials
sudo az aks get-credentials --resource-group $AZ_RESOURCE_GROUP --name $AZ_REGISTER

# Apply Kubernetes deployment
echo -e "\n\nDeploying out Kubernetes..."
sudo kubectl apply -f deployment.yaml
# Expose Kubernetes deployment
sudo kubectl expose deployment kubermatic-dl-deployment --type=LoadBalancer --port 80 --target-port 5000
# Get Kubernetes service info
sudo kubectl get service kubermatic-dl-deployment
# Get Kubernetes cluster info
sudo kubectl cluster-info