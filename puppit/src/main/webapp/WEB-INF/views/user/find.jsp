<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp">
  <jsp:param value="Home" name="title" />
</jsp:include>

<!-- 페이지 전용 스타일: 전역 body를 건드리지 않고, 메인 영역만 가운데 정렬 -->
<style>
:root{
  --page-bg: #f6f8fb;
  --card-bg: #ffffff;
  --accent-1: #5b21b6;
  --accent-2: #7c3aed;
  --muted: #6b7280;
  --danger: #dc2626;
  --radius: 14px;
  --shadow: 0 12px 28px rgba(15,23,42,0.06);
  --maxw: 480px;
  font-family: "Noto Sans KR", "Segoe UI", Roboto, -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial;
}

/* 메인 영역만 배경 + 중앙정렬 — header 높이에 따라 자동 보정(아래 JS 참고) */
.main-content{
  background: var(--page-bg);
  padding: 32px 20px;
  box-sizing: border-box;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 120px); /* 헤더 높이 대략값 — JS가 런타임에 보정함 */
}

/* 카드 */
.find-wrap{
  width:100%;
  max-width:var(--maxw);
  background: var(--card-bg);
  border-radius: calc(var(--radius) + 4px);
  padding: 28px;
  box-shadow: var(--shadow);
  box-sizing: border-box;
  margin-top: -250px;
}

/* 제목 */
.title {
  text-align:center;
  font-size:1.125rem;
  font-weight:700;
  margin: 0 0 18px 0;
  color: #0f172a;
}

