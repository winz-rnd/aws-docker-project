#!/bin/bash
# AWS 배포 검증 스크립트

EC2_HOST="13.209.88.100"

echo "=== AWS Docker 배포 검증 ==="
echo "EC2 Host: $EC2_HOST"
echo ""

# 1. Frontend 확인
echo "1. Frontend 상태 확인 (http://$EC2_HOST:3000)"
frontend_status=$(curl -s -o /dev/null -w "%{http_code}" http://$EC2_HOST:3000)
if [ "$frontend_status" = "200" ]; then
    echo "   ✓ Frontend is running (Status: $frontend_status)"
else
    echo "   ✗ Frontend is not accessible (Status: $frontend_status)"
fi

# 2. Backend API 확인
echo ""
echo "2. Backend API 상태 확인 (http://$EC2_HOST:8081/api/message)"
backend_response=$(curl -s http://$EC2_HOST:8081/api/message)
if [ $? -eq 0 ]; then
    echo "   ✓ Backend API is responding"
    echo "   Response: $backend_response"
else
    echo "   ✗ Backend API is not accessible"
fi

# 3. Health Check
echo ""
echo "3. Backend Health Check (http://$EC2_HOST:8081/actuator/health)"
health_status=$(curl -s http://$EC2_HOST:8081/actuator/health)
if [ $? -eq 0 ]; then
    echo "   ✓ Health check passed"
    echo "   Status: $health_status"
else
    echo "   ✗ Health check failed"
fi

# 4. CORS 테스트
echo ""
echo "4. CORS 설정 확인"
cors_headers=$(curl -s -I -X OPTIONS http://$EC2_HOST:8081/api/message -H "Origin: http://$EC2_HOST:3000")
if echo "$cors_headers" | grep -q "Access-Control-Allow-Origin"; then
    echo "   ✓ CORS headers are configured"
else
    echo "   ✗ CORS headers missing"
fi

echo ""
echo "=== 테스트 완료 ==="
echo ""
echo "브라우저에서 다음 URL을 확인하세요:"
echo "- Frontend: http://$EC2_HOST:3000"
echo "- API Test: http://$EC2_HOST:8081/api/message"