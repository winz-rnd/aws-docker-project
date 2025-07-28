#!/bin/bash
# Ubuntu EC2 파일 시스템 확장 스크립트

echo "=== Ubuntu EC2 파일 시스템 확장 스크립트 ==="
echo

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. 현재 상태 확인
echo -e "${YELLOW}1. 현재 디스크 상태:${NC}"
df -h
echo
echo -e "${YELLOW}블록 디바이스 정보:${NC}"
lsblk
echo

# 2. growpart 설치 확인
echo -e "${YELLOW}2. 필요한 도구 설치 확인...${NC}"
if ! command -v growpart &> /dev/null; then
    echo "cloud-guest-utils 설치 중..."
    sudo apt-get update
    sudo apt-get install -y cloud-guest-utils
fi

# 3. 파티션 확장
echo -e "${YELLOW}3. 파티션 확장 중...${NC}"
echo "명령어: sudo growpart /dev/nvme0n1 1"
sudo growpart /dev/nvme0n1 1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 파티션 확장 성공${NC}"
else
    echo -e "${RED}✗ 파티션이 이미 최대 크기이거나 오류가 발생했습니다${NC}"
fi
echo

# 4. 파일 시스템 타입 확인
FS_TYPE=$(df -T / | awk 'NR==2 {print $2}')
echo -e "${YELLOW}4. 파일 시스템 타입: $FS_TYPE${NC}"

# 5. 파일 시스템 확장
echo -e "${YELLOW}5. 파일 시스템 확장 중...${NC}"
if [ "$FS_TYPE" = "ext4" ]; then
    echo "명령어: sudo resize2fs /dev/nvme0n1p1"
    sudo resize2fs /dev/nvme0n1p1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 파일 시스템 확장 성공${NC}"
    else
        echo -e "${RED}✗ 파일 시스템 확장 실패${NC}"
    fi
else
    echo -e "${RED}지원하지 않는 파일 시스템: $FS_TYPE${NC}"
    echo "수동으로 확장해야 합니다."
fi
echo

# 6. 결과 확인
echo -e "${GREEN}6. 확장 완료! 새로운 디스크 상태:${NC}"
df -h
echo
lsblk
echo

# 7. 추가 정보
echo -e "${GREEN}=== 확장 완료 ===${NC}"
echo "루트 파티션이 성공적으로 확장되었습니다."
echo
echo -e "${YELLOW}도움이 되는 명령어:${NC}"
echo "- 디스크 사용량 확인: df -h"
echo "- 큰 파일 찾기: sudo du -h / 2>/dev/null | sort -rh | head -20"
echo "- Docker 정리: docker system prune -af --volumes"