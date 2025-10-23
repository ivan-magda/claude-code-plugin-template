# Hello World Plugin

A simple example plugin that demonstrates the basic structure and functionality of Claude Code plugins.

## Overview

This plugin provides a `/hello` command that greets users with a friendly message. It serves as a template and learning resource for creating your own Claude Code plugins.

## Commands

### `/hello [name]`

Greets the user with a personalized message.

**Usage:**
```
/hello
/hello World
/hello Team
```

**Examples:**
```
> /hello Alice
Hello, Alice! 👋

This is a sample command from the Hello World plugin, demonstrating how Claude Code 
plugins work. Plugins can add custom commands, agents, hooks, Skills, and MCP servers 
to extend Claude Code's capabilities!

> /hello
Hello, there! 👋

This is a sample command from the Hello World plugin, demonstrating how Claude Code 
plugins work. Plugins can add custom commands, agents, hooks, Skills, and MCP servers 
to extend Claude Code's capabilities!
```

## Installation

### From the Marketplace

If you're using this plugin from a marketplace:

```bash
# Add the marketplace
/plugin marketplace add owner/repo

# Install the plugin
/plugin install hello-world@marketplace-name
```

### For Template Users

If you're using this as a template to create your own plugins:

1. Clone this repository
2. The plugin is automatically available through the local marketplace
3. Test locally using `/plugin marketplace add ./path-to-repo`

## File Structure

```
hello-world/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata and configuration
├── commands/
│   └── hello.md             # Command implementation
└── README.md                # This file
```

## How It Works

1. **Plugin Metadata** (`.claude-plugin/plugin.json`): Defines the plugin name, version, description, author, and other metadata
2. **Command Definition** (`commands/hello.md`): Contains the prompt with frontmatter that Claude executes when the command is invoked
3. **Marketplace Registration**: The plugin is registered in the `.claude-plugin/marketplace.json` file at the repository root

## Customization

To create your own plugin based on this template:

1. Copy the `hello-world` directory
2. Rename it to your plugin name (use kebab-case)
3. Update `.claude-plugin/plugin.json` with your plugin details
4. Create your command files in `commands/`
5. Update the README.md
6. Add your plugin to the marketplace.json

## Learn More

- [Claude Code Plugins Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)

## License

MIT
