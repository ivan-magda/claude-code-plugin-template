# Plugin Manifest Schema

The `plugin.json` file in `.claude-plugin/` defines your plugin's metadata and optionally custom component paths.

## Location

`.claude-plugin/plugin.json` (at plugin root)

## Required Fields

```json
{
  "name": "plugin-name"
}
```

- **name**: kebab-case string, unique identifier (REQUIRED)

## Optional Fields

### Standard Metadata

```json
{
  "version": "1.0.0",
  "description": "What your plugin does",
  "author": {
    "name": "Your Name",
    "email": "you@example.com",
    "url": "https://github.com/your-username"
  },
  "homepage": "https://your-plugin-homepage.com",
  "repository": "https://github.com/your-org/your-repo",
  "license": "MIT",
  "keywords": ["tag1", "tag2"]
}
```

- **version**: Semantic version format (optional metadata)
- **description**: Brief explanation of plugin purpose (optional metadata)
- **author**: Can be string or object with name, email, url
- **homepage**: Documentation URL (optional metadata)
- **repository**: Source code URL (optional metadata)
- **license**: License identifier like "MIT" (optional metadata)
- **keywords**: Array of tags for discovery (optional metadata)

### Component Configuration (Custom Paths Only)

**IMPORTANT**: Only include these fields if you're using **non-standard** paths. If using standard directory structure (`commands/`, `agents/`, `skills/`, `hooks/`), omit these fields entirely.

```json
{
  "commands": ["./custom/path/cmd1.md", "./custom/path/cmd2.md"],
  "agents": ["./custom/agents/reviewer.md", "./custom/agents/tester.md"],
  "hooks": "./custom/hooks/hooks.json",
  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["path/to/server.js"]
    }
  }
}
```

### Component Path Rules

- **commands**: Array of paths to individual `.md` command files, OR string path to a directory
- **agents**: Array of paths to individual `.md` agent files (NOT a directory path)
- **hooks**: Path to `hooks.json` configuration file OR inline hooks object
- **mcpServers**: MCP server configurations object OR path to MCP config file

All paths must be **relative to plugin root** (where `.claude-plugin/` lives) and start with `./`

**Note**: Custom paths supplement default directories - they don't replace them. If `commands/` exists, it's loaded in addition to custom command paths.

### Skills Configuration

For Skills (Agent Skills) provided by your plugin, you can restrict which tools Claude can use:

```json
{
  "name": "my-skill-plugin",
  "skills": [
    {
      "name": "safe-reader",
      "allowed-tools": ["Read", "Grep", "Glob"]
    }
  ]
}
```

However, the recommended approach is to specify `allowed-tools` directly in the `SKILL.md` frontmatter:

```yaml
---
name: safe-reader
description: Read files without making changes
allowed-tools: Read, Grep, Glob
---
```

### Environment Variables

**`${CLAUDE_PLUGIN_ROOT}`** is a special environment variable available in your plugin that contains the absolute path to your plugin directory. Use this in hooks, MCP servers, and scripts to ensure correct paths regardless of installation location.

```json
{
  "name": "my-plugin",
  "hooks": "./hooks/hooks.json"
}
```

Where `hooks/hooks.json` contains:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format-code.sh"
          }
        ]
      }
    ]
  }
}
```

Or inline hooks:

```json
{
  "name": "my-plugin",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh"
          }
        ]
      }
    ]
  }
}
```

Use `${CLAUDE_PLUGIN_ROOT}` for:
- Scripts executed by hooks
- MCP server paths
- Config files referenced by components
- Any file paths in your plugin configuration

## Examples

### Standard Directory Structure (Recommended)

```json
{
  "name": "my-dev-tools"
}
```

**Minimal plugin** - The simplest possible plugin. Claude Code automatically discovers `commands/`, `agents/`, `skills/`, and `hooks/` directories.

```json
{
  "name": "my-dev-tools",
  "version": "1.2.0",
  "description": "Developer productivity tools for Claude Code",
  "author": {
    "name": "Dev Team",
    "email": "dev@company.com"
  },
  "license": "MIT",
  "keywords": ["productivity", "tools"]
}
```

**With metadata** - Adding optional metadata for better discovery and documentation.

### Custom Paths

```json
{
  "name": "enterprise-plugin",
  "description": "Enterprise development tools",
  "author": {
    "name": "Your Name"
  },
  "commands": [
    "./specialized/deploy.md",
    "./utilities/batch-process.md"
  ],
  "agents": [
    "./custom-agents/reviewer.md",
    "./custom-agents/tester.md"
  ]
}
```

**Note**: Using custom paths to organize components. The `description` and `author` fields are optional metadata.

## Common Mistakes

❌ **Wrong**: Including component fields with standard paths
```json
{
  "name": "my-plugin",
  "commands": "./commands/",
  "agents": "./agents/"
}
```

✅ **Correct**: Omit component fields for standard paths
```json
{
  "name": "my-plugin"
}
```

❌ **Wrong**: agents as directory path
```json
{
  "agents": "./agents/"
}
```

✅ **Correct**: agents as array of file paths
```json
{
  "agents": ["./agents/reviewer.md", "./agents/tester.md"]
}
```

❌ **Wrong**: Absolute paths
```json
{
  "commands": "/Users/you/plugins/my-plugin/commands/"
}
```

✅ **Correct**: Relative paths
```json
{
  "commands": ["./custom/cmd.md"]
}
```

## Validation

Use `/plugin-development:validate` to check your manifest structure.
