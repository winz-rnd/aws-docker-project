package com.example.awsdocker.repository;

import com.example.awsdocker.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    
    /**
     * 랜덤한 메시지 하나를 조회합니다.
     */
    @Query(value = "SELECT * FROM messages ORDER BY RAND() LIMIT 1", nativeQuery = true)
    Optional<Message> findRandomMessage();
    
    /**
     * 가장 최근에 생성된 메시지를 조회합니다.
     */
    Optional<Message> findTopByOrderByCreatedAtDesc();
    
    /**
     * 특정 내용을 포함하는 메시지를 조회합니다.
     */
    Optional<Message> findByContentContaining(String content);
}