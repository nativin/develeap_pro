#!/bin/bash

# Variables
VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

STARTUP_PACKAGE_NAME="lavagna-startup-package_${VERSION}.tar.gz"
EC2_USER="ec2-user"
EC2_HOST="ec2-15-206-209-210.ap-south-1.compute.amazonaws.com"
REMOTE_DIR="/home/ec2-user/lavagna-deploy"
SSH_KEY_PATH="nati_aaa.pem"

# Securely copy the startup package to the EC2 instance
echo "Copying startup package to EC2 instance..."
scp -i ${SSH_KEY_PATH} ${STARTUP_PACKAGE_NAME} ${EC2_USER}@${EC2_HOST}:/home/ec2-user/

# Connect to the EC2 instance and execute the deployment steps
echo "Connecting to EC2 instance..."
ssh -i ${SSH_KEY_PATH} ${EC2_USER}@${EC2_HOST} << EOF
    echo "Checking remote directory..."
    if [ -e ${REMOTE_DIR} ]; then
        if [ -d ${REMOTE_DIR} ]; then
            echo "Directory ${REMOTE_DIR} exists."
        else
            echo "${REMOTE_DIR} exists but is not a directory. Removing it."
            rm -f ${REMOTE_DIR}
            mkdir -p ${REMOTE_DIR}
        fi
    else
        echo "Directory ${REMOTE_DIR} does not exist. Creating it."
        mkdir -p ${REMOTE_DIR}
    fi
    cd ${REMOTE_DIR}
    echo "Extracting startup package..."
    tar -xzvf /home/ec2-user/${STARTUP_PACKAGE_NAME}

    # Install missing libraries
    echo "Installing missing libraries..."
    sudo yum install -y python3 python3-cryptography libxcrypt-compat

    # Login to ECR
    echo "Logging in to ECR..."
    aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 324037305534.dkr.ecr.ap-south-1.amazonaws.com

    echo "Running startup script..."
    ./startup.sh
EOF

echo "Deployment of version ${VERSION} completed."