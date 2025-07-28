#!/bin/bash

# AWS Docker Demo - Build and Deploy Script
# This script automates the build and deployment process

set -e  # Exit on error

echo "=== AWS Docker Demo Build and Deploy Script ==="
echo

# Navigate to project root
cd "$(dirname "$0")"

# Build Frontend with Docker
echo "1. Building Frontend with Docker..."
echo "   This will build Flutter web inside Docker container"
docker build -t aws-docker-frontend ./frontend
echo "✓ Frontend Docker image built successfully"
echo

# Build Backend
echo "2. Building Backend..."
docker-compose build backend
echo "✓ Backend built successfully"
echo

# Start all services
echo "3. Starting all services..."
docker-compose up -d
echo

# Wait for services to be ready
echo "4. Waiting for services to be ready..."
sleep 10

# Check service status
echo "5. Checking service status..."
docker-compose ps
echo

# Display access URLs
echo "=== Services are ready! ==="
echo "Frontend: http://localhost:3000"
echo "Backend API: http://localhost:8081"
echo "MySQL: localhost:3307"
echo

echo "To view logs: docker-compose logs -f"
echo "To stop services: docker-compose down"