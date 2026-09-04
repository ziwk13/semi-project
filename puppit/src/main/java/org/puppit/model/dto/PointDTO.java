package org.puppit.model.dto;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class PointDTO {
  
  private Integer chargeId;
  private Integer userId;
  private Integer pointChargeAmount;
  private String pointChargeOrderNumber;
  private Timestamp pointChargeChargedAt; 
  private OrderStatus chargeStatus;
}
