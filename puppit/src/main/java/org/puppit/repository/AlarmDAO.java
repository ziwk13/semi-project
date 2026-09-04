package org.puppit.repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.puppit.model.dto.AlarmDuplicationDTO;
import org.puppit.model.dto.AlarmReadDTO;
import org.puppit.model.dto.NotificationDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class AlarmDAO {
	 @Autowired
     private SqlSessionTemplate sqlSessionTemplate;

	 public int countDuplicateAlarm(AlarmDuplicationDTO alarmDuplicationDTO) {
	     return sqlSessionTemplate.selectOne("mybatis.mapper.alarmMapper.countDuplicateAlarm", alarmDuplicationDTO);
	 }

	public int updateReadStatus(AlarmReadDTO dto) {
		return sqlSessionTemplate.update("mybatis.mapper.alarmMapper.updateReadStatus", dto);
		
	}

	public int updateAllReadStatus(Integer roomId, Integer userId, Integer groupCount) {
		 Map<String, Object> param = new HashMap<>();
	     param.put("roomId", roomId);
	     param.put("userId", userId);
	     param.put("count", groupCount);
	     return sqlSessionTemplate.update("mybatis.mapper.alarmMapper.updateAllReadStatus", param);
	}

	 /**
     * 각 채팅방별 미읽은 메시지 개수를 반환
     * @param userId 로그인한 사용자 id
     * @return Map<roomId, unreadCount>
     */
    public Map<Integer, Integer> getUnreadCountsForUser(int userId) {
        List<Map<String, Object>> resultList = sqlSessionTemplate.selectList(
            "mybatis.mapper.alarmMapper.getUnreadCountsForUser", userId);

        Map<Integer, Integer> unreadCountMap = new HashMap<>();
        for (Map<String, Object> row : resultList) {
            Integer roomId = ((Number) row.get("room_id")).intValue();
            Integer count = ((Number) row.get("unread_count")).intValue();
            unreadCountMap.put(roomId, count);
        }
        for (Map.Entry<Integer, Integer> entry : unreadCountMap.entrySet()) {
            System.out.println("room_id: " + entry.getKey() + ", unread_count: " + entry.getValue());
        }
        return unreadCountMap;
    }

}
