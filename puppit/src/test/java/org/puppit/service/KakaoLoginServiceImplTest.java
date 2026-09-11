package org.puppit.service;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;
import org.puppit.model.dto.UserDTO;
import org.puppit.repository.UserDAO;

/**
 * KakaoLoginServiceImpl 단위 테스트 — 2026-09-11 카카오 로그인 하드닝 검증.
 * 실제 카카오 API 호출 없이 upsertAndGetUser()의 계정 연동 로직만 검증한다.
 */
@RunWith(MockitoJUnitRunner.class)
public class KakaoLoginServiceImplTest {

  @Mock private UserDAO userDAO;

  @InjectMocks
  private KakaoLoginServiceImpl kakaoLoginService;

  private Map<String, Object> kakaoUserInfo(long kakaoId, String email) {
    Map<String, Object> profile = new HashMap<>();
    profile.put("nickname", "테스터");
    profile.put("profile_image_url", "http://example.com/img.png");

    Map<String, Object> account = new HashMap<>();
    account.put("profile", profile);
    if (email != null) {
      account.put("email", email);
    }

    Map<String, Object> userInfo = new HashMap<>();
    userInfo.put("id", kakaoId);
    userInfo.put("kakao_account", account);
    return userInfo;
  }

  @Test
  public void 이미연동된카카오계정이면_프로필만갱신하고_새로만들지않는다() {
    UserDTO existing = UserDTO.builder().userId(1).accountId("kakao_100").provider("kakao").build();
    when(userDAO.findByProvider("kakao", 100L)).thenReturn(existing);

    UserDTO result = kakaoLoginService.upsertAndGetUser(kakaoUserInfo(100L, "tester@example.com"));

    assertNotNull(result);
    assertEquals("kakao_100", result.getAccountId());
    verify(userDAO).updateSocialProfile(existing);
    verify(userDAO, never()).insertSocialUser(any(UserDTO.class));
  }

  @Test
  public void 처음보는카카오계정이고_이메일이겹치지않으면_신규소셜계정을만든다() {
    when(userDAO.findByEmail("new@example.com")).thenReturn(null);
    when(userDAO.findByProvider("kakao", 200L))
        .thenReturn(null) // 최초 조회
        .thenReturn(UserDTO.builder().userId(2).accountId("kakao_200").build()); // insert 이후 재조회

    UserDTO result = kakaoLoginService.upsertAndGetUser(kakaoUserInfo(200L, "new@example.com"));

    assertNotNull(result);
    verify(userDAO).insertSocialUser(any(UserDTO.class));
  }

  @Test
  public void 이메일이이미가입된로컬계정과겹치면_자동연동하지않고예외를던진다() {
    when(userDAO.findByProvider("kakao", 300L)).thenReturn(null);
    UserDTO localAccount = UserDTO.builder().userId(3).accountId("localuser").userEmail("shared@example.com").build();
    when(userDAO.findByEmail("shared@example.com")).thenReturn(localAccount);

    Map<String, Object> userInfo = kakaoUserInfo(300L, "shared@example.com");

    assertThrows(KakaoAccountLinkException.class,
        () -> kakaoLoginService.upsertAndGetUser(userInfo));

    // 계정 선점 공격 방지 핵심: 자동 연동/신규 생성 둘 다 절대 일어나면 안 된다
    verify(userDAO, never()).linkProvider(any(UserDTO.class));
    verify(userDAO, never()).insertSocialUser(any(UserDTO.class));
  }
}
