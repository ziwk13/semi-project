package org.puppit.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class ChatMessageSelectDTO {
	private Integer userId;
	private int roomId;
	private String loginUserId;
	private Integer productId; // 추가된 필드
}
