package org.puppit.service;

import java.util.List;
import java.util.Map;

import org.puppit.model.dto.ReviewDTO;
import org.puppit.model.dto.ReviewInfoDTO;

public interface ReviewService {
  public boolean register(Map<String, Object> review);
  public List<ReviewDTO> getOtherReview(Integer userId);
  public List<ReviewDTO> getMyReview(Integer userId);
  public boolean deleteReviewById(Integer reviewId);
  public boolean updateReviewById(Map<String, Object> map);
  public ReviewInfoDTO selectInfo(Map<String, Object> map);
  
}
