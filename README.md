# Puppit (semi-project)

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
