---
name: pocketbase-collection-operation
description: Safely manage PocketBase collections (list/view/create/update/delete/truncate/import/scaffolds) through the Web API
---

# PocketBase Collections Web API

Use PocketBase **Collections (Web API)** endpoints to **list/create/update/delete/truncate/bulk import/get scaffolds** for collections.

## When should you use this?

- When you need to manage PocketBase **collections (schema)** through code/scripts
- When you need **automated collection setup** in CI/CD, migration, or development environment initialization
- When you need to operate collections through **HTTP API calls** instead of the Dashboard UI

## Common constraints and prerequisites

### 1) Connection info (required)
You need the following values.

- `PB_URL`: base URL of the PocketBase server  
  Example: `http://127.0.0.1:8090` or `https://pb.example.com`
- `PB_ADMIN_EMAIL`: superuser email
- `PB_ADMIN_PASSWORD`: superuser password

#### Input priority
1. Values or env var names explicitly provided by the user
2. Default env vars (`PB_URL`, `PB_ADMIN_EMAIL`, `PB_ADMIN_PASSWORD`)
3. If neither is available: explain the **env var list** and **setup method** below, then continue once values are ready.

#### Example env var setup
```bash
export PB_URL="http://127.0.0.1:8090"
export PB_ADMIN_EMAIL="admin@example.com"
export PB_ADMIN_PASSWORD="your-password"
```

### 2) Authentication (required)

The Collections API requires a superuser token.  
Issue the token with `auth-with-password` from the `_superusers` auth collection.

#### Issue token
- POST `${PB_URL}/api/collections/_superusers/auth-with-password`
- Body (JSON):
  ```json
  {
    "identity": "admin@example.com",
    "password": "your-password"
  }
  ```
- Response (JSON):
  ```json
  {
    "token": "JWT_TOKEN_STRING",
    "record": { "...": "..." }
  }
  ```

#### Headers for all subsequent requests
- `Authorization: <token>`
- `Content-Type: application/json` (when sending a JSON body)

PocketBase uses `Authorization: <token>`, not `Authorization: Bearer <token>`.

Token issuance bash example (with `jq`)
```bash
PB_TOKEN="$(
  curl -sS -X POST "${PB_URL}/api/collections/_superusers/auth-with-password" \
    -H "Content-Type: application/json" \
    -d "{\"identity\":\"${PB_ADMIN_EMAIL}\",\"password\":\"${PB_ADMIN_PASSWORD}\"}" \
  | jq -r .token
)"
```

If `jq` is unavailable (use Python)
```bash
PB_TOKEN="$(
  curl -sS -X POST "${PB_URL}/api/collections/_superusers/auth-with-password" \
    -H "Content-Type: application/json" \
    -d "{\"identity\":\"${PB_ADMIN_EMAIL}\",\"password\":\"${PB_ADMIN_PASSWORD}\"}" \
  | python -c 'import sys,json; print(json.load(sys.stdin)["token"])'
)"
```

### 3) Common request rules
- Base path is always `${PB_URL}/api/...`
- Some endpoints also support `multipart/form-data`, but JSON is the default.
- `collectionIdOrName` accepts either collection ID or collection name.
- If you get 401, token may be missing/expired/invalid. Re-authenticate and retry.
- If you get 403, caller is not a superuser or lacks permission (most collection operations are superuser-only).

### 4) Guardrails for destructive actions (recommended)

The following actions are hard to undo. Run only when the user explicitly requests them.
- `DELETE /api/collections/{collectionIdOrName}` (delete collection)
- `DELETE /api/collections/{collectionIdOrName}/truncate` (delete all records)
- `PUT /api/collections/import` with `deleteMissing=true` (can delete missing collections/fields/data)

## API reference: Collections

Use the following headers for all requests by default.
```
Authorization: <PB_TOKEN>
Content-Type: application/json
```

### A) List collections
- `GET /api/collections`
- Query:
  - `page` (number, default 1)
  - `perPage` (number, default 30)
  - `sort` (string, e.g. `-created,id`)
  - `filter` (string, e.g. (`name~'abc' && created>'2022-01-01'`))
  - `fields` (string, select returned fields)
  - `skipTotal` (boolean, skip total count)
- Response 200 (JSON): `PageResult<Collection>`
  ```json
  {
    "page": 1,
    "perPage": 30,
    "totalItems": 123,
    "totalPages": 5,
    "items": [ { "id": "...", "name": "...", "type": "...", "fields": [ ... ] } ]
  }
  ```
