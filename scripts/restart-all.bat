@echo off
title AWS Docker Project - Restart All Services

echo.
echo ================================
echo   AWS Docker Project 재시작
echo ================================
echo.

REM 프로젝트 루트로 이동
cd /d "%~dp0.."

echo [94m[INFO][0m 프로젝트 경로: %CD%
echo.

echo [94m[INFO][0m 모든 서비스를 중지합니다...
docker-compose down

if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m 서비스가 중지되었습니다.
    
    echo [94m[INFO][0m 모든 서비스를 다시 시작합니다...
    docker-compose up -d
    
    if !errorLevel! == 0 (
        echo [92m[SUCCESS][0m 모든 서비스가 성공적으로 재시작되었습니다!
        echo.
        echo [93m🌐 접속 가능한 URL:[0m
        echo   프론트엔드:      http://localhost:3000
        echo   백엔드 API:      http://localhost:8080
        echo   백엔드 헬스체크:  http://localhost:8080/api/health
        echo   phpMyAdmin:     http://localhost:8081
        echo.
    ) else (
        echo [91m[ERROR][0m 서비스 재시작에 실패했습니다.
    )
) else (
    echo [91m[ERROR][0m 서비스 중지에 실패했습니다.
)

echo.
pause