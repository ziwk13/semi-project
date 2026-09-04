package org.puppit.controller;

import java.util.List;

import org.puppit.model.dto.ProductDTO;
import org.puppit.service.ProductService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import lombok.RequiredArgsConstructor;
@RequiredArgsConstructor
@Controller
@RequestMapping("/category")
public class CategoryController {
  
 private final ProductService productService;
 
 // @RequestParam String categoryName :   ?categoryName=간식
 // @PathVariable String categoryName : /category/간식
 
 @GetMapping(value = "/product", produces = "application/json"  )
 @ResponseBody
 public List<ProductDTO> categoryPage(@RequestParam String categoryName, Model model) {
     List<ProductDTO> products = productService.getProductsByCategory(categoryName);
     model.addAttribute("categoryProducts", products);
     
     System.out.println("categoryProducts : " + products);
     
     model.addAttribute("categoryName", categoryName);
     return products;
 }

}
