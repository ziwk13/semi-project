<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp">
  <jsp:param value="Home" name="title" />
</jsp:include>


<!-- ✅ 소셜 로그인은 JSP에서도 바로 리다이렉트 -->
<c:if test="${not empty sessionScope.sessionMap.provider}">
  <c:redirect url="${contextPath}/user/profile"/>
</c:if>

<title>비밀번호 재확인</title>

<style>
  .pwd-check{
    --page-bg:#f6f8fb; --card-bg:#fff;
    --accent-1:#5b21b6; --accent-2:#7c3aed;
    --muted:#6b7280; --danger:#dc2626; --ok:#16a34a;
    --border:#e5e7eb; --shadow:0 10px 30px rgba(17,24,39,.08);
    font-family:system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
    color:#111827; background:var(--page-bg);
  }
  .pwd-check *{ box-sizing:border-box; }

  #pwdCheckMain{
    min-height:calc(100vh - 80px);
    display:flex; align-items:center; justify-content:center;
    padding:24px 16px;
  }
  .pc-card{
    width:100%; max-width:420px; background:var(--card-bg); border:1px solid var(--border);
    border-radius:20px; padding:28px; box-shadow:var(--shadow);
  }
  .pc-title{ margin:0 0 16px; font-size:1.6rem; font-weight:800; text-align:center; }
  .pc-desc{ margin:0 0 18px; color:var(--muted); text-align:center; font-size:.95rem; }
  .pc-field{ display:flex; flex-direction:column; gap:8px; margin-top:10px; }
  .pc-input{
    width:100%; height:44px; padding:0 14px; border:1px solid var(--border); border-radius:12px;
    background:#fff; outline:none; font-size:1rem;
  }
  .pc-input:focus{ border-color:#c4b5fd; box-shadow:0 0 0 4px rgba(124,58,237,.15) }
  .pc-btn{
    width:100%; height:46px; margin-top:14px; border:0; border-radius:12px; cursor:pointer;
    background:linear-gradient(90deg,var(--accent-1),var(--accent-2)); color:#fff;
    font-size:1rem; font-weight:700;
  }
  .pc-msg{ margin-top:12px; text-align:center; font-size:.92rem; display:block; min-height:1.2em; }
  .pc-msg.error{ color:var(--danger); }
  .pc-msg.ok{ color:var(--ok); }
</style>

<div class="pwd-check">
  <main id="pwdCheckMain">
    <div class="pc-card">
      <h1 class="pc-title">비밀번호 재확인</h1>
      <p class="pc-desc">마이페이지로 이동하기 전, 비밀번호를 한 번 더 확인할게요.</p>

      <!-- 동기 제출: 컨트롤러 @PostMapping("/checkPassword")와 일치 -->
      <form method="post" action="${contextPath}/user/checkPassword">
        <!-- Spring Security 사용 시 CSRF 토큰 hidden으로 포함 -->
        <c:if test="${not empty _csrf}">
          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
        </c:if>

        <div class="pc-field">
          <input class="pc-input" type="password" name="userPassword" id="userPassword"
                 placeholder="비밀번호" autocomplete="current-password" required />
        </div>
        <button class="pc-btn" type="submit">확인</button>
      </form>

      <!-- 리다이렉트로 넘어온 flash 메시지 인라인 표시 -->
      <c:choose>
        <c:when test="${not empty error}">
          <div class="pc-msg error">${error}</div>
        </c:when>
        <c:when test="${not empty msg}">
          <!-- 현재 컨트롤러는 '비밀번호가 일치하지 않습니다'도 msg로 넘기므로 error 스타일로 -->
          <div class="pc-msg error">${msg}</div>
        </c:when>
        <c:otherwise>
          <div class="pc-msg">&nbsp;</div>
        </c:otherwise>
      </c:choose>
    </div>
  </main>
</div>

<script>
  // 헤더 실제 높이로 중앙 정렬 보정
  (function(){
    var main = document.getElementById('pwdCheckMain');
    var header =
      document.querySelector('.site-header .container') ||
      document.querySelector('.site-header') ||
      document.querySelector('header');
    var h = header ? Math.ceil(header.getBoundingClientRect().height) : 0;
    main.style.minHeight = 'calc(100vh - ' + h + 'px)';
  })();
</script>