package org.puppit.model.dto;

import lombok.Getter;
import lombok.Setter;
import java.util.List;

@Getter
@Setter
public class CursorPage<T> {
    private List<T> items;     // 이번에 내려줄 데이터
    private Long nextCursorId;   // 다음 요청 시 사용할 커서 (마지막 아이템의 id 등)
    private String nextCursorCreatedAt;
    private boolean hasNext;   // 다음 페이지가 있는지 여부
}
