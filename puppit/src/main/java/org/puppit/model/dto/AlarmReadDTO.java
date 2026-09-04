package org.puppit.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
public class AlarmReadDTO {
	private Integer roomId;
	private Integer userId;
	private Integer chatReceiver;
	private Integer chatReceiverUserId;
	private Integer messageId;
}
