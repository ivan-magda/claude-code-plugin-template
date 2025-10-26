---
description: Create a local dev marketplace and install the plugin for testing
---

# Test Plugin Locally

Set up a development marketplace for local testing and install the current plugin.

## Prerequisites

- Must be run from a plugin root directory (containing `.claude-plugin/plugin.json`)
- Plugin should pass validation (run `/plugin-development:validate` first)

## Instructions

### What This Command Does

1. Creates a sibling `dev-marketplace/` directory (if it doesn't exist)
2. Generates `dev-marketplace/.claude-plugin/marketplace.json` pointing to your plugin
3. Provides instructions for:
   - Adding the marketplace to Claude Code
   - Installing the plugin
   - Testing workflow (edit → reinstall → test loop)

### Step 1: Read Plugin Metadata

Read `.claude-plugin/plugin.json` to get:
- Plugin name
- Plugin description
- Plugin version

### Step 2: Determine Plugin Path

Get the current plugin directory path. Common patterns:
- Current working directory
- From the location of plugin.json

The marketplace source path should be relative from marketplace to plugin:
- If plugin is at `/path/to/my-plugin/`
- Dev marketplace at `/path/to/dev-marketplace/`
- Source path: `../my-plugin`

### Step 3: Create Dev Marketplace Structure

1. Create directory: `../dev-marketplace/.claude-plugin/`
2. Create `marketplace.json` at `../dev-marketplace/.claude-plugin/marketplace.json`

### Step 4: Generate marketplace.json

Create with this structure:

```json
{
  "name": "dev-marketplace",
  "owner": {
    "name": "Developer"
  },
  "metadata": {
    "description": "Local development marketplace for testing plugins",
    "version": "0.1.0"
  },
  "plugins": [
    {
      "name": "<plugin-name-from-plugin.json>",
      "description": "<description-from-plugin.json>",
      "version": "<version-from-plugin.json>",
      "source": "../<plugin-directory-name>"
    }
  ]
}
```

**Important**: The `source` path is relative from marketplace to plugin directory.

### Step 5: Provide Testing Instructions

Display clear instructions for the user:

```
✅ Dev marketplace created at ../dev-marketplace/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Testing Workflow

1️⃣  ADD MARKETPLACE (First time only)
   /plugin marketplace add ../dev-marketplace

   Verify:
   /plugin marketplace list

2️⃣  INSTALL PLUGIN
   /plugin install <plugin-name>@dev-marketplace

   Verify:
   /help
   (Your commands should appear)

3️⃣  TEST COMMANDS
   /<plugin-name>:<command-name> [args]

   Examples:
   /<plugin-name>:command1
   /<plugin-name>:command2 arg

4️⃣  ITERATION LOOP (After making changes)

   a. Edit your plugin files
   b. Validate: /plugin-development:validate
   c. Uninstall: /plugin uninstall <plugin-name>@dev-marketplace
   d. Reinstall: /plugin install <plugin-name>@dev-marketplace
   e. Test again: /<plugin-name>:command-name

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 Tips

- Must uninstall/reinstall to pick up changes
- Use /plugin-development:validate before each test
- Check /agents to see if your agents appear
- Use claude --debug to see plugin loading details
- Run hooks/scripts directly to test them: ./scripts/validate.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Marketplace Location
Path: ../dev-marketplace/
Config: ../dev-marketplace/.claude-plugin/marketplace.json

Plugin reference:
- Name: <plugin-name>
- Source: ../<plugin-directory>
```

## Example

**Input**: `/plugin-development:test-local`

(Run from `/path/to/my-plugin/`)

**Output**:
```
✅ Dev marketplace created at ../dev-marketplace/

Registered plugin: my-plugin
Source path: ../my-plugin

Next: /plugin marketplace add ../dev-marketplace
Then: /plugin install my-plugin@dev-marketplace
```

## Handling Existing Marketplace

If `../dev-marketplace/.claude-plugin/marketplace.json` already exists:

### Option 1: Update Existing (Recommended)

1. Read existing marketplace.json
2. Check if current plugin already registered
3. If yes: Update the entry
4. If no: Append to plugins array
5. Write back to file

### Option 2: Ask User

```
⚠️  Dev marketplace already exists at ../dev-marketplace/

Current plugins registered:
- plugin-a
- plugin-b

Would you like to:
1. Add <current-plugin> to existing marketplace
2. Replace existing marketplace.json
3. Cancel

(Auto-select option 1 for smooth workflow)
```

## Marketplace Structure Reference

```
dev-marketplace/
└── .claude-plugin/
    └── marketplace.json
```

**marketplace.json**:
```json
{
  "name": "dev-marketplace",
  "owner": {
    "name": "Developer"
  },
  "metadata": {
    "description": "Local development marketplace",
    "version": "0.1.0"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "description": "Plugin description",
      "version": "1.0.0",
      "source": "../plugin-name"
    }
  ]
}
```

## Testing Multiple Plugins

If user has multiple plugins, the dev marketplace can reference them all:

```json
{
  "plugins": [
    {
      "name": "plugin-one",
      "source": "../plugin-one"
    },
    {
      "name": "plugin-two",
      "source": "../plugin-two"
    }
  ]
}
```

Install separately:
```
/plugin install plugin-one@dev-marketplace
/plugin install plugin-two@dev-marketplace
```

## Troubleshooting Tips

Include these in the output:

```
🔧 Troubleshooting

Plugin not loading?
□ Check /plugin list to verify installation
□ Verify plugin.json paths are relative (./commands/)
□ Run /plugin-development:validate

Commands not showing?
□ Check /help for command list
□ Verify commands/ directory has .md files
□ Ensure frontmatter has description field
□ Reinstall the plugin

Skills not triggering?
□ Check SKILL.md frontmatter name matches directory
□ Verify description has clear trigger conditions
□ Skills auto-activate based on context

Hooks not running?
□ Make scripts executable: chmod +x scripts/*.sh
□ Use ${CLAUDE_PLUGIN_ROOT} in hook commands
□ Test script directly: ./scripts/script-name.sh
□ Check claude --debug for hook execution logs
```

## Advanced: Custom Marketplace Location

If user wants marketplace elsewhere:

```
You can specify a custom location:
1. Create marketplace structure anywhere
2. Update source paths accordingly
3. Add marketplace: /plugin marketplace add /path/to/marketplace

Example for repo root:
- Plugin: /repo/plugins/my-plugin/
- Marketplace: /repo/dev-marketplace/
- Source path: ../plugins/my-plugin
```

## Validation Before Testing

Remind user to validate:

```
⚡ Quick Check

Before testing, validate your plugin:
/plugin-development:validate

This catches common issues:
- Invalid JSON
- Path errors
- Naming mismatches
- Missing files
```

## Complete Workflow Example

Show a complete example session:

```
📝 Complete Testing Session

# Initial setup (once)
$ cd my-plugin/
$ /plugin-development:validate
✅ Validation passed

$ /plugin-development:test-local
✅ Dev marketplace created

$ /plugin marketplace add ../dev-marketplace
✅ Marketplace added

$ /plugin install my-plugin@dev-marketplace
✅ Plugin installed

$ /help
Commands:
  /my-plugin:command1 - Does something
  /my-plugin:command2 - Does another thing

$ /my-plugin:command1
[Command executes successfully]

# After making changes
$ [edit files]

$ /plugin-development:validate
✅ Validation passed

$ /plugin uninstall my-plugin@dev-marketplace
✅ Plugin uninstalled

$ /plugin install my-plugin@dev-marketplace
✅ Plugin installed

$ /my-plugin:command1
[Tests updated functionality]
```

## Notes

- The dev marketplace is for **local testing only**
- Do not commit `dev-marketplace/` to your plugin repository
- For team distribution, create a proper marketplace repository
- The source path must be relative from marketplace to plugin
- Must uninstall/reinstall to pick up plugin changes

## After Testing

When ready for team distribution:

```
✅ Plugin tested successfully!

Ready for team distribution:
1. Create a proper marketplace repository
2. Add your plugin to the marketplace
3. Commit and push to GitHub
4. Team installs via: /plugin marketplace add your-org/marketplace-repo
5. Or configure in .claude/settings.json for auto-install
```

## Best Practices

1. **Validate first**: Always run `/plugin-development:validate` before testing
2. **Clean reinstalls**: Uninstall fully before reinstalling
3. **Test all components**: Commands, skills, agents, hooks
4. **Incremental changes**: Test small changes frequently
5. **Debug mode**: Use `claude --debug` when troubleshooting
6. **Direct testing**: Test hook scripts directly before installing

## Related Commands

- `/plugin-development:validate` - Validate before testing
- `/plugin-development:init` - Scaffold new plugin
- `/plugin marketplace list` - See available marketplaces
- `/plugin list` - See installed plugins
- `/help` - See available commands
