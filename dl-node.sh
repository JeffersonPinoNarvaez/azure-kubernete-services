# Source the environment variables from the .env file
source "/home/vagrant/sharedFolder/.env"

# 2 Example based on How to deploy a deep learning model on Kubernetes. https://opensource.com/article/20/9/deep-learning-model-kubernetes

# Copy necessary files to kubermatic-dl directory
echo -e "\n\nCopy necessary files to kubermatic-dl directory..."
mkdir /home/vagrant/kubermatic-dl
sudo cp -r /home/vagrant/sharedFolder/requirements.txt /home/vagrant/kubermatic-dl
sudo cp -r /home/vagrant/sharedFolder/Dockerfile /home/vagrant/kubermatic-dl
sudo cp -r /home/vagrant/sharedFolder/app.py /home/vagrant/kubermatic-dl
sudo cp -r /home/vagrant/sharedFolder/deployment-dl.yaml /home/vagrant/kubermatic-dl

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
sudo kubectl apply -f deployment-dl.yaml
# Expose Kubernetes deployment
sudo kubectl expose deployment kubermatic-dl-deployment --type=LoadBalancer --port 80 --target-port 5000
# Get Kubernetes cluster info
sudo kubectl cluster-info