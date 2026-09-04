package org.puppit.model.dto;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@NoArgsConstructor
@Getter
@Setter
@ToString
public class ChatListDTO {
	private Integer roomId;
	private Integer productId;
	private String productName;
	private Integer productPrice;
	private Integer sellerId;
	private String sellerName;
	private String sellerAccountId;
	private String sellerNickName;
	private String buyerNickName;
	private String buyerAccountId;
	private Integer otherUserId;
	private String otherAccountId;
	private String otherUserName;
	private String lastMessage;
	private Integer lastMessageSenderId;
	private String lastMessageSenderAccountId;
	private String lastMessageSenderName;
	private Integer lastMessageReceiverId;
	private String lastMessageReceiverAccountId;
	private String lastMessageReceiverName;
	private Timestamp sortTime;
	private Timestamp lastMessageAt; // 마지막 메시지 생성 시간 추가
	private String otherProfileImageKey;
	private String chatLastMessageAt;
	
	

	
}