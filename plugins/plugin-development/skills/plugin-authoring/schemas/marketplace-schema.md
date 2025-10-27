# Marketplace Schema

The `marketplace.json` file defines a collection of plugins that users can install.

## Location

`.claude-plugin/marketplace.json` (at marketplace root)

## Structure

```json
{
  "name": "marketplace-name",
  "owner": {
    "name": "Your Organization",
    "email": "team@your-org.com"
  },
  "metadata": {
    "description": "Marketplace description",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "description": "What the plugin does",
      "version": "1.0.0",
      "author": {
        "name": "Author Name"
      },
      "source": "./plugins/plugin-name",
      "category": "utilities",
      "tags": ["tag1", "tag2"],
      "keywords": ["keyword1", "keyword2"]
    }
  ]
}
```

## Required Fields

### Marketplace Level

- **name**: kebab-case string, unique marketplace identifier
- **owner**: Object with `name` (required) and optional `email`
- **plugins**: Array of plugin entries

### Plugin Entry

- **name**: Plugin name (must match `plugin.json`)
- **source**: Relative path to plugin directory OR git URL

## Optional Fields

### Marketplace Level

- **metadata**: Object with:
  - **description**: Brief marketplace description
  - **version**: Marketplace version
  - **pluginRoot**: Base path for relative plugin sources (allows resolving relative plugin paths)

### Plugin Entry

**Standard metadata fields:**

- **description**: Brief description
- **version**: SemVer version
- **author**: String or object with `name`, `email`, `url`
- **category**: Category string (e.g., "utilities", "productivity")
- **tags**: Array of tags for filtering
- **keywords**: Array of keywords for search
- **homepage**: Plugin homepage URL
- **repository**: Plugin repository URL
- **license**: License identifier (e.g., "MIT")
- **strict**: Boolean (default: true) - Require plugin.json in plugin folder

**Component configuration fields:**

- **commands**: String or array - Custom paths to command files or directories
- **agents**: String or array - Custom paths to agent files
- **hooks**: String or object - Custom hooks configuration or path to hooks file
- **mcpServers**: String or object - MCP server configurations or path to MCP config

## Source Types

### Local Path (Development)

```json
{
  "source": "./plugins/my-plugin"
}
```

### Git Repository

Simple string format:

```json
{
  "source": "https://github.com/user/repo"
}
```

Object format for advanced configuration:

```json
{
  "source": {
    "source": "github",
    "repo": "owner/plugin-repo"
  }
}
```

### Git URL Source

```json
{
  "source": {
    "source": "url",
    "url": "https://gitlab.com/team/plugin.git"
  }
}
```

### Git with Subdirectory

```json
{
  "source": "https://github.com/user/repo/tree/main/plugins/my-plugin"
}
```

## Examples

### Local Dev Marketplace

```json
{
  "name": "dev-marketplace",
  "owner": {
    "name": "Developer",
    "email": "dev@localhost"
  },
  "metadata": {
    "description": "Local development marketplace",
    "version": "0.1.0"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "description": "Plugin in development",
      "source": "../my-plugin"
    }
  ]
}
```

### Team Marketplace

```json
{
  "name": "acme-tools",
  "owner": {
    "name": "ACME Corp",
    "email": "tools@acme.com"
  },
  "metadata": {
    "description": "ACME internal tools for Claude Code",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "code-review",
      "description": "ACME code review standards",
      "version": "2.1.0",
      "author": {
        "name": "DevTools Team"
      },
      "source": "./plugins/code-review",
      "category": "development",
      "tags": ["code-review", "standards"],
      "keywords": ["review", "quality", "standards"]
    },
    {
      "name": "deploy-tools",
      "description": "Deployment automation",
      "version": "1.5.0",
      "author": {
        "name": "DevOps Team"
      },
      "source": "./plugins/deploy-tools",
      "category": "devops",
      "tags": ["deployment", "automation"],
      "keywords": ["deploy", "ci", "cd"]
    }
  ]
}
```

### Advanced Plugin Entry

Plugin entries can override default component locations and provide inline configuration:

```json
{
  "name": "enterprise-tools",
  "source": {
    "source": "github",
    "repo": "company/enterprise-plugin"
  },
  "description": "Enterprise workflow automation tools",
  "version": "2.1.0",
  "author": {
    "name": "Enterprise Team",
    "email": "enterprise@company.com"
  },
  "homepage": "https://docs.company.com/plugins/enterprise-tools",
  "repository": "https://github.com/company/enterprise-plugin",
  "license": "MIT",
  "keywords": ["enterprise", "workflow", "automation"],
  "category": "productivity",
  "commands": [
    "./commands/core/",
    "./commands/enterprise/",
    "./commands/experimental/preview.md"
  ],
  "agents": [
    "./agents/security-reviewer.md",
    "./agents/compliance-checker.md"
  ],
  "hooks": "./config/hooks.json",
  "mcpServers": {
    "enterprise-db": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  },
  "strict": false
}
```

<Note>
**Schema relationship**: Plugin entries are based on the *plugin manifest schema* (with all fields made optional) plus marketplace-specific fields (`source`, `strict`, `category`, `tags`). This means any field valid in a `plugin.json` file can also be used in a marketplace entry. When `strict: false`, the marketplace entry serves as the complete plugin manifest if no `plugin.json` exists. When `strict: true` (default), marketplace fields supplement the plugin's own manifest file.
</Note>

<Note>
**Environment variables**: Use `${CLAUDE_PLUGIN_ROOT}` in hooks and mcpServers configurations. This variable resolves to the plugin's installation directory and ensures paths work correctly regardless of where the plugin is installed.
</Note>

## Usage

### Add Marketplace (Local)

```bash
/plugin marketplace add /path/to/marketplace
```

### Add Marketplace (GitHub)

```bash
/plugin marketplace add your-org/your-repo
```

### Install Plugin from Marketplace

```bash
/plugin install plugin-name@marketplace-name
```

### Team Auto-Install

In project `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/marketplace-repo"
      }
    }
  },
  "enabledPlugins": {
    "plugin-name@team-tools": true
  }
}
```

## Testing Workflow

1. Create dev marketplace:
   ```bash
   mkdir -p dev-marketplace/.claude-plugin
   # Create marketplace.json pointing to ../your-plugin
   ```

2. Add to Claude Code:
   ```bash
   /plugin marketplace add ./dev-marketplace
   ```

3. Install plugin:
   ```bash
   /plugin install your-plugin@dev-marketplace
   ```

4. After changes, reinstall:
   ```bash
   /plugin uninstall your-plugin@dev-marketplace
   /plugin install your-plugin@dev-marketplace
   ```

## Best Practices

- **Use kebab-case** for marketplace and plugin names
- **Keep descriptions concise** (< 100 chars)
- **Add meaningful tags** for discoverability
- **Version consistently** using SemVer
- **Test locally** before publishing to GitHub
- **Document plugins** in their README files

## Common Mistakes

❌ **Plugin name mismatch**
```json
// marketplace.json
{ "name": "my-plugin", "source": "./plugins/other-plugin" }

// plugin.json (in other-plugin/)
{ "name": "other-plugin" }  // Names don't match!
```

✅ **Names must match**
```json
// marketplace.json
{ "name": "my-plugin", "source": "./plugins/my-plugin" }

// plugin.json
{ "name": "my-plugin" }  // Matches!
```

❌ **Absolute source paths**
```json
{
  "source": "/Users/you/plugins/my-plugin"
}
```

✅ **Relative source paths**
```json
{
  "source": "./plugins/my-plugin"
}
```

## Validation

Use `/plugin-development:validate` to check marketplace structure.
