package org.puppit.model.dto;

import lombok.Data;

@Data
public class RefundRequest {
  private String merchantUid;
  private String reason;
}
