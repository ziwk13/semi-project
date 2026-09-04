package org.puppit.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class ChatMessageSearchDTO {
	private Integer loginUserId;
	private Integer roomId;
	@Override
	public String toString() {
		return "ChatMessageSearchDTO [loginUserId=" + loginUserId + ", roomId=" + roomId + "]";
	}
	
	
	
}
