<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<style>

  /* 1) 패딩/보더를 width에 포함 → 100%일 때 안 튀어나옴 */
  *, *::before, *::after { box-sizing: border-box; }

  /* 2) 카드 모서리 밖으로 내용이 보이지 않게 */
  .wrap { overflow: hidden; }

  /* (선택) 폼 기본 여백 제거 – 브라우저 기본값 대비 안전 */
  form { margin: 0; }

  :root{ --bg:#fff; --muted:#848a93; --line:#e6e9ef; --primary:#4f86ff; }
  body{background:#f7f8fa;}
  .wrap{max-width:900px;margin:24px auto;padding:16px 20px;background:var(--bg);border-radius:14px;box-shadow:0 6px 18px rgba(0,0,0,.04);}
  h2{margin:0 0 16px 0;font-size:18px;}
  .row{display:flex;gap:24px;align-items:flex-start;}
  .col{flex:1;}
  .field{margin:18px 0;}
  .label{display:block;font-weight:600;margin-bottom:8px;}
  .input, select, textarea{width:100%;padding:12px 14px;border:1px solid var(--line);border-radius:10px;background:#fff;font-size:14px;outline:none;}
  textarea{min-height:120px;resize:vertical;}
  .help{color:var(--muted);font-size:12px;margin-top:6px;}
  .actions{display:flex;gap:10px;justify-content:flex-end;margin-top:24px;}
  .btn{padding:10px 16px;border-radius:10px;border:1px solid var(--line);background:#fff;cursor:pointer}
  .btn.primary{background:var(--primary);border-color:var(--primary);color:#fff;font-weight:600;}
  .btn:disabled{opacity:.6;cursor:not-allowed;}

  /* 이미지 업로더 */
  .tiles{display:flex;gap:14px;flex-wrap:wrap;}
  .tile{width:160px;height:160px;border:1px dashed var(--line);border-radius:12px;background:#fafbff;display:flex;align-items:center;justify-content:center;position:relative;overflow:hidden;}
  .tile input[type=file]{position:absolute;inset:0;opacity:0;cursor:pointer;}
  .tile .placeholder{display:flex;flex-direction:column;align-items:center;color:var(--muted);font-size:12px;gap:6px;}
  .thumb{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;background:#fff;}
  .thumb img{width:100%;height:100%;object-fit:cover;}
  .remove{position:absolute;top:6px;right:6px;background:#000000b0;color:#fff;border:none;width:24px;height:24px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center}
  .badge{position:absolute;bottom:6px;left:6px;background:#000000b0;color:#fff;font-size:11px;padding:3px 6px;border-radius:8px;}
</style>
<c:if test="${not empty success}">
  <script>
    alert("<c:out value='${success}'/>");
    location.href = "${contextPath}/product/myproduct";
  </script>
</c:if>

<c:if test="${not empty error}">
  <script>
    alert("<c:out value='${error}'/>");
    location.href = "${contextPath}/product/new"; <!-- 실패 시 다시 등록 페이지 -->
  </script>
</c:if>
<div class="wrap">
  <form method="post" action="${contextPath}/product/new" enctype="multipart/form-data">
    <h2>상품 등록</h2>

    <!-- 이미지 업로더 (첨부파일 옵션 제거됨) -->
    <div class="field">
      <div class="label">상품이미지 <span class="help">(최대 3장, 첫 장이 썸네일)</span></div>
      <div id="tiles" class="tiles"></div>
      <div class="help">이미지를 하나씩 선택하면 타일이 자동으로 추가돼요.</div>
    </div>

    <div class="field">
      <label class="label">상품명</label>
      <input class="input" type="text" name="productName" placeholder="상품명을 입력하세요" required />
    </div>

    <div class="row">
      <div class="col field">
        <label class="label">카테고리</label>
        <select name="categoryId" required>
          <option value="">선택하세요</option>
          <c:forEach var="c" items="${categories}"><option value="${c.categoryId}">${c.categoryName}</option></c:forEach>
          <c:forEach var="c" items="${formData.categories}"><option value="${c.categoryId}">${c.categoryName}</option></c:forEach>
        </select>
      </div>
      <div class="col field">
        <label class="label">거래지역</label>
        <select name="locationId" required>
          <option value="">선택하세요</option>
          <c:forEach var="l" items="${locations}"><option value="${l.locationId}">${l.region}</option></c:forEach>
          <c:forEach var="l" items="${formData.locations}"><option value="${l.locationId}">${l.region}</option></c:forEach>
        </select>
      </div>
    </div>

    <div class="field">
      <label class="label">상품 상태</label>
      <div style="display:flex;flex-wrap:wrap;gap:14px;">
        <c:forEach var="cond" items="${conditions}">
          <label style="display:flex;align-items:center;gap:6px;">
            <input type="radio" name="conditionId" value="${cond.conditionId}" <c:if test="${cond.conditionId==1}">checked</c:if> />
              ${cond.conditionName}
          </label>
        </c:forEach>
        <c:forEach var="cond" items="${formData.conditions}">
          <label style="display:flex;align-items:center;gap:6px;">
            <input type="radio" name="conditionId" value="${cond.conditionId}" <c:if test="${cond.conditionId==1}">checked</c:if> />
              ${cond.conditionName}
          </label>
        </c:forEach>
      </div>
    </div>

    <div class="field">
      <label class="label">설명</label>
      <textarea name="productDescription" placeholder="브랜드, 구성품, 하자 유무, 사용감 등 상세 정보를 적어주세요."></textarea>
    </div>

    <div class="row">
      <div class="col field">
        <label class="label">가격</label>
        <input class="input" type="number" name="productPrice" placeholder="가격을 입력하세요" min="0" required />
      </div>
    </div>

    <div class="actions">
      <a class="btn" href="${contextPath}/product/myproduct">취소</a>
      <button class="btn primary" type="submit">등록하기</button>
    </div>
  </form>
</div>

<script>
  (function(){
    const MAX_IMAGES = 3;
    const tiles = document.getElementById('tiles');

    // 빈(add) 타일 생성
    function createAddTile(){
      const count = tiles.querySelectorAll('.tile').length;
      if (count >= MAX_IMAGES) return;

      // 이미 빈 타일이 있으면 또 만들지 않음
      if ([...tiles.children].some(t => !t.querySelector('img'))) return;

      const tile = document.createElement('div');
      tile.className = 'tile';



      
      const input = document.createElement('input');
      input.type = 'file';
      input.name = 'imageFiles';       // 컨트롤러 @RequestParam("imageFiles")
      input.accept = 'image/*';

      const ph = document.createElement('div');
      ph.className = 'placeholder';
      ph.innerHTML = `
      <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
        <path d="M12 5v14M5 12h14" stroke="#8a8f98" stroke-width="2" stroke-linecap="round"/>
      </svg>
      <div>이미지 추가</div>
    `;

      input.addEventListener('change', () => handleFileSelect(tile, input));
      tile.appendChild(input);
      tile.appendChild(ph);
      tiles.appendChild(tile);
    }

    // 파일 선택 처리 + 미리보기 + 삭제 버튼
    function handleFileSelect(tile, input){
      if (!input.files || !input.files[0]) return;
      const file = input.files[0];

      // placeholder 제거
      tile.querySelector('.placeholder')?.remove();

      const url = URL.createObjectURL(file);

      const preview = document.createElement('div');
      preview.className = 'thumb';
      const img = document.createElement('img');
      img.src = url;
      preview.appendChild(img);

      const remove = document.createElement('button');
      remove.type = 'button';
      remove.className = 'remove';
      remove.innerHTML = '&times;';
      remove.addEventListener('click', () => {
        URL.revokeObjectURL(url);
        tile.remove();                 // ✅ 사진 삭제 기능
        updateThumbnailBadges();       // ✅ 썸네일 재지정
        createAddTile();               // 빈 타일 보충
      });

      tile.appendChild(preview);
      tile.appendChild(remove);

      updateThumbnailBadges();
      createAddTile();
    }

    // 첫 번째 미리보기 타일에 썸네일 배지 표시 (삭제 후 재지정)
    function updateThumbnailBadges(){
      tiles.querySelectorAll('.badge').forEach(b => b.remove());
      const firstPreviewTile = [...tiles.children].find(t => t.querySelector('img'));
      if (firstPreviewTile) {
        const badge = document.createElement('div');
        badge.className = 'badge';
        badge.textContent = '썸네일';
        firstPreviewTile.appendChild(badge);
      }
    }
    // 초기 1개 빈 타일
    createAddTile();
  })();
</script>
</body>
</html>
