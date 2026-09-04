package org.puppit.service;

import java.util.List;

import org.puppit.model.dto.SearchLogDTO;
import org.puppit.repository.SearchLogDAO;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SearchLogServiceImpl implements SearchLogService {
  
  private final SearchLogDAO searchLogDAO;
  


  @Override
  public List<SearchLogDTO> getTopKeywords() {
    return searchLogDAO.selectTopKeywords();
  }

}
