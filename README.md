# Claude Code Plugin Marketplace Template

A GitHub template repository for creating and managing your own Claude Code plugin marketplace with a plugin development toolkit.

## Quick Start

### Use as Template

1. Click "Use this template" button on GitHub
2. Create your new repository
3. Clone your new repository:
   ```bash
   git clone https://github.com/your-org/your-marketplace-name.git
   cd your-marketplace-name
   ```
4. Customize the marketplace:
   ```bash
   # Update marketplace metadata
   vim .claude-plugin/marketplace.json
   ```

5. Install the plugin development tools:
   ```bash
   # Add your local marketplace
   /plugin marketplace add ./path-to-your-marketplace
   
   # Install the plugin-development plugin
   /plugin install plugin-development@my-team-plugin-marketplace
   ```

6. Test locally (see [Testing](#testing) section)

## What's Included

This template provides:

- **Marketplace Configuration** (`.claude-plugin/marketplace.json`): Central registry for all plugins following the official schema
- **Plugin Development Plugin** (`plugin-development`): Comprehensive toolkit for creating, validating, and managing plugins with:
  - Scaffolding and component generation commands
  - Automated validation and testing
  - Best practices and documentation integration
  - Review agent for release readiness
- **Sample Plugin** (`hello-world`): Fully functional example demonstrating:
  - Proper plugin manifest structure
  - Command with frontmatter
  - Best practices and documentation
- **Comprehensive Documentation** (`docs/`): Complete guides for plugin development, hooks, settings, commands, skills, and sub-agents
- **GitHub Actions**: Automated plugin validation workflow

## Configuration

### Marketplace Configuration

Edit `.claude-plugin/marketplace.json` to customize your marketplace:

```json
{
  "name": "my-team-plugin-marketplace",
  "owner": {
    "name": "Your Organization",
    "email": "team@your-org.com"
  },
  "metadata": {
    "description": "A curated collection of plugins for our team",
    "version": "1.0.0"
  },
  "plugins": [
    // Add your plugins here
  ]
}
```

**Note**: The `name` field should use kebab-case (lowercase with hyphens). See the [Plugin Marketplaces documentation](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces#marketplace-schema) for complete schema details.

### Team Settings (Optional)

You can configure automatic marketplace installation for team projects by adding `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/your-marketplace-name"
      }
    }
  }
}
```

When team members trust the repository folder, Claude Code automatically installs these marketplaces. See [Configure team marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces#configure-team-marketplaces) for details.

## Testing

### Local Testing

1. **Navigate to your project directory**:
   ```bash
   cd your-marketplace-name
   ```

2. **Start Claude Code**:
   ```bash
   claude
   ```

3. **Add your local marketplace**:
   ```
   /plugin marketplace add ./path-to-your-marketplace
   ```

4. **Install a plugin**:
   ```
   /plugin install hello-world@marketplace-name
   /plugin install plugin-development@marketplace-name
   ```

5. **Test commands**:
   ```
   /hello World
   /plugin-development:validate
   ```

6. **Verify installation**:
   ```
   /help
   ```
   Your plugin commands should appear in the help list.

### Using the Marketplace from GitHub

Once published to GitHub, users can add your marketplace:

```bash
# Add marketplace from GitHub
/plugin marketplace add your-org/your-repo-name

# Install plugins
/plugin install plugin-name@your-marketplace-name
```

## Creating New Plugins

### Option 1: Use the Plugin Development Plugin (Recommended)

This template includes a powerful `plugin-development` plugin that automates plugin scaffolding:

```bash
# After cloning and adding this marketplace
/plugin install plugin-development@my-team-plugin-marketplace

# Scaffold a new plugin
/plugin-development:init my-new-plugin

# Add components as needed
/plugin-development:add-command my-command "Description of what the command does"
/plugin-development:add-skill my-skill "Use when working with..."
/plugin-development:validate
```

See the [`plugin-development` README](plugins/plugin-development/README.md) for complete documentation.

### Option 2: Manual Setup

```bash
# Create plugin directory
mkdir -p plugins/my-plugin/.claude-plugin
mkdir -p plugins/my-plugin/commands

# Create plugin metadata
touch plugins/my-plugin/.claude-plugin/plugin.json
touch plugins/my-plugin/README.md
```

#### Step 2: Define Plugin Metadata

Edit `plugins/my-plugin/.claude-plugin/plugin.json`:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Description of what your plugin does",
  "author": {
    "name": "Your Name",
    "email": "your-email@example.com",
    "url": "https://github.com/your-username"
  },
  "homepage": "https://github.com/your-org/your-marketplace-name",
  "repository": "https://github.com/your-org/your-marketplace-name",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
```

**Note**: The `author` field must be an object with `name`, `email`, and optionally `url`. See the [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference#plugin-manifest-schema) for complete schema details.

#### Step 3: Create Command

Create `plugins/my-plugin/commands/my-command.md`:

```markdown
---
description: Brief description of what the command does
argument-hint: [arg1] [arg2]
---

# My Command

[Detailed instructions for Claude on how to execute this command]

## Instructions

1. [Step 1]
2. [Step 2]
3. [Step 3]

[Additional context and guidelines]
```

**Note**: Commands should include frontmatter with `description` and optionally `argument-hint`. The content is a prompt that Claude executes. See the [Slash Commands documentation](https://docs.claude.com/en/docs/claude-code/slash-commands#plugin-commands) for details.

#### Step 4: Register in Marketplace

Add to `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "description": "Description of what your plugin does",
      "version": "1.0.0",
      "author": {
        "name": "Your Name"
      },
      "source": "./plugins/my-plugin",
      "category": "utilities",
      "tags": ["tag1", "tag2"],
      "keywords": ["keyword1", "keyword2"]
    }
  ]
}
```

**Note**: The marketplace plugin entry uses the same schema as `plugin.json` with all fields optional, plus marketplace-specific fields like `source`, `category`, and `tags`. The `author` field should be an object.

## Documentation

### Local Documentation

This repository includes comprehensive documentation for the Claude Code plugin system in the [`docs/`](docs/) directory:

- **[Plugin Development](docs/plugins.md)**: Complete guide to creating and managing plugins
- **[Plugin Reference](docs/plugins-reference.md)**: Technical specifications and advanced features
- **[Plugin Marketplaces](docs/plugin-marketplaces.md)**: Marketplace creation and management
- **[Hooks](docs/hooks.md)**: Event-driven automation and workflows
- **[Settings](docs/settings.md)**: Configuration and customization options
- **[Slash Commands](docs/slash-commands.md)**: Command system and custom commands
- **[Skills](docs/skills.md)**: Agent capabilities and expertise packages
- **[Sub-Agents](docs/sub-agents.md)**: Specialized AI assistants and task delegation

Start with [`docs/plugins.md`](docs/plugins.md) for plugin development basics, or [`docs/README.md`](docs/README.md) for a complete overview of all available documentation.

### Official Claude Code Documentation

- **[Claude Code Plugins](https://docs.claude.com/en/docs/claude-code/plugins)**: Complete plugin development guide
- **[Plugin Marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)**: Marketplace creation and management
- **[Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)**: Technical specifications and schemas
- **[Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)**: Command development details

## License

MIT License - see [LICENSE](LICENSE) file for details
