package org.puppit.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

import org.puppit.model.dto.PasswordResetTokenDTO;
import org.puppit.model.dto.UserDTO;
import org.puppit.model.dto.UserStatusDTO;
import org.puppit.repository.PasswordResetTokenDAO;
import org.puppit.repository.UserDAO;
import org.puppit.util.SecureUtil;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Slf4j
@Service
public class UserServiceImpl implements UserService {

  // 재설정 토큰 유효 시간
  private static final long RESET_TOKEN_TTL_MINUTES = 15;

  // 회원가입 형식 검증 — signup.jsp 의 클라이언트측 정규식과 동일한 정책.
  // JS를 우회해 폼 없이 직접 POST 하는 경우를 막기 위한 서버측 방어선.
  private static final Pattern ACCOUNT_ID_PATTERN = Pattern.compile("^[a-z0-9]{4,12}$");
  private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[A-Z])[A-Za-z0-9!@#]{6,10}$");
  private static final Pattern NICKNAME_PATTERN = Pattern.compile("^[A-Za-z0-9가-힣]{4,8}$");
  private static final Pattern PHONE_PATTERN = Pattern.compile("^01[0-9]-?\\d{3,4}-?\\d{4}$");
  private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");

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

  private boolean isValidSignupFormat(UserDTO user) {
    return user.getUserName() != null && !user.getUserName().isBlank()
        && user.getAccountId() != null && ACCOUNT_ID_PATTERN.matcher(user.getAccountId()).matches()
        && isValidPasswordFormat(user.getUserPassword())
        && user.getNickName() != null && NICKNAME_PATTERN.matcher(user.getNickName()).matches()
        && user.getUserPhone() != null && PHONE_PATTERN.matcher(user.getUserPhone()).matches()
        && user.getUserEmail() != null && EMAIL_PATTERN.matcher(user.getUserEmail()).matches();
  }

  // 회원가입뿐 아니라 비밀번호 재설정에도 같은 정책을 적용하기 위해 분리.
  // (재설정 흐름은 이 검증 없이 곧바로 저장하고 있었음 — 대문자/특수문자 정책이 가입 때만 걸리고
  //  재설정에는 전혀 적용되지 않던 구멍이었음)
  @Override
  public boolean isValidPasswordFormat(String password) {
    return password != null && PASSWORD_PATTERN.matcher(password).matches();
  }

  public boolean signup(UserDTO user) {
    try {
      // 형식 검증은 비밀번호를 해시로 덮어쓰기 전, 원문 상태에서 먼저 수행한다.
      if (!isValidSignupFormat(user)) {
        return false;
      }
      // salt 생성
      byte[] salt = secureUtil.getSalt();
      // 비밀번호 암호화 하기
      String encryptedPassword = secureUtil.hashPBKDF2(user.getUserPassword(), salt);
      // DB로 보낼 salt, 암호화 된 비밀번호를 UserDTO에 저장
      user.setSalt(salt);
      user.setUserPassword(encryptedPassword);
      return userDAO.userSignUp(user) == 1;
    } catch (Exception e) {
      log.error("회원가입 처리 중 오류 (accountId={})", user.getAccountId(), e);
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
      log.error("회원 탈퇴 처리 중 오류 (userId={})", userId, e);
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
      
      // 4) DB에 저장된 해시와 안전비교 (문자열 길이로 조기 반환되는 String.equals 대신
      //    타이밍 공격에 강한 상수시간 비교 사용)
      String storedHash = auth.getUserPassword(); // DB에 저장된 해시 (hex)
      if (storedHash == null) return null;

      boolean matched = MessageDigest.isEqual(
          encryptedPassword.getBytes(StandardCharsets.UTF_8),
          storedHash.getBytes(StandardCharsets.UTF_8));
      return matched ? auth : null;

    } catch (Exception e) {
      // 비밀번호는 절대 로그에 남기지 않는다 — accountId만 기록
      log.error("로그인 처리 중 오류 (accountId={})", user.getAccountId(), e);
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
    return MessageDigest.isEqual(
        encryptedPassword.getBytes(StandardCharsets.UTF_8),
        auth.getUserPassword().getBytes(StandardCharsets.UTF_8));
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
    // 가입 때와 같은 비밀번호 정책을 재설정에도 적용한다(회원가입에만 걸리고
    // 재설정은 그냥 통과되던 구멍 수정).
    if (!isValidPasswordFormat(newPassword)) {
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
    log.debug("프로필 이미지 키 갱신 rows={}, userId={}, key={}", rows, userId, profileImageKey);
    return rows == 1;
  }
}


