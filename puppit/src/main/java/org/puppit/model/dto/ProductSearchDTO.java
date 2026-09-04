package org.puppit.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString
public class ProductSearchDTO {
  private String productName;
  private Integer productId;
  private Integer productPrice;
  private String productImage;
  @Override
  public String toString() {
    return "ProductSearchDTO [productName=" + productName + ", productId=" + productId + ", productPrice="
        + productPrice + ", productImage=" + productImage + "]";
  }

  
  
  
  }
  

