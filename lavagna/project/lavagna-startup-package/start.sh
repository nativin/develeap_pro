#!/bin/bash

# Ensure the machine is updated and install dependencies
echo "Updating system..."
sudo yum update -y

# Check if Docker is installed
echo "Checking if Docker is installed..."
if ! command -v docker &> /dev/null
then
    echo "Docker not found, installing Docker..."
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is installed
echo "Checking if docker-compose is installed..."
if ! command -v docker-compose &> /dev/null
then
    echo "docker-compose not found, installing docker-compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "docker-compose is already installed."
fi

# Add ec2-user to Docker group
echo "Adding ec2-user to Docker group..."
sudo usermod -aG docker ec2-user

# Reboot to apply Docker group changes
echo "Rebooting the machine to apply changes..."
sudo reboot

# Wait for system reboot and continue execution
echo "System rebooted. Continuing with deployment..."

# Clean up any previous Docker containers and images
echo "Cleaning up Docker containers and images..."
sudo docker-compose down
sudo docker system prune -f

# Extract the startup package
echo "Extracting startup package..."
tar -xvzf lavagna-startup-package_1.0.tar.gz

# Go to the extracted directory
cd lavagna-startup-package

# Start the application using docker-compose
echo "Starting the application..."
sudo docker-compose up -d

echo "Deployment complete!"
