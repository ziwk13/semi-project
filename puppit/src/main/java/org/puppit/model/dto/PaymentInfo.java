package org.puppit.model.dto;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@RequiredArgsConstructor
@Getter
public class PaymentInfo {
  private final String status;
  private final String merchantUid;
  private final Integer amount;
}
