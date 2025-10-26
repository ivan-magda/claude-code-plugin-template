---
description: Add a new sub-agent to the current plugin for specialized tasks
argument-hint: [agent-name] ["description"]
---

# Add Agent

Create a new sub-agent file with proper frontmatter and structure.

## Arguments

- `$1` (required): Agent name in kebab-case (e.g., `code-reviewer`)
- `$2` (optional): Description in quotes (e.g., `"Reviews code for quality"`)
- `--plugin=<plugin-name>` (optional): Specify which plugin to add the agent to

**Usage:**
```
# From within a plugin directory, with description
/plugin-development:add-agent code-reviewer "Reviews code for quality, security, and best practices"

# Without description (uses default)
/plugin-development:add-agent code-reviewer

# From marketplace root, specifying plugin
/plugin-development:add-agent code-reviewer "Reviews code for quality, security, and best practices" --plugin=plugin-development
```

## Prerequisites

- Must be run from either:
  - A plugin root directory (containing `.claude-plugin/plugin.json`), OR
  - A marketplace root directory (containing `.claude-plugin/marketplace.json`)
- `agents/` directory will be created if needed

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
      - Present list to user: "Which plugin should I add the agent to?"
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
   - `$1` (agent name): Not empty, kebab-case format (lowercase with hyphens), no spaces or special characters
   - `$2` (description): Optional. If not provided, use default: "Specialized agent for $1 tasks"

3. **Set working directory**:
   - If in plugin directory: Use current directory
   - If in marketplace root: Use `plugins/<plugin-name>/` as working directory

### Create Agent File

**Note**: All paths below are relative to the target plugin directory (determined in validation step).

1. Ensure `agents/` directory exists in target plugin:
   - Check if `<plugin-dir>/agents/` directory exists
   - If it doesn't exist, create it (use `require_user_approval: false` for directory creation)
2. Create `<plugin-dir>/agents/$1.md` with this template:

```markdown
---
description: $2
capabilities: ["capability-1", "capability-2", "capability-3"]
---

# $1 Agent

[Brief introduction explaining the agent's purpose and specialization]

## Purpose

[Detailed description of what this agent does and why it exists]

## What This Agent Does

This agent specializes in:
- [Specialization 1]
- [Specialization 2]
- [Specialization 3]

## Capabilities

1. **Capability 1**: [Description of first capability]
2. **Capability 2**: [Description of second capability]
3. **Capability 3**: [Description of third capability]

## When to Use This Agent

Invoke this agent when:
- [Scenario 1: Complex multi-file analysis needed]
- [Scenario 2: Deep domain expertise required]
- [Scenario 3: Task needs separate context window]

**Do not use** for:
- [What this agent doesn't handle]
- [Tasks better suited for commands or Skills]

## How It Proceeds

The agent follows this workflow:

1. **Gather Context**: [What files/information it reads]
2. **Analyze**: [How it evaluates the situation]
3. **Identify Issues**: [What it looks for]
4. **Formulate Recommendations**: [What guidance it provides]
5. **Report Back**: [What it returns to main conversation]

## Output Format

The agent returns a structured report:

### Critical Issues
- [Issues that must be fixed]

### Warnings
- [Issues that should be fixed]

### Suggestions
- [Nice-to-have improvements]

### Summary
- [Overall assessment and next steps]

## Tool Access

This agent has access to:
- Read: For examining files
- Grep: For searching content
- Glob: For finding files
- [Other tools as needed]

It does **not** modify files directly; instead, it proposes changes for the main conversation to execute.

## Example Invocation

**From main conversation**:
```
/agents $1
```

or via Task tool:
```
Use the $1 agent to [specific task]
```

## Notes

- Agents operate in a **separate context window**
- Results are returned as a single message
- Use for complex, multi-step analysis tasks
- Keep scope focused to 1-3 specific capabilities
```

### Update plugin.json (if needed)

**IMPORTANT**: Only needed if using custom (non-standard) paths.

- **Standard setup** (agents in `agents/` directory): No changes to `plugin.json` needed
- **Custom paths**: Add `"agents": ["./agents/$1.md"]` (or update existing agents array)

### Provide Feedback

After creating the agent:

