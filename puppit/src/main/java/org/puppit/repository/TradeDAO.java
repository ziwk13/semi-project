package org.puppit.repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.mybatis.spring.SqlSessionTemplate;
import org.puppit.model.dto.TradeDTO;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class TradeDAO {
  
  private final SqlSessionTemplate sst;
  
  // 결제 내역 저장
  public int insertTrade(Integer buyerId, Integer sellerId, Integer productId, String status) {
    
    Map<String, Object> paraMap = new HashMap<>();
    String uuid = UUID.randomUUID().toString();
    paraMap.put("uuid", uuid);
    paraMap.put("buyerId", buyerId);
    paraMap.put("sellerId", sellerId);
    paraMap.put("productId", productId);
    paraMap.put("status", status);
    
    System.out.println("DAO다오" + "buyerId: " + buyerId + ", sellerId: " + sellerId);
    
    return sst.insert("mybatis.mapper.tradeMapper.insertTrade", paraMap);
    
  }
  
  // dto 불러오기
  public List<TradeDTO> selectTradeById(Integer userId) {
    Map<String, Object> paraMap = new HashMap<>();
    paraMap.put("userId", userId);
    
    return sst.selectList("mybatis.mapper.tradeMapper.selectTradeById", paraMap);
  }
  // 상품상태코드 3(판매완료)로 변경
  public Integer updateProductStatus(Integer productId) {
    return sst.update("mybatis.mapper.tradeMapper.updateProductStatus", productId);
  }

}
