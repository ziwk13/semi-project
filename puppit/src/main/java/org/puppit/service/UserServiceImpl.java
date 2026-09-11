package org.puppit.service;

import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

import org.puppit.model.dto.PasswordResetTokenDTO;
import org.puppit.model.dto.UserDTO;
import org.puppit.model.dto.UserStatusDTO;
import org.puppit.repository.PasswordResetTokenDAO;
import org.puppit.repository.UserDAO;
import org.puppit.util.SecureUtil;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class UserServiceImpl implements UserService {

  // 재설정 토큰 유효 시간
  private static final long RESET_TOKEN_TTL_MINUTES = 15;

  private final UserDAO userDAO;
  private final PasswordResetTokenDAO passwordResetTokenDAO;
  private final SecureUtil secureUtil;
  
  private boolean emptyCheck(String... fields) {
    for(String field : fields) {
      if(field == null || field.trim().isEmpty()) {
        return true;
      }
    }
    return false; 
  }
  
  public boolean signup(UserDTO user) {
    try {
      // salt 생성
      byte[] salt = secureUtil.getSalt();
      // 비밀번호 암호화 하기
      String encryptedPassword = secureUtil.hashPBKDF2(user.getUserPassword(), salt);
      // DB로 보낼 salt, 암호화 된 비밀번호를 UserDTO에 저장
      user.setSalt(salt);
      user.setUserPassword(encryptedPassword);
      if(emptyCheck(user.getAccountId(), user.getUserPassword(), user.getUserName(), user.getNickName(), user.getUserEmail(), user.getUserPhone())) {
        return false;
      }
      return userDAO.userSignUp(user) == 1;
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }
  @Override
  public boolean deleteMyAccount(Integer userId) {
    try {
      // 유저  조회
      UserDTO auth = userDAO.getUserByUserId(userId);
      if(auth == null) return false;  // 없는 유저 or 이미 탈퇴 처리된 케이스
      
      // 회원 탈퇴
      int rows = userDAO.softDeleteUser(userId);
      return rows == 1;
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }
  @Override
  public UserDTO login(UserDTO user) {
    try {
      // 빈값 체크
      if (emptyCheck(user.getAccountId(), user.getUserPassword())) {
        return null;
      }
      
      // 1) DB에서 accountId로 사용자 정보(솔트, 저장된 해시) 가져오기
      UserDTO auth = userDAO.selectLogin(user.getAccountId());
      if (auth == null) {
        return null; // 계정 없음
      }
      // 2) 솔트 꺼내기 (DB에 VARBINARY로 저장되어 있으면 byte[]로 매핑됨)
      byte[] salt = auth.getSalt();
      if (salt == null) {
        return null; // 안전장치
      }
      
      // 3) 클라이언트가 보낸 평문 비밀번호를 PBKDF2로 해시화
      // secureUtil.hashPBKDF2(...)는 byte[] -> hex(String) 또는 byte[] 반환 등
      // 아래는 "hex 문자열" 반환 가정
      String Password = user.getUserPassword();
      String encryptedPassword = secureUtil.hashPBKDF2(Password, salt); // returns hex string
      
      // 4) DB에 저장된 해시와 안전비교
      String storedHash = auth.getUserPassword(); // DB에 저장된 해시 (hex)
      if (storedHash == null) return null;
      
      return encryptedPassword.equals(auth.getUserPassword()) ? auth : null;
      
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
  }
  // 아이디 찾기
  @Override
  public String findAccountIdByUserNameUserEmail(UserDTO user) {
    return userDAO.findAccountIdByNameAndEmail(user);
  }
  // 비밀번호를 이용한 본인 확인
  public Boolean passwordCheck(int userId, String userPassword) {
    UserDTO auth = userDAO.getUserByUserId(userId);
    if (auth == null || auth.getSalt() == null || auth.getUserPassword() == null) {
      return false;
    }
    String encryptedPassword = secureUtil.hashPBKDF2(userPassword, auth.getSalt());
    return encryptedPassword.equals(auth.getUserPassword());
  }
  // 비밀번호 변경
  @Override
  public Boolean updatePassword(String accountId, String userPassword) {
    byte[] salt = secureUtil.getSalt();
    String encryptedPassword = secureUtil.hashPBKDF2(userPassword, salt);
    
    Map<String, Object> map = new HashMap<>();
    map.put("accountId", accountId);
    map.put("userPassword", encryptedPassword);
    map.put("salt", salt);
    
    return userDAO.updatePasswordByAccountId(map) == 1;
  }
  // 비밀번호 재설정 토큰 발급
  @Override
  public String issuePasswordResetToken(String accountId) {
    if (accountId == null || accountId.isBlank()) return null;

    UserDTO user = userDAO.getUserByAccountId(accountId.trim());
    if (user == null) return null; // 계정 없음 — 호출자는 이 경우에도 동일한 성공 안내를 보여준다

    // 원문 토큰은 반환값으로만 잠깐 존재한다. DB에는 SHA-256 해시만 저장.
    byte[] raw = new byte[32];
    new SecureRandom().nextBytes(raw);
    String rawToken = Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
    String tokenHash = secureUtil.hashSHA256(rawToken); // 토큰 자체가 고엔트로피 난수라 salt 불필요

    PasswordResetTokenDTO token = PasswordResetTokenDTO.builder()
        .userId(user.getUserId())
        .tokenHash(tokenHash)
        .expiresAt(Timestamp.valueOf(LocalDateTime.now().plusMinutes(RESET_TOKEN_TTL_MINUTES)))
        .build();
    passwordResetTokenDAO.insertToken(token);

    return rawToken;
  }
  // 토큰 검증 후 비밀번호 재설정
  @Override
  public boolean resetPasswordWithToken(String rawToken, String newPassword) {
    if (rawToken == null || rawToken.isBlank() || newPassword == null || newPassword.isBlank()) {
      return false;
    }
    String tokenHash = secureUtil.hashSHA256(rawToken);
    PasswordResetTokenDTO token = passwordResetTokenDAO.findValidByHash(tokenHash);
    if (token == null) return false; // 없음 / 만료 / 이미 사용됨

    UserDTO user = userDAO.getUserByUserId(token.getUserId());
    if (user == null) return false;

    boolean ok = updatePassword(user.getAccountId(), newPassword);
    if (ok) {
      passwordResetTokenDAO.markUsed(token.getTokenId());
    }
    return ok;
  }
  @Override
  public Boolean isAccountIdAvailable(String accountId) {
    if(accountId == null || accountId.isBlank()) return false;
    return userDAO.countByAccountId(accountId.trim().toLowerCase()) == 0; 
  } 
  @Override
  public Boolean isNickNameAvailable(String nickName) {
    if(nickName == null || nickName.isBlank()) return false;
    return userDAO.countByNickName(nickName.trim()) == 0;
  }
  @Override
  public Boolean isUserEmailAvailable(String userEmail) {
    if(userEmail == null || userEmail.isBlank()) return false;
    return userDAO.countByEmail(userEmail.trim().toLowerCase()) == 0;
  }
  @Override
  public Integer insertLogStatus(UserStatusDTO log) {
    return userDAO.insertLogStatus(log);
  }
  @Override
  public UserDTO getUserId(String accountId) {
    return userDAO.getUserByAccountId(accountId);
  }

  @Override
  public boolean updateUser(Map<String, Object> map) {
    return userDAO.updateUser(map) == 1;
   
  }
  // userId를 이용해 db에서 ProfileImageKey가져오기
  @Override
  public UserDTO getProfileImageKey(Integer userId) {
    return userDAO.getUserByUserId(userId);
  }

  @Override
  public boolean updateProfileImageKey(Integer userId, String profileImageKey) {
    Map<String, Object> map = new HashMap<>();
    map.put("userId", userId);
    map.put("profileImageKey", profileImageKey);
    int rows = userDAO.updateProfileImageKey(map);   
    System.out.println("[updateProfileImageKey] rows=" + rows + ", userId=" + userId + ", key=" + profileImageKey);
    return rows == 1;
  }
}


