package org.puppit.model.dto;

import lombok.Data;

@Data
public class IamportCancelResponse {
  private Integer cancelledAt;
  private String receiptUrl;
}
