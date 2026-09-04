package org.puppit.repository;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.puppit.model.dto.ReviewDTO;
import org.puppit.model.dto.ReviewInfoDTO;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class ReviewDAO {
  
  private final SqlSessionTemplate sst;
  
  public Integer insertReview(Map<String, Object> review) {
    return sst.insert("org.puppit.review.insertReview", review);
  }
  public List<ReviewDTO> selectOtherReviewById(Integer userId) {
    return sst.selectList("org.puppit.review.selectOtherReviewById", userId);
  }
  public List<ReviewDTO> selectMyReviewById(Integer userId) {
    return sst.selectList("org.puppit.review.selectMyReviewById", userId);
  }
  public Integer deleteReview(Integer reviewId) {
    return sst.delete("org.puppit.review.deleteReviewById", reviewId);
  }
  public Integer updateReview(Map<String, Object> map) {
    return sst.update("org.puppit.review.updateReviewById", map);
  }
  public ReviewInfoDTO selectInfo(Map<String, Object> map) {
    return sst.selectOne("org.puppit.review.selectInfo", map);
  }

}
