# `plugin-development` — Comprehensive Implementation Plan (Hybrid: Skill + Commands + Agent + Hooks)

This plan delivers a Claude Code plugin named **`plugin-development`** that assists developers as they build Claude Code plugins—**from scaffold to release**—while following the official documentation and best practices. It uses a **hybrid architecture**:
- **Agent Skill** – _primary orchestrator & knowledge hub_ (auto‑discovered, progressive disclosure, read‑first)
- **Slash commands** – _explicit actions_ (scaffold, add components, validate, test locally)
- **One focused subagent** – _deep, multi‑step reviews_ in a separate context
- **Hooks** – _automated guardrails_ (validation & formatting around tool use)

> Scope: The plan assumes a Git repo with this plugin as a top‑level folder `plugin-development/`. It also includes a companion **dev marketplace** for local testing and team rollout.

---

## 0) Objectives & Non‑Goals

**Objectives**
1. Provide ambient, docs‑aware guidance while building plugins (Skill).
2. Provide explicit, repeatable actions for scaffolding and validation (Commands).
3. Offer deep, multi‑file **reviews** and readiness checks (Agent).
4. Enforce safety and quality checks automatically (Hooks).
5. Make local testing and **team distribution** simple (Marketplace + Settings).

**Non‑Goals**
- This plugin does **not** replace project‑specific policies; it provides defaults and patterns. 
- No networked MCP servers are included by default (extend later if needed).

---

## 1) Repository Layout

```
plugin-development/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── init.md
│   ├── add-command.md
│   ├── add-skill.md
│   ├── add-agent.md
│   ├── add-hook.md
│   ├── validate.md
│   └── test-local.md
├── agents/
│   └── plugin-reviewer.md
├── skills/
│   └── plugin-authoring/
│       ├── SKILL.md
│       ├── schemas/
│       │   ├── plugin-manifest.md
│       │   ├── hooks-schema.md
│       │   └── marketplace-schema.md
│       ├── templates/
│       │   ├── plugin-manifest.json
│       │   ├── marketplace-manifest.json
│       │   ├── command-template.md
│       │   ├── agent-template.md
│       │   └── skill-template.md
│       ├── examples/
│       │   ├── simple-plugin.md
│       │   └── testing-workflow.md
│       └── best-practices/
│           ├── organization.md
│           └── naming-conventions.md
├── hooks/
│   └── hooks.json
└── scripts/
    ├── validate-plugin.sh
    └── format-or-lint.sh
```

**Notes**
- Only the **manifest** goes in `.claude-plugin/`; all components (commands, agents, skills, hooks) live at **plugin root**.
- Paths in `plugin.json` use `./` and are **relative to plugin root**.

---

## 2) Manifest (`.claude-plugin/plugin.json`)

```jsonc
{
  "name": "plugin-development",
  "version": "1.0.0",
  "description": "Assist with Claude Code plugin development: scaffold, validate, review, and team-ready distribution.",
  "keywords": ["claude-code", "plugins", "developer-tools", "scaffold", "validation"],
  "license": "MIT",
  "repository": "https://example.com/your/repo",
  "commands": "./commands/",
  "agents": "./agents/",
  "hooks": "./hooks/hooks.json"
}
```

**Rationale**
- Declares component paths so Claude loads the plugin’s commands, agent, and hooks.
- Keep additional metadata (author/homepage) as needed for distribution.

---

## 3) Skill (Primary Orchestrator)

**Location**: `skills/plugin-authoring/SKILL.md`

The Skill is concise but _comprehensive via progressive disclosure_. It is **read‑first** (no writes) by default and routes execution to slash commands or the reviewer agent.

