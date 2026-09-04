package org.puppit.service;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.puppit.model.dto.AlarmDuplicationDTO;
import org.puppit.model.dto.ChatListDTO;
import org.puppit.model.dto.ChatMessageDTO;
import org.puppit.model.dto.ChatMessageProductDTO;
import org.puppit.model.dto.ChatMessageSearchDTO;
import org.puppit.model.dto.ChatMessageSelectDTO;
import org.puppit.model.dto.ChatRoomPeopleDTO;
import org.puppit.model.dto.ChatUserDTO;
import org.puppit.model.dto.NotificationDTO;
import org.puppit.model.dto.ChatMessageDTO;
import org.puppit.model.dto.ChatMessageProductDTO;
import org.puppit.model.dto.ChatMessageSelectDTO;
import org.puppit.repository.AlarmDAO;
import org.puppit.repository.ChatDAO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Transactional
@Service
public class ChatServiceImpl implements ChatService{

	private final ChatDAO chatDAO;
	private final AlarmDAO alarmDAO;
	
	@Override
	public List<ChatMessageDTO> getChatMessageList(ChatMessageSelectDTO  chatMessageSelectDTO) {
		List<Map<String, Object>> messageList = chatDAO.getChatMessageList(chatMessageSelectDTO);
		List<ChatMessageDTO> dtoList = messageList.stream().map(message -> {
			ChatMessageDTO dto = new ChatMessageDTO();
			dto.setMessageId(String.valueOf(message.get("message_id")));
			dto.setChatRoomId(String.valueOf(message.get("chat_room_id")) );
			dto.setProductId(String.valueOf(message.get("product_id")));
			dto.setChatSender(Integer.parseInt(String.valueOf(message.get("chat_sender"))));
		    dto.setChatSenderAccountId(String.valueOf(message.get("sender_account_id")));
	        dto.setChatSenderUserName(String.valueOf(message.get("sender_user_name")));
	        dto.setChatReceiver(Integer.parseInt(String.valueOf(message.get("chat_receiver"))));
	        dto.setChatReceiverAccountId(String.valueOf(message.get("receiver_account_id")));
	        dto.setChatReceiverUserName(String.valueOf(message.get("receiver_user_name")));
	        dto.setChatMessage(String.valueOf(message.get("chat_message")));
	        dto.setBuyerId(String.valueOf(message.get("buyer_id")));
	        dto.setChatSellerNickName(String.valueOf(message.get("chat_seller_nick_name")));
	        //dto.setChatSellerNickName();
	        System.out.println("chat_seller_nick_name: " + String.valueOf(message.get("chat_seller_nick_name")));
	        System.out.println("chatSellerNickName: " + dto.getChatSellerNickName());
	        
	        // chat_created_at은 Timestamp로 캐스팅 필요	        
	        Object createdAt = message.get("chat_created_at");
	        if (createdAt instanceof Timestamp) {
	            dto.setChatCreatedAt((Timestamp) createdAt); // ���� ����
	        }
	        dto.setSenderRole(String.valueOf(message.get("sender_role")));
	        dto.setReceiverRole(String.valueOf(message.get("receiver_role")));
			return dto;
		}).collect(Collectors.toList());
		
		return dtoList;
	}

	@Override
	public ChatMessageProductDTO getProduct(Integer productId) {
		return chatDAO.getProduct(productId);
	}

	@Override
	public Integer saveChatMessage(ChatMessageDTO chatMessageDTO) {
		return chatDAO.insertChatMessage(chatMessageDTO);
	}

	@Override
	public List<ChatRoomPeopleDTO> getUserRoleANDAboutChatMessagePeople(ChatMessageSearchDTO chatMessageSearchDTO) {
		return chatDAO.getUserRoleANDAboutChatMessagePeople(chatMessageSearchDTO);
	}

 
	@Override
	public Integer findExistingRoom(int productId, int buyerId, int sellerId) {
	    return chatDAO.selectRoomIdByParticipants(productId, buyerId, sellerId);
	}

