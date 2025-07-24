@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

title AWS Docker Project Setup - Windows

REM Move to project root directory
cd /d "%~dp0.."
set "PROJECT_ROOT=%CD%"

echo.
echo ====================================
echo  AWS Docker Project Windows Setup
echo ====================================
echo.
echo Project path: %PROJECT_ROOT%
echo.

REM Check administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Running with administrator privileges.
) else (
    echo [WARNING] Administrator privileges recommended.
    echo [WARNING] Some features may be limited.
)

echo.
echo ====================================
echo     Checking Prerequisites
echo ====================================

REM Check Docker
docker --version >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Docker is installed.
    for /f "tokens=3" %%i in ('docker --version') do set DOCKER_VERSION=%%i
    echo           Docker version: !DOCKER_VERSION!
) else (
    echo [ERROR] Docker is not installed.
    echo [ERROR] Please install Docker Desktop from https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

REM Check Docker Compose
docker-compose --version >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Docker Compose is installed.
) else (
    echo [ERROR] Docker Compose is not installed.
    echo [ERROR] It should be included with Docker Desktop.
    pause
    exit /b 1
)

REM Check Java (optional)
java -version >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Java is installed.
) else (
    echo [WARNING] Java is not installed.
    echo [WARNING] Java 17 is needed for local backend development.
)

REM Check Flutter (optional)
flutter --version >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Flutter is installed.
) else (
    echo [WARNING] Flutter is not installed.
    echo [WARNING] Flutter is needed for local frontend development.
)

echo.
echo ====================================
echo     Creating Environment Files
echo ====================================

REM Create .env file
if not exist ".env" (
    copy ".env.example" ".env" >nul 2>&1
    if %errorLevel% == 0 (
        echo [SUCCESS] .env file created.
        echo [WARNING] Please modify .env file values as needed.
    ) else (
        echo [ERROR] Failed to create .env file.
    )
) else (
    echo [INFO] .env file already exists.
)

REM Create backend .env file
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
    echo [SUCCESS] backend\.env file created.
) else (
    echo [INFO] backend\.env file already exists.
)

echo.
echo ====================================
echo     Creating Directories
echo ====================================

if not exist "logs" mkdir "logs"
if not exist "data" mkdir "data"
if not exist "data\mysql" mkdir "data\mysql"
if not exist "data\redis" mkdir "data\redis"
if not exist "frontend\build\web" mkdir "frontend\build\web"

echo [SUCCESS] Required directories created.

echo.
echo ====================================
echo     Checking Backend Dependencies
echo ====================================

if exist "backend\gradlew.bat" (
    cd backend
    echo [INFO] Checking Gradle dependencies...
    
    REM Download dependencies if Java is installed
    java -version >nul 2>&1
    if !errorLevel! == 0 (
        gradlew.bat dependencies --quiet >nul 2>&1
        if !errorLevel! == 0 (
            echo [SUCCESS] Backend dependencies setup completed.
        ) else (
            echo [WARNING] Issue occurred while downloading backend dependencies.
        )
    ) else (
        echo [WARNING] Skipping Gradle dependencies because Java is not installed.
    )
    cd ..
) else (
    echo [ERROR] backend\gradlew.bat file not found.
)

echo.
echo ====================================
echo     Checking Frontend Dependencies
echo ====================================

if exist "frontend\pubspec.yaml" (
    cd frontend
    echo [INFO] Checking Flutter dependencies...
    
    REM Download dependencies if Flutter is installed
    flutter --version >nul 2>&1
    if !errorLevel! == 0 (
        flutter pub get >nul 2>&1
        if !errorLevel! == 0 (
            echo [SUCCESS] Frontend dependencies setup completed.
        ) else (
            echo [WARNING] Issue occurred while downloading frontend dependencies.
        )
    ) else (
        echo [WARNING] Skipping Flutter dependencies because Flutter is not installed.
    )
    cd ..
) else (
    echo [ERROR] frontend\pubspec.yaml file not found.
)

echo.
echo ====================================
echo     Setting Up Docker Environment
echo ====================================

echo [INFO] Checking Docker service status...
docker info >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Docker is running properly.
    
    echo [INFO] Building Docker images...
    docker-compose build --no-cache >nul 2>&1
    if !errorLevel! == 0 (
        echo [SUCCESS] Docker image build completed.
    ) else (
        echo [WARNING] Issue occurred during Docker image build.
    )
    
    echo [INFO] Starting MySQL container...
    docker-compose up -d mysql >nul 2>&1
    if !errorLevel! == 0 (
        echo [SUCCESS] MySQL container started.
        
        echo [INFO] Waiting for MySQL database to be ready...
        timeout /t 30 /nobreak >nul
        
        echo [INFO] Starting backend container...
        docker-compose up -d backend >nul 2>&1
        if !errorLevel! == 0 (
            echo [SUCCESS] Backend container started.
        ) else (
            echo [WARNING] Issue occurred while starting backend container.
        )
    ) else (
        echo [ERROR] Failed to start MySQL container.
    )
) else (
    echo [ERROR] Docker is not running.
    echo [ERROR] Please start Docker Desktop.
)

echo.
echo ====================================
echo     Checking Service Status
echo ====================================

echo [INFO] Checking service status...

REM MySQL health check
docker-compose exec -T mysql mysqladmin ping -h localhost --silent >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] MySQL database is running properly.
) else (
    echo [WARNING] MySQL database connection failed.
)

REM Backend API health check
echo [INFO] Checking backend API status...
set /a count=0
:healthcheck_loop
if !count! geq 30 (
    echo [WARNING] Backend API health check failed.
    goto :healthcheck_end
)

curl -f -s http://localhost:8080/api/health >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Backend API is running properly.
    goto :healthcheck_end
) else (
    set /a count+=1
    echo [INFO] Waiting for backend API to start... (!count!/30^)
    timeout /t 10 /nobreak >nul
    goto :healthcheck_loop
)

:healthcheck_end

echo.
echo ====================================
echo     Setup Complete!
echo ====================================

echo [SUCCESS] Windows environment setup completed!
echo.
echo Available commands:
echo.
echo   Docker commands:
echo     docker-compose up -d              # Start all services
echo     docker-compose down               # Stop all services  
echo     docker-compose logs -f            # View logs
echo     docker-compose ps                 # Check container status
echo.
echo   Development commands:
echo     cd backend ^&^& gradlew.bat bootRun    # Run backend locally
echo     cd frontend ^&^& flutter run -d web    # Run frontend locally
echo.
echo   Access URLs:
echo     Frontend:     http://localhost:3000
echo     Backend API:  http://localhost:8080
echo     Health check: http://localhost:8080/api/health  
echo     phpMyAdmin:   http://localhost:8081
echo.
echo   Monitoring:
echo     docker-compose logs backend       # Backend logs
echo     docker-compose logs mysql         # MySQL logs
echo.
echo   Useful batch files:
echo     scripts\start-all.bat             # Start all services
echo     scripts\stop-all.bat              # Stop all services
echo     scripts\restart-all.bat           # Restart all services
echo.

echo Project setup completed. Happy coding! 
echo.
pause