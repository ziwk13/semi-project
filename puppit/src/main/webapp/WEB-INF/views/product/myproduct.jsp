<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<c:if test="${not empty success}">
  <script>alert("${success}");</script>
</c:if>
<c:if test="${not empty error}">
  <script>alert("${error}");</script>
</c:if>

<style>

  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
    box-sizing: border-box;
  }




  table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
    font-size: 14px;
  }
  th, td {
    border-bottom: 1px solid #ddd;
    padding: 10px;
    text-align: center;
    vertical-align: middle;
  }
  th { background-color: #f8f8f8; font-weight: bold; }

  .thumbnail img {
    width: 80px; height: 80px; object-fit: cover; border-radius: 4px;
    transition: transform .15s ease;
  }
  .thumbnail img:hover { transform: scale(1.10); }

  .no-image {
    width: 80px; height: 80px; background:#f0f0f0;
    display:flex; align-items:center; justify-content:center;
    color:#999; font-size:12px; border-radius:4px;
  }

  .nav-menu {
    display:flex; gap:20px; margin-bottom:20px;
  }
  .nav-menu a {
    text-decoration:none; color:#333; font-weight:bold;
  }

  @media (max-width: 640px) {
    .container { padding: 0 12px; }
    table { font-size: 13px; }
  }.
   
</style>


<div class="container">

  <div class="nav-menu">
    <a href="${contextPath}/product/new">상품 등록</a>
    <a href="${contextPath}/product/myproduct">상품 관리</a>
  </div>

  <table>
    <thead>
    <tr>
      <th>사진</th>
      <th>판매 상태</th>
      <th>상품명</th>
      <th>카테고리</th>
      <th>가격</th>
      <th>등록일</th>
      <th>최근 수정일</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach var="item" items="${items}">
      <tr>
        <td class="thumbnail">
          <c:choose>
            <c:when test="${not empty item.thumbnail.imageUrl}">
              <a href="${contextPath}/product/detail/${item.productId}">
                <img src="${item.thumbnail.imageUrl}" alt="상품 이미지"/>
              </a>
            </c:when>
            <c:otherwise>
              <div class="no-image">No Image</div>
            </c:otherwise>
          </c:choose>
        </td>
        <td>
          <a href="${contextPath}/product/detail/${item.productId}">
              ${item.status.statusName}
          </a>
        </td>
        <td><a href="${contextPath}/product/detail/${item.productId}">${item.productName}</a></td>
        <td>${item.category.categoryName}</td>
        <td><fmt:formatNumber value="${item.productPrice}" pattern="#,###"/></td>
        <td><fmt:formatDate value="${item.productCreatedAt}" pattern="yyyy-MM-dd HH:mm"/></td>
        <td><fmt:formatDate value="${item.productUpdatedAt}" pattern="yyyy-MM-dd HH:mm"/></td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</div>
