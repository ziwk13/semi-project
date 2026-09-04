package org.puppit.model.dto;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class ChatRoomPeopleDTO {
	private Integer messageId;
	private Integer chatRoomId;
	private Integer productId;
	private String chatSender;
	private String chatReceiver;
	private String senderAccountId;
	private String senderUserName;
	private String receiverAccountId;
	private String receiverUserName;
	private String chatMessage;
	private Timestamp chatCreatedAt;
	private String senderIsMe;
	private String receiverIsMe;
	private String senderRole;
	private String receiverRole;
	private Integer productSellerId;
	private Integer buyerId;
	@Override
	public String toString() {
		return "ChatRoomPeopleDTO [messageId=" + messageId + ", chatRoomId=" + chatRoomId + ", productId=" + productId
				+ ", chatSender=" + chatSender + ", chatReceiver=" + chatReceiver + ", senderAccountId="
				+ senderAccountId + ", senderUserName=" + senderUserName + ", receiverAccountId=" + receiverAccountId
				+ ", receiverUserName=" + receiverUserName + ", chatMessage=" + chatMessage + ", chatCreatedAt="
				+ chatCreatedAt + ", senderIsMe=" + senderIsMe + ", receiverIsMe=" + receiverIsMe + ", senderRole="
				+ senderRole + ", receiverRole=" + receiverRole + ", productSellerId=" + productSellerId + ", buyerId="
				+ buyerId + "]";
	}
	
	


	
	
}
