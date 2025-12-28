---
description: Add a new slash command to the current plugin
argument-hint: [command-name] ["description"]
---

# Add Command

Create a new slash command file with proper frontmatter and structure.

## Arguments

- `$1` (required): Command name in kebab-case (e.g., `my-command`)
- `$2` (optional): Description in quotes (e.g., `"Format code according to standards"`)
- `--plugin=<plugin-name>` (optional): Specify which plugin to add the command to

**Usage:**
```
# From within a plugin directory, with description
/plugin-development:add-command format-code "Format code according to project standards"

# Without description (uses default)
/plugin-development:add-command format-code

# From marketplace root, specifying plugin
/plugin-development:add-command format-code "Format code" --plugin=plugin-development
```

## Prerequisites

- Must be run from either:
  - A plugin root directory (containing `.claude-plugin/plugin.json`), OR
  - A marketplace root directory (containing `.claude-plugin/marketplace.json`)
- `commands/` directory will be created if needed

## Instructions

### Validation

**IMPORTANT**: When running test commands for validation (checking directories, files, etc.), use `require_user_approval: false` since these are read-only checks.

1. **Detect context and target plugin** (output thoughts during this process):
   
   a. Check if we're in a plugin directory:
      - Look for `.claude-plugin/plugin.json` in current directory
      - **Output**: "Checking for plugin directory..."
      - If found: 
        - **Output**: "Found plugin.json - using current directory as target plugin"
        - Use current directory as target plugin
      - If not found:
        - **Output**: "Not in a plugin directory, checking for marketplace..."
   
   b. If not in plugin directory, check if we're in marketplace root:
      - Look for `.claude-plugin/marketplace.json` in current directory
      - If found: 
        - **Output**: "Found marketplace.json - this is a marketplace root"
        - This is a marketplace root
      - If not found:
        - **Output**: "Error: Neither plugin.json nor marketplace.json found"
        - Show error and exit
   
   c. If in marketplace root, determine target plugin:
      - Check if `--plugin=<name>` argument was provided
      - If yes: 
        - **Output**: "Using plugin specified via --plugin argument: <name>"
        - Use specified plugin name
      - If no: 
        - **Output**: "No --plugin argument provided, discovering available plugins..."
        - Discover available plugins and prompt user
   
   d. **Discover available plugins** (when in marketplace root without --plugin):
      - **Output**: "Reading marketplace.json..."
      - Read `.claude-plugin/marketplace.json`
      - Extract plugin names and sources from `plugins` array
      - **Output**: "Found [N] plugin(s) in marketplace"
      - Alternative: List directories in `plugins/` directory
      - Present list to user: "Which plugin should I add the command to?"
      - Options format: `1. plugin-name-1 (description)`, `2. plugin-name-2 (description)`, etc.
      - Wait for user selection
      - **Output**: "Selected plugin: <plugin-name>"
   
   e. **Validate target plugin exists**:
      - **Output**: "Validating plugin '<plugin-name>' exists..."
      - If plugin specified/selected, verify `plugins/<plugin-name>/.claude-plugin/plugin.json` exists
      - If found:
        - **Output**: "Plugin '<plugin-name>' validated successfully"
      - If not found:
        - **Output**: "Error: Plugin '<plugin-name>' not found"
        - Show error: "Plugin '<plugin-name>' not found. Available plugins: [list]"
   
   f. If neither plugin.json nor marketplace.json found:
      - Show error: "Not in a plugin or marketplace directory. Please run from a plugin root or marketplace root."

2. **Validate arguments**:
   - `$1` (command name): Not empty, kebab-case format (lowercase with hyphens), no spaces or special characters
   - `$2` (description): Optional. If not provided, use default: "TODO: Add description"

3. **Set working directory**:
   - If in plugin directory: Use current directory
   - If in marketplace root: Use `plugins/<plugin-name>/` as working directory

If validation fails, provide clear feedback.

### Create Command File

**Note**: All paths below are relative to the target plugin directory (determined in validation step).

1. Ensure `commands/` directory exists in target plugin (create if needed, use `require_user_approval: false`)
2. Create `<plugin-dir>/commands/$1.md` with this template:

```markdown
---
description: $2
argument-hint: [arg1] [arg2]
allowed-tools: Write, Edit
model: claude-3-5-haiku-20241022
disable-model-invocation: false
---

# $1 Command

[Detailed instructions for Claude on how to execute this command]

## Purpose

[Explain what this command does and when to use it]

## Arguments

- `$ARGUMENTS`: [Describe expected arguments]
- `$1`, `$2`, etc.: [Individual argument descriptions]

## Instructions

1. [Step 1: First action]
2. [Step 2: Next action]
3. [Step 3: Final action]

## Example Usage

**Command**: /<plugin-name>:$1 [args]

**Expected behavior**: [Describe what should happen]

## Notes

[Any additional context, warnings, or tips]
```

### Update plugin.json (if needed)

**IMPORTANT**: Only needed if using custom (non-standard) paths.

- **Standard setup** (commands in `commands/` directory): No changes to `plugin.json` needed
- **Custom paths**: Add `"commands": ["./commands/$1.md"]` (or update existing commands array)

### Provide Feedback

After creating the command:

