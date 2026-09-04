<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp" />

<style>
:root {
  --bg:#fff; --card:#fff; --text:#111; --muted:#8a8f98; --primary:#4f86ff; --line:#e6e9ef;
  --shadow:0 8px 24px rgba(0,0,0,.08);
}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--text);font-family:system-ui,-apple-system,"Segoe UI",Roboto,"Noto Sans KR",sans-serif}
.wrap{max-width:1000px;margin:24px auto;padding:0 20px 28px}
.topbar{display:flex;align-items:center;justify-content:space-between;margin-bottom:14px}
.title{font-size:22px;font-weight:800}
.card{background:var(--card);border:1px solid var(--line);border-radius:16px;box-shadow:var(--shadow);overflow:hidden}
.section{padding:18px 20px;border-top:1px solid var(--line)}
.section:first-child{border-top:none}
.subttl{font-size:16px;font-weight:800;margin-bottom:10px}
.summary{display:grid;grid-template-columns:180px 1fr;gap:10px 16px}
.summary .label{color:var(--muted);font-size:14px}
.summary .value{font-size:15px}
.mono{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;letter-spacing:.2px}
.total{display:flex;align-items:center;justify-content:space-between;padding:14px 16px;background:#fafbff;border:1px dashed var(--line);border-radius:12px;margin-top:6px}
.total .left{font-weight:800}
.total .right{font-size:20px;font-weight:900}
.notice{margin-top:8px;color:var(--muted);font-size:13px}
.actions{display:flex;gap:10px;justify-content:flex-end;margin-top:16px}
.button{
  height:46px;padding:0 16px;border-radius:12px;border:1px solid var(--line);background:#fff;cursor:pointer;font-weight:800
}
.button:active{transform:translateY(1px)}
.btn-primary{background:var(--primary);border-color:transparent;color:#fff;box-shadow:0 6px 16px rgba(79,134,255,.25)}
.btn-primary[disabled]{opacity:.5;cursor:not-allowed;box-shadow:none}
.check{display:flex;align-items:center;gap:8px;margin-top:10px}
hr.sep{border:none;border-top:1px solid var(--line);margin:14px 0}
</style>

<div class="wrap">
  <div class="topbar">
    <div class="title">결제 확인</div>
  </div>

  <form id="payForm" action="${contextPath}/order/pay" method="post" class="card">
    <!-- 주문 요약 -->
    <div class="section">
      <div class="subttl">주문 정보</div>
      <div class="summary">
        <div class="label">구매자</div>
        <div class="value mono">${sessionScope.sessionMap.nickName}</div>

        <div class="label">판매자</div>
        <div class="value mono">${sellerNickname}</div>

        <div class="label">상품명</div>
        <div class="value mono">${productName}</div>

        <div class="label">상품 가격</div>
        <div class="value"><fmt:formatNumber value="${price}" type="number"/> P</div>

        <div class="label">수량</div>
        <div class="value">${quantity}</div>
      </div>

      <div class="total">
        <div class="left">총 결제 금액</div>
        <div class="right"><fmt:formatNumber value="${amount}" type="number"/> P</div>
      </div>

      <p class="notice">주문 정보를 다시 한 번 확인해 주세요. 결제 완료 후에는 구매 취소/환불 규정이 적용됩니다.</p>
    </div>

    <!-- 확인 체크 -->
    <div class="section">
      <label class="check">
        <input type="checkbox" id="agreeChk">
        <span>위 주문 정보를 확인했고 결제를 진행합니다.</span>
      </label>

      <hr class="sep"/>

      <div class="actions">
        <button type="button" class="button" onclick="history.back()">뒤로가기</button>
        <button type="submit" id="payBtn" class="button btn-primary" disabled>결제하기</button>
      </div>
    </div>

    <!-- 서버로 전달할 값 -->
    <input type="hidden" name="buyerId"   value="${buyerId}">
    <input type="hidden" name="sellerId"  value="${sellerId}">
    <input type="hidden" name="productId" value="${productId}">
    <input type="hidden" name="quantity"  value="${quantity}">
    <input type="hidden" name="amount"    value="${amount}">
    <input type="hidden" name="chatSellerAccountId"    value="${chatSellerAccountId}">
  </form>
</div>

<script>
  <c:if test="${not empty msg}">
    alert("${fn:escapeXml(msg)}")
  </c:if>
</script>

<script>
  // 확인 체크해야 결제 가능
  const agreeChk = document.getElementById('agreeChk');
  const payBtn   = document.getElementById('payBtn');
  agreeChk.addEventListener('change', () => {
    payBtn.disabled = !agreeChk.checked;
  });

  // 폼 제출 시 마지막으로 한 번 더 방지 팝업
  document.getElementById('payForm').addEventListener('submit', function(e){
    if (!agreeChk.checked) {
      e.preventDefault();
      return;
    }
    const ok = confirm('정말 결제를 진행하시겠습니까?');
    if (!ok) e.preventDefault();
  });
</script>
