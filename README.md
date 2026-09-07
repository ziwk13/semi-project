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

빠른 경로 (Docker + Maven Wrapper):

```bash
cp .env.example .env
docker compose up -d          # MySQL + 스키마/시드 자동 적용

cp puppit/src/main/resources/application-secret.properties.example \
   puppit/src/main/resources/application-secret.properties
#   최소 db.* 만 채우면 됨 (Docker 기본값: root / puppit / db_puppit)

cd puppit && ./mvnw clean package     # Windows: .\mvnw.cmd clean package
#   → target/puppit-1.0.0.war 를 Tomcat 9 webapps/ 에 puppit.war 로 배치
#   → http://localhost:8080/puppit/
```

사전 요구사항, Docker 없이 실행, Kakao/S3/결제 키, 트러블슈팅은 **[docs/RUNNING.md](docs/RUNNING.md)** 참고.

## 원본과 달라진 점

- DB 비밀번호 / Kakao 키 / S3 버킷명을 소스에서 제거하고 `application-secret.properties` 로 외부화
  (`application-secret.properties` 는 `.gitignore` 처리, `.example` 만 커밋)
- `root-context.xml` / `servlet-context.xml` 에 `<context:property-placeholder>` 추가
- 커밋 히스토리 초기화 (원본 브랜치/PR 이력은 위 원본 저장소 참조)

> ⚠️ 원본 저장소가 public 이라 기존 자격증명은 이미 노출된 상태다.
> RDS 비밀번호 / Kakao 키 / AWS 키 / Iamport 키는 **재발급(rotate)** 후 사용할 것.

## 고도화 TODO

- [x] 빌드/실행 재현성: Maven Wrapper, `docker compose` 로 MySQL + 스키마/시드, `docs/RUNNING.md`
- [ ] 인증/인가를 Spring Security 로 통합, CSRF 방어, IDOR 제거
- [ ] 비밀번호 해시 BCrypt/Argon2 전환, 비밀번호 재설정 토큰 흐름
- [ ] 결제 웹훅 + 거래 동시성/보상 트랜잭션, 포인트 원장 테이블
- [ ] 전역 예외 처리 + 로깅 정리(System.out 제거), 에러 페이지
- [ ] DB 인덱스/제약 정리, 테스트 골격 + CI
- [ ] (선택) Spring Boot 3 / Java 17 / Jakarta 마이그레이션

## 변경 이력

### 2026-09-07 — 1단계: 빌드/실행 재현성

- **Maven Wrapper 도입** (`puppit/mvnw`, `mvnw.cmd`, `.mvn/wrapper/`): 로컬에 Maven 설치 없이
  `./mvnw clean package` 로 빌드 가능. `./mvnw clean package` → BUILD SUCCESS, `target/puppit-1.0.0.war` 확인.
- **`docker-compose.yml`** 신규: `docker compose up -d` 로 MySQL 8.0 컨테이너 기동 + 최초 1회
  `SCHEMA.sql` → `docker/mysql/seed-dev.sql` 자동 적용. `.env.example` 로 접속 정보 외부화.
- **`docker/mysql/seed-dev.sql`** 신규: 조회용 마스터 데이터(카테고리/상태/컨디션/지역) 개발 시드.
- **`SCHEMA.sql`**: 앞뒤에 `SET FOREIGN_KEY_CHECKS = 0/1` 을 추가해 테이블 정의 순서와 무관하게
  통째로 실행되도록 수정.
- **`pom.xml`**: `project.build.sourceEncoding=UTF-8` 명시 — 빌드가 OS 기본 인코딩(한국어 Windows=MS949)에
  좌우되던 문제 제거.
- **`PuppitTest.java`**: 컴파일이 깨져 있던 `import org.junit.Assert.*;` 를 정정하고 스모크 테스트 1개 추가.
- **`docs/RUNNING.md`** 신규: 사전 요구사항 / Docker 유무별 DB 준비 / 빌드 / Tomcat 배포 / 외부 키 /
  트러블슈팅까지 로컬 실행 전 과정을 문서화. README 의 "로컬 실행" 섹션은 요약본으로 축소.
- 정리: `puppit/src/main/resources/target/` 에 쌓여 있던 과거 빌드 산출물(약 68MB, 미추적)이
  리소스로 딸려 들어가 WAR 가 99MB 로 부풀던 것을 확인하고 제거 → WAR 32.8MB 로 정상화.
