package org.puppit.model.dto;

import org.springframework.messaging.handler.annotation.SendTo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProductSearchRequestDTO {

  private String q;        // 검색어 q=query로 검색기능 할때 사용
  private Long cursor;     // 커서(마지막 product_id)
  private Integer size;    // 요청당 가져올 개수 (null이면 기본 20)
}
