# pocketbase-collection-operation-skill

[English](README.md) | [한국어](README.ko.md)

## Overview

This repository provides a skill document for safely operating PocketBase collections through the Web API.
It focuses on collection-level operations (schema and collection metadata), not regular record CRUD.

## Skill Invocation

Call this skill explicitly with:
- `$pocketbase-collection-operation`

You can also invoke it with natural language, for example:
- "Use `pocketbase-collection-operation` to list collections in my PocketBase instance."

## Environment Variables For PocketBase API

Default variable names expected by this skill:
- `PB_URL`: PocketBase base URL (example: `http://127.0.0.1:8090`)
- `PB_ADMIN_EMAIL`: superuser email
- `PB_ADMIN_PASSWORD`: superuser password

Input priority used by the skill:
1. Values or variable names explicitly provided by the user
2. Default env vars above
3. If unavailable, ask the user to provide them

If you want to use different variable names:
1. Map custom variables to the defaults before running.
```bash
export MY_PB_URL="http://127.0.0.1:8090"
export MY_PB_EMAIL="admin@example.com"
export MY_PB_PASSWORD="your-password"

export PB_URL="$MY_PB_URL"
export PB_ADMIN_EMAIL="$MY_PB_EMAIL"
export PB_ADMIN_PASSWORD="$MY_PB_PASSWORD"
```
2. Or explicitly provide the values (or custom variable names) in your agent request so the skill uses them first.

## What This Skill Covers

The skill documents how to perform:
- List collections
- View a collection
- Create a collection
- Update a collection
- Delete a collection
- Truncate a collection
- Bulk import collections
- Get collection scaffolds

## Safety Guardrails

The skill emphasizes explicit confirmation for destructive operations:
- `DELETE /api/collections/{collectionIdOrName}`
- `DELETE /api/collections/{collectionIdOrName}/truncate`
- `PUT /api/collections/import` with `deleteMissing=true`

It also clarifies superuser authentication requirements and request header format (`Authorization: <token>`).

## Repository Structure

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

## Installation

### For Agent

Copy the code block below and provide it to the agent:

```markdown
Follow the instructions located at:
https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/install.md
```

### For Human

Use this section when you want to install the skill manually.

1. Choose language
- English skill source: `https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/en/SKILL.md`
- Korean skill source: `https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/ko/SKILL.md`

2. Choose your agent and install scope (`global` or `project`)
- Codex
- Claude Code
- OpenCode
- Custom agent/tooling

3. Resolve the target skill directory
- Codex global default: `${CODEX_HOME:-$HOME/.codex}/skills/pocketbase-collection-operation`
- Codex project default candidate: `<PROJECT_ROOT>/.codex/skills/pocketbase-collection-operation`
- Claude Code: check official docs, then use your selected global/project skills directory.
  - Docs: [https://code.claude.com/docs/ko/skills](https://code.claude.com/docs/ko/skills)
- OpenCode: check official docs, then use your selected global/project skills directory.
  - Docs: [https://opencode.ai/docs/skills/](https://opencode.ai/docs/skills/)
- If your setup differs, use a custom absolute directory.

4. Run pre-install conflict checks and choose action if conflict exists
- Conflict conditions:
  - The target skill directory exists and is not empty, or
  - `TARGET_DIR/SKILL.md` already exists
- Required options:
  - `Overwrite (Update)`: overwrite only `TARGET_DIR/SKILL.md`
  - `Keep Existing SKILL`: skip installation and keep current file

5. Download and place `SKILL.md`

```bash
SOURCE_URL="https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/en/SKILL.md"  # or ko/SKILL.md
TARGET_DIR="/absolute/path/to/skills/pocketbase-collection-operation"

mkdir -p "$TARGET_DIR"
curl -fsSL "$SOURCE_URL" -o "$TARGET_DIR/SKILL.md"
```

6. Verify installation

```bash
test -f "$TARGET_DIR/SKILL.md" && echo "Installed"
head -n 5 "$TARGET_DIR/SKILL.md"
```

7. Restart or reload your agent session so the skill is discovered.

## Uninstallation

### For Agent

Copy the code block below and provide it to the agent:

```markdown
Follow the instructions located at:
https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/uninstall.md
```

### For Human

1. Choose your agent and uninstall scope (`global` or `project`).
2. Resolve the installed skill directory (`TARGET_DIR`).
3. Remove `TARGET_DIR/SKILL.md`.
4. If the directory becomes empty and you want cleanup, remove the directory too.

```bash
TARGET_DIR="/absolute/path/to/skills/pocketbase-collection-operation"

rm -f "$TARGET_DIR/SKILL.md"
# Optional cleanup
rmdir "$TARGET_DIR" 2>/dev/null || true
```

5. Verify removal.

```bash
test ! -f "$TARGET_DIR/SKILL.md" && echo "Uninstalled"
```

6. Restart or reload your agent session.
