# Flutter Web Build Stage
FROM debian:bullseye-slim AS build

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter using stable release
ENV FLUTTER_VERSION="3.16.0"
RUN curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -o flutter.tar.xz \
    && tar xf flutter.tar.xz -C /opt \
    && rm flutter.tar.xz

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Git 안전 디렉토리 설정
RUN git config --global --add safe.directory /opt/flutter

# Flutter 초기화 및 웹 활성화
RUN flutter --version && \
    flutter doctor -v && \
    flutter config --enable-web && \
    flutter precache --web

# Copy source code
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .

# Build Flutter web
RUN flutter build web --release --web-renderer html

# Production Stage
FROM nginx:alpine

# Copy built files from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 3000

# Start nginx
CMD ["nginx", "-g", "daemon off;"]