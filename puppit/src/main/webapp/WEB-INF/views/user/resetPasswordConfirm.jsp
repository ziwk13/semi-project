<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp">
  <jsp:param value="Home" name="title" />
</jsp:include>

<!-- user/find.jsp 와 동일한 카드 스타일 (재설정 2단계: 새 비밀번호 입력) -->
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
.main-content{
  background: var(--page-bg);
  padding: 32px 20px;
  box-sizing: border-box;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 120px);
}
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
.title { text-align:center; font-size:1.125rem; font-weight:700; margin: 0 0 18px 0; color: #0f172a; }
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
  margin-bottom: 12px;
}
.form-group input::placeholder { color: #bfc7d1; }
.form-group input:focus { border-color: rgba(92, 53, 255, 0.9); box-shadow: 0 8px 22px rgba(92,53,255,0.06); }
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
.msg { margin-top:10px; text-align:center; font-size:0.9rem; color:var(--danger); }
@media (max-width: 520px){
  .main-content { padding:20px 12px; min-height: calc(100vh - 160px); }
  .find-wrap { padding:18px; border-radius:12px; }
  .title { font-size:1rem; }
}
</style>

<main class="main-content" id="mainContent">
  <div class="find-wrap" role="region" aria-labelledby="resetTitle">
    <h1 id="resetTitle" class="title">새 비밀번호 설정</h1>

    <form id="form-reset-confirm" action="${contextPath}/user/reset-password/confirm" method="post" class="find-form" novalidate>
      <input type="hidden" name="token" value="${token}">
      <div class="form-group">
        <input type="password" name="userPassword" id="userPassword" placeholder="새 비밀번호" minlength="8" required autocomplete="new-password">
      </div>
      <div class="form-group">
        <input type="password" name="confirmPassword" id="confirmPassword" placeholder="새 비밀번호 확인" minlength="8" required autocomplete="new-password">
      </div>
      <button type="submit" class="btn-primary">비밀번호 변경</button>
    </form>

    <div class="msg" id="resultMsg">${msg}</div>
  </div>
</main>

<script>
(function () {
  function adjustMain() {
    var header = document.querySelector('.header');
    var main = document.getElementById('mainContent');
    if (!main) return;
    var headerHeight = header ? Math.ceil(header.getBoundingClientRect().height) : 0;
    main.style.minHeight = 'calc(100vh - ' + Math.max(headerHeight, 0) + 'px)';
  }
  window.addEventListener('load', adjustMain);
  window.addEventListener('resize', adjustMain);

  var form = document.getElementById('form-reset-confirm');
  form.addEventListener('submit', function (e) {
    var np = document.getElementById('userPassword').value;
    var cp = document.getElementById('confirmPassword').value;
    if (np !== cp) {
      e.preventDefault();
      document.getElementById('resultMsg').textContent = '비밀번호가 일치하지 않습니다.';
    }
  });
})();

(function showMsg(){
  const msg = "${msg}";
  if (msg && msg.trim() !== "") setTimeout(()=>alert(msg), 50);
})();
</script>
