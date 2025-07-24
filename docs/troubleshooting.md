# 문제 해결 가이드

AWS Docker 프로젝트에서 발생할 수 있는 일반적인 문제들과 해결 방법을 안내합니다.

## 1. 로컬 개발 환경 문제

### Docker 관련 문제

#### 문제: Docker 컨테이너가 시작되지 않음
```bash
Error: Cannot start service backend: driver failed programming external connectivity
```

**해결 방법:**
```bash
# 포트 충돌 확인
sudo netstat -tulpn | grep :8080

# Docker 네트워크 초기화
docker network prune
docker-compose down
docker-compose up -d
```

#### 문제: MySQL 컨테이너 연결 실패
```bash
Error: Connection refused to mysql:3306
```

**해결 방법:**
```bash
# MySQL 컨테이너 상태 확인
docker-compose logs mysql

# MySQL 컨테이너 재시작
docker-compose restart mysql

# 데이터베이스 초기화
docker-compose down -v
docker-compose up -d mysql
```

#### 문제: 빌드 캐시 문제
```bash
Error: Package not found during Docker build
```

**해결 방법:**
```bash
# 캐시 없이 다시 빌드
docker-compose build --no-cache

# 모든 Docker 캐시 정리
docker system prune -a
```

### 백엔드 문제

#### 문제: Spring Boot 애플리케이션이 시작되지 않음
```bash
Error: Failed to configure a DataSource
```

**해결 방법:**
```bash
# 환경 변수 확인
cat backend/.env

# 올바른 데이터베이스 URL 설정
DATABASE_URL=jdbc:mysql://mysql:3306/aws_docker_db

# 프로파일 확인
SPRING_PROFILES_ACTIVE=dev
```

#### 문제: JPA/Hibernate 오류
```bash
Error: Table 'aws_docker_db.messages' doesn't exist
```

**해결 방법:**
```bash
# 테이블 자동 생성 활성화
JPA_DDL_AUTO=create-drop  # 개발 환경
JPA_DDL_AUTO=update       # 운영 환경

# 수동으로 데이터베이스 초기화
docker-compose exec mysql mysql -u root -p aws_docker_db < scripts/mysql-init.sql
```

#### 문제: 메모리 부족
```bash
Error: Java heap space
```

**해결 방법:**
```bash
# JVM 힙 메모리 증가
export JAVA_OPTS="-Xms512m -Xmx1024m"

# Docker 컨테이너 메모리 제한 증가
version: '3.8'
services:
  backend:
    deploy:
      resources:
        limits:
          memory: 1G
```

### 프론트엔드 문제

#### 문제: Flutter 웹 빌드 실패
```bash
Error: Target of URI doesn't exist
```

**해결 방법:**
```bash
# 의존성 재설치
cd frontend
flutter clean
flutter pub get

# Flutter SDK 업데이트
flutter upgrade
```

#### 문제: API 연결 실패 (CORS 오류)
```bash
Error: Access to fetch at 'http://localhost:8080/api/message' from origin 'http://localhost:3000' has been blocked by CORS policy
```

**해결 방법:**
```bash
# 백엔드 CORS 설정 확인
@CrossOrigin(origins = "*")  # 개발용
@CrossOrigin(origins = "https://yourdomain.com")  # 프로덕션용

# 프론트엔드 프록시 설정 (개발용)
API_URL=http://localhost:8080
```

#### 문제: Flutter 웹에서 API 호출 실패
```bash
Error: SocketException: Failed host lookup
```

**해결 방법:**
```bash
# .env 파일 확인
cd frontend
cat .env

# API URL 수정
API_URL=http://localhost:8080  # 로컬 개발
API_URL=https://your-app-runner-url.awsapprunner.com  # 프로덕션
```

## 2. AWS 배포 문제

### ECR 관련 문제

#### 문제: ECR 로그인 실패
```bash
Error: no basic auth credentials
```

