package org.puppit.service;

import java.util.List;

import org.puppit.model.dto.SearchLogDTO;

public interface SearchLogService {

  // 인기 검색어
  List<SearchLogDTO> getTopKeywords();
  
}
