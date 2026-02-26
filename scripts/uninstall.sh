#!/usr/bin/env bash
set -euo pipefail

DEFAULT_CODEX_GLOBAL="${CODEX_HOME:-$HOME/.codex}/skills/pocketbase-collection-operation"
DEFAULT_CODEX_PROJECT="$PWD/.codex/skills/pocketbase-collection-operation"

LANG_CHOICE="en"
AGENT=""
SCOPE=""
TARGET_DIR=""
CLEANUP=""

usage() {
  cat <<'USAGE'
Usage: uninstall.sh [options]

Uninstall pocketbase-collection-operation SKILL.md.

Options:
  --help                                 Show this help message and exit.
  --lang <en|ko>                         Prompt/output language. Default: en.
  --agent <codex|claude-code|open-code|custom>
                                         Agent type.
  --scope <global|project>               Uninstallation scope.
  --target-dir <absolute-path>           Absolute path to target skill directory.
  --cleanup <true|false>                 Remove target directory if empty.

Examples:
  uninstall.sh --lang ko
  uninstall.sh --agent codex --lang en --scope global --target-dir /abs/path --cleanup true
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
      prompt_scope) printf '제거 범위를 선택하세요 [global/project]: ' ;;
      prompt_target_codex) printf '대상 절대경로를 입력하세요(기본값: %s): ' "$1" ;;
      prompt_target_custom) printf '대상 절대경로를 입력하세요: ' ;;
      prompt_cleanup) printf '비어 있는 대상 디렉터리를 정리할까요? [true/false]: ' ;;
      path_must_be_absolute) echo '절대경로만 허용됩니다.' ;;
      invalid_agent) echo '유효하지 않은 agent 값입니다. 허용값: codex, claude-code, open-code, custom' ;;
      invalid_scope) echo '유효하지 않은 scope 값입니다. 허용값: global, project' ;;
      invalid_lang) echo '유효하지 않은 lang 값입니다. 허용값: en, ko' ;;
      invalid_cleanup) echo '유효하지 않은 cleanup 값입니다. 허용값: true, false' ;;
      uninstalling) echo 'SKILL.md를 제거합니다...' ;;
      cleanup_try) echo '대상 디렉터리가 비어 있으면 정리합니다...' ;;
      uninstall_success) echo '제거가 완료되었습니다.' ;;
      uninstall_failed) echo '제거 검증에 실패했습니다: TARGET_DIR/SKILL.md 파일이 남아 있습니다.' ;;
      restart_hint) echo '스킬 반영을 위해 에이전트 세션을 재시작/리로드하세요.' ;;
      *) echo "$key" ;;
    esac
  else
    case "$key" in
      prompt_agent) printf 'Choose agent [codex/claude-code/open-code/custom]: ' ;;
      prompt_scope) printf 'Choose uninstall scope [global/project]: ' ;;
      prompt_target_codex) printf 'Enter absolute target directory [default: %s]: ' "$1" ;;
      prompt_target_custom) printf 'Enter absolute target directory: ' ;;
      prompt_cleanup) printf 'Cleanup empty target directory? [true/false]: ' ;;
      path_must_be_absolute) echo 'Only absolute paths are allowed.' ;;
      invalid_agent) echo 'Invalid value for --agent. Allowed: codex, claude-code, open-code, custom' ;;
      invalid_scope) echo 'Invalid value for --scope. Allowed: global, project' ;;
      invalid_lang) echo 'Invalid value for --lang. Allowed: en, ko' ;;
      invalid_cleanup) echo 'Invalid value for --cleanup. Allowed: true, false' ;;
      uninstalling) echo 'Removing SKILL.md...' ;;
      cleanup_try) echo 'Cleaning up target directory if it is empty...' ;;
      uninstall_success) echo 'Uninstallation completed.' ;;
      uninstall_failed) echo 'Uninstallation verification failed: TARGET_DIR/SKILL.md still exists.' ;;
      restart_hint) echo 'Restart or reload your agent session to reflect skill removal.' ;;
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

validate_cleanup() {
  case "$1" in
    true|false) ;;
    *) show_error_and_exit "$(msg invalid_cleanup)" ;;
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
    --cleanup)
      [[ $# -ge 2 ]] || show_error_and_exit "Missing value for --cleanup"
      CLEANUP="$2"
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
if [[ -n "$CLEANUP" ]]; then
  validate_cleanup "$CLEANUP"
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

while [[ -z "$CLEANUP" ]]; do
  msg prompt_cleanup
  read -r CLEANUP
  validate_cleanup "$CLEANUP"
done

msg uninstalling
rm -f "$TARGET_DIR/SKILL.md"

if [[ "$CLEANUP" == "true" ]]; then
  msg cleanup_try
  rmdir "$TARGET_DIR" 2>/dev/null || true
fi

if [[ ! -f "$TARGET_DIR/SKILL.md" ]]; then
  msg uninstall_success
else
  show_error_and_exit "$(msg uninstall_failed)"
fi

msg restart_hint
