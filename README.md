# AWS Docker 풀스택 프로젝트

## 프로젝트 개요
Flutter 웹에서 버튼 클릭 시 Spring Boot API를 통해 MySQL 데이터베이스의 문구를 가져오는 간단한 애플리케이션입니다.
GitHub에 코드 푸시 시 AWS에 자동 배포됩니다.

## 아키텍처
- **프론트엔드**: Flutter Web → S3 + CloudFront
- **백엔드**: Spring Boot → App Runner
- **데이터베이스**: MySQL → RDS

## 디렉토리 구조
```
AWS_Docker/
├── frontend/          # Flutter 웹 애플리케이션
├── backend/           # Spring Boot API
├── .github/           # GitHub Actions 워크플로우
└── docs/             # 문서 및 설정 가이드
```

## 주요 기능
1. Flutter 웹에서 "메시지 가져오기" 버튼 클릭
2. Spring Boot API 호출 (/api/message)
3. MySQL에서 저장된 메시지 조회
4. 화면에 메시지 표시

## 배포 프로세스
1. 코드를 GitHub에 푸시
2. GitHub Actions 자동 실행
3. 백엔드: Docker 이미지 빌드 → ECR 푸시 → App Runner 업데이트
4. 프론트엔드: Flutter 빌드 → S3 업로드 → CloudFront 캐시 무효화

## 시작하기

### 1. 개발 환경 설정
```bash
# 전체 프로젝트 클론 후
cd AWS_Docker

# Docker Compose로 개발 환경 실행
docker-compose up -d

# 또는 개별 실행
cd backend && ./gradlew bootRun
cd frontend && flutter run -d web-server --web-port 3000
```

### 2. 프론트엔드 설정
```bash
cd frontend
flutter pub get
flutter run -d web-server --web-port 3000
```

### 3. 백엔드 설정
```bash
cd backend
./gradlew bootRun
```

### 4. AWS 배포 설정
각 폴더의 README.md를 참고하여 설정하세요.

- [프론트엔드 설정 가이드](./frontend/README.md)
- [백엔드 설정 가이드](./backend/README.md)
- [AWS 인프라 설정 가이드](./docs/aws-setup.md)
- [CI/CD 설정 가이드](./docs/cicd-setup.md)

## API 명세

### GET /api/message
저장된 메시지를 조회합니다.

**Response:**
```json
{
  "id": 1,
  "content": "안녕하세요! 이것은 데이터베이스에서 가져온 메시지입니다.",
  "createdAt": "2024-07-24T10:30:00"
}
```

## 환경 변수

### 백엔드 (.env)
```
DATABASE_URL=jdbc:mysql://localhost:3306/aws_docker_db
DATABASE_USERNAME=root
DATABASE_PASSWORD=password
```

### AWS 배포용
```
AWS_REGION=ap-northeast-2
ECR_REPOSITORY=aws-docker-backend
S3_BUCKET=aws-docker-frontend
CLOUDFRONT_DISTRIBUTION_ID=XXXXXXXXXX
```

## 기술 스택

### 프론트엔드
- Flutter 3.x
- HTTP 패키지 (API 통신)
- Material Design 3

### 백엔드  
- Spring Boot 3.x
- Spring Data JPA
- MySQL 8.x
- Docker

### 인프라
- AWS App Runner (백엔드)
- AWS S3 + CloudFront (프론트엔드)
- AWS RDS MySQL (데이터베이스)
- AWS ECR (컨테이너 레지스트리)
- GitHub Actions (CI/CD)

## 개발 가이드라인

1. **코드 스타일**: 각 언어별 공식 스타일 가이드 준수
2. **커밋 메시지**: Conventional Commits 형식 사용
3. **브랜치 전략**: GitHub Flow 사용
4. **테스트**: 단위 테스트 및 통합 테스트 작성

## 문제 해결

자주 발생하는 문제와 해결 방법은 [문제 해결 가이드](./docs/troubleshooting.md)를 참고하세요.

## 라이센스

MIT License
