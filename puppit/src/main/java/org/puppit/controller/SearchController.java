  package org.puppit.controller;

import java.util.List;
import java.util.stream.Collectors;

import org.puppit.model.dto.SearchLogDTO;
import org.puppit.service.SearchLogService;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import lombok.RequiredArgsConstructor;

@Controller   // 브라우저에서 들어오는 요청(예: /search/top)을 받아서, Service → DAO → DB 흐름을 타고 다시 JSP 같은 뷰를 반환하는 역할을 하겠다고 선언
@RequiredArgsConstructor // final 붙은 필드를 자동으로 생성자 주입.
@RequestMapping("/search") // @RequestMapping("/search")가 붙으면 컨트롤러 안의 모든 메서드는 기본 경로 /search 밑에서 동작하게 됨.
public class SearchController {
  
  private final SearchLogService searchLogService;
  
  // 인기 검색어 조회
  @GetMapping(value = "/top", produces = MediaType.APPLICATION_JSON_VALUE)
  @ResponseBody
  public List<String> getTopKeywords() {
    return searchLogService.getTopKeywords().stream()
            .map(SearchLogDTO::getSearchKeyword)   // DTO → String
            .filter(kw -> kw != null && !kw.trim().isEmpty())
            .collect(Collectors.toList());         
}
}
