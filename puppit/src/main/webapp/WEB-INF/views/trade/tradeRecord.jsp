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

.badge-status {
  display: inline-block;
  padding: 6px 10px;
  border-radius: 999px;
  border: 1px solid var(--line);
  background: #fff;
  font-weight: 800;
  font-size: 12px;
}

/* 선택: 상태 값에 따른 색상(원하는 값만 추가해서 사용) */
.badge-status[data-status="PAID"],
.badge-status[data-status="COMPLETED"],
.badge-status[data-status="DONE"] {
  background: rgba(20, 180, 70, .08);
  border-color: rgba(20, 180, 70, .25);
}

.badge-status[data-status="CANCELLED"],
.badge-status[data-status="REFUNDED"] {
  background: rgba(220, 0, 0, .06);
  border-color: rgba(220, 0, 0, .25);
}

.badge-status[data-status="PENDING"],
.badge-status[data-status="HOLD"] {
  background: rgba(79, 134, 255, .08);
  border-color: rgba(79, 134, 255, .25);
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
</style>

<div class="wrap">
  <div class="header-row">
    <div class="title">거래 내역</div>
    <div class="count">총 <strong>${fn:length(tradeDTOs)}</strong>건</div>
  </div>

  <div class="card">
    <c:choose>
      <c:when test="${not empty tradeDTOs}">
        <table class="table">
          <thead>
            <tr>
              <th>거래 일시</th>
              <th>상품명</th>
              <th>상품가격</th>
              <th>구매자</th>
              <th>판매자</th>
              <th>상태</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="tradeDTO" items="${tradeDTOs}">
              <tr>
                <td><fmt:formatDate value="${tradeDTO.createdAt}" pattern="yyyy-MM-dd HH:mm" /></td>
                <td class="mono">${tradeDTO.productName}</td>
                <td>${tradeDTO.productPrice} P</td>
                <td>${tradeDTO.buyerNickname}</td>
                <td>${tradeDTO.sellerNickname}</td>
                <td>
                  <span class="badge-status" data-status="${tradeDTO.status}">
                    ${tradeDTO.status}
                  </span>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </c:when>
      <c:otherwise>
        <div class="empty">아직 거래 내역이 없습니다.</div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

</body>
</html>
