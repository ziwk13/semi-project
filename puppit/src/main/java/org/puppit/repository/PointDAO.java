package org.puppit.repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.mybatis.spring.SqlSessionTemplate;
import org.puppit.model.dto.OrderStatus;
import org.puppit.model.dto.PointDTO;
import org.puppit.model.dto.TradeDTO;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class PointDAO {
  
  private final SqlSessionTemplate sst;
  
  // 포인트 충전 OR 상품 판매
  public int updatePoint(Integer uid, Integer amount) {
    Map<String, Object> paraMap = new HashMap<>();
    paraMap.put("uid", uid);
    paraMap.put("amount", amount);
    
    return sst.update("mybatis.mapper.pointMapper.updatePoint", paraMap);
  }
  
  // 상품 구매
  public int decreaseIfEnough(Integer uid, Integer amount) {
    Map<String, Object> paraMap = new HashMap<>();
    paraMap.put("uid", uid);
    paraMap.put("amount", amount);
    
    return sst.update("mybatis.mapper.pointMapper.decreaseIfEnough", paraMap);
  }
  
  // 충전 내역 상태 업데이트
  public int updatePointRecord(String merchantUid, OrderStatus status) {
    Map<String, Object> paraMap = new HashMap<>();
    paraMap.put("status", status);
    paraMap.put("merchantUid", merchantUid);
    
    return sst.update("mybatis.mapper.pointMapper.updatePointRecord", paraMap);
  }
  
  //포인트 충전 내역 기록 
  public Integer insertChargeRecord(Integer uid, Integer amount, String uuid) {
    Map<String, Object> paraMap = new HashMap<>();
    paraMap.put("uid", uid);
    paraMap.put("amount", amount);
    paraMap.put("uuid", uuid);
    
    return sst.insert("mybatis.mapper.pointMapper.insertPointRecord", paraMap);
  }
  
  //dto 불러오기
  public List<PointDTO> selectPointRecordById(Integer userId) {
    Map<String, Object> paraMap = new HashMap<>();
    paraMap.put("userId", userId);
    
    return sst.selectList("mybatis.mapper.pointMapper.selectPointRecordById", paraMap);
  }
  
  // DB 조회
  public Optional<PointDTO> findByMerchantUidForUpdate(String merchantUid) {
    PointDTO pointDTO = sst.selectOne("mybatis.mapper.pointMapper.findByMerchantUidForUpdate", merchantUid);
    return Optional.ofNullable(pointDTO);
  }
  
  // 포인트 환불
  public Integer updateRefundInfo(String merchantUid, OrderStatus status) {
    Map<String, Object> paraMap = new HashMap<>();
    paraMap.put("merchantUid", merchantUid);
    paraMap.put("status", status);
    
    return sst.update("mybatis.mapper.pointMapper.updateRefundInfo", paraMap);
  }

}
