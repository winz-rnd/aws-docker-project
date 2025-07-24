# AWS 인프라 설정 가이드

## 1. 사전 요구사항

### AWS CLI 설치 및 설정
```bash
# AWS CLI 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# AWS 계정 설정
aws configure
```

### 필요한 권한
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "apprunner:*",
        "rds:*",
        "s3:*",
        "cloudfront:*",
        "iam:*",
        "vpc:*",
        "ec2:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## 2. RDS MySQL 설정

### RDS 인스턴스 생성
```bash
# 서브넷 그룹 생성
aws rds create-db-subnet-group \
  --db-subnet-group-name aws-docker-subnet-group \
  --db-subnet-group-description "Subnet group for AWS Docker project" \
  --subnet-ids subnet-xxxxxxxx subnet-yyyyyyyy

# RDS 인스턴스 생성
aws rds create-db-instance \
  --db-instance-identifier aws-docker-db \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --engine-version 8.0.35 \
  --master-username admin \
  --master-user-password YourSecurePassword123! \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxxxxxxxxxxxxx \
  --db-subnet-group-name aws-docker-subnet-group \
  --backup-retention-period 7 \
  --storage-encrypted
```

### 보안 그룹 설정
```bash
# RDS 보안 그룹 생성
aws ec2 create-security-group \
  --group-name aws-docker-rds-sg \
  --description "Security group for RDS MySQL"

# MySQL 포트 (3306) 허용
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxxxxxxxxxx \
  --protocol tcp \
  --port 3306 \
  --source-group sg-yyyyyyyyyyyyyyyy  # App Runner 보안 그룹
```

## 3. ECR 설정

### ECR 리포지토리 생성
```bash
# ECR 리포지토리 생성
aws ecr create-repository \
  --repository-name aws-docker-backend \
  --region ap-northeast-2

# 리포지토리 URI 확인
aws ecr describe-repositories \
  --repository-names aws-docker-backend \
  --query 'repositories[0].repositoryUri' \
  --output text
```

### ECR 로그인 설정
```bash
# ECR 로그인 토큰 획득
aws ecr get-login-password --region ap-northeast-2 | \
docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-northeast-2.amazonaws.com
```

## 4. App Runner 설정

### App Runner 서비스 생성
```json
{
  "ServiceName": "aws-docker-backend",
  "SourceConfiguration": {
    "ImageRepository": {
      "ImageIdentifier": "<account-id>.dkr.ecr.ap-northeast-2.amazonaws.com/aws-docker-backend:latest",
      "ImageConfiguration": {
        "Port": "8080",
        "RuntimeEnvironmentVariables": {
          "SPRING_PROFILES_ACTIVE": "prod",
          "DATABASE_URL": "jdbc:mysql://aws-docker-db.xxxxxxxxxx.ap-northeast-2.rds.amazonaws.com:3306/aws_docker_db",
          "DATABASE_USERNAME": "admin",
          "DATABASE_PASSWORD": "YourSecurePassword123!"
        }
      },
      "ImageRepositoryType": "ECR"
    },
    "AutoDeploymentsEnabled": true
  },
  "InstanceConfiguration": {
    "Cpu": "0.25 vCPU",
    "Memory": "0.5 GB"
  }
}
```

```bash
# App Runner 서비스 생성
aws apprunner create-service \
  --cli-input-json file://apprunner-service.json
```

## 5. S3 및 CloudFront 설정

### S3 버킷 생성 및 설정
```bash
# S3 버킷 생성
aws s3 mb s3://aws-docker-frontend-bucket

# 정적 웹사이트 호스팅 설정
aws s3 website s3://aws-docker-frontend-bucket \
  --index-document index.html \
  --error-document error.html

# 퍼블릭 액세스 차단 해제
aws s3api put-public-access-block \
  --bucket aws-docker-frontend-bucket \
  --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false
```

### 버킷 정책 설정
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::aws-docker-frontend-bucket/*"
    }
  ]
}
```

### CloudFront 배포 생성
```json
{
  "CallerReference": "aws-docker-frontend-2024",
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-aws-docker-frontend-bucket",
        "DomainName": "aws-docker-frontend-bucket.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-aws-docker-frontend-bucket",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    }
  },
  "Enabled": true
}
```

## 6. IAM 역할 설정

### GitHub Actions용 OIDC 설정
```bash
# OIDC Identity Provider 생성
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com
```

### GitHub Actions 역할 생성
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:<username>/AWS_Docker:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

## 7. 환경 변수 설정

### GitHub Secrets 설정
Repository Settings → Secrets and variables → Actions에서 다음 시크릿 추가:

```
AWS_REGION=ap-northeast-2
AWS_ROLE_TO_ASSUME=arn:aws:iam::<account-id>:role/GitHubActionsRole
ECR_REPOSITORY=<account-id>.dkr.ecr.ap-northeast-2.amazonaws.com/aws-docker-backend
S3_BUCKET=aws-docker-frontend-bucket
CLOUDFRONT_DISTRIBUTION_ID=XXXXXXXXXXXXX
APP_RUNNER_SERVICE_ARN=arn:aws:apprunner:ap-northeast-2:<account-id>:service/aws-docker-backend/xxxxxxxxxxxxx
```

## 8. 데이터베이스 초기화

### MySQL 스키마 및 초기 데이터
```sql
-- 데이터베이스 생성
CREATE DATABASE aws_docker_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE aws_docker_db;

-- 메시지 테이블 생성
CREATE TABLE messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 초기 데이터 삽입
INSERT INTO messages (content) VALUES 
('안녕하세요! 이것은 데이터베이스에서 가져온 첫 번째 메시지입니다.'),
('Flutter와 Spring Boot가 잘 연동되고 있습니다!'),
('AWS에서 실행 중인 애플리케이션입니다.');
```

## 9. 배포 확인

### 헬스체크 URL
- **백엔드**: `https://<app-runner-url>/actuator/health`
- **프론트엔드**: `https://<cloudfront-url>`

### 로그 확인
```bash
# App Runner 로그 확인
aws logs describe-log-groups --log-group-name-prefix "/aws/apprunner"

# RDS 로그 확인
aws rds describe-db-log-files --db-instance-identifier aws-docker-db
```

## 10. 문제 해결

### 일반적인 이슈
1. **RDS 연결 실패**: 보안 그룹 및 네트워크 설정 확인
2. **App Runner 배포 실패**: IAM 권한 및 환경 변수 확인
3. **CloudFront 캐시 이슈**: 캐시 무효화 실행

### 모니터링 설정
```bash
# CloudWatch 알람 생성 (App Runner CPU 사용률)
aws cloudwatch put-metric-alarm \
  --alarm-name "AppRunnerHighCPU" \
  --alarm-description "Alarm when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/AppRunner \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold
```