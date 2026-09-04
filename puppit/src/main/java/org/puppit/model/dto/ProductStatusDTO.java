package org.puppit.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class ProductStatusDTO {
    private Integer statusId;
    private String statusName;
    private String statusCode;
}
