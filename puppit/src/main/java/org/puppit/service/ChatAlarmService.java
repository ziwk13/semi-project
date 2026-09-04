package org.puppit.service;

import java.util.Map;

import org.puppit.model.dto.AlarmReadDTO;

public interface ChatAlarmService {
	public Integer readAlarm(Integer messageId);
	public int markAsRead(AlarmReadDTO dto);
	public int markAllAsRead(Integer roomId, Integer userId, Integer groupCount);
	public Map<Integer, Integer> getUnreadCountsForUser(Integer userId);
	
}
