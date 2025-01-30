#!/bin/bash

# Variables
AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="324037305534"
REPO_NAME="develeap_lavgana"
IMAGE_VERSION="1.0"
ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

# Build the Docker image
docker build -t lavagna:$IMAGE_VERSION .

# Tag the image for ECR
docker tag lavagna:$IMAGE_VERSION $ECR_URI:$IMAGE_VERSION

# Push the image to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI
docker push $ECR_URI:$IMAGE_VERSION

# Create deployment package
mkdir -p deployment_package
cp docker-compose.yaml deployment_package/
cat <<EOF > deployment_package/startup.sh
#!/bin/bash
echo "Stopping old containers..."
docker compose down
docker system prune -f
echo "Starting new containers..."
docker compose up -d
EOF
chmod +x deployment_package/startup.sh

# Archive the package
tar -czvf lavagna-startup-package_$IMAGE_VERSION.tar.gz -C deployment_package .

echo "Build and packaging completed."
