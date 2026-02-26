---
name: pocketbase-collection-operation
description: PocketBase Web API로 컬렉션(list/view/create/update/delete/truncate/import/scaffolds)을 안전하게 조회·수정·삭제한다
---

# PocketBase Collections Web API

PocketBase의 **Collections(Web API)** 엔드포인트를 사용해 컬렉션을 **조회/생성/수정/삭제/비우기/일괄 가져오기/스캐폴드 조회**한다.

## 언제 사용하나요?

- PocketBase의 **컬렉션(스키마)** 자체를 코드/스크립트로 관리해야 할 때
- CI/CD, 마이그레이션, 개발 환경 초기화에서 **컬렉션 구성 자동화**가 필요할 때
- Dashboard UI가 아닌 **HTTP API 호출로 컬렉션 조작**이 필요할 때


## 공통 제약/필요 조건

### 1) 연결 정보(필수)
다음 값이 필요하다.

- `PB_URL`: PocketBase 서버의 base URL  
  예: `http://127.0.0.1:8090` 또는 `https://pb.example.com`
- `PB_ADMIN_EMAIL`: superuser 이메일
- `PB_ADMIN_PASSWORD`: superuser 비밀번호

#### 입력 우선순위
1. 사용자가 명시적으로 제공한 값/환경변수 이름
2. 기본 환경변수(`PB_URL`, `PB_ADMIN_EMAIL`, `PB_ADMIN_PASSWORD`)
3. 둘 다 없으면: 아래 **환경변수 목록**과 **설정 방법**을 사용자에게 안내하고, 값이 준비되면 다시 진행한다.

#### 환경변수 설정 예시
```bash
export PB_URL="http://127.0.0.1:8090"
export PB_ADMIN_EMAIL="admin@example.com"
export PB_ADMIN_PASSWORD="your-password"
```


### 2) 인증(필수)

Collections API는 superuser 토큰이 필요하다.
토큰 발급은 _superusers auth 컬렉션의 auth-with-password를 사용한다.

#### 토큰 발급
- POST `${PB_URL}/api/collections/_superusers/auth-with-password`
- Body(JSON):
  ```json
  {
    "identity": "admin@example.com",
    "password": "your-password"
  }
  ```
- Response(JSON):
  ```json
  {
    "token": "JWT_TOKEN_STRING",
    "record": { "...": "..." }
  }
  ```

#### 이후 모든 요청 헤더
- `Authorization: <token>`
- `Content-Type: application/json` (JSON 바디를 보낼 때)

PocketBase는 `Authorization: Bearer <token>` 형태가 아니라, `Authorization: <token>` 형태를 사용한다.

토큰 발급 bash 예시 (jq 사용)
```bash
PB_TOKEN="$(
  curl -sS -X POST "${PB_URL}/api/collections/_superusers/auth-with-password" \
    -H "Content-Type: application/json" \
    -d "{\"identity\":\"${PB_ADMIN_EMAIL}\",\"password\":\"${PB_ADMIN_PASSWORD}\"}" \
  | jq -r .token
)"
```

jq가 없다면 (python 사용)
```bash
PB_TOKEN="$(
  curl -sS -X POST "${PB_URL}/api/collections/_superusers/auth-with-password" \
    -H "Content-Type: application/json" \
    -d "{\"identity\":\"${PB_ADMIN_EMAIL}\",\"password\":\"${PB_ADMIN_PASSWORD}\"}" \
  | python -c 'import sys,json; print(json.load(sys.stdin)["token"])'
)"
```

### 3) 공통 요청 규칙
- Base path는 항상 `${PB_URL}/api/...`
- 일부 엔드포인트는 request body를 `multipart/form-data`로도 보낼 수 있으나, 기본은 JSON을 사용한다.
- `collectionIdOrName`에는 컬렉션 ID 또는 name을 넣을 수 있다.
- 401이 나오면 토큰이 누락/만료/오류일 수 있으니 재인증 후 재시도한다.
- 403이 나오면 superuser가 아니거나 권한이 없다(대부분 collections 조작은 superuser 전용).


### 4) 파괴적 작업 가드레일(권장)

아래 작업은 되돌리기 어렵다. 사용자가 명시적으로 요청한 경우에만 실행한다.
- `DELETE /api/collections/{collectionIdOrName}` (컬렉션 삭제)
- `DELETE /api/collections/{collectionIdOrName}/truncate` (레코드 전체 삭제)
- `PUT /api/collections/import 중 deleteMissing=true` (누락된 컬렉션/필드/데이터 삭제 가능)

