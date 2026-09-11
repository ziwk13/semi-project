# Puppit (semi-project)

반려동물 용품 중고거래 웹 애플리케이션 (Spring MVC 5.3 non-Boot + JSP, MyBatis, MySQL 8, Tomcat 9).

> 원본 저장소가 public이라 기존 DB/Kakao/AWS/Iamport 키는 노출된 상태다. 재발급(rotate) 후 사용할 것.

## 로컬 실행

### 1. DB 준비

**Docker (권장)**

```bash
cp .env.example .env
docker compose up -d
```

최초 기동 시 `puppit/src/main/resources/SCHEMA.sql` → `docker/mysql/seed-dev.sql` 순서로 자동 적용된다.
접속 정보: `localhost:3306`, DB `db_puppit`, 계정 `root` / `puppit`

**로컬에 설치된 MySQL 사용**

```bash
mysql -u root -p -e "CREATE DATABASE db_puppit CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
mysql -u root -p db_puppit < puppit/src/main/resources/SCHEMA.sql
mysql -u root -p db_puppit < docker/mysql/seed-dev.sql
```

### 2. 시크릿 파일

```bash
cp puppit/src/main/resources/application-secret.properties.example \
   puppit/src/main/resources/application-secret.properties
```

최소 `db.*` 만 채우면 된다 (Docker 기본값: `root` / `puppit` / `db_puppit`).
Kakao/S3/Iamport 키가 없어도 앱은 뜬다 — 해당 기능만 동작하지 않는다.

### 3. 빌드

```bash
cd puppit && ./mvnw clean package
```

→ `target/puppit-1.0.0.war`

### 4. Tomcat 배포

```bash
cp target/puppit-1.0.0.war <TOMCAT_HOME>/webapps/puppit.war
<TOMCAT_HOME>/bin/startup.sh   # Windows: startup.bat
```

→ **http://localhost:8080/puppit/**

### 종료

```bash
<TOMCAT_HOME>/bin/shutdown.sh   # Windows: shutdown.bat
docker compose down             # DB까지 내릴 때
```

## 트러블슈팅

| 증상 | 해결 |
|---|---|
| 로컬에 MySQL이 이미 설치돼 있어 `docker compose up` 시 3306 포트 충돌 | `.env`의 `DB_PORT`를 바꾸고 `application-secret.properties`의 `db.url` 포트도 동일하게 수정 |
| `Access denied for user 'root'` | `.env`의 `DB_ROOT_PASSWORD`와 `application-secret.properties`의 `db.password` 불일치 |
| `Public Key Retrieval is not allowed` | `db.url`에 `allowPublicKeyRetrieval=true` 누락 |

더 자세한 사전 요구사항·외부 키 설정은 [docs/RUNNING.md](docs/RUNNING.md) 참고.
