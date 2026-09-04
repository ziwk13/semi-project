package org.puppit.repository;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.puppit.model.dto.SearchLogDTO;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class SearchLogDAO {

  
  private final SqlSession sqlSession;


  // 인기 검색어 조회
  public List<SearchLogDTO> selectTopKeywords() {
    return sqlSession.selectList("search.selectTopKeywords");
  }
}
