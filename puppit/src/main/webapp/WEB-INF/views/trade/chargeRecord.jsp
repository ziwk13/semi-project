<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp" />

<style>
:root {
  --bg: #fff;
  --card: #fff;
  --text: #111;
  --muted: #8a8f98;
  --primary: #4f86ff;
  --line: #dfe3ea;
  --shadow: 0 8px 24px rgba(0, 0, 0, .08);
}
body {
  margin: 0;
  background: var(--bg);
  color: var(--text);
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
}
.wrap {
  max-width: 1200px;
  margin: 24px auto;
  padding: 0 20px 24px;
}
.header-row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 14px;
}
.title {
  font-size: 22px;
  font-weight: 800;
}
.count {
  color: var(--muted);
  font-size: 14px;
}
.card {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
  box-shadow: var(--shadow);
  overflow: hidden;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table thead th {
  text-align: left;
  padding: 14px 16px;
  font-size: 13px;
  color: var(--muted);
  background: #fafbfc;
  border-bottom: 1px solid var(--line);
  white-space: nowrap;
}
.table tbody td {
  padding: 14px 16px;
  border-bottom: 1px solid var(--line);
  font-size: 14px;
}
.table tbody tr:hover {
  background: #fcfdff;
}
.badge-amount {
  display: inline-block;
  padding: 6px 10px;
  border-radius: 999px;
  background: rgba(79, 134, 255, .08);
  border: 1px solid rgba(79, 134, 255, .25);
  font-weight: 800;
}
.mono {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
  letter-spacing: .2px;
}
.empty {
  padding: 28px 20px;
  text-align: center;
  color: var(--muted);
}
.badge-status{
  display:inline-block;
  padding:6px 10px;
  border-radius:999px;
  font-weight:800;
  font-size:12px;
  border:1px solid transparent;
  background:#f6f7f9;
}
.badge-status.pending{
  color:#6b7280;              
  background:rgba(107,114,128,.08);
  border-color:rgba(107,114,128,.25);
}
.badge-status.paid{
  color:#0f766e;              
  background:rgba(15,118,110,.08);
  border-color:rgba(15,118,110,.25);
}
.badge-status.failed{
  color:#b91c1c;              
  background:rgba(185,28,28,.08);
  border-color:rgba(185,28,28,.25);
}
.badge-status.cancelled{
  color:#7c2d12;              
  background:rgba(124,45,18,.08);
  border-color:rgba(124,45,18,.25);
}
.btn-refund{
  padding:8px 16px;border-radius:999px;border:1px solid var(--line);
  color:#374151;background:#e5e7eb;cursor:pointer;font-weight:700;font-size:13px;
}
.btn-refund:disabled{opacity:.6;cursor:not-allowed;}

</style>

<div class="wrap">
  <div class="header-row">
    <div class="title">포인트 충전 내역</div>
    <div class="count">
      총 <strong>${fn:length(pointDTOs)}</strong>건
    </div>
  </div>

  <div class="card">
    <c:choose>
      <c:when test="${not empty pointDTOs}">
        <table class="table">
          <thead>
            <tr>
              <th>충전 시간</th>
              <th>결제번호</th>
              <th>충전 금액</th>
              <th>결제 상태</th>
              <th>환불</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="pointDTO" items="${pointDTOs}">
              <tr>
                <!-- 충전 시간 -->
                <td>
                  <fmt:formatDate value="${pointDTO.pointChargeChargedAt}" pattern="yyyy-MM-dd HH:mm" />
                </td>
                <!-- 주문번호 -->
                <td class="mono">
                  ${pointDTO.pointChargeOrderNumber}
                </td>
                <!-- 충전 금액 -->
                <td>
                  <span class="badge-amount">
                    <fmt:formatNumber value="${pointDTO.pointChargeAmount}" type="number" /> P
                  </span>
                </td>
                <!-- 상태 -->
                <td>
                  <span class="badge-status ${fn:toLowerCase(pointDTO.chargeStatus)}">
                    <c:choose>
                      <c:when test="${pointDTO.chargeStatus == 'PAID'}">결제 완료</c:when>
                      <c:when test="${pointDTO.chargeStatus == 'PENDING'}">결제 대기</c:when>
                      <c:when test="${pointDTO.chargeStatus == 'FAILED'}">결제 실패</c:when>
                      <c:when test="${pointDTO.chargeStatus == 'CANCELLED'}">결제 취소</c:when>
                      <c:otherwise>알수없음</c:otherwise>
                    </c:choose>
                  </span>
                </td>
                <!-- 작업 버튼 영역 -->
                <td>
                  <button type="button"
                          class="btn-refund"
                          data-merchant="${pointDTO.pointChargeOrderNumber}"
                          data-status="${pointDTO.chargeStatus}"
                          <c:if test="${pointDTO.chargeStatus != 'PAID'}">disabled title="결제 완료 상태에서만 환불 가능합니다." aria-disabled="true"</c:if>>
                    환불하기
                  </button>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </c:when>
      <c:otherwise>
        <div class="empty">아직 충전 내역이 없습니다.</div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<script>
  const contextPath = '${contextPath}';

  document.addEventListener("click", async e => {
	  const btn = e.target.closest(".btn-refund");
	  if(!btn) return;
	  
	  const status = btn.dataset.status;
	  if(btn.disabled || status !== 'PAID') return;
	  
	  const merchantUid = btn.dataset.merchant;
	  if(!merchantUid) return;
	  
	  if(!confirm("정말 환불하시겠습니까?")) return;
	  
	  // UI 잠금
	  btn.disabled = true;
	  const originalText = btn.textContent;
	  btn.textContent = "취소 중...";
	  
	  try {
		  const res = await fetch(`${contextPath}/payment/refund`, {
			  method: "POST",
			  headers: {"Content-Type" : "application/json"},
			  body: JSON.stringify({
				  merchantUid: merchantUid,
				  reason: "사용자 요청"
			  })
		  });
		  // 파싱이 실패(예: 빈 바디, 잘못된 JSON)하면 에러가 나고 빈 객체 {}를 반환
		  const data = await res.json().catch(() => ({}));
		  if(!res.ok || data.success === false) {
			  const msg = (data && data.message) ? data.message : "취소 요청 실패";
			  alert(msg);
			  btn.disabled = false;
			  btn.textContent = originalText;
			  return;
		  }
		  alert("취소(환불) 처리되었습니다.");
		  location.reload();
  	} catch (err) {
  		console.error(err);
  		alert("취소 처리 중 오류가 발생했습니다.");
  		btn.disabled = false;
  		btn.textContent = originalText;
  	}
  });
</script>

</body>
</html>
