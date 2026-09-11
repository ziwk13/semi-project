package org.puppit.controller;

import java.util.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.puppit.model.dto.UserDTO;
import org.puppit.model.dto.UserStatusDTO;
import org.puppit.service.KakaoAccountLinkException;
import org.puppit.service.KakaoLoginService;
import org.puppit.service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Slf4j
@Controller
@RequestMapping("/auth/kakao")
public class KakaoLoginAPIController {

  private final KakaoLoginService kakaoLoginService;
  private final UserService userService;

  // 카카오 로그인 버튼/링크는 user/login.jsp 에서 kauth.kakao.com 으로 직접 나간다
  // (UserController#loginForm 이 state 발급까지 포함해서 model을 채워줌).
  // 이 컨트롤러는 콜백(/auth/kakao/callback)만 처리한다.
  @GetMapping("/callback")
  public String kakaoCallback(@RequestParam String code,
                              @RequestParam(required = false) String state,
                              HttpServletRequest request,
                              RedirectAttributes redirectAttr) {
    try {
      // 0) state 검증 — 로그인 CSRF 방지. 발급 당시 세션에 심어둔 값과 일치해야 하고,
      //    1회용이라 검증 직후 세션에서 제거한다(재전송 방지).
      HttpSession stateSession = request.getSession(false);
      Object expectedState = (stateSession == null) ? null : stateSession.getAttribute("kakaoOAuthState");
      if (stateSession != null) {
        stateSession.removeAttribute("kakaoOAuthState");
      }
      if (expectedState == null || !expectedState.equals(state)) {
        log.warn("카카오 로그인 state 불일치 — CSRF 의심 요청 거부");
        redirectAttr.addFlashAttribute("error", "로그인 요청이 만료되었거나 올바르지 않습니다. 다시 시도해주세요.");
        return "redirect:/user/login";
      }

      // 1) code -> access_token (토큰 받기)
      String accessToken = kakaoLoginService.getAccessToken(code);

      // 2) token -> userInfo (사용자 정보 받기)
      Map<String,Object> userInfo = kakaoLoginService.getUserInfo(accessToken);

      // 3) DB upsert -> 우리 서비스 UserDTO (비번 없음)
      UserDTO loginResult = kakaoLoginService.upsertAndGetUser(userInfo);

      if(loginResult == null) {
        // (기존에는 성공 문구 "Puppit에 오신것을 환영 합니다"가 복붙돼 있던 실패 분기)
        redirectAttr.addFlashAttribute("error", "카카오 로그인에 실패했습니다. 다시 시도해주세요.");
        return "redirect:/user/login";
      }

      // ✅ 기존 폼 로그인과 동일하게 세션 구성
      HttpSession oldSession = request.getSession(false);
      if (oldSession != null) oldSession.invalidate();

      Map<String, Object> sessionMap = new HashMap<>();
      sessionMap.put("userId",    loginResult.getUserId());
      sessionMap.put("accountId", loginResult.getAccountId());
      sessionMap.put("userName",  loginResult.getUserName());
      sessionMap.put("nickName",  loginResult.getNickName());
      // 필요하면 provider도 참고용으로 넣기
      sessionMap.put("provider",  loginResult.getProvider()); // "kakao"

      HttpSession newSession = request.getSession(true);
      newSession.setAttribute("sessionMap", sessionMap);

      // ✅ 동일한 방식으로 상태 로그 기록
      Date now = new Date();
      SimpleDateFormat stf = new SimpleDateFormat("yyyy/MM/dd HH:mm");
      String dateTimeStr = stf.format(now);
      Date date = stf.parse(dateTimeStr);
      Timestamp ts = new Timestamp(date.getTime());

      UserStatusDTO userLog = new UserStatusDTO(loginResult.getAccountId(), loginResult.getUserId(), ts);
      userService.insertLogStatus(userLog);

      redirectAttr.addFlashAttribute("msg", "카카오 로그인 성공!");
      return "redirect:/";
    } catch (KakaoAccountLinkException e) {
      // 이메일이 겹치는 로컬 계정이 이미 있는 경우 — 자동 연동하지 않고 명시적으로 안내
      redirectAttr.addFlashAttribute("error", e.getMessage());
      return "redirect:/user/login";
    } catch (Exception e) {
      log.error("카카오 로그인 처리 중 오류", e);
      redirectAttr.addFlashAttribute("error", "카카오 로그인 중 오류가 발생했습니다.");
      return "redirect:/user/login";
    }
  }
}
