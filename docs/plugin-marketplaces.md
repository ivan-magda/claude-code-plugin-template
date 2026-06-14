# Plugin marketplaces

> Create and manage plugin marketplaces to distribute Claude Code extensions across teams and communities.

Plugin marketplaces are catalogs of available plugins that make it easy to discover, install, and manage Claude Code extensions. This guide shows you how to use existing marketplaces and create your own for team distribution.

## Overview

A marketplace is a JSON file that lists available plugins and describes where to find them. Marketplaces provide:

* **Centralized discovery**: Browse plugins from multiple sources in one place
* **Version management**: Track and update plugin versions automatically
* **Team distribution**: Share required plugins across your organization
* **Flexible sources**: Support for git repositories, GitHub repos, local paths, and package managers

### Prerequisites

* Claude Code installed and running
* Basic familiarity with JSON file format
* For creating marketplaces: Git repository or local development environment

## Add and use marketplaces

Add marketplaces using the `/plugin marketplace` commands to access plugins from different sources:

### Add GitHub marketplaces

```shell Add a GitHub repository containing .claude-plugin/marketplace.json theme={null}
/plugin marketplace add owner/repo
```

### Add Git repositories

```shell Add any git repository theme={null}
/plugin marketplace add https://gitlab.com/company/plugins.git
```

### Add local marketplaces for development

```shell Add local directory containing .claude-plugin/marketplace.json theme={null}
/plugin marketplace add ./my-marketplace
```

```shell Add direct path to marketplace.json file theme={null}
/plugin marketplace add ./path/to/marketplace.json
```

```shell Add remote marketplace.json via URL theme={null}
/plugin marketplace add https://url.of/marketplace.json
```

### Install plugins from marketplaces

Once you've added marketplaces, install plugins directly:

```shell Install from any known marketplace theme={null}
/plugin install plugin-name@marketplace-name
```

```shell Browse available plugins interactively theme={null}
/plugin
```

### Verify marketplace installation

After adding a marketplace:

1. **List marketplaces**: Run `/plugin marketplace list` to confirm it's added
2. **Browse plugins**: Use `/plugin` to see available plugins from your marketplace
3. **Test installation**: Try installing a plugin to verify the marketplace works correctly

## Configure team marketplaces

Set up automatic marketplace installation for team projects by specifying required marketplaces in `.claude/settings.json`:

```json  theme={null}
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    },
    "project-specific": {
      "source": {
        "source": "git",
        "url": "https://git.example.com/project-plugins.git"
      }
    }
  }
}
```

When team members trust the repository folder, Claude Code automatically installs these marketplaces and any plugins specified in the `enabledPlugins` field.

### Private repositories

Claude Code supports installing plugins from private repositories. For manual installation and updates, Claude Code uses your existing git credential helpers, so HTTPS access via `gh auth login`, macOS Keychain, or `git-credential-store` works the same as in your terminal. SSH access works as long as the host is already in your `known_hosts` file and the key is loaded in `ssh-agent`.

Background auto-updates run at startup without credential helpers, since interactive prompts would block Claude Code from starting. To enable auto-updates for private marketplaces, set the appropriate authentication token in your environment:

| Provider  | Environment variables        | Notes                                     |
| :-------- | :--------------------------- | :---------------------------------------- |
| GitHub    | `GITHUB_TOKEN` or `GH_TOKEN` | Personal access token or GitHub App token |
| GitLab    | `GITLAB_TOKEN` or `GL_TOKEN` | Personal access token or project token    |
| Bitbucket | `BITBUCKET_TOKEN`            | App password or repository access token   |

Set the token in your shell configuration (for example, `.bashrc`, `.zshrc`) or pass it when running Claude Code:

```bash  theme={null}
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

### Pre-populate plugins for containers

For container images and CI environments, you can pre-populate a plugins directory at build time so Claude Code starts with marketplaces and plugins already available, without cloning anything at runtime. Set the `CLAUDE_CODE_PLUGIN_SEED_DIR` environment variable to point at this directory.

The seed directory mirrors the structure of `~/.claude/plugins`:

```
$CLAUDE_CODE_PLUGIN_SEED_DIR/
  known_marketplaces.json
  marketplaces/<name>/...
  cache/<marketplace>/<plugin>/<version>/...
