# Subagents

> Create and use specialized AI subagents in Claude Code for task-specific workflows and improved context management.

Custom subagents in Claude Code are specialized AI assistants that can be invoked to handle specific types of tasks. They enable more efficient problem-solving by providing task-specific configurations with customized system prompts, tools and a separate context window.

## What are subagents?

Subagents are pre-configured AI personalities that Claude Code can delegate tasks to. Each subagent:

* Has a specific purpose and expertise area
* Uses its own context window separate from the main conversation
* Can be configured with specific tools it's allowed to use
* Includes a custom system prompt that guides its behavior

When Claude Code encounters a task that matches a subagent's expertise, it can delegate that task to the specialized subagent, which works independently and returns results.

## Key benefits

<CardGroup cols={2}>
  <Card title="Context preservation" icon="layer-group">
    Each subagent operates in its own context, preventing pollution of the main conversation and keeping it focused on high-level objectives.
  </Card>

  <Card title="Specialized expertise" icon="brain">
    Subagents can be fine-tuned with detailed instructions for specific domains, leading to higher success rates on designated tasks.
  </Card>

  <Card title="Reusability" icon="rotate">
    Once created, subagents can be used across different projects and shared with your team for consistent workflows.
  </Card>

  <Card title="Flexible permissions" icon="shield-check">
    Each subagent can have different tool access levels, allowing you to limit powerful tools to specific subagent types.
  </Card>
</CardGroup>

## Built-in subagents

Claude Code includes built-in subagents that Claude automatically uses when appropriate. Each inherits the parent conversation's permissions with additional tool restrictions.

Explore and Plan skip your CLAUDE.md files and the parent session's git status to keep research fast and inexpensive. Every other built-in and custom subagent loads both.

