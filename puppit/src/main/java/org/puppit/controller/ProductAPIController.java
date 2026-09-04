package org.puppit.controller;

import java.util.HashMap;
import java.util.Map;

import org.puppit.model.dto.ProductImageDTO;
import org.puppit.repository.ProductDAO;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/api/product")
public class ProductAPIController {
  
  private final ProductDAO productDAO;
  
  @GetMapping(value = "/detail/{productId}", produces = MediaType.APPLICATION_JSON_VALUE)
  @ResponseBody
  public Map<String, Object> getProductThumnailImage(@PathVariable Integer productId, Model model) {
    Map<String, Object> map = new HashMap<String, Object>();
    ProductImageDTO productImageDTO = productDAO.getThumbnailImage(productId);
    map.put("thumbnail", productImageDTO);
    System.out.println("productImageLIstDTO: " + productImageDTO.toString());
    
    return map;
  }
  
}
