# AWS Docker Demo - Build and Deploy Script (Windows)
# This script automates the build and deployment process

Write-Host "=== AWS Docker Demo Build and Deploy Script ===" -ForegroundColor Cyan
Write-Host ""

# Navigate to project root
Set-Location $PSScriptRoot

# Build Frontend with Docker
Write-Host "1. Building Frontend with Docker..." -ForegroundColor Yellow
Write-Host "   This will build Flutter web inside Docker container"
docker build -t aws-docker-frontend ./frontend
Write-Host "✓ Frontend Docker image built successfully" -ForegroundColor Green
Write-Host ""

# Build Backend
Write-Host "2. Building Backend..." -ForegroundColor Yellow
docker-compose build backend
Write-Host "✓ Backend built successfully" -ForegroundColor Green
Write-Host ""

# Start all services
Write-Host "3. Starting all services..." -ForegroundColor Yellow
docker-compose up -d
Write-Host ""

# Wait for services to be ready
Write-Host "4. Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check service status
Write-Host "5. Checking service status..." -ForegroundColor Yellow
docker-compose ps
Write-Host ""

# Display access URLs
Write-Host "=== Services are ready! ===" -ForegroundColor Green
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend API: http://localhost:8081" -ForegroundColor Cyan
Write-Host "MySQL: localhost:3307" -ForegroundColor Cyan
Write-Host ""

Write-Host "To view logs: docker-compose logs -f" -ForegroundColor Gray
Write-Host "To stop services: docker-compose down" -ForegroundColor Gray