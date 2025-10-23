# Claude Code Plugin Marketplace Template

A GitHub template repository for creating and managing your own Claude Code plugin marketplace.

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
5. Test locally (see [Testing](#testing) section)

## What's Included

This template provides:

- **Marketplace Configuration** (`.claude-plugin/marketplace.json`): Central registry for all plugins following the official schema
- **Sample Plugin** (`hello-world`): Fully functional example demonstrating:
  - Proper plugin manifest structure
  - Command with frontmatter
  - Best practices and documentation
- **GitHub Actions**: Automated plugin validation workflow
- **Complete Documentation**: Links to official Claude Code documentation

## Repository Structure

```
.
├── .claude-plugin/
│   └── marketplace.json               # Marketplace definition
├── plugins/
│   └── hello-world/                   # Example: Basic plugin
│       ├── .claude-plugin/
│       │   └── plugin.json            # Plugin manifest
│       ├── commands/
│       │   └── hello.md               # Command definition
│       └── README.md                  # Plugin documentation
├── .github/
│   └── workflows/
│       └── validate-plugins.yml       # CI/CD validation
├── .gitignore
├── LICENSE
└── README.md
```

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
   ```

5. **Test commands**:
   ```
   /hello World
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

### CI/CD Testing

The included GitHub Actions workflow validates:
- JSON syntax in all plugin.json and marketplace.json files
- Required fields are present
- Command files exist
- No duplicate plugin names

## 📝 Creating New Plugins

### Step 1: Create Plugin Structure

```bash
# Create plugin directory
mkdir -p plugins/my-plugin/.claude-plugin
mkdir -p plugins/my-plugin/commands

# Create plugin metadata
touch plugins/my-plugin/.claude-plugin/plugin.json
touch plugins/my-plugin/README.md
```

### Step 2: Define Plugin Metadata

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

### Step 3: Create Command

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

### Step 4: Register in Marketplace

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

### Step 5: Test Your Plugin

```bash
# Validate
./scripts/validate.sh

# Test
./scripts/test-plugin.sh my-plugin

# Try it in Claude Code
claude
/my-command
```

## 📚 Documentation

### Official Claude Code Documentation

- **[Claude Code Plugins](https://docs.claude.com/en/docs/claude-code/plugins)**: Complete plugin development guide
- **[Plugin Marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)**: Marketplace creation and management
- **[Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)**: Technical specifications and schemas
- **[Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)**: Command development details

## 🤝 Contributing

We welcome plugin contributions!

### Submitting a Plugin

1. Fork this repository
2. Create your plugin in the `plugins/` directory
3. Add it to `marketplace.json`
4. Test locally
5. Submit a pull request using the plugin submission template

## 📋 Requirements

- Claude Code installed and running
- Git (for version control and GitHub integration)
- Basic familiarity with JSON and Markdown formats

## 🐛 Troubleshooting

### Plugins Not Loading

1. Verify marketplace.json syntax:
   ```bash
   jq . .claude-plugin/marketplace.json
   ```

2. Check plugin paths are correct:
   ```bash
   ls -la plugins/*/.claude-plugin/plugin.json
   ```

3. Validate settings:
   ```bash
   jq . .claude/settings.json
   ```

### Commands Not Found

1. Ensure command files exist:
   ```bash
   find plugins -name "*.md"
   ```

2. Restart Claude Code

### Validation Errors

Run the validation script for detailed error messages:
```bash
./scripts/validate.sh
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

- Built for the Claude Code community
- Inspired by package managers and plugin systems
- Thanks to all contributors

## 📮 Support

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Documentation**: Check the `docs/` directory for detailed guides

---

**Ready to get started?** Click "Use this template" and create your own plugin marketplace!
