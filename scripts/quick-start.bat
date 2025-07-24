@echo off
chcp 65001 >nul 2>&1
title AWS Docker Project - Quick Start

echo.
echo ====================================
echo     Quick Start - Docker Fix
echo ====================================
echo.

REM Move to project root
cd /d "%~dp0.."

echo Cleaning up previous containers...
docker-compose down >nul 2>&1

echo.
echo Removing old images (this may take a moment)...
docker-compose build --no-cache

if %errorLevel% == 0 (
    echo [SUCCESS] Docker images built successfully!
    echo.
    echo Starting services...
    docker-compose up -d
    
    if !errorLevel! == 0 (
        echo [SUCCESS] Services started!
        echo.
        echo Waiting for services to be ready...
        timeout /t 30 /nobreak >nul
        
        echo Testing backend API...
        curl -s http://localhost:8080/api/health >nul 2>&1
        if !errorLevel! == 0 (
            echo [SUCCESS] Backend is ready!
            echo.
            echo All services are now running:
            echo   Frontend:  http://localhost:3000
            echo   Backend:   http://localhost:8080/api/health
            echo   Database:  http://localhost:8081 (phpMyAdmin)
            echo.
            echo Visit http://localhost:3000 to test the application!
        ) else (
            echo [INFO] Backend is starting up... please wait a moment
            echo [INFO] Then visit http://localhost:3000
        )
    ) else (
        echo [ERROR] Failed to start services
        echo Check logs: docker-compose logs
    )
) else (
    echo [ERROR] Failed to build Docker images
    echo Please check your Docker installation
)

echo.
pause