<Tabs>
  <Tab title="Explore">
    A fast, read-only agent optimized for searching and analyzing codebases.

    * **Model**: Haiku (fast, low-latency)
    * **Tools**: Read-only tools (denied access to Write and Edit tools)
    * **Purpose**: File discovery, code search, codebase exploration

    Claude delegates to Explore when it needs to search or understand a codebase without making changes. This keeps exploration results out of your main conversation context.

    When invoking Explore, Claude specifies a thoroughness level: **quick** for targeted lookups, **medium** for balanced exploration, or **very thorough** for comprehensive analysis.
  </Tab>

  <Tab title="Plan">
    A research agent used during [plan mode](https://code.claude.com/docs/en/permission-modes#analyze-before-you-edit-with-plan-mode) to gather context before presenting a plan.

    * **Model**: Inherits from main conversation
    * **Tools**: Read-only tools (denied access to Write and Edit tools)
    * **Purpose**: Codebase research for planning

    When you're in plan mode and Claude needs to understand your codebase, it delegates research to the Plan subagent so that exploration output stays in a separate context window while the main conversation remains read-only.
  </Tab>

  <Tab title="General-purpose">
    A capable agent for complex, multi-step tasks that require both exploration and action.

    * **Model**: Inherits from main conversation
    * **Tools**: All tools
    * **Purpose**: Complex research, multi-step operations, code modifications

    Claude delegates to general-purpose when the task requires both exploration and modification, complex reasoning to interpret results, or multiple dependent steps.
  </Tab>

  <Tab title="Other">
    Claude Code includes additional helper agents for specific tasks. These are typically invoked automatically, so you don't need to use them directly.

    | Agent             | Model  | When Claude uses it                                      |
    | :---------------- | :----- | :------------------------------------------------------- |
    | statusline-setup  | Sonnet | When you run `/statusline` to configure your status line |
    | claude-code-guide | Haiku  | When you ask questions about Claude Code features        |
  </Tab>
</Tabs>

Built-in subagents are always registered in interactive sessions. To block a specific built-in type, add it to `permissions.deny` (for example, `Agent(Explore)`). To prevent Claude from delegating to any subagent, deny the `Agent` tool itself. In [non-interactive mode](https://code.claude.com/docs/en/headless) and the [Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview), set [`CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS=1`](https://code.claude.com/docs/en/env-vars) to remove all built-in types and supply only your own.

## Quick start

To create your first subagent:

<Steps>
  <Step title="Open the subagents interface">
    Run the following command:

    ```
    /agents
    ```
  </Step>

  <Step title="Select 'Create New Agent'">
    Choose whether to create a project-level or user-level subagent
  </Step>

  <Step title="Define the subagent">
    * **Recommended**: Generate with Claude first, then customize to make it yours
    * Describe your subagent in detail and when it should be used
    * Select the tools you want to grant access to (or leave blank to inherit all tools)
    * The interface shows all available tools, making selection easy
    * If you're generating with Claude, you can also edit the system prompt in your own editor by pressing `e`
  </Step>

  <Step title="Save and use">
    Your subagent is now available! Claude will use it automatically when appropriate, or you can invoke it explicitly:

    ```
    > Use the code-reviewer subagent to check my recent changes
    ```
  </Step>
</Steps>

## Subagent configuration

### File locations

Subagents are Markdown files with YAML frontmatter. Store them in different locations depending on scope. When multiple subagents share the same name, the higher-priority location wins.

| Location                     | Scope                   | Priority    | How to create                                                |
| :--------------------------- | :---------------------- | :---------- | :----------------------------------------------------------- |
| Managed settings             | Organization-wide       | 1 (highest) | Deployed via [managed settings](https://code.claude.com/docs/en/settings) |
| `--agents` CLI flag          | Current session         | 2           | Pass JSON when launching Claude Code                         |
| `.claude/agents/`            | Current project         | 3           | Interactive or manual                                        |
| `~/.claude/agents/`          | All your projects       | 4           | Interactive or manual                                        |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest)  | Installed with [plugins](https://code.claude.com/docs/en/plugins) |

**Project subagents** (`.claude/agents/`) are ideal for subagents specific to a codebase. Check them into version control so your team can use and improve them collaboratively. **User subagents** (`~/.claude/agents/`) are personal subagents available in all your projects.

### Plugin agents

[Plugins](https://code.claude.com/docs/en/plugins) can provide custom subagents that integrate seamlessly with Claude Code. Plugin agents work identically to user-defined agents and appear in the `/agents` interface.

**Plugin agent locations**: Plugins include agents in their `agents/` directory (or custom paths specified in the plugin manifest).

**Using plugin agents**:

* Plugin agents appear in `/agents` alongside your custom agents
* Can be invoked explicitly: "Use the code-reviewer agent from the security-plugin"
* Can be invoked automatically by Claude when appropriate
* Can be managed (viewed, inspected) through `/agents` interface

See the [plugin components reference](https://code.claude.com/docs/en/plugins-reference#agents) for details on creating plugin agents.

### CLI-based configuration

You can also define subagents dynamically using the `--agents` CLI flag, which accepts a JSON object:

```bash  theme={null}
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer. Focus on code quality, security, and best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

The `--agents` flag accepts JSON with the same frontmatter fields as file-based subagents: `description`, `prompt`, `tools`, `disallowedTools`, `model`, `permissionMode`, `mcpServers`, `hooks`, `maxTurns`, `skills`, `initialPrompt`, `memory`, `effort`, `background`, `isolation`, and `color`. Use `prompt` for the system prompt, equivalent to the markdown body in file-based subagents.

**Priority**: CLI-defined subagents have lower priority than project-level subagents but higher priority than user-level subagents.

**Use case**: This approach is useful for:

* Quick testing of subagent configurations
* Session-specific subagents that don't need to be saved
* Automation scripts that need custom subagents
* Sharing subagent definitions in documentation or scripts

For detailed information about the JSON format and all available options, see [Supported frontmatter fields](#supported-frontmatter-fields).

### File format

Each subagent is defined in a Markdown file with this structure:

```markdown  theme={null}
---
name: your-sub-agent-name
description: Description of when this subagent should be invoked
tools: tool1, tool2, tool3  # Optional - inherits all tools if omitted
model: sonnet  # Optional - model alias, full model ID, or 'inherit' (default)
---

Your subagent's system prompt goes here. This can be multiple paragraphs
and should clearly define the subagent's role, capabilities, and approach
to solving problems.

Include specific instructions, best practices, and any constraints
the subagent should follow.
```

#### Supported frontmatter fields

The following fields can be used in the YAML frontmatter. Only `name` and `description` are required.

| Field             | Required | Description                                                                                                                                                                          |
| :---------------- | :------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`            | Yes      | Unique identifier using lowercase letters and hyphens. [Hooks](https://code.claude.com/docs/en/hooks#subagentstart) receive this value as `agent_type`. The filename does not have to match |
| `description`     | Yes      | When Claude should delegate to this subagent                                                                                                                                       |
| `tools`           | No       | Tools the subagent can use. Inherits all tools if omitted. To preload Skills into context, use the `skills` field rather than listing `Skill` here                                 |
| `disallowedTools` | No       | Tools to deny, removed from inherited or specified list                                                                                                                            |
| `model`           | No       | Model to use: `sonnet`, `opus`, `haiku`, `fable`, a full model ID (for example, `claude-opus-4-8`), or `inherit`. Defaults to `inherit`                                            |
| `permissionMode`  | No       | Permission mode: `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin subagents                                                         |
| `maxTurns`        | No       | Maximum number of agentic turns before the subagent stops                                                                                                                         |
| `skills`          | No       | [Skills](https://code.claude.com/docs/en/skills) to preload into the subagent's context at startup. The full skill content is injected, not just the description                   |
| `mcpServers`      | No       | [MCP servers](https://code.claude.com/docs/en/mcp) available to this subagent. Each entry is a server name referencing an already-configured server or an inline definition. Ignored for plugin subagents |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent. Ignored for plugin subagents                                                                                                              |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`. Enables cross-session learning                                                                                            |
| `background`      | No       | Set to `true` to always run this subagent as a background task. Default: `false`                                                                                                   |
| `effort`          | No       | Effort level when this subagent is active. Overrides the session effort level. Options: `low`, `medium`, `high`, `xhigh`, `max`; available levels depend on the model              |
| `isolation`       | No       | Set to `worktree` to run the subagent in a temporary [git worktree](https://code.claude.com/docs/en/worktrees), giving it an isolated copy of the repository                       |
| `color`           | No       | Display color in the task list and transcript. Accepts `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`                                                     |
| `initialPrompt`   | No       | Auto-submitted as the first user turn when this agent runs as the main session agent (via `--agent` or the `agent` setting). Prepended to any user-provided prompt                 |

### Model selection

The `model` field controls which [AI model](https://code.claude.com/docs/en/model-config) the subagent uses:

* **Model alias**: Use one of the available aliases: `sonnet`, `opus`, `haiku`, or `fable`
* **Full model ID**: Use a full model ID such as `claude-opus-4-8` or `claude-sonnet-4-6`. Accepts the same values as the `--model` flag
* **`inherit`**: Use the same model as the main conversation
* **Omitted**: If not specified, defaults to `inherit` (uses the same model as the main conversation)

When Claude invokes a subagent, it can also pass a `model` parameter for that specific invocation. Claude Code resolves the subagent's model in this order:

1. The [`CLAUDE_CODE_SUBAGENT_MODEL`](https://code.claude.com/docs/en/model-config#environment-variables) environment variable, if set
2. The per-invocation `model` parameter
3. The subagent definition's `model` frontmatter
4. The main conversation's model

<Note>
  Using `inherit` is particularly useful when you want your subagents to adapt to the model choice of the main conversation, ensuring consistent capabilities and response style throughout your session.
</Note>

### Available tools

Subagents inherit the [internal tools](https://code.claude.com/docs/en/tools-reference) and MCP tools available in the main conversation by default. The following tools depend on the main conversation's UI or session state and are not available to subagents, even when listed in the `tools` field:

* `AskUserQuestion`
* `EnterPlanMode`
* `ExitPlanMode`, unless the subagent's `permissionMode` is `plan`
* `ScheduleWakeup`
* `WaitForMcpServers`

<Tip>
  **Recommended:** Use the `/agents` command to modify tool access - it provides an interactive interface that lists all available tools, including any connected MCP server tools, making it easier to select the ones you need.
</Tip>

To restrict tools, use either the `tools` field (allowlist) or the `disallowedTools` field (denylist):

* **Omit the `tools` field** to inherit all tools from the main thread (default), including MCP tools
* **Specify individual tools** with the `tools` field as a comma-separated allowlist for more granular control (can be edited manually or via `/agents`)
* **Deny individual tools** with the `disallowedTools` field, for example `disallowedTools: Write, Edit`, to inherit everything except the listed tools

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first, then `tools` is resolved against the remaining pool. A tool listed in both is removed.

**MCP Tools**: Subagents can access MCP tools from configured MCP servers. When the `tools` field is omitted, subagents inherit all MCP tools available to the main thread.

## Managing subagents

### Using the /agents command (Recommended)

The `/agents` command opens a tabbed interface for managing subagents:

```
/agents
```

The **Running** tab lists live and recently finished subagents and lets you open or stop them. The **Library** tab lets you:

* View all available subagents (built-in, user, project, and plugin)
* Create new subagents with guided setup or Claude generation
* Edit existing subagent configuration and tool access
* Delete custom subagents
* See which subagents are active when duplicates exist

This is the recommended way to create and manage subagents. For manual creation or automation, you can also add subagent files directly.

### Direct file management

You can also manage subagents by working directly with their files:

```bash  theme={null}
# Create a project subagent
mkdir -p .claude/agents
echo '---
name: test-runner
description: Use proactively to run tests and fix failures
---

You are a test automation expert. When you see code changes, proactively run the appropriate tests. If tests fail, analyze the failures and fix them while preserving the original test intent.' > .claude/agents/test-runner.md

# Create a user subagent
mkdir -p ~/.claude/agents
# ... create subagent file
```

## Using subagents effectively

### Automatic delegation

Claude Code proactively delegates tasks based on:

* The task description in your request
* The `description` field in subagent configurations
* Current context and available tools

<Tip>
  To encourage proactive delegation, include phrases like "use proactively" in your `description` field.
</Tip>

### Explicit invocation

Request a specific subagent by mentioning it in your command:

```
> Use the test-runner subagent to fix failing tests
> Have the code-reviewer subagent look at my recent changes
> Ask the debugger subagent to investigate this error
```

## Example subagents

### Code reviewer

```markdown  theme={null}
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards of code quality and security.

When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

Review checklist:
- Code is clear and readable
- Functions and variables are well-named
- No duplicated code
- Proper error handling
- No exposed secrets or API keys
- Input validation implemented
- Good test coverage
- Performance considerations addressed

Provide feedback organized by priority:
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (consider improving)

Include specific examples of how to fix issues.
```

### Debugger

```markdown  theme={null}
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior. Use proactively when encountering any issues.
tools: Read, Edit, Bash, Grep, Glob
---

You are an expert debugger specializing in root cause analysis.

When invoked:
1. Capture error message and stack trace
2. Identify reproduction steps
3. Isolate the failure location
4. Implement minimal fix
5. Verify solution works

Debugging process:
- Analyze error messages and logs
- Check recent code changes
- Form and test hypotheses
- Add strategic debug logging
- Inspect variable states

For each issue, provide:
- Root cause explanation
- Evidence supporting the diagnosis
- Specific code fix
- Testing approach
- Prevention recommendations

Focus on fixing the underlying issue, not just symptoms.
```

### Data scientist

```markdown  theme={null}
---
name: data-scientist
description: Data analysis expert for SQL queries, BigQuery operations, and data insights. Use proactively for data analysis tasks and queries.
tools: Bash, Read, Write
model: sonnet
---

You are a data scientist specializing in SQL and BigQuery analysis.

When invoked:
1. Understand the data analysis requirement
2. Write efficient SQL queries
3. Use BigQuery command line tools (bq) when appropriate
4. Analyze and summarize results
5. Present findings clearly

Key practices:
- Write optimized SQL queries with proper filters
- Use appropriate aggregations and joins
- Include comments explaining complex logic
- Format results for readability
- Provide data-driven recommendations

For each analysis:
- Explain the query approach
- Document any assumptions
- Highlight key findings
- Suggest next steps based on data

Always ensure queries are efficient and cost-effective.
```

## Best practices

* **Start with Claude-generated agents**: We highly recommend generating your initial subagent with Claude and then iterating on it to make it personally yours. This approach gives you the best results - a solid foundation that you can customize to your specific needs.

* **Design focused subagents**: Create subagents with single, clear responsibilities rather than trying to make one subagent do everything. This improves performance and makes subagents more predictable.

* **Write detailed prompts**: Include specific instructions, examples, and constraints in your system prompts. The more guidance you provide, the better the subagent will perform.

* **Limit tool access**: Only grant tools that are necessary for the subagent's purpose. This improves security and helps the subagent focus on relevant actions.

* **Version control**: Check project subagents into version control so your team can benefit from and improve them collaboratively.

## Advanced usage

### Chaining subagents

For complex workflows, you can chain multiple subagents:

```
> First use the code-analyzer subagent to find performance issues, then use the optimizer subagent to fix them
```

### Dynamic subagent selection

Claude Code intelligently selects subagents based on context. Make your `description` fields specific and action-oriented for best results.

### Permission modes

The `permissionMode` field controls how the subagent handles permission prompts. Subagents inherit the permission context from the main conversation and can override the mode, except when the parent mode takes precedence.

| Mode                | Behavior                                                                                                                                    |
| :------------------ | :----------------------------------------------------------------------------------------------------------------------------------------- |
| `default`           | Standard permission checking with prompts                                                                                                  |
| `acceptEdits`       | Auto-accept file edits and common filesystem commands for paths in the working directory or `additionalDirectories`                        |
| `auto`              | [Auto mode](https://code.claude.com/docs/en/permission-modes#eliminate-prompts-with-auto-mode): a background classifier reviews commands and protected-directory writes |
| `dontAsk`           | Auto-deny permission prompts (explicitly allowed tools still work)                                                                         |
| `bypassPermissions` | Skip permission prompts                                                                                                                    |
| `plan`              | Plan mode (read-only exploration)                                                                                                          |

<Warning>
  Use `bypassPermissions` with caution. It skips permission prompts, allowing the subagent to execute operations without approval. Explicit `ask` rules and root and home directory removals such as `rm -rf /` still prompt.
</Warning>

If the parent uses `bypassPermissions` or `acceptEdits`, this takes precedence and cannot be overridden. If the parent uses auto mode, the subagent inherits auto mode and any `permissionMode` in its frontmatter is ignored.

### Enable persistent memory

The `memory` field gives the subagent a persistent directory that survives across conversations. The subagent uses this directory to build up knowledge over time, such as codebase patterns, debugging insights, and architectural decisions.

```yaml  theme={null}
---
name: code-reviewer
description: Reviews code for quality and best practices
memory: user
---

You are a code reviewer. As you review code, update your agent memory with
patterns, conventions, and recurring issues you discover.
```

Choose a scope based on how broadly the memory should apply:

| Scope     | Location                                      | Use when                                                                                    |
| :-------- | :-------------------------------------------- | :------------------------------------------------------------------------------------------ |
| `user`    | `~/.claude/agent-memory/<name-of-agent>/`     | the subagent should remember learnings across all projects                                  |
| `project` | `.claude/agent-memory/<name-of-agent>/`       | the subagent's knowledge is project-specific and shareable via version control              |
| `local`   | `.claude/agent-memory-local/<name-of-agent>/` | the subagent's knowledge is project-specific but should not be checked into version control |

When memory is enabled, the subagent's system prompt includes instructions for reading and writing to the memory directory, the first 200 lines or 25KB of `MEMORY.md` (whichever comes first), and Read, Write, and Edit tools are automatically enabled so the subagent can manage its memory files.

### Define hooks for subagents

Subagents can define [hooks](https://code.claude.com/docs/en/hooks) that run during the subagent's lifecycle. There are two ways to configure hooks:

1. **In the subagent's frontmatter**: Define hooks that run only while that subagent is active
2. **In `settings.json`**: Define hooks that run in the main session when subagents start or stop

#### Hooks in subagent frontmatter

Define hooks directly in the subagent's markdown file. These hooks only run while that specific subagent is active and are cleaned up when it finishes. All [hook events](https://code.claude.com/docs/en/hooks#hook-events) are supported. The most common events for subagents are `PreToolUse`, `PostToolUse`, and `Stop` (converted to `SubagentStop` at runtime).

```yaml  theme={null}
---
name: code-reviewer
description: Review code changes with automatic linting
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh $TOOL_INPUT"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
---
```

#### Project-level hooks for subagent events

Configure hooks in `settings.json` that respond to subagent lifecycle events in the main session.

| Event           | Matcher input   | When it fires                    |
| :-------------- | :-------------- | :------------------------------- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop`  | Agent type name | When a subagent completes        |

Both events support matchers to target specific agent types by name. See [Hooks](https://code.claude.com/docs/en/hooks) for the complete hook configuration format.

### Spawn nested subagents

As of Claude Code v2.1.172, a subagent can spawn its own subagents. Use this when a delegated task itself splits into parallel subtasks, so the intermediate output never reaches your main conversation. Only the top-level subagent's summary returns to you.

A nested subagent is configured the same way as a top-level one and resolves from the same scopes. To prevent a specific subagent from spawning others, omit `Agent` from its `tools` list or add it to `disallowedTools`. A fork cannot spawn another fork, but it can spawn other subagent types.

### Fork the current conversation

<Note>
  Forked subagents require Claude Code v2.1.117 or later. From v2.1.161 the `/fork` command is enabled by default; on earlier versions it requires setting the [`CLAUDE_CODE_FORK_SUBAGENT`](https://code.claude.com/docs/en/env-vars) environment variable to `1`.
</Note>

A fork is a subagent that inherits the entire conversation so far instead of starting fresh. A fork sees the same system prompt, tools, model, and message history as the main session, so you can hand it a side task without re-explaining the situation. The fork's own tool calls still stay out of your conversation and only its final result comes back, so your main context window stays clean.

To control fork mode regardless of the staged rollout, set [`CLAUDE_CODE_FORK_SUBAGENT`](https://code.claude.com/docs/en/env-vars) to `1` to enable it explicitly or to `0` to disable it. You can start a fork yourself with `/fork` followed by a directive:

```text  theme={null}
/fork draft unit tests for the parser changes so far
```

The fork appears in a panel below your prompt and runs in the background while you keep working. When it finishes, its result arrives as a message in your main conversation.

## Performance considerations

* **Context efficiency**: Agents help preserve main context, enabling longer overall sessions
* **Latency**: Subagents start off with a clean slate each time they are invoked and may add latency as they gather context that they require to do their job effectively.

## Related documentation

* [Plugins](https://code.claude.com/docs/en/plugins) - Extend Claude Code with custom agents through plugins
* [Slash commands](https://code.claude.com/docs/en/slash-commands) - Learn about other built-in commands
* [Settings](https://code.claude.com/docs/en/settings) - Configure Claude Code behavior
* [Hooks](https://code.claude.com/docs/en/hooks) - Automate workflows with event handlers
