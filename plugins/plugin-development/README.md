# plugin-development

A comprehensive Claude Code plugin that assists developers in creating, validating, and distributing Claude Code plugins—from scaffold to release.

## Overview

The `plugin-development` plugin provides a complete toolkit for plugin authorship using a hybrid architecture:

- **Skill (plugin-authoring)**: Ambient, auto-discovered guidance with progressive disclosure
- **7 Slash Commands**: Explicit actions for scaffolding, validation, and testing
- **Reviewer Agent**: Deep, multi-file audits and readiness checks
- **Hooks**: Automated validation and formatting guardrails

## Installation

This plugin is part of the **Claude Code Plugin Marketplace Template**. To use it:

### Quick Start (Recommended for First-Time Users)

```bash
# From the template root directory
/plugin marketplace add .

# Install the plugin
/plugin install plugin-development@claude-code-plugin-template
```

### For Team Marketplaces

If you're using this template to create your own marketplace:

1. **Set up your marketplace** (see the [main README](../../README.md) for instructions)
2. **Add your marketplace to Claude Code**:
   ```bash
   /plugin marketplace add your-org/your-marketplace-repo
   ```
3. **Install the plugin**:
   ```bash
   /plugin install plugin-development@your-marketplace-name
   ```

### Local Development Setup

If you want to use this for developing new plugins:

```bash
# From the template root directory
cd /path/to/claude-code-plugin-template

# Add the marketplace
/plugin marketplace add .

# Install this plugin
/plugin install plugin-development@claude-code-plugin-template
```

Then use it to scaffold new plugins:

```bash
/plugin-development:init my-new-plugin
```

## Quick Start

> **Before you begin**: Make sure you've installed this plugin following the [Installation](#installation) instructions above.

### Create a New Plugin

Once installed, you can scaffold a new plugin:

```bash
/plugin-development:init my-awesome-plugin
```

This scaffolds:
- `.claude-plugin/plugin.json` - Plugin manifest
- `commands/` - Slash commands directory
- `agents/` - Sub-agents directory
- `skills/` - Skills directory
- `hooks/hooks.json` - Hook configuration
- `scripts/` - Validation scripts
- `README.md` - Documentation template

### Add Components

```bash
# Add a command
/plugin-development:add-command format-code "Format code according to project standards"

# Add a skill
/plugin-development:add-skill code-review "Use when reviewing code or PRs"

# Add an agent
/plugin-development:add-agent security-auditor "Analyzes code for security vulnerabilities"

# Add a hook
/plugin-development:add-hook PreToolUse "Write|Edit"
```

### Validate Your Plugin

```bash
/plugin-development:validate
```

Checks:
- Plugin structure and organization
- Manifest validity (plugin.json)
- Component configuration
- Naming conventions
- Hook safety

### Test Locally

After creating your plugin and making it available in a marketplace:

```bash
# From your plugin directory
/plugin-development:test-local
```

