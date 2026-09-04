<%@ page language="java" contentType="text/html; charset=UTF-8"
  pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp">
  <jsp:param value="Home" name="title" />
</jsp:include>

<style>
:root {
  --bg: #fff;
  --card: #fff;
  --text: #111;
  --muted: #8a8f98;
  --primary: #333333;
  --line: #dfe3ea;
  --shadow: 0 8px 24px rgba(0, 0, 0, .08);
}

* {
  box-sizing: border-box;
}

.wrap {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.topbar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
}

.back-btn {
  border: none;
  background-color: #fff;
  font-size: 20px;
  color: #333;
  cursor: pointer;
}

.title {
  font-weight: 700;
  font-size: 20px;
}

/* 프로필 카드 */
.profile {
  display: flex;
  align-items: center;
  gap: 16px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 16px;
  box-shadow: var(--shadow);
}

.avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  overflow: hidden;
  flex: 0 0 64px;
  border: 2px solid #eee;
  background: #fafafa;
  cursor: pointer;
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.who {
  flex: 1;
}

.nick {
  font-weight: 700;
  font-size: 18px;
}

/* 포인트 카드 — 살짝 컴팩트 */
.point-card {
  margin-top: 18px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 20px;
  padding: 18px;
  box-shadow: var(--shadow);
}

.point-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.point-title {
  font-weight: 800;
  font-size: 18px;
}

.point-row {
  display: flex;
  align-items: center;
  justify-content: space-between; 
  gap: 12px;
  margin: 8px 0 16px;
}

.p-icon {
  position: relative;
  display: inline-block;
  font-size: 28px; 
}

.p-icon .fa-circle {
  color: #FFD43B; 
}

.p-icon .letter {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -55%); 
  font-size: 22px;   
  font-weight: 700;
  color: #fff;       
  font-family: 'Arial', sans-serif;
  font-style: italic;
}

.point-amount{
  display:flex;
  align-items:center;
  gap:12px;
}

.p-amount{
  font-size:28px;      
  font-weight:800;     
  line-height:1;
  white-space:nowrap;  
}

.charge { width: auto; height: 44px; padding: 0 16px; border-radius: 12px; }

.charge-inline {
  height: 44px;           
  padding: 0 16px;       
  border-radius: 12px;   
}

.charge:active {
  transform: translateY(1px);
}
.fa-heart {color: #d94164; font-size: 18px;}

/* 반응형 */
@media (min-width: 768px) {
  .avatar {
    width: 72px;
    height: 72px;
  }
  .p-amount {
    font-size: 32px;
    font-weight:600;
  }
}

/* 액션 카드 (내역 보기) */
.action-grid {
  width: 100%;
  max-width: 1200px;
  display: grid;
  gap: 12px;
}

.action-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 16px;
  box-shadow: var(--shadow);
}

.action-title {
  font-weight: 700;
  font-size: 16px;
}

.action-desc {
  color: var(--muted);
  font-size: 13px;
  margin-top: 4px;
}

.action-btn {
  height: 44px;
  padding: 0 16px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  background: #fff;
  color: var(--text);
  font-weight: 800;
  border: 1px solid var(--line);
  box-shadow: none;
}

.action-btn:active {
  transform: translateY(1px);
}
</style>

