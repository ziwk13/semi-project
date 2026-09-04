package org.puppit.controller;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.puppit.model.dto.ChatMessageDTO;
import org.puppit.model.dto.ChatMessageProductDTO;
import org.puppit.model.dto.ChatMessageSearchDTO;
import org.puppit.model.dto.ChatRoomPeopleDTO;
import org.puppit.model.dto.ChatUserDTO;
import org.puppit.model.dto.NotificationDTO;
import org.puppit.model.dto.UserDTO;
import org.puppit.repository.UserDAO;
import org.puppit.service.ChatService;
import org.puppit.service.UserService;

import org.springframework.stereotype.Controller;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class ChatWebSocketController {

	private final SimpMessagingTemplate messagingTemplate;
	private final UserService userService;
	private final ChatService chatService;
	private final UserDAO userDAO;

	// 클라이언트가 /app/chat.send로 메시지 전송
	@MessageMapping("/chat.send")
	public void sendMessage(@Payload ChatMessageDTO chatMessageDTO, SimpMessageHeaderAccessor headerAccessor) {
	    System.out.println("프론트에서 받은 chatMessageDTO: " + chatMessageDTO.toString());

	    ChatUserDTO receiver = null;
	    Integer productId = 0;

	    // Sender 정보 조회
	    System.out.println("chatMessageDTO.getChatSenderAccountId(): " + chatMessageDTO.getChatSenderAccountId());
	    UserDTO sender = userDAO.getUserByNickName(chatMessageDTO.getChatSenderAccountId());
	    if (sender == null) {
	        System.out.println("Sender 정보를 찾을 수 없습니다. 메시지 처리 중단.");
	        return;
	    }

	    System.out.println("sender: " + sender.toString());

	    // receiver 정보 조회
	    ChatUserDTO chatReceiver = chatService.getReceiverInfoByUserId(chatMessageDTO.getChatReceiver());
	    if (chatReceiver == null) {
	        System.out.println("chatReceiver 정보를 찾을 수 없습니다. 메시지 처리 중단.");
	        return;
	    }

	    System.out.println("chatReceiver: " + chatReceiver.toString());
	    
	    
	    
	    // ChatRoomId 확인 및 파싱
	    Integer chatRoomId = null;
	    try {
	        chatRoomId = chatMessageDTO.getChatRoomId() != null ? Integer.parseInt(chatMessageDTO.getChatRoomId()) : null;
	        System.out.println("chatRoomId: " + chatRoomId);
	    } catch (NumberFormatException e) {
	        System.out.println("chatRoomId가 유효하지 않습니다: " + chatMessageDTO.getChatRoomId());
	        return;
	    }

	    System.out.println("isFirstChat: " + chatService.isFirstChat(chatRoomId));

	    // createdAt
	    String createdAtStr = chatMessageDTO.getChatCreatedAt().toString();
	    Timestamp createdAtTimestamp;
	    
	    try {
	    	// ISO 문자열일 때
	    	if (createdAtStr.contains("T")) {
	    		createdAtStr = createdAtStr.replace("T", " ");
	    	}
	    	createdAtTimestamp = Timestamp.valueOf(createdAtStr);
	    	chatMessageDTO.setChatCreatedAt(createdAtTimestamp);
	    } catch (Exception e) {
	    	// 값이 업거나 잘못된 경우 현재 시각으로 대체
	    	chatMessageDTO.setChatCreatedAt(new Timestamp(System.currentTimeMillis()));
	    }
	    System.out.println("createdAt: " + chatMessageDTO.getChatCreatedAt());
	    
	    
	    
	    
	    
	    // 메시지 중복 확인
	    chatMessageDTO.setChatSender(sender.getUserId());
	    if (chatService.isMessageDuplicate(chatMessageDTO)) {
	        System.out.println("중복 메시지입니다. 저장하지 않습니다.");
	        return;
	    }

	    if (chatService.isFirstChat(chatRoomId)) {
	        // 첫 채팅인 경우 Receiver 및 Product 정보 설정
	        productId = chatService.getProductIdByRoomId(chatRoomId);
	        System.out.println("productId: " + productId);
	        receiver = chatService.getSellerByProductId(productId);

	        if (receiver == null || sender.getUserId().equals(receiver.getUserId())) {
	            System.out.println("Receiver 정보를 찾을 수 없거나 Sender와 동일합니다. 메시지 처리 중단.");
	            return;
	        }

	        chatMessageDTO.setChatSender(sender.getUserId());
	        chatMessageDTO.setChatSenderAccountId(sender.getNickName());
	        chatMessageDTO.setChatSenderUserName(sender.getUserName());
	        chatMessageDTO.setSenderRole("BUYER");

	        chatMessageDTO.setChatReceiver(receiver.getUserId());
	        chatMessageDTO.setChatReceiverAccountId(receiver.getNickName());
	        chatMessageDTO.setChatReceiverUserName(receiver.getUserName());
	        chatMessageDTO.setReceiverRole("SELLER");
	        chatMessageDTO.setProductId(productId.toString());
	    } else {
	        // 기존 채팅인 경우
	        ChatMessageSearchDTO messageSearchDTO = new ChatMessageSearchDTO(sender.getUserId(), chatRoomId);
	        List<ChatRoomPeopleDTO> chatRoomPeoples = chatService.getUserRoleANDAboutChatMessagePeople(messageSearchDTO);

	        if (chatRoomPeoples == null || chatRoomPeoples.isEmpty()) {
	            System.out.println("chatRoomPeoples가 비어 있습니다.");
	            return;
	        }

	        ChatRoomPeopleDTO latest = chatRoomPeoples.get(chatRoomPeoples.size() - 1);

	        if (!chatMessageDTO.getChatSenderAccountId().equals(chatMessageDTO.getChatReceiverAccountId())) {
	            chatMessageDTO.setChatSender(sender.getUserId());
	            chatMessageDTO.setChatSenderAccountId(sender.getNickName());
	            chatMessageDTO.setChatSenderUserName(sender.getUserName());
	            chatMessageDTO.setSenderRole(latest.getSenderRole());
	            chatMessageDTO.setReceiverRole(chatMessageDTO.getReceiverRole());
	            chatMessageDTO.setChatReceiver(chatMessageDTO.getChatReceiver());
	            chatMessageDTO.setChatReceiverAccountId(chatReceiver.getNickName());
	            chatMessageDTO.setChatReceiverUserName(chatReceiver.getUserName());
	            chatMessageDTO.setReceiverRole(chatMessageDTO.getReceiverRole());
	            chatMessageDTO.setProductId(productId.toString());
	        }
	    }

	    System.out.println("저장 전 chatMessageDTO: " + chatMessageDTO.toString());

	    // 메시지 ID를 서버에서 UUID로 생성
	    chatMessageDTO.setMessageId(UUID.randomUUID().toString());

	    // 데이터 검증
	    if (chatMessageDTO.getChatSenderAccountId().equals(chatMessageDTO.getChatReceiverAccountId())) {
	        System.out.println("Sender와 Receiver가 동일합니다. 데이터 검증 실패.");
	        return;
	    }

	    // 메시지 저장
	    try {
	        Integer insertedRow = chatService.saveChatMessage(chatMessageDTO);
	        System.out.println("insertedRow: " + insertedRow);
	    } catch (Exception e) {
	        System.out.println("채팅 메시지 저장 중 오류 발생: " + e.getMessage());
	        e.printStackTrace();
	    }

//	    String destination = "/topic/chat/" + chatMessageDTO.getChatRoomId();
//	    messagingTemplate.convertAndSend(destination, chatMessageDTO);
	    
	    String roomDestination = "/topic/chat/" + chatMessageDTO.getChatRoomId();
	    messagingTemplate.convertAndSend(roomDestination, chatMessageDTO);
	    
	    // 추가: 전체 chat 메시지 브로드캐스트 (채팅방 목록용)
	    String globalChatDestination = "/topic/chat";
	    messagingTemplate.convertAndSend(globalChatDestination, chatMessageDTO);
	    
	    productId = chatService.getProductIdByRoomId(chatRoomId);
	    
	    System.out.println("productId: " + productId);
	    System.out.println("productName: " + chatService.getProductNameById(productId));
	    
	    System.out.println("messageId: "+ chatMessageDTO.getMessageId());
	    
	    // 알림 메시지 생성
	    NotificationDTO notification = new NotificationDTO();
	    notification.setRoomId(chatRoomId);
	    notification.setUserId(sender.getUserId());
        notification.setSenderAccountId(sender.getNickName());
        notification.setReceiverAccountId(chatMessageDTO.getChatReceiverAccountId());
        notification.setChatMessage(chatMessageDTO.getChatMessage());
        notification.setSenderRole(chatMessageDTO.getSenderRole());
        notification.setReceiverRole(chatMessageDTO.getReceiverRole());
        notification.setChatCreatedAt(chatMessageDTO.getChatCreatedAt());
        notification.setProductName(chatService.getProductNameById(productId));
        notification.setMessageId(Integer.parseInt(chatMessageDTO.getMessageId())); // 메시지 고유 ID 사용
        notification.setIsRead(1);
        notification.setChatSender(chatMessageDTO.getChatSender());
        notification.setChatReceiver(chatMessageDTO.getChatReceiver());

        Integer alarmInsertRowId = chatService.saveAlarmData(notification);
        System.out.println("메시지 알림 저장 성공: " + alarmInsertRowId);
        System.out.println("메시지 알림 내용: " + notification.toString());
        
        // 알림을 브로드캐스트
        messagingTemplate.convertAndSend("/topic/notification", notification);
        System.out.println("Broadcasting notification: " + notification);
	    
	    
	    
	}
	
	
	
}