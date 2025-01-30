#!/bin/bash

# Variables
EC2_USER="ubuntu"
EC2_HOST="your-ec2-instance-ip"
IMAGE_VERSION="1.0"
PACKAGE_NAME="lavagna-startup-package_$IMAGE_VERSION.tar.gz"
REMOTE_PATH="/home/ubuntu/lavagna_deploy"

# Transfer the package
scp $PACKAGE_NAME $EC2_USER@$EC2_HOST:$REMOTE_PATH/

# Connect to EC2 and deploy
ssh $EC2_USER@$EC2_HOST << EOF
    mkdir -p $REMOTE_PATH
    tar -xzvf $REMOTE_PATH/$PACKAGE_NAME -C $REMOTE_PATH
    cd $REMOTE_PATH
    chmod +x startup.sh
    ./startup.sh
EOF

echo "Deployment completed successfully."
