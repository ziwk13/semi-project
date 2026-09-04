package org.puppit.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RefundResult {
  private boolean success;
  private OrderStatus status;
  private String message;
  private Integer refundedAmount;
  private String receiptUrl;

}