## API 레퍼런스: Collections

아래 모든 요청은 기본적으로 다음 헤더를 사용한다.
```
Authorization: <PB_TOKEN>
Content-Type: application/json
```

### A) List collections
- `GET /api/collections`
- Query:
  - `page` (number, default 1)
  - `perPage` (number, default 30)
  - `sort` (string, 예: `-created,id`)
  - `filter` (string, 예: (`name~'abc' && created>'2022-01-01'`))
  - `fields` (string, 반환 필드 선택)
  - `skipTotal` (boolean, total 계산 생략)
- Response 200(JSON): `PageResult<Collection>`
  ```json
  {
    "page": 1,
    "perPage": 30,
    "totalItems": 123,
    "totalPages": 5,
    "items": [ { "id": "...", "name": "...", "type": "...", "fields": [ ... ] } ]
  }
  ```
- curl 예시
  ```bash
  curl -sS "${PB_URL}/api/collections?page=1&perPage=50&sort=-created" \
    -H "Authorization: ${PB_TOKEN}"
  ```

### B) View collection
- `GET /api/collections/{collectionIdOrName}`
- Query:
  - fields (string)
- Response 200(JSON): `Collection`
  ```json
  {
    "id": "COLLECTION_ID",
    "name": "posts",
    "type": "base",
    "system": false,
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "fields": [ { "name": "title", "type": "text" } ],
    "indexes": []
  }
  ```
- curl 예시
  ```bash
  curl -sS "${PB_URL}/api/collections/posts" \
    -H "Authorization: ${PB_TOKEN}"
  ```

### C) Create collection
- POST `/api/collections`
- Body: `CollectionCreate`

#### CollectionCreate (요약 스키마)
```json
{
  "id": "optional_15_chars",
  "name": "required_unique_name",
  "type": "base | view | auth",             // default: base
  "fields": [ /* Array<Field> */ ],         // view는 viewQuery 기반 자동 채움(보통 생략 가능)
  "indexes": [ "CREATE INDEX ..." ],        // view는 indexes 미지원
  "system": false,

  "listRule": null,
  "viewRule": null,
  "createRule": null,
  "updateRule": null,
  "deleteRule": null,

  // type=view 일 때 필수
  "viewQuery": "SELECT ...",

  // type=auth 일 때 주로 사용
  "manageRule": null,
  "authRule": null,
  "authAlert": { "enabled": true, "emailTemplate": { "subject": "...", "body": "..." } },
  "oauth2": { "enabled": false, "providers": [], "mappedFields": { "id": "", "name": "", "username": "", "avatarURL": "" } },
  "passwordAuth": { "enabled": true, "identityFields": ["email"] },
  "mfa": { "enabled": false, "duration": 1800, "rule": "" },
  "otp": { "enabled": false, "duration": 180, "length": 8, "emailTemplate": { "subject": "...", "body": "..." } }
}
```
- Response 200(JSON): `Collection`

#### curl 예시 (base)
```bash
curl -sS -X POST "${PB_URL}/api/collections" \
  -H "Authorization: ${PB_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "exampleBase",
    "type": "base",
    "fields": [
      { "name": "title", "type": "text", "required": true, "min": 1 },
      { "name": "status", "type": "bool" }
    ]
  }'
```

#### curl 예시 (view)
```bash
curl -sS -X POST "${PB_URL}/api/collections" \
  -H "Authorization: ${PB_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "exampleView",
    "type": "view",
    "listRule": "@request.auth.id != \"\"",
    "viewRule": null,
    "viewQuery": "SELECT id, name FROM posts"
  }'
```

#### curl 예시 (auth)
```json
curl -sS -X POST "${PB_URL}/api/collections" \
  -H "Authorization: ${PB_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "exampleAuth",
    "type": "auth",
    "createRule": "id = @request.auth.id",
    "updateRule": "id = @request.auth.id",
    "deleteRule": "id = @request.auth.id",
    "fields": [
      { "name": "name", "type": "text" }
    ],
    "passwordAuth": { "enabled": true, "identityFields": ["email"] }
  }'
```


### D) Update collection
- `PATCH /api/collections/{collectionIdOrName}`
- Body: `CollectionUpdate` (부분 업데이트)

