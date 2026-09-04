package org.puppit.service;

import java.util.List;

import org.puppit.model.dto.IamportCancelRequest;
import org.puppit.model.dto.OrderStatus;
import org.puppit.model.dto.PaymentInfo;
import org.puppit.model.dto.PointDTO;
import org.puppit.model.dto.RefundRequest;
import org.puppit.model.dto.RefundResult;
import org.puppit.model.dto.VerifyResultDTO;
import org.puppit.repository.PointDAO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Transactional
@RequiredArgsConstructor
@Service
public class PointServiceImpl implements PointService {

  private final PointDAO pointDAO;
  private final IamPortService iamPortService;

  @Override
  @Transactional
  public VerifyResultDTO verifyAndChargeByImpUid(Integer uid, String impUid) {
    // pg 조회
    PaymentInfo pg = iamPortService.getPaymentInfoByImpUid(impUid);
    // 결제 정보의 status가 "paid"가 아니라면
    if(!"paid".equalsIgnoreCase(pg.getStatus())) {
      return VerifyResultDTO.fail("NOT_PAID");
    }
    
    // DB 주문 정보 조회
    PointDTO pointDTO = pointDAO.findByMerchantUidForUpdate(pg.getMerchantUid())
        .orElseThrow(() -> new IllegalStateException("ORDER_NOT_FOUND"));
    
    // 소유권/상태/금액 검증
    if(!pointDTO.getUserId().equals(uid)) return VerifyResultDTO.fail("OWNER_MISMATCH");
    if(!pointDTO.getChargeStatus().equals(OrderStatus.PENDING)) return VerifyResultDTO.fail("INVALID_STATE");
    if(pointDTO.getPointChargeAmount().compareTo(pg.getAmount()) != 0) return VerifyResultDTO.fail("AMOUNT_MISMATCH");
    
    // 상태 전이 + 적립(멱등)
    
    try {
      boolean resultRecordUpdate = pointDAO.updatePointRecord(pg.getMerchantUid(), OrderStatus.PAID) == 1;
      boolean resultPointUpdate = pointDAO.updatePoint(uid, pg.getAmount()) == 1;
      
      if(!resultPointUpdate) {
        throw new RuntimeException("포인트 잔액 충전 실패");
      }
      if(!resultRecordUpdate) {
        throw new RuntimeException("포인트 충전내역 업데이트 실패");
      }
      
    } catch (Exception e) {
      log.error("verifyAndCharge FAILED", e);
      throw new RuntimeException("포인트 충전 중 오류가 발생했습니다.", e);
    }
    return VerifyResultDTO.ok();
  }
  
  @Override
  public List<PointDTO> selectPointRecordById(Integer userId) {
    List<PointDTO> result = pointDAO.selectPointRecordById(userId);
    return result;
  }

  @Override
  public boolean insertChargeRecord(Integer uid, Integer amount, String uuid) {
    Integer result = pointDAO.insertChargeRecord(uid, amount, uuid);
    return result == 1;
  }

  @Override
  public void updateStatusToFailed(String merchantUid) {
    pointDAO.updatePointRecord(merchantUid, OrderStatus.FAILED);
  }

  @Override
  @Transactional
  public RefundResult refund(Integer uid, RefundRequest req) {
    PointDTO pointDTO = pointDAO.findByMerchantUidForUpdate(req.getMerchantUid())
        .orElseThrow(() -> new IllegalStateException("ORDER_NOT_FOUND"));
    // 소유권 or 상태 체크
    if(!pointDTO.getUserId().equals(uid)) throw new SecurityException("OWNER_MISMATCH");
    if(pointDTO.getChargeStatus() != OrderStatus.PAID) throw new IllegalStateException("NOT_REFUNDABLE_STATE");
    
    iamPortService.cancelPayment(IamportCancelRequest.builder()
        .merchantUid(pointDTO.getPointChargeOrderNumber())
        .amount(pointDTO.getPointChargeAmount())
        .reason(req.getReason())
        .build());
    int totalPaid = pointDTO.getPointChargeAmount();
    pointDAO.updateRefundInfo(pointDTO.getPointChargeOrderNumber(), OrderStatus.CANCELLED);
    pointDAO.updatePoint(pointDTO.getUserId(), -totalPaid);
    
    return new RefundResult(true, OrderStatus.CANCELLED, "환불 완료", totalPaid, null);
  }
  
  

  
  
}