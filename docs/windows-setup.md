# 윈도우 환경에서 로컬 테스트 가이드

윈도우에서 AWS Docker 프로젝트를 로컬에서 실행하고 테스트하는 방법을 안내합니다.

## 1. 사전 요구사항

### 필수 설치 항목

#### 1.1 Docker Desktop for Windows
```bash
# 다운로드 링크
https://www.docker.com/products/docker-desktop/

# 설치 후 확인
docker --version
docker-compose --version
```

**주의사항:**
- WSL 2 백엔드 사용 권장
- Hyper-V 또는 WSL 2 활성화 필요
- 최소 4GB RAM 권장

#### 1.2 Java 17 (백엔드 로컬 실행용)
```bash
# Oracle JDK 17 또는 OpenJDK 17 설치
https://adoptium.net/

# 설치 후 확인
java -version
javac -version

# 환경변수 설정 확인
echo %JAVA_HOME%
```

#### 1.3 Flutter SDK (프론트엔드 로컬 실행용)
```bash
# Flutter 다운로드
https://docs.flutter.dev/get-started/install/windows

# 설치 후 확인
flutter doctor

# Chrome 설치 확인 (웹 개발용)
flutter devices
```

#### 1.4 Git for Windows
```bash
# 다운로드
https://git-scm.com/download/win

# 설치 후 확인
git --version
```

### 선택 설치 항목

#### 1.5 MySQL Workbench (DB 관리용)
```bash
# 다운로드
https://dev.mysql.com/downloads/workbench/
```

#### 1.6 Postman (API 테스트용)
```bash
# 다운로드
https://www.postman.com/downloads/
```

#### 1.7 VS Code (코드 편집기)
```bash
# 다운로드
https://code.visualstudio.com/

# 유용한 확장프로그램
- Docker
- Flutter
- Java Extension Pack
- REST Client
```

## 2. 윈도우 환경 설정

### 2.1 WSL 2 설정 (권장)
```powershell
# PowerShell을 관리자 권한으로 실행
# WSL 기능 활성화
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 가상 머신 플랫폼 활성화
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 재부팅 후 WSL 2로 설정
wsl --set-default-version 2

# Ubuntu 설치 (선택사항)
wsl --install -d Ubuntu
```

### 2.2 Docker Desktop 설정
1. **Settings → General**
   - ✅ Use WSL 2 based engine
   - ✅ Expose daemon on tcp://localhost:2375

2. **Settings → Resources → WSL Integration**
   - ✅ Enable integration with my default WSL distro
   - ✅ Ubuntu (설치한 경우)

3. **Settings → Docker Engine**
   ```json
   {
     "registry-mirrors": [],
     "insecure-registries": [],
     "debug": false,
     "experimental": false
   }
   ```

### 2.3 방화벽 설정
```powershell
# PowerShell을 관리자 권한으로 실행
# Docker Desktop을 방화벽에서 허용
New-NetFirewallRule -DisplayName "Docker Desktop" -Direction Inbound -Protocol TCP -LocalPort 2375
New-NetFirewallRule -DisplayName "MySQL" -Direction Inbound -Protocol TCP -LocalPort 3306
New-NetFirewallRule -DisplayName "Backend API" -Direction Inbound -Protocol TCP -LocalPort 8080
New-NetFirewallRule -DisplayName "Frontend" -Direction Inbound -Protocol TCP -LocalPort 3000
```

## 3. 프로젝트 클론 및 설정

### 3.1 프로젝트 클론
```cmd
# Command Prompt 또는 PowerShell에서 실행
cd C:\
mkdir Projects
cd Projects
git clone <your-repository-url> AWS_Docker
cd AWS_Docker
```

### 3.2 환경 설정 파일 생성
```cmd
# .env 파일 생성
copy .env.example .env

# 윈도우용 설정으로 수정 (.env 파일)
DATABASE_URL=jdbc:mysql://localhost:3306/aws_docker_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8
DATABASE_USERNAME=root
DATABASE_PASSWORD=password
API_URL=http://localhost:8080
```

### 3.3 백엔드 환경 설정
```cmd
cd backend
copy ..\backend\.env.example .env

# backend\.env 파일 내용
SPRING_PROFILES_ACTIVE=dev
DATABASE_URL=jdbc:mysql://localhost:3306/aws_docker_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8
DATABASE_USERNAME=root
DATABASE_PASSWORD=password
JPA_DDL_AUTO=update
JPA_SHOW_SQL=true
LOG_LEVEL=DEBUG
```

## 4. Docker로 실행하기 (권장 방법)

### 4.1 Docker Compose 실행
```cmd
# 프로젝트 루트에서 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 특정 서비스 로그만 확인
docker-compose logs -f backend
docker-compose logs -f mysql
```

### 4.2 서비스 상태 확인
```cmd
# 컨테이너 상태 확인
docker-compose ps

# 헬스체크
curl http://localhost:8080/api/health
```

### 4.3 Docker 문제 해결
```cmd
# Docker Desktop 재시작
# Windows 서비스에서 Docker Desktop Service 재시작

# 컨테이너 재시작
docker-compose down
docker-compose up -d

# 볼륨 초기화 (데이터 삭제 주의!)
docker-compose down -v
docker-compose up -d
```

