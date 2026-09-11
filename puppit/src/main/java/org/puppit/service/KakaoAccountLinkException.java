package org.puppit.service;

// 카카오 로그인 이메일이 이미 가입된 로컬 계정과 겹칠 때 던진다.
// 로컬 회원가입은 이메일 소유권을 검증하지 않으므로(가입 시 인증 메일 없음),
// 카카오가 인증한 이메일만 믿고 자동으로 계정을 연동하면 공격자가 피해자의
// 이메일로 로컬 계정을 미리 만들어 두고, 피해자가 나중에 카카오로 로그인할 때
// 그 계정에 흡수되게 만드는 "계정 선점(pre-account takeover)"이 가능해진다.
// 그래서 자동 연동 대신 이 예외로 명시적으로 거부한다.
public class KakaoAccountLinkException extends RuntimeException {

  public KakaoAccountLinkException(String message) {
    super(message);
  }
}
