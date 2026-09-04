package org.puppit.service;

import java.util.HashMap;
import java.util.Map;

import org.puppit.model.dto.IamportCancelRequest;
import org.puppit.model.dto.IamportCancelResponse;
import org.puppit.model.dto.PaymentInfo;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class IamPortService {
    private final String API_KEY;
    private final String API_SECRET;
    private final RestTemplate restTemplate = new RestTemplate();

    public IamPortService(@Value("${iamport.api.key}") String API_KEY,
                          @Value("${iamport.api.secret}") String API_SECRET) {
      this.API_KEY = API_KEY;
      this.API_SECRET = API_SECRET;
    }
    // 1. 아임포트 access_token 발급
    private String getAccessToken() {
        String url = "https://api.iamport.kr/users/getToken";

        Map<String, String> body = new HashMap<>();
        body.put("imp_key", API_KEY);
        body.put("imp_secret", API_SECRET);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, String>> entity = new HttpEntity<>(body, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);

        Map responseBody = response.getBody();
        Map<String, Object> responseData = (Map<String, Object>) responseBody.get("response");

        return (String) responseData.get("access_token");
    }

    // 2. 결제정보 조회 (imp_uid로)
    public PaymentInfo getPaymentInfoByImpUid(String impUid) {
      String accessToken = getAccessToken();

      HttpHeaders headers = new HttpHeaders();
      headers.set("Authorization", accessToken);

      HttpEntity<Void> entity = new HttpEntity<>(headers);
      String url = "https://api.iamport.kr/payments/" + impUid;

      ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);
      Map body = response.getBody();

      // PortOne 표준: code == 0 이면 정상
      Object code = (body != null) ? body.get("code") : null;
      if (!(code instanceof Number) || ((Number) code).intValue() != 0) {
          return null;
      }

      Map<String, Object> resp = (Map<String, Object>) body.get("response");
      if (resp == null) {
          return null;
      }

      Number amountNum = (Number) resp.get("amount");
      String merchantUid = (String) resp.get("merchant_uid");
      String status = (String) resp.get("status"); // paid|ready|failed|cancelled...
      Integer amount = (amountNum != null) ? amountNum.intValue() : null;

      return new PaymentInfo(status, merchantUid, amount);
    }
    
    // 결제 취소
    public IamportCancelResponse cancelPayment(IamportCancelRequest req) {
      String token = getAccessToken();
      
      HttpHeaders headers = new HttpHeaders();
      headers.setContentType(MediaType.APPLICATION_JSON);
      headers.setBearerAuth(token);
      
      Map<String, Object> payload = new HashMap<>();
      if(req.getMerchantUid() != null) payload.put("merchant_uid", req.getMerchantUid());
      if (req.getAmount() != null) payload.put("amount", req.getAmount()); 
      if (req.getReason() != null) payload.put("reason", req.getReason());
      if (req.getChecksum() != null) payload.put("checksum", req.getChecksum()); 
      
      HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
      ResponseEntity<Map> res = restTemplate.postForEntity(
          "https://api.iamport.kr/payments/cancel", entity, Map.class);
      
      if (!"0".equals(String.valueOf(res.getBody().get("code")))) {
        throw new IllegalStateException("IAMPORT_CANCEL_FAIL: " + res.getBody().get("message"));
      }
      Map response = (Map) res.getBody().get("response");

      // 필요한 필드만 매핑
      IamportCancelResponse out = new IamportCancelResponse();
      out.setCancelledAt((Integer) response.get("cancelled_at"));
      out.setReceiptUrl((String) response.get("receipt_url"));
      return out;

    }
}