```

To build a seed directory, run Claude Code once during image build, install the plugins you need, then copy the resulting `~/.claude/plugins` directory into your image and point `CLAUDE_CODE_PLUGIN_SEED_DIR` at it. To skip the copy step, set `CLAUDE_CODE_PLUGIN_CACHE_DIR` to your target seed path during the build so plugins install directly there:

```bash  theme={null}
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins
```

Then set `CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/claude-seed` in your container's runtime environment so Claude Code reads from the seed on startup.

The seed directory is read-only and never written to; auto-updates are disabled for seed marketplaces. Marketplaces declared in the seed take precedence over matching entries in the user's configuration on each startup, and running `/plugin marketplace remove` or `/plugin marketplace update` against a seed-managed marketplace fails with guidance to ask your administrator to update the seed image.

### Managed marketplace restrictions

For organizations requiring strict control over plugin sources, administrators can restrict which marketplaces users are allowed to add using the [`strictKnownMarketplaces`](/en/settings#strictknownmarketplaces) setting in `managed-settings.json`.

| Value               | Behavior                                                         |
| ------------------- | ---------------------------------------------------------------- |
| Undefined (default) | No restrictions. Users can add any marketplace                   |
| Empty array `[]`    | Complete lockdown. Users cannot add any new marketplaces         |
| List of sources     | Users can only add marketplaces that match the allowlist exactly |

Disable all marketplace additions:

```json  theme={null}
{
  "strictKnownMarketplaces": []
}
```

Allow specific marketplaces only, or use regex pattern matching on the host or path:

```json  theme={null}
{
  "strictKnownMarketplaces": [
    {
      "source": "github",
      "repo": "acme-corp/approved-plugins"
    },
    {
      "source": "url",
      "url": "https://plugins.example.com/marketplace.json"
    },
    {
      "source": "hostPattern",
      "hostPattern": "^github\\.example\\.com$"
    },
    {
      "source": "pathPattern",
      "pathPattern": "^/opt/approved/"
    }
  ]
}
```

The allowlist uses exact matching for most source types (no URL normalization), while `hostPattern` and `pathPattern` match against a regex. Restrictions are checked before any network or filesystem operation, on marketplace add and on plugin install, update, refresh, and auto-update. The same enforcement applies to `blockedMarketplaces`. Because these settings live in managed settings, individual users and project configurations cannot override them.

***

## Create your own marketplace

Build and distribute custom plugin collections for your team or community.

### Prerequisites for marketplace creation

* Git repository (GitHub, GitLab, or other git hosting)
* Understanding of JSON file format
* One or more plugins to distribute

### Create the marketplace file

Create `.claude-plugin/marketplace.json` in your repository root:

```json  theme={null}
{
  "name": "company-tools",
  "owner": {
    "name": "DevTools Team",
    "email": "devtools@example.com"
  },
  "plugins": [
    {
      "name": "code-formatter",
      "source": "./plugins/formatter",
      "description": "Automatic code formatting on save",
      "version": "2.1.0",
      "author": {
        "name": "DevTools Team"
      }
    },
    {
      "name": "deployment-tools",
      "source": {
        "source": "github",
        "repo": "company/deploy-plugin"
      },
      "description": "Deployment automation tools"
    }
  ]
}
```

### Marketplace schema

#### Required fields

| Field     | Type   | Description                                                  |
| :-------- | :----- | :---------------------------------------------------------- |
| `name`    | string | Marketplace identifier (kebab-case, no spaces)              |
| `owner`   | object | Marketplace maintainer information (see Owner fields below) |
| `plugins` | array  | List of available plugins                                   |

<Note>
  **Reserved names**: The following marketplace names are reserved for official Anthropic use and cannot be used by third-party marketplaces: `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `claude-plugins-community`, `claude-community`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `anthropic-agent-skills`, `knowledge-work-plugins`, `life-sciences`, `claude-for-legal`, `claude-for-financial-services`, `financial-services-plugins`. Names that impersonate official marketplaces, such as `official-claude-plugins` or `anthropic-tools-v2`, are also blocked.
