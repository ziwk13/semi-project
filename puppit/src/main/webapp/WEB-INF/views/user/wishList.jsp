<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp" />

<style>
  body { margin:0; background:#fff; font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Noto Sans KR',sans-serif; color:#111; }
  .wrap { max-width:1100px; margin:0 auto; padding:20px; }

  .page-title { display:flex; align-items:flex-end; gap:8px; margin:6px 0 14px; }
  .page-title h1 { font-size:22px; font-weight:700; margin:0; }
  .count { color:#d94164; font-weight:700; }

  .toolbar { display:flex; align-items:center; gap:12px; padding:10px 0 16px; border-top:1px solid #eee; }
  .checkbox { display:inline-flex; align-items:center; gap:8px; cursor:pointer; user-select:none; }
  .checkbox input { width:16px; height:16px; }
  .btn { border:1px solid #dfe3ea; background:#fff; border-radius:10px; padding:8px 12px; cursor:pointer; font-size:14px; }
  .btn:disabled { opacity:.5; cursor:not-allowed; }
  .btn.danger {color: #2b2b2b;}

  .grid { display:grid; grid-template-columns: 1fr 1fr; gap:16px; }
  @media (max-width: 860px){ .grid { grid-template-columns: 1fr; } }

  .item { position:relative; display:grid; grid-template-columns: 140px 1fr 40px; gap:14px; border:1px solid #e8edf4; border-radius:14px; padding:14px; }
  .thumb { width:140px; height:140px; border-radius:10px; overflow:hidden; background:#f6f7f9; display:flex; align-items:center; justify-content:center; }
  .thumb img { width:100%; height:100%; object-fit:cover; }

  .info { display:flex; flex-direction:column; gap:8px; }
  .title { font-weight:700; font-size:16px; line-height:1.3; max-height:2.6em; overflow:hidden; }
  .price { font-size:18px; font-weight:700; letter-spacing:-0.3px; }
  .meta { font-size:12px; color:#6b7280; display:flex; gap:10px; }

  .pick { display:flex; align-items:center; justify-content:center; }
  .pick input { display:none; }

  .pick .box {
    width:22px; height:22px;
    display:flex; align-items:center; justify-content:center;
    font-size:30px;
    color:#ccc;
  }
  .pick .on { display:none; color:#d94164; }
  .item input[type=checkbox]:checked + .box .on { display:inline; }
  .item input[type=checkbox]:checked + .box .off { display:none; }
    

  .empty { padding:60px 0; text-align:center; color:#666; }

  .card-link { text-decoration:none; color:inherit; }
</style>

<div class="wrap">

  <div class="page-title">
    <h1>찜 <span class="count"><c:out value="${fn:length(productAndImages)}"/></span></h1>
  </div>

  <c:if test="${not empty msg}">
    <div style="margin: 8px 0 16px; padding:10px 12px; border:1px solid #dfe3ea; border-radius:10px; background:#f7f8fa;">
      ${msg}
    </div>
  </c:if>

  <!-- 선택삭제/전체선택 툴바 -->
  <div class="toolbar">
    <label class="checkbox">
      <input type="checkbox" id="checkAll" />
    </label>

    <button id="btnDeleteSelected" class="btn danger" disabled>선택삭제</button>
  </div>

  <c:choose>
    <c:when test="${not empty productAndImages}">
      <!-- 선택삭제용 폼(동적으로 productId 다중 추가) - CSRF 제거 -->
      <form id="formDeleteSelected" action="${contextPath}/wish/delete" method="post" style="display:none;"></form>

      <div class="grid" id="wishGrid">
        <c:forEach var="p" items="${productAndImages}">
          <div class="item" data-product-id="${p.productId}">
            <!-- 썸네일 -->
            <a class="thumb card-link" href="${contextPath}/product/detail/${p.productId}">
              <c:choose>
                <c:when test="${not empty p.imageUrl}">
                  <img src="${p.imageUrl}" alt="${p.productName}" />
                </c:when>
                <c:otherwise>
                  이미지 없음
                </c:otherwise>
              </c:choose>
            </a>

            <!-- 정보 -->
            <div class="info">
              <a class="card-link" href="${contextPath}/product/detail/${p.productId}">
                <div class="title">${p.productName}</div>
              </a>
              <div class="price">
                <fmt:formatNumber value="${p.productPrice}" type="currency" currencySymbol="₩" />
              </div>
              <div class="meta">
                <span class="date" data-created="${p.productCreatedAt}"></span>
                <c:if test="${not empty p.region}">
                  <span>${p.region}</span>
                </c:if>
              </div>
            </div>

            <!-- 개별 체크박스 -->
            <label class="pick">
              <input type="checkbox" class="row-check" value="${p.productId}">
              <span class="box">
                <i class="fa-regular fa-circle-check off"></i>
                <i class="fa-solid fa-circle-check on"></i>
              </span>
            </label>

          </div>
        </c:forEach>
      </div>
    </c:when>
    <c:otherwise>
      <div class="empty">찜한 상품이 없습니다.</div>
    </c:otherwise>
  </c:choose>
</div>

<script>
// 날짜차이 계산
function timeAgo(dateStr) {
  if (!dateStr) return "";
  const created = new Date(dateStr);
  const now = new Date();
  const diffMs = now - created;
  const diffDays = Math.floor(diffMs / (1000*60*60*24));

  if (diffDays < 1) {
    const diffHours = Math.floor(diffMs / (1000*60*60));
    if (diffHours <= 0) return "방금 전";
    return diffHours + "시간 전";
  }
  if (diffDays < 30) return diffDays + "일 전";
  const diffMonths = Math.floor(diffDays / 30);
  if (diffMonths < 12) return diffMonths + "개월 전";
  const diffYears = Math.floor(diffMonths / 12);
  return diffYears + "년 전";
}

// 등록일 표시
document.querySelectorAll(".meta .date").forEach(el => {
  const val = el.dataset.created;
  if (val) el.textContent = timeAgo(val);
});

(function(){
  const grid = document.getElementById('wishGrid');
  const checkAll = document.getElementById('checkAll');
  const deleteBtn = document.getElementById('btnDeleteSelected');
  const formSel = document.getElementById('formDeleteSelected');
  const formAll = document.getElementById('formDeleteAll');

  if (!grid) return;

  const rows = Array.from(grid.querySelectorAll('.row-check'));

  function updateToolbar() {
    const checked = rows.filter(r => r.checked);
    deleteBtn.disabled = checked.length === 0;
    checkAll.checked = checked.length === rows.length && rows.length > 0;
  }

  checkAll?.addEventListener('change', () => {
    rows.forEach(r => r.checked = checkAll.checked);
    updateToolbar();
  });

  rows.forEach(r => r.addEventListener('change', updateToolbar));
  updateToolbar();

  deleteBtn?.addEventListener('click', (e) => {
    e.preventDefault();
    const checked = rows.filter(r => r.checked);
    if (checked.length === 0) return;

    // 모두 체크면 전체삭제 사용
    if (checked.length === rows.length) {
      if (confirm('정말 전체 삭제할까요?')) formAll.submit();
      return;
    }

    if (!confirm('선택한 상품을 삭제할까요?')) return;

    // 기존 hidden 제거
    formSel.querySelectorAll('input[name="productId"]').forEach(n => n.remove());
    // 선택된 productId 추가
    checked.forEach(r => {
      const hid = document.createElement('input');
      hid.type = 'hidden';
      hid.name = 'productId';
      hid.value = r.value;
      formSel.appendChild(hid);
    });

    formSel.submit();
  });
})();
</script>
