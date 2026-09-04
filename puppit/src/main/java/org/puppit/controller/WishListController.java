package org.puppit.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.puppit.model.dto.ProductAndImageDTO;
import org.puppit.model.dto.ProductDTO;
import org.puppit.model.dto.ProductImageDTO;
import org.puppit.model.dto.WishListDTO;
import org.puppit.service.WishListService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/wish")
public class WishListController {
  
  private final WishListService wishListService;
  
  @GetMapping("/list")
  public String wishList(Integer userId, Model model) {
    List<ProductAndImageDTO> productAndImages = wishListService.selectWishListProducts(userId);
    
    model.addAttribute("productAndImages", productAndImages);
    return "user/wishList";
  }
  
  @PostMapping("/delete")
  public String deleteWish(@RequestParam("productId") List<Integer> productIds,
                           @SessionAttribute("sessionMap") Map<String, Object> sessionMap,
                           RedirectAttributes rttr) {
    Integer userId = (Integer) sessionMap.get("userId"); 
    boolean result = wishListService.deleteWishListByUserAndProduct(userId, productIds);
    rttr.addFlashAttribute("msg", result ? "삭제되었습니다." : "이미 삭제되었거나 존재하지 않습니다.");
    return "redirect:/wish/list?userId=" + userId;
  }

  @PostMapping("/delete-all")
  public String deleteAll(@SessionAttribute("sessionMap") Map<String,Object> sessionMap) {
      Integer userId = (Integer) sessionMap.get("userId");
      wishListService.deleteAllWishListByUser(userId);
      return "redirect:/wish/list?userId=" + userId;
  }
  
  @PostMapping(value = "/toggle", produces = "application/json; charset=UTF-8")
  @ResponseBody
  public Map<String, Object> toggleWish(
          @RequestParam Integer productId,
          @SessionAttribute(value = "sessionMap", required = false) Map<String, Object> sessionMap) {

    try {
      if (sessionMap == null || sessionMap.get("userId") == null) {
          return Map.of("ok", false, "reason", "UNAUTH");
      }
      Integer userId = (Integer) sessionMap.get("userId");

      // 서비스 시그니처가 (userId, productId)이므로 그대로 호출 OK
      boolean added = wishListService.toggle(userId, productId);
      Integer wishCount = wishListService.getCount(productId);
      System.out.println("찜개수: " + wishCount);
      return Map.of("ok", true, "added", added, "wishCount", wishCount);

  } catch (Exception e) {
      e.printStackTrace(); // 서버 콘솔에서 스택 확인
      return Map.of("ok", false, "reason", "ERROR", "message", String.valueOf(e.getMessage()));
  }
  }
}
