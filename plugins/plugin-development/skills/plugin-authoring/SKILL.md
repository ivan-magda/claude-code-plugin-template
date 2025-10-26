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
□ .claude-plugin/plugin.json exists
□ Component dirs at plugin root (not inside .claude-plugin/)
□ Commands use kebab-case naming
□ Skills have valid SKILL.md frontmatter
□ Hooks use ${CLAUDE_PLUGIN_ROOT} for paths
```

### Release Checklist

```
□ plugin.json: name/version/keywords present
□ commands/agents/skills/hooks paths resolve
□ local marketplace installs cleanly
□ docs: README + examples linked
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
2. Edit `skills/<name>/SKILL.md`
3. Add frontmatter: `name` (required), `description` (required), `allowed-tools` (optional)
4. Keep SKILL.md concise; place details in sibling files

### Troubleshooting

- **Plugin not loading?** Check `plugin.json` paths are relative to plugin root
- **Commands not showing?** Verify `commands` field points to `./commands/`
- **Hooks not running?** Ensure scripts are executable (`chmod +x`)
- **Skill not triggering?** Check `name` matches directory and is lowercase-hyphenated

## Notes

- Prefer templates & scripts over freeform generation for deterministic tasks
- If writes are needed, propose a command or a PR-style diff first
- For complex audits, delegate to `/agents plugin-reviewer`
- Always validate with `/plugin-development:validate` before testing