```markdown
---
name: plugin-authoring
description: Expert guidance for Claude Code plugin development. Use when creating or modifying plugins, working with plugin.json / marketplace.json, or adding commands, agents, Skills, or hooks.
allowed-tools: Read, Grep, Glob
---

# Plugin Authoring (Skill)

You are the canonical guide for Claude Code plugin development. Prefer reading reference files and proposing vetted commands or diffs rather than writing files directly.

## Triggers & Scope
Activate whenever context includes `.claude-plugin/`, `plugin.json`, `marketplace.json`, `commands/`, `agents/`, `skills/`, or `hooks/`.

## Flow of Operation
1) Diagnose current repo layout (read-only).
2) Propose the minimal safe action (scaffold, validate, or review).
3) Execute via `/plugin-development:...` commands when the user agrees.
4) Escalate to the **plugin-reviewer** agent for deep audits.
5) Guardrails: default to read-only; ask before edits.

## Quick Links (Progressive Disclosure)
- **Schemas**: [schemas/plugin-manifest.md](schemas/plugin-manifest.md), [schemas/hooks-schema.md](schemas/hooks-schema.md), [schemas/marketplace-schema.md](schemas/marketplace-schema.md)
- **Templates**: [templates/](templates/)
- **Examples**: [examples/](examples/)
- **Best practices**: [best-practices/](best-practices/)

## Checklists
**Component Checklist**
```
□ .claude-plugin/plugin.json exists
□ Component dirs at plugin root (not inside .claude-plugin/)
□ Commands use kebab-case naming
□ Skills have valid SKILL.md frontmatter
□ Hooks use ${CLAUDE_PLUGIN_ROOT} for paths
```

**Release Checklist**
```
□ plugin.json: name/version/keywords present
□ commands/agents/skills/hooks paths resolve
□ local marketplace installs cleanly
□ docs: README + examples linked
```

## Playbooks
- **Scaffold** → `/plugin-development:init <name>` then fill templates.
- **Add a component** → `/plugin-development:add-command|add-skill|add-agent|add-hook`.
- **Validate** → `/plugin-development:validate` (schema & structure checks).
- **Test locally** → `/plugin-development:test-local` (dev marketplace).

## Notes
- Prefer templates & scripts over freeform generation for deterministic tasks.
- If writes are needed, propose a command or a PR-style diff first.
```

**Support files**: Provide self‑contained `schemas/`, `templates/`, `examples/`, and `best-practices/` so the Skill can link out without bloating SKILL.md.

---

## 4) Slash Commands (Explicit Actions)

Create command files in `commands/` with frontmatter, argument hints, and (if applicable) **Bash** preambles guarded by `allowed-tools`.

### 4.1 `commands/init.md`
Scaffold the plugin boilerplate.

```markdown
---
description: Scaffold a new Claude Code plugin in the current repo following official layout.
argument-hint: [plugin-name]
allowed-tools: Bash(mkdir:*), Bash(touch:*), Bash(printf:*), Bash(cp:*)
---

Create the standard plugin structure and a starter manifest:

!`mkdir -p .claude-plugin commands agents skills hooks scripts`
!`printf '%s
' '{ "name": "$1", "version": "0.1.0", "description": "New plugin", "license": "MIT" }' > .claude-plugin/plugin.json'

Explain next steps:
- Open /plugin to verify installation
- Add Skills/Agents/Hooks as needed
```

### 4.2 `commands/add-command.md`
```markdown
---
description: Add a new plugin slash command file with description and (optional) argument hint.
argument-hint: [command-name] [short-description...]
---

Create `commands/$1.md` with frontmatter and a clear, third‑person description.
Add placeholders for `$ARGUMENTS`/`$1` etc., and optional Bash preamble.
```

### 4.3 `commands/add-skill.md`
```markdown
---
description: Add a new Skill folder with SKILL.md that Claude can discover automatically.
argument-hint: [skill-name] [one-line-when-to-use]
---

Create `skills/$1/SKILL.md`:
- `name: $1` (lowercase, hyphenated), third‑person `description`
- Keep SKILL.md concise; place details in sibling files (progressive disclosure)
```

### 4.4 `commands/add-agent.md`
```markdown
---
description: Add a new plugin subagent with standard capabilities and tool access notes.
argument-hint: [agent-name] [short-description...]
---

Create `agents/$1.md` with a system prompt, capabilities, and when to use it.
```

### 4.5 `commands/add-hook.md`
```markdown
---
description: Add a basic hooks.json or append new events to existing hooks config.
argument-hint: [event] [matcher]
---