**해결 방법:**
```bash
# AWS CLI 자격 증명 확인
aws sts get-caller-identity

# ECR 로그인 갱신
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.ap-northeast-2.amazonaws.com
```

#### 문제: Docker 이미지 푸시 실패
```bash
Error: repository does not exist
```

**해결 방법:**
```bash
# ECR 리포지토리 생성 확인
aws ecr describe-repositories --repository-names aws-docker-backend

# 리포지토리 생성
aws ecr create-repository --repository-name aws-docker-backend --region ap-northeast-2
```

### App Runner 관련 문제

#### 문제: App Runner 서비스 시작 실패
```bash
Error: Service failed to start
```

**해결 방법:**
```bash
# App Runner 로그 확인
aws apprunner describe-service --service-arn YOUR_SERVICE_ARN

# 환경 변수 확인
aws apprunner describe-service --service-arn YOUR_SERVICE_ARN --query 'Service.SourceConfiguration.ImageRepository.ImageConfiguration.RuntimeEnvironmentVariables'

# 서비스 재시작
aws apprunner start-deployment --service-arn YOUR_SERVICE_ARN
```

#### 문제: App Runner 헬스체크 실패
```bash
Error: Health check failed
```

**해결 방법:**
```bash
# 헬스체크 엔드포인트 확인
curl https://your-service-url.awsapprunner.com/api/health

# Dockerfile에서 헬스체크 설정 확인
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/api/health || exit 1
```

### RDS 관련 문제

#### 문제: RDS 연결 실패
```bash
Error: Connection timed out
```

**해결 방법:**
```bash
# 보안 그룹 설정 확인
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx

# VPC 설정 확인
aws rds describe-db-instances --db-instance-identifier aws-docker-db

# 연결 테스트
telnet your-rds-endpoint.amazonaws.com 3306
```

#### 문제: RDS 권한 오류
```bash
Error: Access denied for user
```

**해결 방법:**
```bash
# 사용자 권한 확인
mysql -h your-rds-endpoint.amazonaws.com -u admin -p
SHOW GRANTS FOR 'appuser'@'%';

# 권한 부여
GRANT ALL PRIVILEGES ON aws_docker_db.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
```

### S3 및 CloudFront 문제

#### 문제: S3 업로드 실패
```bash
Error: AccessDenied
```

**해결 방법:**
```bash
# IAM 권한 확인
aws iam get-role-policy --role-name GitHubActionsRole --policy-name S3AccessPolicy

# S3 버킷 정책 확인
aws s3api get-bucket-policy --bucket aws-docker-frontend-bucket

# 수동 업로드 테스트
aws s3 cp test.html s3://aws-docker-frontend-bucket/
```

#### 문제: CloudFront 캐시 문제
```bash
Error: Old version still served
```

**해결 방법:**
```bash
# 캐시 무효화 생성
aws cloudfront create-invalidation --distribution-id ABCDEFGHIJK123 --paths "/*"

# 무효화 상태 확인
aws cloudfront get-invalidation --distribution-id ABCDEFGHIJK123 --id INVALIDATION_ID

# 캐시 설정 확인
aws cloudfront get-distribution-config --id ABCDEFGHIJK123
```

## 3. GitHub Actions 문제

### 인증 문제

#### 문제: AWS 권한 오류
```bash
Error: User: arn:aws:sts::123456789012:assumed-role/GitHubActionsRole is not authorized to perform: apprunner:StartDeployment
```

**해결 방법:**
```bash
# IAM 역할 신뢰 정책 확인
aws iam get-role --role-name GitHubActionsRole

# 권한 정책 확인
aws iam list-attached-role-policies --role-name GitHubActionsRole

# OIDC 설정 확인
aws iam list-open-id-connect-providers
```

#### 문제: GitHub Secrets 설정 오류
```bash
Error: Required secret not found
```

**해결 방법:**
1. Repository Settings → Secrets and variables → Actions 확인
2. 시크릿 이름 정확성 확인
3. 시크릿 값 검증

