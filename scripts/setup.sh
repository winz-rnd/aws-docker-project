#!/bin/bash

# AWS Docker 프로젝트 설정 스크립트
# 이 스크립트는 로컬 개발 환경을 자동으로 설정합니다

set -e  # 에러 발생시 스크립트 중단

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수들
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 프로젝트 루트 디렉토리로 이동
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

log_info "AWS Docker 프로젝트 설정을 시작합니다..."
log_info "프로젝트 경로: $PROJECT_ROOT"

# 사전 요구사항 확인
check_requirements() {
    log_info "사전 요구사항을 확인합니다..."
    
    # Docker 확인
    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되어 있지 않습니다. Docker를 먼저 설치해주세요."
        exit 1
    fi
    log_success "Docker가 설치되어 있습니다."
    
    # Docker Compose 확인
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose가 설치되어 있지 않습니다. Docker Compose를 먼저 설치해주세요."
        exit 1
    fi
    log_success "Docker Compose가 설치되어 있습니다."
    
    # Java 확인 (선택사항)
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d '"' -f 2)
        log_success "Java가 설치되어 있습니다: $JAVA_VERSION"
    else
        log_warning "Java가 설치되어 있지 않습니다. 로컬에서 백엔드를 실행하려면 Java 17이 필요합니다."
    fi
    
    # Flutter 확인 (선택사항)
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        log_success "Flutter가 설치되어 있습니다: $FLUTTER_VERSION"
    else
        log_warning "Flutter가 설치되어 있지 않습니다. 로컬에서 프론트엔드를 실행하려면 Flutter가 필요합니다."
    fi
}

# 환경 설정 파일 생성
setup_env_files() {
    log_info "환경 설정 파일을 생성합니다..."
    
    # 루트 .env 파일
    if [ ! -f ".env" ]; then
        cp .env.example .env
        log_success ".env 파일이 생성되었습니다."
        log_warning "필요에 따라 .env 파일의 값들을 수정해주세요."
    else
        log_info ".env 파일이 이미 존재합니다."
    fi
    
    # 백엔드 .env 파일
    if [ ! -f "backend/.env" ]; then
        cat > backend/.env << EOF
SPRING_PROFILES_ACTIVE=dev
DATABASE_URL=jdbc:mysql://localhost:3306/aws_docker_db?useSSL=false&serverTimezone=Asia/Seoul
DATABASE_USERNAME=appuser
DATABASE_PASSWORD=apppassword
JPA_DDL_AUTO=update
JPA_SHOW_SQL=true
LOG_LEVEL=DEBUG
EOF
        log_success "backend/.env 파일이 생성되었습니다."
    else
        log_info "backend/.env 파일이 이미 존재합니다."
    fi
    
    # 프론트엔드 .env 파일 확인
    if [ ! -f "frontend/.env" ]; then
        log_info "frontend/.env 파일이 이미 생성되어 있습니다."
    fi
}

# 디렉토리 생성
create_directories() {
    log_info "필요한 디렉토리를 생성합니다..."
    
    mkdir -p logs
    mkdir -p data/mysql
    mkdir -p data/redis
    mkdir -p frontend/build/web
    
    log_success "디렉토리가 생성되었습니다."
}

# 백엔드 의존성 설치
setup_backend() {
    log_info "백엔드 의존성을 확인합니다..."
    
    if [ -f "backend/gradlew" ]; then
        cd backend
        chmod +x gradlew
        
        if command -v java &> /dev/null; then
            log_info "Gradle 의존성을 다운로드합니다..."
            ./gradlew dependencies --quiet
            log_success "백엔드 의존성 설정이 완료되었습니다."
        else
            log_warning "Java가 설치되어 있지 않아 Gradle 의존성을 건너뜁니다."
        fi
        
        cd ..
    else
        log_error "backend/gradlew 파일을 찾을 수 없습니다."
    fi
}

# 프론트엔드 의존성 설치
setup_frontend() {
    log_info "프론트엔드 의존성을 확인합니다..."
    
    if [ -f "frontend/pubspec.yaml" ]; then
        cd frontend
        
        if command -v flutter &> /dev/null; then
            log_info "Flutter 의존성을 다운로드합니다..."
            flutter pub get
            log_success "프론트엔드 의존성 설정이 완료되었습니다."
        else
            log_warning "Flutter가 설치되어 있지 않아 의존성 설치를 건너뜁니다."
        fi
        
        cd ..
    else
        log_error "frontend/pubspec.yaml 파일을 찾을 수 없습니다."
    fi
}

# Docker 이미지 빌드 및 컨테이너 실행
setup_docker() {
    log_info "Docker 환경을 설정합니다..."
    
    # Docker 이미지 빌드
    log_info "Docker 이미지를 빌드합니다..."
    docker-compose build --no-cache
    
    # Docker 컨테이너 실행
    log_info "Docker 컨테이너를 시작합니다..."
    docker-compose up -d mysql
    
    # MySQL 컨테이너가 시작될 때까지 대기
    log_info "MySQL 데이터베이스가 준비될 때까지 대기합니다..."
    sleep 30
    
    # 백엔드 컨테이너 실행
    docker-compose up -d backend
    
    log_success "Docker 환경 설정이 완료되었습니다."
}

# 헬스체크 수행
health_check() {
    log_info "서비스 상태를 확인합니다..."
    
    # MySQL 헬스체크
    if docker-compose exec -T mysql mysqladmin ping -h localhost --silent; then
        log_success "MySQL 데이터베이스가 정상적으로 실행 중입니다."
    else
        log_warning "MySQL 데이터베이스 연결에 실패했습니다."
    fi
    
    # 백엔드 API 헬스체크
    for i in {1..30}; do
        if curl -f -s http://localhost:8080/api/health > /dev/null 2>&1; then
            log_success "백엔드 API가 정상적으로 실행 중입니다."
            break
        else
            if [ $i -eq 30 ]; then
                log_warning "백엔드 API 헬스체크에 실패했습니다."
            else
                log_info "백엔드 API 시작을 대기 중입니다... ($i/30)"
                sleep 10
            fi
        fi
    done
}

# 사용법 안내
show_usage() {
    log_success "설정이 완료되었습니다!"
    echo ""
    echo "📋 사용 가능한 명령어:"
    echo ""
    echo "  🐳 Docker 명령어:"
    echo "    docker-compose up -d              # 모든 서비스 시작"
    echo "    docker-compose down               # 모든 서비스 중지"
    echo "    docker-compose logs -f            # 로그 확인"
    echo "    docker-compose ps                 # 컨테이너 상태 확인"
    echo ""
    echo "  🔧 개발 명령어:"
    echo "    cd backend && ./gradlew bootRun   # 백엔드 로컬 실행"
    echo "    cd frontend && flutter run -d web # 프론트엔드 로컬 실행"
    echo ""
    echo "  🌐 접속 URL:"
    echo "    프론트엔드:     http://localhost:3000"
    echo "    백엔드 API:     http://localhost:8080"
    echo "    백엔드 헬스체크: http://localhost:8080/api/health"
    echo "    phpMyAdmin:     http://localhost:8081"
    echo ""
    echo "  📊 모니터링:"
    echo "    docker-compose logs backend       # 백엔드 로그"
    echo "    docker-compose logs mysql         # MySQL 로그"
    echo "    docker-compose exec mysql mysql -u root -p  # MySQL 콘솔"
    echo ""
}

# 메인 실행 함수
main() {
    check_requirements
    setup_env_files
    create_directories
    setup_backend
    setup_frontend
    setup_docker
    health_check
    show_usage
}

# 스크립트 실행
main "$@"