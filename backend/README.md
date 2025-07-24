# Spring Boot 백엔드 API

Flutter 웹 애플리케이션을 위한 RESTful API 서버입니다.

## 기술 스택

- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Data JPA**
- **MySQL 8.0** (프로덕션)
- **H2 Database** (개발/테스트)
- **Docker**

## API 엔드포인트

### 헬스체크
- `GET /api/health` - 서버 상태 확인

### 메시지 API
- `GET /api/message` - 랜덤 메시지 조회 (Flutter에서 사용)
- `GET /api/messages` - 모든 메시지 조회
- `GET /api/messages/{id}` - 특정 메시지 조회
- `GET /api/message/latest` - 최신 메시지 조회
- `POST /api/messages` - 새 메시지 생성
- `PUT /api/messages/{id}` - 메시지 수정
- `DELETE /api/messages/{id}` - 메시지 삭제

## 로컬 개발 환경 설정

### 1. 사전 요구사항
- Java 17 이상
- Docker (선택사항)

### 2. 애플리케이션 실행

#### Gradle로 실행
```bash
# 의존성 설치 및 애플리케이션 실행
./gradlew bootRun
```

#### Docker로 실행
```bash
# Docker 이미지 빌드
docker build -t aws-docker-backend .

# 컨테이너 실행
docker run -p 8080:8080 aws-docker-backend
```

### 3. H2 데이터베이스 콘솔 (개발용)
- URL: http://localhost:8080/h2-console
- JDBC URL: jdbc:h2:mem:testdb
- Username: sa
- Password: (빈값)

## 환경별 설정

### Local (기본)
- H2 인메모리 데이터베이스 사용
- 자동으로 테스트 데이터 생성
- 개발자 도구 활성화

### Development (MySQL)
```bash
# MySQL 프로필로 실행
./gradlew bootRun --args='--spring.profiles.active=dev'

# 또는 환경변수 설정
export SPRING_PROFILES_ACTIVE=dev
./gradlew bootRun
```

### Production (AWS)
```bash
# 환경변수 설정 후 실행
export SPRING_PROFILES_ACTIVE=prod
export DATABASE_URL=jdbc:mysql://aws-docker-db.xxxxxxxxxx.ap-northeast-2.rds.amazonaws.com:3306/aws_docker_db
export DATABASE_USERNAME=admin
export DATABASE_PASSWORD=your-secure-password
./gradlew bootRun
```

## Docker Compose (개발용)

MySQL과 함께 실행하려면:

```yaml
# docker-compose.yml 예시
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: aws_docker_db
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

  backend:
    build: .
    ports:
      - "8080:8080"
    environment:
      SPRING_PROFILES_ACTIVE: dev
      DATABASE_URL: jdbc:mysql://mysql:3306/aws_docker_db
      DATABASE_USERNAME: root
      DATABASE_PASSWORD: password
    depends_on:
      - mysql

volumes:
  mysql_data:
```

## 테스트

```bash
# 단위 테스트 실행
./gradlew test

# 통합 테스트 포함 모든 테스트 실행
./gradlew check
```

## API 테스트

### cURL 예시
```bash
# 헬스체크
curl http://localhost:8080/api/health

# 랜덤 메시지 조회
curl http://localhost:8080/api/message

# 모든 메시지 조회
curl http://localhost:8080/api/messages

# 새 메시지 생성
curl -X POST http://localhost:8080/api/messages \
  -H "Content-Type: application/json" \
  -d '{"content":"새로운 메시지입니다!"}'
```

## 모니터링

### Actuator 엔드포인트
- `/actuator/health` - 헬스체크
- `/actuator/info` - 애플리케이션 정보
- `/actuator/metrics` - 메트릭 정보

## 문제 해결

### 일반적인 이슈

1. **포트 충돌**
   ```bash
   # 다른 포트로 실행
   ./gradlew bootRun --args='--server.port=8081'
   ```

2. **데이터베이스 연결 실패**
   - MySQL 서버 상태 확인
   - 연결 정보 (URL, 사용자명, 비밀번호) 확인
   - 방화벽 설정 확인

3. **메모리 부족**
   ```bash
   # JVM 힙 메모리 증가
   export JAVA_OPTS="-Xms512m -Xmx1024m"
   ./gradlew bootRun
   ```

### 로그 확인
```bash
# 애플리케이션 로그 레벨 변경
export LOG_LEVEL=DEBUG
./gradlew bootRun
```

## 배포

### AWS App Runner 배포
1. ECR에 Docker 이미지 푸시
2. App Runner 서비스 설정
3. 환경변수 구성
4. 자동 배포 활성화

자세한 배포 가이드는 [AWS 설정 가이드](../docs/aws-setup.md)를 참고하세요.