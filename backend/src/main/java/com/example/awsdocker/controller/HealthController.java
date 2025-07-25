package com.example.awsdocker.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.sql.DataSource;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
@CrossOrigin(origins = "*")
public class HealthController {
    
    @Autowired
    private DataSource dataSource;
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> health = new HashMap<>();
        
        // 전체 상태
        String status = "UP";
        
        // API 서버 상태
        health.put("status", status);
        health.put("api", "UP");
        
        // 데이터베이스 연결 상태 확인
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(2)) { // 2초 타임아웃
                health.put("database", "UP");
                health.put("dbType", connection.getMetaData().getDatabaseProductName());
                health.put("dbVersion", connection.getMetaData().getDatabaseProductVersion());
            } else {
                health.put("database", "DOWN");
                status = "DOWN";
            }
        } catch (Exception e) {
            health.put("database", "DOWN");
            health.put("dbError", e.getMessage());
            status = "DOWN";
        }
        
        // 시스템 정보
        health.put("javaVersion", System.getProperty("java.version"));
        health.put("uptime", java.lang.management.ManagementFactory.getRuntimeMXBean().getUptime());
        
        // 최종 상태 업데이트
        health.put("status", status);
        
        return ResponseEntity.ok(health);
    }
}