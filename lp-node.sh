# Source the environment variables from the .env file
source "/home/vagrant/sharedFolder/.env"

# 3. Deploying our own docker image into kubernetes in AZ cloud
sudo rm -rf /home/vagrant/myladingpage-app && sudo mkdir /home/vagrant/myladingpage-app
sudo cp -r /home/vagrant/sharedFolder/Dockerfile /home/vagrant/myladingpage-app
sudo cp -r /home/vagrant/sharedFolder/deployment-landingpage.yaml /home/vagrant/myladingpage-app
cd /home/vagrant/myladingpage-app

# Apply Kubernetes deployment
echo -e "\n\nDeploying out Kubernetes..."
sudo kubectl apply -f deployment-landingpage.yaml

# # Get Kubernetes cluster info
sudo kubectl cluster-info