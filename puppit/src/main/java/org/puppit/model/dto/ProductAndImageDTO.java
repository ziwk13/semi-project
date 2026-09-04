package org.puppit.model.dto;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class ProductAndImageDTO {


  private Integer productId;
  private Integer locationId;
  private Integer categoryId;
  private Integer sellerId;
  private Integer conditionId;
  private Integer statusId;
  private String productName;
  private Integer productPrice;
  private String productDescription;
  private Timestamp productCreatedAt;
  private Timestamp productUpdatedAt;
  private int totalCount;
  private Integer imageId;
  private String imageUrl;
  private String imageKey;
  private boolean thumbnail;
  private String region;
  
  
  
  
  
  
  


  
  

}
