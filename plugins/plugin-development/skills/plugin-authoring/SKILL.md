---
name: plugin-authoring
description: Expert guidance for Claude Code plugin development. Use when creating or modifying plugins, working with plugin.json or marketplace.json, or adding commands, agents, Skills, or hooks.
allowed-tools: Read, Grep, Glob
---

# Plugin Authoring (Skill)

You are the canonical guide for Claude Code plugin development. Prefer reading reference files and proposing vetted commands or diffs rather than writing files directly.

## Triggers & Scope

Activate whenever context includes `.claude-plugin/`, `plugin.json`, `marketplace.json`, `commands/`, `agents/`, `skills/`, or `hooks/`.

## Flow of Operation

1. **Diagnose** current repo layout (read-only)
2. **Propose** the minimal safe action (scaffold, validate, or review)
3. **Execute** via `/plugin-development:...` commands when the user agrees
4. **Escalate** to the **plugin-reviewer** agent for deep audits
5. **Guardrails**: default to read-only; ask before edits

## Quick Links (Progressive Disclosure)

- **Schemas**: [schemas/plugin-manifest.md](schemas/plugin-manifest.md), [schemas/hooks-schema.md](schemas/hooks-schema.md), [schemas/marketplace-schema.md](schemas/marketplace-schema.md)
- **Templates**: [templates/](templates/)
- **Examples**: [examples/](examples/)
- **Best practices**: [best-practices/](best-practices/)

## Checklists

### Component Checklist

```
□ .claude-plugin/plugin.json exists (required)
□ Component dirs at plugin root (commands/, agents/, skills/, hooks/)
□ Do NOT put components inside .claude-plugin/ directory
□ Commands use kebab-case naming
□ Skills have valid frontmatter (name + description required)
□ Skills name matches directory (lowercase-hyphenated, max 64 chars)
□ Hooks use ${CLAUDE_PLUGIN_ROOT} for paths (not relative paths)
□ All scripts are executable (chmod +x)
```

### Release Checklist

```
□ plugin.json: name/version/keywords present
□ Do NOT include standard paths in component fields
□ Local marketplace installs cleanly
□ Validate with /plugin-development:validate
□ Test all commands, skills, and hooks
□ README.md exists with usage examples
```

## Playbooks

- **Scaffold** → `/plugin-development:init <name>` then fill templates
- **Add a component** → `/plugin-development:add-command|add-skill|add-agent|add-hook`
- **Validate** → `/plugin-development:validate` (schema & structure checks)
- **Test locally** → `/plugin-development:test-local` (dev marketplace)

## Common Workflows

### Creating a New Plugin

1. Run `/plugin-development:init <plugin-name>` to scaffold structure
2. Edit `.claude-plugin/plugin.json` with your metadata
3. Add components using `/plugin-development:add-command`, etc.
4. Validate with `/plugin-development:validate`
5. Test locally with `/plugin-development:test-local`

### Adding a Slash Command

1. Run `/plugin-development:add-command <name> <description>`
2. Edit `commands/<name>.md` with instructions
3. Add frontmatter: `description` and `argument-hint`
4. Test: `/plugin install` your plugin, then `/<name>`

### Adding a Skill

1. Run `/plugin-development:add-skill <name> <when-to-use>`
2. Edit `skills/<name>/SKILL.md` with your instructions
3. **Frontmatter requirements**:
   - `name`: lowercase, hyphenated, max 64 chars (required)
   - `description`: include both WHAT the Skill does AND WHEN to use it, max 1024 chars (required)
   - `allowed-tools`: comma-separated list of tools (optional, restricts tool access)
4. Keep SKILL.md concise; place details in sibling files (reference.md, examples.md, scripts/)

### Troubleshooting

- **Plugin not loading?** Check `plugin.json` paths are relative to plugin root. Do NOT include `commands`, `agents`, `skills`, or `hooks` fields for standard directories.
- **Commands not showing?** Verify `commands/` directory exists at plugin root with `.md` files. Do NOT add `commands` field to `plugin.json` for standard paths.
- **Hooks not running?** Ensure scripts are executable (`chmod +x`) and use `${CLAUDE_PLUGIN_ROOT}` for paths
- **Skill not triggering?** Check `name` matches directory and is lowercase-hyphenated (max 64 chars). Ensure `description` includes both what and when to use (max 1024 chars)

## Notes

- Prefer templates & scripts over freeform generation for deterministic tasks
- If writes are needed, propose a command or a PR-style diff first
- For complex audits, delegate to `/agents plugin-reviewer`
- Always validate with `/plugin-development:validate` before testing
