<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
 

<%
Map<String, Object> sessionMap = (Map<String, Object>) session.getAttribute("sessionMap");
String accountId = "";
Integer userId = 0;
String nickName = "";
if (sessionMap != null) {
    Object accountIdObj = sessionMap.get("accountId");
    if (accountIdObj != null) {
        accountId = accountIdObj.toString();
    }
    Object userIdObj = sessionMap.get("userId");
    if (userIdObj != null) {
        userId = Integer.parseInt(userIdObj.toString());
    }
    Object nickNameObj = sessionMap.get("nickName");
    if (nickNameObj != null) {
    	nickName = nickNameObj.toString();
    }
}


ObjectMapper mapper = new ObjectMapper();
String chatListJson = mapper.writeValueAsString(request.getAttribute("chatList"));
String profileImageJson = mapper.writeValueAsString(request.getAttribute("profileImage"));
//out.println("DEBUG chatList=" + request.getAttribute("chatList"));
//out.println("DEBUG profileImage=" + request.getAttribute("profileImage"));

%>

<c:set var="loginUserId" value="<%= accountId %>" />
<c:set var="userId" value="<%=userId %>"/>
<c:set var="nickName" value="<%=nickName %>"/>
<c:set var="highlightRoomIdStr" value="${highlightRoomIdStr}"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp?dt=<%=System.currentTimeMillis()%>"/>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅방 목록</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
     body { font-family: 'Noto Sans KR', sans-serif; background: #fff; margin: 0; padding: 0; }
		.container {
		    max-width: 1200px;
		    width: 100%;
		    min-height: 700px;
		    padding-top: 100px;
		    display: flex;
		    flex-direction: row;
		    gap: 0;
		    justify-content: center;
		    align-items: flex-start;
		    margin: 0 auto;
		    background: #fff;
		    box-sizing: border-box;
		}
		
		/* 채팅목록 영역 50% */
		.chatlist-container {
		    width: 50%;
		    min-width: 0;
		    height: 600px;
		    border: none;
		    padding: 0;
		    margin: 0;
		    overflow-y: auto;
		    box-sizing: border-box;
		}
		
		/* 채팅창 영역 50% */
		.chat-container {
		    width: 50%;
		    min-width: 0;
		    height: 600px;
		    display: flex;
		    flex-direction: column;
		    justify-content: flex-end;
		    padding: 20px;
		    box-sizing: border-box;
		    background: #fafafa;
		}
        .chat-list { display: flex; flex-direction: column; gap: 20px; }
        .chatList { display: flex; flex-direction: row; align-items: center; padding: 0 10px; gap: 16px; cursor: pointer; background: #fff; border-radius: 18px; min-height: 80px; transition: background 0.15s; box-shadow: none; border: none; }
        .chatList:hover { background: #f5f5f5; }
        .chat-profile-img { width: 56px; height: 56px; border-radius: 50%; object-fit: cover; margin-right: 10px; border: 1.5px solid #eee; background: #fafafa; display: flex; justify-content: center; align-items: center; font-size: 28px; color: #bbb; }
        .chat-info-area { flex: 1 1 0; display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .chat-nickname { font-size: 18px; font-weight: 700; color: #222; margin-bottom: 2px; letter-spacing: -0.5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .chat-message { font-size: 15px; color: #444; white-space: normal; overflow: visible; text-overflow: initial; max-width: none; }
        .chat-meta { display: flex; flex-direction: column; align-items: flex-end; min-width: 90px; gap: 8px; }
        .chat-time { font-size: 14px; color: #757575; font-weight: 400; }
        .chat-unread-badge { display: inline-block; width: 22px; height: 22px; line-height: 20px; font-size: 15px; background: #fff; color: #e74c3c; border: 2px solid #e74c3c; border-radius: 50%; text-align: center; font-weight: 700; margin-top: 2px; margin-right: 5px; }
        .chat-history { display: flex; flex-direction: column; align-items: flex-start; width: 100%; gap: 12px; margin-bottom: 16px; overflow-y: auto; flex: 1; scrollbar-width: none; -ms-overflow-style: none; }
        .chat-history::-webkit-scrollbar { display: none; }
        .chat-history .chat-message { max-width: 60%; min-width: 80px; padding: 10px 16px; border-radius: 12px; margin-bottom: 4px; display: flex; flex-direction: column; background: #eee; box-sizing: border-box; word-break: break-word; height: auto; overflow: visible; }
        .chat-history .chat-message.right { align-self: flex-end !important; background: #e9f7fe; text-align: right; }
        .chat-history .chat-message.left { align-self: flex-start !important; background: #eee; text-align: left; }
        .chat-history .chat-message .chat-userid { font-size: 13px; color: #888; margin-bottom: 2px; }
        .chat-history .chat-message .chat-text { font-size: 15px; margin-bottom: 2px; white-space: pre-wrap; overflow-wrap: break-word; word-break: break-word; }
        .chat-history .chat-message .chat-time { font-size: 12px; color: #aaa; margin-top: 2px; align-self: flex-end; }
        .chatList.highlight { background: #fff8e1; border: 2px solid #ffb300; }	
        .center-message { text-align:center; margin:20px 0; color:#888; }
        .notification {
	        position: fixed;
	        right: -100px;
	        top: 20px;
	        width: 300px;
	        background-color: #f9f9f9;
	        border: 1px solid #ccc;
	        padding: 10px;
	        border-radius: 5px;
	        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
	        transition: right 1s;
	    }

		/* 반응형 대응: 모바일 화면에서는 100%로 */
		@media (max-width: 1200px) {
		    .container { max-width: 100vw; }
		    .chatlist-container, .chat-container { width: 100%; }
		    .container { flex-direction: column; }
		}
        /* 채팅이 두 번 이상 이루어졌을 때 보이는 결제하기 버튼(#pay-btn)의 스타일 오버라이드 */
		#pay-btn {
		  background: #000 !important;    /* 검정색 배경 */
		  color: #fff !important;         /* 흰색 글자 */
		  border: none !important;
		  width: 200px !important;        /* 너비 200px */
		  height: 50px !important;        /* 높이 50px */
		  font-size: 20px;
		  font-weight: 700;
		  border-radius: 8px;
		  cursor: pointer;
		  box-shadow: 0 2px 8px rgba(25, 25, 25, 0.15);
		  text-align: center;
		  display: inline-block;
		  margin-top: 10px;
		  transition: background 0.2s;
		}
		
		#pay-btn:hover {
		  background: #222 !important;    /* 호버시 어두운 회색 */
		}
		/* 채팅 입력 textarea 스타일 */
        .chat-input-group textarea#chatMessageInput {
            width: 400px;
            height: 100px;
            resize: none;
            font-size: 16px;
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid #d1d5db;
            box-sizing: border-box;
            margin-right: 12px;
            font-family: 'Noto Sans KR', sans-serif;
            line-height: 1.5;
        }
        /* 전송 버튼 스타일 */
        .chat-input-group button {
            width: 200px;
            height: 50px;
            background: #000 !important;
            color: #fff !important;
            border: none;
            border-radius: 8px;
            font-size: 18px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s;
        }
        .chat-input-group button#sendChatButton:hover {
            background: #222 !important;
        }
        .chat-input-group {
            display: flex;
            flex-direction: row;
            align-items: flex-end;
            gap: 12px;
            margin-top: 8px;
        }
        
        .notification {
    position: fixed;
    right: 20px;
    top: 20px;    /* 항상 화면 위쪽에 */
    z-index: 9999;  /* 다른 요소 위에 보이게 */
    width: 300px;
    background-color: #f9f9f9;
    border: 1px solid #ccc;
    padding: 10px;
    border-radius: 5px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    transition: right 1s;
}


.chat-last-time {
  white-space: normal;
  overflow: visible;
  text-overflow: initial;
  max-width: none;
  display: inline;         /* 시간 옆에 붙게 */
}

/* 쩜세개 옵션 팝업 */
#chat-options-popup {
    min-width:120px;
    box-shadow:0 2px 8px rgba(0,0,0,0.08);
    background:#f6f6f6;
    border-radius:8px;
    border:1px solid #bbb;
    position:absolute;
    right:0;
    top:38px;
    z-index:999;
    display: none;
}

.chat-option-item:hover {
    background:#ececec;
}
#chat-options-btn {
    transition:background 0.15s;
}
#chat-options-btn:hover {
    background:#eee;
}
#exit-chatroom-modal {
    background:rgba(0,0,0,0.2);
    align-items:center;
    justify-content:center;
}

// 1. CSS 추가 (팝업/모달/버튼/배경 등)
const style = document.createElement('style');
style.innerHTML = `
/* 쩜세개 옵션 활성화시 채팅방 배경 회색 */
.chatList.option-active {
  background: #eee !important;
}

/* 옵션 팝업 */
#chat-options-popup.active {
  display: block !important;
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}

/* 모달 배경 */
#exit-chatroom-modal-bg {
  position: fixed;
  top:0; left:0; right:0; bottom:0;
  background: rgba(0,0,0,0.18);
  z-index: 99999;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 모달창 */
#exit-chatroom-modal {
  background: #fff;
  border-radius: 14px;
  padding: 32px 28px 24px 28px;
  min-width: 360px;
  box-shadow: 0 4px 32px rgba(0,0,0,0.11);
  position: relative;
  animation: fadein 0.25s;
}
@keyframes fadein { from{opacity:0;} to{opacity:1;} }
/* X버튼 */
#exit-chatroom-modal .close-btn,
#exit-chatroom-done .close-btn {
  position: absolute;
  right: 18px;
  top: 18px;
  font-size: 22px;
  color: #888;
  background: none;
  border: none;
  cursor: pointer;
  font-weight: 700;
  transition: color 0.18s;
  z-index: 1;
}
#exit-chatroom-modal .close-btn:hover,
#exit-chatroom-done .close-btn:hover { color: #e74c3c; }
/* 안내문구 */
#exit-chatroom-modal .exit-text {
  margin-bottom: 28px;
  color:#222;
  font-size:17px;
  text-align:center;
}
/* 확인 버튼 */
#exit-chatroom-modal .confirm-btn {
  background: #e74c3c;
  color: #fff;
  font-weight:700;
  font-size:18px;
  border:none;
  border-radius:8px;
  padding: 10px 28px;
  cursor: pointer;
  display:block;
  margin: 0 auto;
  transition: background 0.18s;
}
#exit-chatroom-modal .confirm-btn:hover { background: #c0392b; }
/* 삭제 완료 팝업 */
#exit-chatroom-done {
  position: fixed;
  top: 50px;
  right: 50px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.13);
  padding: 24px 38px 20px 22px;
  min-width: 290px;
  z-index: 99999;
  font-size:18px;
  color:#222;
  animation: fadein 0.2s;
}
#exit-chatroom-done .close-btn {
  top: 12px;
  right: 12px;
}
#chat-options-popup .chat-option-item#exit-chatroom {
  color: #e74c3c;
  font-weight:700;
}

#chatListRenderArea {
    margin: 0;
    padding: 0;
}
.chatList {
    display: flex;
    align-items: flex-start;
    margin-bottom: 18px;
    cursor: pointer;
}
.chat-profile-img {
    width: 48px;
    height: 48px;
    margin-right: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
}
.chat-profile-img img {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    object-fit: cover;
    border: 1px solid #ccc;
}
.chat-info-wrap {
    display: flex;
    flex-direction: column;
    flex: 1;
}
.chat-user-row {
    font-weight: bold;
    font-size: 18px;
    margin-bottom: 2px;
}
.chat-user-row .chat-role {
    font-size: 14px;
    font-weight: normal;
    margin-left: 3px;
    color: #666;
}
.chat-message-row {
    font-size: 16px;
    margin-bottom: 2px;
    color: #222;
    word-break: break-all;
}
.chat-meta-row {
    font-size: 13px;
    color: #888;
}
.unread-badge {
    background: #e74c3c;
    color: #fff;
    font-size: 13px;
    font-weight: bold;
    border-radius: 10px;
    padding: 3px 7px;
    margin-left: 8px;
    vertical-align: middle;
    display: none;
}


    </style>
</head>
<body>
<!-- 알림 팝업 영역 추가 -->
<div id="unreadNotificationArea" style="position:fixed; right:20px; top:80px; z-index:99999; display:none;">
    <!-- 읽지 않은 메시지 알림 목록이 동적으로 삽입됨 -->
</div>
<div class="container">
   
    
    <div class="chatlist-container" id="chatlist-container">
     
        <div style="display: flex; align-items: center; margin-bottom: 12px; box-sizing: border-box;">
            <button id="back-btn"
                style="background: none; border: none; color: #222; font-size: 24px; font-weight: 700; cursor: pointer; padding: 0; margin-right: 8px; display: flex; align-items: center;">
                <i class="fa-solid fa-arrow-left" style="font-size: 24px;"></i>
            </button>
            
        </div>
        <div id="chatListRenderArea">
	         <div style="text-align: center; font-size: 22px; font-weight: 700; color: #222; margin-bottom: 16px;">
	            채팅방목록
	        </div>
        
            <c:forEach items="${chatList}" var="chat">
                <div class="chatList" data-room-id="${chat.roomId}">
                    <span class="chat-profile-img chat-profile-icon">
                    
                    
                        <i class="fa-solid fa-user"></i>
                    </span>
                    <div class="chat-info-area" style="cursor:pointer;">
                        <div class="chat-nickname">
                         
                        		<c:choose>
								   <c:when test="${chat.sellerAccountId eq loginUserId}">
								        <c:out value="${chat.productName}"/>/ 
								        <c:out value="${chat.buyerNickName}" />
								    </c:when>
								    <c:when test="${chat.buyerAccountId eq loginUserId}">
								    	<c:out value="${chat.productName}"/>/ 
								        <c:out value="${chat.sellerNickName}" />
								    </c:when>
								    <c:otherwise>
								        <c:out value="알 수 없음" />
								    </c:otherwise>	                        		
                        	      </c:choose> 
						
                        
                        
                            
                               
                        </div>
                         
                        <div class="chat-message">
						    <span class="chat-message-text">
						        <c:choose>
						            <c:when test="${not empty chat.lastMessage}">
						                <c:out value="${chat.lastMessage}" />
						            </c:when>
						            <c:otherwise>
						                상품판매자와 채팅을 시작해보세요
						            </c:otherwise>
						        </c:choose>
						    </span>
						     <span class="chat-last-time" style="margin-left:8px; color:#888;">
					            <c:out value="${chat.chatLastMessageAt}" />
					        </span>
						</div>
                        
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
    <div class="chat-container">
        <div class="product-info-area" id="product-info-area"></div>
        <div class="center-message" id="center-message">채팅방을 먼저 선택해주세요</div>
        <div class="chat-history" id="chat-history"></div>
        <div class="chat-input-group">
             <textarea id="chatMessageInput" placeholder="채팅메시지를 입력하세요" rows="5"></textarea>
            <button type="button"  id="sendChatButton">전송</button>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1.6.1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.2/stomp.min.js"></script>
<script>

const chatInputGroup = document.querySelector('.chat-input-group');
const centerMessage = document.getElementById('center-message');
const chatHistory = document.getElementById('chat-history');
const productInfoArea = document.getElementById('product-info-area');
const renderedMessageIds = new Set();
console.log("contextPath", contextPath);
console.log("loginUserId", loginUserId);
console.log("userId", userId);

//let stompClient = null;
let currentRoomId = null;
let currentSubscription = null;
let isConnected = false;
let productId = null;
let buyerId = null;
let buyerAccountId = "";
//3. 채팅방 접속자 관리 (프론트 전역)
let activeRooms = {}; // { roomId: { buyer: true/false, seller: true/false } }
//하이라이트 타이머 관리용 객체
let highlightTimers = {}; // { roomId: timerId }
let notificationSubscription = null;
window.chatList = <%= (chatListJson != null && !chatListJson.isEmpty() ? chatListJson : "[]") %>;
window.profileImage = <%= (profileImageJson != null && !profileImageJson.isEmpty() ? profileImageJson : "null") %>;
const chatList = window.chatList;
const profileImages = window.profileImage;
window.myAccountId = "<%= accountId %>";

document.addEventListener('DOMContentLoaded', function() {
	 // JSP EL 값을 JS 변수에 할당
    var userId = "${userId}";
	  let isLoggedIn = "${not empty sessionScope.sessionMap.accountId}";
	  const isChatListPage = window.location.pathname.indexOf("/chat/recentRoomList") !== -1;
	  if (isLoggedIn === "true" && isChatListPage) {
	        loadUnreadCounts();
	  }
	  
	  document.body.addEventListener('click', function(e) {
	        if (e.target && e.target.id === 'chat-options-btn') {
	            showOptionsPopup(e.target);
	        }
	    });
	  
	  
	  
	  	// 1. 로그인 성공시 내가 안읽은 메시지 전부 알림팝업에 띄우기
      // (sessionScope.sessionMap.accountId 방식의 로그인 체크)
     
   if (isLoggedIn === "true") {
       fetch(contextPath + '/api/alarm?userId=' + userId)
           .then(res => res.json())
           .then(unreadMessages => {
               if (Array.isArray(unreadMessages) && unreadMessages.length > 0) {
            	   console.log('unreadMessages: ', unreadMessages);
                   //showUnreadNotificationsPopup(unreadMessages);
                   //showAlarmPopup([unreadMessages]);
            	   window.showAlarmPopup(unreadMessages);
               }
           })
           .catch(err => console.error('안읽은 메시지 알림 fetch 에러:', err));
   }
	

	  	
	  	
	  	
	if (!window.stompClient || !window.stompClient.connected) {
        const socket = new SockJS(contextPath + '/ws-chat');
        console.log("Connecting websocket...");
        window.stompClient = Stomp.over(socket);
        window.stompClient.connect({}, function() {
            window.isConnected = true;
            console.log("STOMP connected!");
            // 알림 구독은 무조건!
            subscribeNotifications();
            // 기존 채팅방 클릭시 connectAndSubscribe(roomId)에서 채팅방 구독(connect+subscribeRoom)는 그대로 두기
        });
    } else {
    	  console.log("Websocket already connected, subscribing notifications...");
        // 이미 연결된 경우에도 알림 구독은 항상 시도!
        subscribeNotifications();
    }
   
    const myAccountId = window.myAccountId;
    const defaultImg = contextPath + '/resources/image/profile-default.png';

    // 채팅 내역 없는 방의 roomId를 저장 (비동기 DB 조회 결과 활용)
    // { roomId: true/false }
    const noChatRooms = {};   
    
 // 1. DB에서 로그인 사용자의 userId와 각 채팅방의 상품 seller_id 간 채팅내역이 있는지 fetch
    // (비동기로 한 번에 가져오면 좋음, 예시 API: /api/chat/count?roomId=xxx&buyerId=yyy&sellerId=zzz)
    // 아래는 모든 채팅방을 한 번에 조회하는 예시
    const chatCountPromises = [];
    
    // 콘솔에서 JS로 넘어온 값을 바로 확인
    console.log("chatList =", chatList);
    console.log("profileImages =", profileImages);
    const urlParams = new URLSearchParams(window.location.search);
    const highlightRoomId = urlParams.get('highlightRoomId');
    if (highlightRoomId) {
        setTimeout(() => {
            // highlightChatRoom 함수가 전역에 등록되어 있으면 활용
            if (typeof window.highlightChatRoom === 'function') {
                window.highlightChatRoom(highlightRoomId);
            } else {
                // 직접 구현: 해당 채팅방 div에 highlight 클래스 추가
                document.querySelectorAll('.chatList').forEach(chatDiv => {
                    if (String(chatDiv.dataset.roomId) === String(highlightRoomId)) {
                        chatDiv.classList.add('highlight');
                        // 2초 후 하이라이트 자동 제거
                        setTimeout(() => {
                            chatDiv.classList.remove('highlight');
                        }, 2000);
                    }
                });
            }
        }, 150); // DOM 렌더 완료 후 실행 (fetch 등 비동기 작업 후라면 150ms~300ms로 늘려도 됨)
    }
    
    
    
    chatList.forEach(chat => {
        // chat.roomId, chat.buyerId (혹은 현재 로그인자), chat.sellerId 필요
        // buyerId는 로그인자 userId
        // sellerId는 chat.sellerId
        // roomId: chat.roomId
        // buyerId: 로그인자 userId
        // sellerId: chat.sellerId 또는 chat.productSellerId
        const roomId = chat.roomId || '';
        const buyerId = userId || '';
        const sellerId = chat.sellerId || chat.productSellerId || '';
        
        // 콘솔로 확인(디버깅)
        console.log('카운트 fetch:', {roomId, buyerId, sellerId});
        
       
        
        // roomId, buyerId, sellerId가 올바르게 바인딩되어 API에 전달되도록!
        chatCountPromises.push(
            fetch(
                contextPath + '/api/chat/count?roomId=' + chat.roomId + '&buyerId=' + userId + '&sellerId=' + chat.sellerId
            )
            .then(function(res) { return res.json(); })
            .then(function(data) {
            	console.log('data.totalChatCount: ', data.totalChatCount);
            	noChatRooms[chat.roomId] = {
                        totalChatCount: data.totalChatCount || 0,
                        buyerToSellerCount: data.buyerToSellerCount || 0
                    };
            })
            .catch(function() {
            	 noChatRooms[chat.roomId] = { totalChatCount: false, buyerToSellerCount: false };
            })
        );
    });
    

    // 채팅방 목록 이미지 바인딩은 모든 카운트 fetch 이후에 실행
Promise.all(chatCountPromises).then(() => {
    document.querySelectorAll('.chatList').forEach(function(chatDiv) {
        const roomId = chatDiv.dataset.roomId;
        let info = Array.isArray(profileImages) ? profileImages.find(pi => String(pi.chatRoomId) === String(roomId)) : null;
        let imgSrc = '';
        if (info) {
            const sellerProfileImageKey = info.sellerProfileImageKey;
            const receiverProfileImageKey = info.receiverProfileImageKey;
            const buyerAccountId = String(info.chatReceiverAccountId);
            const sellerAccountId = String(info.productSellerAccountId);
            const myAccountId = String(window.myAccountId);
            // API에서 받아온 값 사용
            const totalChatCount = noChatRooms[roomId]?.totalChatCount || 0;

            // 내가 구매자면 판매자 프로필
            if (myAccountId === buyerAccountId && info.sellerProfileImageKey) {
                imgSrc = 'https://jscode-upload-images.s3.ap-northeast-2.amazonaws.com/' + info.sellerProfileImageKey;
            }
            // 내가 판매자면 구매자 프로필
            else if (myAccountId === sellerAccountId && info.receiverProfileImageKey) {
                imgSrc = 'https://jscode-upload-images.s3.ap-northeast-2.amazonaws.com/' + info.receiverProfileImageKey;
            }
            // 그 외: otherProfileImageKey (예: 운영자, 자기 자신과의 채팅 등)
            else if (info.otherProfileImageKey) {
                imgSrc = 'https://jscode-upload-images.s3.ap-northeast-2.amazonaws.com/' + info.otherProfileImageKey;
            }
        }
        if (!imgSrc) imgSrc = defaultImg;
        const profileSpan = chatDiv.querySelector('.chat-profile-img');
        if (profileSpan) {
            profileSpan.innerHTML = `<img src="\${imgSrc}" alt="프로필 이미지" width="64" height="64" style="width:64px;height:64px;object-fit:cover;border-radius:50%;" onerror="this.src='${defaultImg}'"/>`;
        }
    });
});
    
    

    // 채팅방 클릭 직접 바인딩 (이벤트 위임 중복 삭제)
    document.querySelectorAll('.chatList').forEach(function(chatDiv) {
        chatDiv.addEventListener('click', function(e) {
            const roomId = chatDiv.dataset.roomId;
            selectedRoomId = roomId;
            currentRoomId = roomId;
            console.log('roomId:', roomId);
            console.log('selectedRoomId:', selectedRoomId);

            // 선택/하이라이트 처리
            document.querySelectorAll('.chatList').forEach(el => el.classList.remove('highlight', 'selected'));
            chatDiv.classList.add('highlight', 'selected');
            if (highlightTimers[roomId]) clearTimeout(highlightTimers[roomId]);
            highlightTimers[roomId] = setTimeout(() => {
                chatDiv.classList.remove('highlight');
                highlightTimers[roomId] = null;
            }, 2000);

            showChatUI();
            chatHistory.innerHTML = "";
            renderedMessageIds.clear();
            loadChatHistory(roomId).then(() => {
                connectAndSubscribe(roomId);
            });

            // 채팅방 목록 클릭 시, 뱃지 즉시 제거 (서버 요청과 관계없이 UI에서 바로 제거)
            const badge = chatDiv.querySelector('.unread-badge');
            if (badge && badge.style.display !== 'none' && parseInt(badge.textContent) > 0) {
                badge.style.display = 'none';
                badge.textContent = '';
            }
            

            // 뱃지에서 unreadCount 추출
           // const badge = chatDiv.querySelector('.unread-badge');
           // let unreadCount = 0;
          //  if (badge && badge.textContent) {
          //      unreadCount = parseInt(badge.textContent) || 0;
          //  }
            /*
            if (unreadCount > 0) {
                fetch(contextPath + '/api/alarm/readAll', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        roomId: roomId,
                        userId: userId,
                        count: unreadCount
                    })
                })
                .then(res => res.json())
                .then(data => {
                	console.log('');
                    badge.style.display = 'none';
                    badge.textContent = '';
                   // if (window.removeAlarmPopupRoom) window.removeAlarmPopupRoom(roomId);
                    
                 // 읽음 처리 함수 호출
                    markRoomMessagesAsRead(roomId, unreadCount);
                    
                    // ★★★ [여기서] 읽음 처리 후 목록 새로고침 추가! ★★★
                    setTimeout(reloadRecentRoomList, 250);
                    // 250ms 딜레이: 서버에서 읽음 처리 완료 후 동기화
                    
                    
                })
                .catch(err => {
                    console.error('안읽은 메시지 읽음 처리 에러:', err);
                });
            }  else {
            	console.log('else');
            } */
        });
    });

    // 뒤로가기 버튼 이벤트
    const backBtn = document.getElementById('back-btn');
    if (backBtn) {
        backBtn.addEventListener('click', function() {
            window.history.back();
        });
    }

    // sendBtn, showChatUI, loadUnreadCounts 등 기존 기능 그대로
    const sendBtn = document.getElementById('sendChatButton');
    if (sendBtn) {
        sendBtn.addEventListener('click', function(e){
            // e.preventDefault();
            alert("sendMessage click");
            sendMessage(currentRoomId, chatMessages);
        });
    }
    
    // 엔터 입력 시 메시지 전송 (shift + Enter는 줄바꿈)
    const chatInput = document.getElementById('chatMessageInput');
    if (chatInput) {
    	chatInput.addEventListener('keydown', function(e) {
    		if (e.key === 'Enter') {
    			if (e.shiftKey) {
    				// 줄바꿈
    				return;
    			} else {
    				//Enter만 메시지 전송
    				e.preventDefault();// 줄바꿈방지
    				sendMessage(currentRoomId, chatMessages);
    			}
    		}
    	})
    }    
    
    enableChatInput(false);
    showChatUI(false);

  
    
   
    


   
    
}); //DOM끝






//팝업 생성/삭제 함수
function showOptionsPopup(anchorElem) {
    // 이미 있으면 제거
    const old = document.getElementById('chat-options-popup');
    if (old) old.remove();
    // 팝업 생성
    const popup = document.createElement('div');
    popup.id = 'chat-options-popup';
    popup.style.display = 'block';
    popup.style.position = 'absolute';
    popup.style.right = '0';
    popup.style.top = '38px';
    popup.style.background = '#fff';
    popup.style.border = '1px solid #bbb';
    popup.style.borderRadius = '8px';
    popup.style.minWidth = '220px';
    popup.style.minHeight = '50px';
    popup.style.zIndex = '99999';
    popup.innerHTML = `
        <div class="chat-option-item" id="exit-chatroom-btn" style="background:#e74c3c;color:#fff;border-radius:8px;font-size:15px;font-weight:700;margin-bottom:2px;cursor:pointer;">채팅방 나가기</div>
    `;
    anchorElem.parentNode.appendChild(popup);

    // 나가기 버튼 클릭 이벤트
    popup.querySelector('#exit-chatroom-btn').onclick = function(e) {
        popup.remove();
        showExitChatroomModal();
    };

    // 외부 클릭시 닫기
    setTimeout(() => {
        document.addEventListener('mousedown', function handler(ev) {
            if (!popup.contains(ev.target) && ev.target !== anchorElem) {
                popup.remove();
                document.removeEventListener('mousedown', handler);
            }
        });
    }, 30);
}

//첫번째 팝업(정말 나가시겠습니까?)
function showExitChatroomModal() {
    removeModalById('exit-chatroom-modal-bg');
    const modalBg = document.createElement('div');
    modalBg.className = 'custom-modal-bg';
    modalBg.id = 'exit-chatroom-modal-bg';
    modalBg.innerHTML = `
        <div class="custom-modal">
            <button class="close-btn" title="닫기">&times;</button>
            <div class="exit-text">정말 채팅방을 나가시겠습니까?<br>대화내용을 복구할 수 없습니다.</div>
            <button class="confirm-btn">확인</button>
        </div>
    `;
    document.body.appendChild(modalBg);

    modalBg.querySelector('.close-btn').onclick = () => modalBg.remove();
    modalBg.querySelector('.confirm-btn').onclick = function() {
        modalBg.remove();
        // --- 실제 삭제 요청 ---
        fetch(contextPath + '/chat/removeroom?roomId=' + currentRoomId, {
            method: 'POST'
        })
        .then(res => res.json())
        .then(data => {
            console.log('삭제 결과:', data);
            if (data.success) {
                showExitDonePopup().then(() => {
                    // 팝업이 사라진 후에 리스트 리로드!!
                    reloadRecentRoomList();
                });
            } else {
                alert('삭제 실패: ' + (data.message || ''));
            }
        })
        .catch(err => {
            alert('삭제 중 오류 발생: ' + err);
        });
    };
}

//두번째 팝업(나가기 완료)
function showExitDonePopup() {
    return new Promise((resolve) => {
        removeModalById('exit-chatroom-done-bg');
        const doneBg = document.createElement('div');
        doneBg.className = 'custom-modal-bg';
        doneBg.id = 'exit-chatroom-done-bg';
        doneBg.style.position = 'fixed';   // ← 반드시 fixed
        doneBg.style.top = '50%';
        doneBg.style.left = '50%';
        doneBg.style.transform = 'translate(-50%, -50%)';
        doneBg.style.zIndex = '999999';    // ← z-index 높게!
        doneBg.innerHTML = `
            <div class="custom-modal">
                <button class="close-btn" title="닫기">&times;</button>
                <div class="exit-text">채팅방 나가기 되었습니다.</div>
            </div>
        `;
        document.body.appendChild(doneBg);

        setTimeout(() => {
            doneBg.remove();
            resolve();
        }, 2000);

        doneBg.querySelector('.close-btn').onclick = () => {
            doneBg.remove();
            resolve();
        };
    });
}






function reloadRecentRoomList() {
    const defaultImg = contextPath + '/resources/image/profile-default.png';
    fetch(contextPath + '/api/chat/recentRoomList')
        .then(res => res.json())
        .then(data => {
            const chatListRenderArea = document.getElementById('chatListRenderArea');
            if (!chatListRenderArea) return;
            chatListRenderArea.innerHTML = '';

            const chats = Array.isArray(data.chats) ? data.chats : [];
            const profileImages = Array.isArray(data.profileImage) ? data.profileImage : [];

            chats.forEach(chat => {
                // 프로필 이미지 계산 기존대로
                let imgSrc = defaultImg;
                const profileInfo = profileImages.find(pi => String(pi.chatRoomId) === String(chat.roomId));
                if (profileInfo && profileInfo.sellerProfileImageKey) {
                    imgSrc = 'https://jscode-upload-images.s3.ap-northeast-2.amazonaws.com/' + profileInfo.sellerProfileImageKey;
                }

                // 현재 로그인한 계정 ID (판매자/구매자 판별)
                const myAccountId = window.myAccountId;

                imgSrc = defaultImg;
                let opponentNickName = '';
                // 상대방 닉네임/ID 결정
                if (chat.sellerAccountId === myAccountId) {
                    // 내가 판매자 → 상대방은 구매자
                    opponentNickName = chat.buyerNickName || chat.buyerName || chat.buyerAccountId || '';
                    opponentAccountId = chat.buyerAccountId || '';
                } else if (chat.buyerAccountId === myAccountId) {
                    // 내가 구매자 → 상대방은 판매자
                    opponentNickName = chat.sellerNickName || chat.sellerName || chat.sellerAccountId || '';
                    opponentAccountId = chat.sellerAccountId || '';
                } else {
                    // 예외(운영자, 자기 자신 등)
                    opponentNickName = chat.buyerNickName || chat.sellerNickName || '';
                    opponentAccountId = '';
                }

                // 상대방 ID 기준으로 프로필이미지 결정
                if (profileInfo) {
                    if (opponentAccountId === profileInfo.productSellerAccountId && profileInfo.sellerProfileImageKey) {
                        // 상대방이 판매자일 때
                        imgSrc = 'https://jscode-upload-images.s3.ap-northeast-2.amazonaws.com/' + profileInfo.sellerProfileImageKey;
                    } else if (opponentAccountId === profileInfo.chatReceiverAccountId && profileInfo.receiverProfileImageKey) {
                        // 상대방이 구매자일 때
                        imgSrc = 'https://jscode-upload-images.s3.ap-northeast-2.amazonaws.com/' + profileInfo.receiverProfileImageKey;
                    } else if (profileInfo.otherProfileImageKey) {
                        // 기타 예외케이스
                        imgSrc = 'https://jscode-upload-images.s3.ap-northeast-2.amazonaws.com/' + profileInfo.otherProfileImageKey;
                    }
                }

                // 메시지/시간 기존대로
                const lastMsg = chat.lastMessage || '';
                const lastMsgTime = chat.chatLastMessageAt || '';

                // 채팅방 아이템 HTML
                const html =
                    '<div class="chatList" data-room-id="'+chat.roomId + '">' +
                        '<span class="chat-profile-img">' +
                            '<img src="' + imgSrc + '" alt="프로필 이미지" onerror="this.src=\'' + defaultImg + '\'"/>' +
                        '</span>' +
                        '<div class="chat-info-wrap">' +
                            '<div class="chat-user-row">' +
                                chat.productName + ' / ' + opponentNickName +
                            '</div>' +
                            '<div class="chat-message-row">' +
                                lastMsg +
                            '</div>' +
                            '<div class="chat-meta-row">' +
                                lastMsgTime +
                            '</div>' +
                        '</div>' +
                        '<span class="unread-badge"></span>' +
                    '</div>';

                chatListRenderArea.insertAdjacentHTML('beforeend', html);
            });
            
            // 채팅방 클릭 이벤트 바인딩
            chatListRenderArea.querySelectorAll('.chatList').forEach(function(chatDiv) {
                chatDiv.addEventListener('click', function() {
                    // 하이라이트 처리
                    chatListRenderArea.querySelectorAll('.chatList').forEach(el => {
                        el.classList.remove('highlight', 'selected');
                    });
                    chatDiv.classList.add('highlight', 'selected');
                    const roomId = chatDiv.getAttribute('data-room-id');
                    if (roomId) {
                        selectedRoomId = roomId;
                        currentRoomId = roomId; // ★ currentRoomId를 반드시 설정
                        // 메시지 영역 초기화
                        chatHistory.innerHTML = "";
                        renderedMessageIds.clear();
                        showChatUI(true); // 채팅 UI 활성화
                        loadChatHistory(roomId).then(() => {
                            if (typeof connectAndSubscribe === 'function') {
                                connectAndSubscribe(roomId);
                            }
                        });
                    }
                });
            });
            
         // === [여기에 추가!] ===
            // 채팅방 렌더링 후, 미읽은 메시지 뱃지 표시
            fetch(contextPath + '/api/chat/unreadCount?userId=' + userId)
                .then(res => res.json())
                .then(unreadCounts => {
                    updateUnreadBadges(unreadCounts); // 뱃지 표시
                });
            
            
            
        }) // ← forEach 바깥에 닫는 괄호!
        .catch(err => {
            console.error('채팅방 목록 재요청 에러:', err);
        });
}



//중복 제거 함수
function removeModalById(id) {
    const elem = document.getElementById(id);
    if (elem) elem.remove();
    console.log('id: ', id);
}


/* [추가] 채팅 UI show/hide 함수 */
function showChatUI(isRoomSelected=true) {
    if (isRoomSelected) {
        // 채팅방 선택됨: 입력 보여주고, history 보여주고, 안내 메시지는 조건부
        chatInputGroup.style.display = "flex";
        chatHistory.style.display = "flex";
        // 안내 메시지는 대화 내역 없을 때만 show
        centerMessage.style.display = "none"; // hide "채팅방을 먼저 선택해주세요"
    } else {
        // 채팅방 미선택: 안내 메시지 show, 나머지 hide
        centerMessage.textContent = "채팅방을 먼저 선택해주세요";
        centerMessage.style.display = "block";
        chatInputGroup.style.display = "none";
        chatHistory.style.display = "none";
        productInfoArea.innerHTML = ""; // 상품영역도 숨김
    }
}

function loadUnreadCounts() {
    fetch(contextPath + '/api/chat/unreadCount?userId=' + userId)
        .then(res => res.json())
        .then(unreadCounts => {
            updateUnreadBadges(unreadCounts);
        });
}
function updateUnreadBadges(unreadCounts) {
    document.querySelectorAll('.chatList').forEach(function(roomElem) {
        var roomId = roomElem.getAttribute('data-room-id');
        var count = unreadCounts[roomId] || 0;
        let badge = roomElem.querySelector('.unread-badge');
        if (!badge) {
            badge = document.createElement('span');
            badge.className = 'unread-badge';
            roomElem.appendChild(badge);
        }
        if (count > 0) {
            badge.textContent = count;
            badge.style.display = 'inline-block';
        } else {
            badge.style.display = 'none';
        }
    });
}

//--- 읽음 처리 ---
function markRoomMessagesAsRead(roomId, unreadCount) {
    // userId는 chat_receiver 기준(로그인 사용자)
    fetch(contextPath + '/api/alarm/readAll', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            roomId: roomId,
            userId: userId, // chat_receiver
            count: unreadCount
        })
    })
    .then(res => res.json())
    .then(data => {
    	console.log('읽음처리 data: ', data);
        // 성공 시 뱃지 제거, 알림 팝업 제거
        removeUnreadBadge(roomId);
        removeAlarmPopupRoom(roomId);
    })
    .catch(err => {
    	// 실패해도 UI 뱃지/팝업 제거 시도
        removeUnreadBadge(roomId);
        removeAlarmPopupRoom(roomId);
    });
}

function markRoomMessagesAsRead(roomId, unreadCount) {
	console.log('roomId: ', roomId, ' ,unreadCount: ', unreadCount);
    fetch(contextPath + '/api/alarm/readAll', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            roomId: roomId,
            userId: userId,
            count: unreadCount
        })
    })
    .then(res => res.json())
    .then(data => {
    	console.log('data: ', data);
        removeUnreadBadge(roomId);
        removeAlarmPopupRoom(roomId);
    })
    .catch(err => {
        console.error('안읽은 메시지 읽음 처리 에러:', err);
    });
}



//--- 알림 팝업에서 읽음 처리 ---
function removeAlarmPopupRoom(roomId) {
    // 알림 팝업에서 해당 roomId의 메시지 제거
    const alarmArea = document.getElementById('alarmArea');
 	console.log('removeAlarmPopupRoom: ' , alarmArea);
    if (alarmArea) {
        const alarmLinks = alarmArea.querySelectorAll('.alarm-link[data-room-id="' + roomId + '"]');
        alarmLinks.forEach(link => {
            const liElem = link.closest('li');
            if (liElem) liElem.remove();
        });
        // 알림이 모두 없어졌으면 팝업 닫기
        const remainLinks = alarmArea.querySelectorAll('.alarm-link');
        if (remainLinks.length === 0) {
            closeAlarmPopup();
        }
    }
}

// --- 뱃지 제거 ---
function removeUnreadBadge(roomId) {
	console.log('removeUnreadBadge() : roomId: ',roomId);
    document.querySelectorAll('.chatList[data-room-id="' + roomId + '"] .unread-badge').forEach(badge => {
        badge.style.display = 'none';
        badge.textContent = '';
    });
}

function enableChatInput(enable) {
    const input = document.querySelector('input[placeholder="채팅메시지를 입력하세요"]');
    const button = document.querySelector('button[type="submit"]');
    if (input && button) {
        input.disabled = !enable;
        button.disabled = !enable;
    }
}


function loadChatHeader(product, buyerId, sellerId, sellerAccountId, buyerAccountId) {
    const chatHeader = document.getElementById('chat-header');
    console.log('loadChatHeader 호출됨');
    console.log('chatHeader:', chatHeader);
    console.log('buyerId:', buyerId, 'sellerId:', sellerId, 'sellerAccountId:', sellerAccountId, 'buyerAccountId:', buyerAccountId);

    // sellerAccountId와 buyerAccountId를 안전하게 처리
    const sellerText = typeof sellerAccountId === 'string' && sellerAccountId.trim() !== '' ? sellerAccountId : "정보 없음";
    const buyerText = typeof buyerAccountId === 'string' && buyerAccountId.trim() !== '' ? buyerAccountId : "구매자 계정 정보 없음";

    if (String(userId) === String(buyerId)) {
        // 현재 사용자가 구매자인 경우
        chatHeader.innerHTML = `<strong>상품 판매자:</strong> ${sellerText}`;
    } else if (String(userId) === String(sellerId)) {
        // 현재 사용자가 판매자인 경우
        chatHeader.innerHTML = `<strong>구매자:</strong> ${buyerText}`;
    } else {
        // 알 수 없는 역할일 경우 기본 메시지 표시
        chatHeader.innerHTML = `<strong>채팅 상대 정보를 불러올 수 없습니다.</strong>`;
    }
}

function loadChatHistory(roomId) {
	console.log('loadChatHistory() 실행');
    return fetch(contextPath + '/chat/message?roomId=' + roomId)
        .then(response => response.json())
        .then(data => {
            console.log('Server Response:', data); // 서버 응답 로그 출력
            chatHistory.innerHTML = "";
            renderedMessageIds.clear();
            
            buyerId = null;
            buyerAccountId = "";
            const sellerId = data.product.sellerId || null; // 판매자 ID
            const sellerAccountId = data.product.chatSellerAccountId || ""; // 판매자의 accountId
            //let buyerAccountId = ""; // 구매자의 accountId 초기화

            // 전역 저장
            window.chatMessages = Array.isArray(data.chatMessages) ? data.chatMessages : [];
            

            // 판매자 닉네임/ID도 전역 저장
            window.chatSellerNickName = window.chatMessages.length > 0 ? window.chatMessages[0].chatSellerNickName || "" : "";
            window.sellerId = data.product.sellerId || null;
            
           // === buyerId와 buyerAccountId 추출 ===
            if (Array.isArray(data.chatMessages) && data.chatMessages.length > 0) {
                // BUYER가 보낸 메시지 중 첫 번째에서 buyer 정보 추출
                const buyerMessage = data.chatMessages.find(msg => msg.senderRole === "BUYER");
                if (buyerMessage) {
                    buyerId = buyerMessage.buyerId || buyerMessage.chatSender || null;
                    buyerAccountId = buyerMessage.chatSenderAccountId || "";
                }
            }
         	// 만약 위에서 못 찾았으면 product에서 시도 (없으면 null/"")
            if (!buyerId && data.product && data.product.buyerId) {
                buyerId = data.product.buyerId;
            }
            if (!buyerAccountId && data.product && data.product.buyerAccountId) {
                buyerAccountId = data.product.buyerAccountId;
            }
            
            // ★ 추가: 전역 저장!
            window.buyerId = buyerId;
            window.buyerAccountId = buyerAccountId;
            window.sellerId = sellerId; // ★ 추가!
            
            // ★ 여기에 추가!
            window.lastProductInfo = data.product;
            
            // ★ 판매자 닉네임 전역 저장 (chatMessages에서 첫 메시지의 chatSellerNickName 사용)
            if (Array.isArray(data.chatMessages) && data.chatMessages.length > 0) {
                window.chatSellerNickName = data.chatMessages[0].chatSellerNickName || "";
            } else {
                window.chatSellerNickName = "";
            }
            
            // 디버깅 출력
            console.log("buyerId: ", buyerId, " sellerId: ", sellerId, " sellerAccountId: ", sellerAccountId, " buyerAccountId: ", buyerAccountId);

            
            
            
            renderProductInfo(data.product, data.chatMessages || []);

            const messages = Array.isArray(data.chatMessages) ? data.chatMessages : [];
            messages.forEach(chat => {
                addChatMessageToHistory(chat);
            });

            // [변경] 안내 메시지: 대화 없으면 "판매자와 채팅을 시작해보세요"
            if (messages.length === 0) {
                centerMessage.textContent = "판매자와 채팅을 시작해보세요";
                centerMessage.style.display = "block";
                // 반드시 Promise를 반환!
                return Promise.resolve();
            } else {
                centerMessage.style.display = "none";
                // 대화가 있으면 상품정보 + 결제버튼 조건을 위해 count API 호출
                return fetchChatCount(roomId, buyerId, sellerId).then(totalChatCount => {
                	renderProductInfo(data.product, data.chatMessages || [], totalChatCount);
                })
            }
            
            
        });
}

//fetchChatCount 함수 변경
function fetchChatCount(roomId, buyerId, sellerId) {
    return fetch(contextPath + '/api/chat/count?roomId=' + roomId 
        + '&buyerId=' + buyerId + '&sellerId=' + sellerId)
        .then(res => res.json())
        .then(data => data.totalChatCount)
        .catch(() => 0);
}


function renderProductInfo(product, chatMessages, totalChatCount) {
	  console.log('Rendering Product Info:', product); // 서버에서 전달된 product 확인
      const price = Number(product.productPrice);
	  console.log('product sellerId: ', product.sellerId);

	  // 구매자인지 판단 (userId와 product.buyerId 비교)
	  let isBuyer = String(userId) === String(product.buyerId);

	  // 결제버튼 노출 조건: 구매자이면서 총 채팅횟수 2회 이상
	  const showPayButton = isBuyer && totalChatCount >= 2;
	 
	  let html = '<div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:10px;">'
		  // 왼쪽: 상품명/가격/결제버튼
		  + '<div style="display:flex; flex-direction:column;">'
		    + '<div>'
		      + '<strong>상품명:</strong> ' + product.productName
		    + '</div>'
		    + '<div style="display:flex; align-items:center;">'
		      + '<strong>가격:</strong> ' + product.productPrice + '원';
		
	  if (String(userId) === String(product.buyerId) && totalChatCount >= 2) {
		    html += '<button'
		      + ' id="pay-btn"'
		      + ' style="margin-left:12px;"'
		      + ' data-buyer-id="' + userId + '"'
		      + ' data-seller-id="' + product.sellerId + '"'
		      + ' data-seller-account-id="' + product.chatSellerAccountId + '"'
		      + ' data-seller-nick-name="' + product.chatSellerNickName + '"'
		      + ' data-product-name="' + product.productName + '"'
		      + ' data-product-id="' + product.productId + '"'
		      + '>결제하기</button>';
	  }
		
	  html += '</div>' // 가격/결제버튼 라인 끝
		  + '</div>' // 왼쪽 컬럼 끝
		  // 오른쪽: 쩜세개 버튼
		  + '<div style="position:relative;">'
		    + '<button id="chat-options-btn" style="background:none; border:none; font-size:32px; cursor:pointer;" title="옵션">&#x22EE;</button>'
		    + '<div id="chat-options-popup" style="display:none; position:absolute; right:0; top:38px; background:#f6f6f6; border:1px solid #bbb; border-radius:8px; min-width:120px; z-index:999;">'
		      + '<div class="chat-option-item" id="view-product-info" style="padding:12px; cursor:pointer; font-size:15px; border-bottom:1px solid #eee;">상품정보 보기</div>'
		      + '<div class="chat-option-item" id="exit-chatroom" style="padding:12px; cursor:pointer; font-size:15px;">대화방 나가기</div>'
		    + '</div>'
		  + '</div>' // 오른쪽 끝
		+ '</div>'; // 전체 flex 행 끝


        // 1. 구매자/판매자 구분
        // 현재 로그인한 사용자가 구매자인 경우에만 결제 버튼 노출
        isBuyer = String(userId) === String(product.buyerId || window.buyerId);
        
        
     // 2. DB에서 받아온 구매자-판매자간 총 채팅 횟수(totalChatCount) 활용
        // totalChatCount는 반드시 서버에서 받아온 값을 파라미터로 전달해야 함
        if (isBuyer && totalChatCount >= 2) {
            html += `<button
                id="pay-btn"
                data-buyer-id="\${userId}"
                data-seller-id="\${product.sellerId}"
                data-seller-account-id="\${product.chatSellerAccountId}"
                data-seller-nick-name="\${product.chatSellerNickName}"
                data-product-name="\${product.productName}"
                data-product-id="\${product.productId}"
            >결제하기</button>`;
        }


    
    
    productInfoArea.innerHTML = html;

    const payBtn = document.getElementById('pay-btn');
    if (payBtn) {
    	
       
        payBtn.onclick = function(e) {
            const btn = e.currentTarget;
            console.log("btn.dataset: ", btn.dataset); // 버튼 데이터 확인
            const buyerId = btn.dataset.buyerId; // buyerId 가져오기
            const chatSellerAccountId = btn.dataset.sellerAccountId; // Fix: Access chatSellerAccountId from dataset
            console.log('결제버튼 클릭 - chatSellerAccountId1:', chatSellerAccountId);
            const quantity = 1;
            
            
            const productId = product.productId;
            const payUrl = contextPath + '/order/pay'
            	+ '?buyerId=' + encodeURIComponent(buyerId)
                + '&sellerId=' + encodeURIComponent(product.sellerId)
                + '&chatSellerAccountId=' + encodeURIComponent(chatSellerAccountId)
                + '&productName=' + encodeURIComponent(product.productName)
                + '&productId=' + encodeURIComponent(product.productId)
                + '&quantity=' + encodeURIComponent(quantity);
            console.log('payUrl: ', payUrl);
            window.location.href = payUrl;
        };
    }
}

function addChatMessageToHistory(chat) {
	// 이미 렌더링된 메시지는 건너뜀
    if (chat.messageId && renderedMessageIds.has(chat.messageId)) return;
    if (chat.messageId) renderedMessageIds.add(chat.messageId);

    // 내 닉네임은 로그인 시 window.nickName에 저장되어 있다고 가정
    const myNickName = window.nickName; // 예: "캡틴미영짱짱" 또는 "소금파전"
    // 내 계정ID는 로그인 시 window.userId에 저장되어 있다고 가정
    const myId = String(window.userId); // 계정ID로 비교 (더 정확함)
    const senderId = String(chat.chatSender);
    const receiverId = String(chat.chatReceiver);
    // 내가 sender인지 receiver인지 판별
    const isMeSender = String(chat.chatSenderAccountId) === String(myNickName);
    const isMeReceiver = String(chat.chatReceiverAccountId) === String(myNickName);

    let alignClass = "left"; // 기본 왼쪽

    if (senderId === myId) {
        // 내가 보낸 메시지
        alignClass = "right";
    } else {
        // 내가 받은 메시지
        alignClass = "left";
    }
    let msg = chat.message || chat.chatMessage || "";
    let formattedTime = formatChatTime(chat.chatCreatedAt || "");

    let html =
        '<div class="chat-message ' + alignClass + '">' +
            '<div class="chat-userid">' + (chat.chatSenderAccountId || chat.chatSenderUserName || "") + '</div>' +
            '<div class="chat-text">' + msg + '</div>' +
            '<div class="chat-time">' + formattedTime + '</div>' +
        '</div>';
    chatHistory.innerHTML += html;

    // 스크롤을 최신 메시지로 이동
    chatHistory.scrollTop = chatHistory.scrollHeight;
}


//시간 형식 변환 함수 추가
function formatChatTime(timeString) {
    if (!timeString) return "시간 정보 없음";
    if (/^\d+$/.test(timeString)) {
        const date = new Date(Number(timeString));
        if (!isNaN(date.getTime())) {
            return date.toLocaleString("ko-KR", {
                year: "numeric", month: "2-digit", day: "2-digit",
                hour: "2-digit", minute: "2-digit", second: "2-digit",
                hour12: true
            });
        }
    }
    let date = new Date(timeString);
    console.log('date: ', date);
    if (isNaN(date.getTime()) && timeString.includes('+09:00')) {
        date = new Date(timeString.replace('+09:00', 'Z'));
    }
    if (!isNaN(date.getTime())) {
        return date.toLocaleString("ko-KR", {
            year: "numeric", month: "2-digit", day: "2-digit",
            hour: "2-digit", minute: "2-digit", second: "2-digit",
            hour12: true
        });
    }
    return "시간 정보 없음";
}


function connectAndSubscribe(currentRoomId) {
    if (!window.stompClient || !window.stompClient.connected) {
        const socket = new SockJS(contextPath + '/ws-chat');
        window.stompClient = Stomp.over(socket);
        enableChatInput(false); // 연결 전 입력 비활성화
        window.stompClient.connect({}, function() {
            window.isConnected = true;
            subscribeRoom(currentRoomId); // ★ 반드시 연결 후에만!
            enableChatInput(true);        // 연결 후 입력 가능
            subscribeNotifications();
        });
    } else {
        subscribeRoom(currentRoomId); // 이미 연결되어 있으면 바로 구독
        enableChatInput(true);
        subscribeNotifications();
    }
}





function subscribeRoom(currentRoomId) {
	if (currentSubscription) currentSubscription.unsubscribe();
    currentSubscription = stompClient.subscribe('/topic/chat/' + currentRoomId, function (msg) {
        const chat = JSON.parse(msg.body);
       
        let rawTime = chat.chatCreatedAt || "";
        console.log("addChatMessageToHistory: rawTime =", rawTime, typeof rawTime);
       
         // === 하이라이트 처리 코드 START ===
        // 메시지 송신자 역할
        const senderRole = chat.senderRole; // "BUYER" 또는 "SELLER"
        
        // 현재 사용자 역할
        let currentUserRole = (String(userId) === String(chat.chatSender)) ? senderRole : (senderRole === "BUYER" ? "SELLER" : "BUYER");

        // 구매자/판매자 접속자 기록
        setUserInRoom(chat.chatRoomId, senderRole);
        setUserInRoom(chat.chatRoomId, currentUserRole);

        // === 하이라이트 처리 코드 START ===
        // 메시지의 수신자가 현재 로그인한 사용자일 때만 하이라이트!
        // userId(숫자)와 chat.chatReceiver(숫자) 또는
        // loginUserId(문자열)와 chat.chatReceiverAccountId(문자열) 비교
        if (
        		String(chat.chatReceiver) === String(userId) ||
        	     String(chat.chatReceiverAccountId) === String(loginUserId)
        	    && String(chat.chatSenderAccountId) !== String(loginUserId) 
        ) {
            highlightChatRoom(chat.chatRoomId);
        } else {
            removeHighlightChatRoom(chat.chatRoomId);
        }
        // === 하이라이트 처리 코드 END ===
        
       if (String(currentRoomId) === String(chat.chatRoomId)) {
            addChatMessageToHistory(chat);
            centerMessage.style.display = "none";
             // === 결제버튼 갱신을 위해 상품영역 재렌더링 ===
            // chatHistory.innerHTML에 메시지 추가 후, product, chatMessages를 다시 계산
            // window.lastProductInfo, chatHistory에서 메시지 목록 추출
            if (window.lastProductInfo) {
                // 채팅 메시지 목록을 chatHistory에서 직접 추출 (이미 렌더링된 메시지들)
                // 하지만 서버에서 내려온 chatMessages가 최신일 수 있으니, 아래처럼 메시지 배열 관리가 필요
                // 간단하게: chatHistory에 있는 메시지들을 모을 수도 있지만, 
                // 최신 메시지(chat)까지 포함하여 productInfoArea 갱신
                // 기존 채팅방 메시지 배열이 있으면 거기에 push
                if (!window.currentChatMessages) window.currentChatMessages = [];
                window.currentChatMessages.push(chat);
                // 여기가 핵심!
                fetchChatCount(chat.chatRoomId, window.buyerId, window.sellerId).then(totalChatCount => {
                    renderProductInfo(window.lastProductInfo, window.currentChatMessages, totalChatCount);
                });
                // productInfoArea 재렌더링
                //renderProductInfo(window.lastProductInfo, window.currentChatMessages);
            }
            
            
            
        } else if (!isMine) {
            // 수신자인 경우에만 알림 표시
            displayNotification(
                chat.chatSenderAccountId,
                chat.chatMessage,
                chat.senderRole,
                chat.chatCreatedAt,
                chat.productName
            );
        }
    // 채팅방 목록의 마지막 메시지/시간도 항상 업데이트!
       
       reloadRecentRoomList();
    });
}

function enableChatInput(enable) {
    const input = document.querySelector('input[placeholder="채팅메시지를 입력하세요"]');
    const button = document.querySelector('button[type="submit"]');
    if (input && button) {
        input.disabled = !enable;
        button.disabled = !enable;
    }
}

function getCurrentChatTime() {
	return new Date().toISOString(); // 예: "2025-08-21T13:23:59.000Z"
}


//1. 채팅방 하이라이트 함수
function highlightChatRoom(roomId) {
	// 1. 모든 채팅방의 highlight 클래스 제거
    document.querySelectorAll('.chatList').forEach(chatDiv => {
        chatDiv.classList.remove('highlight');
    });

 // 2. 선택된 채팅방만 highlight 추가
    document.querySelectorAll('.chatList').forEach(chatDiv => {
        if (String(chatDiv.dataset.roomId) === String(roomId)) {
            chatDiv.classList.add('highlight');
            // 2초 후 하이라이트 제거 (선택된 방만)
            if (highlightTimers[roomId]) clearTimeout(highlightTimers[roomId]);
            highlightTimers[roomId] = setTimeout(() => {
                chatDiv.classList.remove('highlight');
                highlightTimers[roomId] = null;
            }, 2000);
        }
    });       
}

//2. 하이라이트 제거 함수
function removeHighlightChatRoom(roomId) {
    const chatLists = document.querySelectorAll('.chatList');
    chatLists.forEach(chatDiv => {
        if (String(chatDiv.dataset.roomId) === String(roomId)) {
            chatDiv.classList.remove('highlight');
        }
    });
}

//4. 채팅방 입장시 접속자 기록 (간단 예시, 실제는 서버에서 WebSocket으로 관리)
function setUserInRoom(roomId, role) {
    if (!activeRooms[roomId]) activeRooms[roomId] = { buyer: false, seller: false };
    activeRooms[roomId][role.toLowerCase()] = true;
}





function sendMessage(currentRoomId, chatMessages = []) {
	alert('sendMessage 함수 내부 들어옴');
    // chatMessages가 undefined/null이면 window.chatMessages(전역)를 사용
    if (!Array.isArray(chatMessages) || chatMessages.length === 0) {
        chatMessages = window.chatMessages || [];
    }
    const input = document.getElementById('chatMessageInput');
    if (!input) {
        alert("채팅 입력창을 찾을 수 없습니다.");
        return;
    }
    const message = input.value;
    console.log("message: ", message);
    //if (!stompClient || !isConnected) return;
    //if (!message.trim() || !currentRoomId) return;

    // 1. productSellerId는 상품영역에서만 추출 (window.lastProductInfo를 반드시 사용)
    let productSellerId = window.lastProductInfo?.sellerId || null;
    let productSellerAccountId = window.lastProductInfo?.chatSellerAccountId || null;
    let productId = window.lastProductInfo?.productId || null;
    console.log("productSellerId: ", productSellerId, " productSellerAccountId: ", " productId: ", productId);

    // 2. buyerId/buyerAccountId는 chatMessages에서만 추출
    let buyerId = null, buyerAccountId = null;
    if (Array.isArray(chatMessages)) {
        // BUYER가 보낸 첫번째 메시지에서 추출 (없으면 null)
        const buyerMessage = chatMessages.find(msg => msg.senderRole === "BUYER");
        if (buyerMessage) {
            buyerId = buyerMessage.buyerId || buyerMessage.chatSender || null;
            buyerAccountId = buyerMessage.chatSenderAccountId || null;
        }
    }

    // senderRole/receiverRole 계산
    let senderRole = null, receiverRole = null;
    if (String(userId) === String(productSellerId)) {
    	  senderRole = "SELLER";
    	  receiverRole = "BUYER";
   	} else {
   	  // 판매자가 아닌 모든 사용자는 buyer로 간주
   	  senderRole = "BUYER";
   	  receiverRole = "SELLER";
   	  // buyerId를 현재 로그인한 사용자로 지정(기존 buyer가 없으면)
   	  if (!buyerId) {
   	    buyerId = userId;
   	  }
   	}

    // chatSender/chatReceiver 값 결정
    const chatSender = userId;
    const chatReceiver = (senderRole === "SELLER") ? buyerId : productSellerId;
    const chatReceiverAccountId = (senderRole === "SELLER") ? buyerAccountId : productSellerAccountId;

    // 방어 코드: id 누락 시 안내
    if (!productSellerId || !buyerId) {
        alert("buyer/seller 정보가 없어 메시지 전송이 불가능합니다.");
        return;
    }

    // 방어 코드: 구매자/판매자 계정정보 누락 시 안내
    if (senderRole === "SELLER" && !buyerAccountId) {
        alert("구매자 계정정보가 없어 메시지 전송이 불가능합니다.");
        return;
    }
    if (senderRole === "BUYER" && !productSellerAccountId) {
        alert("판매자 계정정보가 없어 메시지 전송이 불가능합니다.");
        return;
    }

    // ★ 현재 시간 넣기
    const chatCreatedAt = getCurrentChatTime();

    const chatMessage = {
        chatRoomId: currentRoomId,
        chatMessage: message,
        chatSenderAccountId: nickName,
        chatReceiverAccountId: chatReceiverAccountId,
        productId: productId,
        buyerId: buyerId,
        senderRole: senderRole,
        receiverRole: receiverRole,
        chatSender: chatSender,
        chatReceiver: chatReceiver,
        chatCreatedAt: chatCreatedAt
    };

    console.log('[sendMessage] chatMessage:', chatMessage);
    stompClient.send("/app/chat.send", {}, JSON.stringify(chatMessage));
    
 
    
    reloadRecentRoomList();
    input.value = "";
    
}



//ISO 포맷/타임스탬프 모두 지원
    // 시간 포맷 함수 JS에서 구현 (JSP에서는 EL/함수 호출 X)
    function formatTimestamp(ts) {
        if (!ts) return '';
        let date;
        if (typeof ts === 'number' || /^\d+$/.test(ts)) {
            date = new Date(Number(ts));
        } else if (typeof ts === 'string') {
            date = new Date(ts);
            if (isNaN(date.getTime()) && ts.includes('+09:00')) {
                date = new Date(ts.replace('+09:00', 'Z'));
            }
        } else {
            return '';
        }
        if (isNaN(date.getTime())) return '';
        const yyyy = date.getFullYear();
        const mm = String(date.getMonth() + 1).padStart(2, '0');
        const dd = String(date.getDate()).padStart(2, '0');
        const hh = String(date.getHours()).padStart(2, '0');
        const min = String(date.getMinutes()).padStart(2, '0');
        const ss = String(date.getSeconds()).padStart(2, '0');
        return yyyy + '-' + mm + '-' + dd + ' ' + hh + ':' + min + ':' + ss;
    }


    function updateChatListLastMessage(roomId, lastMsg, lastMsgTime) {
        // 채팅방 목록에서 해당 roomId의 최근 메시지/시간을 업데이트
        const chatDiv = document.querySelector('.chatList[data-room-id="' + roomId + '"]');
        if (chatDiv) {
            const msgRow = chatDiv.querySelector('.chat-message-row');
            const timeRow = chatDiv.querySelector('.chat-meta-row');
            if (msgRow) msgRow.textContent = lastMsg;
            if (timeRow) timeRow.textContent = lastMsgTime;
        }
    }




//window에 등록
window.showExitDonePopup = showExitDonePopup;
window.showExitChatroomModal = showExitChatroomModal; // window에 등록
window.highlightChatRoom = highlightChatRoom;
window.updateChatListLastMessage = updateChatListLastMessage;
window.displayNotification = displayNotification;
</script>
</body>
</html>