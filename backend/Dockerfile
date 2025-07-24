# 멀티 스테이지 빌드를 사용하여 이미지 크기 최적화

# 1단계: 빌드 스테이지
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app

# Gradle Wrapper 복사
COPY gradlew .
COPY gradle gradle

# build.gradle과 settings.gradle 복사
COPY build.gradle .
COPY settings.gradle .

# Gradle Wrapper 실행 권한 부여
RUN chmod +x gradlew

# 의존성 다운로드 (캐시 최적화)
RUN ./gradlew dependencies --no-daemon

# 소스 코드 복사
COPY src src

# 애플리케이션 빌드
RUN ./gradlew bootJar --no-daemon

# 2단계: 런타임 스테이지
FROM eclipse-temurin:17-jre-alpine

# Alpine Linux용 패키지 설치 및 사용자 생성
RUN apk add --no-cache curl && \
    addgroup -g 1000 appuser && \
    adduser -D -s /bin/sh -u 1000 -G appuser appuser

WORKDIR /app

# 빌드 스테이지에서 jar 파일 복사
COPY --from=builder /app/build/libs/app.jar app.jar

# 파일 소유권 변경
RUN chown -R appuser:appuser /app

# non-root 사용자로 전환
USER appuser

# 헬스체크 설정
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/api/health || exit 1

# 포트 노출
EXPOSE 8080

# JVM 옵션 설정
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 애플리케이션 실행
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]