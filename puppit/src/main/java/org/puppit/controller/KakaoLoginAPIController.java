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
import org.puppit.service.KakaoLoginService;
import org.puppit.service.UserService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
@RequestMapping("/auth/kakao")
public class KakaoLoginAPIController {

  private final KakaoLoginService kakaoLoginService;
  private final UserService userService;

  @Value("${kakao.rest.api.key}")
  private String kakaoApiKey;
  @Value("${kakao.redirect.uri}")
  private String kakaoRedirectUri;

  @GetMapping("/login")
  public String kakaoLoginForm(Model model) {
    model.addAttribute("kakaoApiKey", kakaoApiKey);
    model.addAttribute("redirectUri", kakaoRedirectUri);
    return "user/login";
  }
  @GetMapping("/callback")
  public String kakaoCallback(@RequestParam String code,
                              HttpServletRequest request,
                              RedirectAttributes redirectAttr) {
    try {
      // 1) code -> access_token (토큰 받기)
      String accessToken = kakaoLoginService.getAccessToken(code);

      // 2) token -> userInfo (사용자 정보 받기)
      Map<String,Object> userInfo = kakaoLoginService.getUserInfo(accessToken);

      // 3) DB upsert -> 우리 서비스 UserDTO (비번 없음)
      UserDTO loginResult = kakaoLoginService.upsertAndGetUser(userInfo);

      if(loginResult == null) {
        redirectAttr.addFlashAttribute("error", "Puppit에 오신것을 환영 합니다");
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
    } catch (Exception e) {
      e.printStackTrace();
      redirectAttr.addFlashAttribute("error", "카카오 로그인 중 오류가 발생했습니다.");
      return "redirect:/user/login";
    }
  }
}
