package org.puppit.repository;


import java.math.BigInteger;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.puppit.model.dto.ChaListProfileImageDTO;
import org.puppit.model.dto.ChatListDTO;

import org.puppit.model.dto.ChatMessageDTO;
import org.puppit.model.dto.ChatMessageProductDTO;
import org.puppit.model.dto.ChatMessageSearchDTO;
import org.puppit.model.dto.ChatMessageSelectDTO;
import org.puppit.model.dto.ChatRoomPeopleDTO;
import org.puppit.model.dto.ChatUserDTO;
import org.puppit.model.dto.NotificationDTO;
import org.puppit.model.dto.UserDTO;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Transactional
@Repository
public class ChatDAO {
	
	private final SqlSessionTemplate sqlSession;
	private final UserDAO userDAO;
    
	public List<ChatListDTO> getChatList(int userId,  Integer highlightRoomId) {
		Map<String, Object> param = new HashMap<>();
		param.put("userId", userId);
		param.put("highlightRoomId", highlightRoomId);
	    return sqlSession.selectList("mybatis.mapper.chatMapper.getChatList", param);
	}
	
	public List<Map<String, Object>> getChatMessageList(ChatMessageSelectDTO chatMessageSelectDTO) {
		return sqlSession.selectList("mybatis.mapper.chatMessageMapper.getChatMessageList", chatMessageSelectDTO);
	}
	
	public ChatMessageProductDTO getProduct(Integer productId) {
		return sqlSession.selectOne("mybatis.mapper.chatMessageMapper.getProduct", productId);
	}
	
	 public Integer insertChatMessage(ChatMessageDTO chatMessageDTO) {
	    	return sqlSession.insert("mybatis.mapper.chatMessageMapper.insertChatMessage", chatMessageDTO);
	    }
	

	 public List<ChatRoomPeopleDTO> getUserRoleANDAboutChatMessagePeople(ChatMessageSearchDTO chatMessageSearchDTO) {
		 return sqlSession.selectList("mybatis.mapper.chatMessageMapper.getUserRoleANDAboutChatMessagePeople", chatMessageSearchDTO);
	 }
	 

     public Integer selectRoomIdByParticipants(int productId, int buyerId, int sellerId) {
        Map<String, Object> param = new HashMap<>();
        param.put("productId", productId);
        param.put("buyerId", buyerId);
        param.put("sellerId", sellerId);
        return sqlSession.selectOne("mybatis.mapper.chatMessageMapper.selectRoomIdByParticipants", param);
     }

     public Integer insertRoom(int productId, int buyerId, int sellerId) {
	    Map<String, Object> param = new HashMap<>();
	    param.put("productId", productId);
	    param.put("buyerId", buyerId);
	    param.put("sellerId", sellerId);
	    sqlSession.insert("mybatis.mapper.chatMessageMapper.insertRoom", param);
	    Object roomIdObj = param.get("room_id");
	    if (roomIdObj == null) return null;
	    if (roomIdObj instanceof Integer) {
	        return (Integer) roomIdObj;
	    } else if (roomIdObj instanceof BigInteger) {
	        return ((BigInteger) roomIdObj).intValue();
	    } else if (roomIdObj instanceof Long) {
	        return ((Long) roomIdObj).intValue();
	    } else {
	        return Integer.parseInt(roomIdObj.toString());
	    }
	}

  // 추가: 생성일 기준 내림차순 목록
   public Map<String, Object> getChatListByCreatedDesc(int userId) {
         Map<String, Object> paramMap = new HashMap<>();
         paramMap.put("userId", userId);
         
         Map<String, Object> resultMap = new HashMap<>();
         
         List<ChaListProfileImageDTO> chatProfileImages = selectChatRoomListWithProfile(paramMap);
         resultMap.put("profileImage", chatProfileImages);
         List<ChatListDTO> chatList = sqlSession.selectList("mybatis.mapper.chatMessageMapper.getChatRoomsByCreatedDesc", paramMap);

         // Mapper/Service에서 변환
         for (int i = 0; i < chatList.size(); i++) {
        	 Timestamp t = chatList.get(i).getLastMessageAt();
        	 String formatted = formatTimestamp(t); // "2025-08-28 09:34:10" 
        	 chatList.get(i).setChatLastMessageAt(formatted);
         }
         
               
         resultMap.put("chats", chatList);
         return resultMap;
   } 
   
   
   public String formatTimestamp(Timestamp ts) {
	    if (ts == null) return "";
	    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	    return sdf.format(ts);
	}

   
   
   public List<ChaListProfileImageDTO> selectChatRoomListWithProfile(Map<String, Object> map) {
	   System.out.println("userId: " + map.get("userId"));
	   UserDTO user = userDAO.getUserByUserId((Integer) map.get("userId"));
	   System.out.println("accountId: " + user.getAccountId());
	   map.put("accountId", user.getAccountId());
	   return sqlSession.selectList("mybatis.mapper.chatMapper.getChatMyProfileImage", map);
   }
   
   

