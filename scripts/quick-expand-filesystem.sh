#!/bin/bash
# Quick filesystem expansion after EBS volume increase

echo "=== EC2 파일 시스템 확장 스크립트 ==="
echo

# 1. 현재 상태 확인
echo "1. 현재 디스크 상태:"
df -h
echo
lsblk
echo

# 2. 파티션 확장
echo "2. 파티션 확장 중..."
sudo growpart /dev/xvda 1 2>/dev/null || sudo growpart /dev/nvme0n1 1 2>/dev/null || echo "파티션이 이미 최대 크기입니다."
echo

# 3. 파일 시스템 타입 확인
FS_TYPE=$(df -T / | awk 'NR==2 {print $2}')
echo "3. 파일 시스템 타입: $FS_TYPE"
echo

# 4. 파일 시스템 확장
echo "4. 파일 시스템 확장 중..."
if [ "$FS_TYPE" = "xfs" ]; then
    sudo xfs_growfs /
elif [ "$FS_TYPE" = "ext4" ] || [ "$FS_TYPE" = "ext3" ]; then
    ROOT_DEVICE=$(df / | awk 'NR==2 {print $1}')
    sudo resize2fs $ROOT_DEVICE
else
    echo "지원하지 않는 파일 시스템: $FS_TYPE"
    exit 1
fi
echo

# 5. 결과 확인
echo "5. 확장 완료! 새로운 디스크 상태:"
df -h
echo

echo "✅ 파일 시스템 확장이 완료되었습니다!"