</Note>

#### Owner fields

| Field   | Type   | Required | Description                      |
| :------ | :----- | :------- | :------------------------------- |
| `name`  | string | Yes      | Name of the maintainer or team   |
| `email` | string | No       | Contact email for the maintainer |

#### Optional fields

| Field                                 | Type   | Description                                                                                                                                                              |
| :------------------------------------ | :----- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `$schema`                             | string | JSON Schema URL for editor autocomplete and validation. Claude Code ignores this field at load time.                                                                    |
| `description`                         | string | Brief marketplace description                                                                                                                                           |
| `version`                             | string | Marketplace manifest version                                                                                                                                            |
| `metadata.pluginRoot`                 | string | Base path for relative plugin sources                                                                                                                                  |
| `allowCrossMarketplaceDependenciesOn` | array  | Other marketplaces that plugins in this marketplace may depend on. Dependencies from a marketplace not listed here are blocked at install. See [Plugin dependencies](/en/plugin-dependencies). |

`description` and `version` are also accepted under `metadata` for backward compatibility.

### Plugin entries

<Note>
  Plugin entries are based on the *plugin manifest schema* (with all fields made optional) plus marketplace-specific fields (`source`, `category`, `tags`, `strict`), with `name` being required.
</Note>

**Required fields:**

| Field    | Type           | Description                               |
| :------- | :------------- | :---------------------------------------- |
| `name`   | string         | Plugin identifier (kebab-case, no spaces) |
| `source` | string\|object | Where to fetch the plugin from            |

#### Optional plugin fields

**Standard metadata fields:**

| Field            | Type    | Description                                                                                                                                                                                                            |
| :--------------- | :------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `displayName`    | string  | Human-readable name shown in UI surfaces. Falls back to `name` when omitted. May contain spaces and any casing. Not used for namespacing or lookup. Requires Claude Code v2.1.143 or later.                            |
| `description`    | string  | Brief plugin description                                                                                                                                                                                              |
| `version`        | string  | Plugin version                                                                                                                                                                                                       |
| `author`         | object  | Plugin author information                                                                                                                                                                                            |
| `homepage`       | string  | Plugin homepage or documentation URL                                                                                                                                                                                 |
| `repository`     | string  | Source code repository URL                                                                                                                                                                                           |
| `license`        | string  | SPDX license identifier (e.g., MIT, Apache-2.0)                                                                                                                                                                       |
| `keywords`       | array   | Tags for plugin discovery and categorization                                                                                                                                                                         |
| `category`       | string  | Plugin category for organization                                                                                                                                                                                     |
| `tags`           | array   | Tags for searchability                                                                                                                                                                                               |
| `strict`         | boolean | Controls whether plugin.json is the authority for component definitions (default: true) <sup>1</sup>                                                                                                                  |
| `defaultEnabled` | boolean | Whether the plugin is enabled after install (default: true). Set to `false` to install the plugin disabled until the user opts in. Takes precedence over the same field in the plugin's `plugin.json`. Requires Claude Code v2.1.154 or later. |

**Component configuration fields:**

| Field        | Type           | Description                                                    |
| :----------- | :------------- | :------------------------------------------------------------- |
| `skills`     | string\|array  | Custom paths to skill directories containing `<name>/SKILL.md` |
| `commands`   | string\|array  | Custom paths to flat `.md` skill files or directories          |
| `agents`     | string\|array  | Custom paths to agent files                                    |
| `hooks`      | string\|object | Custom hooks configuration or path to hooks file               |
| `mcpServers` | string\|object | MCP server configurations or path to MCP config                |
| `lspServers` | string\|object | LSP server configurations or path to LSP config                |

*<sup>1 - When `strict: true` (default), `plugin.json` is the authority for components and the marketplace entry supplements it (both sources are merged). When `strict: false`, the marketplace entry is the entire definition; if the plugin also has a `plugin.json` that declares components, that's a conflict and the plugin fails to load.</sup>*

