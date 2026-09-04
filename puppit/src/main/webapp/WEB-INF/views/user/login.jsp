<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}"/>

<jsp:include page="../layout/header.jsp"/>

<c:if test="${not empty msg}">
  <div class="msg success"><c:out value="${msg}" /></div>
</c:if>

<!-- 페이지 전용 스타일 -->
<style>
  :root{
    --page-bg: #f6f8fb;
    --card-bg: #ffffff;
    --accent-1: #5b21b6;
    --accent-2: #7c3aed;
    --muted: #6b7280;
    --radius: 14px;
    --shadow: 0 12px 28px rgba(15,23,42,0.06);
    --maxw: 440px;
    font-family: "Noto Sans KR", "Segoe UI", Roboto, system-ui, Arial;
  }

  html, body {
    height: 100%;
    margin: 0;
    padding: 0;
    background: #fff;
    font-family: 'Pretendard', 'Noto Sans KR', sans-serif;
  }

  /* <-- 중요한 변경: body를 flex로 사용하지 않음 */
  body {
    background: var(--page-bg);
    /* display:flex;  <-- 제거 */
    padding: 0; /* 헤더가 있으니 상단 패딩 제거 */
    box-sizing: border-box;
  }

  /* site-main: header 아래에서 카드만 가운데 정렬 */
  .site-main {
    display:flex;
    justify-content:center;
    align-items:center;
    padding: 36px 16px;
    min-height: calc(100vh - 90px); /* header 높이(대략) — 아래 JS가 런타임에 보정 */
    box-sizing: border-box;
    /* margin-top: -250px; */
  }

  .login-wrap{
    width:100%;
    max-width:var(--maxw);
    background:var(--card-bg);
    border-radius:calc(var(--radius) + 6px);
    padding:28px;
    box-shadow:var(--shadow);
    box-sizing:border-box;
  }

  .logo { text-align:center; margin-bottom:8px; }
  .logo h1{ margin:0; font-size:1.4rem; font-weight:800; color:#0f172a; }

  .login-form { margin-top:14px; display:flex; flex-direction:column; gap:12px; }
  .field { display:flex; flex-direction:column; gap:6px; }
  .field label{ font-size:0.95rem; color:var(--muted); }
  .field input{ width:100%; padding:12px 14px; border-radius:10px; border:1px solid #e6e9ee; background:#fff; box-sizing:border-box; }
  .field input:focus{ border-color: rgba(92,53,255,0.9); box-shadow:0 8px 22px rgba(92,53,255,0.06); }

  .btn-row{ margin-top:6px; }
  .btn-primary { width:100%; padding:12px 14px; background: linear-gradient(90deg, var(--accent-1), var(--accent-2)); color:#fff; border-radius:10px; border:none; font-weight:700; box-shadow:0 10px 22px rgba(124,58,237,0.18); cursor:pointer; }

  .links{ margin-top:12px; text-align:center; color:var(--muted); font-size:0.92rem; display:flex; flex-direction:column; gap:6px; }
  .links a{ color:var(--accent-1); text-decoration:none; font-weight:600; }
  .error { margin-top:10px; color:#dc2626; text-align:center; }

  @media (max-width:420px){
    .site-main { padding:20px; }
    .login-wrap { padding:18px; }
  }
</style>

<!-- header.jsp가 include되어 header가 먼저 렌더됨 -->
<main class="site-main" id="siteMain">
  <section class="login-wrap" role="main" aria-labelledby="loginTitle">
    <div class="logo">
      <h1 id="loginTitle">Puppit 로그인</h1>
    </div>

    <form class="login-form" method="post" action="${contextPath}/user/login" onsubmit="return handleSubmit(event)">
      <div class="field">
        <label for="accountId">아이디</label>
        <input id="accountId" name="accountId" type="text" autocomplete="username" required />
      </div>

      <div class="field">
        <label for="userPassword">비밀번호</label>
        <input id="userPassword" name="userPassword" type="password" autocomplete="current-password" required />
      </div>

      <div class="btn-row">
        <button type="submit" class="btn-primary">로그인</button>
      </div>
    </form>

    <c:if test="${not empty error}">
      <div class="error">${error}</div>
    </c:if>

    <div class="links" aria-live="polite">
      <div>아이디/비밀번호를 잊으셨나요? <a href="${contextPath}/user/find">아이디/비밀번호 찾기</a></div>
      <div>Puppit이 처음이신가요? <a href="${contextPath}/user/signup">회원가입 하기</a></div>
      <div>카카오톡으로 로그인 하기</div>
    </div>
    
    <div>
      <c:url var="kakaoAuth" value="https://kauth.kakao.com/oauth/authorize">
          <c:param name="client_id" value="${kakaoApiKey}"/>
          <c:param name="redirect_uri" value="${redirectUri}"/>
          <c:param name="response_type" value="code"/>
          <c:param name="scope" value="profile_nickname,profile_image"/>
      </c:url>
      <a href="${kakaoAuth}">
        <img src="${contextPath}/resources/image/kakao-login-medium-wide.png" alt="카카오로그인" style="display: block; margin: 0 auto;"/>
      </a>
    </div>
  </section>
</main>

<script>
  function handleSubmit(e){ return true; }

  // 헤더 높이에 따라 main 높이 보정 (동적으로 계산)
  (function adjustMain(){
    var headerContainer = document.querySelector('.site-header .container');
    var main = document.getElementById('siteMain');
    if (!main) return
    var headerHeight = headerContainer ? Math.ceil(headerContainer.getBoundingClientRect().height) : 0;
    main.style.minHeight = 'calc(100vh - ' + headerHeight + 'px)';
  })();

  // 서버 메시지 alert 처리
  (function showMsg(){
    const msg = "${msg}";
    if (msg && msg.trim() !== "") setTimeout(()=>alert(msg), 50);
  })();
</script>
</body>
</html>