<div class="wrap">
  <div class="topbar">
    <button class="back-btn" onclick="history.back()" aria-label="뒤로가기">
      <i class="fa-solid fa-arrow-left"></i>
    </button>
    <div class="title">마이페이지</div>
  </div>

  <!-- 프로필 -->
  <div class="profile">
    <div class="avatar">
      <c:choose>
        <c:when test="${not empty user.profileImageKey}">
          <img src="https://jscode-upload-images.s3.ap-northeast-2.amazonaws.com/${user.profileImageKey}"
               alt="프로필 이미지"
               onerror="this.src='${contextPath}/resources/image/profile-default.png'">
        </c:when>
        <c:otherwise>
          <img src="${contextPath}/resources/image/profile-default.png" alt="프로필 이미지">
        </c:otherwise>
      </c:choose>
      
    </div>
    <div class="who">
      <div class="nick">${user.nickName != null ? user.nickName : 'happy'}</div>
    </div>
    <button class="action-btn" type="button" onclick="location.href='${contextPath}/user/checkPassword'">프로필 수정</button>
  </div>
  
    <!-- 프로필 이미지 업로드 폼 (숨김) -->
  <form id="avatarForm"
        action="${contextPath}/user/profile/image"
        method="post"
        enctype="multipart/form-data"
        style="display:none">
    <input id="avatarFile" type="file" name="file" accept="image/*">
  </form>
  
  
    <!-- 찜 목록 카드 -->
  <div class="action-card" style="margin-top: 18px;">
    <div>
      <div class="action-title"><i class="fa-solid fa-heart"></i> 찜 목록</div>
      <div class="action-desc">내가 찜한 상품을 확인해보세요</div>
    </div>
    <button class="action-btn" type="button" onclick="location.href='${contextPath}/wish/list?userId=${user.userId}'">목록 보기</button>
  </div>
  

  <!-- 포인트 충전 -->
  <div class="point-card">
    <div class="point-head">
      <div class="point-title">포인트</div>
    </div>
    <div class="point-row">
      <div class="point-amount">
        <div class="p-icon"><i class="fa-solid fa-circle"></i><span class="letter">p</span></div>
        <div class="p-amount">
          <c:choose>
            <c:when test="${not empty user.point}">
              <fmt:formatNumber value="${user.point}" type="number" />
            </c:when>
            <c:otherwise>0</c:otherwise>
          </c:choose>
        </div>
      </div>
    
      <button class="action-btn charge-inline" type="button"
              onclick="location.href='${contextPath}/payment/paymentForm'">충전하기</button>
    </div>
        
  </div>

  <!-- 포인트 충전 내역 -->
  <div class="action-card" style="margin-top: 18px;">
    <div>
      <div class="action-title">포인트 충전 내역</div>
      <div class="action-desc">최근 충전 기록을 확인하세요</div>
    </div>
    <button class="action-btn" type="button"
            onclick="location.href='${contextPath}/payment/history'">
      내역 보기
    </button>
  </div>
  
  <!-- 판매 내역 -->
  <div class="action-card" style="margin-top: 18px;">
    <div>
      <div class="action-title">판매 내역</div>
      <div class="action-desc">내가 판매한 기록을 확인하세요</div>
    </div>
    <button class="action-btn" type="button"
            onclick="location.href='${contextPath}/trade/history?userId=${user.userId}&type=sell'">
      내역 보기
    </button>
  </div>
  
  <!-- 구매 내역 -->
  <div class="action-card" style="margin-top: 18px;">
    <div>
      <div class="action-title">구매 내역</div>
      <div class="action-desc">내가 구매한 기록을 확인하세요</div>
    </div>
    <button class="action-btn" type="button"
            onclick="location.href='${contextPath}/trade/history?userId=${user.userId}&type=buy'">
      내역 보기
    </button>
  </div>
  
  <!-- 나한테 달린 후기 -->
  <div class="action-card" style="margin-top: 18px;">
    <div>
      <div class="action-title">다른 사람의 후기</div>
      <div class="action-desc">내 상품에 대한 다른 사람의 후기를 확인하세요</div>
    </div>
    <button class="action-btn" type="button"
            onclick="location.href='${contextPath}/review/showOther'">
      후기 보기
    </button>
  </div>
  
  <!-- 내가 쓴 후기 -->
  <div class="action-card" style="margin-top: 18px;">
    <div>
      <div class="action-title">내 후기</div>
      <div class="action-desc">내가 쓴 후기를 확인하세요</div>
    </div>
    <button class="action-btn" type="button"
            onclick="location.href='${contextPath}/review/showMy'">
      후기 보기
    </button>
  </div>
</div>

<script>
  (function () {
    const avatarBox = document.querySelector(".profile .avatar");
    const fileInput = document.getElementById("avatarFile");
    const form = document.getElementById("avatarForm");

    if (!avatarBox || !fileInput || !form) return;

    // 1) 아바타 클릭 -> 파일 선택 창
    avatarBox.addEventListener("click", function () {
      fileInput.click();
    });

    // 2) 파일 선택 즉시 업로드
    fileInput.addEventListener("change", function () {
      const file = fileInput.files && fileInput.files[0];
      if (!file) return;

      // (선택) 간단 검증: 타입/크기
      const okTypes = ["image/jpeg", "image/png", "image/webp"];
      if (!okTypes.includes(file.type)) {
        alert("JPG/PNG/WEBP만 업로드 가능합니다.");
        fileInput.value = "";
        return;
      }
      const MAX = 2 * 1024 * 1024; // 2MB 예시
      if (file.size > MAX) {
        alert("파일이 너무 큽니다. 최대 2MB까지 가능합니다.");
        fileInput.value = "";
        return;
      }
      
      form.submit(); // 바로 업로드
    });
  })();
</script>

</body>
</html>