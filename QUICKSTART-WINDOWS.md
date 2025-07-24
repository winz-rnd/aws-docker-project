# 🚀 윈도우에서 빠른 시작 가이드

윈도우 환경에서 AWS Docker 프로젝트를 5분 안에 실행하는 방법입니다.

## ⚡ 빠른 실행 (권장)

### 1단계: 사전 요구사항 확인
- ✅ **Docker Desktop for Windows** 설치 및 실행
- ✅ **WSL 2** 활성화 (권장)
- ⚠️ Java 17, Flutter는 선택사항 (Docker로 모든 것을 실행)

### 2단계: 프로젝트 설정
```cmd
# Command Prompt 또는 PowerShell에서 실행
cd C:\
mkdir Projects
cd Projects
git clone <your-repository-url> AWS_Docker
cd AWS_Docker

# 자동 설정 스크립트 실행
scripts\setup-windows.bat
```

### 3단계: 서비스 시작
```cmd
# 모든 서비스 시작
scripts\start-all.bat

# 또는 Docker Compose 직접 사용
docker-compose up -d
```

### 4단계: 접속 확인
- **프론트엔드**: http://localhost:3000
- **백엔드 API**: http://localhost:8080/api/health
- **phpMyAdmin**: http://localhost:8081

## 🎯 테스트 방법

### 기본 테스트
1. **브라우저에서 http://localhost:3000 접속**
2. **"메시지 가져오기" 버튼 클릭**
3. **데이터베이스에서 랜덤 메시지 조회 확인**

### API 테스트
```cmd
# API 테스트 스크립트 실행
scripts\test-api.bat

# 또는 수동 테스트
curl http://localhost:8080/api/health
curl http://localhost:8080/api/message
```

## 🔧 문제 해결

### Docker 문제
```cmd
# Docker Desktop 재시작
# 작업 관리자에서 Docker Desktop 종료 후 재시작

# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f
```

### 포트 충돌 문제
```cmd
# 포트 사용 확인
netstat -ano | findstr :8080
netstat -ano | findstr :3306

# 프로세스 종료 (필요시)
taskkill /PID <PID번호> /F
```

### 서비스 재시작
```cmd
# 모든 서비스 재시작
scripts\restart-all.bat

# 또는
docker-compose down
docker-compose up -d
```

## 📱 개발 모드

### 백엔드만 로컬에서 실행
```cmd
# MySQL만 Docker로 실행
docker-compose up -d mysql phpmyadmin

# 백엔드를 로컬에서 실행 (Java 17 필요)
cd backend
gradlew.bat bootRun
```

### 프론트엔드만 로컬에서 실행
```cmd
# 백엔드는 Docker로 실행
docker-compose up -d mysql backend

# 프론트엔드를 로컬에서 실행 (Flutter 필요)
cd frontend
flutter pub get
flutter run -d web-server --web-port 3000
```

## 🛠️ 유용한 명령어

### Docker 관리
```cmd
# 서비스 시작
scripts\start-all.bat

# 서비스 중지
scripts\stop-all.bat

# 서비스 재시작
scripts\restart-all.bat

# 로그 실시간 확인
docker-compose logs -f

# 특정 서비스 로그만 확인
docker-compose logs -f backend
docker-compose logs -f mysql
```

### 데이터베이스 관리
```cmd
# phpMyAdmin 접속
start http://localhost:8081
# 사용자: root, 비밀번호: password

# MySQL 콘솔 접속
docker-compose exec mysql mysql -u root -p

# 데이터베이스 초기화
docker-compose down -v
docker-compose up -d
```

### 개발 도구
```cmd
# VS Code에서 프로젝트 열기
code .

# 백엔드 IDE에서 열기 (IntelliJ IDEA)
idea backend

# API 테스트
scripts\test-api.bat
```

## 🎉 성공 확인

모든 것이 정상적으로 작동하면:

1. ✅ http://localhost:3000 에서 Flutter 웹 앱 확인
2. ✅ "메시지 가져오기" 버튼 클릭 시 메시지 표시
3. ✅ http://localhost:8080/api/health 에서 백엔드 상태 확인
4. ✅ http://localhost:8081 에서 데이터베이스 확인

## 📞 도움이 필요한 경우

1. **문제 해결 가이드**: `docs\windows-setup.md` 참고
2. **상세 문제 해결**: `docs\troubleshooting.md` 참고
3. **Docker 상태 확인**: `docker-compose ps`
4. **로그 확인**: `docker-compose logs -f`

---

🎯 **목표**: Flutter 웹에서 버튼 클릭 → Spring Boot API 호출 → MySQL 데이터베이스에서 메시지 조회

🚀 **지금 바로 시작하세요!**