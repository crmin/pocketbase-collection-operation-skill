# pocketbase-collection-operation-skill

[English](README.md) | [한국어](README.ko.md)

## 개요

이 저장소는 PocketBase Collections Web API를 안전하게 다루기 위한 스킬 문서를 제공합니다.
일반 레코드 CRUD가 아니라 컬렉션 자체(스키마/메타데이터) 작업에 초점을 둡니다.

## 스킬 호출 방법

이 스킬을 명시적으로 호출할 때는 아래 이름을 사용합니다.
- `$pocketbase-collection-operation`

자연어로도 호출할 수 있습니다. 예시:
- "`pocketbase-collection-operation` 스킬을 사용해서 PocketBase 컬렉션 목록을 조회해줘."

## PocketBase API 환경변수

이 스킬이 기본으로 기대하는 환경변수 이름:
- `PB_URL`: PocketBase base URL (예: `http://127.0.0.1:8090`)
- `PB_ADMIN_EMAIL`: superuser 이메일
- `PB_ADMIN_PASSWORD`: superuser 비밀번호

스킬 입력 우선순위:
1. 사용자가 명시적으로 제공한 값 또는 변수명
2. 위 기본 환경변수
3. 둘 다 없으면 사용자에게 입력 요청

다른 환경변수 이름을 쓰고 싶다면:
1. 실행 전에 기본 변수명으로 매핑
```bash
export MY_PB_URL="http://127.0.0.1:8090"
export MY_PB_EMAIL="admin@example.com"
export MY_PB_PASSWORD="your-password"

export PB_URL="$MY_PB_URL"
export PB_ADMIN_EMAIL="$MY_PB_EMAIL"
export PB_ADMIN_PASSWORD="$MY_PB_PASSWORD"
```
2. 또는 에이전트 요청 시 커스텀 변수명/값을 명시 전달해서 해당 값을 우선 사용하도록 지정

## 스킬 범위

다음 컬렉션 작업 절차를 다룹니다.
- 컬렉션 목록 조회
- 단일 컬렉션 조회
- 컬렉션 생성
- 컬렉션 수정
- 컬렉션 삭제
- 컬렉션 truncate
- 컬렉션 일괄 import
- 스캐폴드 조회

## 안전 가드레일

스킬은 파괴적 작업에 대해 명시적 재확인을 권장합니다.
- `DELETE /api/collections/{collectionIdOrName}`
- `DELETE /api/collections/{collectionIdOrName}/truncate`
- `PUT /api/collections/import` with `deleteMissing=true`

또한 superuser 인증 요구사항과 요청 헤더 형식(`Authorization: <token>`)을 명확히 안내합니다.

## 저장소 구조

```text
.
├── ko/
│   └── SKILL.md
├── en/
│   └── SKILL.md
├── install.md
├── uninstall.md
├── README.md
└── README.ko.md
```

## 설치 방법

### For Agent

아래 codeblock을 복사해서 agent에게 전달하세요.

```markdown
Follow the instructions located at:
https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/install.md
```

### For Human

수동 설치가 필요할 때 아래 절차를 사용합니다.

터미널에서 `scripts/install.sh`를 실행하거나 아래 수동 절차를 직접 수행합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/scripts/install.sh | bash -s -- --lang ko
```

1. 언어 선택
- 영어 스킬 원본: `https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/en/SKILL.md`
- 한국어 스킬 원본: `https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/ko/SKILL.md`

2. 사용 중인 에이전트와 설치 범위(`global` 또는 `project`) 선택
- Codex
- Claude Code
- OpenCode
- 커스텀 에이전트/도구

3. 대상 스킬 디렉터리 확정
- Codex global 기본 경로: `${CODEX_HOME:-$HOME/.codex}/skills/pocketbase-collection-operation`
- Codex project 설치 후보 경로: `<PROJECT_ROOT>/.codex/skills/pocketbase-collection-operation`
- Claude Code는 공식 문서 기준으로 global/project 경로를 먼저 확인한 뒤 설치합니다.
  - 문서: [https://code.claude.com/docs/ko/skills](https://code.claude.com/docs/ko/skills)
- OpenCode는 공식 문서 기준으로 global/project 경로를 먼저 확인한 뒤 설치합니다.
  - 문서: [https://opencode.ai/docs/skills/](https://opencode.ai/docs/skills/)
- 환경이 다르면 사용자 지정 절대경로를 사용합니다.

4. 설치 전 충돌 검사 후 처리 옵션 선택
- 충돌 조건:
  - 대상 디렉터리가 이미 존재하고 비어있지 않음, 또는
  - `TARGET_DIR/SKILL.md`가 이미 존재
- 사용자 선택지:
  - `Overwrite (Update)`: `TARGET_DIR/SKILL.md`만 덮어쓰기
  - `Keep Existing SKILL`: 설치 건너뛰고 기존 파일 유지

5. `SKILL.md` 다운로드 및 배치

```bash
SOURCE_URL="https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/en/SKILL.md"  # 또는 ko/SKILL.md
TARGET_DIR="/absolute/path/to/skills/pocketbase-collection-operation"

mkdir -p "$TARGET_DIR"
curl -fsSL "$SOURCE_URL" -o "$TARGET_DIR/SKILL.md"
```

6. 설치 확인

```bash
test -f "$TARGET_DIR/SKILL.md" && echo "Installed"
head -n 5 "$TARGET_DIR/SKILL.md"
```

7. 스킬 인식 반영을 위해 에이전트 세션을 재시작/리로드합니다.

## 제거 방법

### For Agent

아래 codeblock을 복사해서 agent에게 전달하세요.

```markdown
Follow the instructions located at:
https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/uninstall.md
```

### For Human

1. 사용 중인 에이전트와 제거 범위(`global` 또는 `project`)를 확인합니다.
2. 설치된 스킬 디렉터리(`TARGET_DIR`)를 확인합니다.
3. `TARGET_DIR/SKILL.md`를 삭제합니다.
4. 디렉터리가 비었고 정리하고 싶다면 디렉터리도 삭제합니다.

```bash
TARGET_DIR="/absolute/path/to/skills/pocketbase-collection-operation"

rm -f "$TARGET_DIR/SKILL.md"
# 선택 정리
rmdir "$TARGET_DIR" 2>/dev/null || true
```

5. 제거 확인

```bash
test ! -f "$TARGET_DIR/SKILL.md" && echo "Uninstalled"
```

6. 에이전트 세션을 재시작/리로드합니다.
