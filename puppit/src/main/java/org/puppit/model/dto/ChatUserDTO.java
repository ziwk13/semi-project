package org.puppit.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class ChatUserDTO {

	private Integer userId;
	private String accountId;
	private String userName;
	private String nickName;
	
	@Override
	public String toString() {
		return "ChatUserDTO [userId=" + userId + ", accountId=" + accountId + ", userName=" + userName + ", nickName="
				+ nickName + "]";
	}
	

  
  
}

