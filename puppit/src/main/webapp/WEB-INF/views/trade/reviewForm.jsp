<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp">
  <jsp:param value="리뷰 작성" name="title" />
</jsp:include>

<style>
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif; background:#f9fafb; }
  .wrap { max-width: 700px; margin: 30px auto; padding: 24px; background:#fff; border:1px solid #eee; border-radius:12px; box-shadow:0 4px 16px rgba(0,0,0,.05); }
  h1 { font-size: 22px; font-weight: 700; margin-bottom: 20px; text-align:center; }
  .info-row { margin-bottom: 14px; display:flex; align-items:center; gap:10px; }
  .label { display:inline-block; width:90px; font-weight:600; color:#374151; }
  .value { color:#111; }
  textarea { width:100%; min-height:120px; padding:12px; border:1px solid #d1d5db; border-radius:8px; font-size:14px; resize:vertical; }
  textarea:focus { border-color:#111; outline:none; box-shadow:0 0 0 2px rgba(0,0,0,.1); }

  /* 별점 (왼쪽 -> 오른쪽 채움) */
  .rating-stars { display:flex; gap:6px; margin:8px 0; }
  .rating-stars .star {
    border:0; background:transparent; cursor:pointer; padding:0;
    font-size:28px; line-height:1;
  }
  .rating-stars .star i { color:#e5e7eb; transition:color .15s; } /* 비활성 */
  .rating-stars .star.on i { color:#facc15; } /* 채움 */

  .btn-submit { display:block; width:100%; margin-top:20px; height:46px; background:#111; color:#fff; border:none; border-radius:10px; font-size:16px; font-weight:600; cursor:pointer; }
  .btn-submit:hover { background:#333; }
</style>

<div class="wrap">
  <h1>리뷰 작성</h1>
  <form action="${contextPath}/review/register" method="post">
    <!-- 실제 필요한 값은 hidden으로 -->
    <input type="hidden" name="buyerId" value="${buyerId}">
    <input type="hidden" name="sellerId" value="${sellerId}">
    <input type="hidden" name="productId" value="${productId}">
    <input type="hidden" name="rating" id="ratingValue" value="0"><!-- JS가 채움 -->

    <!-- 표시용 -->
    <div class="info-row">
      <span class="label">구매자</span>
      <span class="value">${buyerNickname}</span>
    </div>
    <div class="info-row">
      <span class="label">판매자</span>
      <span class="value">${sellerNickname}</span>
    </div>
    <div class="info-row">
      <span class="label">상품명</span>
      <span class="value">${productName}</span>
    </div>

    <div class="info-row">
      <span class="label">평점</span>
      <div class="rating-stars" id="ratingStars" aria-label="별점 선택">
        <button type="button" class="star" data-val="1" aria-label="1점"><i class="fa-solid fa-star"></i></button>
        <button type="button" class="star" data-val="2" aria-label="2점"><i class="fa-solid fa-star"></i></button>
        <button type="button" class="star" data-val="3" aria-label="3점"><i class="fa-solid fa-star"></i></button>
        <button type="button" class="star" data-val="4" aria-label="4점"><i class="fa-solid fa-star"></i></button>
        <button type="button" class="star" data-val="5" aria-label="5점"><i class="fa-solid fa-star"></i></button>
      </div>
    </div>

    <div class="info-row" style="align-items:flex-start;">
      <span class="label" style="padding-top:8px;">내용</span>
      <textarea name="content" placeholder="내용을 입력하세요"></textarea>
    </div>

    <button type="submit" class="btn-submit">작성 완료</button>
  </form>
</div>

<script>
  (function(){
    const container = document.getElementById('ratingStars');
    const stars = Array.from(container.querySelectorAll('.star'));
    const input = document.getElementById('ratingValue');

    function paint(val){
      stars.forEach((btn, idx) => {
        btn.classList.toggle('on', idx < val); // 왼쪽부터 val개 켜짐
      });
    }

    // 초기값 표시(필요 시 서버에서 기본값 주면 반영)
    paint(Number(input.value || 0));

    stars.forEach((btn, idx) => {
      btn.addEventListener('click', () => {
        const val = idx + 1;
        input.value = val;
        paint(val);
      });
    });
  })();
</script>