   /**
    * roomId를 사용하여 productId를 가져오는 메서드
    * @param roomId 채팅방 ID
    * @return 해당 채팅방의 상품 ID
    */
   public Integer findProductIdByRoomId(int roomId) {
       return sqlSession.selectOne("mybatis.mapper.chatMessageMapper.findProductIdByRoomId", roomId);
   }

public ChatMessageProductDTO getProductWithSellerAccountId(Integer productId) {
	return sqlSession.selectOne("mybatis.mapper.chatMessageMapper.getProductWithSellerAccountId", productId);
}

public ChatUserDTO getSellerByProductId(Integer productId) {
    return sqlSession.selectOne("mybatis.mapper.chatMessageMapper.getSellerAccountIdByProductId", productId);
}

public boolean isFirstChat(Integer roomId, Integer senderId, Integer receiverId) {
	Map<String, Object> params = new HashMap<>();
    params.put("roomId", roomId);
    params.put("senderId", senderId);
    params.put("receiverId", receiverId);
	return  sqlSession.selectOne("mybatis.mapper.chatMessageMapper.getChatParticipants", params);
}


/**
 * 특정 채팅방에서 기존 채팅 메시지의 개수를 조회하는 메서드
 * @param roomId 채팅방 ID
 * @return 채팅 메시지 개수
 */
public Integer getChatCountByRoomId(Integer roomId) {
    return sqlSession.selectOne("mybatis.mapper.chatMessageMapper.getChatCountByRoomId", roomId);
}

public boolean isMessageDuplicate(ChatMessageDTO chatMessageDTO) {
	 Map<String, Object> params = new HashMap<>();
	    params.put("chatRoomId", chatMessageDTO.getChatRoomId());
	    params.put("chatSenderAccountId", chatMessageDTO.getChatSenderAccountId());
	    params.put("chatMessage", chatMessageDTO.getChatMessage());
	    params.put("chatSender", chatMessageDTO.getChatSender()); // Integer로 전달
	    params.put("chatCreatedAt", chatMessageDTO.getChatCreatedAt());
	 Integer count = sqlSession.selectOne("mybatis.mapper.chatMessageMapper.checkMessageDuplicate", params);
	    return count != null && count > 0;
}

public Integer saveAlarmData(NotificationDTO messageAlarm) {
	
	return sqlSession.insert("mybatis.mapper.chatMessageMapper.saveAlarmData", messageAlarm);
}

public ChatUserDTO getReceiverInfoByUserId(Integer chatReceiverAccountId) {
	
	return sqlSession.selectOne("mybatis.mapper.chatMessageMapper.getReceiverInfoByUserId", chatReceiverAccountId);
}

public String getProductNameById(int parseInt) {
	
	return sqlSession.selectOne("mybatis.mapper.chatMessageMapper.getProductNameById", parseInt);
}

public List<NotificationDTO> getUnreadAlarms(Integer userId) {
	
	return sqlSession.selectList("mybatis.mapper.chatMessageMapper.getUnreadAlarms", userId);
}

public int getTotalChatCount(int roomId, int buyerId, int sellerId) {
	 Map<String, Object> paramMap = new HashMap<>();
	 paramMap.put("roomId", roomId);
	 paramMap.put("buyerId", buyerId);
	 paramMap.put("sellerId", sellerId);

	 Integer count = sqlSession.selectOne("mybatis.mapper.chatMapper.getTotalChatCount", paramMap);
	 return count != null ? count : 0;
}

public int getBuyerToSellerCount(int roomId, int buyerId, int sellerId) {
	Map<String, Object> paramMap = new HashMap<>();
    paramMap.put("roomId", roomId);
    paramMap.put("buyerId", buyerId);
    paramMap.put("sellerId", sellerId);
    Integer count = sqlSession.selectOne("mybatis.mapper.chatMapper.getBuyerToSellerCount", paramMap);
    return count != null ? count : 0;
}

public void deleteChatsByRoomId(int roomId) {
	sqlSession.delete( "mybatis.mapper.chatMapper.deleteChatsByRoomId", roomId);
    
}


public void deleteRoom(int roomId) {
	 sqlSession.delete("mybatis.mapper.chatMapper.deleteRoom", roomId);
   
}

public void deleteAlarmsByRoomId(int roomId) {
	sqlSession.delete("mybatis.mapper.chatMapper.deleteAlarmsByRoomId", roomId);
}




public List<Integer> findRoomIdsByProductId(Integer productId) {
    return sqlSession.selectList("mybatis.mapper.chatMapper.findRoomIdsByProductId", productId);
}


public void deleteAlarmsByRoomId(Integer roomId) {
    sqlSession.delete("mybatis.mapper.chatMapper.deleteAlarmsByRoomId", roomId);
}


public void deleteChatsByRoomId(Integer roomId) {
    sqlSession.delete("mybatis.mapper.chatMapper.deleteChatsByRoomId", roomId);
}


public void deleteRoomsByProductId(Integer productId) {
    sqlSession.delete("mybatis.mapper.chatMapper.deleteRoomsByProductId", productId);
}

public void deleteAlarmsByRoomIdCascade(int roomId) {
	sqlSession.delete("mybatis.mapper.chatMapper.deleteAlarmsByRoomIdCascade", roomId);
	
}

   
   
   
  
}