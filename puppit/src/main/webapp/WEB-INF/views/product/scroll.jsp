<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<style>
  .container { max-width:1200px; margin:0 auto; padding:24px 20px 60px; background:#fff; }
  .product-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr); /* 한 줄 4개 */
    gap: 20px;
  }
  .product-box {
    border:1px solid #ececef; border-radius:12px; padding:12px;
  }
  .product-box img { width:100%; height:200px; object-fit:cover; display:block; border-radius:8px; }
  .product-name { margin-top:8px; font-weight:600; }
  .product-price { margin-top:4px; color:#555; }
  .loading { text-align:center; padding:16px; color:#666; }
</style>

<div class="container">
  <h2>상품 목록</h2>
  <div id="grid" class="product-grid"></div>

  <div id="loading" class="loading" style="display:none;">불러오는 중...</div>
  <!-- 관찰용 센티넬 -->
  <div id="sentinel" style="height:1px;"></div>
</div>

<script type="text/javascript">
  const contextPath = '${contextPath}';

  let cursor = null;     // 서버에서 내려준 nextCursor 저장
  let hasMore = true;    // 더 불러올 것이 있는지
  let loading = false;   // 중복 요청 방지
  const size = 20;

  function formatPrice(n) {
    try {
      return new Intl.NumberFormat('ko-KR').format(n) + '원';
    } catch(e) {
      return n + '원';
    }
  }

  function render(items) {
    const grid = document.getElementById('grid');
    items.forEach(p => {
      const a = document.createElement('a');
      a.href = contextPath + '/product/' + p.productId; // 상세로 라우팅 경로 맞춰줘
      a.className = 'product-box';
      a.innerHTML = `
        <img src="${p.productImage ? (contextPath + '/uploads/' + p.productImage) : (contextPath + '/resources/image/no-image.png')}" alt="">
        <div class="product-name">${p.productName}</div>
        <div class="product-price">${formatPrice(p.productPrice)}</div>
      `;
      grid.appendChild(a);
    });
  }

  async function loadMore() {
    if (loading || !hasMore) return;
    loading = true;
    document.getElementById('loading').style.display = 'block';

    try {
      const qs = new URLSearchParams();
      qs.set('size', size);
      if (cursor) qs.set('cursor', cursor);

      const res = await fetch(`${contextPath}/products/scroll?` + qs.toString(), {
        headers: { 'Accept': 'application/json' }
      });
      if (!res.ok) throw new Error('네트워크 오류');
      const data = await res.json();

      render(data.items || []);
      cursor = data.nextCursor;
      hasMore = !!data.hasMore;

      if (!hasMore) {
        // 관찰 중지 (더 이상 로드할 데이터 없음)
        io.disconnect();
        document.getElementById('loading').textContent = '마지막입니다.';
      } else {
        document.getElementById('loading').style.display = 'none';
      }
    } catch (e) {
      console.error(e);
      document.getElementById('loading').textContent = '불러오는 중 오류가 발생했습니다.';
    } finally {
      loading = false;
    }
  }

  // IntersectionObserver로 sentinel 보이면 다음 로드
  const io = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
      loadMore();
    }
  }, {
    root: null,
    rootMargin: '200px', // 살짝 여유(프리페치)
    threshold: 0
  });

  io.observe(document.getElementById('sentinel'));

  // 첫 로드
  loadMore();
</script>
