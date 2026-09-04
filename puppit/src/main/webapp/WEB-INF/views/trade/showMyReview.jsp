<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp">
  <jsp:param value="내 후기" name="title" />
</jsp:include>

<style>
  .table { width:1200px; border-collapse:collapse; margin:0 auto; padding:20px;}
  .table th,.table td { padding:12px; border-bottom:1px solid #eee; text-align:left; }
  .table th { background:#fafafa; font-weight:700; color:#374151; }
  .muted { color:#6b7280; font-size:.9rem; }
  .actions { display:flex; gap:8px; flex-wrap:wrap; }
  .btn { border:1px solid #d1d5db; background:#fff; border-radius:8px; padding:6px 10px; cursor:pointer; }
  .btn.primary { background:#111; color:#fff; border-color:#111; }
  .btn.danger  { color:#d94164; border-color:#ffd9e1; background:#fff7f9; }
  .content-input {
    width: 100%;
    min-width: 260px;
    min-height: 80px;        
    padding: 6px 8px;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    resize: vertical;        
    font-family: inherit;     
    line-height: 1.4;
  }
  .content-input[disabled] {
    border-color: transparent;
    background: transparent;
    padding: 0;
    resize: none;        
  }

  select.rating { padding:6px 8px; border:1px solid #d1d5db; border-radius:8px; }
  select.rating[disabled] { border-color:transparent; background:transparent; appearance:none; -webkit-appearance:none; padding:0; }
  .row-editing { background:#fffdf6; }
  .msgbar { margin:12px 0; padding:10px; border:1px solid #e5e7eb; border-radius:10px; background:#f8fafc; }
  .msgbar.ok { border-color:#c7f2d0; background:#effaf3; color:#0a7a31; }
  .msgbar.err { border-color:#ffd9e1; background:#fff7f9; color:#d94164; }
  .rating-stars {
    display:flex; gap:4px;
    font-size:18px;
    color:#d1d5db; /* 기본 회색 */
  }
  .rating-stars i {
    cursor:default;
    transition:color .2s;
  }
  .rating-stars i.active,
  .rating-stars i.fa-solid {
    color:#facc15; /* 노란색 */
  }
  .row-editing .rating-stars i { cursor:pointer; }
  .title {
    font-size: 22px;
    font-weight: 800;
    padding: 0 250px;
  }
</style>

<div class="title">내가 쓴 후기</div>
<br>

<c:if test="${not empty msg}">
  <div class="msgbar">${msg}</div>
</c:if>

<table class="table" id="reviewTable">
  <thead>
    <tr>
      <th>판매자</th>
      <th>구매자</th>
      <th>상품명</th>
      <th style="width:20%;">내용</th>
      <th>평점</th>
      <th>작성</th>
      <th>수정</th>
      <th>액션</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="r" items="${reviewDTOs}">
      <tr data-review-id="${r.reviewId}">
        <td>${r.sellerNickname}</td>
        <td>${r.buyerNickname}</td>
        <td>${r.productName}</td>
        <!-- 내용: 보기/수정 겸용 -->
        <td>
          <textarea class="content-input" name="content" disabled>${r.content}</textarea>
        </td>
        <!-- 평점: 보기/수정 겸용 -->
        <td>
          <div class="rating-stars" data-rating="${r.rating}" data-editable="false">
            <c:forEach begin="1" end="5" var="i">
              <i class="${i <= r.rating ? 'fa-solid' : 'fa-regular'} fa-star"
                 data-value="${i}"></i>
            </c:forEach>
            <input type="hidden" class="rating-value" name="rating" value="${r.rating}" />
          </div>
        </td>
        <td class="muted"><fmt:formatDate value="${r.createdAt}" pattern="yyyy.MM.dd HH:mm"/></td>
        <td class="muted">
          <c:choose>
            <c:when test="${not empty r.updatedAt}">
              <fmt:formatDate value="${r.updatedAt}" pattern="yyyy.MM.dd HH:mm"/>
            </c:when>
            <c:otherwise>-</c:otherwise>
          </c:choose>
        </td>

        <td class="actions">
          <button type="button" class="btn js-edit">수정</button>
          <button type="button" class="btn primary js-save" style="display:none;">저장</button>
          <button type="button" class="btn js-cancel" style="display:none;">취소</button>
          <button type="button" class="btn danger js-delete">삭제</button>
        </td>
      </tr>
    </c:forEach>
  </tbody>
</table>

<script>
  const ctx = "${contextPath}";

  // helper: URLSearchParams로 폼 인코딩
  function toFormBody(obj) {
    return new URLSearchParams(Object.entries(obj)).toString();
  }

  // 행 편집 상태 토글
  function setEditing(row, on) {
  row.classList.toggle('row-editing', on);
  const content = row.querySelector('.content-input');
  const stars   = row.querySelector('.rating-stars');
  const btnEdit   = row.querySelector('.js-edit');
  const btnSave   = row.querySelector('.js-save');
  const btnCancel = row.querySelector('.js-cancel');

  if (on) {
    row.dataset._backupContent = content.value;
    row.dataset._backupRating  = stars.dataset.rating;

    content.disabled = false;
    stars.dataset.editable = "true";
    btnEdit.style.display   = 'none';
    btnSave.style.display   = '';
    btnCancel.style.display = '';
  } else {
    content.disabled = true;
    stars.dataset.editable = "false";
    btnEdit.style.display   = '';
    btnSave.style.display   = 'none';
    btnCancel.style.display = 'none';
  }
}
  //별 아이콘 클릭 이벤트
  document.addEventListener('click', e => {
    const star = e.target.closest('.rating-stars i');
    if (!star) return;
    const stars = star.closest('.rating-stars');
    if (stars.dataset.editable !== "true") return;

    const newVal = parseInt(star.dataset.value);
    stars.dataset.rating = newVal;
    stars.querySelector('.rating-value').value = newVal;

    stars.querySelectorAll('i').forEach(i => {
      const v = parseInt(i.dataset.value);
      i.classList.toggle('fa-solid', v <= newVal);
      i.classList.toggle('fa-regular', v > newVal);
    });
  });

  // 저장(POST /review/edit)
  async function saveRow(row) {
  const reviewId = row.dataset.reviewId;
  const content  = row.querySelector('.content-input').value.trim();
  const rating   = row.querySelector('.rating-value').value;

  if (!content) { alert('내용을 입력하세요.'); return; }

  try {
    const res = await fetch(ctx + "/review/edit", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
      body: toFormBody({ reviewId, content, rating })
    });
    if (!res.ok) throw new Error("HTTP " + res.status);
    setEditing(row, false);
    
    location.reload();

    toast('리뷰가 수정되었습니다.', true);
  } catch (e) {
    console.error(e);
    toast('수정 중 오류가 발생했습니다.', false);
  }
}


  // 취소(백업값 복원)
  function cancelRow(row) {
  row.querySelector('.content-input').value = row.dataset._backupContent;
  const stars = row.querySelector('.rating-stars');
  const old   = row.dataset._backupRating;
  stars.dataset.rating = old;
  stars.querySelector('.rating-value').value = old;
  stars.querySelectorAll('i').forEach(i => {
    const v = parseInt(i.dataset.value);
    i.classList.toggle('fa-solid', v <= old);
    i.classList.toggle('fa-regular', v > old);
  });
  setEditing(row, false);
}

  // 삭제(POST /review/delete)
  async function deleteRow(row) {
    if (!confirm('이 리뷰를 삭제할까요?')) return;
    const reviewId = row.dataset.reviewId;
    try {
      const res = await fetch(ctx + "/review/delete", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
        body: toFormBody({ reviewId })
      });
      if (!res.ok) throw new Error("HTTP " + res.status);
      row.remove();
      toast('리뷰가 삭제되었습니다.', true);
    } catch (e) {
      console.error(e);
      toast('삭제 중 오류가 발생했습니다.', false);
    }
  }

  // 간단 메시지 바
  function toast(message, ok) {
    let bar = document.querySelector('.msgbar.dynamic');
    if (!bar) {
      bar = document.createElement('div');
      bar.className = 'msgbar dynamic';
      document.querySelector('h1').after(bar);
    }
    bar.textContent = message;
    bar.classList.toggle('ok', !!ok);
    bar.classList.toggle('err', !ok);
    clearTimeout(bar._t);
    bar._t = setTimeout(() => bar.remove(), 2500);
  }

  // 이벤트 위임
  document.getElementById('reviewTable').addEventListener('click', (e) => {
    const btn = e.target.closest('button');
    if (!btn) return;
    const row = btn.closest('tr');
    if (!row) return;

    if (btn.classList.contains('js-edit'))   setEditing(row, true);
    if (btn.classList.contains('js-cancel')) cancelRow(row);
    if (btn.classList.contains('js-save'))   saveRow(row);
    if (btn.classList.contains('js-delete')) deleteRow(row);
  });
</script>
