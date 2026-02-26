# Agent Uninstallation Guide

Use this guide when an agent needs to remove this skill from the user's skill directory.

## Required Behavior

The agent must ask the user all of the following before uninstalling:
1. Which agent is being used: `codex`, `claude code`, `open code`, or `custom`.
2. Which scope to uninstall from: `global` or `project`.
3. The final target skill directory (absolute path).

Do not assume a path if the user cannot confirm it.

## Agent-Specific Path Guidance

### Codex
- Global default: `${CODEX_HOME:-$HOME/.codex}/skills/pocketbase-collection-operation`
- Project candidate path: `<PROJECT_ROOT>/.codex/skills/pocketbase-collection-operation`
- If either differs in the user environment, ask for the exact absolute path.

### Claude Code
- Ask whether the user wants global or project uninstall.
- Ask for the exact path based on the user's setup.
- Reference docs: [https://code.claude.com/docs/ko/skills](https://code.claude.com/docs/ko/skills)

### OpenCode
- Ask whether the user wants global or project uninstall.
- Ask for the exact path based on the user's setup.
- Reference docs: [https://opencode.ai/docs/skills/](https://opencode.ai/docs/skills/)

### Custom Agent
- Always request the exact destination directory.

## Uninstallation Steps

1. Determine `TARGET_DIR` from user-confirmed path.
2. Remove `TARGET_DIR/SKILL.md`.
3. Optionally remove `TARGET_DIR` if it is empty and user wants cleanup.
4. Verify that `TARGET_DIR/SKILL.md` does not exist.
5. Tell the user to restart/reload the agent.

## Command Template

```bash
# 1) Set target directory from user-confirmed path
TARGET_DIR="/absolute/path/to/skills/pocketbase-collection-operation"

# 2) Remove skill file
rm -f "$TARGET_DIR/SKILL.md"

# 3) Optional cleanup (remove directory only if empty)
rmdir "$TARGET_DIR" 2>/dev/null || true

# 4) Verify
test ! -f "$TARGET_DIR/SKILL.md" && echo "Uninstalled"
```

## Validation Checklist

- `TARGET_DIR/SKILL.md` no longer exists.
- Optional cleanup removed only empty directories.
- User is informed that agent restart/reload may be required.
