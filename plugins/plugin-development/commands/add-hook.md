---
description: Add a hook configuration to automate plugin behavior at lifecycle events
argument-hint: [event-type] [matcher-pattern]
---

# Add Hook

Add or update hooks.json with a new hook configuration for automated behavior.

## Arguments

- `$1` (required): Event type (`PreToolUse`, `PostToolUse`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `Notification`, `Stop`, `SubagentStop`, or `PreCompact`)
- `$2` (optional): Matcher pattern (e.g., `Write|Edit` or `.*`)
- `--plugin=<plugin-name>` (optional): Specify which plugin to add the hook to

**Usage:**
```
# From within a plugin directory
/plugin-development:add-hook PreToolUse "Write|Edit"

# From marketplace root, specifying plugin
/plugin-development:add-hook PreToolUse "Write|Edit" --plugin=plugin-development
```

## Template Variables

When generating hook configurations and scripts:
- `$1`: Event type
- `$2`: Matcher pattern (or default based on event type)
- `${CLAUDE_PLUGIN_ROOT}`: Plugin root path (use in all hook commands)

## Prerequisites

- Must be run from either:
  - A plugin root directory (containing `.claude-plugin/plugin.json`), OR
  - A marketplace root directory (containing `.claude-plugin/marketplace.json`)
- `hooks/` directory will be created if needed

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
      - Present list to user: "Which plugin should I add the hook to?"
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

2. **Validate event type**:
   - Must be one of: `PreToolUse`, `PostToolUse`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `Notification`, `Stop`, `SubagentStop`, `PreCompact`

3. **If no matcher provided, use sensible default based on event type**

4. **Set working directory**:
   - If in plugin directory: Use current directory
   - If in marketplace root: Use `plugins/<plugin-name>/` as working directory

### Event Types & Default Matchers

- **PreToolUse**: Default matcher `Write|Edit` (validation before writes)
- **PostToolUse**: Default matcher `Write|Edit` (formatting after writes)
- **SessionStart**: Default matcher `startup` (also supports: `resume`, `clear`, `compact`)
- **SessionEnd**: No matcher (triggers on session end with reason: `clear`, `logout`, `prompt_input_exit`, `other`)
- **UserPromptSubmit**: Default matcher `.*` (all prompts)
- **Notification**: No matcher (triggers on all notifications)
- **Stop**: No matcher (triggers when main agent stops)
- **SubagentStop**: No matcher (triggers when subagent stops)
- **PreCompact**: Default matcher `manual` (also supports: `auto`)

### Create or Update hooks.json

**Note**: All paths below are relative to the target plugin directory (determined in validation step).

1. Ensure `<plugin-dir>/hooks/` directory exists (use `require_user_approval: false`)
2. If `<plugin-dir>/hooks/hooks.json` doesn't exist, create it with this structure:

```json
{
  "description": "Plugin automation hooks",
  "hooks": {}
}
```

3. Add the new hook configuration based on event type:

#### PreToolUse Example

```json
{
  "description": "Plugin automation hooks",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "$2 or default",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

#### PostToolUse Example

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "$2 or default",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

#### SessionStart Example

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "$2 or 'startup'",
        "hooks": [
          {
            "type": "command",
            "command": "echo '✓ Plugin loaded'"
          }
        ]
      }
    ]
  }
}
```

### Create Hook Script (if needed)

If the event is PreToolUse or PostToolUse, create a corresponding script:

1. Ensure `<plugin-dir>/scripts/` directory exists (use `require_user_approval: false`)
2. For PreToolUse, create `<plugin-dir>/scripts/validate.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Validation logic here
# Exit 0: allow
# Exit 2: block (with stderr message to Claude)
# Exit other: warning

echo "Validation passed"
exit 0
```

3. For PostToolUse, create `<plugin-dir>/scripts/format.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Formatting logic here
# Always exits 0 for non-blocking

echo "Formatting complete"
exit 0
```

4. Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Update plugin.json

**IMPORTANT**: Only needed if using custom (non-standard) paths.

- **Standard setup** (hooks at `hooks/hooks.json`): No changes to `plugin.json` needed
- **Custom path**: Add `"hooks": "./custom/path/hooks.json"`

For standard setup:
```json
{
  "name": "my-plugin"
}
```

### Provide Feedback

After adding the hook:

```
✓ Added $1 hook to <plugin-name>/hooks/hooks.json
✓ Matcher: $2 (or default)
✓ Created script: <plugin-name>/scripts/<script-name>.sh (if applicable)

Plugin: <plugin-name>
Hook configuration:
- Event: $1
- Matcher: $2
- Script: ${CLAUDE_PLUGIN_ROOT}/scripts/<script-name>.sh

Next steps:
1. Edit <plugin-name>/hooks/hooks.json to customize timeout or command
2. Edit <plugin-name>/scripts/<script-name>.sh with your logic
3. Test the hook:
   - Install plugin with /plugin-development:test-local
   - Trigger the event (e.g., use Write tool for PreToolUse)
4. Debug with: claude --debug

Exit codes for PreToolUse:
- 0: Allow operation
- 2: Block operation (stderr shown to Claude)
- Other: Warning (non-blocking)

Exit codes for UserPromptSubmit:
- 0: Allow prompt (stdout added as context)
- 2: Block prompt (stderr shown to user, prompt erased)
- Other: Warning (non-blocking)

Exit codes for Stop/SubagentStop:
- 0: Allow stop
- 2: Block stop, continue execution (stderr shown to Claude)
- Other: Warning (allows stop)

Exit codes for PostToolUse, SessionStart, SessionEnd, Notification, PreCompact:
- All non-blocking (informational)
```

