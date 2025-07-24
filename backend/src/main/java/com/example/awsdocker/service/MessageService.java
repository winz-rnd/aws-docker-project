package com.example.awsdocker.service;

import com.example.awsdocker.dto.MessageDto;
import com.example.awsdocker.entity.Message;
import com.example.awsdocker.repository.MessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class MessageService {
    
    private final MessageRepository messageRepository;
    
    @Autowired
    public MessageService(MessageRepository messageRepository) {
        this.messageRepository = messageRepository;
    }
    
    /**
     * 모든 메시지를 조회합니다.
     */
    public List<MessageDto> getAllMessages() {
        return messageRepository.findAll()
                .stream()
                .map(MessageDto::from)
                .collect(Collectors.toList());
    }
    
    /**
     * 랜덤한 메시지 하나를 조회합니다.
     */
    public Optional<MessageDto> getRandomMessage() {
        return messageRepository.findRandomMessage()
                .map(MessageDto::from);
    }
    
    /**
     * 가장 최근 메시지를 조회합니다.
     */
    public Optional<MessageDto> getLatestMessage() {
        return messageRepository.findTopByOrderByCreatedAtDesc()
                .map(MessageDto::from);
    }
    
    /**
     * ID로 메시지를 조회합니다.
     */
    public Optional<MessageDto> getMessageById(Long id) {
        return messageRepository.findById(id)
                .map(MessageDto::from);
    }
    
    /**
     * 새로운 메시지를 생성합니다.
     */
    @Transactional
    public MessageDto createMessage(String content) {
        Message message = new Message(content);
        Message savedMessage = messageRepository.save(message);
        return MessageDto.from(savedMessage);
    }
    
    /**
     * 메시지를 업데이트합니다.
     */
    @Transactional
    public Optional<MessageDto> updateMessage(Long id, String content) {
        return messageRepository.findById(id)
                .map(message -> {
                    message.setContent(content);
                    return MessageDto.from(messageRepository.save(message));
                });
    }
    
    /**
     * 메시지를 삭제합니다.
     */
    @Transactional
    public boolean deleteMessage(Long id) {
        if (messageRepository.existsById(id)) {
            messageRepository.deleteById(id);
            return true;
        }
        return false;
    }
}