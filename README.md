# Puppit (semi-project)

반려동물 용품 중고거래 웹 애플리케이션 (Spring MVC 5.3 non-Boot + JSP, MyBatis, MySQL 8, Tomcat 9).

> MySQL만 Docker로 실행하고 앱은 로컬 JDK 11 / Tomcat 9에서 실행합니다. Compose의 계정과 비밀번호는 개발용이며 DB는 루프백 주소에만 공개합니다.

## 로컬 실행

아래 명령은 모두 **저장소 루트(`git clone` 직후 생긴 폴더)** 에서 실행한다.
(`.env.example`, `docker-compose.yml`, `puppit/` 이 한 폴더 안에 같이 보여야 정상)

### 1. DB 준비

**아래 A/B 중 하나만 실행한다** (둘 다 하지 않는다).

**A. Docker (권장)**

```bash
cp .env.example .env
docker compose up -d
```

최초 기동 시 `puppit/src/main/resources/SCHEMA.sql` → `docker/mysql/seed-dev.sql` 순서로 자동 적용된다.
접속 정보: `localhost:3306`, DB `db_puppit`, 계정 `root` / `puppit`

> `Error response from daemon: ports are not available ... 3306` 이 뜨면 PC에 MySQL이 이미 설치·구동 중이라 3306이 겹친 것이다.
> `mysql -u root -p ...` 로 우회하지 말고(A/B 혼용 금지), `.env`의 `DB_PORT`를 `3307` 등으로 바꾸고 `docker compose up -d`를 다시 실행한다.
> (이후 2번 시크릿 파일의 `db.url` 포트도 같은 값으로 맞춘다.)

**B. 로컬에 설치된 MySQL 사용** (A를 했다면 이 블록은 건너뛴다)

```bash
mysql -u root -p -e "CREATE DATABASE db_puppit CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
mysql -u root -p db_puppit < puppit/src/main/resources/SCHEMA.sql
mysql -u root -p db_puppit < docker/mysql/seed-dev.sql
```

여기서 쓰는 계정/비밀번호는 **본인 PC에 이미 설치된 MySQL의 root 비밀번호**다(A의 Docker 계정과 다른, 원래부터 본인만 아는 값).

### 2. 시크릿 파일

```bash
cp puppit/src/main/resources/application-secret.properties \
   puppit/src/main/resources/application-secret.local.properties
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
