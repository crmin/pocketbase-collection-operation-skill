# Agent Installation Guide

Use this guide when an agent needs to install this skill into the user's skill directory.

## Required Behavior

The agent must ask the user all of the following before installing:
1. Which agent is being used: `codex`, `claude code`, `open code`, or `custom`.
2. Which language to install: `en` or `ko`.
3. Which scope to use: `global` or `project`.
4. The final target skill directory (absolute path).

Do not assume a path if the user cannot confirm it.

Before writing files, the agent must check:
- Whether `TARGET_DIR` exists
- Whether `TARGET_DIR` is non-empty
- Whether `TARGET_DIR/SKILL.md` already exists

If either conflict condition is true, the agent must ask the user to choose exactly one option:
- `Overwrite (Update)`
- `Keep Existing SKILL`

Conflict handling rules:
- `Overwrite (Update)`: overwrite only `TARGET_DIR/SKILL.md` with the selected language source. Do not delete other files.
- `Keep Existing SKILL`: skip installation and report that the existing skill was kept.

## Source URLs

- English skill: `https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/en/SKILL.md`
- Korean skill: `https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/ko/SKILL.md`

## Agent-Specific Path Guidance

### Codex
- Global default: `${CODEX_HOME:-$HOME/.codex}/skills/pocketbase-collection-operation`
- Project candidate path: `<PROJECT_ROOT>/.codex/skills/pocketbase-collection-operation`
- If either differs in the user environment, ask for the exact absolute path.

### Claude Code
- Ask whether the user wants global or project installation.
- Ask for the exact path based on the user's setup.
- Reference docs: [https://code.claude.com/docs/ko/skills](https://code.claude.com/docs/ko/skills)

### OpenCode
- Ask whether the user wants global or project installation.
- Ask for the exact path based on the user's setup.
- Reference docs: [https://opencode.ai/docs/skills/](https://opencode.ai/docs/skills/)

### Custom Agent
- Always request the exact destination directory.

## Installation Steps

1. Determine `SOURCE_URL` from language choice.
2. Determine `TARGET_DIR` from user-confirmed path.
3. Detect conflicts (`TARGET_DIR` non-empty or `TARGET_DIR/SKILL.md` exists).
4. If conflict exists, ask user to choose `Overwrite (Update)` or `Keep Existing SKILL`.
5. If user chooses keep, stop and report no changes.
6. If user chooses overwrite, or no conflict exists, install/update `SKILL.md`.
7. Verify the resulting file.
8. Tell the user to restart/reload the agent.

## Command Template (with conflict branch)

```bash
# 1) Set source URL based on language
SOURCE_URL="https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/en/SKILL.md"  # or ko/SKILL.md

# 2) Set target directory from user-confirmed path
TARGET_DIR="/absolute/path/to/skills/pocketbase-collection-operation"

# 3) Detect conflict
CONFLICT=0
if [ -d "$TARGET_DIR" ] && [ -n "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
  CONFLICT=1
fi
if [ -f "$TARGET_DIR/SKILL.md" ]; then
  CONFLICT=1
fi

# 4) If conflict exists, get explicit user choice
# Set ACTION to OVERWRITE or KEEP after asking the user.
ACTION="OVERWRITE"

if [ "$CONFLICT" -eq 1 ] && [ "$ACTION" = "KEEP" ]; then
  echo "Keeping existing SKILL. Installation skipped."
  exit 0
fi

# 5) Install or update (SKILL.md only)
mkdir -p "$TARGET_DIR"
curl -fsSL "$SOURCE_URL" -o "$TARGET_DIR/SKILL.md"

# 6) Verify
test -f "$TARGET_DIR/SKILL.md" && echo "Installed"
head -n 5 "$TARGET_DIR/SKILL.md"
```

## Validation Checklist

- Conflict detection was executed before writing files.
- If conflict existed, the user was offered both options:
  - `Overwrite (Update)`
  - `Keep Existing SKILL`
- `Overwrite (Update)` only replaced `TARGET_DIR/SKILL.md`.
- `Keep Existing SKILL` skipped installation.
- Front matter contains `name: pocketbase-collection-operation`.
- Installed language matches user choice (`en` or `ko`).
- User is informed that agent restart/reload may be required.