### Plugin sources

Plugin sources tell Claude Code where to fetch each individual plugin listed in your marketplace. These are set in the `source` field of each plugin entry in `marketplace.json`.

| Source        | Type                            | Fields                             | Notes                                                                                                                                              |
| ------------- | ------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Relative path | `string` (e.g. `"./my-plugin"`) | none                               | Local directory within the marketplace repo. Must start with `./`. Resolved relative to the marketplace root, not the `.claude-plugin/` directory |
| `github`      | object                          | `repo`, `ref?`, `sha?`             |                                                                                                                                                  |
| `url`         | object                          | `url`, `ref?`, `sha?`              | Git URL source                                                                                                                                    |
| `git-subdir`  | object                          | `url`, `path`, `ref?`, `sha?`      | Subdirectory within a git repo. Clones sparsely to minimize bandwidth for monorepos                                                               |
| `npm`         | object                          | `package`, `version?`, `registry?` | Installed via `npm install`                                                                                                                       |

The git-based source types are `github`, `url`, and `git-subdir`. When both `ref` and `sha` are set on any of them, the `sha` is the effective pin.

#### Relative paths

For plugins in the same repository, use a path starting with `./`:

```json  theme={null}
{
  "name": "my-plugin",
  "source": "./plugins/my-plugin"
}
```

Paths resolve relative to the marketplace root (the directory containing `.claude-plugin/`). Do not use `../` to reference paths outside the marketplace root.

#### GitHub repositories

```json  theme={null}
{
  "name": "github-plugin",
  "source": {
    "source": "github",
    "repo": "owner/plugin-repo"
  }
}
```

You can pin to a specific branch, tag, or commit:

```json  theme={null}
{
  "name": "github-plugin",
  "source": {
    "source": "github",
    "repo": "owner/plugin-repo",
    "ref": "v2.0.0",
    "sha": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0"
  }
}
```

| Field  | Type   | Description                                                           |
| :----- | :----- | :------------------------------------------------------------------- |
| `repo` | string | Required. GitHub repository in `owner/repo` format                    |
| `ref`  | string | Optional. Git branch or tag (defaults to repository default branch)   |
| `sha`  | string | Optional. Full 40-character git commit SHA to pin to an exact version |

#### Git repositories

```json  theme={null}
{
  "name": "git-plugin",
  "source": {
    "source": "url",
    "url": "https://gitlab.com/team/plugin.git"
  }
}
```

You can pin to a specific branch, tag, or commit:

```json  theme={null}
{
  "name": "git-plugin",
  "source": {
    "source": "url",
    "url": "https://gitlab.com/team/plugin.git",
    "ref": "main",
    "sha": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0"
  }
}
```

| Field | Type   | Description                                                           |
| :---- | :----- | :------------------------------------------------------------------- |
| `url` | string | Required. Full git repository URL (`https://` or `git@`)             |
| `ref` | string | Optional. Git branch or tag (defaults to repository default branch)  |
| `sha` | string | Optional. Full 40-character git commit SHA to pin to an exact version |

#### Git subdirectories

Use `git-subdir` to point to a plugin that lives inside a subdirectory of a git repository. Claude Code uses a sparse, partial clone to fetch only the subdirectory, minimizing bandwidth for large monorepos.

```json  theme={null}
{
  "name": "monorepo-plugin",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/org/monorepo.git",
    "path": "tools/claude-plugin"
  }
}
```

| Field  | Type   | Description                                                                                              |
| :----- | :----- | :------------------------------------------------------------------------------------------------------ |
| `url`  | string | Required. Git repository URL, GitHub `owner/repo` shorthand, or SSH URL                                  |
| `path` | string | Required. Subdirectory path within the repo containing the plugin (for example, `"tools/claude-plugin"`) |
| `ref`  | string | Optional. Git branch or tag (defaults to repository default branch)                                      |
| `sha`  | string | Optional. Full 40-character git commit SHA to pin to an exact version                                    |

#### npm packages

Plugins distributed as npm packages are installed using `npm install`. This works with any package on the public npm registry or a private registry your team hosts.