```
✓ Created <plugin-name>/agents/$1.md

Plugin: <plugin-name>
Agent: $1
Description: $2

Next steps:
1. Edit <plugin-name>/agents/$1.md with specific instructions
2. Key frontmatter fields:
   - description: What the agent does (shows in /agents list)
   - capabilities: List of capabilities (JSON array)
3. Define clear workflow steps
4. Specify what the agent returns
5. Test with /plugin-development:test-local

Agent will be invoked as: /agents $1
Or via Task tool in main conversation.
```

## Examples

### Example 1: From Plugin Directory

**Context**: Currently in `/path/to/marketplace/plugins/plugin-development/`

**Input**: 
```
/plugin-development:add-agent code-reviewer "Reviews code for quality, security, and best practices"
```

**Arguments**:
- `$1` = `code-reviewer`
- `$2` = `Reviews code for quality, security, and best practices`

**Process**:
1. Detects `.claude-plugin/plugin.json` in current directory
2. Uses current directory as target plugin
3. Creates `agents/` directory if needed
4. Creates `agents/code-reviewer.md`

**Result**:
- Creates `agents/code-reviewer.md` with template
- Frontmatter description: "Reviews code for quality, security, and best practices"
- Ready to customize with specific review criteria

### Example 2: From Marketplace Root with --plugin

**Context**: Currently in `/path/to/marketplace/` (marketplace root)

**Input**: 
```
/plugin-development:add-agent code-reviewer "Reviews code for quality, security, and best practices" --plugin=plugin-development
```

**Process**:
1. Detects `.claude-plugin/marketplace.json` in current directory
2. Extracts `--plugin=plugin-development` from arguments
3. Validates `plugins/plugin-development/.claude-plugin/plugin.json` exists
4. Uses `plugins/plugin-development/` as target
5. Creates `plugins/plugin-development/agents/code-reviewer.md`

**Result**:
- Creates `plugins/plugin-development/agents/code-reviewer.md`
- Agent added to plugin-development plugin

### Example 3: From Marketplace Root without --plugin

**Context**: Currently in `/path/to/marketplace/` (marketplace root)

**Input**: 
```
/plugin-development:add-agent code-reviewer "Reviews code for quality, security, and best practices"
```

**Process**:
1. Detects `.claude-plugin/marketplace.json` in current directory
2. No `--plugin` argument provided
3. Reads marketplace.json and discovers available plugins:
   - `hello-world` - A simple example plugin
   - `plugin-development` - Assist with Claude Code plugin development
4. Prompts user: "Which plugin should I add the agent to?"
   ```
   1. hello-world - A simple example plugin demonstrating basic Claude Code plugin functionality
   2. plugin-development - Assist with Claude Code plugin development: scaffold, validate, review, and team-ready distribution
   ```
5. User selects option 2
6. Uses `plugins/plugin-development/` as target
7. Creates `plugins/plugin-development/agents/code-reviewer.md`

**Result**:
- Creates `plugins/plugin-development/agents/code-reviewer.md`
- Agent added to selected plugin

## Agent Frontmatter

### Required Fields

```yaml
---
description: Third-person description of what this agent does
---
```

### Optional Fields

```yaml
---
description: Agent description
capabilities: ["capability-1", "capability-2"]    # List of what it can do
---
```

