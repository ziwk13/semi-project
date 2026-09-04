package org.puppit.service;

import java.util.ArrayList;
import java.util.List;

import org.puppit.model.dto.ProductAndImageDTO;
import org.puppit.model.dto.ProductDTO;
import org.puppit.model.dto.ProductImageDTO;
import org.puppit.model.dto.WishListDTO;
import org.puppit.repository.WishListDAO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class WishListService {
  
  private final WishListDAO wishListDAO;
  
  public List<WishListDTO> getWishListByUserId(Integer userId) {
    return wishListDAO.getWishListByUserId(userId);
  }
  public ProductDTO getProductById(Integer productId) {
    return wishListDAO.getProductById(productId);
  }
  public boolean deleteWishListByUserAndProduct(Integer userId, List<Integer> productIds) {
    return wishListDAO.deleteWishListByUserAndProduct(userId, productIds) == 1;
  }
  public boolean deleteAllWishListByUser(Integer userId) {
    return wishListDAO.deleteAllWishListByUser(userId) == 1;
  }
  public ProductImageDTO getProductImage(Integer productId) {
    return wishListDAO.getProductImage(productId);
  }
  public ProductAndImageDTO getProductAndImage(Integer productId) {
    return wishListDAO.getProductAndImage(productId);
  }
  
  @Transactional
  public List<ProductAndImageDTO> selectWishListProducts(Integer userId) {
    return wishListDAO.selectWishListProducts(userId);
  }
  public boolean toggle(Integer userId, Integer productId) {
    List<Integer> productIds = new ArrayList<Integer>();
    productIds.add(productId);
    Integer deleted = wishListDAO.deleteWishListByUserAndProduct(userId, productIds);
    if(deleted > 0) {
      return false;
    }
    wishListDAO.insertWishList(userId, productId);
    return true;
  }
  public boolean existsByUserAndProduct(Integer userId, Integer productId) {
    return wishListDAO.existsByUserAndProduct(userId, productId) == 1 ? true : false;
  }
  public Integer getCount(Integer productId) {
    return wishListDAO.getCount(productId);
  }

}
