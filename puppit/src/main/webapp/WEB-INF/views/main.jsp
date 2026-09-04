<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="./layout/header.jsp" />

<script type="application/json" id="flash-msg"><c:out value='${msg}'/></script>
<script>
  (function () {
    var el = document.getElementById('flash-msg');
    var msg = el ? el.textContent : '';
    if (msg && msg.trim() !== '') alert(msg);
  })();
</script>

<style>
/* ===== 상품 그리드 ===== */
.product-grid {
	display: grid;
	grid-template-columns: repeat(5, 1fr);
	gap: 24px;
}

@media ( max-width :1024px) {
	.product-grid {
		grid-template-columns: repeat(3, 1fr);
	}
}

@media ( max-width :768px) {
	.product-grid {
		grid-template-columns: repeat(2, 1fr);
	}
}

/* ===== 상품 카드 ===== */
.product-card {
	display: block;
	text-decoration: none;
	color: inherit;
	background: #fff;
	border-radius: 14px;
	border: 1px solid #ececef;
	overflow: hidden;
	transition: all 0.25s ease-in-out;
	box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.product-card:hover {
	transform: translateY(-6px) scale(1.02);
	box-shadow: 0 10px 20px rgba(0, 0, 0, 0.12);
}

/* ===== 썸네일 이미지 ===== */
.thumb {
	width: 100%;
	aspect-ratio: 1/1;
	object-fit: cover;
	border-bottom: 1px solid #f1f1f1;
	background: #f8f8f8;
	transition: transform 0.3s ease;
}

.product-card:hover .thumb {
	transform: scale(1.05);
}

/* ===== 상품명 ===== */
.product-title {
	margin: 10px 12px 4px;
	font-size: 15px;
	color: #111;
	font-weight: 600;
	line-height: 1.4;
	white-space: normal;
	overflow: hidden;
}
 

/* ===== 가격 ===== */
.product-price {
	margin: 0 12px 12px;
	font-size: 15px;
	font-weight: 700;
	color: #e74c3c;
}

/* ===== 검색 결과 ===== */
#search-results {
	background: #fff;
}

.empty {
	text-align: center;
	padding: 20px;
	color: #777;
}

.badge {
	display: inline-block;
	margin-left: 6px;
	padding: 2px 6px;
	font-size: 12px;
	border-radius: 6px;
	color: #fff;
}

.badge-sale {
	background-color: #28a745;
} /* 판매중 - 초록 */

.badge-reserve {
	background-color: #ffc107;
} /* 예약중 - 노랑 */

.badge-soldout {
	background-color: #dc3545;
} /* 판매완료 - 빨강 */

</style>


<div class="container">
	<!-- 상품 리스트 -->
	<c:if test="${not empty products}">
		<div class="product-grid" id="productGrid">
		    <!-- 초기 상품 리스트 동기 렌더링 -->
			<c:forEach items="${products}" var="p">
				<a class="product-card"
					href="${contextPath}/product/detail/${p.productId}"> <img
					class="thumb" src="${p.thumbnail.imageUrl}" alt="${p.productName}"
					onerror="this.onerror=null; this.src='${contextPath}/resources/image/no-image.png';">
					<div class="product-title">${p.productName}
						<c:if test="${p.statusId == 1}">
							<span class="badge badge-sale">판매중</span>
						</c:if>
						<c:if test="${p.statusId == 2}">
							<span class="badge badge-reserve">예약중</span>
						</c:if>
						<c:if test="${p.statusId == 3}">
							<span class="badge badge-soldout">판매완료</span>
						</c:if>
					</div>
					<div class="product-price">
						<fmt:formatNumber value="${p.productPrice}" type="number"
							groupingUsed="true" />
						원
					</div>
				</a>
			</c:forEach>
		</div>
	</c:if>
</div>



