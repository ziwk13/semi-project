package org.puppit.controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.puppit.model.dto.UserDTO;
import org.puppit.model.dto.UserStatusDTO;
import org.puppit.service.S3Service;
import org.puppit.service.UserService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequestMapping("/user")
@RequiredArgsConstructor
@Slf4j
@Controller
public class UserController {
  
  private final UserService userService;
  private final S3Service s3Service;
  private final AmazonS3 amazonS3;

  @Value("${aws.s3.bucket}")
  private String BUCKET;
  @Value("${kakao.rest.api.key}")
  private String kakaoApiKey;
  @Value("${kakao.redirect.uri}")
  private String kakaoRedirectUri;
  
  
  @SuppressWarnings("unchecked")
  @GetMapping("/mypage")
  public String myPage(HttpSession session, Model model) {
    Object attr = session.getAttribute("sessionMap");
    Map<String, Object> map = (Map<String, Object>)attr;
    Object accountId = map.get("accountId");
    String accountIdResult = accountId.toString();
    UserDTO userDTO = userService.getUserId(accountIdResult);
    model.addAttribute("user", userDTO);
    return "user/mypage";
  }
  
  // 회원가입 폼 보여주기
  @GetMapping("/signup")
  public String showSignupForm() {
      return "user/signup";  
  }
  // 회원가입
  @PostMapping("/signup")
  public String signUp(UserDTO user, RedirectAttributes redirectAttr) {
    String userEmail = user.getUserEmail() == null ? null : user.getUserEmail().trim().toLowerCase();
    String accountId = user.getAccountId() == null ? null : user.getAccountId().trim();
    String nickName = user.getNickName() == null ? null : user.getNickName().trim();
    
    if(!userService.isAccountIdAvailable(accountId)
        || !userService.isNickNameAvailable(nickName)
        || !userService.isUserEmailAvailable(userEmail)) {
      redirectAttr.addFlashAttribute("error", "올바른 정보를 입력 해주세요");
      return "redirect:/user/signup";
    }
    try {
      boolean signupResult = userService.signup(user);
      if(!signupResult) throw new IllegalStateException();
        // 회원가입 성공
        redirectAttr.addFlashAttribute("msg", "Puppit에 오신것을 환영 합니다");
        return "redirect:/";

      } catch (Exception e) {
        // 회원가입 실패
        redirectAttr.addFlashAttribute("error", "올바른 정보를 입력 해주세요");
        return "redirect:/user/signup";
      }
    }  
  // 회원 탈퇴
  @PostMapping("/delete")
  public String deleteAccount(HttpSession session,
                             @RequestParam("agreement") String agreement,
                             @RequestParam(value = "userPassword", required = false) String userPassword,
                             @SessionAttribute(name = "sessionMap", required = false) Map<String, Object> sessionMap,
                             RedirectAttributes redirectAttr) {

    // 로그인 여부부터 확인 — sessionMap이 null일 수 있으므로 get() 호출보다 먼저 체크
    if (sessionMap == null || sessionMap.get("userId") == null) {
      redirectAttr.addFlashAttribute("error", "로그인이 필요 합니다");
      return "redirect:/user/login";
    }
    Integer userId = (Integer) sessionMap.get("userId");

    if (!"회원 탈퇴 하겠습니다 이에 동의 합니다".equals(agreement)) {
      redirectAttr.addFlashAttribute("error", "동의 문구가 일치하지 않습니다");
      return "redirect:/user/profile";
    }

    // 비밀번호 로그인 사용자는 탈퇴 직전 현재 비밀번호를 재확인한다.
    // 카카오 등 소셜 로그인 사용자는 비밀번호가 없으므로 재확인을 건너뛴다(checkPwd와 동일한 정책).
    String provider = (String) sessionMap.get("provider");
    boolean isSocial = provider != null && !provider.isEmpty();
    if (!isSocial) {
      if (userPassword == null || userPassword.isBlank() || !userService.passwordCheck(userId, userPassword)) {
        redirectAttr.addFlashAttribute("error", "비밀번호가 일치하지 않습니다");
        return "redirect:/user/profile";
      }
    }

    boolean ok = userService.deleteMyAccount(userId);
    if(!ok) {
      redirectAttr.addFlashAttribute("error", "삭제에 실패 했습니다");
      return "redirect:/user/profile";
    }
    // 세션 초기화
    session.invalidate();
    redirectAttr.addFlashAttribute("msg", "Puppit 탈퇴가 완료 되었습니다. 감사합니다");
    return "redirect:/";
  }
  
