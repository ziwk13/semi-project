package org.puppit.service;

import lombok.RequiredArgsConstructor;
import org.puppit.model.dto.*;
import org.puppit.repository.ChatDAO;
import org.puppit.repository.ProductDAO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductDAO productDAO;
    private final ChatDAO chatDAO;
    private final S3Service s3Service;
    

    /** 상품 등록 */
    @Transactional
    @Override
    public int registerProduct(ProductDTO productDTO, List<MultipartFile> imageFiles) {
        productDAO.insertProduct(productDTO);

        if (productDTO.getStatusId() == null) {
            productDTO.setStatusId(1);
        }

        for (int i = 0; i < imageFiles.size(); i++) {
            MultipartFile file = imageFiles.get(i);
            if (!file.isEmpty()) {
                try {
                    Map<String, String> uploadResult = s3Service.uploadFile(file, "product");

                    ProductImageDTO imageDTO = new ProductImageDTO();
                    imageDTO.setProductId(productDTO.getProductId());
                    imageDTO.setImageUrl(uploadResult.get("fileUrl"));
                    imageDTO.setImageKey(uploadResult.get("fileName"));
                    imageDTO.setThumbnail(i == 0);

                    productDAO.insertProductImage(imageDTO);

                    if (i == 0) {
                        productDAO.updateThumbnail(productDTO.getProductId(), imageDTO.getImageId());
                    }
                } catch (IOException e) {
                    throw new RuntimeException("이미지 업로드 실패", e);
                }
            }
        }

        return productDTO.getProductId();
    }

    /** 상품 등록 폼 데이터 */
    @Override
    public Map<String, List<?>> getProductFormData() {
        Map<String, List<?>> map = new HashMap<>();
        map.put("categories", productDAO.getCategories());
        map.put("locations", productDAO.getLocations());
        map.put("conditions", productDAO.getConditions());
        return map;
    }

    @Override
    public ProductDTO getProductById(Integer productId) {
        return productDAO.getProductById(productId);
    }

    @Override
    public List<ProductDTO> selectMyProducts(Integer sellerId) {
        return productDAO.selectMyProducts(sellerId);
    }

    @Override
    public List<ProductDTO> getProductList() {
        return productDAO.getProductList();
    }

    @Override
    public ProductDTO getProductDetail(Integer productId) {
        return productDAO.getProductDetail(productId);
    }

    @Override
    public Map<String, Object> getUsers(ProductDTO dto, HttpServletRequest request) {

      return null;
    }


    @Override
    public List<ProductDTO> searchByNew(String searchName) {
        return productDAO.searchByNew(searchName);
    }

    @Override
    public Map<String, Object> getProducts(PageDTO dto, Map<String,Object> filters) {
      String sort = Objects.toString(filters.get("sort"), "DESC");
      int itemCount = productDAO.getProductCountFiltered(filters);
      dto.setItemCount(itemCount);

      if (dto.getOffset() >= itemCount) {
          return Map.of("products", List.of(), "itemCount", itemCount, "hasMore", false);
      }

      Map<String,Object> params = new HashMap<>(filters);
      params.put("offset", dto.getOffset());
      params.put("size",   dto.getSize());
      params.put("sort",   sort);

      List<ProductDTO> products = productDAO.selectPagedProductsFiltered(params);
      boolean hasMore = dto.getOffset() + products.size() < itemCount;

      return Map.of("products", products, "itemCount", itemCount, "hasMore", hasMore);
    }


    @Override
    public List<String> getAutoComplete(String keyword) {
        return productDAO.getAutoComplete(keyword);
    }

    /** 상품 수정 */
    @Transactional
    @Override
    public int updateProduct(ProductDTO productDTO, List<Integer> deleteImageIds, List<MultipartFile> imageFiles) throws Exception {
        productDAO.updateProduct(productDTO);

        if (deleteImageIds != null && !deleteImageIds.isEmpty()) {
            for (Integer imageId : deleteImageIds) {
                ProductImageDTO img = productDAO.getImageById(imageId);
                if (img != null) {
                    s3Service.deleteFile(img.getImageUrl());
                    productDAO.deleteImage(imageId);
                }
            }
        }

        if (imageFiles != null && !imageFiles.isEmpty()) {
            for (MultipartFile file : imageFiles) {
                if (!file.isEmpty()) {
                    Map<String, String> uploadResult = s3Service.uploadFile(file, "product");

                    ProductImageDTO imageDTO = new ProductImageDTO();
                    imageDTO.setProductId(productDTO.getProductId());
                    imageDTO.setImageUrl(uploadResult.get("fileUrl"));
                    imageDTO.setImageKey(uploadResult.get("fileName"));
                    imageDTO.setThumbnail(false);

                    productDAO.insertProductImage(imageDTO);
                }
            } 
        }

        List<ProductImageDTO> remainImages = productDAO.getProductImages(productDTO.getProductId());
        if (!remainImages.isEmpty()) {
            productDAO.unsetAllThumbnails(productDTO.getProductId());
            productDAO.setThumbnail(remainImages.get(0).getImageId());
            productDAO.updateThumbnail(productDTO.getProductId(), remainImages.get(0).getImageId());
        }

        return productDTO.getProductId();
    }

    @Transactional
    @Override
    public int deleteProduct(Integer productId) {

        List<ProductImageDTO> images = productDAO.getProductImages(productId);

        for (ProductImageDTO img : images) {
            String key = img.getImageKey();

            if (key != null && !key.isBlank()) {
                try {
                    s3Service.deleteFile(key);     
                } catch (Exception e) {
                   e.printStackTrace();
                }
            }
        }
        
        // 2) 해당 product_id로 만들어진 room_id 리스트 조회
        List<Integer> roomIdList = chatDAO.findRoomIdsByProductId(productId); // 예: SELECT room_id FROM room WHERE product_id = #{productId}

        if (roomIdList != null && !roomIdList.isEmpty()) {
            // 3) 각 room_id별로 alarm, chat 삭제
            for (Integer roomId : roomIdList) {
            	chatDAO.deleteAlarmsByRoomId(roomId); // 예: DELETE FROM alarm WHERE room_id = #{roomId}
            	chatDAO.deleteChatsByRoomId(roomId); // 예: DELETE FROM chat WHERE chat_room_id = #{roomId}
            }

            // 4) room 삭제
            chatDAO.deleteRoomsByProductId(productId); // 예: DELETE FROM room WHERE product_id = #{productId}
        }

        
        
        
        
        
        
        // 4) 상품 삭제
        return productDAO.deleteProduct(productId);
    }







    @Override
    public List<ProductDTO> getProductsByCategory(String categoryName) {
      return productDAO.getProductsByCategory(categoryName);
    }


    public ProductImageDTO getThumbnailImage(Integer productId) {
        return productDAO.getThumbnailImage(productId);
    }

    @Override
    public List<ProductImageDTO> getProductImages(Integer productId) {


        return productDAO.getProductImages(productId);

    }

    @Transactional
    @Override
    public void setThumbnail(Integer productId, Integer imageId) {
        productDAO.unsetAllThumbnails(productId);
        productDAO.setThumbnail(imageId);
        productDAO.updateThumbnail(productId, imageId);
    }

    @Transactional
    @Override
    public void deleteImage(Integer imageId) throws Exception {
        ProductImageDTO img = productDAO.getImageById(imageId);
        if (img != null) {
            s3Service.deleteFile(img.getImageUrl());
            productDAO.deleteImage(imageId);
        }
    }

    @Override
    public List<ProductDTO> mainProducts() {
      return productDAO.mainProducts();
    }

    @Override
    public ProductDTO detailProducts(Integer productId) {
      return productDAO.detailProducts(productId);
    }

    @Override
    public List<ProductSearchDTO> searchByCategory(String categoryName) {
      System.out.println("productSearchDTO: " + productDAO.searchByCategory(categoryName));
      return productDAO.searchByCategory(categoryName);
    }

    @Override
    public List<ProductImageDTO> getSubImages(Integer productId) {
      return productDAO.getsubImages(productId);
    }

	@Override
	public Integer updateIsReadCount(int productId) {
		
		return productDAO.updateIsReadCount(productId);
	}
}