```json  theme={null}
{
  "name": "my-npm-plugin",
  "source": {
    "source": "npm",
    "package": "@acme/claude-plugin"
  }
}
```

| Field      | Type   | Description                                                                                  |
| :--------- | :----- | :------------------------------------------------------------------------------------------ |
| `package`  | string | Required. Package name or scoped package (for example, `@org/plugin`)                        |
| `version`  | string | Optional. Version or version range (for example, `2.1.0`, `^2.0.0`, `~1.5.0`)                |
| `registry` | string | Optional. Custom npm registry URL. Defaults to the system npm registry (typically npmjs.org) |

#### Advanced plugin entries

Plugin entries can override default component locations and provide additional metadata. Note that `${CLAUDE_PLUGIN_ROOT}` is an environment variable that resolves to the plugin's installation directory (for details see [Environment variables](/en/plugins-reference#environment-variables)):

```json  theme={null}
{
  "name": "enterprise-tools",
  "source": {
    "source": "github",
    "repo": "company/enterprise-plugin"
  },
  "description": "Enterprise workflow automation tools",
  "version": "2.1.0",
  "author": {
    "name": "Enterprise Team",
    "email": "enterprise@example.com"
  },
  "homepage": "https://docs.example.com/plugins/enterprise-tools",
  "repository": "https://github.com/company/enterprise-plugin",
  "license": "MIT",
  "keywords": ["enterprise", "workflow", "automation"],
  "category": "productivity",
  "commands": [
    "./commands/core/",
    "./commands/enterprise/",
    "./commands/experimental/preview.md"
  ],
  "agents": [
    "./agents/security-reviewer.md",
    "./agents/compliance-checker.md"
  ],
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{"type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"}]
      }
    ]
  },
  "mcpServers": {
    "enterprise-db": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  },
  "strict": false
}
```

<Note>
  **Schema relationship**: Plugin entries use the plugin manifest schema with all fields made optional, plus marketplace-specific fields (`source`, `strict`, `category`, `tags`). This means any field valid in a `plugin.json` file can also be used in a marketplace entry. When `strict: false`, the marketplace entry is the entire plugin definition; if the plugin's `plugin.json` also declares components, that is a conflict and the plugin fails to load. When `strict: true` (default), `plugin.json` is the authority and marketplace fields supplement it (both are merged).
</Note>

#### Strict mode

The `strict` field controls whether `plugin.json` is the authority for component definitions (skills, agents, hooks, MCP servers, output styles).

| Value            | Behavior                                                                                                                                                         |
| :--------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `true` (default) | `plugin.json` is the authority. The marketplace entry can supplement it with additional components, and both sources are merged.                                 |
| `false`          | The marketplace entry is the entire definition. If the plugin also has a `plugin.json` that declares components, that's a conflict and the plugin fails to load. |

***

## Host and distribute marketplaces

Choose the best hosting strategy for your plugin distribution needs.

### Host on GitHub (recommended)

GitHub provides the easiest distribution method:

1. **Create a repository**: Set up a new repository for your marketplace
2. **Add marketplace file**: Create `.claude-plugin/marketplace.json` with your plugin definitions
3. **Share with teams**: Team members add with `/plugin marketplace add owner/repo`

**Benefits**: Built-in version control, issue tracking, and team collaboration features.

### Host on other git services

Any git hosting service works for marketplace distribution, using a URL to an arbitrary git repository.

For example, using GitLab:

```shell  theme={null}
/plugin marketplace add https://gitlab.com/company/plugins.git
```

### Use local marketplaces for development

Test your marketplace locally before distribution:

```shell Add local marketplace for testing theme={null}
/plugin marketplace add ./my-local-marketplace
```

```shell Test plugin installation theme={null}
/plugin install test-plugin@my-local-marketplace
```

## Manage marketplace operations

### List known marketplaces

```shell List all configured marketplaces theme={null}
/plugin marketplace list
```

Shows all configured marketplaces with their sources and status.

### Update marketplace metadata

```shell Refresh marketplace metadata theme={null}
/plugin marketplace update marketplace-name
```

