package org.puppit.service;

import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.puppit.model.dto.UserDTO;

public interface KakaoLoginService {

  @Mapper
  String getAccessToken(String code);
  Map<String, Object> getUserInfo(String accessToken);
  UserDTO upsertAndGetUser(Map<String,Object> kakaoUserInfo);
}
