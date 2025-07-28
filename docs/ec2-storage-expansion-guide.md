# EC2 인스턴스 저장 공간 확장 가이드

이 문서는 AWS EC2 인스턴스의 EBS 볼륨 크기를 늘리는 방법을 단계별로 설명합니다.

## 목차
1. [현재 디스크 사용량 확인](#1-현재-디스크-사용량-확인)
2. [AWS 콘솔에서 EBS 볼륨 확장](#2-aws-콘솔에서-ebs-볼륨-확장)
3. [EC2 인스턴스에서 파일 시스템 확장](#3-ec2-인스턴스에서-파일-시스템-확장)
4. [자동화 스크립트](#4-자동화-스크립트)

## 1. 현재 디스크 사용량 확인

### SSH로 EC2 접속
```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
```

### 디스크 사용량 확인 명령어
```bash
# 전체 디스크 사용량 확인
df -h

# 특정 디렉토리 크기 확인
du -sh /var/*
du -sh /home/*

# 파티션 정보 확인
lsblk

# 현재 볼륨 상태 확인
sudo fdisk -l
```

### 출력 예시
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       8G   7.2G  800M  91% /
```

## 2. AWS 콘솔에서 EBS 볼륨 확장

### 단계별 절차

1. **AWS Management Console 로그인**
   - EC2 Dashboard 접속

2. **볼륨 찾기**
   - 왼쪽 메뉴에서 "Elastic Block Store" → "볼륨" 클릭
   - 해당 인스턴스의 볼륨 ID 확인

3. **볼륨 수정**
   - 볼륨 선택 → "작업" → "볼륨 수정"
   - 새로운 크기 입력 (예: 8GB → 20GB)
   - "수정" 클릭

4. **상태 확인**
   - 볼륨 상태가 "optimizing"에서 "in-use"로 변경될 때까지 대기
   - 보통 5-10분 소요

### AWS CLI 사용 방법
```bash
# 볼륨 ID 확인
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 \
  --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId'

# 볼륨 크기 수정 (예: 20GB로 확장)
aws ec2 modify-volume --volume-id vol-1234567890abcdef0 --size 20

# 수정 상태 확인
aws ec2 describe-volumes-modifications --volume-ids vol-1234567890abcdef0
```

## 3. EC2 인스턴스에서 파일 시스템 확장

EBS 볼륨 크기를 늘렸더라도 파일 시스템을 확장해야 실제로 사용할 수 있습니다.

### 파티션 확장 (필요한 경우)

```bash
# 파티션 상태 확인
sudo lsblk

# growpart 설치 (Amazon Linux 2)
sudo yum install -y cloud-utils-growpart

# 파티션 확장 (예: /dev/xvda의 첫 번째 파티션)
sudo growpart /dev/xvda 1
```

### 파일 시스템 확장

#### XFS 파일 시스템 (Amazon Linux 2 기본)
```bash
# 파일 시스템 타입 확인
df -T

# XFS 파일 시스템 확장
sudo xfs_growfs /

# 확장 결과 확인
df -h
```

#### EXT4 파일 시스템
```bash
# EXT4 파일 시스템 확장
sudo resize2fs /dev/xvda1

# 확장 결과 확인
df -h
```

### 확장 전후 비교
```bash
# 확장 전
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       8G   7.2G  800M  91% /

# 확장 후
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       20G  7.2G   13G  36% /
```

## 4. 자동화 스크립트

### 디스크 사용량 모니터링 스크립트
```bash
#!/bin/bash
# disk-monitor.sh

THRESHOLD=80
CURRENT=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ $CURRENT -gt $THRESHOLD ]; then
    echo "WARNING: Disk usage is at ${CURRENT}%"
    echo "Current disk status:"
    df -h
    
    # 큰 파일/디렉토리 찾기
    echo -e "\nLargest directories:"
    du -h / 2>/dev/null | sort -rh | head -20
    
    # Docker 정리 (해당하는 경우)
    if command -v docker &> /dev/null; then
        echo -e "\nCleaning Docker resources..."
        docker system prune -af --volumes
    fi
fi
```

### 전체 확장 프로세스 자동화
```bash
#!/bin/bash
# expand-ebs-volume.sh

# 변수 설정
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
VOLUME_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId' \
  --output text)
NEW_SIZE=$1

if [ -z "$NEW_SIZE" ]; then
    echo "Usage: $0 <new-size-in-gb>"
    exit 1
fi

echo "Expanding volume $VOLUME_ID to ${NEW_SIZE}GB..."

# 1. EBS 볼륨 크기 수정
aws ec2 modify-volume --volume-id $VOLUME_ID --size $NEW_SIZE

# 2. 수정 완료 대기
echo "Waiting for volume modification to complete..."
while true; do
    STATE=$(aws ec2 describe-volumes-modifications --volume-ids $VOLUME_ID \
      --query 'VolumesModifications[0].ModificationState' --output text)
    
    if [ "$STATE" = "completed" ] || [ "$STATE" = "optimizing" ]; then
        echo "Volume modification $STATE"
        break
    fi
    
    echo "Current state: $STATE, waiting..."
    sleep 10
done

# 3. 파티션 확장
echo "Expanding partition..."
sudo growpart /dev/xvda 1

# 4. 파일 시스템 확장
echo "Expanding filesystem..."
sudo xfs_growfs / || sudo resize2fs /dev/xvda1

# 5. 결과 확인
echo "Expansion complete. New disk status:"
df -h
```

## 추가 팁

### 1. 사전 준비사항
- **백업**: 중요한 데이터는 반드시 백업
- **스냅샷**: EBS 볼륨 스냅샷 생성
- **다운타임**: 파티션 확장 시 재부팅이 필요할 수 있음

### 2. 비용 고려사항
- EBS 볼륨 크기에 따라 요금 증가
- GP3 볼륨 타입이 비용 효율적
- 불필요한 스냅샷 정기적으로 삭제

### 3. 모니터링 설정
```bash
# CloudWatch 알람 설정 (CLI)
aws cloudwatch put-metric-alarm \
  --alarm-name disk-usage-alarm \
  --alarm-description "Alarm when disk usage exceeds 80%" \
  --metric-name DiskSpaceUtilization \
  --namespace System/Linux \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1
```

### 4. 정기적인 정리 작업
```bash
# 로그 파일 정리
sudo find /var/log -type f -name "*.log" -mtime +30 -delete

# 패키지 캐시 정리
sudo yum clean all

# Docker 이미지/컨테이너 정리
docker system prune -af --volumes

# 오래된 커널 제거
sudo package-cleanup --oldkernels --count=1
```

## 트러블슈팅

### 파일 시스템 확장이 안 되는 경우
1. 파티션 테이블 확인: `sudo fdisk -l`
2. 파티션이 전체 디스크를 사용하는지 확인
3. 재부팅 후 다시 시도

### 볼륨 수정이 실패하는 경우
1. 볼륨이 이미 수정 중인지 확인
2. 인스턴스가 실행 중인지 확인
3. IAM 권한 확인

### 디스크 공간이 계속 부족한 경우
1. 대용량 파일 찾기: `find / -type f -size +1G 2>/dev/null`
2. 로그 로테이션 설정 확인
3. 임시 파일 정리: `sudo rm -rf /tmp/*`

이 가이드를 따라 EC2 인스턴스의 저장 공간을 안전하게 확장할 수 있습니다.