# pocketbase-collection-operation-skill

[English](README.md) | [한국어](README.ko.md)

## Overview

This repository provides a skill document for safely operating PocketBase collections through the Web API.
It focuses on collection-level operations (schema and collection metadata), not regular record CRUD.

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
- Codex global default: `${CODEX_HOME:-$HOME/.codex}/skills/pocketbase-collection-operations`
- Codex project default candidate: `<PROJECT_ROOT>/.codex/skills/pocketbase-collection-operations`
- Claude Code: check official docs, then use your selected global/project skills directory.
  - Docs: [https://code.claude.com/docs/ko/skills](https://code.claude.com/docs/ko/skills)
- OpenCode: check official docs, then use your selected global/project skills directory.
  - Docs: [https://opencode.ai/docs/skills/](https://opencode.ai/docs/skills/)
- If your setup differs, use a custom absolute directory.

4. Download and place `SKILL.md`

```bash
SOURCE_URL="https://raw.githubusercontent.com/crmin/pocketbase-collection-operation-skill/main/en/SKILL.md"  # or ko/SKILL.md
TARGET_DIR="/absolute/path/to/skills/pocketbase-collection-operations"

mkdir -p "$TARGET_DIR"
curl -fsSL "$SOURCE_URL" -o "$TARGET_DIR/SKILL.md"
```

5. Verify installation

```bash
test -f "$TARGET_DIR/SKILL.md" && echo "Installed"
head -n 5 "$TARGET_DIR/SKILL.md"
```

6. Restart or reload your agent session so the skill is discovered.
