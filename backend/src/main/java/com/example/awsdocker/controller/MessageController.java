package com.example.awsdocker.controller;

import com.example.awsdocker.dto.MessageDto;
import com.example.awsdocker.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*") // 개발 환경용, 프로덕션에서는 구체적인 도메인 지정
public class MessageController {
    
    private final MessageService messageService;
    
    @Autowired
    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }
    
    /**
     * 헬스체크 엔드포인트
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of(
            "status", "UP",
            "service", "AWS Docker Backend",
            "timestamp", java.time.LocalDateTime.now().toString()
        ));
    }
    
    /**
     * 랜덤 메시지 조회 (Flutter에서 주로 사용할 엔드포인트)
     */
    @GetMapping("/message")
    public ResponseEntity<MessageDto> getMessage() {
        return messageService.getRandomMessage()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * 모든 메시지 조회
     */
    @GetMapping("/messages")
    public ResponseEntity<List<MessageDto>> getAllMessages() {
        List<MessageDto> messages = messageService.getAllMessages();
        return ResponseEntity.ok(messages);
    }
    
    /**
     * 특정 ID의 메시지 조회
     */
    @GetMapping("/messages/{id}")
    public ResponseEntity<MessageDto> getMessageById(@PathVariable Long id) {
        return messageService.getMessageById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * 가장 최근 메시지 조회
     */
    @GetMapping("/message/latest")
    public ResponseEntity<MessageDto> getLatestMessage() {
        return messageService.getLatestMessage()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * 새 메시지 생성
     */
    @PostMapping("/messages")
    public ResponseEntity<MessageDto> createMessage(@RequestBody Map<String, String> request) {
        String content = request.get("content");
        if (content == null || content.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        
        MessageDto createdMessage = messageService.createMessage(content.trim());
        return ResponseEntity.ok(createdMessage);
    }
    
    /**
     * 새 메시지 생성 (간편 엔드포인트)
     */
    @PostMapping("/message")
    public ResponseEntity<MessageDto> createMessageSimple(@RequestBody Map<String, String> request) {
        return createMessage(request);
    }
    
    /**
     * 메시지 업데이트
     */
    @PutMapping("/messages/{id}")
    public ResponseEntity<MessageDto> updateMessage(
            @PathVariable Long id, 
            @RequestBody Map<String, String> request) {
        String content = request.get("content");
        if (content == null || content.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        
        return messageService.updateMessage(id, content.trim())
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * 메시지 삭제
     */
    @DeleteMapping("/messages/{id}")
    public ResponseEntity<Void> deleteMessage(@PathVariable Long id) {
        boolean deleted = messageService.deleteMessage(id);
        return deleted ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }
}