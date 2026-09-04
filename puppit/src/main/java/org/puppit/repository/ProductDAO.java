package org.puppit.repository;

import org.apache.ibatis.session.SqlSession;
import org.puppit.model.dto.*;
import org.springframework.stereotype.Repository;
import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class ProductDAO {

    private final SqlSession sqlSession;

    /** ------------------- 상품 ------------------- */
    public int insertProduct(ProductDTO productDTO) {
        sqlSession.insert("product.insertProduct", productDTO);
        return productDTO.getProductId();
    }

    public int updateProduct(ProductDTO productDTO) {
        return sqlSession.update("product.updateProduct", productDTO);
    }

    public int deleteProduct(Integer productId) {
        return sqlSession.delete("product.deleteProduct", productId);
    }

    public ProductDTO getProductById(Integer productId) {
        return sqlSession.selectOne("product.getProductById", productId);
    }

    public List<ProductDTO> getProductList() {
        return sqlSession.selectList("product.getProductList");
    }

    public ProductDTO getProductDetail(Integer productId) {
        return sqlSession.selectOne("product.getProductDetail", productId);
    }

    public List<ProductDTO> selectMyProducts(Integer sellerId) {
        return sqlSession.selectList("product.selectMyProducts", sellerId);
    }

    public Integer getProductCount() {
        return sqlSession.selectOne("product.getProductCount");
    }

    /** ------------------- 검색 ------------------- */
    public List<ProductDTO> searchByNew(String searchName) {
        return sqlSession.selectList("search.searchByNew", searchName);
    }

    public List<String> getAutoComplete(String keyword) {
        return sqlSession.selectList("product.getAutoComplete", keyword);
    }

    /** ------------------- 분류 데이터 ------------------- */
    public List<CategoryDTO> getCategories() {
        return sqlSession.selectList("product.getCategories");
    }

    public List<LocationDTO> getLocations() {
        return sqlSession.selectList("product.getLocations");
    }

    public List<ConditionDTO> getConditions() {
        return sqlSession.selectList("product.getConditions");
    }

    /** ------------------- 이미지 ------------------- */
    public int insertProductImage(ProductImageDTO productImageDTO) {
        return sqlSession.insert("product.insertProductImage", productImageDTO);
    }

    public List<ProductImageDTO> getProductImages(int productId) {
        return sqlSession.selectList("product.getProductImages", productId);
    }

    public ProductImageDTO getImageById(int imageId) {
        return sqlSession.selectOne("product.getImageById", imageId);
    }

    public int deleteImage(int imageId) {
        return sqlSession.delete("product.deleteImage", imageId);
    }

    public void unsetAllThumbnails(Integer productId) {
        sqlSession.update("product.unsetAllThumbnails", productId);
    }

    public void setThumbnail(Integer imageId) {
        sqlSession.update("product.setThumbnail", imageId);
    }

    /** 단순히 썸네일 1개만 ProductImageDTO로 조회 */
    public ProductImageDTO getThumbnailImage(Integer productId) {
        return sqlSession.selectOne("product.getThumbnailImage", productId);
    }

    /** product 테이블의 thumbnail_id 갱신 */
    public void updateThumbnail(Integer productId, Integer imageId) {
        Map<String, Object> params = new HashMap<>();
        params.put("productId", productId);
        params.put("imageId", imageId);
        sqlSession.update("product.updateThumbnail", params);
    }


    public List<ProductDTO> getProductsByCategory (String categoryName) {
        return sqlSession.selectList("product.getProductsByCategory", categoryName);
    }
    
    public List<ProductDTO> mainProducts () {
      return sqlSession.selectList("product.mainProducts");
    }
    
    public ProductDTO detailProducts (Integer productId) {
      return sqlSession.selectOne("product.detailProducts", productId);
    }
    
    public List<ProductDTO> selectPagedProducts(Map<String, Object> map) {
      return sqlSession.selectList("product.selectPagedProducts", map);
    }
 
    public List<ProductSearchDTO> searchByCategory(String categoryName) {
      return sqlSession.selectList("product.searchByCategory", categoryName);
    }
    
    public Integer getProductCountFiltered(Map<String,Object> filters) {
      return sqlSession.selectOne("product.getProductCountFiltered", filters);
    }
    
    public List<ProductDTO> selectPagedProductsFiltered(Map<String,Object> params) {
      return sqlSession.selectList("product.selectPagedProductsFiltered", params);
    }
      
    public List<ProductImageDTO> getsubImages(Integer productId) {
      return sqlSession.selectList("product.getSubImages", productId);
    }

	public Integer updateIsReadCount(int productId) {		
		return sqlSession.update("product.updateIsReadCount", productId);
	}
    

}
