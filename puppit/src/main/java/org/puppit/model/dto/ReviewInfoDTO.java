package org.puppit.model.dto;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@RequiredArgsConstructor
@ToString
public class ReviewInfoDTO {
 
  private final String buyerNickname;
  private final String sellerNickname;
  private final String productName;
}
