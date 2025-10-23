---
description: Greet the user with a friendly, personalized message
argument-hint: [name]
---

# Hello Command

Greet the user warmly and enthusiastically. This is a demonstration command from the Hello World plugin that shows how Claude Code plugins work.

## Instructions

1. If the user provided a name in `$ARGUMENTS`, greet them personally (e.g., "Hello, Alice! 👋")
2. If no name was provided, use a friendly generic greeting (e.g., "Hello, there! 👋")
3. After the greeting, briefly explain that this is an example plugin demonstrating Claude Code's plugin system
4. Mention that plugins can provide custom commands, agents, hooks, Skills, and MCP servers
5. Keep the tone warm, friendly, and encouraging

## Example responses

**With name** (`/hello World`):
```
Hello, World! 👋

This is a sample command from the Hello World plugin, demonstrating how Claude Code plugins work. Plugins can add custom commands, agents, hooks, Skills, and MCP servers to extend Claude Code's capabilities!
```

**Without name** (`/hello`):
```
Hello, there! 👋

This is a sample command from the Hello World plugin, demonstrating how Claude Code plugins work. Plugins can add custom commands, agents, hooks, Skills, and MCP servers to extend Claude Code's capabilities!
```
