package org.puppit.model.dto;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@RequiredArgsConstructor
public class ReviewDTO {
  
  private final Integer reviewId;
  private final Integer sellerId;
  private final Integer buyerId;
  private final Integer productId;
  private final String content;
  private final Integer rating;
  private final Timestamp createdAt;
  private final Timestamp updatedAt;
  
  private final String sellerNickname;
  private final String buyerNickname;
  private final String productName;
  

}
