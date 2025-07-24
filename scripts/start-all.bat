@echo off
title AWS Docker Project - Start All Services

echo.
echo ================================
echo    AWS Docker Project 시작
echo ================================
echo.

REM 프로젝트 루트로 이동
cd /d "%~dp0.."

echo [94m[INFO][0m 프로젝트 경로: %CD%
echo.

echo [94m[INFO][0m Docker 서비스 상태를 확인합니다...
docker info >nul 2>&1
if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m Docker가 정상적으로 실행 중입니다.
) else (
    echo [91m[ERROR][0m Docker가 실행되고 있지 않습니다.
    echo [91m[ERROR][0m Docker Desktop을 시작해주세요.
    pause
    exit /b 1
)

echo.
echo [94m[INFO][0m 모든 서비스를 시작합니다...
docker-compose up -d

if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m 모든 서비스가 성공적으로 시작되었습니다!
    echo.
    echo [93m🌐 접속 가능한 URL:[0m
    echo   프론트엔드:      http://localhost:3000
    echo   백엔드 API:      http://localhost:8080
    echo   백엔드 헬스체크:  http://localhost:8080/api/health
    echo   phpMyAdmin:     http://localhost:8081
    echo.
    echo [93m📊 서비스 상태 확인:[0m
    echo   docker-compose ps
    echo   docker-compose logs -f
    echo.
    echo [93m🛑 서비스 중지:[0m
    echo   scripts\stop-all.bat
    echo.
) else (
    echo [91m[ERROR][0m 서비스 시작에 실패했습니다.
    echo [91m[ERROR][0m 로그를 확인해주세요: docker-compose logs
)

echo 브라우저에서 http://localhost:3000 에 접속하여 애플리케이션을 확인하세요!
echo.
pause