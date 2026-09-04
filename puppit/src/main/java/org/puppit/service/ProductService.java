package org.puppit.service;

import org.puppit.model.dto.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

public interface ProductService {

    int registerProduct(ProductDTO productDTO, List<MultipartFile> imageFiles);

    Map<String, List<?>> getProductFormData();

    ProductDTO getProductById(Integer productId);

    List<ProductDTO> selectMyProducts(Integer sellerId);

    List<ProductDTO> getProductList();

    ProductDTO getProductDetail(Integer productId);

    Map<String, Object> getUsers(ProductDTO dto, HttpServletRequest request);

    List<ProductDTO> searchByNew(String searchName);

    Map<String, Object> getProducts(PageDTO dto, Map<String,Object> filters);

    List<String> getAutoComplete(String keyword);

    int updateProduct(ProductDTO productDTO, List<Integer> deleteImageIds, List<MultipartFile> imageFiles) throws Exception;

    int deleteProduct(Integer productId);


    List<ProductDTO> getProductsByCategory(String categoryName);

    ProductImageDTO getThumbnailImage(Integer productId);

    List<ProductImageDTO> getProductImages(Integer productId);

    void setThumbnail(Integer productId, Integer imageId);


    void deleteImage(Integer imageId) throws Exception;
    List<ProductDTO> mainProducts();
    
    ProductDTO detailProducts(Integer product);
    
    public List<ProductSearchDTO> searchByCategory(String categoryName); 
    
    List<ProductImageDTO> getSubImages(Integer productId);

	Integer updateIsReadCount(int productId);
     
  

    
}
