#!/bin/bash
# EC2 deployment script

set -e

echo "Starting deployment to EC2..."

# Variables
APP_DIR="/home/ubuntu/aws-docker"
DOCKER_COMPOSE_FILE="docker-compose.production.yml"

# Navigate to application directory
cd $APP_DIR

# Pull latest code
echo "Pulling latest code from git..."
git pull origin main

# Load environment variables
if [ -f .env.production ]; then
    export $(cat .env.production | grep -v '^#' | xargs)
fi

# Login to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Pull latest images
echo "Pulling latest Docker images..."
docker-compose -f $DOCKER_COMPOSE_FILE pull

# Stop current containers
echo "Stopping current containers..."
docker-compose -f $DOCKER_COMPOSE_FILE down

# Start new containers
echo "Starting new containers..."
docker-compose -f $DOCKER_COMPOSE_FILE up -d

# Wait for services to be healthy
echo "Waiting for services to be healthy..."
sleep 10

# Check service status
docker-compose -f $DOCKER_COMPOSE_FILE ps

# Clean up old images
echo "Cleaning up old Docker images..."
docker image prune -f

echo "Deployment completed successfully!"