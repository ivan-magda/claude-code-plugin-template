# Claude Code settings

> Configure Claude Code with global and project-level settings, and environment variables.

Claude Code offers a variety of settings to configure its behavior to meet your needs. You can configure Claude Code by running the `/config` command when using the interactive REPL, which opens a tabbed Settings interface where you can view status information and modify configuration options.

## Settings files

The `settings.json` file is our official mechanism for configuring Claude
Code through hierarchical settings:

* **User settings** are defined in `~/.claude/settings.json` and apply to all
  projects.
* **Project settings** are saved in your project directory:
  * `.claude/settings.json` for settings that are checked into source control and shared with your team
  * `.claude/settings.local.json` for settings that are not checked in, useful for personal preferences and experimentation. Claude Code will configure git to ignore `.claude/settings.local.json` when it is created.
* **Managed settings**: For organizations that need centralized control, Claude Code supports multiple delivery mechanisms for managed settings. All use the same JSON format and cannot be overridden by user or project settings:
  * **Server-managed settings**: delivered from Anthropic's servers via the Claude.ai admin console. See [server-managed settings](/en/server-managed-settings).
  * **MDM/OS-level policies**: delivered through native device management on macOS and Windows:
    * macOS: `com.anthropic.claudecode` managed preferences domain
    * Windows: `HKLM\SOFTWARE\Policies\ClaudeCode` registry key with a `Settings` value containing JSON (deployed via Group Policy or Intune)
    * Windows (user-level): `HKCU\SOFTWARE\Policies\ClaudeCode` (lowest policy priority, only used when no admin-level source exists)
  * **File-based**: `managed-settings.json` and `managed-mcp.json` deployed to system directories:
    * macOS: `/Library/Application Support/ClaudeCode/`
    * Linux and WSL: `/etc/claude-code/`
    * Windows: `C:\Program Files\ClaudeCode\`

    The legacy Windows path `C:\ProgramData\ClaudeCode\managed-settings.json` is no longer supported as of v2.1.75. Administrators who deployed settings to that location must migrate files to `C:\Program Files\ClaudeCode\managed-settings.json`.

    File-based managed settings also support a drop-in directory at `managed-settings.d/` in the same system directory alongside `managed-settings.json`. Following the systemd convention, `managed-settings.json` is merged first as the base, then all `*.json` files in the drop-in directory are sorted alphabetically and merged on top.

  See [managed settings](/en/permissions#managed-only-settings) and [Managed MCP configuration](/en/managed-mcp) for details.
* **Other configuration** is stored in `~/.claude.json`. This file contains your OAuth session, [MCP server](/en/mcp) configurations for user and local scopes, per-project state (allowed tools, trust settings), and various caches. Project-scoped MCP servers are stored separately in `.mcp.json`.

```JSON Example settings.json theme={null}
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test *)",
      "Read(~/.zshrc)"
    ],
    "deny": [
      "Bash(curl *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp"
  }
}
```

The `$schema` line points to the [official JSON schema](https://json.schemastore.org/claude-code-settings.json) for Claude Code settings. Adding it to your `settings.json` enables autocomplete and inline validation in editors that support JSON schema validation.

### Available settings

`settings.json` supports a number of options:

| Key                          | Description                                                                                                                                                                                                                                                                       | Example                                                     |
| :--------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------- |
| `agent`                      | Run the main thread as a named subagent, and set the default agent for sessions dispatched from `claude agents`. Applies that subagent's system prompt, tool restrictions, and model. See [Invoke subagents explicitly](/en/sub-agents#invoke-subagents-explicitly)               | `"code-reviewer"`                                           |
| `alwaysThinkingEnabled`      | Enable [extended thinking](/en/model-config#extended-thinking) by default for all sessions. Typically configured via the `/config` command rather than editing directly                                                                                                            | `true`                                                      |
| `apiKeyHelper`               | Custom script, to be executed in `/bin/sh`, to generate an auth value. This value will be sent as `X-Api-Key` and `Authorization: Bearer` headers for model requests. Set the refresh interval with [`CLAUDE_CODE_API_KEY_HELPER_TTL_MS`](/en/env-vars)                            | `/bin/generate_temp_api_key.sh`                             |
| `attribution`                | Customize attribution for git commits and pull requests. See [Attribution settings](#attribution-settings)                                                                                                                                                                        | `{"commit": "🤖 Generated with Claude Code", "pr": ""}`     |
| `autoMemoryEnabled`          | Enable [auto memory](/en/memory#enable-or-disable-auto-memory). When `false`, Claude does not read from or write to the auto memory directory. Default: `true`                                                                                                                      | `false`                                                     |
| `autoMemoryDirectory`        | Custom directory for [auto memory](/en/memory#storage-location) storage. Accepts an absolute path or a `~/`-prefixed path                                                                                                                                                          | `"~/my-memory-dir"`                                         |
| `autoUpdatesChannel`         | Release channel to follow for updates. Use `"stable"` for a version that is typically about one week old, or `"latest"` (default) for the most recent release. To disable auto-updates entirely, set [`DISABLE_AUTOUPDATER`](/en/setup#disable-auto-updates) in `env`               | `"stable"`                                                  |
| `availableModels`            | Restrict which models users can select for the main session, [subagents](/en/sub-agents), and the [advisor](/en/advisor). See [Restrict model selection](/en/model-config#restrict-model-selection)                                                                                | `["sonnet", "haiku"]`                                       |
| `cleanupPeriodDays`          | Session files older than this period are deleted at startup (default: 30 days, minimum 1). Setting to `0` is rejected with a validation error                                                                                                                                       | `20`                                                        |
| `defaultShell`               | Default shell for input-box `!` commands. Accepts `"bash"` (default) or `"powershell"`. Setting `"powershell"` routes interactive `!` commands through PowerShell on Windows                                                                                                        | `"powershell"`                                              |
| `disableAgentView`           | Set to `true` to turn off [background agents and agent view](/en/agent-view): `claude agents`, `--bg`, `/background`, and the on-demand supervisor. Equivalent to setting `CLAUDE_CODE_DISABLE_AGENT_VIEW` to `1`                                                                    | `true`                                                      |
| `disableAllHooks`            | Disable all [hooks](/en/hooks) and any custom [status line](/en/statusline)                                                                                                                                                                                                        | `true`                                                      |
| `disableBundledSkills`       | Set to `true` to disable the [skills](/en/skills) and workflows that ship with Claude Code. Equivalent to setting `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` to `1`                                                                                                                       | `true`                                                      |
| `disableWorkflows`           | Disable [dynamic workflows](/en/workflows#turn-workflows-off) and the bundled workflow commands. Default: `false`. Equivalent to setting `CLAUDE_CODE_DISABLE_WORKFLOWS` to `1`                                                                                                     | `true`                                                      |
| `editorMode`                 | Key binding mode for the input prompt: `"normal"` or `"vim"`. Default: `"normal"`. Appears in `/config` as **Editor mode**                                                                                                                                                         | `"vim"`                                                     |
| `effortLevel`                | Persist the [effort level](/en/model-config#adjust-effort-level) across sessions. Accepts `"low"`, `"medium"`, `"high"`, or `"xhigh"`                                                                                                                                               | `"xhigh"`                                                   |
| `enableAllProjectMcpServers` | Automatically approve all MCP servers defined in project `.mcp.json` files                                                                                                                                                                                                        | `true`                                                      |
| `enabledMcpjsonServers`      | List of specific MCP servers from `.mcp.json` files to approve                                                                                                                                                                                                                    | `["memory", "github"]`                                      |
| `enforceAvailableModels`     | When `true` and `availableModels` is a non-empty list in managed or policy settings, the Default model is also constrained to the allowlist. Requires Claude Code v2.1.175 or later                                                                                                 | `true`                                                      |
| `env`                        | Environment variables applied to every session and to subprocesses Claude Code spawns from it                                                                                                                                                                                      | `{"FOO": "bar"}`                                            |
| `disabledMcpjsonServers`     | List of specific MCP servers from `.mcp.json` files to reject                                                                                                                                                                                                                     | `["filesystem"]`                                            |
| `fallbackModel`              | Fallback model(s) to try in order when the primary model is overloaded or unavailable. `"default"` expands to the default model. Chains are capped at three models. See [Fallback model chains](/en/model-config#fallback-model-chains)                                              | `["claude-sonnet-4-6", "claude-haiku-4-5"]`                 |
| `forceLoginMethod`           | Use `claudeai` to restrict login to Claude.ai accounts, `console` to restrict login to Claude Console accounts                                                                                                                                                                     | `claudeai`                                                  |
| `forceLoginOrgUUID`          | Require login to belong to a specific Anthropic organization. Accepts a single UUID string, which also pre-selects that organization during login, or an array of UUIDs where any listed organization is accepted                                                                  | `"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"`                    |
| `gcpAuthRefresh`             | Custom script that refreshes GCP Application Default Credentials when they expire or cannot be loaded. See [advanced credential configuration](/en/google-vertex-ai#advanced-credential-configuration)                                                                              | `gcloud auth application-default login`                     |
| `hooks`                      | Configure custom commands to run at lifecycle events. See [hooks documentation](/en/hooks) for format                                                                                                                                                                              | See [hooks](/en/hooks)                                      |
| `includeCoAuthoredBy`        | **Deprecated**: Use `attribution` instead. Whether to include the `co-authored-by Claude` byline in git commits and pull requests (default: `true`)                                                                                                                                | `false`                                                     |
| `minimumVersion`             | Floor that prevents background auto-updates and `claude update` from installing a version below this one. For a hard floor that blocks startup entirely, see `requiredMinimumVersion`                                                                                                | `"2.1.100"`                                                 |
| `model`                      | Override the default model to use for Claude Code. `--model` and [`ANTHROPIC_MODEL`](/en/model-config#environment-variables) override this for one session                                                                                                                          | `"claude-sonnet-4-6"`                                       |
| `modelOverrides`             | Map Anthropic model IDs to provider-specific model IDs such as Bedrock inference profile ARNs. See [Override model IDs per version](/en/model-config#override-model-ids-per-version)                                                                                                | `{"claude-opus-4-6": "arn:aws:bedrock:..."}`                |
| `otelHeadersHelper`          | Script to generate dynamic OpenTelemetry headers. Runs at startup and periodically. See [Dynamic headers](/en/monitoring-usage#dynamic-headers)                                                                                                                                    | `/bin/generate_otel_headers.sh`                             |
| `outputStyle`                | Configure an output style to adjust the system prompt. See [output styles documentation](/en/output-styles)                                                                                                                                                                        | `"Explanatory"`                                             |
| `permissions`                | See table below for structure of permissions.                                                                                                                                                                                                                                     |                                                             |
| `plansDirectory`             | Customize where plan files are stored. Path is relative to project root. Default: `~/.claude/plans`                                                                                                                                                                                | `"./plans"`                                                 |
| `requiredMaximumVersion`     | Managed settings only. Maximum Claude Code version allowed to start. If the running version is newer, Claude Code exits at startup. Versions that predate this setting ignore it                                                                                                    | `"2.1.150"`                                                 |
| `requiredMinimumVersion`     | Managed settings only. Minimum Claude Code version required to start. If the running version is older, Claude Code exits at startup. Versions that predate this setting ignore it                                                                                                   | `"2.1.150"`                                                 |
| `respectGitignore`           | Control whether the `@` file picker respects `.gitignore` patterns. When `true` (default), files matching `.gitignore` patterns are excluded from suggestions                                                                                                                       | `false`                                                     |
| `statusLine`                 | Configure a custom status line to display context. See [`statusLine` documentation](/en/statusline)                                                                                                                                                                                | `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `allowedMcpServers`          | When set in managed-settings.json, allowlist of MCP servers users can configure. Undefined = no restrictions, empty array = lockdown. Applies to all scopes. Denylist takes precedence. See [Managed MCP configuration](/en/managed-mcp)                                            | `[{ "serverName": "github" }]`                              |
| `deniedMcpServers`           | When set in managed-settings.json, denylist of MCP servers that are explicitly blocked. Applies to all scopes including managed servers. Denylist takes precedence over allowlist. See [Managed MCP configuration](/en/managed-mcp)                                                 | `[{ "serverName": "filesystem" }]`                          |
| `allowAllClaudeAiMcps`       | (Managed settings only) Load claude.ai connectors alongside a deployed `managed-mcp.json`, which otherwise takes exclusive control and suppresses them. See [Managed MCP configuration](/en/managed-mcp)                                                                            | `true`                                                      |
| `allowManagedMcpServersOnly` | (Managed settings only) Only `allowedMcpServers` from managed settings are respected. `deniedMcpServers` still merges from all sources. See [Managed MCP configuration](/en/managed-mcp)                                                                                            | `true`                                                      |
| `allowManagedHooksOnly`      | (Managed settings only) Only managed hooks, SDK hooks, and hooks from plugins force-enabled in managed settings `enabledPlugins` are loaded. User, project, and all other plugin hooks are blocked                                                                                  | `true`                                                      |
| `allowManagedPermissionRulesOnly` | (Managed settings only) Prevent user and project settings from defining `allow`, `ask`, or `deny` permission rules. Only rules in managed settings apply. See [Managed-only settings](/en/permissions#managed-only-settings)                                                  | `true`                                                      |
| `blockedMarketplaces`        | (Managed settings only) Blocklist of marketplace sources. Enforced on marketplace add and on plugin install, update, refresh, and auto-update. See [Managed marketplace restrictions](/en/plugin-marketplaces#managed-marketplace-restrictions)                                     | `[{ "source": "github", "repo": "untrusted/plugins" }]`     |
| `parentSettingsBehavior`     | (Managed settings only) Controls whether managed settings supplied programmatically by an embedding host process apply when an admin-deployed managed tier is also present. `"first-wins"` (default) or `"merge"`. Requires Claude Code v2.1.133 or later                            | `"merge"`                                                   |
| `policyHelper`               | Admin-deployed executable that computes managed settings dynamically at startup. Only honored from MDM or a system `managed-settings.json` file. Requires Claude Code v2.1.136 or later                                                                                             | `{"path": "/usr/local/bin/claude-policy"}`                  |
| `awsAuthRefresh`             | Custom script that modifies the `.aws` directory (see [advanced credential configuration](/en/amazon-bedrock#advanced-credential-configuration))                                                                                                                                   | `aws sso login --profile myprofile`                         |
| `awsCredentialExport`        | Custom script that outputs JSON with AWS credentials (see [advanced credential configuration](/en/amazon-bedrock#advanced-credential-configuration))                                                                                                                               | `/bin/generate_aws_grant.sh`                                |

### Permission settings

| Keys                           | Description                                                                                                                                                                                                                                                                                                                   | Example                                                                |
| :----------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------- |
| `allow`                        | Array of permission rules to allow tool use. Tool-name globs are supported only in the tool position after a literal `mcp__<server>__` prefix. See [Permission rule syntax](#permission-rule-syntax) below for pattern matching details                                                                                        | `[ "Bash(git diff *)" ]`                                              |
| `ask`                          | Array of permission rules to ask for confirmation upon tool use. See [Permission rule syntax](#permission-rule-syntax) below                                                                                                                                                                                                  | `[ "Bash(git push *)" ]`                                              |
| `deny`                         | Array of permission rules to deny tool use. Use this to exclude sensitive files from Claude Code access. Tool names accept glob patterns: `"*"` denies every tool and `"mcp__*"` denies all MCP tools. See [Permission rule syntax](#permission-rule-syntax) and [Bash permission limitations](/en/permissions#tool-specific-permission-rules) | `[ "WebFetch", "Bash(curl *)", "Read(./.env)", "Read(./secrets/**)" ]` |
| `additionalDirectories`        | Additional [working directories](/en/permissions#working-directories) for file access                                                                                                                                                                                                                                         | `[ "../docs/" ]`                                                       |
| `defaultMode`                  | Default [permission mode](/en/permission-modes) when opening Claude Code. Valid values: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. The `--permission-mode` CLI flag overrides this setting for a single session                                                                                 | `"acceptEdits"`                                                        |
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent `bypassPermissions` mode from being activated. This disables the `--dangerously-skip-permissions` command-line flag. Typically placed in [managed settings](/en/permissions#managed-settings) to enforce organizational policy                                                                   | `"disable"`                                                            |

### Sandbox settings

Configure advanced sandboxing behavior. Sandboxing isolates bash commands from your filesystem and network. See [Sandboxing](/en/sandboxing) for details.

| Keys                                   | Description                                                                                                                                                                                                                                                                       | Example                           |
| :------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------- |
| `enabled`                              | Enable bash sandboxing (macOS, Linux, and WSL2). Default: false                                                                                                                                                                                                                  | `true`                            |
| `failIfUnavailable`                    | Exit with an error at startup if `sandbox.enabled` is true but the sandbox cannot start. When false (default), a warning is shown and commands run unsandboxed                                                                                                                     | `true`                            |
| `autoAllowBashIfSandboxed`             | Auto-approve bash commands when sandboxed. Default: true                                                                                                                                                                                                                          | `true`                            |
| `excludedCommands`                     | Commands that should run outside of the sandbox                                                                                                                                                                                                                                   | `["docker *"]`                    |
| `allowUnsandboxedCommands`             | Allow commands to run outside the sandbox via the `dangerouslyDisableSandbox` parameter. When `false`, the escape hatch is completely disabled and all commands must run sandboxed (or be in `excludedCommands`). Default: true                                                     | `false`                           |
| `filesystem.allowWrite`                | Additional paths where sandboxed commands can write. Arrays are merged across all settings scopes. Also merged with paths from `Edit(...)` allow permission rules                                                                                                                  | `["/tmp/build", "~/.kube"]`       |
| `filesystem.denyWrite`                 | Paths where sandboxed commands cannot write. Arrays are merged across all settings scopes. Also merged with paths from `Edit(...)` deny permission rules                                                                                                                           | `["/etc", "/usr/local/bin"]`      |
| `filesystem.denyRead`                  | Paths where sandboxed commands cannot read. Arrays are merged across all settings scopes. Also merged with paths from `Read(...)` deny permission rules                                                                                                                            | `["~/.aws/credentials"]`          |
| `filesystem.allowRead`                 | Paths to re-allow reading within `denyRead` regions. Takes precedence over `denyRead`. Arrays are merged across all settings scopes                                                                                                                                                | `["."]`                           |
| `filesystem.allowManagedReadPathsOnly` | (Managed settings only) Only `filesystem.allowRead` paths from managed settings are respected. `denyRead` still merges from all sources. Default: false                                                                                                                            | `true`                            |
| `network.allowUnixSockets`             | (macOS only) Unix socket paths accessible in sandbox. Ignored on Linux and WSL2; use `allowAllUnixSockets` instead                                                                                                                                                                | `["~/.ssh/agent-socket"]`         |
| `network.allowAllUnixSockets`          | Allow all Unix socket connections in sandbox. On Linux and WSL2 this is the only way to permit Unix sockets. Default: false                                                                                                                                                       | `true`                            |
| `network.allowLocalBinding`            | Allow binding to localhost ports (macOS only). Default: false                                                                                                                                                                                                                     | `true`                            |
| `network.allowMachLookup`              | Additional XPC/Mach service names the sandbox may look up (macOS only). Supports a single trailing `*` for prefix matching                                                                                                                                                         | `["com.apple.coresimulator.*"]`   |
| `network.allowedDomains`               | Array of domains to allow for outbound network traffic. Supports wildcards (e.g., `*.example.com`)                                                                                                                                                                                | `["github.com", "*.npmjs.org"]`   |
| `network.deniedDomains`                | Array of domains to block for outbound network traffic. Takes precedence over `allowedDomains` when both match. Merged from all settings sources                                                                                                                                   | `["sensitive.cloud.example.com"]` |
| `network.allowManagedDomainsOnly`      | (Managed settings only) Only `allowedDomains` and `WebFetch(domain:...)` allow rules from managed settings are respected. Default: false                                                                                                                                           | `true`                            |
| `network.httpProxyPort`                | HTTP proxy port used if you wish to bring your own proxy. If not specified, Claude will run its own proxy.                                                                                                                                                                         | `8080`                            |
| `network.socksProxyPort`               | SOCKS5 proxy port used if you wish to bring your own proxy. If not specified, Claude will run its own proxy.                                                                                                                                                                       | `8081`                            |
| `enableWeakerNestedSandbox`            | Enable weaker sandbox for unprivileged Docker environments (Linux and WSL2 only). **Reduces security.** Default: false                                                                                                                                                            | `true`                            |
| `enableWeakerNetworkIsolation`         | (macOS only) Allow access to the system TLS trust service in the sandbox. Required for Go-based tools like `gh`, `gcloud`, and `terraform` to verify TLS certificates when using `httpProxyPort` with a MITM proxy and custom CA. **Reduces security.** Default: false             | `true`                            |

**Configuration example:**

```json  theme={null}
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker *"],
    "filesystem": {
      "allowWrite": ["/tmp/build", "~/.kube"],
      "denyRead": ["~/.aws/credentials"]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org", "registry.yarnpkg.com"],
      "deniedDomains": ["uploads.github.com"],
      "allowUnixSockets": [
        "/var/run/docker.sock"
      ],
      "allowLocalBinding": true
    }
  }
}
```

**Filesystem and network restrictions** can be configured in two ways that are merged together:

* **`sandbox.filesystem` settings** (shown above): Control paths at the OS-level sandbox boundary. These restrictions apply to all subprocess commands (e.g., `kubectl`, `terraform`, `npm`), not just Claude's file tools.
* **Permission rules**: Use `Edit` allow/deny rules to control Claude's file tool access, `Read` deny rules to block reads, and `WebFetch` allow/deny rules to control network domains. Paths from these rules are also merged into the sandbox configuration.

### Attribution settings

Claude Code adds attribution to git commits and pull requests. These are configured separately:

* Commits use [git trailers](https://git-scm.com/docs/git-interpret-trailers) (like `Co-Authored-By`) by default, which can be customized or disabled
* Pull request descriptions are plain text

| Keys     | Description                                                                                |
| :------- | :----------------------------------------------------------------------------------------- |
| `commit` | Attribution for git commits, including any trailers. Empty string hides commit attribution |
| `pr`     | Attribution for pull request descriptions. Empty string hides pull request attribution     |

**Default commit attribution:**

```text  theme={null}
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

The model name in the trailer reflects the active model for the session.

**Default pull request attribution:**

```text  theme={null}
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**Example:**

```json  theme={null}
{
  "attribution": {
    "commit": "Generated with AI\n\nCo-Authored-By: AI <ai@example.com>",
    "pr": ""
  }
}
```

The `attribution` setting takes precedence over the deprecated `includeCoAuthoredBy` setting. To hide all attribution, set `commit` and `pr` to empty strings.

### Settings precedence

Settings apply in order of precedence. From highest to lowest:

1. **Managed settings** ([server-managed](/en/server-managed-settings), MDM/OS-level policies, or file-based `managed-settings.json`)
   * Policies deployed by IT through server delivery, MDM configuration profiles, registry policies, or managed settings files
   * Cannot be overridden by any other level, including command line arguments

2. **Command line arguments**
   * Temporary overrides for a specific session. JSON passed via `--settings <file-or-json>` merges with file-based settings using the same rules as the other layers

3. **Local project settings** (`.claude/settings.local.json`)
   * Personal project-specific settings

4. **Shared project settings** (`.claude/settings.json`)
   * Team-shared project settings in source control

5. **User settings** (`~/.claude/settings.json`)
   * Personal global settings

This hierarchy ensures that organizational policies are always enforced while still allowing teams and individuals to customize their experience.

> **Array settings merge across scopes.** When the same array-valued setting (such as `sandbox.filesystem.allowWrite` or `permissions.allow`) appears in multiple scopes, the arrays are **concatenated and deduplicated**, not replaced. Two exceptions: `fallbackModel`, an ordered chain where the highest-precedence file that defines it supplies the entire value, and (as of v2.1.175) `availableModels`, where a managed or policy value replaces lower-precedence entries entirely.

### Key points about the configuration system

* **Memory files (`CLAUDE.md`)**: Contain instructions and context that Claude loads at startup
* **Settings files (JSON)**: Configure permissions, environment variables, and tool behavior
* **Skills**: Custom prompts that can be invoked with `/skill-name` or loaded by Claude automatically
* **MCP servers**: Extend Claude Code with additional tools and integrations
* **Precedence**: Higher-level configurations (Managed) override lower-level ones (User/Project)
* **Inheritance**: Settings merge across scopes; scalar values from higher-priority scopes override, and arrays concatenate. Exceptions: `fallbackModel`, where the highest-precedence scope supplies the whole chain, and `availableModels`, where a managed or policy value replaces lower-precedence entries

### System prompt

Claude Code's internal system prompt is not published. To add custom instructions, use `CLAUDE.md` files or the `--append-system-prompt` flag.

### Excluding sensitive files

To prevent Claude Code from accessing files containing sensitive information (e.g., API keys, secrets, environment files), use the `permissions.deny` setting in your `.claude/settings.json` file:

```json  theme={null}
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./config/credentials.json)",
      "Read(./build)"
    ]
  }
}
```

This replaces the deprecated `ignorePatterns` configuration. Files matching these patterns are excluded from file discovery and search results, and read operations on these files are denied.

## Subagent configuration

Claude Code supports custom AI subagents that can be configured at both user and project levels. These subagents are stored as Markdown files with YAML frontmatter:

* **User subagents**: `~/.claude/agents/` - Available across all your projects
* **Project subagents**: `.claude/agents/` - Specific to your project and can be shared with your team

Subagent files define specialized AI assistants with custom prompts and tool permissions. Learn more about creating and using subagents in the [subagents documentation](/en/sub-agents).

## Plugin configuration

Claude Code supports a plugin system that lets you extend functionality with skills, agents, hooks, and MCP servers. Plugins are distributed through marketplaces and can be configured at both user and repository levels.

### Plugin settings

Plugin-related settings in `settings.json`:

```json  theme={null}
{
  "enabledPlugins": {
    "formatter@acme-tools": true,
    "deployer@acme-tools": true,
    "analyzer@security-plugins": false
  },
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": {
        "source": "github",
        "repo": "acme-corp/claude-plugins"
      }
    }
  }
}
```

#### `enabledPlugins`

Controls which plugins are enabled. Format: `"plugin-name@marketplace-name": true/false`. A plugin with no entry at any scope falls back to its [`defaultEnabled`](/en/plugins-reference#default-enablement) value.

**Scopes**:

* **User settings** (`~/.claude/settings.json`): Personal plugin preferences
* **Project settings** (`.claude/settings.json`): Project-specific plugins shared with team
* **Local settings** (`.claude/settings.local.json`): Per-machine overrides, gitignored when Claude Code creates it
* **Managed settings** (`managed-settings.json`): Organization-wide policy overrides that block installation at all scopes and hide the plugin from the marketplace

> Project settings take precedence over user settings, so setting a plugin to `false` in `~/.claude/settings.json` does not disable a plugin that the project's `.claude/settings.json` enables. To opt out of a project-enabled plugin on your machine, set it to `false` in `.claude/settings.local.json` instead.

**Example**:

```json  theme={null}
{
  "enabledPlugins": {
    "code-formatter@team-tools": true,
    "deployment-tools@team-tools": true,
    "experimental-features@personal": false
  }
}
```

#### `extraKnownMarketplaces`

Defines additional marketplaces that should be made available for the repository. Typically used in repository-level settings to ensure team members have access to required plugin sources.

**When a repository includes `extraKnownMarketplaces`**:

1. Team members are prompted to install the marketplace when they trust the folder
2. Team members are then prompted to install plugins from that marketplace
3. Users can skip unwanted marketplaces or plugins (stored in user settings)
4. Installation respects trust boundaries and requires explicit consent

**Example**:

```json  theme={null}
{
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": {
        "source": "github",
        "repo": "acme-corp/claude-plugins"
      }
    },
    "security-plugins": {
      "source": {
        "source": "git",
        "url": "https://git.example.com/security/plugins.git"
      }
    }
  }
}
```

**Marketplace source types**:

* `github`: GitHub repository (uses `repo`)
* `git`: Any git URL (uses `url`)
* `directory`: Local filesystem path (uses `path`, for development only)
* `hostPattern`: regex pattern to match marketplace hosts (uses `hostPattern`)
* `settings`: inline marketplace declared directly in `settings.json` without a separate hosted repository (uses `name` and `plugins`)

For `github` and `git` sources, set `"skipLfs": true` inside the `source` object to skip Git LFS downloads. Each marketplace entry also accepts an optional `autoUpdate` Boolean; official Anthropic marketplaces default to `true` and all others default to `false`.

#### `strictKnownMarketplaces`

**Managed settings only**: Controls which plugin marketplaces users are allowed to add and install plugins from. This setting can only be configured in [managed settings](#settings-files) and provides administrators with strict control over marketplace sources.

**Allowlist behavior**:

* `undefined` (default): No restrictions - users can add any marketplace
* Empty array `[]`: Complete lockdown - users cannot add any new marketplaces
* List of sources: Users can only add marketplaces that match exactly

Unlike `extraKnownMarketplaces`, which uses named marketplaces with a nested `source`, `strictKnownMarketplaces` uses direct source objects:

```json  theme={null}
{
  "strictKnownMarketplaces": [
    { "source": "github", "repo": "acme-corp/approved-plugins" }
  ]
}
```

Restrictions are checked BEFORE any network requests or filesystem operations, and managed settings cannot be overridden. See [Managed marketplace restrictions](/en/plugin-marketplaces#managed-marketplace-restrictions) for details.

#### `strictPluginOnlyCustomization`

**Managed settings only**: blocks skills, agents, hooks, and MCP servers from user and project sources, so they can only come from plugins or managed settings. The value is either `true` to lock all four surfaces, or an array naming the surfaces to lock (`"skills"`, `"agents"`, `"hooks"`, `"mcp"`). Requires Claude Code v2.1.82 or later.

```json  theme={null}
{
  "strictPluginOnlyCustomization": ["skills", "hooks"]
}
```

### Managing plugins

Use the `/plugin` command to manage plugins interactively:

* Browse available plugins from marketplaces
* Install/uninstall plugins
* Enable/disable plugins
* View plugin details (skills, agents, hooks provided)
* Add/remove marketplaces

Learn more about the plugin system in the [plugins documentation](/en/plugins).

## Environment variables

Environment variables let you control Claude Code behavior without editing settings files. Any variable can also be configured in [`settings.json`](#available-settings) under the `env` key to apply it to every session or roll it out to your team.

See the [environment variables reference](/en/env-vars) for the full list.

## Tools available to Claude

Claude Code has access to a set of tools for reading, editing, searching, running commands, and orchestrating subagents. Tool names are the exact strings you use in permission rules and hook matchers.

See the [tools reference](/en/tools-reference) for the full list and Bash tool behavior details.

## See also

* [Permissions](/en/permissions): permission system, rule syntax, tool-specific patterns, and managed policies
* [Authentication](/en/authentication): set up user access to Claude Code
* [Debug your configuration](/en/debug-your-config): diagnose why a setting, hook, or MCP server isn't taking effect
* [Troubleshoot installation and login](/en/troubleshoot-install): installation, authentication, and platform issues
