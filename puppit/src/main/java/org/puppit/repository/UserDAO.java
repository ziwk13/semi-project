package org.puppit.repository;

import java.util.HashMap;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.puppit.model.dto.UserDTO;
import org.puppit.model.dto.UserStatusDTO;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Repository
public class UserDAO {
  
  private final SqlSessionTemplate sqlSession;
  
  // 회원가입
  public Integer userSignUp(UserDTO user) {
    return sqlSession.insert("mybatis.mapper.userMapper.userSignUp", user);
  }
  // 회원탈퇴
  public int softDeleteUser(Integer userId) {
    return sqlSession.update("mybatis.mapper.userMapper.softDeleteUser", userId);
  }
  // 로그인
  public UserDTO selectLogin(String accountId) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.selectLogin", accountId);
  }
  // 아이디 중복 확인
  public Integer countByAccountId(String accountId) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.countByAccountId", accountId);
  }
  // 닉네임 중복확인
  public Integer countByNickName(String nickName) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.countByNickName", nickName);
  }
  // 이메일 중복 확인
  public Integer countByEmail(String userEmail) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.countByEmail", userEmail);
  }
  // 로그인 정보
  public Integer insertLogStatus(UserStatusDTO log) {
    return sqlSession.insert("mybatis.mapper.userMapper.insertLogStatus", log);
  }
 
  // user 정보 조회 (accountId)
  public UserDTO getUserByAccountId(String accountId) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.getUserByAccountId", accountId);
  }
  // user 정보 조회 (user_id)
  public UserDTO getUserByUserId(Integer userId) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.getUserByUserId", userId);
  }
  // 아이디 찾기
  public String findAccountIdByNameAndEmail(UserDTO user) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.findAccountIdByNameAndEmail", user);
  }
  // 비밀번호 변경
  public Integer updatePasswordByAccountId(Map<String, Object> map) {
    return sqlSession.update("mybatis.mapper.userMapper.updatePasswordByAccountId", map);
  }
  public Integer updateUser(Map<String, Object> map) {
    return sqlSession.update("mybatis.mapper.userMapper.updateUser", map);
  }
  public Integer updateProfileImageKey(Map<String, Object> map) {
    return sqlSession.update("mybatis.mapper.userMapper.updateProfileImageKey", map);
  }
  public UserDTO findByProvider(String provider, Long providerId) {
    Map<String,Object> map = new HashMap<>();
    map.put("provider", provider);
    map.put("providerId", providerId);
    return sqlSession.selectOne("mybatis.mapper.userMapper.findByProvider", map);
  }
  public UserDTO findByEmail(String email) {
      return sqlSession.selectOne("mybatis.mapper.userMapper.findByEmail", email);
  }
  public int insertSocialUser(UserDTO user) {
      return sqlSession.insert("mybatis.mapper.userMapper.insertSocialUser", user);
  }
  public int linkProvider(UserDTO user) {
      return sqlSession.update("mybatis.mapper.userMapper.linkProvider", user);
  }
  public int updateSocialProfile(UserDTO user) {
      return sqlSession.update("mybatis.mapper.userMapper.updateSocialProfile", user);
  }
  public UserDTO getUserByNickName(String nickName) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.getUserByNickName", nickName);
   }
}
