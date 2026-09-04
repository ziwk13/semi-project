<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Puppit 회원가입</title>

<style>
:root{
  --page-bg:#f6f8fb; --card-bg:#fff;
  --accent-1:#5b21b6; --accent-2:#7c3aed;
  --muted:#6b7280; --danger:#dc2626; --ok:#059669; --info:#475569;
  --radius:14px; --shadow:0 14px 30px rgba(15,23,42,.06);
  --maxw:720px; --gap:14px;
  font-family:"Noto Sans KR",system-ui,Segoe UI,Roboto,Arial;
}
html,body{height:100%;margin:0}
body{background:var(--page-bg);color:#0f172a}

/* 중앙 카드 */
.site-main{min-height:100vh;display:flex;justify-content:center;align-items:center;padding:36px 16px;box-sizing:border-box}
.signup-card{width:100%;max-width:var(--maxw);background:var(--card-bg);border-radius:calc(var(--radius)+4px);box-shadow:var(--shadow);padding:28px;box-sizing:border-box}
.signup-card h1{margin:0 0 8px;font-size:1.5rem;font-weight:800}
.section-title{margin:10px 0 14px;font-size:1.125rem;font-weight:700}

/* 그리드 */
.form-grid{display:grid;grid-template-columns:1fr 1fr;gap:var(--gap);align-items:start}
.full{grid-column:1 / -1}

/* 필드 */
.field{display:flex;flex-direction:column;gap:6px}
.field label{font-size:.95rem;color:var(--muted)}
.input{padding:12px 14px;border:1px solid #e6e9ee;border-radius:10px;background:#fff;font-size:.95rem;outline:none;box-sizing:border-box;transition:border-color .15s, box-shadow .15s}
.input:focus{border-color:rgba(92,53,255,.9);box-shadow:0 8px 22px rgba(92,53,255,.06)}
.is-valid{border-color:rgba(5,150,105,.9)}
.is-invalid{border-color:rgba(220,38,38,.9)}

/* 입력 + 버튼 그룹 */
.input-row{display:flex;align-items:stretch;gap:8px}
.input-row .input{flex:1}
.check-btn{padding:12px 14px;border:1px solid #d1d5db;border-radius:10px;background:#fff;cursor:pointer;font-size:.85rem;white-space:nowrap}
.check-btn[disabled]{opacity:.6;cursor:not-allowed}

/* 피드백 메시지 */
.feedback{min-height:18px;font-size:.85rem}
.fb-info{color:var(--info)}
.fb-ok{color:var(--ok)}
.fb-err{color:var(--danger)}
.fb-loading::before{content:"";display:inline-block;width:.9em;height:.9em;margin-right:6px;border:2px solid #cbd5e1;border-top-color:#6366f1;border-radius:50%;animation:spin 0.8s linear infinite;vertical-align:-2px}
@keyframes spin{to{transform:rotate(360deg)}}

/* 제출 */
.actions{margin-top:6px}
.btn-primary{width:100%;padding:12px 14px;border:none;border-radius:10px;color:#fff;font-weight:700;background:linear-gradient(90deg,var(--accent-1),var(--accent-2));box-shadow:0 12px 26px rgba(124,58,237,.15);cursor:pointer}
.btn-primary[disabled]{opacity:.6;cursor:not-allowed}

/* 서버에서 온 에러가 있으면 상단 배너 */
.form-msg{margin-bottom:8px;padding:10px;border-radius:10px;background:#fef2f2;color:#991b1b;border:1px solid #fecaca}

/* 모바일 */
@media(max-width:820px){.form-grid{grid-template-columns:1fr}}
</style>
</head>
<body>

<main class="site-main">
  <section class="signup-card" aria-labelledby="signupTitle">
    <h1 id="signupTitle">Puppit 회원가입</h1>
    <div class="section-title">기본정보</div>

    <c:if test="${not empty error}">
      <div class="form-msg">${error}</div>
    </c:if>

    <form id="signupForm" action="${contextPath}/user/signup" method="post" novalidate>
      <div class="form-grid">

        <!-- 아이디 -->
        <div class="field">
          <label for="accountId">아이디</label>
          <div class="input-row">
            <input class="input" type="text" id="accountId" name="accountId" autocomplete="username">
            <button type="button" class="check-btn" id="checkIdBtn">중복검사</button>
          </div>
          <div class="feedback fb-info" id="accountIdMsg" aria-live="polite">영문 소문자/숫자 4~12자</div>
        </div>

        <!-- 이름 -->
        <div class="field">
          <label for="userName">이름</label>
          <input class="input" type="text" id="userName" name="userName">
          <div class="feedback" id="userNameMsg" aria-live="polite"></div>
        </div>

        <!-- 비밀번호 -->
        <div class="field">
          <label for="userPassword">비밀번호</label>
          <input class="input" type="password" id="userPassword" name="userPassword" autocomplete="new-password">
          <div class="feedback" id="userPasswordMsg" aria-live="polite">대문자 1개 포함, 영문/숫자/!@#만, 6~10자</div>
        </div>

        <!-- 비밀번호 확인 -->
        <div class="field">
          <label for="checkPwd">비밀번호 확인</label>
          <input class="input" type="password" id="checkPwd" name="checkPwd" autocomplete="new-password">
          <div class="feedback" id="checkPwdMsg" aria-live="polite"></div>
        </div>

        <!-- 닉네임 -->
        <div class="field">
          <label for="nickName">닉네임</label>
          <div class="input-row">
            <input class="input" type="text" id="nickName" name="nickName">
            <button type="button" class="check-btn" id="checkNickNameBtn">중복검사</button>
          </div>
          <div class="feedback fb-info" id="nickNameMsg" aria-live="polite">한글/영문/숫자 4~8자</div>
        </div>

        <!-- 휴대전화 -->
        <div class="field">
          <label for="userPhone">휴대전화</label>
          <input class="input" type="text" id="userPhone" name="userPhone" placeholder="010-1234-5678">
          <div class="feedback" id="userPhoneMsg" aria-live="polite"></div>
        </div>

        <!-- 이메일 -->
        <div class="field full">
          <label for="userEmail">이메일</label>
          <div class="input-row">
            <input class="input" type="text" id="userEmail" name="userEmail" autocomplete="email">
            <button type="button" class="check-btn" id="checkEmailBtn">중복검사</button>
          </div>
          <div class="feedback" id="userEmailMsg" aria-live="polite"></div>
        </div>

      </div>

      <div class="actions">
        <button type="submit" id="submitBtn" class="btn-primary" disabled>가입하기</button>
      </div>
    </form>
  </section>
</main>

<script>
  const CTX = '${contextPath}';

	  
  // 상태 관리
  const validity = {
    accountId:false, accountIdDup:false,
    userName:false,
    userPassword:false, checkPwd:false,
    nickName:false, nickNameDup:false,
    userPhone:false,
    userEmail:false, userEmailDup:false
  };

  // 공통 유틸
  function $(id){ return document.getElementById(id); }
  function setFeedback(id, type, text){
    const el = $(id);
    el.className = 'feedback ' + (type==='ok' ? 'fb-ok' : type==='err' ? 'fb-err' : type==='loading' ? 'fb-info fb-loading' : 'fb-info');
    el.textContent = text || '';
  }
  function setInputState(inputEl, ok){
    inputEl.classList.remove('is-valid','is-invalid');
    if (ok === true) inputEl.classList.add('is-valid');
    if (ok === false) inputEl.classList.add('is-invalid');
  }
  function updateSubmit(){
    const allOk = validity.accountId && validity.accountIdDup &&
                  validity.userName &&
                  validity.userPassword && validity.checkPwd &&
                  validity.nickName && validity.nickNameDup &&
                  validity.userPhone &&
                  validity.userEmail && validity.userEmailDup;
    $('submitBtn').disabled = !allOk;
  }

  // 즉시 검증 (입력 중)
  $('accountId').addEventListener('input', () => {
    const v = $('accountId').value.trim();
    const re = /^[a-z0-9]{4,12}$/;
    const ok = re.test(v);
    validity.accountId = ok;
    validity.accountIdDup = false; // 값 바뀌면 중복검사 무효화
    setInputState($('accountId'), ok ? true : (v ? false : undefined));
    setFeedback('accountIdMsg', ok ? 'info' : (v ? 'err' : 'info'), ok ? '형식 OK, 중복검사를 진행하세요.' : (v ? '영문 소문자/숫자 4~12자' : '영문 소문자/숫자 4~12자'));
    updateSubmit();
  });

  $('userName').addEventListener('input', () => {
    const ok = $('userName').value.trim().length > 0;
    validity.userName = ok;
    setInputState($('userName'), ok || undefined);
    setFeedback('userNameMsg', ok ? 'ok' : 'err', ok ? '좋습니다.' : '이름을 입력해주세요.');
    updateSubmit();
  });

  $('userPassword').addEventListener('input', () => {
    const v = $('userPassword').value;
    const re = /^(?=.*[A-Z])[A-Za-z0-9!@#]{6,10}$/;
    const ok = re.test(v);
    validity.userPassword = ok;
    setInputState($('userPassword'), ok || (v ? false : undefined));
    setFeedback('userPasswordMsg', ok ? 'ok' : (v ? 'err' : 'info'), ok ? '사용 가능한 비밀번호 형식입니다.' : (v ? '대문자1, 6~10자, 영/숫/!@#' : '대문자 1개 포함, 영문/숫자/!@#만, 6~10자'));
    // 확인과도 동기화
    const m = $('checkPwd').value;
    const match = v && m && v === m;
    validity.checkPwd = match;
    setInputState($('checkPwd'), m ? match : undefined);
    setFeedback('checkPwdMsg', m ? (match ? 'ok' : 'err') : 'info', m ? (match ? '비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.') : '');
    updateSubmit();
  });

  $('checkPwd').addEventListener('input', () => {
    const pw = $('userPassword').value;
    const m  = $('checkPwd').value;
    const ok = pw && m && pw === m;
    validity.checkPwd = ok;
    setInputState($('checkPwd'), m ? ok : undefined);
    setFeedback('checkPwdMsg', m ? (ok ? 'ok' : 'err') : 'info', m ? (ok ? '비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.') : '');
    updateSubmit();
  });

  $('nickName').addEventListener('input', () => {
    const v = $('nickName').value.trim();
    const re = /^[A-Za-z0-9\uAC00-\uD7A3]{4,8}$/;
    const ok = re.test(v);
    validity.nickName = ok;
    validity.nickNameDup = false;
    setInputState($('nickName'), ok ? true : (v ? false : undefined));
    setFeedback('nickNameMsg', ok ? 'info' : (v ? 'err' : 'info'), ok ? '형식 OK, 중복검사를 진행하세요.' : (v ? '한글/영문/숫자 4~8자' : '한글/영문/숫자 4~8자'));
    updateSubmit();
  });

  $('userPhone').addEventListener('input', () => {
    const v = $('userPhone').value.trim();
    const re = /^01[0-9]-?\d{3,4}-?\d{4}$/;
    const ok = re.test(v);
    validity.userPhone = ok;
    setInputState($('userPhone'), v ? ok : undefined);
    setFeedback('userPhoneMsg', v ? (ok ? 'ok' : 'err') : 'info', v ? (ok ? '형식 OK' : '예: 010-1234-5678') : '');
    updateSubmit();
  });

  $('userEmail').addEventListener('input', () => {
    const v = $('userEmail').value.trim();
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const ok = re.test(v);
    validity.userEmail = ok;
    validity.userEmailDup = false;
    setInputState($('userEmail'), v ? ok : undefined);
    setFeedback('userEmailMsg', v ? (ok ? 'info' : 'err') : 'info', v ? (ok ? '형식 OK, 중복검사를 진행하세요.' : '이메일 형식을 확인해주세요.') : '');
    updateSubmit();
  });

  // 중복검사 (서버 통신)
  $('checkIdBtn').addEventListener('click', async () => {
    const v = $('accountId').value.trim();
    const re = /^[a-z0-9]{4,12}$/;
    if (!re.test(v)) {
      setFeedback('accountIdMsg','err','아이디 형식이 올바르지 않습니다.');
      setInputState($('accountId'), false);
      validity.accountIdDup = false;
      updateSubmit();
      return;
    }
    $('checkIdBtn').disabled = true;
    setFeedback('accountIdMsg','loading','중복 검사 중...');
    try{
      const res = await fetch(CTX + '/user/check?accountId=' + encodeURIComponent(v));
      if (res.status === 200) {
        setFeedback('accountIdMsg','ok','사용 가능한 아이디 입니다.');
        setInputState($('accountId'), true);
        validity.accountIdDup = true;
      } else if (res.status === 409) {
        setFeedback('accountIdMsg','err','중복된 아이디 입니다.');
        setInputState($('accountId'), false);
        validity.accountIdDup = false;
      } else {
        setFeedback('accountIdMsg','err','확인 중 오류가 발생했습니다.');
        validity.accountIdDup = false;
      }
    } catch(e){
      setFeedback('accountIdMsg','err','네트워크 오류입니다.');
      validity.accountIdDup = false;
    } finally{
      $('checkIdBtn').disabled = false;
      updateSubmit();
    }
  });

  $('checkNickNameBtn').addEventListener('click', async () => {
    const v = $('nickName').value.trim();
    const re = /^[A-Za-z0-9\uAC00-\uD7A3]{4,8}$/;
    if (!re.test(v)) {
      setFeedback('nickNameMsg','err','닉네임 형식이 올바르지 않습니다.');
      setInputState($('nickName'), false);
      validity.nickNameDup = false;
      updateSubmit();
      return;
    }
    $('checkNickNameBtn').disabled = true;
    setFeedback('nickNameMsg','loading','중복 검사 중...');
    try{
      const res = await fetch(CTX + '/user/check?nickName=' + encodeURIComponent(v));
      if (res.status === 200) {
        setFeedback('nickNameMsg','ok','사용 가능한 닉네임 입니다.');
        setInputState($('nickName'), true);
        validity.nickNameDup = true;
      } else if (res.status === 409) {
        setFeedback('nickNameMsg','err','중복된 닉네임 입니다.');
        setInputState($('nickName'), false);
        validity.nickNameDup = false;
      } else {
        setFeedback('nickNameMsg','err','확인 중 오류가 발생했습니다.');
        validity.nickNameDup = false;
      }
    } catch(e){
      setFeedback('nickNameMsg','err','네트워크 오류입니다.');
      validity.nickNameDup = false;
    } finally{
      $('checkNickNameBtn').disabled = false;
      updateSubmit();
    }
  });

  $('checkEmailBtn').addEventListener('click', async () => {
    const v = $('userEmail').value.trim();
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!re.test(v)) {
      setFeedback('userEmailMsg','err','이메일 형식이 올바르지 않습니다.');
      setInputState($('userEmail'), false);
      validity.userEmailDup = false;
      updateSubmit();
      return;
    }
    $('checkEmailBtn').disabled = true;
    setFeedback('userEmailMsg','loading','중복 검사 중...');
    try{
      const res = await fetch(CTX + '/user/check?userEmail=' + encodeURIComponent(v));
      if (res.status === 200) {
        setFeedback('userEmailMsg','ok','사용 가능한 이메일 입니다.');
        setInputState($('userEmail'), true);
        validity.userEmailDup = true;
      } else if (res.status === 409) {
        setFeedback('userEmailMsg','err','중복된 이메일 입니다.');
        setInputState($('userEmail'), false);
        validity.userEmailDup = false;
      } else {
        setFeedback('userEmailMsg','err','확인 중 오류가 발생했습니다.');
        validity.userEmailDup = false;
      }
    } catch(e){
      setFeedback('userEmailMsg','err','네트워크 오류입니다.');
      validity.userEmailDup = false;
    } finally{
      $('checkEmailBtn').disabled = false;
      updateSubmit();
    }
  });

  // 최초 상태 업데이트
  updateSubmit();
</script>

</body>
</html>