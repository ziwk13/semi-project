package org.puppit.model.dto;




import java.sql.Timestamp;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class ChatMessageDTO {
	private String messageId;
	private String chatRoomId;
	private String productId;

	private Integer chatSender;
	private String chatSenderAccountId;
	private String chatSenderUserName;
	private Integer chatReceiver;

	private String chatReceiverAccountId;
	private String chatReceiverUserName;
	private String chatMessage;
	@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", timezone = "Asia/Seoul")
	private Timestamp chatCreatedAt;
	private String senderRole;
	private String receiverRole;
	private String chatSellerAccountId;
	private String chatSellerNickName;
	private String buyerId;
	
	@Override
	public String toString() {
		return "ChatMessageDTO [messageId=" + messageId + ", chatRoomId=" + chatRoomId + ", productId=" + productId
				+ ", chatSender=" + chatSender + ", chatSenderAccountId=" + chatSenderAccountId
				+ ", chatSenderUserName=" + chatSenderUserName + ", chatReceiver=" + chatReceiver
				+ ", chatReceiverAccountId=" + chatReceiverAccountId + ", chatReceiverUserName=" + chatReceiverUserName
				+ ", chatMessage=" + chatMessage + ", chatCreatedAt=" + chatCreatedAt + ", senderRole=" + senderRole
				+ ", receiverRole=" + receiverRole + ", chatSellerAccountId=" + chatSellerAccountId
				+ ", chatSellerNickName=" + chatSellerNickName + ", buyerId=" + buyerId + "]";
	}
	
	




}
