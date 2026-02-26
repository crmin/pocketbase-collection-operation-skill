#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME=$(basename "$0")
DEFAULT_CODEX_GLOBAL="${CODEX_HOME:-$HOME/.codex}/skills/pocketbase-collection-operation"
DEFAULT_CODEX_PROJECT="$PWD/.codex/skills/pocketbase-collection-operation"

LANG_CHOICE="en"
AGENT=""
SCOPE=""
TARGET_DIR=""
CONFLICT_ACTION=""

usage() {
  cat <<'USAGE'
Usage: install.sh [options]

Install pocketbase-collection-operation SKILL.md.

Options:
  --help                              Show this help message and exit.
  --lang <en|ko>                      Prompt/output language. Default: en.
  --agent <codex|claude-code|open-code|custom>
                                      Agent type.
  --scope <global|project>            Installation scope.
  --target-dir <absolute-path>        Absolute path to target skill directory.
  --conflict-action <overwrite|keep>  Action when conflict exists.

Examples:
  install.sh --lang ko
  install.sh --agent codex --lang en --scope global --target-dir /abs/path --conflict-action overwrite
USAGE
}

is_absolute_path() {
  [[ "$1" == /* ]]
}

show_error_and_exit() {
  local message="$1"
  if [[ "$LANG_CHOICE" == "ko" ]]; then
    echo "오류: $message" >&2
    echo "사용법은 --help를 확인하세요." >&2
  else
    echo "Error: $message" >&2
    echo "Run with --help to see valid options." >&2
  fi
  exit 1
}

msg() {
  local key="$1"
  shift || true

  if [[ "$LANG_CHOICE" == "ko" ]]; then
    case "$key" in
      prompt_agent) printf '에이전트를 선택하세요 [codex/claude-code/open-code/custom]: ' ;;
      prompt_scope) printf '설치 범위를 선택하세요 [global/project]: ' ;;
      prompt_target_codex) printf '대상 절대경로를 입력하세요(기본값: %s): ' "$1" ;;
      prompt_target_custom) printf '대상 절대경로를 입력하세요: ' ;;
      prompt_conflict) printf '충돌이 감지되었습니다. 동작을 선택하세요 [overwrite/keep]: ' ;;
      path_must_be_absolute) echo '절대경로만 허용됩니다.' ;;
      invalid_agent) echo '유효하지 않은 agent 값입니다. 허용값: codex, claude-code, open-code, custom' ;;
      invalid_scope) echo '유효하지 않은 scope 값입니다. 허용값: global, project' ;;
      invalid_lang) echo '유효하지 않은 lang 값입니다. 허용값: en, ko' ;;
      invalid_conflict_action) echo '유효하지 않은 conflict-action 값입니다. 허용값: overwrite, keep' ;;
      conflict_detected) echo '기존 파일/디렉터리 충돌이 감지되었습니다.' ;;
      keep_existing) echo '기존 SKILL을 유지하고 설치를 건너뜁니다.' ;;
      installing) echo 'SKILL.md를 설치/업데이트합니다...' ;;
      install_success) echo '설치가 완료되었습니다.' ;;
      install_failed) echo '설치 검증에 실패했습니다: TARGET_DIR/SKILL.md 파일이 없습니다.' ;;
      restart_hint) echo '스킬 반영을 위해 에이전트 세션을 재시작/리로드하세요.' ;;
      *) echo "$key" ;;
    esac
  else
    case "$key" in
      prompt_agent) printf 'Choose agent [codex/claude-code/open-code/custom]: ' ;;
      prompt_scope) printf 'Choose install scope [global/project]: ' ;;
      prompt_target_codex) printf 'Enter absolute target directory [default: %s]: ' "$1" ;;
      prompt_target_custom) printf 'Enter absolute target directory: ' ;;
      prompt_conflict) printf 'Conflict detected. Choose action [overwrite/keep]: ' ;;
      path_must_be_absolute) echo 'Only absolute paths are allowed.' ;;
      invalid_agent) echo 'Invalid value for --agent. Allowed: codex, claude-code, open-code, custom' ;;
      invalid_scope) echo 'Invalid value for --scope. Allowed: global, project' ;;
      invalid_lang) echo 'Invalid value for --lang. Allowed: en, ko' ;;
      invalid_conflict_action) echo 'Invalid value for --conflict-action. Allowed: overwrite, keep' ;;
      conflict_detected) echo 'Conflict detected with existing directory/file.' ;;
      keep_existing) echo 'Keeping existing SKILL. Installation skipped.' ;;
      installing) echo 'Installing/updating SKILL.md...' ;;
      install_success) echo 'Installation completed.' ;;
      install_failed) echo 'Installation verification failed: TARGET_DIR/SKILL.md not found.' ;;
      restart_hint) echo 'Restart or reload your agent session to discover the updated skill.' ;;
      *) echo "$key" ;;
    esac
  fi
}

validate_lang() {
  case "$1" in
    en|ko) ;;
    *) show_error_and_exit "$(msg invalid_lang)" ;;
  esac
}

validate_agent() {
  case "$1" in
    codex|claude-code|open-code|custom) ;;
    *) show_error_and_exit "$(msg invalid_agent)" ;;
  esac
}

validate_scope() {
  case "$1" in
    global|project) ;;
    *) show_error_and_exit "$(msg invalid_scope)" ;;
  esac
}

validate_conflict_action() {
  case "$1" in
    overwrite|keep) ;;
    *) show_error_and_exit "$(msg invalid_conflict_action)" ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    --lang)
      [[ $# -ge 2 ]] || show_error_and_exit "Missing value for --lang"
      LANG_CHOICE="$2"
      shift 2
      ;;
    --agent)
      [[ $# -ge 2 ]] || show_error_and_exit "Missing value for --agent"
      AGENT="$2"
      shift 2
      ;;
    --scope)
      [[ $# -ge 2 ]] || show_error_and_exit "Missing value for --scope"
      SCOPE="$2"
      shift 2
      ;;
    --target-dir)
      [[ $# -ge 2 ]] || show_error_and_exit "Missing value for --target-dir"
      TARGET_DIR="$2"
      shift 2
      ;;
    --conflict-action)
      [[ $# -ge 2 ]] || show_error_and_exit "Missing value for --conflict-action"
      CONFLICT_ACTION="$2"
      shift 2
      ;;
    *)
      show_error_and_exit "Unknown option: $1"
      ;;
  esac
done

validate_lang "$LANG_CHOICE"

if [[ -n "$AGENT" ]]; then
  validate_agent "$AGENT"
fi
if [[ -n "$SCOPE" ]]; then
  validate_scope "$SCOPE"
fi
if [[ -n "$CONFLICT_ACTION" ]]; then
  validate_conflict_action "$CONFLICT_ACTION"
fi

while [[ -z "$AGENT" ]]; do
  msg prompt_agent
  read -r AGENT
  validate_agent "$AGENT"
done

while [[ -z "$SCOPE" ]]; do
  msg prompt_scope
  read -r SCOPE
  validate_scope "$SCOPE"
done

if [[ -z "$TARGET_DIR" ]]; then
  if [[ "$AGENT" == "codex" ]]; then
    DEFAULT_TARGET="$DEFAULT_CODEX_GLOBAL"
    if [[ "$SCOPE" == "project" ]]; then
      DEFAULT_TARGET="$DEFAULT_CODEX_PROJECT"
    fi

    while true; do
      msg prompt_target_codex "$DEFAULT_TARGET"
      read -r TARGET_DIR
      if [[ -z "$TARGET_DIR" ]]; then
        TARGET_DIR="$DEFAULT_TARGET"
      fi
      if is_absolute_path "$TARGET_DIR"; then
        break
      fi
      msg path_must_be_absolute
    done
  else
    while true; do
      msg prompt_target_custom
      read -r TARGET_DIR
      if is_absolute_path "$TARGET_DIR"; then
        break
      fi
      msg path_must_be_absolute
    done
  fi
else
  is_absolute_path "$TARGET_DIR" || show_error_and_exit "$(msg path_must_be_absolute)"
fi

SOURCE_URL="https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/en/SKILL.md"
if [[ "$LANG_CHOICE" == "ko" ]]; then
  SOURCE_URL="https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/ko/SKILL.md"
fi

CONFLICT=0
if [[ -d "$TARGET_DIR" ]] && [[ -n "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]]; then
  CONFLICT=1
fi
if [[ -f "$TARGET_DIR/SKILL.md" ]]; then
  CONFLICT=1
fi

if [[ "$CONFLICT" -eq 1 ]]; then
  msg conflict_detected
  while [[ -z "$CONFLICT_ACTION" ]]; do
    msg prompt_conflict
    read -r CONFLICT_ACTION
    validate_conflict_action "$CONFLICT_ACTION"
  done

  if [[ "$CONFLICT_ACTION" == "keep" ]]; then
    msg keep_existing
    exit 0
  fi
fi

msg installing
mkdir -p "$TARGET_DIR"
curl -fsSL "$SOURCE_URL" -o "$TARGET_DIR/SKILL.md"

if [[ -f "$TARGET_DIR/SKILL.md" ]]; then
  msg install_success
  head -n 5 "$TARGET_DIR/SKILL.md"
else
  show_error_and_exit "$(msg install_failed)"
fi

msg restart_hint
