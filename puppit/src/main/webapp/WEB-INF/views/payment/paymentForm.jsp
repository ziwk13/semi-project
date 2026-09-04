<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="chargeLimit" value="500000" />

<jsp:include page="../layout/header.jsp" />

<style>
  :root{
    --bg:#fff; --card:#fff; --text:#111; --muted:#8a8f98; --line:#e6e9ef; --primary:#4f86ff;
  }
  *{box-sizing:border-box;}
  body{margin:0;background:var(--bg);font-family:system-ui,-apple-system,"Segoe UI",Roboto,"Noto Sans KR",sans-serif;color:var(--text);}
  .wrap{max-width:1200px;margin:0 auto;padding:20px;}
  
  /* 헤더 */
  .topbar{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;}
  .left{display:flex;align-items:center;gap:10px;}
  .back-btn{
    border:none;background-color:#fff;color:#333;cursor:pointer;font-size:20px;line-height:1;
    width:36px;height:36px;border-radius:8px;display:flex;align-items:center;justify-content:center;
  }
  .title{font-weight:800;font-size:22px;}
  
  /* 섹션 타이틀 행 */
  .row-head{display:flex;align-items:center;justify-content:space-between;margin:18px 2px 10px;}
  .row-head .label{font-weight:700;}
  .row-head .limit{font-size:14px;color:#5a6cff;font-weight:700;}

  /* 입력 박스 */
  .input-box{
    background:var(--card);border:1px solid var(--line);border-radius:12px;height:56px;padding:0 14px;
    display:flex;align-items:center;gap:8px;
  }
  .input-box input{
    flex:1;border:none;outline:none;font-size:16px;background:transparent;
  }
  .hint{margin:8px 4px 0;color:var(--muted);font-size:13px;}

  /* 퀵 버튼 */
  .quick{display:flex;gap:8px;flex-wrap:wrap;margin-top:14px;}
  .chip{
    border:1px solid var(--line);background:#fff;border-radius:8px;padding:10px 12px;
    font-weight:700;cursor:pointer;font-size:14px;
  }
  .chip:active{transform:translateY(1px);}

  /* 구분선(아래 공간 남김) */
  .space{height:240px;}
  .charge-btn-wrap {
    display: flex;
    justify-content: center; 
    align-items: center;    
  }
  .charge-btn{
  width:600px;
  height:50px;
  font-size:18px;
  font-weight:700;
  border:none;
  border-radius:10px;
  background:#333333;
  color:#fff;
  cursor:pointer;
  }
</style>

<div class="wrap">
  <div class="topbar">
    <div class="left">
      <button class="back-btn" onclick="history.back()" aria-label="뒤로가기">
        <i class="fa-solid fa-arrow-left"></i>
      </button>
      <div class="title">포인트 충전</div>
    </div>
  </div>
  <div class="row-head">
    <div class="label">충전금액</div>
    <div class="limit">
      충전 가능 금액
      <a style="color:#5a6cff; text-decoration:none;">
        <fmt:formatNumber value="${chargeLimit}" type="number" />
      </a>
    </div>
  </div>

  <div class="input-box">
    <input id="amount" type="text" inputmode="numeric" autocomplete="off"
           placeholder="충전할 포인트 입력 (1,000P 단위 입력 가능)">
    <strong>P</strong>
  </div>
  <div class="hint">1,000P 단위로 입력됩니다. 최대 <fmt:formatNumber value="${chargeLimit}" type="number" />P</div>

  <div class="quick">
    <button class="chip" type="button" id="btnMax">최대금액</button>
    <button class="chip" type="button" data-add="10000">+ 1만P</button>
    <button class="chip" type="button" data-add="30000">+ 3만P</button>
    <button class="chip" type="button" data-add="50000">+ 5만P</button>
  </div>
  <!-- 서버로 전송할 hidden 값 -->
  <div class="space">
    <input type="hidden" id="uid" value="${sessionScope.sessionMap.userId}">
    <input type="hidden" id="name" value="${sessionScope.sessionMap.userName}">
    <input type="hidden" id="email" value="${sessionScope.sessionMap.userEmail}">
  </div>
  
  <div class="charge-btn-wrap">
    <button type="button" class="charge-btn" onclick="requestPay()">충전하기</button>
  </div>
</div>

<script>
  const limit = Number("${chargeLimit}");
  const $amount = document.getElementById('amount');
  // 숫자가 아니면 제거
  function onlyDigits(str) {return (str||'').replace(/[^\d]/g,'');}  
  // 천 단위로 콤마
  function format(n) {return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');}
  // 천 단위로만 입력 
  function snap1000(n) {
    if (isNaN(n)) return 0;
    n = Math.min(n, limit);
    return Math.floor(n / 1000) * 1000;
  }

  // 입력 중: 숫자만 + 콤마 (스냅 X)
  $amount.addEventListener('input', () => {
    const raw = onlyDigits($amount.value);
    if (!raw) { $amount.value = ''; return; }
    $amount.value = format(Number(raw));
  });

  // 포커스 아웃: 1,000 단위 스냅 + 상한
  function finalize() {
    const raw = Number(onlyDigits($amount.value));
    if (!raw) { $amount.value = ''; return; }
    const snapped = snap1000(raw);
    $amount.value = snapped ? format(snapped) : '';
  }
  $amount.addEventListener('blur', finalize);

  // Enter로도 확정
  $amount.addEventListener('keydown', e => {
    if (e.key === 'Enter') {
      e.preventDefault();
      finalize();
      $amount.blur();
    }
  });

  // 퀵 버튼(+1만/+3만/+5만/최대)
  document.querySelectorAll('.chip[data-add]').forEach(btn => {
    btn.addEventListener('click', () => {
      const add = Number(btn.dataset.add);
      const current = Number(onlyDigits($amount.value)) || 0;
      const next = Math.min(current + add, limit);
      $amount.value = format(next);
      finalize(); 
    });
  });
  document.getElementById('btnMax')?.addEventListener('click', () => {
    $amount.value = format(snap1000(limit));
  });
</script>
<script src="https://cdn.iamport.kr/js/iamport.payment-1.2.0.js"></script>
<script>
  const $payBtn = document.querySelector(".charge-btn");

  async function requestPay() {
    try {
      // 중복 클릭 방지
      $payBtn.disabled = true;

      // 입력 확정 및 값 읽기
      finalize();
      const uid   = document.getElementById("uid").value?.trim();
      const name  = document.getElementById("name").value?.trim();
      const email = document.getElementById("email").value?.trim();
      const raw   = Number(onlyDigits(document.getElementById("amount").value));
      const amount = snap1000(raw);

      if (!uid || !amount) {
        alert("유저 ID와 금액(1,000P 단위)을 확인하세요.");
        $payBtn.disabled = false;
        return;
      }
      if (amount > limit) {
        alert("최대 충전 한도를 초과했습니다.");
        $payBtn.disabled = false;
        return;
      }

      // 1) 서버에서 주문번호(merchant_uid) 발급 및 대기 저장
      const res = await fetch("${contextPath}/payment/orders", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          amount: amount
        })
      });
      if (!res.ok) throw new Error("주문 생성 실패");
      const { merchant_uid } = await res.json();

      // 2) SDK 준비
      const IMP = window.IMP;
      if (!IMP) throw new Error("IMP SDK가 로드되지 않았습니다.");
      IMP.init("imp85811517"); // 가맹점 코드

      // 3) 결제창 호출
      IMP.request_pay({
        pg: "html5_inicis",
        pay_method: "card",
        name: "포인트 충전",
        amount: amount,
        buyer_name: name,
        buyer_email: email,
        merchant_uid: merchant_uid
      }, async function (rsp) {
        if (!rsp.success) {
          alert("결제 실패: " + rsp.error_msg);
          // 서버에 실패 상태 업데이트 요청
          try {
        	  await fetch(`${contextPath}/payment/fail`, {
        		  method: "POST",
        		  headers: {"Content-Type" : "application/json"},
        		  body: JSON.stringify({merchantUid: merchant_uid})
        	  });
      		} catch (err) {
      			console.error("실패 상태 업데이트 실패", err);
      		}
          $payBtn.disabled = false;
          return;
        }

        // 4) 서버 검증
        try {
          const vres = await fetch("${contextPath}/payment/verify", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              imp_uid: rsp.imp_uid
            })
          });
          const result = await vres.json();

          if (result.success) {
            alert("충전 성공!");
            window.location.href = "${contextPath}/user/mypage";
          } else {
            alert("결제는 성공했지만 검증에 실패했습니다.");
            $payBtn.disabled = false;
          }
        } catch (e) {
          console.error(e);
          alert("검증 중 오류가 발생했습니다.");
          $payBtn.disabled = false;
        }
      });

    } catch (e) {
      console.error(e);
      alert("결제 준비 중 오류가 발생했습니다.");
      $payBtn.disabled = false;
    }
  }
</script>



</body>
</html>

