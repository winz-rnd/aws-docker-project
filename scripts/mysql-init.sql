-- AWS Docker 프로젝트 MySQL 데이터베이스 초기화 스크립트
-- 이 스크립트는 Docker 컨테이너 시작 시 자동으로 실행됩니다

-- 데이터베이스 생성 (이미 존재하면 무시)
CREATE DATABASE IF NOT EXISTS aws_docker_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 데이터베이스 사용
USE aws_docker_db;

-- 메시지 테이블 생성
CREATE TABLE IF NOT EXISTS messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at),
    INDEX idx_updated_at (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 초기 메시지 데이터 삽입
INSERT INTO messages (content) VALUES 
('Hello! This is the first message from the database.'),
('Flutter and Spring Boot are working well together!'),
('This application is running on AWS.'),
('Spring Boot API running in Docker container.'),
('Deployed automatically through GitHub Actions.'),
('Connected to RDS MySQL database.'),
('Running reliably on App Runner.'),
('Providing fast responses through CloudFront CDN.'),
('Backend API with microservices architecture.'),
('Handling core features of full-stack web application.'),
('Providing stable data storage using MySQL 8.0.'),
('Supporting JWT token-based authentication.'),
('Following RESTful API design principles.'),
('Providing real-time health check functionality.'),
('Supporting containerized deployment through Docker.'),
('Providing Kubernetes-compatible configuration.'),
('Architecture verified in production environment.'),
('Scalable cloud-native design.'),
('Integrated monitoring and logging.'),
('Applied security best practices.')
ON DUPLICATE KEY UPDATE content = VALUES(content);

-- 사용자 테이블 생성 (향후 확장용)
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 관리자 사용자 생성 (기본 비밀번호: admin123)
INSERT INTO users (username, email, password_hash, full_name) VALUES 
('admin', 'admin@example.com', '$2a$10$example.hash.here', 'Administrator')
ON DUPLICATE KEY UPDATE username = VALUES(username);

-- 메시지 카테고리 테이블 (향후 확장용)
CREATE TABLE IF NOT EXISTS message_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#007bff',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 기본 카테고리 생성
INSERT INTO message_categories (name, description, color) VALUES 
('General', 'General messages', '#007bff'),
('Notice', 'Important announcements', '#dc3545'),
('Guide', 'User guide messages', '#28a745'),
('System', 'System related messages', '#6c757d')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- 메시지에 카테고리 컬럼 추가 (향후 확장용)
-- 컬럼이 존재하지 않을 때만 추가
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA = 'aws_docker_db' 
                   AND TABLE_NAME = 'messages' 
                   AND COLUMN_NAME = 'category_id');

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE messages ADD COLUMN category_id BIGINT DEFAULT 1, ADD FOREIGN KEY (category_id) REFERENCES message_categories(id) ON DELETE SET NULL', 
    'SELECT "Column category_id already exists" AS message');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 통계 테이블 (API 호출 통계용)
CREATE TABLE IF NOT EXISTS api_statistics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    endpoint VARCHAR(255) NOT NULL,
    method VARCHAR(10) NOT NULL,
    status_code INT NOT NULL,
    response_time_ms INT,
    user_agent TEXT,
    ip_address VARCHAR(45),
    called_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_endpoint (endpoint),
    INDEX idx_called_at (called_at),
    INDEX idx_status_code (status_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 설정 테이블 (애플리케이션 설정용)
CREATE TABLE IF NOT EXISTS app_settings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(255) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_setting_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 기본 설정값 삽입
INSERT INTO app_settings (setting_key, setting_value, description) VALUES 
('app_name', 'AWS Docker Backend', 'Application name'),
('app_version', '1.0.0', 'Application version'),
('max_messages_per_request', '10', 'Maximum messages per API request'),
('cache_ttl_minutes', '5', 'Cache TTL in minutes'),
('maintenance_mode', 'false', 'Maintenance mode enabled')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);

-- 인덱스 최적화를 위한 추가 인덱스 (이미 존재하면 무시)
-- CREATE INDEX idx_messages_content_fulltext ON messages(content(100));

-- 데이터베이스 정보 출력
SELECT 
    'Database initialization completed successfully!' AS status,
    COUNT(*) AS total_messages,
    (SELECT COUNT(*) FROM message_categories) AS total_categories,
    (SELECT COUNT(*) FROM app_settings) AS total_settings
FROM messages;

-- 권한 설정 (Docker 환경용)
GRANT ALL PRIVILEGES ON aws_docker_db.* TO 'appuser'@'%';
FLUSH PRIVILEGES;