## Example Usage

**Input**: `/plugin-development:add-hook PreToolUse "Write|Edit"`

**Result**:
- Creates or updates `hooks/hooks.json`
- Adds PreToolUse hook with Write|Edit matcher
- Creates `scripts/validate.sh`
- Makes script executable
- Provides usage instructions

**For complete details on hooks**, see:
- [Hooks reference documentation](/en/docs/claude-code/hooks)
- [Plugin hooks reference](/en/docs/claude-code/plugins-reference#hooks)

## Hook Event Details

| Event | Purpose | Can Block | Common Use Cases | Default Matcher |
|-------|---------|-----------|------------------|-----------------|
| **PreToolUse** | Validate before execution | Yes (exit 2) | Validate structure, check permissions | `Write\|Edit` |
| **PostToolUse** | React after execution | Partial* | Format files, run linters, update metadata | `Write\|Edit` |
| **SessionStart** | Setup at session start | No | Welcome message, check environment, init | `startup` |
| **SessionEnd** | Cleanup at session end | No | Save state, log statistics, cleanup | N/A (no matcher) |
| **UserPromptSubmit** | Validate/enhance prompts | Yes (exit 2) | Inject context, validate prompts, block sensitive | `.*` |
| **Notification** | React to notifications | No | Send alerts, log notifications | N/A (no matcher) |
| **Stop** | Control agent stoppage | Yes (exit 2) | Continue with tasks, validate completion | N/A (no matcher) |
| **SubagentStop** | Control subagent stoppage | Yes (exit 2) | Continue subagent, validate subagent results | N/A (no matcher) |
| **PreCompact** | Before context compact | No | Save state, log compact trigger | `manual` or `auto` |

\* PostToolUse can't prevent the tool (already ran) but can provide feedback to Claude with `"decision": "block"`

**Example hook structure**:
```json
{
  "matcher": "Write|Edit",
  "hooks": [{
    "type": "command",
    "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh",
    "timeout": 30
  }]
}
```

## Matcher Patterns

Matchers use **regex patterns**:
- `Write`: Only Write tool
- `Write|Edit`: Write or Edit
- `Bash.*`: Bash with any arguments
- `.*`: All tools
- `Read|Grep|Glob`: Read operations

## Script Template: Validation (PreToolUse)

```bash
#!/usr/bin/env bash
set -euo pipefail

ERRS=()

# Validation checks
[ -f "required-file.txt" ] || ERRS+=("Missing required-file.txt")
[ -d "required-dir" ] || ERRS+=("Missing required-dir/")

# If errors, block with exit 2
if [ "${#ERRS[@]}" -gt 0 ]; then
  printf "❌ Validation failed:\n" 1>&2
  printf "  %s\n" "${ERRS[@]}" 1>&2
  exit 2  # Block the operation
fi

# Success
echo "✓ Validation passed"
exit 0
```

## Script Template: Formatting (PostToolUse)

```bash
#!/usr/bin/env bash
set -euo pipefail

# Format files (non-blocking)
# Example: run prettier, black, rustfmt, etc.

if command -v prettier &> /dev/null; then
  prettier --write "**/*.{js,json,md}" 2>/dev/null || true
fi

echo "✓ Formatting complete"
exit 0
```

## Environment Variables

Available in hook scripts:

- `${CLAUDE_PLUGIN_ROOT}`: Absolute path to plugin root
- `$CLAUDE_PROJECT_DIR`: Project root directory (absolute path)
- `$CLAUDE_ENV_FILE`: File path for persisting environment variables (SessionStart hooks only)
- `$CLAUDE_CODE_REMOTE`: Set to "true" in web environment, unset in CLI
- All standard environment variables

Always use `${CLAUDE_PLUGIN_ROOT}` for portable paths in plugins.

## Best Practices & Common Mistakes

### ✅ Do This
- **Use ${CLAUDE_PLUGIN_ROOT}**: Portable script paths
- **Set timeouts**: 10-30 seconds typical, 300+ for slow ops like `npm install`
- **Fast scripts**: Keep runtime < 1 second when possible
- **Exit code 2 to block**: Only in PreToolUse for validation failures
- **Clear error messages**: Helpful stderr output
- **Make executable**: `chmod +x scripts/*.sh`

### ❌ Avoid This
- **Absolute paths**: `/Users/you/plugin/scripts/` (use `${CLAUDE_PLUGIN_ROOT}` instead)
- **Missing timeouts**: Slow operations without timeout values
- **Non-executable scripts**: Forgot to `chmod +x`

## Debugging Hooks

### Use debug mode

```bash
claude --debug
```

This shows:
- Hook registration
- Hook execution
- Exit codes
- Stdout/stderr output

### Test scripts directly

```bash
./scripts/validate.sh
echo $?  # Check exit code
```

### Check hook configuration

```bash
cat hooks/hooks.json | jq .
```

## Validation Checklist

After adding a hook:
```
□ hooks/hooks.json created/updated
□ Hook event is valid (PreToolUse, etc.)
□ Matcher pattern is appropriate
□ Script created (if needed)
□ Script is executable (chmod +x)
□ Script uses ${CLAUDE_PLUGIN_ROOT}
□ Timeout set for long operations
□ plugin.json updated (only if using custom paths)
□ Tested with /plugin-development:test-local
```