- curl example
  ```bash
  curl -sS "${PB_URL}/api/collections?page=1&perPage=50&sort=-created" \
    -H "Authorization: ${PB_TOKEN}"
  ```

### B) View collection
- `GET /api/collections/{collectionIdOrName}`
- Query:
  - `fields` (string)
- Response 200 (JSON): `Collection`
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
- curl example
  ```bash
  curl -sS "${PB_URL}/api/collections/posts" \
    -H "Authorization: ${PB_TOKEN}"
  ```

### C) Create collection
- POST `/api/collections`
- Body: `CollectionCreate`

#### CollectionCreate (summary schema)
```json
{
  "id": "optional_15_chars",
  "name": "required_unique_name",
  "type": "base | view | auth",             // default: base
  "fields": [ /* Array<Field> */ ],           // for view, auto-filled from viewQuery (usually optional)
  "indexes": [ "CREATE INDEX ..." ],         // view does not support indexes
  "system": false,

  "listRule": null,
  "viewRule": null,
  "createRule": null,
  "updateRule": null,
  "deleteRule": null,

  // required when type=view
  "viewQuery": "SELECT ...",

  // mainly used when type=auth
  "manageRule": null,
  "authRule": null,
  "authAlert": { "enabled": true, "emailTemplate": { "subject": "...", "body": "..." } },
  "oauth2": { "enabled": false, "providers": [], "mappedFields": { "id": "", "name": "", "username": "", "avatarURL": "" } },
  "passwordAuth": { "enabled": true, "identityFields": ["email"] },
  "mfa": { "enabled": false, "duration": 1800, "rule": "" },
  "otp": { "enabled": false, "duration": 180, "length": 8, "emailTemplate": { "subject": "...", "body": "..." } }
}
```
- Response 200 (JSON): `Collection`

#### curl example (base)
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

#### curl example (view)
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

#### curl example (auth)
```bash
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
- Body: `CollectionUpdate` (partial update)

#### CollectionUpdate (summary)
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
- Response 200 (JSON): `Collection`
- curl example
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
- curl example
  ```bash
  curl -sS -X DELETE "${PB_URL}/api/collections/demo" \
    -H "Authorization: ${PB_TOKEN}" \
    -o /dev/null -w "%{http_code}\n"
  ```

### F) Truncate collection (delete all records)
- `DELETE /api/collections/{collectionIdOrName}/truncate`
- Response 204: `null`
- curl example
  ```bash
  curl -sS -X DELETE "${PB_URL}/api/collections/demo/truncate" \
    -H "Authorization: ${PB_TOKEN}" \
    -o /dev/null -w "%{http_code}\n"
  ```

### G) Import collections (bulk)
- `PUT /api/collections/import`
- Body (JSON):
  ```json
  {
    "collections": [ /* Array<Collection> */ ],
    "deleteMissing": false
  }
  ```
- Response 204: `null`

> `deleteMissing=true` can delete existing collections/fields that are not present in the import payload, and can remove related record data.

- curl example
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

### H) Scaffolds (get default collection templates)
- `GET /api/collections/meta/scaffolds`
- Response 200 (JSON): `Scaffolds`
  ```json
  {
    "auth": { "type": "auth", "fields": [ /* default fields */ ], "...": "..." },
    "base": { "type": "base", "fields": [ /* default fields */ ], "...": "..." },
    "view": { "type": "view", "fields": [ /* empty by default */ ], "viewQuery": "" }
  }
  ```
- curl example
  ```bash
  curl -sS "${PB_URL}/api/collections/meta/scaffolds" \
    -H "Authorization: ${PB_TOKEN}"
  ```

## Recommended execution order (workflow)
1. Validate inputs: secure `PB_URL`, `PB_ADMIN_EMAIL`, `PB_ADMIN_PASSWORD`
2. Issue token: acquire `PB_TOKEN` through `_superusers/auth-with-password`
3. Start with safe reads:
  - List collections -> View collection
4. Apply changes:
  - Create or Update
5. Reconfirm user intent before destructive actions:
  - Delete / Truncate / Import (`deleteMissing=true`)

## Quick checklist
- Did you avoid duplicating `/api` in `PB_URL`? (base should be host only)
- Is `Authorization: <token>` header format correct?
- Did you log in as superuser? (regular auth record tokens may be blocked for collection operations)
- Did you intentionally set `deleteMissing=true` for import?
- Are truncate/delete actions truly necessary?

## Reference
[PocketBase Collections API](https://pocketbase.io/docs/api-collections/)
