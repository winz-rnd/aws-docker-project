@echo off
title AWS Docker Project - Stop All Services

echo.
echo ================================
echo    AWS Docker Project 중지
echo ================================
echo.

REM 프로젝트 루트로 이동
cd /d "%~dp0.."

echo [94m[INFO][0m 프로젝트 경로: %CD%
echo.

echo [94m[INFO][0m 모든 서비스를 중지합니다...
docker-compose down

if %errorLevel% == 0 (
    echo [92m[SUCCESS][0m 모든 서비스가 성공적으로 중지되었습니다!
    echo.
    echo [93m🔄 서비스 재시작:[0m
    echo   scripts\start-all.bat
    echo.
    echo [93m🗑️ 데이터 초기화 (주의!):[0m
    echo   docker-compose down -v
    echo.
) else (
    echo [91m[ERROR][0m 서비스 중지에 실패했습니다.
    echo [91m[ERROR][0m 수동으로 확인해주세요: docker-compose ps
)

echo.
pause