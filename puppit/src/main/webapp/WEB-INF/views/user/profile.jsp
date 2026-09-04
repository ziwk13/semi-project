<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp"></jsp:include>


<style>
  :root {
    --bg:#fff; --card:#fff; --text:#111; --muted:#6b7280;
    --line:#e5e7eb; --primary:#333333; --shadow:0 12px 28px rgba(0,0,0,.08);
  }
  body { background:var(--bg); }

  .profile-card{
    max-width:760px; margin:24px auto; padding:24px;
    background:var(--card); border-radius:16px; box-shadow:var(--shadow);
  }

  .profile-table{
    width:100%; border-collapse:separate; border-spacing:0;
    border:1px solid var(--line); border-radius:12px; overflow:hidden;
  }
  .profile-table th, .profile-table td{ padding:14px 16px; }
  .profile-table th{
    width:160px; background:#f9fafb; color:#374151; text-align:left; font-weight:700;
    border-bottom:1px solid #f1f5f9;
  }
  .profile-table td{ border-bottom:1px solid #f1f5f9; }
  .profile-table tr:last-child th,
  .profile-table tr:last-child td{ border-bottom:none; }

  .form-row{ display:flex; gap:8px; align-items:center; }
  .form-row input[type="text"]{
    flex:1 1 auto; height:42px; padding:0 12px;
    border:1px solid #d1d5db; border-radius:10px; font-size:14px; color:var(--text);
    outline:none; background:#fff;
  }
  .form-row input[type="text"]:focus{
    border-color:#111; box-shadow:0 0 0 3px rgba(0,0,0,.08);
  }

  .button{ height:42px; padding:0 14px; border:none; border-radius:10px;
           font-weight:700; cursor:pointer; }
  .button-check{ background:#eef2ff; color:#1f2937; border:1px solid #c7d2fe; }
  .button-check:hover{ background:#e0e7ff; }

  /* 수정 버튼 (form 밖) */
  #btn-submit{
    height:50px; padding:0 16px; border-radius:12px;
    font-size:16px; font-weight:800; color:#fff; background:var(--primary);
    border:none; cursor:pointer;
  }
  #btn-submit:hover{ filter:brightness(1.08); }

  /* 버튼 배치용 래퍼 (폼 밖) */
  .actions {
    display:flex; gap:12px; align-items:center; justify-content:flex-start;
    max-width:760px; margin:12px auto 0 auto;
  }

  /* 탈퇴 버튼 (outline-danger 톤) */
  #btn-delete{
    height:50px; padding:0 16px; border-radius:12px; font-size:16px; font-weight:800;
    background:#fff; color:#b91c1c; border:1px solid #ef4444; cursor:pointer;
  }
  #btn-delete:hover{ background:#fee2e2; }

  /* 탈퇴 확인 박스 */
  .danger-box{
    max-width:760px; margin:12px auto 0 auto; padding:16px;
    border:1px solid #fecaca; background:#fff1f2; border-radius:12px;
    display:none;
  }
  .danger-title{ margin:0 0 8px; color:#991b1b; font-weight:800; }
  .danger-desc{ margin:0 0 10px; color:#7f1d1d; font-size:.95rem; }
  .danger-row{ display:flex; gap:8px; align-items:center; }
  #agreementInput{
    flex:1 1 auto; height:44px; padding:0 12px; border:1px solid #fca5a5; border-radius:10px;
    background:#fff; outline:none; font-size:14px;
  }
  #agreementInput:focus{ border-color:#ef4444; box-shadow:0 0 0 3px rgba(239,68,68,.15); }
  #btn-confirm-delete{
    height:44px; padding:0 14px; border-radius:10px; border:none; cursor:pointer;
    background:#dc2626; color:#fff; font-weight:800;
  }
  #btn-confirm-delete:hover{ filter:brightness(1.05); }

  @media (max-width:600px){
    .profile-table th{ width:120px; }
    .form-row{ flex-direction:column; align-items:stretch; }
    .button-check{ width:100%; }
    .danger-row{ flex-direction:column; align-items:stretch; }
  }
  .title {
    font-size: 22px;
    font-weight: 800;
    padding: 0 430px;
  }
</style>

<div class="title">프로필 페이지</div>

<div class="profile-card">
  <form id="profileForm" action="${contextPath}/user/profile" method="post">
    <table class="profile-table">
      <tr>
        <th>아이디</th>
        <td>
          <div class="form-row">
            <input id="accountId" type="text" name="accountId" value="${sessionScope.sessionMap.accountId}" readOnly>
          </div>
        </td>
      </tr>
      <tr>
        <th>이름</th>
        <td>
          <div class="form-row">
            <input type="text" name="userName" value="${sessionScope.sessionMap.userName}">
          </div>
        </td>
      </tr>
      <tr>
        <th>닉네임</th>
        <td>
          <div class="form-row">
            <input id="nickName" type="text" name="nickName" value="${sessionScope.sessionMap.nickName}">
            <button type="button" class="button button-check" id="checkNickNameBtn">중복확인</button>
          </div>
        </td>
      </tr>
      <tr>
        <th>이메일</th>
        <td>
          <div class="form-row">
            <input id="userEmail" type="text" name="userEmail" value="${sessionScope.sessionMap.userEmail}">
            <button type="button" class="button button-check" id="checkEmailBtn">중복확인</button>
          </div>
        </td>
      </tr>
    </table>
  </form>
</div>

<!-- 폼 밖: 수정/탈퇴 액션 -->
<div class="actions">
  <!-- 수정: JS로 profileForm submit -->
  <button id="btn-submit" type="button" class="button">수정</button>

  <!-- 회원 탈퇴: 별도의 POST 폼 (문구 입력만) -->
  <form id="deleteForm" action="${contextPath}/user/delete" method="post" style="display:inline;">
    <input type="hidden" name="agreement" id="agreementHidden">
    <c:if test="${not empty _csrf}">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
    </c:if>
    <button type="button" id="btn-delete">회원 탈퇴</button>
  </form>
</div>

<!-- 탈퇴 확인 박스 (문구 입력) -->
<div id="dangerBox" class="danger-box" aria-hidden="true">
  <h3 class="danger-title">탈퇴 전 최종 확인</h3>
  <p class="danger-desc">아래 문구를 정확히 입력해야 탈퇴가 진행됩니다.</p>
  <p class="danger-desc"><strong>회원 탈퇴 하겠습니다 이에 동의 합니다</strong></p>
  <div class="danger-row">
    <input type="text" id="agreementInput" placeholder="위 문구를 입력해주세요">
    <button type="button" id="btn-confirm-delete">탈퇴 진행</button>
  </div>
</div>

<script type="text/javascript">
  const initial = {
		  nickname: document.getElementById("nickName").defaultValue,
		  email: document.getElementById("userEmail").defaultValue
  };
  
  const elNick = document.getElementById("nickName");
  const elEmail = document.getElementById("userEmail");
  
  let nicknameChecked = false;
  let emailChecked = false;

  // 닉네임 중복 검사
  document.getElementById("checkNickNameBtn").addEventListener("click", function(e) {
    const nickName = document.getElementById("nickName").value.trim();
    if(!nickName) { alert("닉네임을 입력 해주세요"); return; }
    const isRegex = /^[A-Za-z0-9\uAC00-\uD7A3]{4,8}$/;
    if(!isRegex.test(nickName)) { alert("닉네임은 한글/영문/숫자 포함 4~8자 입니다"); return; }

    fetch("${contextPath}/user/check?nickName=" + encodeURIComponent(nickName))
      .then(response => {
        if(response.status === 200) { alert('사용 가능한 닉네임 입니다.'); nicknameChecked = true; return; }
        else if(response.status === 409) { alert('중복된 닉네임 입니다.'); return; }
      });
  });

  // 이메일 중복 검사
  document.getElementById("checkEmailBtn").addEventListener("click", function(e) {
    const userEmail = document.getElementById("userEmail").value.trim();
    if(!userEmail) { alert("이메일을 입력 해주세요"); return; }
    const isRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if(!isRegex.test(userEmail)) { alert("이메일 형식이 올바르지 않습니다"); return; }

    fetch("${contextPath}/user/check?userEmail=" + encodeURIComponent(userEmail))
      .then(response => {
        if(response.status === 200) { alert('사용 가능한 이메일 입니다'); emailChecked = true; return; }
        else if(response.status === 409) { alert('중복된 이메일 입니다'); return; }
      });
  });


    elNick.addEventListener("input", () => {
      if (elNick.value !== initial.nickname) nicknameChecked = false;
    });
    elEmail.addEventListener("input", () => {
      if (elEmail.value !== initial.email) emailChecked = false;
    });

  // 수정 (form 밖 버튼 → form submit)
  document.getElementById("btn-submit").addEventListener("click", e => {
	  const currNick = document.getElementById("nickName").value;
	  const currEmail = document.getElementById("userEmail").value;
	  
    if((!nicknameChecked && initial.nickname != currNick) || (!emailChecked && initial.email != currEmail)) {
      if(!nicknameChecked && initial.nickname != currNick) alert("닉네임 중복확인을 해주세요");
      else if(!emailChecked && initial.email != currEmail) alert("이메일 중복확인을 해주세요");
      return;
    }
    document.getElementById("profileForm").submit();
  });

  // 회원 탈퇴 플로우 (문구 입력 박스 토글)
  const PHRASE = "회원 탈퇴 하겠습니다 이에 동의 합니다";
  const dangerBox = document.getElementById("dangerBox");
  const agreementInput = document.getElementById("agreementInput");
  const agreementHidden = document.getElementById("agreementHidden");

  document.getElementById("btn-delete").addEventListener("click", function() {
    const visible = dangerBox.style.display === "block";
    dangerBox.style.display = visible ? "none" : "block";
    dangerBox.setAttribute("aria-hidden", visible ? "true" : "false");
    if (!visible) {
      agreementInput.value = "";
      setTimeout(() => agreementInput.focus(), 0);
    }
  });

  // 최종 탈퇴 진행
  document.getElementById("btn-confirm-delete").addEventListener("click", function() {
    const val = agreementInput.value.trim();
    if (val !== PHRASE) {
      alert("동의 문구가 정확히 일치해야 합니다.");
      agreementInput.focus();
      return;
    }
    if (!confirm("정말 탈퇴하시겠습니까? 복구할 수 없습니다.")) return;

    agreementHidden.value = val;
    document.getElementById("deleteForm").submit();
  });
</script>
</body>
</html>