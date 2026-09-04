package org.puppit.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.puppit.model.dto.ReviewDTO;
import org.puppit.model.dto.ReviewInfoDTO;
import org.puppit.service.ReviewService;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.SessionAttributes;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/review")
public class ReviewController {
  
  private final ReviewService reviewService;
  
  @GetMapping("/form")
  public String writeReview(Integer buyerId, Integer sellerId, Integer productId, Model model) {
    
    Map<String, Object> map = new HashMap<>();
    map.put("buyerId", buyerId);
    map.put("sellerId", sellerId);
    map.put("productId", productId);
    
    ReviewInfoDTO info = reviewService.selectInfo(map);
    
    model.addAttribute("buyerId", buyerId);
    model.addAttribute("sellerId", sellerId);
    model.addAttribute("productId", productId);
    model.addAttribute("buyerNickname", info.getBuyerNickname());
    model.addAttribute("sellerNickname", info.getSellerNickname());
    model.addAttribute("productName", info.getProductName());
    
    System.out.println("바이어: " + info.getBuyerNickname());
    System.out.println("셀러: " + info.getSellerNickname());
    System.out.println("프로덕트: " + info.getProductName());
    
    return "trade/reviewForm";
  }
  
  @PostMapping("/register")
  public String registerReview(Integer buyerId, Integer sellerId, Integer productId, Integer rating, String content, RedirectAttributes rttr) {
    Map<String, Object> review = new HashMap<>();
    review.put("buyerId", buyerId);
    review.put("sellerId", sellerId);
    review.put("productId", productId);
    review.put("rating", rating);
    review.put("content", content);
    try {
      boolean result = reviewService.register(review);
      rttr.addFlashAttribute("msg", result ? "리뷰 작성 성공" : "리뷰 작성 실패");
    } catch (DuplicateKeyException e) {
      rttr.addFlashAttribute("msg", "후기는 상품당 한 번만 작성할 수 있습니다.");
    }
    return "redirect:/";
  }
  
  @GetMapping("/showOther")
  public String showOtherReview(HttpSession session, Model model) {
    Map<String, Object> sessionMap = (Map<String, Object>)session.getAttribute("sessionMap");
    Integer userId = (Integer) sessionMap.get("userId");
    List<ReviewDTO> reviewDTOs = reviewService.getOtherReview(userId);
    model.addAttribute("reviewDTOs", reviewDTOs);
    
    return "trade/showOtherReview";
  }
  
  @GetMapping("/showMy")
  public String showMyReview(HttpSession session, Model model) {
    Map<String, Object> sessionMap = (Map<String, Object>)session.getAttribute("sessionMap");
    Integer userId = (Integer) sessionMap.get("userId");
    List<ReviewDTO> reviewDTOs = reviewService.getMyReview(userId);
    model.addAttribute("reviewDTOs", reviewDTOs);
    
    return "trade/showMyReview";
  }
  
  @PostMapping("/delete")
  public String deleteReview(Integer reviewId, RedirectAttributes rttr) {
    boolean result = reviewService.deleteReviewById(reviewId);
    rttr.addFlashAttribute("msg", result ? "리뷰 삭제 성공" : "리뷰 삭제 실패");
    return "redirect:/";
  }
  
  @PostMapping("/edit")
  public String updateReview(Integer reviewId, String content, Integer rating, RedirectAttributes rttr) {
    Map<String, Object> map = new HashMap<>();
    map.put("reviewId", reviewId);
    map.put("content", content);
    map.put("rating", rating);
    boolean result = reviewService.updateReviewById(map);
    rttr.addFlashAttribute("msg", result ? "리뷰 수정 성공" : "리뷰 수정 실패");
    return "redirect:/";
  }

}
