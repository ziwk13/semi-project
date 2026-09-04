package org.puppit.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.puppit.model.dto.PointDTO;
import org.puppit.model.dto.RefundRequest;
import org.puppit.model.dto.RefundResult;
import org.puppit.model.dto.VerifyResultDTO;
import org.puppit.service.PointService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.SessionAttribute;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequiredArgsConstructor
@RequestMapping("/payment")
public class PointController {
  
  private final PointService pointService;
  
  @GetMapping("/history")
  public String getPaymentHistory(@SessionAttribute Map<String, Object> sessionMap, Model model) {
    Integer userId = (Integer) sessionMap.get("userId");
    List<PointDTO> pointDTOs = pointService.selectPointRecordById(userId);
    model.addAttribute("pointDTOs", pointDTOs);
    return "trade/chargeRecord";
  }
  
  // 결제창 화면
  @GetMapping("/paymentForm")
  public String paymentForm() {
    return "/payment/paymentForm";
  }
   
  // impUid로 결제 정보 검증 및 포인트 업데이트
  @PostMapping(value = "/verify", produces = "application/json")
  @ResponseBody
  public Map<String, Object> verifyPayment(
      @RequestBody Map<String, Object> data,
      @SessionAttribute("sessionMap") Map<String, Object> sessionMap) {
   
    String impUid = (String) data.get("imp_uid");
    Integer uid = (Integer)sessionMap.get("userId");

    VerifyResultDTO r = pointService.verifyAndChargeByImpUid(uid, impUid);
    return Map.of("success", r.isSuccess(), "message", r.getMessage());
  }
    
  // 주문번호 생성 및 DB 저장 
  @PostMapping(value="/orders", produces="application/json")
  @ResponseBody
  public Map<String, Object> makeMerchantUid(@RequestBody Map<String, Object> data,
                                             @SessionAttribute("sessionMap") Map<String, Object> sessionMap) {
    Integer uid  = (Integer) sessionMap.get("userId");
    Integer amount = Integer.parseInt(data.get("amount").toString());
    String uuid = UUID.randomUUID().toString();
    
    pointService.insertChargeRecord(uid, amount, uuid);
    
    Map<String, Object> map = new HashMap<>();
    map.put("merchant_uid", uuid);
    
    return map;
  }
  
  // 결제 실패한 경우 DB 업데이트
  @PostMapping("/fail")
  @ResponseBody
  public String updateFailPointCharge(@RequestBody Map<String, Object> body) {
    String merchantUid = body.get("merchantUid").toString();
    pointService.updateStatusToFailed(merchantUid);
    return "ok";
  }
  
  // 결제 취소
  @PostMapping("/refund")
  public ResponseEntity<?> refund(
      @RequestBody RefundRequest req,
      @SessionAttribute("sessionMap") Map<String, Object> sessionMap) {

    Integer uid = (Integer) sessionMap.get("userId");
    RefundResult result = pointService.refund(uid, req);
    return ResponseEntity.ok(result);
  }
 
  
}