#### CollectionUpdate (요약)
```json
{
  "name": "required",
  "fields": [ /* Array<Field> */ ],
  "indexes": [ "CREATE INDEX ..." ],
  "system": false,

  "listRule": null,
  "viewRule": null,
  "createRule": null,
  "updateRule": null,
  "deleteRule": null,

  "viewQuery": "SELECT ...",

  "manageRule": null,
  "authRule": null,
  "authAlert": { "enabled": true, "emailTemplate": { "subject": "...", "body": "..." } },
  "oauth2": { "enabled": false, "providers": [], "mappedFields": { "id": "", "name": "", "username": "", "avatarURL": "" } },
  "passwordAuth": { "enabled": true, "identityFields": ["email"] },
  "mfa": { "enabled": false, "duration": 1800, "rule": "" },
  "otp": { "enabled": false, "duration": 180, "length": 8, "emailTemplate": { "subject": "...", "body": "..." } }
}
```
- Response 200(JSON): `Collection`
- curl 예시
  ```bash
  curl -sS -X PATCH "${PB_URL}/api/collections/demo" \
    -H "Authorization: ${PB_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "new_demo",
      "listRule": "created > \"2022-01-01 00:00:00\""
    }'
  ```

### E) Delete collection
- `DELETE /api/collections/{collectionIdOrName}`
- Response 204: `null`
- curl 예시
  ```bash
  curl -sS -X DELETE "${PB_URL}/api/collections/demo" \
    -H "Authorization: ${PB_TOKEN}" \
    -o /dev/null -w "%{http_code}\n"
  ```


### F) Truncate collection (records 전체 삭제)
- `DELETE /api/collections/{collectionIdOrName}/truncate`
- Response 204: `null`
- curl 예시
  ```bash
  curl -sS -X DELETE "${PB_URL}/api/collections/demo/truncate" \
    -H "Authorization: ${PB_TOKEN}" \
    -o /dev/null -w "%{http_code}\n"
  ```


### G) Import collections (bulk)
- `PUT /api/collections/import`
- Body(JSON):
  ```json
  {
    "collections": [ /* Array<Collection> */ ],
    "deleteMissing": false
  }
  ```
- Response 204: `null`

> `deleteMissing=true`는 "import에 없는 기존 컬렉션/필드"를 삭제할 수 있고, 관련 레코드 데이터도 삭제될 수 있으니 주의.

- curl 예시
  ```bash
  curl -sS -X PUT "${PB_URL}/api/collections/import" \
    -H "Authorization: ${PB_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "collections": [
        {
          "name": "collection1",
          "type": "base",
          "fields": [ { "name": "status", "type": "bool" } ]
        },
        {
          "name": "collection2",
          "type": "base",
          "fields": [ { "name": "title", "type": "text" } ]
        }
      ],
      "deleteMissing": false
    }' \
    -o /dev/null -w "%{http_code}\n"
  ```


### H) Scaffolds (기본 컬렉션 템플릿 조회)
- `GET /api/collections/meta/scaffolds`
- Response 200(JSON): `Scaffolds`
  ```json
  {
    "auth": { "type": "auth", "fields": [ /* default fields */ ], "...": "..." },
    "base": { "type": "base", "fields": [ /* default fields */ ], "...": "..." },
    "view": { "type": "view", "fields": [ /* empty by default */ ], "viewQuery": "" }
  }
  ```
- curl 예시
  ```bash
  curl -sS "${PB_URL}/api/collections/meta/scaffolds" \
    -H "Authorization: ${PB_TOKEN}"
  ```


## 권장 실행 순서(워크플로우)
1.	입력 확인: `PB_URL`, `PB_ADMIN_EMAIL`, `PB_ADMIN_PASSWORD` 확보
2.	토큰 발급: `_superusers/auth-with-password`로 `PB_TOKEN` 획득
3.	안전한 조회로 시작:
  - List collections → View collection
4.	변경 작업:
  - Create 또는 Update
5.	파괴적 작업은 사용자 요청을 재확인 후 실행:
  - Delete / Truncate / Import(`deleteMissing=true`)


## 빠른 점검 체크리스트
- `PB_URL`에 `/api`를 중복으로 붙이지 않았나? (base는 host까지만)
- `Authorization: <token>` 헤더 형식이 맞나?
- superuser로 로그인했나? (일반 auth record 토큰으로는 collections 조작이 막힐 수 있음)
- import에서 `deleteMissing=true`를 의도했나?
- truncate/delete는 정말 필요한가?

## 참고
[oai_citation:0‡pocketbase.io](https://pocketbase.io/docs/api-collections/)