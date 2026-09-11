package org.puppit.service;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;
import org.puppit.model.dto.PasswordResetTokenDTO;
import org.puppit.model.dto.UserDTO;
import org.puppit.repository.PasswordResetTokenDAO;
import org.puppit.repository.UserDAO;
import org.puppit.util.SecureUtil;

/**
 * UserServiceImpl 단위 테스트 — 2026-09-11 로그인/회원가입 하드닝 작업을 검증한다.
 * 실제 DB 대신 UserDAO/PasswordResetTokenDAO/SecureUtil을 목(mock)으로 대체해 서비스 로직만 검증.
 */
@RunWith(MockitoJUnitRunner.class)
public class UserServiceImplTest {

  @Mock private UserDAO userDAO;
  @Mock private PasswordResetTokenDAO passwordResetTokenDAO;
  @Mock private SecureUtil secureUtil;

  @InjectMocks
  private UserServiceImpl userService;

  private UserDTO validSignupUser() {
    return UserDTO.builder()
        .accountId("tester01")
        .userPassword("Passw0rd!") // 대문자 1개 + 영/숫/!@# 6~10자 정책 만족
        .userName("테스터")
        .nickName("테스터닉")
        .userEmail("tester@example.com")
        .userPhone("010-1234-5678")
        .build();
  }

  // ---------- signup: 회원가입 서버측 형식 검증 (수정 #5) ----------

  @Test
  public void signup_유효한형식이면_비밀번호를해시화해서DAO에저장한다() {
    UserDTO user = validSignupUser();
    byte[] salt = new byte[16];
    when(secureUtil.getSalt()).thenReturn(salt);
    when(secureUtil.hashPBKDF2(eq("Passw0rd!"), eq(salt))).thenReturn("hashed");
    when(userDAO.userSignUp(any(UserDTO.class))).thenReturn(1);

    boolean result = userService.signup(user);

    assertTrue(result);
    assertEquals("hashed", user.getUserPassword()); // 원문이 해시로 치환됐는지
    verify(userDAO).userSignUp(user);
  }

  @Test
  public void signup_비밀번호정책위반이면_해시화도DAO호출도없이실패한다() {
    UserDTO user = validSignupUser();
    user.setUserPassword("weak"); // 대문자 없음 + 6자 미만 → 정책 위반

    boolean result = userService.signup(user);

    assertFalse(result);
    verifyNoInteractions(userDAO); // 형식 검증이 해시화 이전에 걸러내는지 확인
    verifyNoInteractions(secureUtil);
  }

  @Test
  public void signup_이메일형식이깨졌으면_실패한다() {
    UserDTO user = validSignupUser();
    user.setUserEmail("not-an-email");

    assertFalse(userService.signup(user));
    verifyNoInteractions(userDAO);
  }

  @Test
  public void signup_아이디에대문자가있으면_실패한다() {
    UserDTO user = validSignupUser();
    user.setAccountId("Tester01"); // 정책: 영문 소문자+숫자만

    assertFalse(userService.signup(user));
    verifyNoInteractions(userDAO);
  }

  // ---------- login: 로그인 (수정 #6 상수시간 비교 포함) ----------

  @Test
  public void login_비밀번호가일치하면_사용자정보를반환한다() {
    byte[] salt = new byte[16];
    UserDTO stored = UserDTO.builder().accountId("tester01").salt(salt).userPassword("hashed").build();
    when(userDAO.selectLogin("tester01")).thenReturn(stored);
    when(secureUtil.hashPBKDF2("rawpw", salt)).thenReturn("hashed");

    UserDTO input = UserDTO.builder().accountId("tester01").userPassword("rawpw").build();
    UserDTO result = userService.login(input);

    assertNotNull(result);
    assertEquals("tester01", result.getAccountId());
  }

  @Test
  public void login_비밀번호가틀리면_null을반환한다() {
    byte[] salt = new byte[16];
    UserDTO stored = UserDTO.builder().accountId("tester01").salt(salt).userPassword("hashed").build();
    when(userDAO.selectLogin("tester01")).thenReturn(stored);
    when(secureUtil.hashPBKDF2("wrongpw", salt)).thenReturn("different");

    UserDTO input = UserDTO.builder().accountId("tester01").userPassword("wrongpw").build();
    assertNull(userService.login(input));
  }

  @Test
  public void login_존재하지않는계정이면_null을반환한다() {
    when(userDAO.selectLogin("ghost")).thenReturn(null);

    UserDTO input = UserDTO.builder().accountId("ghost").userPassword("any").build();
    assertNull(userService.login(input));
  }

  // ---------- reset token: reset-password 취약점 수정 (수정 #1) ----------

