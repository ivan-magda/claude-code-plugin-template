---
description: Scaffold a new Claude Code plugin with standard structure and starter files
argument-hint: [plugin-name]
---

# Initialize Plugin

Create the standard directory structure and files for a new Claude Code plugin.

## Arguments

- `$1` (required): Plugin name in kebab-case (e.g., `my-awesome-plugin`)

## What This Command Does

1. Creates the plugin directory structure:
   - `.claude-plugin/` with `plugin.json`
   - `commands/` directory
   - `agents/` directory
   - `skills/` directory
   - `hooks/` directory with `hooks.json`
   - `scripts/` directory
2. Generates a starter `plugin.json` with the provided name
3. Creates a README.md template
4. Provides next steps

## Instructions

### Validation

First, validate the plugin name:
- Must be provided (not empty)
- Should be kebab-case (lowercase with hyphens)
- Should not contain spaces or special characters

If validation fails, explain the requirements and ask for a valid name.

### Create Directory Structure

Create these directories:
```
$1/
├── .claude-plugin/
├── commands/
├── agents/
├── skills/
├── hooks/
└── scripts/
```

### Create plugin.json

Create `.claude-plugin/plugin.json` with this template:

```json
{
  "name": "$1",
  "version": "0.1.0",
  "description": "Brief description of what this plugin does",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
```

### Create hooks.json

Create `hooks/hooks.json` with a basic structure:

```json
{
  "description": "Plugin hooks",
  "hooks": {}
}
```

### Create README.md

Create `README.md` with this template:

```markdown
# $1

[Brief description of what this plugin does]

## Installation

```bash
/plugin install $1@marketplace-name
```

## Commands

[List commands here]

## Usage

[Provide examples]
```

### Create Validation Script

Create `scripts/validate-plugin.sh` with executable permissions:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Basic plugin structure validation
[ -f ".claude-plugin/plugin.json" ] || { echo "Missing plugin.json" >&2; exit 2; }
exit 0
```

Make it executable: `chmod +x scripts/validate-plugin.sh`

## Next Steps

After scaffolding, provide these instructions to the user:

```
✓ Plugin scaffolded at $1/

Next steps:
1. Edit $1/.claude-plugin/plugin.json with your metadata
2. Add components:
   - /plugin-development:add-command <name> <description>
   - /plugin-development:add-skill <name> <description>
   - /plugin-development:add-agent <name> <description>
3. Validate: /plugin-development:validate
4. Test locally: /plugin-development:test-local
```

## Example

**Input**: `/plugin-development:init my-awesome-plugin`

**Result**:
- Creates `my-awesome-plugin/` with full structure
- Generates starter files
- Displays next steps

## Notes

- The command creates the plugin directory in the current working directory
- All paths in generated files are relative (use `./`)
- The plugin is not yet installed; use `/plugin-development:test-local` to test it
