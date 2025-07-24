-- 초기 데이터 삽입 (H2 데이터베이스용)
-- 이 파일은 애플리케이션 시작 시 자동으로 실행됩니다

INSERT INTO messages (content, created_at, updated_at) VALUES 
('안녕하세요! 이것은 데이터베이스에서 가져온 첫 번째 메시지입니다.', NOW(), NOW()),
('Flutter와 Spring Boot가 잘 연동되고 있습니다!', NOW(), NOW()),
('AWS에서 실행 중인 애플리케이션입니다.', NOW(), NOW()),
('Docker 컨테이너에서 실행되는 Spring Boot API입니다.', NOW(), NOW()),
('GitHub Actions를 통해 자동 배포되었습니다.', NOW(), NOW()),
('RDS MySQL 데이터베이스와 연결되어 있습니다.', NOW(), NOW()),
('App Runner에서 안정적으로 실행 중입니다.', NOW(), NOW()),
('CloudFront CDN을 통해 빠른 응답을 제공합니다.', NOW(), NOW()),
('마이크로서비스 아키텍처의 백엔드 API입니다.', NOW(), NOW()),
('풀스택 웹 애플리케이션의 핵심 기능을 담당합니다.', NOW(), NOW());