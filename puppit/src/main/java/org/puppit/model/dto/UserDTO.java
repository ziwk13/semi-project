package org.puppit.model.dto;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
@Builder
public class UserDTO {

  //user table PK
  private Integer userId;
  private String accountId;
  private String userName;
  private String nickName;
  private String userPassword;
  private String userEmail;
  private String userPhone;
  private Timestamp createdAt;
  private Timestamp updatedAt;
  private Integer point;
  private byte[] salt;
  private String profileImageKey;
  private String provider;  // "kakao"
  private Long providerId;  // 카카오 userId

  
}
