# 로컬 실행 가이드

Puppit 을 개발 PC 에서 처음부터 띄우는 절차. Windows 기준이며 macOS/Linux 는 경로 구분자와
`mvnw.cmd` → `./mvnw` 만 바꿔 읽으면 된다.

## 0. 사전 요구사항

| 도구 | 버전 | 비고 |
|---|---|---|
| JDK | 11 이상 (17 로 빌드/실행 확인됨) | `java -version` |
| Docker Desktop | 최신 | MySQL 을 컨테이너로 띄우는 경우. 없으면 §1-B 참고 |
| Apache Tomcat | 9.0.x | WAR 를 배포할 서블릿 컨테이너 |
| Maven | **불필요** | 저장소에 Maven Wrapper(`mvnw`) 포함 |

> Kakao 로그인 / S3 이미지 업로드 / 포인트 결제는 외부 서비스 키가 있어야 동작한다.
> 키 없이도 앱은 뜨고, 상품 목록·회원가입·로그인 등 기본 흐름은 확인할 수 있다. (§5 참고)

---

## 1. 데이터베이스

### 1-A. Docker 로 띄우기 (권장)

저장소 루트에서:

```powershell
copy .env.example .env      # 값 수정 불필요, 기본값이면 그대로
docker compose up -d
```

- 최초 기동 시 `puppit/src/main/resources/SCHEMA.sql` → `docker/mysql/seed-dev.sql` 순서로 자동 적용된다.
  (스키마 = 테이블 정의, 시드 = 카테고리/지역/상태 등 조회용 마스터 데이터)
- 접속 정보: `localhost:3306`, DB `db_puppit`, 계정 `root` / `puppit`
- 로그 확인: `docker compose logs -f mysql`
- 완전 초기화(스키마부터 다시): `docker compose down -v` 후 다시 `up -d`

### 1-B. 로컬에 설치된 MySQL 사용

```sql
CREATE DATABASE db_puppit CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
```

그 다음 순서대로 실행:

```powershell
mysql -u root -p db_puppit < puppit/src/main/resources/SCHEMA.sql
mysql -u root -p db_puppit < docker/mysql/seed-dev.sql
```

`SCHEMA.sql` 은 앞뒤로 `SET FOREIGN_KEY_CHECKS = 0/1` 을 두어 테이블 순서와 무관하게 통째로 실행된다.

---

## 2. 시크릿 설정 파일

`application-secret.properties` 는 `CHANGE_ME` 뿐인 템플릿으로 git에 커밋돼 있다.
이 파일을 복사해서 실제 값을 채운 `application-secret.local.properties` 를 만든다
(이 파일만 `.gitignore` 처리되어 커밋되지 않는다).

```powershell
copy puppit\src\main\resources\application-secret.properties ^
     puppit\src\main\resources\application-secret.local.properties
```

생성한 파일에서 최소한 DB 항목만 채우면 로컬 구동이 된다. (Docker 기본값 기준)

```properties
db.url=jdbc:mysql://localhost:3306/db_puppit?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8&allowPublicKeyRetrieval=true&useSSL=false
db.username=root
db.password=puppit
```

---

## 3. 빌드

```powershell
cd puppit
.\mvnw.cmd clean package
```

- 최초 실행은 의존성을 내려받아 수 분 걸린다. (Wrapper 가 Maven 3.9.11 도 자동 설치)
- 산출물: `puppit/target/puppit-1.0.0.war`
- 테스트만: `.\mvnw.cmd test` / 테스트 건너뛰고 패키징: `.\mvnw.cmd -DskipTests package`

---

## 4. Tomcat 배포 및 실행

1. `puppit/target/puppit-1.0.0.war` 를 `TOMCAT_HOME/webapps/puppit.war` 로 복사
2. Tomcat 기동
   ```powershell
   $env:CATALINA_HOME\bin\startup.bat        # 또는 IDE 의 Tomcat 실행 구성
   ```
3. 컨텍스트 경로가 `puppit` 이므로 접속 주소는 **http://localhost:8080/puppit/**

> IntelliJ 라면 Run/Debug Configurations → `Tomcat Server > Local` → Deployment 에
> `puppit:war exploded` 를 추가하고 Application context 를 `/puppit` 으로 두는 방식이 편하다.

### 종료

```powershell
$env:CATALINA_HOME\bin\shutdown.bat
docker compose down          # DB 까지 내릴 때
```

---

## 5. 선택 기능용 외부 키

`application-secret.local.properties` 및 환경변수에 값을 넣어야 해당 기능이 동작한다.

| 기능 | 필요한 값 |
|---|---|
| Kakao 소셜 로그인 | `kakao.rest.api.key`, `kakao.redirect.uri` (기본 `http://localhost:8080/puppit/auth/kakao/callback`) |
| 포인트 결제 | `iamport.api.key`, `iamport.api.secret` |
| 상품/프로필 이미지 (S3) | `aws.s3.bucket` + 환경변수 `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` |

---

## 6. 트러블슈팅

| 증상 | 원인 / 해결 |
|---|---|
| `docker compose up` 후 앱에서 `Unknown database 'db_puppit'` | 이전에 다른 설정으로 만든 볼륨이 남아있음 → `docker compose down -v` 후 재기동 |
| `Access denied for user 'root'` | `.env` 의 `DB_ROOT_PASSWORD` 와 `application-secret.local.properties` 의 `db.password` 불일치 |
| `Public Key Retrieval is not allowed` | `db.url` 에 `allowPublicKeyRetrieval=true` 누락 |
| 빌드 시 한글 깨짐/인코딩 경고 | JDK 파일 인코딩 UTF-8 확인 (`-Dfile.encoding=UTF-8`) |
| 포트 3306 충돌 | `.env` 의 `DB_PORT` 변경 후 `db.url` 도 동일 포트로 수정 |
