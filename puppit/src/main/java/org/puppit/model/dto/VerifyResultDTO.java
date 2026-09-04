package org.puppit.model.dto;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

// 결제 검증 결과 DTO
@Getter
@Setter
@RequiredArgsConstructor
public class VerifyResultDTO {
  private final boolean success;
  private final String message;
  
  public static VerifyResultDTO ok() {
    return new VerifyResultDTO(true, "결제 검증 성공");
  }
  public static VerifyResultDTO fail(String message) {
    return new VerifyResultDTO(false, "message");
  }
}
