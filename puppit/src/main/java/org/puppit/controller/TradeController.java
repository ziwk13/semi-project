package org.puppit.controller;

import java.util.List;

import org.puppit.model.dto.TradeDTO;
import org.puppit.service.TradePaymentService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class TradeController {
  
  private final TradePaymentService tradeService;
  
  @GetMapping("/trade/history")
  public String getTradeHistory(Integer userId, 
                                String type, 
                                Model model) {
    List<TradeDTO> tradeDTOs = tradeService.selectTradeById(userId);
    model.addAttribute("tradeDTOs", tradeDTOs);
    
    return (type.equals("buy") ? "trade/buyRecord" : type.equals("sell") ? "trade/sellRecord" : "/");
  }
  
 
}
