package org.puppit.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
public class ChaListProfileImageDTO {
	private Integer chatRoomId;
	private String productName;
	private String chatMessage;
	private String chatSenderAccountId;
	private String chatReceiverAccountId;
	private String receiverProfileImageKey;
	private Integer productSellerId;
	private String productSellerAccountId;
	private String sellerProfileImageKey;
	private String otherProfileImageKey;
}