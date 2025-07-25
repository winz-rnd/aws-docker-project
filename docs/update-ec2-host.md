# EC2 HOST 업데이트 가이드

## GitHub Secrets에서 EC2_HOST 업데이트하기

1. GitHub 리포지토리로 이동
2. Settings → Secrets and variables → Actions 클릭
3. EC2_HOST 찾아서 Edit 클릭
4. 새로운 값 입력: `13.209.88.100`
5. Update secret 클릭

## 확인사항
- EC2_HOST: 13.209.88.100
- EC2_USER: ubuntu (변경 없음)
- EC2_SSH_KEY: 기존 키 사용 (변경 없음)

## 업데이트 후 테스트
GitHub Actions가 새로운 IP로 정상적으로 배포되는지 확인