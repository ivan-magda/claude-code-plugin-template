---
name: agent-name
description: What this agent specializes in and when to invoke it (third person). Include "PROACTIVELY" for auto-delegation.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: default
skills: skill1, skill2
---

<!--
AGENT FRONTMATTER REFERENCE (from official Anthropic docs):

REQUIRED FIELDS:
- name: Unique identifier (lowercase letters and hyphens, e.g., code-reviewer)
- description: When to invoke this agent and its purpose

OPTIONAL FIELDS:
- tools: Comma-separated list of tools (e.g., "Read, Grep, Glob, Bash")
         If omitted, inherits all tools from main thread including MCP tools
- model: Which AI model to use
         Valid values: sonnet, opus, haiku, inherit (or omit for default)
         Use 'inherit' to match main conversation's model
- permissionMode: How the agent handles permission requests
         Valid values: default, acceptEdits, bypassPermissions, plan
- skills: Comma-separated list of skills to auto-load (agents don't inherit skills)

NOTE: The 'capabilities' field is NOT in official docs and may be deprecated.
      Use 'tools' for agents (not 'allowed-tools' which is for skills).
-->

# Agent Name

[Brief introduction to the agent's purpose and specialization]

## What This Agent Does

[Detailed description of the agent's responsibilities]

## Capabilities

1. **Capability 1**: [Description]
2. **Capability 2**: [Description]
3. **Capability 3**: [Description]

## When to Use This Agent

Invoke this agent when:
- [Scenario 1]
- [Scenario 2]
- [Scenario 3]

## How It Proceeds

[Step-by-step workflow the agent follows]

1. **Analyze**: [What it reads/examines]
2. **Evaluate**: [How it assesses the situation]
3. **Report**: [What it returns to the main conversation]

## Output Format

[What kind of report or recommendations the agent provides]

Example:
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (nice to have)
- Summary of findings

## Tool Access

[What tools this agent has access to and why]

## Notes

[Any limitations, constraints, or important considerations]
