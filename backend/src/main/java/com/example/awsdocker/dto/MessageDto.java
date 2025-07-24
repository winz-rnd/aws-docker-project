package com.example.awsdocker.dto;

import com.example.awsdocker.entity.Message;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;

public class MessageDto {
    
    private Long id;
    private String content;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public MessageDto() {}
    
    // 생성자
    public MessageDto(Long id, String content, LocalDateTime createdAt) {
        this.id = id;
        this.content = content;
        this.createdAt = createdAt;
    }
    
    // Entity에서 DTO로 변환하는 정적 메서드
    public static MessageDto from(Message message) {
        return new MessageDto(
            message.getId(),
            message.getContent(),
            message.getCreatedAt()
        );
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    @Override
    public String toString() {
        return "MessageDto{" +
                "id=" + id +
                ", content='" + content + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}