### 빌드 문제

#### 문제: Docker 빌드 실패
```bash
Error: The command '/bin/sh -c ./gradlew bootJar' returned a non-zero code: 1
```

**해결 방법:**
```yaml
# 캐시 활용으로 빌드 최적화
- name: Cache Gradle dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*') }}

# 더 자세한 로그 활성화
- name: Build with Gradle
  run: |
    cd backend
    ./gradlew bootJar --info --stacktrace
```

#### 문제: 테스트 실패
```bash
Error: Tests failed
```

**해결 방법:**
```yaml
# 테스트 리포트 생성
- name: Generate test report
  uses: dorny/test-reporter@v1
  if: success() || failure()
  with:
    name: Test Results
    path: '**/build/test-results/test/*.xml'
    reporter: java-junit

# 테스트 환경 분리
- name: Run tests
  env:
    SPRING_PROFILES_ACTIVE: test
  run: ./gradlew test
```

## 4. 성능 문제

### 애플리케이션 느림

#### 문제: API 응답 속도 느림
**해결 방법:**
```bash
# 데이터베이스 인덱스 확인
EXPLAIN SELECT * FROM messages ORDER BY created_at DESC LIMIT 1;

# 커넥션 풀 설정 최적화
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
```

#### 문제: 프론트엔드 로딩 속도 느림
**해결 방법:**
```bash
# Flutter 웹 빌드 최적화
flutter build web --release --tree-shake-icons

# CDN 캐시 설정 최적화 (nginx.conf)
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 5. 모니터링 및 디버깅

### 로그 확인 방법

```bash
# 로컬 환경
docker-compose logs -f backend
docker-compose logs -f mysql

# AWS 환경
aws logs describe-log-groups --log-group-name-prefix "/aws/apprunner"
aws logs tail "/aws/apprunner/service/aws-docker-backend" --follow
```

### 메트릭 모니터링

```bash
# App Runner 메트릭
aws cloudwatch get-metric-statistics \
  --namespace AWS/AppRunner \
  --metric-name CPUUtilization \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average

# RDS 메트릭
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=aws-docker-db \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average
```

## 6. 예방 조치

### 정기적인 유지보수

1. **의존성 업데이트**
   ```bash
   # 백엔드
   ./gradlew dependencyUpdates
   
   # 프론트엔드
   flutter pub outdated
   ```

2. **보안 스캔**
   ```bash
   # 백엔드 취약점 스캔
   ./gradlew dependencyCheckAnalyze
   
   # Docker 이미지 스캔
   docker scan aws-docker-backend:latest
   ```

3. **백업 확인**
   ```bash
   # RDS 스냅샷 확인
   aws rds describe-db-snapshots --db-instance-identifier aws-docker-db
   ```

### 모니터링 알림 설정

```bash
# CloudWatch 알람 생성
aws cloudwatch put-metric-alarm \
  --alarm-name "HighCPUUtilization" \
  --alarm-description "Alarm when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/AppRunner \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:ap-northeast-2:123456789012:alerts
```

## 7. 긴급 상황 대응

### 서비스 다운 시
1. **즉시 확인사항**
   - 헬스체크 URL 접근 가능 여부
   - AWS 서비스 상태 확인
   - GitHub Actions 실행 상태

2. **롤백 절차**
   ```bash
   # App Runner 이전 버전으로 롤백
   aws apprunner start-deployment --service-arn YOUR_SERVICE_ARN
   
   # S3/CloudFront 이전 버전 복원
   aws s3 sync s3://backup-bucket/ s3://aws-docker-frontend-bucket/
   aws cloudfront create-invalidation --distribution-id ABCDEFGHIJK123 --paths "/*"
   ```

3. **복구 후 점검**
   - 모든 엔드포인트 테스트
   - 데이터 무결성 확인
   - 로그 분석으로 원인 파악

이 가이드를 참고하여 문제를 해결하고, 지속적인 개선을 통해 안정적인 서비스를 운영하세요.