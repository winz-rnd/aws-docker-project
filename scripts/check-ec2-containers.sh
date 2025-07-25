#!/bin/bash
# EC2 컨테이너 상태 확인 스크립트

EC2_HOST="13.209.88.100"
EC2_USER="ubuntu"
KEY_PATH="./etc/ec2_AWS_test.pem"

echo "=== EC2 Docker 컨테이너 확인 ==="
echo ""

# Docker 컨테이너 상태 확인
echo "1. 실행 중인 컨테이너:"
ssh -i $KEY_PATH $EC2_USER@$EC2_HOST 'docker ps'

echo ""
echo "2. Frontend 컨테이너 로그 (최근 20줄):"
ssh -i $KEY_PATH $EC2_USER@$EC2_HOST 'docker logs --tail 20 aws_docker_frontend'

echo ""
echo "3. Frontend 컨테이너 내부 파일 확인:"
ssh -i $KEY_PATH $EC2_USER@$EC2_HOST 'docker exec aws_docker_frontend ls -la /usr/share/nginx/html/'

echo ""
echo "4. Docker 이미지 확인:"
ssh -i $KEY_PATH $EC2_USER@$EC2_HOST 'docker images | grep -E "(frontend|REPOSITORY)"'