Refreshes plugin listings and metadata from the marketplace source.

### Remove a marketplace

```shell Remove a marketplace theme={null}
/plugin marketplace remove marketplace-name
```

Removes the marketplace from your configuration.

<Warning>
  Removing a marketplace from its last remaining scope also uninstalls any plugins you installed from it. To refresh a marketplace without losing installed plugins, use `claude plugin marketplace update` instead.
</Warning>

***

## Manage marketplaces from the CLI

Claude Code provides non-interactive `claude plugin marketplace` subcommands for scripting and automation. These are equivalent to the `/plugin marketplace` commands available inside an interactive session.

### Plugin marketplace add

```bash  theme={null}
claude plugin marketplace add <source> [options]
```

`<source>` is a GitHub `owner/repo` shorthand, git URL, remote URL to a `marketplace.json` file, or local directory path. To pin to a branch or tag, append `@ref` to the GitHub shorthand or `#ref` to a git URL.

| Option                | Description                                                                                                                                         | Default |
| :-------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------- | :------ |
| `--scope <scope>`     | Where to declare the marketplace: `user`, `project`, or `local`. See [Plugin installation scopes](/en/plugins-reference#plugin-installation-scopes) | `user`  |
| `--sparse <paths...>` | Limit checkout to specific directories via git sparse-checkout. Useful for monorepos                                                                |         |

### Plugin marketplace list

```bash  theme={null}
claude plugin marketplace list [options]
```

| Option   | Description    |
| :------- | :------------- |
| `--json` | Output as JSON |

With `--json`, each entry includes `name`, `source`, and source-specific fields: `repo` for GitHub sources, `url` for git and URL sources, and `path` for local sources. GitHub and git sources also include a `ref` field when the marketplace was added with a pinned branch or tag.

### Plugin marketplace remove

Remove a configured marketplace. The alias `rm` is also accepted.

```bash  theme={null}
claude plugin marketplace remove <name> [options]
```

| Option            | Description                                                                                                                                                                                                                  | Default      |
| :---------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------- |
| `--scope <scope>` | Restrict removal to a single settings scope: `user`, `project`, or `local`. See [Plugin installation scopes](/en/plugins-reference#plugin-installation-scopes). When omitted, the declaration is removed from every editable scope | (all scopes) |

### Plugin marketplace update

```bash  theme={null}
claude plugin marketplace update [name]
```

Refreshes marketplaces from their sources to retrieve new plugins and version changes. Updates all marketplaces if `name` is omitted.

***

## Version resolution and release channels

Plugin versions determine cache paths and update detection: if the resolved version matches what a user already has, `/plugin update` and auto-update skip the plugin.

Claude Code resolves a plugin's version from the first of these that is set:

1. `version` in the plugin's `plugin.json`
2. `version` in the plugin's marketplace entry
3. The git commit SHA of the plugin's source

For the git-based source types `github`, `url`, `git-subdir`, and relative paths inside a git-hosted marketplace, you can omit `version` entirely and every new commit is treated as a new version. This is the simplest setup for internal or actively-developed plugins.

<Warning>
  Setting `version` pins the plugin. If `plugin.json` declares `"version": "1.0.0"`, pushing new commits without changing that string does nothing for existing users, because Claude Code sees the same version and keeps the cached copy. Bump the field on every release, or omit it to use the commit SHA.

  Avoid setting `version` in both `plugin.json` and the marketplace entry. The `plugin.json` value always wins silently, so a stale manifest version can mask a version you set in `marketplace.json`.
</Warning>

### Set up release channels

To support "stable" and "latest" release channels for your plugins, you can set up two marketplaces that point to different refs or SHAs of the same repo, then assign the two marketplaces to different user groups through [managed settings](/en/settings#settings-files).

```json  theme={null}
{
  "name": "stable-tools",
  "plugins": [
    {
      "name": "code-formatter",
      "source": {
        "source": "github",
        "repo": "acme-corp/code-formatter",
        "ref": "stable"
      }
    }
  ]
}
```

Each channel must resolve to a different version. If you use explicit versions, `plugin.json` must declare a different `version` at each pinned ref. If you omit `version`, the distinct commit SHAs already distinguish the channels.

### Pin dependency versions

A plugin can constrain its dependencies to a semver range so that updates to a dependency do not break the dependent plugin. See [Constrain plugin dependency versions](/en/plugin-dependencies) for the `{plugin-name}--v{version}` git-tag convention and range syntax.

***

## Troubleshooting marketplaces

### Common marketplace issues

#### Marketplace not loading

**Symptoms**: Can't add marketplace or see plugins from it

**Solutions**:

* Verify the marketplace URL is accessible
* Check that `.claude-plugin/marketplace.json` exists at the specified path
* Ensure JSON syntax is valid using `claude plugin validate` or `/plugin validate`
* For private repositories, confirm you have access permissions

#### Plugin installation failures

**Symptoms**: Marketplace appears but plugin installation fails

**Solutions**:

* Verify plugin source URLs are accessible
* Check that plugin directories contain required files
* For GitHub sources, ensure repositories are public or you have access
* Test plugin sources manually by cloning/downloading
* If the source pins both `ref` and `sha`, a deleted upstream branch or tag does not block installation. If the install still fails, confirm the pinned commit still exists in the repository

#### Private repository authentication fails

**Symptoms**: Authentication errors when installing plugins from private repositories

**Solutions**:

For manual installation and updates:

* Verify you're authenticated with your git provider (for example, run `gh auth status` for GitHub)
* Check that your credential helper is configured correctly: `git config --global credential.helper`
* Try cloning the repository manually to verify your credentials work

For background auto-updates:

* Set the appropriate token in your environment: `echo $GITHUB_TOKEN`
* Check that the token has the required permissions (read access to the repository)
* For GitHub, ensure the token has the `repo` scope for private repositories
* For GitLab, ensure the token has at least `read_repository` scope
* Verify the token hasn't expired

#### Marketplace updates fail in offline environments

**Symptoms**: Marketplace `git pull` fails and Claude Code wipes the existing cache, causing plugins to become unavailable.

**Cause**: By default, when a `git pull` fails, Claude Code removes the stale clone and attempts to re-clone. In offline or airgapped environments, re-cloning fails the same way, leaving the marketplace directory empty.

**Solution**: Set `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` to keep the existing cache when the pull fails instead of wiping it:

```bash
export CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1
```

With this variable set, Claude Code retains the stale marketplace clone on `git pull` failure and continues using the last-known-good state. For fully offline deployments where the repository will never be reachable, use [`CLAUDE_CODE_PLUGIN_SEED_DIR`](#pre-populate-plugins-for-containers) to pre-populate the plugins directory at build time instead.

#### Git operations time out

**Symptoms**: Plugin installation or marketplace updates fail with a timeout error like "Git clone timed out after 120s" or "Git pull timed out after 120s".

**Cause**: Claude Code uses a 120-second timeout for all git operations, including cloning plugin repositories and pulling marketplace updates. Large repositories or slow network connections may exceed this limit.

**Solution**: Increase the timeout using the `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` environment variable. The value is in milliseconds:

```bash
export CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS=300000  # 5 minutes
```

#### Plugins with relative paths fail in URL-based marketplaces

**Symptoms**: Added a marketplace via URL (such as `https://example.com/marketplace.json`), but plugins with relative path sources like `"./plugins/my-plugin"` fail to install with "path not found" errors.

**Cause**: URL-based marketplaces only download the `marketplace.json` file itself. They do not download plugin files from the server. Relative paths in the marketplace entry reference files on the remote server that were not downloaded.

**Solutions**:

* **Use external sources**: Change plugin entries to use GitHub, npm, or git URL sources instead of relative paths:
  ```json
  { "name": "my-plugin", "source": { "source": "github", "repo": "owner/repo" } }
  ```
* **Use a Git-based marketplace**: Host your marketplace in a Git repository and add it with the git URL. Git-based marketplaces clone the entire repository, making relative paths work correctly.

#### Files not found after installation

**Symptoms**: Plugin installs but references to files fail, especially files outside the plugin directory

**Cause**: Plugins are copied to a cache directory rather than used in-place. Paths that reference files outside the plugin's directory (such as `../shared-utils`) won't work because those files aren't copied.

**Solutions**: See [Plugin caching and file resolution](/en/plugins-reference#plugin-caching-and-file-resolution) for workarounds including symlinks and directory restructuring.

### Validation and testing

Test your marketplace before sharing:

```bash Validate marketplace JSON syntax theme={null}
claude plugin validate .
```

Or from within Claude Code:

```shell  theme={null}
/plugin validate .
```

```shell Add marketplace for testing theme={null}
/plugin marketplace add ./path/to/marketplace
```

```shell Install test plugin theme={null}
/plugin install test-plugin@marketplace-name
```

For complete plugin testing workflows, see [Test your plugins locally](/en/plugins#test-your-plugins-locally). For technical troubleshooting, see [Plugins reference](/en/plugins-reference).

### Marketplace validation errors

Run `claude plugin validate .` or `/plugin validate .` from your marketplace directory to check for issues. When pointed at a marketplace directory, the validator checks `marketplace.json` only: schema, duplicate plugin names, source path traversal, and version mismatches against each referenced `plugin.json`. To validate an individual plugin's `plugin.json` and its skill, agent, command, and hook files, run the command against the plugin directory itself, for example `claude plugin validate ./plugins/my-plugin`. Common errors:

| Error                                             | Cause                                           | Solution                                                                                                                                    |
| :------------------------------------------------ | :---------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------ |
| `File not found: .claude-plugin/marketplace.json` | Missing manifest                                | Create `.claude-plugin/marketplace.json` with required fields                                                                               |
| `Invalid JSON syntax: Unexpected token...`        | JSON syntax error in marketplace.json           | Check for missing commas, extra commas, or unquoted strings                                                                                 |
| `Duplicate plugin name "x" found in marketplace`  | Two plugins share the same name                 | Give each plugin a unique `name` value                                                                                                      |
| `plugins[0].source: Path contains ".."`           | Source path contains `..`                       | Use paths relative to the marketplace root without `..`. See [Relative paths](#relative-paths)                                              |
| `YAML frontmatter failed to parse: ...`           | Invalid YAML in a skill, agent, or command file | Fix the YAML syntax in the frontmatter block. Reported only when validating a plugin directory                                              |
| `Invalid JSON syntax: ...` (hooks.json)           | Malformed `hooks/hooks.json`                    | Fix JSON syntax. A malformed `hooks/hooks.json` prevents the entire plugin from loading. Reported only when validating a plugin directory   |

**Warnings** (non-blocking):

* `Marketplace has no plugins defined`: add at least one plugin to the `plugins` array
* `No marketplace description provided`: add a top-level `description` to help users understand your marketplace
* `Plugin name "x" is not kebab-case`: rename to lowercase letters, digits, and hyphens only (for example, `my-plugin`). Claude Code accepts other forms, but the Claude.ai marketplace sync rejects them.

***

## Next steps

### For marketplace users

* **Discover community marketplaces**: Search GitHub for Claude Code plugin collections
* **Contribute feedback**: Report issues and suggest improvements to marketplace maintainers
* **Share useful marketplaces**: Help your team discover valuable plugin collections

### For marketplace creators

* **Build plugin collections**: Create themed marketplace around specific use cases
* **Establish versioning**: Implement clear versioning and update policies
* **Community engagement**: Gather feedback and maintain active marketplace communities
* **Documentation**: Provide clear README files explaining your marketplace contents

### For organizations

* **Private marketplaces**: Set up internal marketplaces for proprietary tools
* **Governance policies**: Establish guidelines for plugin approval and security review
* **Training resources**: Help teams discover and adopt useful plugins effectively

## See also

* [Plugins](/en/plugins) - Installing and using plugins
* [Plugins reference](/en/plugins-reference) - Complete technical specifications and schemas
* [Plugin development](/en/plugins#develop-more-complex-plugins) - Creating your own plugins
* [Settings](/en/settings#plugin-configuration) - Plugin configuration options
