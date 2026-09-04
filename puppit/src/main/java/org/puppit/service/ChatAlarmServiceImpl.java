package org.puppit.service;

import java.util.Map;

import org.puppit.model.dto.AlarmReadDTO;
import org.puppit.repository.AlarmDAO;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class ChatAlarmServiceImpl implements ChatAlarmService {

	private final AlarmDAO alarmDAO;
	
	
	@Override
	public Integer readAlarm(Integer messageId) {
		// TODO Auto-generated method stub
		return null;
	}


	@Override
	public int markAsRead(AlarmReadDTO dto) {
	 return alarmDAO.updateReadStatus(dto);
		
	}


	@Override
	public int markAllAsRead(Integer roomId, Integer userId, Integer groupCount) {
	 return alarmDAO.updateAllReadStatus(roomId, userId, groupCount);
	}
	
	@Override
	public Map<Integer, Integer> getUnreadCountsForUser(Integer userId) {
	    // 쿼리: SELECT room_id, COUNT(*) FROM alarm WHERE user_id = :userId AND is_read = 1 GROUP BY room_id
	    return alarmDAO.getUnreadCountsForUser(userId);
	}

}