	@Override
	public Integer createRoom(int productId, int buyerId, int sellerId) {
	    return chatDAO.insertRoom(productId, buyerId, sellerId);
	}

	@Override
	public List<ChatListDTO> getChatRooms(int userId,  Integer highlightRoomId) {
		 return chatDAO.getChatList(userId, highlightRoomId);
	}

	@Override
	public Map<String, Object> getChatRoomsByCreatedDesc(int userId) {
	    return chatDAO.getChatListByCreatedDesc(userId);
	}

	@Override
	public Integer getProductIdByRoomId(int roomId) {
		 return chatDAO.findProductIdByRoomId(roomId);
	}

	@Override
	public ChatMessageProductDTO getProductWithSellerAccountId(Integer productId) {
		return chatDAO.getProductWithSellerAccountId(productId);
	}

	@Override
	public ChatUserDTO getSellerByProductId(Integer productId) {
		// TODO Auto-generated method stub
		return chatDAO.getSellerByProductId(productId);
	}

	 /**
     * 첫 채팅 여부를 확인하는 메서드
     * @param chatRoomId 채팅방 ID
     * @return 첫 채팅일 경우 true, 아닐 경우 false
     */
	@Override
    public boolean isFirstChat(Integer chatRoomId) {
        Integer chatCount = chatDAO.getChatCountByRoomId(chatRoomId);
        return chatCount == null || chatCount == 0;
    }

	@Override
	public boolean isMessageDuplicate(ChatMessageDTO chatMessageDTO) {
		  // 메시지 중복 여부 확인 로직
	    return chatDAO.isMessageDuplicate(chatMessageDTO);
	}

	@Override
	public Integer saveAlarmData(NotificationDTO messageAlarm) {
		return chatDAO.saveAlarmData(messageAlarm);
	}

	@Override
	public ChatUserDTO getReceiverInfoByUserId(Integer chatReceiverAccountId) {
		
		return chatDAO.getReceiverInfoByUserId(chatReceiverAccountId);
	}

	@Override
	public String getProductNameById(int parseInt) {
		
		return chatDAO.getProductNameById(parseInt);
	}

	@Override
	public List<NotificationDTO> getUnreadAlarms(Integer userId) {
		
		return chatDAO.getUnreadAlarms(userId);
	}
	
    @Override
    public int isAlarmDuplicate(NotificationDTO notification) {
        // 예시: DB에 동일한 messageId, roomId, senderAccountId, receiverAccountId, chatMessage가 있으면 중복
        // 실제 DB 쿼리로 변경 필요 (아래는 Pseudo 코드)
    	AlarmDuplicationDTO alarmDuplicationDTO = new AlarmDuplicationDTO();
    	alarmDuplicationDTO.setChatMessage(notification.getChatMessage());
    	alarmDuplicationDTO.setRoomId(notification.getRoomId());
    	alarmDuplicationDTO.setUserId(notification.getUserId());
    	
    	
        return alarmDAO.countDuplicateAlarm(alarmDuplicationDTO);
        // 또는 아래처럼 여러 필드를 조합하여 체크 가능
        // return alarmMapper.existsAlarm(notification.getMessageId(), notification.getRoomId(), notification.getSenderAccountId(), notification.getReceiverAccountId(), notification.getChatMessage());
    }

	@Override
	public int getTotalChatCount(int roomId, int buyerId, int sellerId) {
		return chatDAO.getTotalChatCount(roomId, buyerId, sellerId);
	}

	@Override
	public int getBuyerToSellerCount(int roomId, int buyerId, int sellerId) {
	    return chatDAO.getBuyerToSellerCount(roomId, buyerId, sellerId);
	}

	@Override
	public void removeRoomCascade(int roomId) throws Exception {
		chatDAO.deleteAlarmsByRoomIdCascade(roomId);
		
		// 1. 자식(alarm) 먼저 삭제
		chatDAO.deleteAlarmsByRoomId(roomId);
	    // 2. 자식(chat) 먼저 삭제
	    chatDAO.deleteChatsByRoomId(roomId);
	    // 3. 부모(room) 삭제
	    chatDAO.deleteRoom(roomId);
	}

}