package org.puppit.model.dto;



import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class ChatMessageProductDTO {
	private String productId;
	private String productName;
	private String productPrice;
	private String sellerId;
	private String chatSellerAccountId;
	
	@Override
	public String toString() {
		return "ChatMessageProductDTO [productId=" + productId + ", productName=" + productName + ", productPrice="
				+ productPrice + ", sellerId=" + sellerId + ", chatSellerAccountId=" + chatSellerAccountId + "]";
	}
	

	

}