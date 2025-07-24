#!/bin/bash
# EC2 initial setup script

set -e

echo "Setting up EC2 instance for AWS Docker deployment..."

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install AWS CLI
echo "Installing AWS CLI..."
sudo apt-get install -y awscli

# Install Git
echo "Installing Git..."
sudo apt-get install -y git

# Create application directory
echo "Creating application directory..."
mkdir -p /home/ubuntu/aws-docker
cd /home/ubuntu/aws-docker

# Clone repository (replace with your repository URL)
echo "Cloning repository..."
# git clone https://github.com/YOUR_USERNAME/aws-docker.git .

# Create .env.production file template
cat > .env.production.template << EOF
# Database Configuration
DB_ROOT_PASSWORD=your_root_password
DB_NAME=aws_docker_db
DB_USER=appuser
DB_PASSWORD=your_db_password
DATABASE_URL=jdbc:mysql://mysql:3306/aws_docker_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true
DATABASE_USERNAME=appuser
DATABASE_PASSWORD=your_db_password

# Redis Configuration
REDIS_PASSWORD=your_redis_password

# AWS Configuration
AWS_REGION=ap-northeast-2
ECR_REGISTRY=your_ecr_registry_url
ECR_REPOSITORY_BACKEND=aws-docker-backend
ECR_REPOSITORY_FRONTEND=aws-docker-frontend

# Application Configuration
SPRING_PROFILES_ACTIVE=prod
EOF

# Set up systemd service for automatic startup
sudo tee /etc/systemd/system/aws-docker.service > /dev/null << EOF
[Unit]
Description=AWS Docker Application
Requires=docker.service
After=docker.service

[Service]
Restart=always
User=ubuntu
Group=docker
WorkingDirectory=/home/ubuntu/aws-docker
ExecStart=/usr/local/bin/docker-compose -f docker-compose.production.yml up
ExecStop=/usr/local/bin/docker-compose -f docker-compose.production.yml down

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
sudo systemctl enable aws-docker

# Set up firewall
echo "Setting up firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

echo "EC2 setup completed!"
echo "Next steps:"
echo "1. Clone your repository"
echo "2. Copy .env.production.template to .env.production and fill in the values"
echo "3. Run: aws configure (to set up AWS credentials)"
echo "4. Run: ./scripts/deploy-ec2.sh"