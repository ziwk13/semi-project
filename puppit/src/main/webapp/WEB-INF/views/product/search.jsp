<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>검색 결과</title>
<style>
.grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
}
.card {
    border: 1px solid #ececef;
    border-radius: 12px;
    padding: 10px;
    background: #fff;
}
.card .name {
    margin-top: 8px;
    font-weight: 600;
}
.card .price {
    margin-top: 4px;
    color: #555;
}
</style>
</head>
<body>

<h2>"${searchName}" 검색 결과</h2>

<c:choose>
    <c:when test="${empty searchResult}">
        <p>조건에 맞는 상품이 없습니다.</p>
    </c:when>
    <c:otherwise>
        <div class="grid">
            <c:forEach items="${searchResult}" var="p">
                <div class="card">
                    <a href="${contextPath}/product/detail/${p.productId}">
                        <img src="${p.productImage != null ? contextPath.concat('/uploads/').concat(p.productImage) : contextPath.concat('/resources/image/no-image.png')}"
                             alt="${p.productName}" 
                             style="width:100%;height:180px;object-fit:cover;border-radius:8px;">
                        <div class="name">${p.productName}</div>
                        <div class="price">
                            <fmt:formatNumber value="${p.productPrice}" type="number" groupingUsed="true"/>원
                        </div>
                    </a>
                </div>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>

</body>
</html>
