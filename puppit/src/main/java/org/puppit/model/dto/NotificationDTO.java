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
public class NotificationDTO {
	private Integer roomId;
	private Integer userId;
	private String senderAccountId;
	private String receiverAccountId;
	private String chatMessage;
	private String senderRole;
	private String receiverRole;
	private Timestamp chatCreatedAt;
	private String productName;
	private Integer alarmReadMessageId;
	private Integer alarmId;
	private Integer messageId;
	private Integer isRead;
	private Integer chatSender;
	private Integer chatReceiver;
	
	@Override
	public String toString() {
		return "NotificationDTO [roomId=" + roomId + ", userId=" + userId + ", senderAccountId=" + senderAccountId
				+ ", receiverAccountId=" + receiverAccountId + ", chatMessage=" + chatMessage + ", senderRole="
				+ senderRole + ", receiverRole=" + receiverRole + ", chatCreatedAt=" + chatCreatedAt + ", productName="
				+ productName + ", alarmReadMessageId=" + alarmReadMessageId + ", alarmId=" + alarmId + ", messageId="
				+ messageId + ", isRead=" + isRead + ", chatSender=" + chatSender + ", chatReceiver=" + chatReceiver
				+ "]";
	}
	
	
	
	
	
	
}