  // 중복 검사
  @GetMapping("/check")
  public ResponseEntity<Void> check(UserDTO userDTO) {
    if (userDTO.getUserEmail() != null) {
      boolean ok = userService.isUserEmailAvailable(userDTO.getUserEmail().trim().toLowerCase());
      return ok ? ResponseEntity.ok().build() : ResponseEntity.status(HttpStatus.CONFLICT).build();
    }
    if (userDTO.getAccountId() != null) {
      boolean ok = userService.isAccountIdAvailable(userDTO.getAccountId().trim());
      return ok ? ResponseEntity.ok().build() : ResponseEntity.status(HttpStatus.CONFLICT).build();
    }
    if (userDTO.getNickName() != null) {
      boolean ok = userService.isNickNameAvailable(userDTO.getNickName().trim());
      return ok ? ResponseEntity.ok().build() : ResponseEntity.status(HttpStatus.CONFLICT).build();
    }
    return ResponseEntity.badRequest().build(); // 파라미터 없음
  }
  
  // 로그인 폼 보여주기
  @GetMapping("/login")
  public String loginForm(Model model) {
    model.addAttribute("kakaoApiKey", kakaoApiKey);
    model.addAttribute("redirectUri", kakaoRedirectUri);
    return "user/login";
  }
  // 로그인
  @PostMapping("/login")
  public String login( UserDTO user, HttpSession session, RedirectAttributes redirectAttr, HttpServletRequest request) {
    try {
      UserDTO loginResult = userService.login(user);

      if (loginResult == null) {
          // 실패: 아이디나 비밀번호가 틀림
          redirectAttr.addFlashAttribute("error", "아이디나 비밀번호를 확인 해주세요");
          return "redirect:/user/login";
      }
      
      HttpSession oldSession = request.getSession(false);
      if(oldSession != null) {
       oldSession.invalidate(); 
      }
      // 성공: 세션 저장 (db에서 가져온 loginResult 사용)
      Map<String, Object> sessionMap = new HashMap<String, Object>();
      sessionMap.put("userId", loginResult.getUserId());
      sessionMap.put("accountId", loginResult.getAccountId());
      sessionMap.put("userName", loginResult.getUserName());
      sessionMap.put("nickName", loginResult.getNickName());
      sessionMap.put("userEmail", loginResult.getUserEmail());
      
      session = request.getSession(true);
      session.setAttribute("sessionMap", sessionMap);
      
      // timeStamp 생성
      Date now = new Date();
      SimpleDateFormat stf = new SimpleDateFormat("yyyy/MM/dd HH:mm");
      String dateTimeStr = stf.format(now);
      Date date = stf.parse(dateTimeStr);
      Timestamp timestamp = new Timestamp(date.getTime());

      UserStatusDTO userLog = new UserStatusDTO(loginResult.getAccountId(), loginResult.getUserId(), timestamp);
      userService.insertLogStatus(userLog);
      String returnTo = (String) session.getAttribute("redirectAfterLogin");
      if(returnTo != null) {
        session.removeAttribute("redirectAfterLogin");
        return "redirect:" + returnTo;
      }
      return "redirect:/";
  } catch (Exception e) {
     e.printStackTrace();
     redirectAttr.addFlashAttribute("error", "로그인 중 오류가 발생했습니다.");
     return "redirect:/user/login";
  }
}
   // 로그 아웃
  @GetMapping("/logout")
  public String logout(HttpSession session) {
    session.invalidate();
    return "redirect:/";
  }
  // 아이디 찾기 폼
  @GetMapping("/find")
  public String findCheckForm() {
    return "user/find";
  }
  // 아이디 찾기
  @PostMapping("/find")
  public String findCheck(RedirectAttributes redirectAttr, UserDTO user) {
    String findId = userService.findAccountIdByUserNameUserEmail(user);
    if(findId == null) {
      redirectAttr.addFlashAttribute("msg", "입력하신 정보로 가입 된 회원 아이디는 존재하지 않습니다.");
      return "redirect:/user/find";
    } else {
      redirectAttr.addFlashAttribute("msg", findId + "입니다.");
      return "redirect:/user/login";
    }
  }
  // 비밀번호 변경 폼 (1단계: 아이디 입력)
  @GetMapping("/reset-password")
  public String changePassword() {
    return "user/find";
  }
  // 비밀번호 재설정 요청 — accountId만으로 토큰을 발급한다.
  // 계정 존재 여부와 무관하게 항상 같은 안내를 보여줘 계정 존재를 노출하지 않는다(user enumeration 방지).
  @PostMapping("/reset-password")
  public String requestPasswordReset(@RequestParam String accountId, RedirectAttributes redirectAttr) {
    if (accountId == null || accountId.isBlank()) {
      redirectAttr.addFlashAttribute("error", "아이디를 입력하세요");
      redirectAttr.addFlashAttribute("activeTab", "resetPw");
      return "redirect:/user/find";
    }
    String rawToken = userService.issuePasswordResetToken(accountId.trim());
    if (rawToken != null) {
      // TODO: 실제 서비스라면 가입 이메일로 링크를 발송한다. 메일 서버가 없는 데모 환경이라 로그로 대체.
      String resetLink = "/user/reset-password/confirm?token=" + rawToken;
      log.info("[비밀번호 재설정] accountId={} link={} (15분 후 만료)", accountId.trim(), resetLink);
    }
    redirectAttr.addFlashAttribute("msg",
        "입력하신 아이디로 재설정 링크를 보내드렸습니다. (데모 환경: 서버 로그에서 링크를 확인하세요)");
    return "redirect:/user/find";
  }
  // 비밀번호 재설정 폼 (2단계: 토큰으로 새 비밀번호 입력)
  @GetMapping("/reset-password/confirm")
  public String resetPasswordConfirmForm(@RequestParam String token, Model model) {
    model.addAttribute("token", token);
    return "user/resetPasswordConfirm";
  }
  // 비밀번호 재설정 확정 — 토큰 검증 후에만 비밀번호를 바꾼다.
  @PostMapping("/reset-password/confirm")
  public String resetPasswordConfirm(@RequestParam String token,
                                     @RequestParam String userPassword,
                                     RedirectAttributes redirectAttr) {
    boolean ok = userService.resetPasswordWithToken(token, userPassword);
    if (!ok) {
      redirectAttr.addFlashAttribute("error", "링크가 만료되었거나 이미 사용되었습니다. 다시 요청해 주세요");
      return "redirect:/user/find";
    }
    redirectAttr.addFlashAttribute("msg", "비밀번호가 변경 되었습니다 다시 로그인 해주세요");
    return "redirect:/user/login";
  }
  // mypage에서 profile 가기전 password 검사 페이지
  @GetMapping("/checkPassword")
  public String checkPwd(@SessionAttribute(name = "sessionMap", required = false) Map<String, Object> sessionMap) {
    
    // 로그인 가드
    if(sessionMap == null || sessionMap.get("userId") == null) {
      return "redirect:/user/login";
    }
    // 카카오 로그인시 비밀번호 재확인 필요 x
    String provider = (String)sessionMap.get("provider");
    
    if(provider != null && !provider.isEmpty()) {
      return "redirect:/user/profile";
    }
    return "user/checkPassword";
  }
  //mypage에서 profile 가기전 password 검사
  @PostMapping("/checkPassword")
  public String checkPwd(RedirectAttributes redirectAttr, 
                         @SessionAttribute(name = "sessionMap", required = false) Map<String, Object> sessionMap, 
                         @RequestParam("userPassword") String userPassword) {
    try {
      if(sessionMap == null || sessionMap.get("userId") == null) {
        redirectAttr.addFlashAttribute("msg", "로그인이 필요합니다");
        return "redirect:/user/login";
      }
      
      // 카카오 로그인시 비밀번호 재확인 필요 x
      String provider = (String)sessionMap.get("provider");
      
      if(provider != null && !provider.isEmpty()) {
        return "redirect:/user/profile";
      }

      Integer userId = (Integer) sessionMap.get("userId"); // <-- 키는 "userId"

      boolean ok = userService.passwordCheck(userId, userPassword);
      if (!ok) {
        redirectAttr.addFlashAttribute("msg", "비밀번호가 일치하지 않습니다");
        return "redirect:/user/checkPassword";
      }
      return "redirect:/user/profile";
    } catch (Exception e) {
      e.printStackTrace();
      redirectAttr.addFlashAttribute("error", "오류가 발생 했습니다");
      return "redirect:/user/mypage";
    }
  }
  // 프로필 페이지
  @GetMapping("/profile")
  public String profileForm() {
    return "user/profile";
  }
  // 프로필 수정
  @PostMapping("/profile")
  public String profileEdit(RedirectAttributes rttr,
                            HttpSession session,
                            HttpServletRequest request,
                            @RequestParam("accountId") String accountId,
                            @RequestParam("userName") String userName,
                            @RequestParam("nickName") String nickName,
                            @RequestParam("userEmail") String userEmail) {
    
    @SuppressWarnings("unchecked")
    Map<String, Object> sessionMap = (Map<String, Object>)session.getAttribute("sessionMap");
    String prevAccountId = (String) sessionMap.get("accountId");
    UserDTO user = userService.getUserId(prevAccountId);
    user.setAccountId(accountId);
    user.setUserName(userName);
    user.setNickName(nickName);
    user.setUserEmail(userEmail);
    Map<String, Object> map = new HashMap<>();
    map.put("user", user);
    map.put("prevAccountId", prevAccountId);
    boolean result = userService.updateUser(map);
    
    rttr.addFlashAttribute("msg", result ? "프로필 수정 성공" : "프로필 수정 실패");
    
    UserDTO newUser = userService.getUserId(accountId);
    
    Map<String, Object> newSessionMap = new HashMap<String, Object>();
    newSessionMap.put("userId", newUser.getUserId());
    newSessionMap.put("accountId", newUser.getAccountId());
    newSessionMap.put("userName", newUser.getUserName());
    newSessionMap.put("nickName", newUser.getNickName());
    newSessionMap.put("userEmail", newUser.getUserEmail());
    
    session = request.getSession(true);
    session.setAttribute("sessionMap", newSessionMap);
    
    return "redirect:/";
  }
  // 프로필 이미지 수정
  @PostMapping("/profile/image")
  public String changeProfileimage(@SessionAttribute("sessionMap") Map<String, Object> sessionMap,
                                   @RequestParam("file") MultipartFile file,
                                   RedirectAttributes rttr) {
    
    Integer userId = (Integer) sessionMap.get("userId");
    if(userId == null) return "redirect:/login";
    try {
      // ex) "profile/123"
      String folder = "profile/" + userId;
      Map<String, String> uploaded = s3Service.uploadFile(file, folder);
      String newKey = uploaded.get("fileName"); // ex) profile/123/uuid_filename.jpg
      
      // 기존 키 조회 후 삭제(옵션)
      String oldKey = userService.getProfileImageKey(userId).getProfileImageKey();
      if (oldKey != null && !oldKey.isBlank()) {
          try {
              amazonS3.deleteObject(BUCKET, oldKey);
              // 필요 시만 삭제
              // amazonS3.deleteObject(bucket, oldKey);
          } catch (Exception ignore) {}
      }

      // DB에 새 키 저장 (URL 말고 Key를 저장하세요)
      userService.updateProfileImageKey(userId, newKey);

      rttr.addFlashAttribute("msg", "프로필 이미지가 변경되었습니다.");
      amazonS3.setObjectAcl(BUCKET, newKey, CannedAccessControlList.PublicRead);
    } catch (Exception e) {
      rttr.addFlashAttribute("msg", "업로드 실패" + e.getMessage());
    }
    
    return "redirect:/user/mypage";                                   
  }
}
