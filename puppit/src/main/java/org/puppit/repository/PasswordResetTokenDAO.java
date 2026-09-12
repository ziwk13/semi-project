package org.puppit.repository;

import org.mybatis.spring.SqlSessionTemplate;
import org.puppit.model.dto.PasswordResetTokenDTO;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Repository
public class PasswordResetTokenDAO {

  private final SqlSessionTemplate sqlSession;

  // 토큰 발급 (해시만 저장)
  public int insertToken(PasswordResetTokenDTO token) {
    return sqlSession.insert("mybatis.mapper.passwordResetTokenMapper.insertToken", token);
  }
  // 해시로 유효한(만료 전 + 미사용) 토큰 조회
  public PasswordResetTokenDTO findValidByHash(String tokenHash) {
    return sqlSession.selectOne("mybatis.mapper.passwordResetTokenMapper.findValidByHash", tokenHash);
  }
  // 1회성 보장: 사용 처리
  public int markUsed(Integer tokenId) {
    return sqlSession.update("mybatis.mapper.passwordResetTokenMapper.markUsed", tokenId);
  }
}
