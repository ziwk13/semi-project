package org.puppit.service;

import java.util.List;
import java.util.Map;

import org.puppit.model.dto.ReviewDTO;
import org.puppit.model.dto.ReviewInfoDTO;
import org.puppit.repository.ReviewDAO;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReviewServiceImpl implements ReviewService {
  private final ReviewDAO reviewDAO;

  @Override
  public boolean register(Map<String, Object> review) {
    Integer result = reviewDAO.insertReview(review);
    return result == 1;
  }

  @Override
  public List<ReviewDTO> getOtherReview(Integer userId) {
    List<ReviewDTO> reviewDTOs = reviewDAO.selectOtherReviewById(userId);
    return reviewDTOs;
  }
  @Override
  public List<ReviewDTO> getMyReview(Integer userId) {
    List<ReviewDTO> reviewDTOs = reviewDAO.selectMyReviewById(userId);
    return reviewDTOs;
  }

  @Override
  public boolean deleteReviewById(Integer reviewId) {
    Integer result = reviewDAO.deleteReview(reviewId);
    return result == 1; 
  }

  @Override
  public boolean updateReviewById(Map<String, Object> map) {
    Integer result = reviewDAO.updateReview(map);
    return result == 1;
  }

  @Override
  public ReviewInfoDTO selectInfo(Map<String, Object> map) {
    ReviewInfoDTO info = reviewDAO.selectInfo(map);
    return info;
  }
  
  
  
}
