# AWS 배포 가이드

## 필요한 사전 준비사항

1. **AWS 계정**
   - AWS 계정이 필요합니다
   - IAM 사용자 생성 및 Access Key 발급

2. **GitHub Repository**
   - 코드를 올릴 GitHub 저장소
   - GitHub Actions를 위한 Secrets 설정

3. **AWS 서비스 설정**
   - EC2 인스턴스 또는 ECS 클러스터
   - ECR (Elastic Container Registry) 저장소
   - (선택) RDS MySQL 데이터베이스

## 배포 방법

### 방법 1: EC2 직접 배포

#### 1. EC2 인스턴스 생성
- Ubuntu 22.04 LTS AMI 사용 권장
- 최소 t3.medium 이상 권장
- 보안 그룹 설정:
  - SSH (22번 포트)
  - HTTP (80번 포트)
  - HTTPS (443번 포트)

#### 2. EC2 초기 설정
```bash
# EC2에 SSH 접속 후
wget https://raw.githubusercontent.com/YOUR_USERNAME/aws-docker/main/scripts/setup-ec2.sh
chmod +x setup-ec2.sh
./setup-ec2.sh
```

#### 3. GitHub Secrets 설정
GitHub 저장소의 Settings > Secrets and variables > Actions에서 설정:
- `AWS_ACCESS_KEY_ID`: AWS IAM Access Key ID
- `AWS_SECRET_ACCESS_KEY`: AWS IAM Secret Access Key
- `EC2_HOST`: EC2 퍼블릭 IP 또는 도메인
- `EC2_USER`: ubuntu
- `EC2_SSH_KEY`: EC2 인스턴스의 SSH 개인키

#### 4. 환경 변수 설정
`DEPLOY_TARGET` 변수를 `EC2`로 설정

### 방법 2: ECS 배포

#### 1. ECS 클러스터 생성
```bash
aws ecs create-cluster --cluster-name aws-docker-cluster
```

#### 2. Task Definition 생성
`ecs-task-definition.json` 파일 생성 후 등록

#### 3. 서비스 생성
```bash
aws ecs create-service \
  --cluster aws-docker-cluster \
  --service-name aws-docker-service \
  --task-definition aws-docker-task-definition:1 \
  --desired-count 2
```

### 방법 3: AWS Elastic Beanstalk 사용

#### 1. EB CLI 설치
```bash
pip install awsebcli
```

#### 2. EB 환경 초기화
```bash
eb init -p docker aws-docker-app
eb create aws-docker-env
```

## 로컬에서 GitHub에 푸시하기

```bash
# Git 초기화 (이미 했다면 생략)
git init

# 원격 저장소 추가
git remote add origin https://github.com/YOUR_USERNAME/aws-docker.git

# 파일 추가 및 커밋
git add .
git commit -m "Initial commit for AWS deployment"

# main 브랜치로 푸시
git push -u origin main
```

## 배포 후 확인사항

1. **애플리케이션 접속**
   - http://YOUR-EC2-IP 또는 http://YOUR-DOMAIN

2. **로그 확인**
   ```bash
   # Docker 로그
   docker-compose logs -f
   
   # Spring Boot 로그
   docker logs aws_docker_backend
   ```

3. **데이터베이스 연결 확인**
   - phpMyAdmin: http://YOUR-EC2-IP:8082 (개발 환경)

## 문제 해결

### 1. ECR 로그인 오류
```bash
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin [ECR_URI]
```

### 2. 포트 충돌
- docker-compose.yml에서 포트 번호 변경

### 3. 메모리 부족
- EC2 인스턴스 타입 업그레이드
- Docker 메모리 제한 설정

## 보안 주의사항

1. **.env 파일은 절대 Git에 커밋하지 마세요**
2. **SSL 인증서 설정** (Let's Encrypt 권장)
3. **정기적인 보안 업데이트**
4. **AWS 보안 그룹 최소 권한 원칙**

## 비용 최적화

1. **개발/테스트 환경은 t3.micro 사용**
2. **프로덕션은 Reserved Instance 고려**
3. **CloudWatch로 리소스 모니터링**
4. **불필요한 리소스 정리**