# Puppit (semi-projcet)

반려동물 용품 중고거래 웹 애플리케이션. 학원 팀 프로젝트
[`choimeeyoung94/semi-team-project`](https://github.com/choimeeyoung94/semi-team-project)
를 베이스로, 개인 고도화를 위해 히스토리를 정리하고 새로 시작한 저장소.

## 기술 스택

- Java 11 (빌드 JDK 17 사용 가능), Spring MVC 5.3 (non-Boot, XML 설정), WAR / Tomcat 9
- MyBatis 3.5 + mybatis-spring, HikariCP, MySQL 8
- JSP + JSTL
- WebSocket + STOMP + SockJS (실시간 채팅/알림)
- AWS S3 (이미지), Kakao OAuth (소셜 로그인), Iamport/PortOne (포인트 결제)

## 로컬 실행

1. **설정 파일 생성**

   ```bash
   cp puppit/src/main/resources/application-secret.properties.example \
      puppit/src/main/resources/application-secret.properties
   ```

   생성한 파일에 실제 값 입력:

   | 키 | 설명 |
   |---|---|
   | `db.url` / `db.username` / `db.password` | MySQL 접속 정보 |
   | `kakao.rest.api.key` / `kakao.redirect.uri` | Kakao Developers 앱 |
   | `iamport.api.key` / `iamport.api.secret` | PortOne(구 아임포트) |
   | `aws.s3.bucket` | S3 버킷 이름 |

   AWS 자격증명은 환경변수로 주입: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`

2. **DB 스키마**: `puppit/src/main/resources/SCHEMA.sql` 참고 (외래키 순서상 그대로 실행은 안 되니 마스터 테이블부터 생성)

3. **빌드 / 배포**

   ```bash
   cd puppit
   mvn clean package        # target/puppit-1.0.0.war
   ```

   생성된 WAR 를 Tomcat 9 `webapps/` 에 `puppit.war` 로 배치 → `http://localhost:8080/puppit/`

## 원본과 달라진 점

- DB 비밀번호 / Kakao 키 / S3 버킷명을 소스에서 제거하고 `application-secret.properties` 로 외부화
  (`application-secret.properties` 는 `.gitignore` 처리, `.example` 만 커밋)
- `root-context.xml` / `servlet-context.xml` 에 `<context:property-placeholder>` 추가
- 커밋 히스토리 초기화 (원본 브랜치/PR 이력은 위 원본 저장소 참조)

> ⚠️ 원본 저장소가 public 이라 기존 자격증명은 이미 노출된 상태다.
> RDS 비밀번호 / Kakao 키 / AWS 키 / Iamport 키는 **재발급(rotate)** 후 사용할 것.

## 고도화 TODO

- [ ] 인증/인가를 Spring Security 로 통합, CSRF 방어, IDOR 제거
- [ ] 비밀번호 해시 BCrypt/Argon2 전환, 비밀번호 재설정 토큰 흐름
- [ ] 결제 웹훅 + 거래 동시성/보상 트랜잭션, 포인트 원장 테이블
- [ ] 전역 예외 처리 + 로깅 정리(System.out 제거), 에러 페이지
- [ ] DB 인덱스/제약 정리, 테스트 골격 + CI
- [ ] (선택) Spring Boot 3 / Java 17 / Jakarta 마이그레이션
