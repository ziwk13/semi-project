package org.puppit.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

import org.springframework.stereotype.Component;

@Component
public class SecureUtil {
  public byte[] getSalt() {
    SecureRandom random = new SecureRandom();
    byte[] salt = new byte[16];
    random.nextBytes(salt);
    return salt;
  }
  
  //----- SHA256 해시값 반환 (Salt 적용 없음)
  public String hashSHA256(final String password) {    
    try {
      MessageDigest md = MessageDigest.getInstance("SHA-256");  //----- SHA-256 단방향 암호화 알고리즘 (MD5, SHA-1, SHA-512, SHA3-256 등 가능)
      byte[] hash = md.digest(password.getBytes());
      StringBuilder hexString = new StringBuilder();
      for (byte b : hash) {
        hexString.append(String.format("%02x", b));
      }
      return hexString.toString();
    } catch (NoSuchAlgorithmException e) {
      throw new RuntimeException(e);
    }
  }
  //----- SHA256 해시값 반환 (Salt 적용)
  public String hashSHA256(final String password, final byte[] salt) {    
    try {
      MessageDigest md = MessageDigest.getInstance("SHA-256");  //----- SHA-256 단방향 암호화 알고리즘 (MD5, SHA-1, SHA-512, SHA3-256 등 가능)
      md.update(salt);  //----- Salt 적용
      byte[] hash = md.digest(password.getBytes());
      StringBuilder hexString = new StringBuilder();
      for (byte b : hash) {
        hexString.append(String.format("%02x", b));
      }
      return hexString.toString();
    } catch (NoSuchAlgorithmException e) {
      throw new RuntimeException(e);
    }
  }
  //----- 반복횟수가 많은 KDF(Key Derivation Function) 방식을 이용해 더 안전한 비밀번호 해싱 가능(PBKDF2 알고리즘 사용 예시)
  public String hashPBKDF2(final String password, final byte[] salt) {
    // 반복 횟수와 해시 길이 설정 (추천: 65536, 256bit)
    try {
      int iterations = 65536;
      int keyLength = 256;
      PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, keyLength);
      SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
      byte[] hash = skf.generateSecret(spec).getEncoded();
      return Base64.getEncoder().encodeToString(hash);
    } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
      throw new RuntimeException(e);
    }
  }
  

}
