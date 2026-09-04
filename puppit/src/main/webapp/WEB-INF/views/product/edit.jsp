<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>

<style>
  *, *::before, *::after { box-sizing: border-box; }
  .wrap { overflow: hidden; }

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

<div class="wrap">
  <!-- 상품 수정 form -->
  <form id="editForm" method="post" action="${contextPath}/product/update" enctype="multipart/form-data">
    <h2>상품 수정</h2>
    <input type="hidden" name="productId" value="${product.productId}"/>

    <!-- 이미지 업로더 -->
    <div class="field">
      <div class="label">상품이미지 <span class="help">(최대 3장, 첫 장이 썸네일)</span></div>
      <div id="tiles" class="tiles">
        <!-- 기존 이미지 출력 -->
        <c:forEach var="img" items="${images}" varStatus="status">
          <div class="tile" id="tile-${img.imageId}">
            <div class="thumb">
              <img src="${img.imageUrl}" alt="기존 이미지"/>
            </div>
            <c:if test="${status.first}">
              <div class="badge">썸네일</div>
            </c:if>
            <button type="button" class="remove" onclick="deleteImage(${img.imageId})">&times;</button>
          </div>
        </c:forEach>
      </div>
      <div class="help">이미지를 교체하거나 삭제 후 새로 업로드할 수 있습니다.</div>
    </div>

    <!-- 상품명 -->
    <div class="field">
      <label class="label">상품명</label>
      <input class="input" type="text" name="productName" value="${product.productName}" required />
    </div>

    <div class="row">
      <div class="col field">
        <label class="label">카테고리</label>
        <select name="categoryId" required>
          <c:forEach var="c" items="${categories}">
            <option value="${c.categoryId}" <c:if test="${product.categoryId eq c.categoryId}">selected</c:if>>${c.categoryName}</option>
          </c:forEach>
        </select>
      </div>
      <div class="col field">
        <label class="label">거래지역</label>
        <select name="locationId" required>
          <c:forEach var="l" items="${locations}">
            <option value="${l.locationId}" <c:if test="${product.locationId eq l.locationId}">selected</c:if>>${l.region}</option>
          </c:forEach>
        </select>
      </div>
    </div>

    <!-- 상품 상태 -->
    <div class="field">
      <label class="label">상품 상태</label>
      <div style="display:flex;flex-wrap:wrap;gap:14px;">
        <c:forEach var="cond" items="${conditions}">
          <label style="display:flex;align-items:center;gap:6px;">
            <input type="radio" name="conditionId" value="${cond.conditionId}" <c:if test="${product.conditionId eq cond.conditionId}">checked</c:if> />
              ${cond.conditionName}
          </label>
        </c:forEach>
      </div>
    </div>

    <!-- 설명 -->
    <div class="field">
      <label class="label">설명</label>
      <textarea name="productDescription" required>${product.productDescription}</textarea>
    </div>

    <!-- 가격 -->
    <div class="row">
      <div class="col field">
        <label class="label">가격</label>
        <input class="input" type="number" name="productPrice" value="${product.productPrice}" min="0" required />
      </div>
    </div>

    <!-- 수정 버튼 -->
    <div class="actions">
      <a class="btn" href="${contextPath}/product/detail/${product.productId}">취소</a>
      <button class="btn primary" type="submit">수정 완료</button>
    </div>
  </form>

  <!-- 상품 삭제 form (별도 분리) -->
  <form id="deleteForm" action="${contextPath}/product/delete" method="post" style="margin-top:10px;">
    <input type="hidden" name="productId" value="${product.productId}"/>
    <button type="submit" class="btn"
            onclick="return confirm('정말 삭제하시겠습니까?');">상품 삭제</button>
  </form>
</div>

<script>
  const MAX_IMAGES = 3;
  const tiles = document.getElementById('tiles');
  const form = document.getElementById('editForm');

  // 이미지 삭제
  function deleteImage(imageId) {
    const tile = document.getElementById("tile-" + imageId);
    if (tile) tile.remove();

    const hidden = document.createElement("input");
    hidden.type = "hidden";
    hidden.name = "deleteImageIds";
    hidden.value = imageId;
    form.appendChild(hidden);

    updateThumbnailBadges();
    createAddTile();
  }

  // 새 이미지 추가 버튼
  function createAddTile() {
    const count = tiles.querySelectorAll('.tile').length;
    if (count >= MAX_IMAGES) return;
    if ([...tiles.children].some(t => !t.querySelector('img'))) return;

    const tile = document.createElement('div');
    tile.className = 'tile';

    const input = document.createElement('input');
    input.type = 'file';
    input.name = 'imageFiles'; // 여러개 업로드 → name 동일
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

  // 파일 선택 미리보기
  function handleFileSelect(tile, input) {
    if (!input.files || !input.files[0]) return;
    const file = input.files[0];

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
      tile.remove();
      updateThumbnailBadges();
      createAddTile();
    });

    tile.appendChild(preview);
    tile.appendChild(remove);

    updateThumbnailBadges();
    createAddTile();
  }

  // 썸네일(첫 번째 이미지) 갱신
  function updateThumbnailBadges() {
    tiles.querySelectorAll('.badge').forEach(b => b.remove());
    const firstPreviewTile = [...tiles.children].find(t => t.querySelector('img'));
    if (firstPreviewTile) {
      const badge = document.createElement('div');
      badge.className = 'badge';
      badge.textContent = '썸네일';
      firstPreviewTile.appendChild(badge);
    }
  }

  // 초기 실행
  if (tiles.querySelectorAll('.tile').length < MAX_IMAGES) {
    createAddTile();
  }
</script>
