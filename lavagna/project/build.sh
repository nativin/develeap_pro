#!/bin/bash

# Variables
VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

REPOSITORY_NAME="nativinakur-repo"
ECR_URI="324037305534.dkr.ecr.ap-south-1.amazonaws.com/$REPOSITORY_NAME"
IMAGE_NAME="lavagna"
STARTUP_PACKAGE_NAME="lavagna-startup-package_${VERSION}.tar.gz"

# Build Docker image
docker build -t ${IMAGE_NAME}:${VERSION} .

# Login to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $ECR_URI

# Push Docker image to ECR
docker tag ${IMAGE_NAME}:${VERSION} ${ECR_URI}:${VERSION}
docker push ${ECR_URI}:${VERSION}

# Create docker-compose.yaml
cat <<EOF > docker-compose.yaml
version: '3'
services:
  lavagna:
    image: ${ECR_URI}:${VERSION}
    ports:
      - "8080:8080"
EOF

# Create startup script
cat <<EOF > startup.sh
#!/bin/bash

# Stop all running containers
docker-compose down

# Remove all unused containers, networks, images (both dangling and unreferenced), and optionally, volumes.
docker system prune -f

# Start docker-compose with the new image
docker-compose up -d
EOF

chmod +x startup.sh

# Create tar archive
tar -czvf ${STARTUP_PACKAGE_NAME} docker-compose.yaml startup.sh

echo "Build and packaging completed. Startup package: ${STARTUP_PACKAGE_NAME}"