# Agent Installation Guide

Use this guide when an agent needs to install this skill into the user's skill directory.

## Required Behavior

The agent must ask the user all of the following before installing:
1. Which agent is being used: `codex`, `claude code`, `open code`, or `custom`.
2. Which language to install: `en` or `ko`.
3. Which scope to use: `global` or `project`.
4. The final target skill directory (absolute path).

Do not assume a path if the user cannot confirm it.

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
3. Create directory and download skill file.
4. Verify the resulting file.
5. Tell the user to restart/reload the agent.

### Command Template

```bash
# 1) Set source URL based on language
SOURCE_URL="https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/en/SKILL.md"  # or ko/SKILL.md

# 2) Set target directory from user-confirmed path
TARGET_DIR="/absolute/path/to/skills/pocketbase-collection-operation"

# 3) Install
mkdir -p "$TARGET_DIR"
curl -fsSL "$SOURCE_URL" -o "$TARGET_DIR/SKILL.md"

# 4) Verify
test -f "$TARGET_DIR/SKILL.md" && echo "Installed"
head -n 5 "$TARGET_DIR/SKILL.md"
```

## Validation Checklist

- The file exists at `TARGET_DIR/SKILL.md`.
- Front matter contains `name: pocketbase-collection-operation`.
- Installed language matches user choice (`en` or `ko`).
- User is informed that agent restart/reload may be required.
