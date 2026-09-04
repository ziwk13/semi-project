package org.puppit.controller;

import lombok.RequiredArgsConstructor;
import org.puppit.model.dto.ProductDTO;

import org.puppit.model.dto.ProductImageDTO;
import org.puppit.model.dto.ProductSearchDTO;
import org.puppit.repository.ProductDAO;
import org.puppit.service.ProductService;
import org.puppit.service.S3Service;
import org.puppit.service.WishListService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/product")
public class ProductController {

    private final ProductService productService;
    private final WishListService wishListService;
    private final S3Service s3Service;
    private final ProductDAO productDAO;

    /** 상품 등록 폼 */
    @GetMapping("/new")
    public String newForm(ProductDTO productDTO, Model model, HttpSession session,
                          RedirectAttributes ra) {
        Object attr = session.getAttribute("sessionMap");
        Map<String, Object> map = (Map<String, Object>) attr;
        Integer sellerId = (Integer) map.get("userId");

        if (sellerId == null) {
            ra.addFlashAttribute("error", "상품 등록은 로그인 후 이용 가능합니다.");
            return "redirect:/user/login";
        }

        var formData = productService.getProductFormData();
        model.addAttribute("categories", formData.get("categories"));
        model.addAttribute("locations", formData.get("locations"));
        model.addAttribute("conditions", formData.get("conditions"));
        model.addAttribute("product", new ProductDTO());

        return "product/productForm";
    }

    /** 상품 등록 처리 */
    @PostMapping("/new")
    public String create(@ModelAttribute ProductDTO product,
                         @RequestParam("imageFiles") List<MultipartFile> imageFiles,
                         HttpSession session,
                         RedirectAttributes ra) {

        Object attr = session.getAttribute("sessionMap");
        Map<String, Object> map = (Map<String, Object>) attr;
        Integer sellerId = (Integer) map.get("userId");

        if (sellerId == null) {
            ra.addFlashAttribute("error", "상품 등록은 로그인 후 이용 가능합니다.");
            return "redirect:/user/login";
        }

        product.setSellerId(sellerId);

        if (product.getStatusId() == null) {
            product.setStatusId(1); // 기본값: 판매중
        }

        try {
            productService.registerProduct(product, imageFiles);
            ra.addFlashAttribute("success", "상품이 등록되었습니다."); // 성공 메시지
            return "redirect:/product/myproduct";
            // ✅ 상품관리 페이지로 이동
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", "상품 등록 중 오류: " + e.getMessage());
            return "redirect:/product/new"; // 실패 시 다시 등록폼으로
        }
    }

    /** 상품 상세 조회 */
    @GetMapping("/detail/{productId}")
    public String getProductDetail(@PathVariable int productId, @SessionAttribute(value="sessionMap", required=false) Map<String,Object> sessionMap, Model model) {
    	Integer isReadCount = productService.updateIsReadCount(productId);
    	ProductDTO product = productService.detailProducts(productId);
        if (product == null) {
            model.addAttribute("error", "해당 상품을 찾을 수 없습니다.");
            return "error/404";
        }
        boolean wished = false;
        if (sessionMap != null && sessionMap.get("userId") != null) {
          Integer userId = (Integer) sessionMap.get("userId");
          wished = wishListService.existsByUserAndProduct(userId, productId);
      }
        product.setWished(wished);
        List<ProductImageDTO> subImages = productService.getSubImages(productId);
        
        // JSP로 전달
        model.addAttribute("product", product);
        model.addAttribute("subImages", subImages);

        model.addAttribute("isReadCount", isReadCount);

        Integer wishCount = wishListService.getCount(productId);
        model.addAttribute("wishCount", wishCount);

        return "product/detail";
    }

    /** 내 상품 목록 */
    @GetMapping("/myproduct")
    public String myProduct(HttpSession session, RedirectAttributes ra, Model model) {
        Object attr = session.getAttribute("sessionMap");
        if (attr == null) {
            ra.addFlashAttribute("error", "상품 관리는 로그인 후 이용 가능합니다.");
            return "redirect:/user/login";
        }

        Map<String, Object> map = (Map<String, Object>) attr;
        Integer sellerId = (Integer) map.get("userId");

        List<ProductDTO> items = productService.selectMyProducts(sellerId);
        model.addAttribute("items", items);
        return "product/myproduct";
    }

