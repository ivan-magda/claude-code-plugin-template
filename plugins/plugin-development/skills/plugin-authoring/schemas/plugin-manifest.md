# Plugin Manifest Schema

The `plugin.json` file in `.claude-plugin/` defines your plugin's metadata and optionally custom component paths.

## Location

`.claude-plugin/plugin.json` (at plugin root)

## Required Fields

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "What your plugin does"
}
```

- **name**: kebab-case string, unique identifier
- **version**: SemVer format (e.g., "1.0.0")
- **description**: Brief, user-facing description

## Optional Fields

### Standard Metadata

```json
{
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

- **commands**: Array of paths to individual `.md` command files, OR directory path
- **agents**: Array of paths to individual `.md` agent files (NOT a directory)
- **hooks**: Path to `hooks.json` configuration file
- **mcpServers**: MCP server configurations or path to MCP config file

All paths must be **relative to plugin root** (where `.claude-plugin/` lives)

### Author Field

Can be either:
- **String**: `"author": "Your Name"`
- **Object**: `"author": { "name": "Your Name", "email": "...", "url": "..." }`

## Examples

### Standard Directory Structure (Recommended)

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

**Note**: No component fields needed. Claude Code automatically discovers `commands/`, `agents/`, `skills/`, and `hooks/` directories.

### Custom Paths

```json
{
  "name": "enterprise-plugin",
  "version": "1.0.0",
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