<script>
(() => {
	// 페이지 로드 시 동작
	// URL 파라미터(q, category)를 확인해서 검색 / 카테고리 로딩 / 기본 로딩 결정
  document.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    const q = params.get("q");
    const category = params.get("category");

    if (q) {
      search(q);
    } else if (category) {
      loadCategory(category);
    } else {
      fillIfShort();
    }
  });

  // 기본 설정
  const mainGrid = document.getElementById('productGrid');
  const size    = 40;	// 한 번에 불러올 상품 개수
  
  // 상태값 관리
  let loading = false;
  let endOfData = false;
  let offset = mainGrid ? mainGrid.querySelectorAll('.product-card').length : 0;
  let lastRequestedOffset = -1;	// 마지막 요청 offset 중복 방지

  // 중복 상품 방지
  const seenIds = new Set(
    Array.from(mainGrid ? mainGrid.querySelectorAll('.product-card') : [])
      .map(a => {
        try {
          const parts = a.getAttribute('href').split('/');
          return Number(parts[parts.length - 1]);
        } catch (_) { return null; }
      })
      .filter(Boolean)
  );

  const formatPrice = v => {
    if (v == null) return '';
    try { return new Intl.NumberFormat('ko-KR').format(v) + '원'; }
    catch { return v + '원'; }
  };

  // 상품 리스트 DOM에 추가
  const appendProducts = (list) => {
    if (!Array.isArray(list) || !list.length) return;

    let html = '';
    let added = 0;

    for (const p of list) {
      const id    = p.productId;
      if (!id || seenIds.has(id)) continue;  // 중복이면 skip
      seenIds.add(id);

      const name  = p.productName || '';
      const price = p.productPrice ? formatPrice(p.productPrice) : '';
      const imgUrl =
        (p.thumbnail && p.thumbnail.imageUrl) ? p.thumbnail.imageUrl :
        (p.thumbImageUrl ? p.thumbImageUrl : (contextPath + '/resources/image/no-image.png'));

   // 상태 뱃지 처리
      let statusBadge = '';
      if (p.statusId == 1) {
        statusBadge = '<span class="badge badge-sale">판매중</span>';
      } else if (p.statusId == 2) {
        statusBadge = '<span class="badge badge-reserve">예약중</span>';
      } else if (p.statusId == 3) {
        statusBadge = '<span class="badge badge-soldout">판매완료</span>';
      }

      // 상품 카드 HTML 생성
      html +=
        '<a class="product-card" href="' + contextPath + '/product/detail/' + id + '">' +
         
        '<img class="thumb" src="' + imgUrl + '" alt="상품이미지 없음">' +
          '<div class="product-title">' + name +  '&nbsp' + statusBadge +  '</div>' +
          '<div class="product-price">' + price + '</div>' +
          
        '</a>';

      added++;
    }

    if (added > 0) {
      mainGrid.insertAdjacentHTML('beforeend', html);
      offset = mainGrid.querySelectorAll('.product-card').length;
    }
  };

  let currentFilter = { q:'', category:'', sort:'DESC' };
    
  
  // 무한스크롤 비동기 로직
  const fetchProducts = async () => {
    if (loading || endOfData) return;
    if (offset === lastRequestedOffset) return;
    lastRequestedOffset = offset;

    loading = true;
    
    const url =
      contextPath + "/product/list?offset=" + offset + "&size=" + size
      + (currentFilter.q ? "&q=" + encodeURIComponent(currentFilter.q) : "")
      + (currentFilter.category ? "&category=" + encodeURIComponent(currentFilter.category) : "")
      + "&sort=" + encodeURIComponent(currentFilter.sort);

    try {
      const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
      if (!res.ok) throw new Error("HTTP " + res.status);

      const data  = await res.json();
      console.log('data: ' , data);
      const list  = Array.isArray(data.products) ? data.products : [];
      const total = Number.isFinite(data.itemCount) ? data.itemCount : null;
      const more  = (typeof data.hasMore === 'boolean') ? data.hasMore : null;

      if (list.length > 0) {
        const before = offset;
        appendProducts(list);

        if (more !== null) {
          endOfData = !more;
        } else if ((total !== null && offset >= total) || list.length < size) {
          endOfData = true;
        }

        if (offset === before && !endOfData) {
          lastRequestedOffset = -1;
          offset += size;
          return fetchProducts();
        }
      } else {
        endOfData = true;
      }
    } catch (e) {
      console.error(e);
      endOfData = true;
    } finally {
      loading = false;
    }
  };
  window.fetchProducts = fetchProducts;

  // 스크롤 핸들러
  let scrollTimer;
  function scrollHandler() {
    if (scrollTimer) clearTimeout(scrollTimer);
    scrollTimer = setTimeout(() => {
      if (loading || endOfData) return;
      if (document.documentElement.scrollTop + window.innerHeight >= document.documentElement.scrollHeight - 100) {
        fetchProducts();
      }
    }, 50);
  }
  window.addEventListener("scroll", scrollHandler);

  // 초기 화면이 짧을 때 자동으로 채우기
  const fillIfShort = async () => {
    while (!endOfData &&
           mainGrid &&
           mainGrid.style.display !== 'none' &&
           document.documentElement.scrollHeight <= window.innerHeight) {
      await fetchProducts();
    }
  };

  // 헤더에서 전달받은 이벤트 처리
  window.addEventListener('puppit:applyFilter', (e) => {
    const { q = '', category = '' } = e.detail || {};
    offset = 0;
    endOfData = false;
    lastRequestedOffset = -1;
    seenIds.clear();

    if (mainGrid) { mainGrid.innerHTML = ''; mainGrid.style.display = 'grid'; }

    currentFilter = { ...currentFilter, q, category };

    const input = document.getElementById('search-input');
    if (input) input.value = q;

    fetchProducts();
  });

  // 카테고리 선택시 상품 불러오기
  async function loadCategory(categoryName) {
    offset = 0;
    endOfData = false;
    lastRequestedOffset = -1;
    seenIds.clear();
    mainGrid.innerHTML = "";

    currentFilter = { ...currentFilter, category: categoryName, q: "" };

    await fetchProducts();
  }
  window.loadCategory = loadCategory;

  // 검색시 상품 불러오기
  async function search(keyword) {
    const q = (keyword || "").trim();
    if (!q) return;

    offset = 0;
    endOfData = false;
    lastRequestedOffset = -1;
    seenIds.clear();
    mainGrid.innerHTML = "";

    currentFilter = { ...currentFilter, q, category: "" };

    await fetchProducts();
  }

})();
</script>