Create or update `hooks/hooks.json` with a safe default for $1 (event) / $2 (matcher).
```

### 4.6 `commands/validate.md`
```markdown
---
description: Validate plugin layout and (optionally) marketplace.json.
allowed-tools: Bash(test:*), Bash(printf:*), Bash(jq:*)
---

# Validate plugin

!`test -f .claude-plugin/plugin.json || printf 'Missing .claude-plugin/plugin.json
'`
!`test -d commands || printf 'Missing commands/\n'`
!`test -d hooks || printf 'Missing hooks/\n'`
```

### 4.7 `commands/test-local.md`
```markdown
---
description: Create and install a local dev marketplace for iterative testing.
allowed-tools: Bash(mkdir:*), Bash(printf:*)
---

# Local dev marketplace

!`mkdir -p ../dev-marketplace/.claude-plugin`
!`printf '%s' '{ "name": "dev-marketplace", "owner": { "name": "Developer" }, "plugins": [{ "name": "plugin-development", "source": "../plugin-development", "description": "WIP plugin-development" }] }' > ../dev-marketplace/.claude-plugin/marketplace.json`

Next steps:
- `/plugin marketplace add ../dev-marketplace`
- `/plugin install plugin-development@dev-marketplace`
```

> **Namespacing**: Use `/plugin-development:init` etc. to avoid collisions.

---

## 5) Reviewer Agent (Subagent)

**Location**: `agents/plugin-reviewer.md`

A specialized subagent for multi‑step audits with a separate context window.

```markdown
---
description: Reviews a plugin for correct structure, safe hooks, clear commands/skills, and marketplace readiness.
capabilities: ["structure-audit", "hook-safety-checks", "marketplace-readiness"]
---

# Plugin Reviewer

## What this agent does
- Inspect `.claude-plugin/plugin.json`
- Verify root component directories
- Review command frontmatter and Skill metadata
- Flag risky hooks or missing timeouts
- Check marketplace readiness and local install flow

## How to proceed
1. Read manifest and list files
2. Report issues as Critical / Should fix / Nice to have
3. Provide diffs or snippets to fix (prefer commands where possible)
```
 
---

## 6) Hooks (Automation & Guardrails)

**Location**: `hooks/hooks.json`

Run validators around tool use and inject context at session start.

```jsonc
{
  "description": "Auto-validate basic plugin structure",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate-plugin.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format-or-lint.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          { "type": "command", "command": "echo 'plugin-development session started'" }
        ]
      }
    ]
  }
}
```

**Exit codes** (recommended):  
- `0` = OK; `stdout` visible (special rules for SessionStart).  
- `2` = **block** with actionable `stderr` fed back to Claude.  
- Other non‑zero = non‑blocking error (surface to user).

---

## 7) Utility Scripts

**`scripts/validate-plugin.sh`** – structural checks (portable, POSIX‑y):

```bash
#!/usr/bin/env bash
set -euo pipefail

ERRS=()

[ -f ".claude-plugin/plugin.json" ] || ERRS+=("Missing .claude-plugin/plugin.json")
[ -d "commands" ] || ERRS+=("Missing commands/")
[ -d "hooks" ] || ERRS+=("Missing hooks/")

if [ "${#ERRS[@]}" -gt 0 ]; then
  printf "%s\n" "${ERRS[@]}" 1>&2
  # Use 2 to block if you prefer to stop unsafe edits
  exit 1
fi

