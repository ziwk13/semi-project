package org.puppit.model.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class IamportCancelRequest {
  private String merchantUid;
  private Integer amount;
  private String reason;
  private Integer checksum;
}
