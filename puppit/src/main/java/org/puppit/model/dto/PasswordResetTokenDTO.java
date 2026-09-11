package org.puppit.model.dto;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

// 비밀번호 재설정 토큰. DB 테이블(password_reset_token)은 이미 스키마에 설계돼 있었지만
// 애플리케이션 레이어에서 쓰인 적이 없었다 — 이번에 실제로 연결한다.
// tokenHash: DB 컬럼명은 `token` 이지만 원문 토큰은 절대 저장하지 않고 SHA-256 해시만 담는다.
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
@Builder
public class PasswordResetTokenDTO {

  private Integer tokenId;
  private Integer userId;
  private String tokenHash;
  private Timestamp expiresAt;
  private Boolean used;
  private Timestamp createdAt;
}
