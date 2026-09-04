package org.puppit.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.sql.Timestamp;


@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@ToString
public class ProductDTO {


    private Integer productId;
    private Integer locationId;
    private Integer categoryId;
    private Integer sellerId;
    private String sellerNickname;
    private Integer conditionId;
    private Integer statusId;
    private String productName;
    private Integer productPrice;
    private String productDescription;
    private Timestamp productCreatedAt;
    private Timestamp productUpdatedAt;
    private int totalCount;
    private String statusName;
    private int isRead;


    private CategoryDTO      category;
    private ProductStatusDTO  status;

    private ProductImageDTO   thumbnail;  // 썸네일 1장
    
    private boolean wished;  // 현재 로그인 사용자가 찜했는지 여부



    
    

}
