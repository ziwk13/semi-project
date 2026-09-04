package org.puppit.model.dto;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class TradeDTO {
  private Integer paymentId;
  private String uuid;
  private Integer buyerId;  
  private Integer sellerId;  
  private Integer productId;
  private String buyerNickname;
  private String sellerNickname;
  private String productName;
  private String productPrice;
  private String status; 
  private Timestamp createdAt;
}
