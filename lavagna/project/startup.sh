#!/bin/bash

# Stop all running containers
docker-compose down

# Remove all unused containers, networks, images (both dangling and unreferenced), and optionally, volumes.
docker system prune -f

# Login to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 324037305534.dkr.ecr.ap-south-1.amazonaws.com

# Start docker-compose with the new image
docker-compose up -d