**For complete details on agents**, see:
- [Subagents documentation](/en/docs/claude-code/sub-agents)
- [Plugin agents reference](/en/docs/claude-code/plugins-reference#agents)

## Error Handling

### Not in Plugin or Marketplace Directory

**Error**: "Not in a plugin or marketplace directory."

**Solution**: Navigate to either:
- A plugin directory (containing `.claude-plugin/plugin.json`), OR
- A marketplace root (containing `.claude-plugin/marketplace.json`)

### Plugin Not Found

**Error**: "Plugin 'my-plugin' not found. Available plugins: hello-world, plugin-development"

**Solution**: 
- Check plugin name spelling
- Use `--plugin=<correct-name>` with one of the available plugins
- Or navigate to the plugin directory directly

### Invalid Agent Name

**Error**: "Agent name must be in kebab-case format (lowercase with hyphens)"

**Solution**: Use kebab-case format:
- ✅ Good: `code-reviewer`, `security-auditor`, `api-generator`
- ❌ Bad: `CodeReviewer`, `code_reviewer`, `code reviewer`

### Missing Description

**Error**: "Description is required"

**Solution**: Provide description in quotes:
```
/plugin-development:add-agent code-reviewer "Reviews code for quality, security, and best practices"
```

## When to Use Agents vs. Commands vs. Skills

### Use an Agent when:
- Task requires **deep, multi-file analysis**
- Need **separate context window** (complex reasoning)
- Want **detailed, structured report** back
- Task has **multiple steps** that benefit from isolation

### Use a Command when:
- Task is **explicit, one-time action**
- User needs to **trigger on demand**
- Task is **straightforward** with clear inputs/outputs

### Use a Skill when:
- Want **ambient, automatic activation**
- Need **persistent guidance** throughout session
- Task benefits from **progressive disclosure**
- Should trigger based on **context clues**

## Agent Design Best Practices

### 1. Focused Scope

✅ **Good** (focused):
```markdown
# Code Security Auditor

Specializes in security analysis:
- SQL injection vulnerabilities
- XSS vulnerabilities
- Authentication issues
```

❌ **Bad** (too broad):
```markdown
# General Code Helper

Does everything related to code.
```

### 2. Clear Capabilities

List 2-5 specific capabilities:
```yaml
capabilities: [
  "security-vulnerability-detection",
  "authentication-analysis",
  "dependency-audit"
]
```

### 3. Structured Output

Define consistent report format:
```markdown
## Critical (P0)
- [List critical issues]

## High Priority (P1)
- [List high priority issues]

## Suggestions
- [List improvements]
```

### 4. Tool Restrictions

Agents typically don't modify files:
```markdown
## Tool Access

- Read, Grep, Glob: For analysis
- No Write/Edit: Agent proposes, main conversation executes
```

## Agent Workflow Template

All agents should follow a consistent structure:

```markdown
1. **Understand Context**: Read relevant files
2. **Analyze**: Apply domain expertise
3. **Identify Issues**: Find problems/opportunities
4. **Prioritize**: Rank by severity/importance
5. **Recommend**: Provide actionable guidance
6. **Report**: Return structured findings
```

## Common Agent Patterns

### Auditor Pattern

For review/analysis agents:
- Reads multiple files
- Checks against standards/criteria
- Reports issues by severity
- Provides specific fix recommendations

### Generator Pattern

For design/planning agents:
- Analyzes requirements
- Proposes architecture/approach
- Provides implementation steps
- Returns detailed plan

### Refactoring Pattern

For code improvement agents:
- Analyzes existing code
- Identifies improvement opportunities
- Proposes refactoring steps
- Estimates impact/effort

## Invocation Methods

### Direct Invocation

User explicitly calls the agent:
```
/agents code-reviewer
```

### Via Main Conversation

Claude uses Task tool:
```
Let me use the code-reviewer agent to analyze this...
```

### From Skill

Skill escalates to agent for deep analysis:
```markdown
For comprehensive review, delegate to the code-reviewer agent.
```

## Best Practices

1. **Single responsibility**: One clear purpose
2. **Structured output**: Consistent report format
3. **No side effects**: Read-only, propose changes
4. **Clear scope**: 2-5 capabilities max
5. **Fast feedback**: Aim for < 30 seconds runtime
6. **Actionable results**: Specific, implementable recommendations

## Common Mistakes to Avoid

❌ **Too broad scope**
```yaml
capabilities: ["everything", "all-tasks", "general-help"]
```

✅ **Focused capabilities**
```yaml
capabilities: ["security-audit", "vulnerability-scan", "compliance-check"]
```

❌ **Vague instructions**
```markdown
Analyze the code and find problems.
```

✅ **Specific workflow**
```markdown
1. Read all .py files in src/
2. Check for SQL injection patterns
3. Verify authentication usage
4. Report findings by severity
```

## Validation Checklist

After creating an agent:
```
□ Agent file created in agents/ directory
□ Frontmatter includes description
□ Capabilities listed (2-5 items)
□ Clear workflow defined
□ Output format specified
□ Agent name is kebab-case
□ plugin.json has agents field
□ Purpose is focused and specific
```