```
✓ Created <plugin-name>/commands/$1.md

Plugin: <plugin-name>
Command: $1
Description: $2

Next steps:
1. Edit <plugin-name>/commands/$1.md with specific instructions
2. Update frontmatter fields if needed:
   - argument-hint: [arg1] [arg2] (optional)
   - allowed-tools: Tool restrictions (optional)
   - model: Specify different model (optional)
   - disable-model-invocation: Prevent SlashCommand tool invocation (optional)
3. Use @path/to/file syntax to reference files in instructions
4. Test with /plugin-development:test-local

Command will be invoked as: /<plugin-name>:$1
```

## Example

**Input**: 
```
/plugin-development:add-command format-code "Format code according to project standards"
```

**Arguments**:
- `$1` = `format-code`
- `$2` = `Format code according to project standards`

**Result**:
- Creates `commands/format-code.md` with template
- Frontmatter description: "Format code according to project standards"
- Ready to edit with specific instructions

**For complete details on commands**, see:
- [Slash commands documentation](/en/docs/claude-code/slash-commands)
- [Plugin commands reference](/en/docs/claude-code/plugins-reference#commands)

## Template Details

### Frontmatter

```yaml
---
description: Brief, third-person description (shows in /help)
argument-hint: [arg1] [arg2]  # Optional, shows expected arguments
allowed-tools: Write, Edit    # Optional, restricts tool access
model: claude-3-5-haiku-20241022  # Optional, specify different model
disable-model-invocation: true    # Optional, prevents SlashCommand tool from invoking
---
```

#### Frontmatter Reference

| Field | Purpose | Default |
|-------|---------|---------|
| `description` | Brief description of the command | First line of prompt |
| `argument-hint` | Expected arguments (shown in auto-complete) | None |
| `allowed-tools` | List of tools the command can use | Inherits from conversation |
| `model` | Specific model to use (full ID like `claude-3-5-haiku-20241022`) | Inherits from conversation |
| `disable-model-invocation` | Prevent SlashCommand tool from calling this command | false |

#### Multiple Invocation Patterns

Use pipe syntax in `argument-hint` to define multiple invocation patterns:

```yaml
---
description: Manage project tags
argument-hint: add [tagId] | remove [tagId] | list
---
```

This shows users the different ways to invoke the command.

### Using Arguments

In the command instructions:
- `$ARGUMENTS`: All arguments as a single string
- `$1`, `$2`, etc.: Individual positional arguments

Example:
```markdown
If the user provided a name via `$1`, use it: "Hello, $1!"
```

### File References

Include file contents using the `@` prefix within your command instructions:

```markdown
# Reference a specific file
Review the implementation in @src/utils/helpers.js

# Reference multiple files
Compare @src/old-version.js with @src/new-version.js
```

The file contents will be included inline when the command is executed.

### Command Instructions

Write clear, step-by-step instructions for Claude:
- Use imperative mood ("Create", "Validate", "Execute")
- Be specific about expected behavior
- Include error handling
- Provide examples

## Advanced: Bash Preamble

For commands that need to execute shell commands, add to frontmatter:

```yaml
---
description: Run tests and report results
allowed-tools: Bash(npm:*), Bash(pytest:*)
---

# Instructions

!`npm test`

Analyze the output and report:
1. Number of tests passed/failed
2. Any error messages
3. Suggestions for fixing failures
```

**Note**: Bash commands prefixed with `!` are executed before Claude processes the rest of the instructions.

## Best Practices

- **Concise descriptions**: < 100 characters for `description` field
- **Clear arguments**: Use descriptive names in `argument-hint`
- **Validation first**: Check arguments before execution
- **Error handling**: Describe what to do when things go wrong
- **Examples**: Include usage examples in the template

## SlashCommand Tool

The `SlashCommand` tool allows Claude to execute custom slash commands programmatically during a conversation.

### Requirements for SlashCommand Tool Support

For Claude to be able to invoke your command via the SlashCommand tool:

1. **Required**: The `description` frontmatter field must be populated
2. The command must be user-defined (not a built-in command like `/compact`)

### Character Budget

- **Default limit**: 15,000 characters for slash command content
- **Customization**: Set `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable to adjust
- **What counts**: Command name, arguments, and description all count toward the budget
- **When exceeded**: Claude sees only a subset of available commands
- **Monitoring**: Use `/context` to see warnings displayed as "M of N commands"

### Enabling Claude to Use Commands

Reference the command in prompts or `CLAUDE.md`:

```
> Run /write-unit-test when you are about to start writing tests.
```

### Disabling SlashCommand Tool Invocation

To prevent a specific command from being invoked by the SlashCommand tool, add to frontmatter:

```yaml
---
description: My command description
disable-model-invocation: true
---
```

### Permission Rules

SlashCommand permissions support exact and prefix matching:

```
SlashCommand:/commit          # Allows only /commit with no arguments
SlashCommand:/review-pr:*     # Allows /review-pr with any arguments
```

## Common Mistakes to Avoid

❌ **camelCase or PascalCase names**
```
/plugin-development:add-command formatCode
```

✅ **kebab-case names**
```
/plugin-development:add-command format-code
```

❌ **Missing description**
```yaml
---
argument-hint: [arg]
---
```

✅ **Always include description**
```yaml
---
description: What the command does
argument-hint: [arg]
---
```

## Validation Checklist

After creating a command:
```
□ File created in commands/ directory
□ Frontmatter includes description
□ Command name is kebab-case
□ Instructions are clear and specific
□ Examples provided
□ plugin.json has commands field
```