## 5. 개별 실행하기 (개발용)

### 5.1 MySQL만 Docker로 실행
```cmd
# MySQL 컨테이너만 실행
docker-compose up -d mysql

# MySQL 연결 확인
docker-compose exec mysql mysql -u root -p
```

### 5.2 백엔드 로컬 실행
```cmd
# Command Prompt에서 실행
cd backend

# Gradle Wrapper 권한 설정 (WSL 환경에서)
# WSL에서: chmod +x gradlew

# 윈도우에서 직접 실행
gradlew.bat bootRun

# 또는 IDE에서 실행
# IntelliJ IDEA: AwsDockerApplication.java 우클릭 → Run
```

### 5.3 프론트엔드 로컬 실행
```cmd
# Command Prompt에서 실행
cd frontend

# 의존성 설치
flutter pub get

# 웹 실행
flutter run -d web-server --web-port 3000

# 또는 Chrome에서 실행
flutter run -d chrome --web-port 3000
```

## 6. 테스트 실행

### 6.1 백엔드 테스트
```cmd
cd backend

# 단위 테스트 실행
gradlew.bat test

# 테스트 리포트 확인
start build\reports\tests\test\index.html
```

### 6.2 프론트엔드 테스트
```cmd
cd frontend

# 코드 분석
flutter analyze

# 단위 테스트 실행
flutter test

# 웹 통합 테스트
flutter drive --target=test_driver/app.dart -d web-server
```

### 6.3 API 테스트
```cmd
# curl 사용 (Git Bash 또는 WSL에서)
curl http://localhost:8080/api/health
curl http://localhost:8080/api/message

# PowerShell 사용
Invoke-RestMethod -Uri http://localhost:8080/api/health
Invoke-RestMethod -Uri http://localhost:8080/api/message
```

## 7. 윈도우 특화 도구 활용

### 7.1 Windows Terminal 설정
```json
// settings.json에 추가
{
    "name": "AWS Docker Project",
    "commandline": "cmd.exe /k cd /d C:\\Projects\\AWS_Docker",
    "startingDirectory": "C:\\Projects\\AWS_Docker",
    "icon": "🐳"
}
```

### 7.2 배치 파일 활용
```batch
:: start-all.bat
@echo off
echo Starting AWS Docker Project...
cd /d C:\Projects\AWS_Docker
docker-compose up -d
echo Services started!
pause
```

```batch
:: stop-all.bat
@echo off
echo Stopping AWS Docker Project...
cd /d C:\Projects\AWS_Docker
docker-compose down
echo Services stopped!
pause
```

### 7.3 PowerShell 스크립트
```powershell
# start-project.ps1
Set-Location "C:\Projects\AWS_Docker"
Write-Host "Starting AWS Docker Project..." -ForegroundColor Green
docker-compose up -d
Write-Host "Services started successfully!" -ForegroundColor Green
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend: http://localhost:8080" -ForegroundColor Cyan
```

## 8. 자주 발생하는 윈도우 문제

### 8.1 Docker 관련 문제
```cmd
# Docker Desktop이 시작되지 않는 경우
# 1. Windows 기능에서 Hyper-V 활성화
# 2. BIOS에서 가상화 기술 활성화
# 3. WSL 2 설치 및 업데이트

# 포트 충돌 문제
netstat -ano | findstr :8080
taskkill /PID <PID번호> /F
```

### 8.2 경로 관련 문제
```cmd
# 백슬래시 문제 해결
# Windows: C:\Projects\AWS_Docker
# Docker: /c/Projects/AWS_Docker (Git Bash)
# WSL: /mnt/c/Projects/AWS_Docker
```

### 8.3 권한 문제
```cmd
# PowerShell 실행 정책 변경
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 파일 권한 문제 (WSL에서)
chmod +x gradlew
chmod +x scripts/setup.sh
```

## 9. 개발 환경 최적화

### 9.1 IDE 설정
**IntelliJ IDEA:**
- Spring Boot 플러그인 설치
- Docker 플러그인 활성화
- Gradle 자동 가져오기 설정

**VS Code:**
```json
// .vscode/settings.json
{
    "java.home": "C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.8.101-hotspot",
    "flutter.flutterSdkPath": "C:\\flutter",
    "docker.host": "tcp://localhost:2375"
}
```

### 9.2 성능 최적화
```cmd
# Docker Desktop 메모리 할당 증가
# Settings → Resources → Advanced → Memory: 4GB 이상

# WSL 2 메모리 제한 설정
# %UserProfile%\.wslconfig
[wsl2]
memory=4GB
processors=2
```

## 10. 접속 URL 정리

로컬 환경에서 접속할 수 있는 URL들:

- **프론트엔드**: http://localhost:3000
- **백엔드 API**: http://localhost:8080
- **백엔드 헬스체크**: http://localhost:8080/api/health
- **phpMyAdmin**: http://localhost:8081
- **MySQL**: localhost:3306

이제 윈도우 환경에서 완전한 로컬 개발 환경을 구축할 수 있습니다! 🚀