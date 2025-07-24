@echo off
chcp 65001 >nul 2>&1
title AWS Docker Project - Start Services

echo.
echo ====================================
echo    AWS Docker Project - Start
echo ====================================
echo.

REM Move to project root
cd /d "%~dp0.."

echo Project path: %CD%
echo.

echo Checking Docker status...
docker info >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Docker is running.
) else (
    echo [ERROR] Docker is not running.
    echo [ERROR] Please start Docker Desktop.
    pause
    exit /b 1
)

echo.
echo Starting all services...
docker-compose up -d

if %errorLevel% == 0 (
    echo [SUCCESS] All services started successfully!
    echo.
    echo Access URLs:
    echo   Frontend:      http://localhost:3000
    echo   Backend API:   http://localhost:8080
    echo   Health check:  http://localhost:8080/api/health
    echo   phpMyAdmin:    http://localhost:8081
    echo.
    echo Service status:
    echo   docker-compose ps
    echo   docker-compose logs -f
    echo.
    echo To stop services:
    echo   scripts\stop-simple.bat
    echo.
) else (
    echo [ERROR] Failed to start services.
    echo [ERROR] Check logs: docker-compose logs
)

echo Visit http://localhost:3000 in your browser to test the application!
echo.
pause