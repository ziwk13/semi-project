package org.puppit.service;

import java.util.Map;

import org.puppit.model.dto.UserDTO;
import org.puppit.repository.UserDAO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import lombok.RequiredArgsConstructor;


@RequiredArgsConstructor
@Service
public class KakaoLoginServiceImpl implements KakaoLoginService {

  @Value("${kakao.rest.api.key}")
  private String clientId;
  @Value("${kakao.redirect.uri}")
  private String redirectUri;
  private final String tokenUrl = "https://kauth.kakao.com/oauth/token";
  private final String userInfoUrl = "https://kapi.kakao.com/v2/user/me";
  private final UserDAO userDAO;

  private final RestTemplate restTemplate = new RestTemplate();

  @SuppressWarnings("unused")
  public String getAccessToken(String code) {
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

    MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
    params.add("grant_type", "authorization_code");
    params.add("client_id", clientId);
    params.add("redirect_uri", redirectUri);
    params.add("code", code);

    HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(params, headers);

    ResponseEntity<Map> response = restTemplate.postForEntity(tokenUrl, request, Map.class);

    if (response.getStatusCode() == HttpStatus.OK) {
      Map body = response.getBody();
      String accessToken = (String) body.get("access_token");
      String refreshToken = (String) body.get("refresh_token");

      return accessToken;
    } else {
      throw new RuntimeException("토큰 요청 실패: " + response.getStatusCode());
    }
  }
  // 2. 토큰 -> 사용자 정보
  public Map<String, Object> getUserInfo(String accessToken) {
    HttpHeaders headers = new HttpHeaders();
    headers.setBearerAuth(accessToken); // Authorization: Bearer {token}
    HttpEntity<Void> request = new HttpEntity<>(headers);

    ResponseEntity<Map> response = restTemplate.exchange(
        userInfoUrl, HttpMethod.GET, request, Map.class);

    if (response.getStatusCode() == HttpStatus.OK) {
      @SuppressWarnings("unchecked")
      Map<String, Object> userInfo = response.getBody();
      return userInfo;
    } else {
      throw new RuntimeException("사용자 정보 요청 실패: " + response.getStatusCode());
    }
  }
  // 카카오 프로필 파싱용 (우리 DB 필드명에 맞춰 통일)
  static class KakaoProfile {
    Long id;
    String email;
    String nickname;
    String profileImage; // DB: profile_imageKey, DTO: profileImageKey
  }

  @SuppressWarnings("unchecked")
  private KakaoProfile parseProfile(Map<String, Object> userInfo) {
    KakaoProfile p = new KakaoProfile();
    p.id = ((Number) userInfo.get("id")).longValue();

    Map<String, Object> account = (Map<String, Object>) userInfo.get("kakao_account");
    if (account != null) {
      p.email = (String) account.get("email");
      Map<String, Object> prof = (Map<String, Object>) account.get("profile");
      if (prof != null) {
        p.nickname = (String) prof.get("nickname");
        // 고화질: profile_image_url (썸네일 쓰고 싶으면 thumbnail_image_url)
        p.profileImage = (String) prof.get("profile_image_url");
      }
    }
    return p;
  }

  /**
   * 카카오 프로필을 우리 DB와 연동하여 로그인용 UserDTO 반환
   */
  @Transactional
  @Override
  public UserDTO upsertAndGetUser(Map<String, Object> kakaoUserInfo) {
    KakaoProfile p = parseProfile(kakaoUserInfo);

    // 1) provider + provider_id 로 기존 사용자 조회
    UserDTO found = userDAO.findByProvider("kakao", p.id);
    if (found != null) {
      // 프로필 최신화
      if (p.nickname != null) found.setNickName(p.nickname);
      found.setProfileImageKey(p.profileImage);     // DTO 필드명에 맞게
      userDAO.updateSocialProfile(found);
      return found;
    }

    // 2) 이메일 기반 자동 연동은 하지 않는다 — KakaoAccountLinkException 참고.
    //    (로컬 회원가입이 이메일 소유권을 검증하지 않는 상태에서 자동 연동을 허용하면
    //     계정 선점 공격에 노출된다. 대신 명시적으로 거부하고 기존 계정으로 로그인하도록 안내한다.)
    if (p.email != null && !p.email.isEmpty()) {
      UserDTO byEmail = userDAO.findByEmail(p.email);
      if (byEmail != null) {
        throw new KakaoAccountLinkException(
            "이미 가입된 이메일입니다. 아이디/비밀번호로 로그인 후 이용해주세요.");
      }
    }

    // 3) 신규 소셜 가입
    UserDTO social = new UserDTO();
    social.setAccountId("kakao_" + p.id);
    social.setUserName(p.nickname != null ? p.nickname : "카카오유저");
    social.setNickName(p.nickname);
    
    String email = (p.email != null && !p.email.isEmpty()) ? p.email : ("kakao_" + p.id + "@no-email.local");
    social.setUserEmail(email);
    
    social.setProvider("kakao");
    social.setProviderId(p.id);
    social.setProfileImageKey(p.profileImage);

    userDAO.insertSocialUser(social);
    return userDAO.findByProvider("kakao", p.id);
  }
}