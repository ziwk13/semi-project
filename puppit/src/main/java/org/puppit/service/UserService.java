package org.puppit.service;

import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.puppit.model.dto.UserDTO;
import org.puppit.model.dto.UserStatusDTO;

@Mapper
public interface UserService {
  
  // 회원 가입
  boolean signup(UserDTO user); 
  // 회원 탈퇴
  boolean deleteMyAccount(Integer userId);
  UserDTO login(UserDTO user);
  // 아이디 중복 체크
  Boolean isAccountIdAvailable(String accountId);
  // 닉네임 중복 체크
  Boolean isNickNameAvailable(String nickName);
  // 이메일 중복 체크
  Boolean isUserEmailAvailable(String userEmail);
  // 로그인 정보
  Integer insertLogStatus(UserStatusDTO log);
  // accountId를 이용해 유저 정보 찾기
  UserDTO getUserId(String accountId);
  // accountId 찾기
  String findAccountIdByUserNameUserEmail(UserDTO user);
  // 비밀번호 변경
   Boolean updatePassword(String accountId, String userPassword);
  // 기존 비밀번호 확인
  Boolean passwordCheck(int userId, String userPassword);
  // 비밀번호 재설정 토큰 발급. accountId가 존재하지 않아도 null을 반환할 뿐 예외를 던지지 않는다
  // (컨트롤러는 존재 여부와 무관하게 항상 같은 안내 문구를 보여줘 계정 존재 여부 노출을 막는다)
  String issuePasswordResetToken(String accountId);
  // 토큰 검증 후 비밀번호 재설정. 토큰이 없거나/만료/이미 사용됐으면 false
  boolean resetPasswordWithToken(String rawToken, String newPassword);

  boolean updateUser(Map<String, Object> map);
  UserDTO getProfileImageKey(Integer userId);
  boolean updateProfileImageKey(Integer userId, String profileImageKey);
  
}