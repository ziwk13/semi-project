package org.puppit.model.dto;


import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductImageDTO {

    private Integer imageId;
    private Integer productId;
    private String imageUrl;
    private String imageKey;
    private boolean thumbnail;

}