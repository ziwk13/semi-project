package org.puppit.controller;

import org.puppit.model.dto.ProductDTO;
import org.puppit.model.dto.UserDTO;
import org.puppit.service.ProductService;
import org.puppit.service.TradePaymentService;
import org.puppit.service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.RequiredArgsConstructor;

@RequestMapping("/order")
@Controller
@RequiredArgsConstructor
public class OrderController {
  
  private final TradePaymentService tps;
  private final ProductService productService;
  private final UserService userService;
  
  @GetMapping("/pay")
  public String orderForm(@RequestParam("buyerId") Integer buyerId, 
                          @RequestParam("sellerId") Integer sellerId, 
                          @RequestParam("chatSellerAccountId") String chatSellerAccountId, 
                          @RequestParam("productId") Integer productId, 
                          @RequestParam("quantity") Integer quantity, 
                          Model model,
                          RedirectAttributes rttr) {
    
    ProductDTO productDTO = productService.getProductById(productId);
    Integer price = productDTO.getProductPrice();
    String productName = productDTO.getProductName();
    Integer amount = price * quantity;
    Integer statusId = productDTO.getStatusId();
    
    UserDTO userDTO = userService.getUserId(String.valueOf(chatSellerAccountId));
    String userNickname = userDTO.getNickName();
    
    if(statusId == 3) {
      rttr.addFlashAttribute("msg", "이미 판매완료된 상품입니다.");
      return "redirect:/";
    }

    model.addAttribute("buyerId", buyerId);
    model.addAttribute("sellerId", sellerId);
    model.addAttribute("productId", productId);
    model.addAttribute("quantity", quantity);
    model.addAttribute("price", price);
    model.addAttribute("amount", amount);
    model.addAttribute("productName", productName);
    model.addAttribute("sellerNickname", userNickname);
    model.addAttribute("chatSellerAccountId", chatSellerAccountId);
    
    return "/payment/orderForm";
  }
  
  @PostMapping("/pay")
  public String order(@RequestParam("buyerId") Integer buyerId, 
                      @RequestParam("sellerId") Integer sellerId, 
                      @RequestParam("productId") Integer productId, 
                      @RequestParam("quantity") Integer quantity,
                      @RequestParam("chatSellerAccountId") String chatSellerAccountId,
                      RedirectAttributes rttr) {
    
    ProductDTO p = productService.getProductById(productId);
    int price = p.getProductPrice();
    int amount = price * quantity; 
    
    try {
      tps.payAndRecord(buyerId, sellerId, productId, quantity, amount);
      rttr.addFlashAttribute("msg", "결제가 완료되었습니다.");
      
      return "redirect:/";
      
    } catch (RuntimeException e) {
      rttr.addFlashAttribute("msg", e.getMessage());
      
      rttr.addAttribute("buyerId", buyerId);
      rttr.addAttribute("sellerId", sellerId);
      rttr.addAttribute("productId", productId);
      rttr.addAttribute("quantity", quantity);
      rttr.addAttribute("chatSellerAccountId", chatSellerAccountId);
      
      return "redirect:/order/pay";
    }
  }
}