exit 0
```

**`scripts/format-or-lint.sh`** – run formatters/linters conditionally (stub you can extend).

```bash
#!/usr/bin/env bash
set -euo pipefail
# Detect changed files (optional) and run formatters
# e.g., prettier/eslint/ruff/black based on repo language
exit 0
```

> Ensure scripts are **executable** (`chmod +x`).

---

## 8) Local Development Marketplace (for Testing)

Create a sibling `dev-marketplace/` with `.claude-plugin/marketplace.json` that points to your working copy. Typical install loop:

```
/plugin marketplace add ../dev-marketplace
/plugin install plugin-development@dev-marketplace
```

Reinstall to pick up changes:
```
/plugin uninstall plugin-development@dev-marketplace
/plugin install   plugin-development@dev-marketplace
```

---

## 9) Team Settings (Optional Rollout)

Projects can request known marketplaces and enabled plugins via `.claude/settings.json`:

```jsonc
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    }
  },
  "enabledPlugins": {
    "plugin-development@team-tools": true
  }
}
```

> Team members will be prompted to trust the folder and install when they open the repo.

---

## 10) Permissions & Safety

- Keep the Skill **read‑only** by default (`allowed-tools: Read, Grep, Glob`).  
- Route file creation/edits through **commands** so users explicitly consent.  
- Use **hooks** to block risky operations (`PreToolUse` exit code `2`).  
- Configure project/user **permissions** to deny sensitive file reads and potentially risky Bash invocations.  
- Consider **sandbox** mode for higher autonomy, and set explicit allow/ask/deny lists as needed.

Example (project `.claude/settings.json`):

```jsonc
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ],
    "ask": [
      "Bash(npm:* )",
      "SlashCommand:/plugin-development:*"
    ]
  },
  "sandbox": {
    "enabled": true
  }
}
```

---

## 11) Validation, Debugging, and UX

- Provide `/plugin-development:validate` and **hooks** to keep feedback loops tight.
- Encourage using `claude --debug` to see plugin load, component registration, and hook runs.
- Keep **SKILL.md** < ~500 lines; push heavy content into referenced files.
- Prefer **one‑level‑deep** links from SKILL.md to avoid nested reads.

---

## 12) Release & Versioning

- **SemVer** in `plugin.json`.
- Maintain `CHANGELOG.md`; include notable changes to Skill/commands/hooks.
- For distribution, publish to a **GitHub marketplace repo**; team repos can list it via `extraKnownMarketplaces`.

---

## 13) Roadmap (Optional Enhancements)

- Add **MCP servers** (e.g., JSON schema validator, repo indexer).
- Enrich hooks with **JSON outputs** (PreToolUse decisions, UserPromptSubmit context injection).
- Provide **guided wizards** under commands (multi‑step Q&A to configure complex plugins).
- Add a “**Docs Sync**” command to update templates/schemas from upstream sources.

---

## 14) Acceptance Criteria (Definition of Done)

- [ ] Manifest loads without warnings; commands show up in `/help`; agent shows in `/agents`.
- [ ] Skill self‑describes, triggers correctly, and remains under size budget.
- [ ] `init`, `add-*`, `validate`, and `test-local` commands run successfully on a fresh repo.
- [ ] Hooks execute and **block** (exit 2) when structure is invalid; otherwise pass.
- [ ] Local marketplace install/uninstall loop works from a sibling folder.
- [ ] Project `.claude/settings.json` demo shows distribution & permissions patterns.
- [ ] README explains installation, usage, and safety posture.

---

## 15) Appendix: Starter Templates

### A) `skills/plugin-authoring/templates/plugin-manifest.json`
```json
{
  "name": "SAMPLE-NAME",
  "version": "0.1.0",
  "description": "Example plugin",
  "license": "MIT"
}
```

### B) `skills/plugin-authoring/templates/command-template.md`
```markdown
---
description: Brief, third-person description of what this command does
argument-hint: [arg1] [arg2]
---

# Command instructions

Explain expectations, inputs, and outputs.
(Optionally) Include Bash snippets prefixed with !` ... ` guarded by allowed-tools in frontmatter.
```

### C) `skills/plugin-authoring/templates/skill-template.md`
```markdown
---
name: your-skill-name
description: What the Skill does and WHEN to use it (third person).
allowed-tools: Read, Grep, Glob
---

# Your Skill

Provide minimal instructions, link to sibling references for details.
```

### D) `skills/plugin-authoring/templates/agent-template.md`
```markdown
---
description: What this agent specializes in; when to invoke it.
capabilities: ["task1", "task2"]
---

# Agent Name

Responsibilities, step-by-step approach, and example invocations.
```

### E) `skills/plugin-authoring/examples/testing-workflow.md`
Step-by-step local testing using a dev marketplace, including reinstall loops and `/plugin` UI usage.
```

plan:end
