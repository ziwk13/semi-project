<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp">
  <jsp:param value="다른 사람의 후기" name="title" />
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
  .not-exists {text-align:center; color:#6b7280; padding: 20px 0;}
  .title {
    font-size: 22px;
    font-weight: 800;
    padding: 0 250px;
  }
</style>

<div class="title">다른 사람의 후기</div>

<c:if test="${not empty msg}">
  <div class="msgbar">${msg}</div>
</c:if>
<c:choose>
  <c:when test="${not empty reviewDTOs}">
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
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </c:when>
  <c:otherwise>
    <div class="not-exists">
      <span>후기가 존재하지 않습니다.</span>
    </div>
  </c:otherwise>
</c:choose>


