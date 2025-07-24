@echo off
chcp 65001 >nul 2>&1
title AWS Docker Project - API Test

echo.
echo ====================================
echo     API Connection Test
echo ====================================
echo.

REM Move to project root
cd /d "%~dp0.."

echo Testing API server connection...
echo.

echo [TEST 1] Backend health check...
curl -s http://localhost:8080/api/health
if %errorLevel% == 0 (
    echo.
    echo [SUCCESS] Health check passed!
) else (
    echo [ERROR] Health check failed! Please check backend server.
)

echo.
echo [TEST 2] Random message retrieval...
curl -s http://localhost:8080/api/message
if %errorLevel% == 0 (
    echo.
    echo [SUCCESS] Message retrieval successful!
) else (
    echo [ERROR] Message retrieval failed! Please check API server.
)

echo.
echo [TEST 3] All messages retrieval...
curl -s http://localhost:8080/api/messages
if %errorLevel% == 0 (
    echo.
    echo [SUCCESS] All messages retrieval successful!
) else (
    echo [ERROR] All messages retrieval failed!
)

echo.
echo ====================================
echo      Test Complete
echo ====================================
echo.
echo Tips:
echo   - Visit http://localhost:3000 in browser for frontend test
echo   - Use Postman for detailed API endpoint testing
echo   - Check phpMyAdmin (http://localhost:8081) for database
echo.
pause