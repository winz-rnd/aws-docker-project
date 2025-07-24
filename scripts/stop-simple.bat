@echo off
chcp 65001 >nul 2>&1
title AWS Docker Project - Stop Services

echo.
echo ====================================
echo    AWS Docker Project - Stop
echo ====================================
echo.

REM Move to project root
cd /d "%~dp0.."

echo Project path: %CD%
echo.

echo Stopping all services...
docker-compose down

if %errorLevel% == 0 (
    echo [SUCCESS] All services stopped successfully!
    echo.
    echo To restart services:
    echo   scripts\start-simple.bat
    echo.
    echo To reset data (WARNING - deletes all data):
    echo   docker-compose down -v
    echo.
) else (
    echo [ERROR] Failed to stop services.
    echo [ERROR] Check manually: docker-compose ps
)

echo.
pause