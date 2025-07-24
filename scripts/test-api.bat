@echo off
title AWS Docker Project - API Test

echo.
echo ================================
echo     API 연결 테스트
echo ================================
echo.

REM 프로젝트 루트로 이동
cd /d "%~dp0.."

echo [94m[INFO][0m API 서버 연결을 테스트합니다...
echo.

echo [94m[TEST 1][0m 백엔드 헬스체크...
curl -s http://localhost:8080/api/health
if %errorLevel% == 0 (
    echo.
    echo [92m[SUCCESS][0m 헬스체크 성공!
) else (
    echo [91m[ERROR][0m 헬스체크 실패! 백엔드 서버를 확인해주세요.
)

echo.
echo [94m[TEST 2][0m 랜덤 메시지 조회...
curl -s http://localhost:8080/api/message
if %errorLevel% == 0 (
    echo.
    echo [92m[SUCCESS][0m 메시지 조회 성공!
) else (
    echo [91m[ERROR][0m 메시지 조회 실패! API 서버를 확인해주세요.
)

echo.
echo [94m[TEST 3][0m 모든 메시지 조회...
curl -s http://localhost:8080/api/messages
if %errorLevel% == 0 (
    echo.
    echo [92m[SUCCESS][0m 모든 메시지 조회 성공!
) else (
    echo [91m[ERROR][0m 모든 메시지 조회 실패!
)

echo.
echo ================================
echo      테스트 완료
echo ================================
echo.
echo [93m💡 팁:[0m
echo   - 브라우저에서 http://localhost:3000 접속하여 프론트엔드 테스트
echo   - Postman으로 API 엔드포인트 상세 테스트 가능
echo   - phpMyAdmin (http://localhost:8081)에서 데이터베이스 확인
echo.
pause