/* 폼 */
.find-form input{
  width:100%;
  padding:12px 16px;
  font-size:0.98rem;
  border-radius:10px;
  border:1px solid #e6e9ee;
  outline:none;
  background:#fff;
  transition: box-shadow .14s ease, border-color .14s ease;
  box-sizing: border-box;
}
.form-group input::placeholder { color: #bfc7d1; }
.form-group input:focus { border-color: rgba(92, 53, 255, 0.9); box-shadow: 0 8px 22px rgba(92,53,255,0.06); }

/* 버튼 */
.btn-primary{
  width:100%;
  padding:12px 16px;
  font-weight:700;
  font-size:1rem;
  color:#fff;
  border:none;
  border-radius:10px;
  cursor:pointer;
  background: linear-gradient(90deg, var(--accent-1), var(--accent-2));
  box-shadow: 0 10px 22px rgba(124,58,237,0.18);
}
.btn-primary:active { transform: translateY(0); opacity: .98; }

/* 메시지 영역 */
.msg { margin-top:10px; text-align:center; font-size:0.9rem; color:var(--danger); }

/* 반응형 */
@media (max-width: 520px){
  .main-content { padding:20px 12px; min-height: calc(100vh - 160px); }
  .find-wrap { padding:18px; border-radius:12px; }
  .title { font-size:1rem; }
}
.tab-buttons{
  display:flex; gap:6px; margin:0 0 14px 0; justify-content:center;
}
.tab-btn{
  padding:8px 14px; border-radius:10px; border:1px solid #e6e9ee;
  background:#fff; cursor:pointer; font-weight:600; font-size:.95rem;
}
.tab-btn.is-active{
  color:#fff; border-color:transparent;
  background: linear-gradient(90deg, var(--accent-1), var(--accent-2));
  box-shadow: 0 10px 22px rgba(124,58,237,0.18);
}
.tab-panel.is-hidden{ display:none; }
</style>

<main class="main-content" id="mainContent">
  <div class="find-wrap" role="region" aria-labelledby="findTitle">
    <h1 id="findTitle" class="title">아이디/비밀번호 찾기</h1>

    <!-- 탭 버튼 -->
    <div class="tab-buttons" role="tablist" aria-label="아이디/비밀번호 선택">
      <button type="button" class="tab-btn is-active" role="tab" aria-selected="true" aria-controls="panel-find-id" id="tab-find-id">
        아이디 찾기
      </button>
      <button type="button" class="tab-btn" role="tab" aria-selected="false" aria-controls="panel-reset-pw" id="tab-reset-pw">
        비밀번호 변경
      </button>
    </div>

    <!-- 아이디 찾기 -->
    <section id="panel-find-id" class="tab-panel" role="tabpanel" aria-labelledby="tab-find-id">
      <form id="form-find-id" action="${contextPath}/user/find" method="post" class="find-form" novalidate>
        <div class="form-group">
          <input type="text" name="userName" id="userName" placeholder="이름" required autocomplete="name">
        </div>
        <div class="form-group">
          <input type="email" name="userEmail" id="userEmail" placeholder="이메일" required autocomplete="email">
        </div>
        <button type="submit" class="btn-primary">아이디 찾기</button>
      </form>
    </section>

    <!-- 비밀번호 변경 (아이디만 알고 있는 간단 버전) -->
    <section id="panel-reset-pw" class="tab-panel is-hidden" role="tabpanel" aria-labelledby="tab-reset-pw" aria-hidden="true">
      <form id="form-reset-pw" action="${contextPath}/user/reset-password" method="post" class="find-form" novalidate>
        <div class="form-group">
          <input type="text" name="accountId" id="accountId" placeholder="아이디" required autocomplete="username">
        </div>
        <div class="form-group">
          <input type="password" name="userPassword" id="userPassword" placeholder="새 비밀번호 (대문자 1개 포함, 영문/숫자/!@#만, 6~10자)" minlength="8" required autocomplete="new-password">
        </div>
        <div class="form-group">
          <input type="password" name="confirmPassword" id="confirmPassword" placeholder="새 비밀번호 확인" minlength="8" required autocomplete="new-password">
        </div>
        <button type="submit" class="btn-primary">비밀번호 변경</button>
      </form>
      <p class="msg" id="pwHelp">※ 보안을 위해 추후에 현재 비밀번호 확인/이메일 인증을 추가하는 것을 추천합니다.</p>
    </section>

    <div class="msg" id="resultMsg">${msg}</div>
  </div>
</main>

<!-- 헤더 높이에 따라 main 높이 보정 (헤더가 .header 클래스를 가질 때 작동) -->
<script>
(function () {
  // 헤더 높이 보정
  function adjustMain() {
    var header = document.querySelector('.header');
    var main = document.getElementById('mainContent');
    if (!main) return;
    var headerHeight = header ? Math.ceil(header.getBoundingClientRect().height) : 0;
    main.style.minHeight = 'calc(100vh - ' + Math.max(headerHeight, 0) + 'px)';
  }
  window.addEventListener('load', adjustMain);
  window.addEventListener('resize', adjustMain);

  // 탭 토글
  var tabId = document.getElementById('tab-find-id');
  var tabPw = document.getElementById('tab-reset-pw');
  var panelId = document.getElementById('panel-find-id');
  var panelPw = document.getElementById('panel-reset-pw');

  function activate(tabBtn, panel, otherBtn, otherPanel) {
    tabBtn.classList.add('is-active');
    tabBtn.setAttribute('aria-selected', 'true');
    panel.classList.remove('is-hidden');
    panel.removeAttribute('aria-hidden');

    otherBtn.classList.remove('is-active');
    otherBtn.setAttribute('aria-selected', 'false');
    otherPanel.classList.add('is-hidden');
    otherPanel.setAttribute('aria-hidden', 'true');
  }

  tabId.addEventListener('click', function () {
    activate(tabId, panelId, tabPw, panelPw);
  });
  tabPw.addEventListener('click', function () {
    activate(tabPw, panelPw, tabId, panelId);
  });

  // 비밀번호 확인 간단 검증
  var formPw = document.getElementById('form-reset-pw');
  if (formPw) {
    formPw.addEventListener('submit', function (e) {
      var np = document.getElementById('userPassword').value;
      var cp = document.getElementById('confirmPassword').value;
      if (np !== cp) {
        e.preventDefault();
        document.getElementById('resultMsg').textContent = '비밀번호가 일치하지 않습니다.';
      }
    });
  }
  var activeTab = '${activeTab}';
  if (activeTab === 'resetPw') {
    activate(tabPw, panelPw, tabId, panelId);
  }
})();

// 서버 메시지 alert 처리
(function showMsg(){
  const msg = "${msg}";
  if (msg && msg.trim() !== "") setTimeout(()=>alert(msg), 50);
})();
</script>