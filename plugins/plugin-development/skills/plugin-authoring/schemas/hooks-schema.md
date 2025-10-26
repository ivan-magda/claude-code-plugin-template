# Hooks Schema

Hooks allow you to run commands at specific lifecycle events. Define them in `hooks/hooks.json`.

## Location

`hooks/hooks.json` (at plugin root, referenced in `plugin.json`)

## Structure

```json
{
  "description": "Optional description of what these hooks do",
  "hooks": {
    "EventName": [
      {
        "matcher": "pattern",
        "hooks": [
          {
            "type": "command",
            "command": "path/to/script.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## Event Types

### PreToolUse

Runs **before** Claude uses a tool. Can block tool execution.

```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
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
```

**Matcher**: Regex pattern matching tool names (e.g., `Write`, `Read`, `Bash.*`)

**Exit codes**:
- `0`: Allow (stdout visible to Claude)
- `2`: **Block** (stderr shown to Claude as feedback)
- Other: Warning (non-blocking)

### PostToolUse

Runs **after** a tool completes. Cannot block.

```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
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
```

### SessionStart

Runs when Claude Code session starts.

```json
{
  "SessionStart": [
    {
      "matcher": "startup",
      "hooks": [
        {
          "type": "command",
          "command": "echo 'Plugin loaded!'"
        }
      ]
    }
  ]
}
```

**Note**: SessionStart stdout is only visible if it starts with special markers (see docs).

### UserPromptSubmit

Runs when user submits a prompt (experimental).

```json
{
  "UserPromptSubmit": [
    {
      "matcher": ".*",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/context-injector.sh"
        }
      ]
    }
  ]
}
```

## Environment Variables

Available in hook commands:

- `${CLAUDE_PLUGIN_ROOT}`: Absolute path to plugin root
- `${CLAUDE_WORKING_DIR}`: Current working directory
- Standard env vars from shell

## Timeouts

- Default: No timeout
- Recommended: 10-30 seconds for validation
- Max: Keep under 60 seconds for good UX

## Common Patterns

### Validation Hook (Blocking)

```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
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
```

**validate.sh**:
```bash
#!/usr/bin/env bash
if [ validation_fails ]; then
  echo "Error: validation failed" >&2
  exit 2  # Block the tool
fi
exit 0  # Allow
```

### Formatting Hook (Non-blocking)

```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
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
```

### Startup Message

```json
{
  "SessionStart": [
    {
      "matcher": "startup",
      "hooks": [
        {
          "type": "command",
          "command": "echo '✓ My Plugin loaded'"
        }
      ]
    }
  ]
}
```

## Best Practices

- **Use `${CLAUDE_PLUGIN_ROOT}`** for portable paths
- **Set timeouts** to prevent hanging
- **Exit code 2** to block (PreToolUse only)
- **Keep scripts fast** (< 1 second ideally)
- **Make scripts executable** (`chmod +x`)
- **Test hooks** before distributing

## Common Mistakes

❌ **Absolute paths** (not portable)
```json
{
  "command": "/Users/you/plugin/scripts/validate.sh"
}
```

✅ **Plugin-relative paths**
```json
{
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"
}
```

❌ **No timeout** on slow operations
```json
{
  "command": "npm install",
  // Missing timeout!
}
```

✅ **Set appropriate timeout**
```json
{
  "command": "npm install",
  "timeout": 300000
}
```

## Debugging

Use `claude --debug` to see:
- Hook registration
- Hook execution timing
- Exit codes and output
- Blocking decisions
