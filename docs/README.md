# Claude Code Plugin System Documentation

This directory contains comprehensive documentation for the Claude Code plugin system - the complete guide to extending Claude Code with custom functionality. Each guide serves a specific purpose for plugin development, management, and usage.

## Documentation Overview

### Core Features & Usage

**📋 [hooks.md](hooks.md)** - **Hook System Reference**<br>
Complete technical reference for implementing hooks in Claude Code. Read this when you need to:
- Configure event-driven automation
- Set up pre/post tool execution workflows
- Implement custom validation or processing
- Debug hook-related issues

**⚙️ [settings.md](settings.md)** - **Configuration Guide**<br>
Comprehensive guide to Claude Code configuration options. Read this when you need to:
- Configure global or project settings
- Set up permissions and access controls
- Manage environment variables
- Configure subagents and plugins

**💬 [slash-commands.md](slash-commands.md)** - **Command Reference**<br>
Complete guide to slash commands for controlling Claude Code behavior. Read this when you need to:
- Learn built-in command functionality
- Create custom slash commands
- Work with plugin commands
- Use the SlashCommand tool programmatically

### Advanced Features

**🎯 [skills.md](skills.md)** - **Agent Skills Guide**<br>
Guide for creating and managing Agent Skills to extend Claude's capabilities. Read this when you need to:
- Build modular capabilities for Claude
- Create reusable expertise packages
- Share team workflows and conventions
- Package complex functionality with scripts

**🧠 [sub-agents.md](sub-agents.md)** - **Subagent System**<br>
Guide for creating specialized AI subagents for task-specific workflows. Read this when you need to:
- Build specialized AI assistants
- Implement task delegation patterns
- Create domain-specific expertise
- Manage multi-agent workflows

### Plugin System

**🔧 [plugins.md](plugins.md)** - **Plugin Development**<br>
Hands-on guide for extending Claude Code with custom functionality. Read this when you need to:
- Create your first plugin
- Install and manage plugins
- Develop complex plugin features
- Test and share plugins

**📦 [plugins-reference.md](plugins-reference.md)** - **Plugin Technical Reference**<br>
Complete technical specifications for the plugin system. Read this when you need to:
- Understand plugin architecture details
- Implement advanced plugin components
- Work with plugin manifests and schemas
- Debug plugin issues

**🏪 [plugin-marketplaces.md](plugin-marketplaces.md)** - **Marketplace Management**<br>
Guide for creating and managing plugin distribution systems. Read this when you need to:
- Set up team plugin distribution
- Create marketplace repositories
- Manage plugin versions and updates
- Host community plugin collections

## Getting Started

**New to Claude Code plugins?** Start with:
1. [plugins.md](plugins.md) - Plugin quickstart tutorial
2. [settings.md](settings.md) - Plugin configuration
3. [slash-commands.md](slash-commands.md) - Plugin commands

**Want to develop plugins?** Read:
1. [plugins.md](plugins.md) - Plugin development basics
2. [plugins-reference.md](plugins-reference.md) - Technical specifications
3. [plugin-marketplaces.md](plugin-marketplaces.md) - Distribution

**Need automation?** Check:
1. [hooks.md](hooks.md) - Event-driven workflows
2. [sub-agents.md](sub-agents.md) - Task delegation
3. [plugin-marketplaces.md](plugin-marketplaces.md) - Team distribution

## Contributing

When adding new documentation:
- Follow existing file naming conventions (`kebab-case.md`)
- Include practical examples and code snippets
- Cross-reference related documentation
- Update this README when adding new files

## See Also

- [Claude Code Main Documentation](/) - Complete Claude Code documentation
- [Plugin Development Examples](https://github.com/anthropics/claude-code-plugins) - Community plugin examples
- [Claude Code GitHub](https://github.com/anthropics/claude-code) - Source code and issues
