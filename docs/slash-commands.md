# Slash commands

> Control Claude's behavior during an interactive session with slash commands.

## Built-in slash commands

The table below lists commands included in Claude Code. Most are built-in commands whose behavior is coded into the CLI. Two kinds of entries are marked:

* **Skill**: a bundled [skill](/en/skills#bundled-skills). It works like skills you write yourself: a prompt handed to Claude, which Claude can also invoke automatically when relevant.
* **Workflow**: a bundled [dynamic workflow](/en/workflows#bundled-workflows) that fans work out across many subagents and runs in the background.

In the table, `<arg>` indicates a required argument and `[arg]` indicates an optional one. Not every command appears for every user; availability depends on your platform, plan, and environment.

| Command                                                                            | Purpose                                                                                                                  |
| :--------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------- |
| `/add-dir <path>`                                                                  | Add a working directory for file access during the current session                                                      |
| `/advisor [model\|off]`                                                            | Enable or disable the advisor tool, which consults a second model for guidance at key moments during a task             |
| `/agents`                                                                          | Manage [agent](/en/sub-agents) configurations                                                                           |
| `/background [prompt]`                                                             | Detach the current session to run as a background agent and free this terminal. Alias: `/bg`                            |
| `/batch <instruction>`                                                             | **Skill.** Orchestrate large-scale changes across a codebase in parallel, running each unit in its own git worktree     |
| `/branch [name]`                                                                   | Create a branch of the current conversation at this point so you can try a different direction                          |
| `/btw <question>`                                                                  | Ask a quick side question without adding to the conversation                                                            |
| `/cd <path>`                                                                       | Move this session to a new working directory                                                                            |
| `/claude-api [migrate\|managed-agents-onboard]`                                    | **Skill.** Load Claude API reference material for your project's language and Managed Agents reference                  |
| `/clear [name]`                                                                    | Start a new conversation with empty context. Aliases: `/reset`, `/new`                                                  |
| `/code-review [low\|medium\|high\|xhigh\|max\|ultra] [--fix] [--comment] [target]` | **Skill.** Review the current diff for correctness bugs and for reuse, simplification, and efficiency cleanups          |
| `/compact [instructions]`                                                          | Free up context by summarizing the conversation so far, optionally with focus instructions                             |
| `/config`                                                                          | Open the [Settings](/en/settings) interface to adjust theme, model, output style, and preferences. Alias: `/settings`  |
| `/context [all]`                                                                   | Visualize current context usage as a colored grid                                                                      |
| `/cost`                                                                            | Alias for `/usage`                                                                                                      |
| `/debug [description]`                                                             | **Skill.** Enable debug logging for the current session and troubleshoot issues by reading the session debug log       |
| `/deep-research <question>`                                                        | **Workflow.** Fan out web searches on a question, fetch and cross-check sources, and synthesize a cited report         |
| `/diff`                                                                            | Open an interactive diff viewer showing uncommitted changes and per-turn diffs                                         |
| `/doctor`                                                                          | Diagnose and verify your Claude Code installation and settings                                                         |
| `/effort [level\|auto]`                                                            | Set the model [effort level](/en/model-config#adjust-effort-level)                                                     |
| `/feedback [report]`                                                               | Submit feedback, report a bug, or share your conversation. Aliases: `/bug`, `/share`                                   |
| `/fork <directive>`                                                                | Spawn a forked subagent that inherits the full conversation and works on the directive while you keep going            |
| `/goal [condition\|clear]`                                                         | Set a [goal](/en/goal): Claude keeps working across turns until the condition is met                                   |
| `/help`                                                                            | Show help and available commands                                                                                       |
| `/hooks`                                                                           | View [hook](/en/hooks) configurations for tool events                                                                  |
| `/init`                                                                            | Initialize project with a `CLAUDE.md` guide                                                                            |
| `/login`                                                                           | Sign in to your Anthropic account                                                                                      |
| `/logout`                                                                          | Sign out from your Anthropic account                                                                                    |
| `/loop [interval] [prompt]`                                                        | **Skill.** Run a prompt repeatedly while the session stays open. Alias: `/proactive`                                   |
| `/mcp`                                                                             | Manage MCP server connections and OAuth authentication                                                                 |
| `/memory`                                                                          | Edit `CLAUDE.md` memory files, enable or disable auto-memory, and view auto-memory entries                            |
| `/model [model]`                                                                   | Switch the AI model and save it as your default for new sessions                                                       |
| `/permissions`                                                                     | Manage allow, ask, and deny rules for tool permissions. Alias: `/allowed-tools`                                        |
| `/plan [description]`                                                              | Enter plan mode directly from the prompt                                                                               |
| `/plugin [subcommand]`                                                             | Manage Claude Code [plugins](/en/plugins)                                                                              |
| `/resume [session]`                                                                | Resume a conversation by ID or name, or open the session picker. Alias: `/continue`                                   |
| `/review [PR]`                                                                     | Review a pull request locally in your current session                                                                  |
| `/rewind`                                                                          | Rewind the conversation and/or code to a previous point. Aliases: `/checkpoint`, `/undo`                              |
| `/run`                                                                             | **Skill.** Launch and drive your project's app to see a change working in the running app, not just in tests          |
| `/sandbox`                                                                         | Toggle [sandbox mode](/en/sandboxing). Available on supported platforms only                                          |
| `/security-review`                                                                 | Analyze pending changes on the current branch for security vulnerabilities                                            |
| `/simplify [target]`                                                               | **Skill.** Review the changed code for cleanup opportunities and apply the fixes                                      |
| `/skills`                                                                          | List available [skills](/en/skills)                                                                                    |
| `/status`                                                                          | Open the Settings interface (Status tab) showing version, model, account, and connectivity                            |
| `/tasks`                                                                           | View and manage everything running in the background. Also available as `/bashes`                                     |
| `/terminal-setup`                                                                  | Configure terminal keybindings for Shift+Enter and other shortcuts                                                     |
| `/usage`                                                                           | Show session cost, plan usage limits, and activity stats. `/cost` and `/stats` are aliases                            |
| `/verify`                                                                          | **Skill.** Confirm a code change does what it should by building your project's app, running it, and observing the result |
| `/workflows`                                                                       | Open the [workflow](/en/workflows#watch-the-run) progress view to watch, pause, resume, or save workflows             |

## Custom slash commands

Custom slash commands allow you to define frequently-used prompts as Markdown files that Claude Code can execute. Commands are organized by scope (project-specific or personal) and support namespacing through directory structures.

### Syntax

```
/<command-name> [arguments]
```

#### Parameters

| Parameter        | Description                                                       |
| :--------------- | :---------------------------------------------------------------- |
| `<command-name>` | Name derived from the Markdown filename (without `.md` extension) |
| `[arguments]`    | Optional arguments passed to the command                          |

### Command types

#### Project commands

Commands stored in your repository and shared with your team. When listed in `/help`, these commands show "(project)" after their description.

**Location**: `.claude/commands/`

In the following example, we create the `/optimize` command:

```bash  theme={null}
# Create a project command
mkdir -p .claude/commands
echo "Analyze this code for performance issues and suggest optimizations:" > .claude/commands/optimize.md
```

#### Personal commands

Commands available across all your projects. When listed in `/help`, these commands show "(user)" after their description.

**Location**: `~/.claude/commands/`

In the following example, we create the `/security-review` command:

```bash  theme={null}
# Create a personal command
mkdir -p ~/.claude/commands
echo "Review this code for security vulnerabilities:" > ~/.claude/commands/security-review.md
```

### Features

#### Namespacing

Organize commands in subdirectories. The subdirectories are used for organization and appear in the command description, but they do not affect the command name itself. The description will show whether the command comes from the project directory (`.claude/commands`) or the user-level directory (`~/.claude/commands`), along with the subdirectory name.

Conflicts between user and project level commands are not supported. Otherwise, multiple commands with the same base file name can coexist.

For example, a file at `.claude/commands/frontend/component.md` creates the command `/component` with description showing "(project:frontend)".
Meanwhile, a file at `~/.claude/commands/component.md` creates the command `/component` with description showing "(user)".

#### Arguments

Pass dynamic values to commands using argument placeholders:

##### All arguments with `$ARGUMENTS`

The `$ARGUMENTS` placeholder captures all arguments passed to the command:

```bash  theme={null}
# Command definition
echo 'Fix issue #$ARGUMENTS following our coding standards' > .claude/commands/fix-issue.md

# Usage
> /fix-issue 123 high-priority
# $ARGUMENTS becomes: "123 high-priority"
```

##### Individual arguments with `$1`, `$2`, etc.

Access specific arguments individually using positional parameters (similar to shell scripts):

```bash  theme={null}
# Command definition  
echo 'Review PR #$1 with priority $2 and assign to $3' > .claude/commands/review-pr.md

# Usage
> /review-pr 456 high alice
# $1 becomes "456", $2 becomes "high", $3 becomes "alice"
```

Use positional arguments when you need to:

* Access arguments individually in different parts of your command
* Provide defaults for missing arguments
* Build more structured commands with specific parameter roles

#### Bash command execution

Execute bash commands before the slash command runs using the `!` prefix. The output is included in the command context. You *must* include `allowed-tools` with the `Bash` tool, but you can choose the specific bash commands to allow.

For example:

```markdown  theme={null}
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Create a git commit
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single git commit.
```

#### File references

Include file contents in commands using the `@` prefix to [reference files](/en/common-workflows#reference-files-and-directories).

For example:

```markdown  theme={null}
# Reference a specific file

Review the implementation in @src/utils/helpers.js

# Reference multiple files

Compare @src/old-version.js with @src/new-version.js
```

#### Thinking mode

Slash commands can trigger extended thinking by including [extended thinking keywords](/en/common-workflows#use-extended-thinking).

### Frontmatter

Command files support frontmatter, useful for specifying metadata about the command:

| Frontmatter                | Purpose                                                                                                                                                                               | Default                             |
| :------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :---------------------------------- |
| `allowed-tools`            | List of tools the command can use                                                                                                                                                     | Inherits from the conversation      |
| `argument-hint`            | The arguments expected for the slash command. Example: `argument-hint: add [tagId] \| remove [tagId] \| list`. This hint is shown to the user when auto-completing the slash command. | None                                |
| `description`              | Brief description of the command                                                                                                                                                      | Uses the first line from the prompt |
| `model`                    | Model to use when this command is active. Accepts the same values as [`/model`](/en/model-config), or `inherit` to keep the active model.                                            | Inherits from the conversation      |
| `disable-model-invocation` | Whether to prevent the `Skill` tool from calling this command                                                                                                                        | false                               |

For example:

```markdown  theme={null}
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
argument-hint: [message]
description: Create a git commit
model: haiku
---

Create a git commit with message: $ARGUMENTS
```

Example using positional arguments:

```markdown  theme={null}
---
argument-hint: [pr-number] [priority] [assignee]
description: Review pull request
---

Review PR #$1 with priority $2 and assign to $3.
Focus on security, performance, and code style.
```

## Plugin commands

[Plugins](/en/plugins) can provide custom slash commands that integrate seamlessly with Claude Code. Plugin commands work exactly like user-defined commands but are distributed through [plugin marketplaces](/en/plugin-marketplaces).

### How plugin commands work

Plugin commands are:

* **Namespaced**: Commands can use the format `/plugin-name:command-name` to avoid conflicts (plugin prefix is optional unless there are name collisions)
* **Automatically available**: Once a plugin is installed and enabled, its commands appear in `/help`
* **Fully integrated**: Support all command features (arguments, frontmatter, bash execution, file references)

### Plugin command structure

**Location**: `commands/` directory in plugin root

**File format**: Markdown files with frontmatter

**Basic command structure**:

```markdown  theme={null}
---
description: Brief description of what the command does
---

# Command Name

Detailed instructions for Claude on how to execute this command.
Include specific guidance on parameters, expected outcomes, and any special considerations.
```

**Advanced command features**:

* **Arguments**: Use placeholders like `{arg1}` in command descriptions
* **Subdirectories**: Organize commands in subdirectories for namespacing
* **Bash integration**: Commands can execute shell scripts and programs
* **File references**: Commands can reference and modify project files

### Invocation patterns

```shell Direct command (when no conflicts) theme={null}
/command-name
```

```shell Plugin-prefixed (when needed for disambiguation) theme={null}
/plugin-name:command-name
```

```shell With arguments (if command supports them) theme={null}
/command-name arg1 arg2
```

## MCP slash commands

MCP servers can expose prompts as slash commands that become available in Claude Code. These commands are dynamically discovered from connected MCP servers.

### Command format

MCP commands follow the pattern:

```
/mcp__<server-name>__<prompt-name> [arguments]
```

### Features

#### Dynamic discovery

MCP commands are automatically available when:

* An MCP server is connected and active
* The server exposes prompts through the MCP protocol
* The prompts are successfully retrieved during connection

#### Arguments

MCP prompts can accept arguments defined by the server:

```
# Without arguments
> /mcp__github__list_prs

# With arguments
> /mcp__github__pr_review 456
> /mcp__jira__create_issue "Bug title" high
```

#### Naming conventions

* Server and prompt names are normalized
* Spaces and special characters become underscores
* Names are lowercased for consistency

### Managing MCP connections

Use the `/mcp` command to:

* View all configured MCP servers
* Check connection status
* Authenticate with OAuth-enabled servers
* Clear authentication tokens
* View available tools and prompts from each server

### MCP permissions and wildcards

When configuring [permissions for MCP tools](/en/iam#tool-specific-permission-rules), note that **wildcards are not supported**:

* ✅ **Correct**: `mcp__github` (approves ALL tools from the github server)
* ✅ **Correct**: `mcp__github__get_issue` (approves specific tool)
* ❌ **Incorrect**: `mcp__github__*` (wildcards not supported)

To approve all tools from an MCP server, use just the server name: `mcp__servername`. To approve specific tools only, list each tool individually.

## `Skill` tool

Custom slash commands have been merged into [skills](/en/skills), and Claude
invokes them through the `Skill` tool. By default, Claude can invoke any skill
that doesn't have `disable-model-invocation: true` set, so it can run custom
commands on your behalf when relevant to your conversation.

To encourage Claude to trigger a skill, your instructions (prompts, CLAUDE.md,
etc.) generally need to reference the command by name with its slash.

Example:

```
> Run /write-unit-test when you are about to start writing tests.
```

In a regular session, skill descriptions are loaded into context so Claude knows
what's available, but the full skill content only loads when invoked. You can use
`/context` to monitor token usage and follow the operations below to manage
context.

### `Skill` tool supported commands

Claude can invoke any skill that:

* Does not have `disable-model-invocation: true` set in its frontmatter.
* Has a `description` so Claude knows when to use it. If omitted, the first
  paragraph of markdown content is used.

A few built-in commands are also available through the `Skill` tool, including
`/init`, `/review`, and `/security-review`. Other built-in commands such as
`/compact` are not.

Run `/doctor` to see whether the skill listing budget is overflowing and which
skills are affected.

### Disable the `Skill` tool

To prevent Claude from invoking any skills via the tool, deny the `Skill` tool in
`/permissions`:

```text  theme={null}
# Add to deny rules:
Skill
```

This will also remove the skill descriptions from context.

### Disable specific commands only

To prevent a specific skill from being invoked by Claude, add
`disable-model-invocation: true` to the skill's frontmatter.

This will also remove the skill from Claude's context entirely.

### `Skill` permission rules

Allow or deny specific skills using [permission rules](/en/permissions):

* **Exact match**: `Skill(commit)` (allows only `/commit` with no arguments)
* **Prefix match**: `Skill(review-pr *)` (allows `/review-pr` with any arguments)

### Character budget limit

Skill descriptions are loaded into context so Claude knows what's available. All
skill names are always included, but if you have many skills, descriptions are
shortened to fit a character budget, which can strip the keywords Claude needs to
match your request. When the budget overflows, descriptions for the skills you
invoke least are dropped first.

* **Default limit**: scales at 1% of the model's context window (configurable via
  the [`skillListingBudgetFraction`](/en/settings#available-settings) setting,
  e.g. `0.02` = 2%)
* **Custom limit**: set the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable
  to a fixed character count

Each entry's combined `description` and `when_to_use` text is capped at 1,536
characters regardless of budget; the cap is configurable with
[`maxSkillDescriptionChars`](/en/settings#available-settings). Run `/doctor` to
see whether the budget is overflowing and which skills are affected.

## Skills vs slash commands

**Slash commands** and **Agent Skills** serve different purposes in Claude Code:

### Use slash commands for

**Quick, frequently-used prompts**:

* Simple prompt snippets you use often
* Quick reminders or templates
* Frequently-used instructions that fit in one file

**Examples**:

* `/review` → "Review this code for bugs and suggest improvements"
* `/explain` → "Explain this code in simple terms"
* `/optimize` → "Analyze this code for performance issues"

### Use Skills for

**Comprehensive capabilities with structure**:

* Complex workflows with multiple steps
* Capabilities requiring scripts or utilities
* Knowledge organized across multiple files
* Team workflows you want to standardize

**Examples**:

* PDF processing Skill with form-filling scripts and validation
* Data analysis Skill with reference docs for different data types
* Documentation Skill with style guides and templates

### Key differences

| Aspect         | Slash Commands                   | Agent Skills                        |
| -------------- | -------------------------------- | ----------------------------------- |
| **Complexity** | Simple prompts                   | Complex capabilities                |
| **Structure**  | Single .md file                  | Directory with SKILL.md + resources |
| **Discovery**  | Explicit invocation (`/command`) | Automatic (based on context)        |
| **Files**      | One file only                    | Multiple files, scripts, templates  |
| **Scope**      | Project or personal              | Project or personal                 |
| **Sharing**    | Via git                          | Via git                             |

### Example comparison

**As a slash command**:

```markdown  theme={null}
# .claude/commands/review.md
Review this code for:
- Security vulnerabilities
- Performance issues
- Code style violations
```

Usage: `/review` (manual invocation)

**As a Skill**:

```
.claude/skills/code-review/
├── SKILL.md (overview and workflows)
├── SECURITY.md (security checklist)
├── PERFORMANCE.md (performance patterns)
├── STYLE.md (style guide reference)
└── scripts/
    └── run-linters.sh
```

Usage: "Can you review this code?" (automatic discovery)

The Skill provides richer context, validation scripts, and organized reference material.

### When to use each

**Use slash commands**:

* You invoke the same prompt repeatedly
* The prompt fits in a single file
* You want explicit control over when it runs

**Use Skills**:

* Claude should discover the capability automatically
* Multiple files or scripts are needed
* Complex workflows with validation steps
* Team needs standardized, detailed guidance

Both slash commands and Skills can coexist. Use the approach that fits your needs.

Learn more about [Agent Skills](/en/skills).

## See also

* [Plugins](/en/plugins) - Extend Claude Code with custom commands through plugins
* [Identity and Access Management](/en/iam) - Complete guide to permissions, including MCP tool permissions
* [Interactive mode](/en/interactive-mode) - Shortcuts, input modes, and interactive features
* [CLI reference](/en/cli-reference) - Command-line flags and options
* [Settings](/en/settings) - Configuration options
* [Memory management](/en/memory) - Managing Claude's memory across sessions