This creates a dev marketplace and provides installation instructions for iterative testing. See the [Testing Your Plugin](#testing-your-plugin) section below for complete workflow details.

## Commands Reference

| Command | Description |
|---------|-------------|
| `/plugin-development:init [name]` | Scaffold a new plugin with standard structure |
| `/plugin-development:add-command [name] [desc]` | Add a new slash command |
| `/plugin-development:add-skill [name] [desc]` | Add a new Skill with SKILL.md |
| `/plugin-development:add-agent [name] [desc]` | Add a new sub-agent |
| `/plugin-development:add-hook [event] [matcher]` | Add a hook configuration |
| `/plugin-development:validate` | Validate plugin structure and configuration |
| `/plugin-development:test-local` | Create dev marketplace for local testing |

## Skill: plugin-authoring

The plugin-authoring Skill provides ambient guidance throughout your development session.

**Triggers**: Automatically activates when working with:
- `.claude-plugin/plugin.json`
- `marketplace.json`
- `commands/`, `agents/`, `skills/`, or `hooks/` directories

**Capabilities**:
- Read-only analysis and guidance
- Progressive disclosure (links to detailed docs)
- Proposes safe actions via commands
- Escalates to plugin-reviewer agent for deep audits

**Access**: Automatic (no explicit invocation needed)

## Agent: plugin-reviewer

Deep, comprehensive audits of plugins for release readiness.

**Invoke**: `/agents plugin-reviewer`

**Provides**:
- Structure audit
- Manifest validation
- Component analysis
- Hook safety checks
- Marketplace readiness assessment
- Prioritized issue list (Critical → Low)
- Specific fix recommendations

**Runtime**: 5-15 minutes (separate context window)

## Hooks

Automated validation and formatting hooks are included:

### PreToolUse
- Validates plugin structure before Write/Edit operations
- Exit code 2 blocks unsafe operations
- Provides actionable error messages

### PostToolUse
- Runs formatting/linting after Write/Edit (stub, extend as needed)

### SessionStart
- Displays plugin load confirmation

## Development Workflow

### Prerequisites

Before starting plugin development:

1. **Clone or download this template**:
   ```bash
   git clone https://github.com/your-org/claude-code-plugin-template.git
   cd claude-code-plugin-template
   ```

2. **Install this plugin** (see [Installation](#installation) above)

3. **Create a new plugin**:
   ```bash
   /plugin-development:init my-plugin
   cd my-plugin/
   ```

### 1. Initialize

Once installed, create your plugin:

```bash
cd my-projects/
/plugin-development:init my-plugin
cd my-plugin/
```

### 2. Add Components

```bash
/plugin-development:add-command hello "Greet the user"
# Edit commands/hello.md with your instructions

/plugin-development:add-skill my-expertise "Use when working with X"
# Edit skills/my-expertise/SKILL.md
```

### 3. Validate

```bash
/plugin-development:validate
```

Fix any errors or warnings.

### 4. Test Locally

```bash
/plugin-development:test-local
/plugin marketplace add ../dev-marketplace
/plugin install my-plugin@dev-marketplace
```

Test your commands:
```bash
/my-plugin:hello
```

### 5. Iterate

After making changes:
```bash
/plugin-development:validate
/plugin uninstall my-plugin@dev-marketplace
/plugin install my-plugin@dev-marketplace
# Test again
```

### 6. Review Before Release

```bash
/agents plugin-reviewer
```

Fix any critical or high-priority issues identified.

### 7. Distribute

Add to your team marketplace repository and push to GitHub.

## Documentation

The plugin includes comprehensive reference material:

### Schemas
- `schemas/plugin-manifest.md` - plugin.json structure
- `schemas/hooks-schema.md` - Hooks configuration
- `schemas/marketplace-schema.md` - Marketplace structure

### Templates
- `templates/plugin-manifest.json` - Starter plugin.json
- `templates/marketplace-manifest.json` - Marketplace template
- `templates/command-template.md` - Command structure
- `templates/skill-template.md` - Skill structure
- `templates/agent-template.md` - Agent structure

### Examples
- `examples/simple-plugin.md` - Complete minimal plugin example
- `examples/testing-workflow.md` - Step-by-step testing guide

### Best Practices
- `best-practices/organization.md` - Plugin structure guidelines
- `best-practices/naming-conventions.md` - Naming standards

## Architecture

### Hybrid Design

**Skill (Read-First)**:
- Ambient, automatic activation
- Read-only by default (Read, Grep, Glob)
- Proposes commands for execution
- Progressive disclosure keeps it concise

**Commands (Explicit)**:
- User-triggered actions
- Deterministic operations
- Template-based generation
- Clear consent for modifications

**Agent (Deep Analysis)**:
- Separate context window
- Multi-file analysis
- Comprehensive reporting
- Use for release readiness

**Hooks (Automation)**:
- Validation before writes
- Formatting after writes
- Automated guardrails
- Safety first

## Safety & Permissions

### Default Safety

- Skill is **read-only** by default
- All writes go through **explicit commands**
- Hooks **block** unsafe operations (exit code 2)
- Agent **proposes** changes, doesn't execute

### Recommended Permissions

For enhanced security, configure in `.claude/settings.json`:

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ],
    "ask": [
      "SlashCommand:/plugin-development:*"
    ]
  }
}
```

## Troubleshooting

### Plugin not loading?
- Check `/plugin list` to verify installation
- Verify `plugin.json` doesn't include component fields for standard paths
- If using custom paths, ensure they're relative (e.g., `["./custom/cmd.md"]`)
- Run `/plugin-development:validate`

### Commands not showing?
- Check `/help` for command list
- Ensure `commands/` has `.md` files with frontmatter
- Verify `description` field in frontmatter
- Reinstall the plugin

### Skills not triggering?
- Check `SKILL.md` frontmatter `name` matches directory (kebab-case)
- Verify `description` includes both what the Skill does AND when to use it
- Include specific trigger keywords users would naturally mention
- Description must be max 1024 characters
- Skills are model-invoked (automatically activate based on context)

### Hooks not running?
- Make scripts executable: `chmod +x scripts/*.sh`
- Use `${CLAUDE_PLUGIN_ROOT}` in hook commands
- Test script directly: `./scripts/validate-plugin.sh`
- Use `claude --debug` to see hook execution

## Contributing

This plugin follows its own best practices:
- kebab-case naming throughout
- Progressive disclosure in skills
- Template-based generation
- Comprehensive validation

To extend:
1. Add new commands in `commands/`
2. Enhance the skill with new reference docs
3. Update the reviewer agent with new checks
4. Add hooks for new automation

## Resources

### Official Documentation
- [Claude Code Plugins](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)

### Local Documentation
See `skills/plugin-authoring/` for:
- Schemas (plugin manifest, hooks, marketplace)
- Templates (reusable starter files)
- Examples (complete working plugins)
- Best practices (organization, naming)

## License

MIT License - See LICENSE file for details

## Version

**1.0.0** - Initial release

### Features
- ✅ Plugin scaffolding (init command)
- ✅ Component generation (add-command, add-skill, add-agent, add-hook)
- ✅ Validation (validate command)
- ✅ Local testing (test-local command)
- ✅ Ambient guidance (plugin-authoring skill)
- ✅ Deep review (plugin-reviewer agent)
- ✅ Automated safety (validation hooks)
- ✅ Comprehensive documentation (schemas, templates, examples, best practices)

## Support

For issues or questions:
- **Using the template**: See the [main README](../../README.md) for template setup instructions
- **Plugin issues**: Check validation output: `/plugin-development:validate`
- **Best practices**: Review `skills/plugin-authoring/best-practices/`
- **Deep audit**: Request deep audit: `/agents plugin-reviewer`
- **Debug mode**: Test with debug mode: `claude --debug`