    /** 검색 */
    @GetMapping(value = "/search", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public List<ProductDTO> searchByNew(@RequestParam String searchName) {
        return productService.searchByNew(searchName);
    }

    /** 카테고리별 상품 조회 */
    @GetMapping(value = "/category", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public List<ProductSearchDTO> searchByCategory(@RequestParam String categoryName) {
      return productService.searchByCategory(categoryName);
    }
    
    /** 자동완성 */
    @GetMapping(value = "/autocomplete", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public List<String> getAutoComplete(@RequestParam("keyword") String keyword) {
        return productService.getAutoComplete(keyword);
    }

    /** 상품 수정 폼 */
    @GetMapping("/edit/{productId}")
    public String editForm(@PathVariable("productId") Integer productId,
                           HttpSession session,
                           RedirectAttributes ra,
                           Model model) {

        Object attr = session.getAttribute("sessionMap");
        Map<String, Object> map = (Map<String, Object>) attr;
        Integer sellerId = (Integer) map.get("userId");

        ProductDTO productDTO = productService.getProductById(productId);
        if (productDTO == null) {
            ra.addFlashAttribute("error", "상품을 찾을 수 없습니다.");
            return "redirect:/product/myproduct";
        }
        if (!productDTO.getSellerId().equals(sellerId)) {
            ra.addFlashAttribute("error", "상품 주인만 수정 가능합니다.");
            return "redirect:/product/myproduct";
        }

        model.addAttribute("product", productDTO);
        model.addAttribute("categories", productDAO.getCategories());
        model.addAttribute("locations", productDAO.getLocations());
        model.addAttribute("conditions", productDAO.getConditions());
        model.addAttribute("images", productDAO.getProductImages(productId));

        return "product/edit";
    }

    /** 상품 수정 처리 */
    @PostMapping("/update")
    public String update(@ModelAttribute ProductDTO product,
                         @RequestParam(value="imageFiles", required=false) List<MultipartFile> imageFiles,
                         @RequestParam(value="deleteImageIds", required=false) List<Integer> deleteImageIds,
                         HttpSession session,
                         RedirectAttributes ra) {

        Object attr = session.getAttribute("sessionMap");
        Map<String, Object> map = (Map<String, Object>) attr;
        Integer sellerId = (Integer) map.get("userId");

        ProductDTO origin = productService.getProductById(product.getProductId());
        if (origin == null || !origin.getSellerId().equals(sellerId)) {
            ra.addFlashAttribute("error", "상품 주인만 수정 가능합니다.");
            return "redirect:/product/myproduct";
        }

        try {
            product.setSellerId(sellerId);
            productService.updateProduct(product, deleteImageIds, imageFiles);
            ra.addFlashAttribute("success", "상품이 수정되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "상품 수정 실패: " + e.getMessage());
        }

        return "redirect:/product/myproduct";

    }

    /** 상품 삭제 */
    @PostMapping("/delete")
    public String delete(@RequestParam("productId") Integer productId,
                         HttpSession session,
                         RedirectAttributes ra) {

        Object attr = session.getAttribute("sessionMap");
        Map<String, Object> map = (Map<String, Object>) attr;
        Integer sellerId = (Integer) map.get("userId");

        ProductDTO productDTO = productService.getProductById(productId);
        if (productDTO == null || !productDTO.getSellerId().equals(sellerId)) {
            ra.addFlashAttribute("error", "상품 주인만 삭제 가능합니다.");
            return "redirect:/product/myproduct";
        }

        int result = productService.deleteProduct(productId);
        if (result > 0) {
            ra.addFlashAttribute("success", "상품이 삭제되었습니다.");
        } else {
            ra.addFlashAttribute("error", "상품 삭제 실패");
        }

        return "redirect:/product/myproduct";
    }


    /** 상품 썸네일 조회 */
    @GetMapping("/thumbnail/{productId}")
    @ResponseBody
    public ProductImageDTO getThumbnail(@PathVariable Integer productId) {
        return productService.getThumbnailImage(productId);
    }

    /** 상품 이미지 전체 조회 */
    @GetMapping("/images/{productId}")
    @ResponseBody
    public List<ProductImageDTO> getImages(@PathVariable Integer productId) {
        return productService.getProductImages(productId);
    }

    /** 썸네일 변경 */
    @PostMapping("/thumbnail/{productId}/{imageId}")
    @ResponseBody
    public String setThumbnail(@PathVariable Integer productId,
                               @PathVariable Integer imageId) {
        productService.setThumbnail(productId, imageId);
        return "썸네일이 변경되었습니다.";
    }

    /** 이미지 삭제 */
    @DeleteMapping("/image/{imageId}")
    @ResponseBody
    public String deleteImage(@PathVariable Integer imageId) throws Exception {
        productService.deleteImage(imageId);
        return "이미지가 삭제되었습니다.";
    }
    

    
}
