# pocketbase-collection-operation-skill

[English](README.md) | [한국어](README.ko.md)

## 개요

이 저장소는 PocketBase Collections Web API를 안전하게 다루기 위한 스킬 문서를 제공합니다.
일반 레코드 CRUD가 아니라 컬렉션 자체(스키마/메타데이터) 작업에 초점을 둡니다.

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

4. `SKILL.md` 다운로드 및 배치

```bash
SOURCE_URL="https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/en/SKILL.md"  # 또는 ko/SKILL.md
TARGET_DIR="/absolute/path/to/skills/pocketbase-collection-operation"

mkdir -p "$TARGET_DIR"
curl -fsSL "$SOURCE_URL" -o "$TARGET_DIR/SKILL.md"
```

5. 설치 확인

```bash
test -f "$TARGET_DIR/SKILL.md" && echo "Installed"
head -n 5 "$TARGET_DIR/SKILL.md"
```

6. 스킬 인식 반영을 위해 에이전트 세션을 재시작/리로드합니다.
