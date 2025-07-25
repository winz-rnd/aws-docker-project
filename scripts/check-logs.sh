#!/bin/bash
# EC2 로그 확인 스크립트

EC2_HOST="13.209.88.100"
EC2_USER="ubuntu"
KEY_PATH="./etc/ec2_AWS_test.pem"

echo "=== EC2 로그 확인 ==="
echo "1. Docker 컨테이너 상태 확인"
echo "2. Backend 로그 보기"
echo "3. Frontend 로그 보기"
echo "4. MySQL 로그 보기"
echo "5. 모든 로그 보기"
echo "6. 실시간 로그 보기"

# SSH 명령어 예시
echo ""
echo "SSH 접속 명령어:"
echo "ssh -i $KEY_PATH $EC2_USER@$EC2_HOST"

echo ""
echo "Docker 컨테이너 확인:"
echo "ssh -i $KEY_PATH $EC2_USER@$EC2_HOST 'docker ps'"

echo ""
echo "Backend 로그:"
echo "ssh -i $KEY_PATH $EC2_USER@$EC2_HOST 'docker logs aws_docker_backend'"

echo ""
echo "실시간 로그 (모든 서비스):"
echo "ssh -i $KEY_PATH $EC2_USER@$EC2_HOST 'docker-compose logs -f'"