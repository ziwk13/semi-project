package org.puppit.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.puppit.model.dto.AlarmReadDTO;
import org.puppit.model.dto.NotificationDTO;
import org.puppit.model.dto.UserDTO;
import org.puppit.repository.UserDAO;
import org.puppit.service.ChatAlarmService;
import org.puppit.service.ChatService;
import org.puppit.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ChatApiAlarmController {

	private final ChatService chatService;
	private final ChatAlarmService alarmService;
	private final UserService userService;
	private final UserDAO userDAO;
	
	
	@GetMapping(value = "/alarm",  produces = MediaType.APPLICATION_JSON_VALUE)
	@ResponseBody
	public List< NotificationDTO> getUnreadAlarms(@RequestParam Integer userId) {
		List<NotificationDTO> unreadAlarms = chatService.getUnreadAlarms(userId);
		System.out.println("안읽은 알림: " + chatService.getUnreadAlarms(userId) );
		return unreadAlarms;
	}
	
	@PostMapping(value = "/alarm/read",  produces = MediaType.APPLICATION_JSON_VALUE)
	@ResponseBody
	public ResponseEntity<?> readAlarm(@RequestBody AlarmReadDTO alarmReadDTO) {
	    try {
	    	System.out.println("AlarmReadDTO: "+ alarmReadDTO.toString());
	        System.out.println("messageId: " + alarmReadDTO.getMessageId());
	        UserDTO user = userDAO.getUserByUserId(alarmReadDTO.getChatReceiver());
	        if (user == null) {
	            Map<String, Object> result = new HashMap<>();
	            result.put("result", "fail");
	            result.put("error", "해당 chatReceiver에 대한 사용자 정보가 없습니다.");
	            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
	        }
	        alarmReadDTO.setChatReceiverUserId(user.getUserId());
	        int readUpdateCount = alarmService.markAsRead(alarmReadDTO);
	        System.out.println("알림 메시지 읽음 여부: " + readUpdateCount);
	        return ResponseEntity.ok().body(java.util.Map.of("result", "ok"));
	    } catch (Exception e) {
	        Map<String, Object> result = new HashMap<>();
	        result.put("result", "fail");
	        result.put("error", e.getMessage() == null ? "" : e.getMessage());
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
	    }
	}
	
	
	@PostMapping(value = "/alarm/readAll", produces = MediaType.APPLICATION_JSON_VALUE)
	@ResponseBody
	public ResponseEntity<?> readAllAlarms(@RequestBody Map<String, Object> params) {
	    try {
	        Integer roomId = Integer.valueOf(params.get("roomId").toString());
	        Integer userId = Integer.valueOf(params.get("userId").toString());
	        Integer groupCount = Integer.valueOf(params.get("count").toString());
	        int n = alarmService.markAllAsRead(roomId, userId, groupCount);
	        System.out.println("roomId: " + roomId + ",userId: " + userId + ",groupCount: " + groupCount + ",n: " + n);
	        
	        
	        return ResponseEntity.ok(Map.of("result", "ok", "count", n));
	    } catch (Exception e) {
	        Map<String, Object> result = new HashMap<>();
	        result.put("result", "fail");
	        result.put("error", e.getMessage() == null ? "" : e.getMessage());
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
	    }
	}
	
	@GetMapping(value = "/chat/unreadCount", produces = MediaType.APPLICATION_JSON_VALUE)
	@ResponseBody
	public Map<Integer, Integer> getUnreadCounts(@RequestParam Integer userId) {
	    return alarmService.getUnreadCountsForUser(userId);
	}
	
	@GetMapping(value = "/chat/count", produces = MediaType.APPLICATION_JSON_VALUE)
	@ResponseBody
	public Map<String, Integer> getTotalChatCount(@RequestParam("roomId") int roomId,
	                                              @RequestParam("buyerId") int buyerId,
	                                              @RequestParam("sellerId") int sellerId) {
	    System.out.println("/api/chat/count");
	    int totalChatCount = chatService.getTotalChatCount(roomId, buyerId, sellerId);
	    int buyerToSellerCount = chatService.getBuyerToSellerCount(roomId, buyerId, sellerId); // ★ 추가!
	    System.out.println("roomId: " + roomId + ", totalChatCount: " + totalChatCount + ", buyerToSellerCount: " + buyerToSellerCount);

	    Map<String, Integer> result = new HashMap<>();
	    result.put("totalChatCount", totalChatCount);
	    result.put("buyerToSellerCount", buyerToSellerCount); // ★ 추가!
	    return result;
	}
	

	
	
	
	
	// 2. 채팅방 목록 조회(생성일 기준 내림차순) - 상품상세에서 채팅하기 클릭 등
		@GetMapping(value = "/chat/recentRoomList", produces = MediaType.APPLICATION_JSON_VALUE)
		@ResponseBody
		public Map<String, Object> recentRoomList(@RequestParam(value = "highlightRoomId", required = false) Integer highlightRoomId,
									 @RequestParam(value = "highlightMessageId", required = false)	Integer highlightMessageId,
									 Model model, HttpSession session) {
		    Map<String, Object> map = (Map<String, Object>) session.getAttribute("sessionMap");
		    if (map == null || map.get("userId") == null) {
		        throw new IllegalStateException("세션 정보가 없습니다. 로그인이 필요합니다.");
		    }

		    Object userIdObj = map.get("userId");
		    int userId;
		    try {
		        userId = Integer.parseInt(userIdObj.toString());
		    } catch (NumberFormatException e) {
		        throw new IllegalArgumentException("사용자 ID 변환 중 오류가 발생했습니다.", e);
		    }

		    Map<String, Object> chatMap = chatService.getChatRoomsByCreatedDesc(userId);
		   System.out.println("chatMap - chats: " + chatMap.get("chats"));
		   System.out.println("profileImage: " + chatMap.get("profileImage"));
		   chatMap.put("highlightRoomId", highlightRoomId);
		   chatMap.put("highlightMessageId", highlightMessageId);
		    return chatMap;
		}
		
	
}