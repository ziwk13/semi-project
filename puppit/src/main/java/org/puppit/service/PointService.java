package org.puppit.service;

import java.util.List;

import org.puppit.model.dto.PointDTO;
import org.puppit.model.dto.RefundRequest;
import org.puppit.model.dto.RefundResult;
import org.puppit.model.dto.VerifyResultDTO;

public interface PointService {
    public VerifyResultDTO verifyAndChargeByImpUid(Integer uid, String impUid);
    public List<PointDTO> selectPointRecordById(Integer userId);
    public boolean insertChargeRecord(Integer uid, Integer amount, String uuid);
    public void updateStatusToFailed(String merchantUid);
    public RefundResult refund(Integer uid, RefundRequest req);
}