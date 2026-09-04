package org.puppit.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class AlarmDuplicationDTO {
	private Integer roomId;
	private Integer userId;
	private String chatMessage;
	
	@Override
	public String toString() {
		return "AlarmDuplicationDTO [roomId=" + roomId + ", userId=" + userId + ", chatMessage=" + chatMessage + "]";
	}
	
}