  @Test
  public void issuePasswordResetToken_존재하는계정이면_토큰발급하고DB에는해시만저장한다() {
    UserDTO stored = UserDTO.builder().userId(1).accountId("tester01").build();
    when(userDAO.getUserByAccountId("tester01")).thenReturn(stored);
    when(secureUtil.hashSHA256(any(String.class))).thenReturn("hashed-token");

    String rawToken = userService.issuePasswordResetToken("tester01");

    assertNotNull(rawToken);
    ArgumentCaptor<PasswordResetTokenDTO> captor = ArgumentCaptor.forClass(PasswordResetTokenDTO.class);
    verify(passwordResetTokenDAO).insertToken(captor.capture());
    assertEquals(Integer.valueOf(1), captor.getValue().getUserId());
    assertEquals("hashed-token", captor.getValue().getTokenHash());
    assertNotEquals("원문 토큰이 그대로 저장되면 안 된다", rawToken, captor.getValue().getTokenHash());
  }

  @Test
  public void issuePasswordResetToken_존재하지않는계정이면_null이고DAO호출도안한다_사용자열거방지() {
    when(userDAO.getUserByAccountId("ghost")).thenReturn(null);

    assertNull(userService.issuePasswordResetToken("ghost"));
    verifyNoInteractions(passwordResetTokenDAO);
  }

  @Test
  public void resetPasswordWithToken_유효한토큰이면_비밀번호변경후토큰을사용처리한다() {
    when(secureUtil.hashSHA256("raw-token")).thenReturn("hashed-token");
    PasswordResetTokenDTO token = PasswordResetTokenDTO.builder().tokenId(10).userId(1).build();
    when(passwordResetTokenDAO.findValidByHash("hashed-token")).thenReturn(token);
    when(userDAO.getUserByUserId(1)).thenReturn(UserDTO.builder().userId(1).accountId("tester01").build());
    when(secureUtil.getSalt()).thenReturn(new byte[16]);
    when(secureUtil.hashPBKDF2(eq("NewPassw0rd!"), any(byte[].class))).thenReturn("newHash");
    when(userDAO.updatePasswordByAccountId(anyMap())).thenReturn(1);

    boolean result = userService.resetPasswordWithToken("raw-token", "NewPassw0rd!");

    assertTrue(result);
    verify(passwordResetTokenDAO).markUsed(10);
  }

  @Test
  public void resetPasswordWithToken_토큰이없거나만료면_실패하고_재사용처리도하지않는다() {
    when(secureUtil.hashSHA256("bad-token")).thenReturn("hashed-bad");
    when(passwordResetTokenDAO.findValidByHash("hashed-bad")).thenReturn(null);

    boolean result = userService.resetPasswordWithToken("bad-token", "NewPassw0rd!");

    assertFalse(result);
    verify(passwordResetTokenDAO, never()).markUsed(anyInt());
    verify(userDAO, never()).updatePasswordByAccountId(anyMap());
  }

  // ---------- delete: 회원 탈퇴 (수정 #2 NPE 순서와 연결되는 서비스 로직) ----------

  @Test
  public void deleteMyAccount_존재하는유저면_소프트삭제한다() {
    when(userDAO.getUserByUserId(1)).thenReturn(UserDTO.builder().userId(1).build());
    when(userDAO.softDeleteUser(1)).thenReturn(1);

    assertTrue(userService.deleteMyAccount(1));
  }

  @Test
  public void deleteMyAccount_존재하지않는유저면_softDelete를호출하지않는다() {
    when(userDAO.getUserByUserId(99)).thenReturn(null);

    assertFalse(userService.deleteMyAccount(99));
    verify(userDAO, never()).softDeleteUser(anyInt());
  }

  // ---------- passwordCheck: 탈퇴 전 비밀번호 재확인 (수정 #4) ----------

  @Test
  public void passwordCheck_비밀번호가일치하면_true를반환한다() {
    byte[] salt = new byte[16];
    UserDTO stored = UserDTO.builder().salt(salt).userPassword("hashed").build();
    when(userDAO.getUserByUserId(1)).thenReturn(stored);
    when(secureUtil.hashPBKDF2("pw", salt)).thenReturn("hashed");

    assertTrue(userService.passwordCheck(1, "pw"));
  }

  @Test
  public void passwordCheck_비밀번호가틀리면_false를반환한다() {
    byte[] salt = new byte[16];
    UserDTO stored = UserDTO.builder().salt(salt).userPassword("hashed").build();
    when(userDAO.getUserByUserId(1)).thenReturn(stored);
    when(secureUtil.hashPBKDF2("wrong", salt)).thenReturn("different");

    assertFalse(userService.passwordCheck(1, "wrong"));
  }
}
