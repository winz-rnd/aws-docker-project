@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

REM AWS Docker Project Windows Setup Script
REM This script automatically sets up the local development environment on Windows

title AWS Docker Project Setup - Windows

REM Move to project root directory
cd /d "%~dp0.."
set "PROJECT_ROOT=%CD%"

echo.
echo [INFO] Starting AWS Docker project Windows setup...
echo [INFO] Project path: %PROJECT_ROOT%
echo.

REM 관리자 권한 확인
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m 관리자 권한으로 실행 중입니다.
) else (
    echo [93m[WARNING][0m 관리자 권한으로 실행하는 것을 권장합니다.
    echo [93m[WARNING][0m 일부 기능이 제한될 수 있습니다.
)

echo.
echo ================================
echo     사전 요구사항 확인
echo ================================

REM Docker 확인
docker --version >nul 2>&1
if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m Docker가 설치되어 있습니다.
    for /f "tokens=3" %%i in ('docker --version') do set DOCKER_VERSION=%%i
    echo                Docker 버전: !DOCKER_VERSION!
) else (
    echo [91m[ERROR][0m Docker가 설치되어 있지 않습니다.
    echo [91m[ERROR][0m https://www.docker.com/products/docker-desktop/ 에서 Docker Desktop을 설치해주세요.
    pause
    exit /b 1
)

REM Docker Compose 확인
docker-compose --version >nul 2>&1
if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m Docker Compose가 설치되어 있습니다.
    for /f "tokens=3" %%i in ('docker-compose --version') do set COMPOSE_VERSION=%%i
    echo                Docker Compose 버전: !COMPOSE_VERSION!
) else (
    echo [91m[ERROR][0m Docker Compose가 설치되어 있지 않습니다.
    echo [91m[ERROR][0m Docker Desktop에 포함되어 있어야 합니다.
    pause
    exit /b 1
)

REM Java 확인
java -version >nul 2>&1
if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m Java가 설치되어 있습니다.
    for /f "tokens=1,2,3" %%i in ('java -version 2^>^&1 ^| findstr "version"') do set JAVA_VERSION=%%k
    echo                Java 버전: !JAVA_VERSION!
) else (
    echo [93m[WARNING][0m Java가 설치되어 있지 않습니다.
    echo [93m[WARNING][0m 로컬에서 백엔드를 실행하려면 Java 17이 필요합니다.
)

REM Flutter 확인
flutter --version >nul 2>&1
if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m Flutter가 설치되어 있습니다.
    for /f "tokens=2" %%i in ('flutter --version 2^>^&1 ^| findstr "Flutter"') do set FLUTTER_VERSION=%%i
    echo                Flutter 버전: !FLUTTER_VERSION!
) else (
    echo [93m[WARNING][0m Flutter가 설치되어 있지 않습니다.
    echo [93m[WARNING][0m 로컬에서 프론트엔드를 실행하려면 Flutter가 필요합니다.
)

echo.
echo ================================
echo     환경 설정 파일 생성
echo ================================

REM .env 파일 생성
if not exist ".env" (
    copy ".env.example" ".env" >nul 2>&1
    if %errorLevel% == 0 (
        echo [92m[SUCCESS][0m .env 파일이 생성되었습니다.
        echo [93m[WARNING][0m 필요에 따라 .env 파일의 값들을 수정해주세요.
    ) else (
        echo [91m[ERROR][0m .env 파일 생성에 실패했습니다.
    )
) else (
    echo [94m[INFO][0m .env 파일이 이미 존재합니다.
)

REM 백엔드 .env 파일 생성
if not exist "backend\.env" (
    (
        echo SPRING_PROFILES_ACTIVE=dev
        echo DATABASE_URL=jdbc:mysql://localhost:3306/aws_docker_db?useSSL=false^&serverTimezone=Asia/Seoul^&characterEncoding=UTF-8
        echo DATABASE_USERNAME=root
        echo DATABASE_PASSWORD=password
        echo JPA_DDL_AUTO=update
        echo JPA_SHOW_SQL=true
        echo LOG_LEVEL=DEBUG
    ) > "backend\.env"
    echo [92m[SUCCESS][0m backend\.env 파일이 생성되었습니다.
) else (
    echo [94m[INFO][0m backend\.env 파일이 이미 존재합니다.
)

echo.
echo ================================
echo     필요한 디렉토리 생성
echo ================================

if not exist "logs" mkdir "logs"
if not exist "data" mkdir "data"
if not exist "data\mysql" mkdir "data\mysql"
if not exist "data\redis" mkdir "data\redis"
if not exist "frontend\build\web" mkdir "frontend\build\web"

echo [92m[SUCCESS][0m 필요한 디렉토리가 생성되었습니다.

echo.
echo ================================
echo     백엔드 의존성 확인
echo ================================

if exist "backend\gradlew.bat" (
    cd backend
    echo [94m[INFO][0m Gradle 의존성을 확인합니다...
    
    REM Java가 설치되어 있으면 의존성 다운로드
    java -version >nul 2>&1
    if !errorLevel! == 0 (
        gradlew.bat dependencies --quiet >nul 2>&1
        if !errorLevel! == 0 (
            echo [92m[SUCCESS][0m 백엔드 의존성 설정이 완료되었습니다.
        ) else (
            echo [93m[WARNING][0m 백엔드 의존성 다운로드 중 문제가 발생했습니다.
        )
    ) else (
        echo [93m[WARNING][0m Java가 설치되어 있지 않아 Gradle 의존성을 건너뜁니다.
    )
    cd ..
) else (
    echo [91m[ERROR][0m backend\gradlew.bat 파일을 찾을 수 없습니다.
)

echo.
echo ================================
echo     프론트엔드 의존성 확인
echo ================================

if exist "frontend\pubspec.yaml" (
    cd frontend
    echo [94m[INFO][0m Flutter 의존성을 확인합니다...
    
    REM Flutter가 설치되어 있으면 의존성 다운로드
    flutter --version >nul 2>&1
    if !errorLevel! == 0 (
        flutter pub get >nul 2>&1
        if !errorLevel! == 0 (
            echo [92m[SUCCESS][0m 프론트엔드 의존성 설정이 완료되었습니다.
        ) else (
            echo [93m[WARNING][0m 프론트엔드 의존성 다운로드 중 문제가 발생했습니다.
        )
    ) else (
        echo [93m[WARNING][0m Flutter가 설치되어 있지 않아 의존성 설치를 건너뜁니다.
    )
    cd ..
) else (
    echo [91m[ERROR][0m frontend\pubspec.yaml 파일을 찾을 수 없습니다.
)

echo.
echo ================================
echo     Docker 환경 설정
echo ================================

echo [94m[INFO][0m Docker 서비스 상태를 확인합니다...
docker info >nul 2>&1
if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m Docker가 정상적으로 실행 중입니다.
    
    echo [94m[INFO][0m Docker 이미지를 빌드합니다...
    docker-compose build --no-cache >nul 2>&1
    if !errorLevel! == 0 (
        echo [92m[SUCCESS][0m Docker 이미지 빌드가 완료되었습니다.
    ) else (
        echo [93m[WARNING][0m Docker 이미지 빌드 중 문제가 발생했습니다.
    )
    
    echo [94m[INFO][0m MySQL 컨테이너를 시작합니다...
    docker-compose up -d mysql >nul 2>&1
    if !errorLevel! == 0 (
        echo [92m[SUCCESS][0m MySQL 컨테이너가 시작되었습니다.
        
        echo [94m[INFO][0m MySQL 데이터베이스가 준비될 때까지 대기합니다...
        timeout /t 30 /nobreak >nul
        
        echo [94m[INFO][0m 백엔드 컨테이너를 시작합니다...
        docker-compose up -d backend >nul 2>&1
        if !errorLevel! == 0 (
            echo [92m[SUCCESS][0m 백엔드 컨테이너가 시작되었습니다.
        ) else (
            echo [93m[WARNING][0m 백엔드 컨테이너 시작 중 문제가 발생했습니다.
        )
    ) else (
        echo [91m[ERROR][0m MySQL 컨테이너 시작에 실패했습니다.
    )
) else (
    echo [91m[ERROR][0m Docker가 실행되고 있지 않습니다.
    echo [91m[ERROR][0m Docker Desktop을 시작해주세요.
)

echo.
echo ================================
echo     서비스 상태 확인
echo ================================

echo [94m[INFO][0m 서비스 상태를 확인합니다...

REM MySQL 헬스체크
docker-compose exec -T mysql mysqladmin ping -h localhost --silent >nul 2>&1
if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m MySQL 데이터베이스가 정상적으로 실행 중입니다.
) else (
    echo [93m[WARNING][0m MySQL 데이터베이스 연결에 실패했습니다.
)

REM 백엔드 API 헬스체크
echo [94m[INFO][0m 백엔드 API 상태를 확인합니다...
set /a count=0
:healthcheck_loop
if !count! geq 30 (
    echo [93m[WARNING][0m 백엔드 API 헬스체크에 실패했습니다.
    goto :healthcheck_end
)

curl -f -s http://localhost:8080/api/health >nul 2>&1
if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m 백엔드 API가 정상적으로 실행 중입니다.
    goto :healthcheck_end
) else (
    set /a count+=1
    echo [94m[INFO][0m 백엔드 API 시작을 대기 중입니다... (!count!/30^)
    timeout /t 10 /nobreak >nul
    goto :healthcheck_loop
)

:healthcheck_end

echo.
echo ================================
echo     설정 완료!
echo ================================

echo [92m[SUCCESS][0m 윈도우 환경 설정이 완료되었습니다!
echo.
echo [94m[INFO][0m 사용 가능한 명령어:
echo.
echo   [93m🐳 Docker 명령어:[0m
echo     docker-compose up -d              # 모든 서비스 시작
echo     docker-compose down               # 모든 서비스 중지  
echo     docker-compose logs -f            # 로그 확인
echo     docker-compose ps                 # 컨테이너 상태 확인
echo.
echo   [93m🔧 개발 명령어:[0m
echo     cd backend ^&^& gradlew.bat bootRun    # 백엔드 로컬 실행
echo     cd frontend ^&^& flutter run -d web    # 프론트엔드 로컬 실행
echo.
echo   [93m🌐 접속 URL:[0m
echo     프론트엔드:     http://localhost:3000
echo     백엔드 API:     http://localhost:8080
echo     백엔드 헬스체크: http://localhost:8080/api/health  
echo     phpMyAdmin:     http://localhost:8081
echo.
echo   [93m📊 모니터링:[0m
echo     docker-compose logs backend       # 백엔드 로그
echo     docker-compose logs mysql         # MySQL 로그
echo.
echo   [93m🔧 유용한 배치 파일:[0m
echo     scripts\start-all.bat             # 모든 서비스 시작
echo     scripts\stop-all.bat              # 모든 서비스 중지
echo     scripts\restart-all.bat           # 모든 서비스 재시작
echo.

echo 프로젝트 설정이 완료되었습니다. 즐거운 개발 되세요! 🚀
echo.
pause