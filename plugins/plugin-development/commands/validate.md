---
description: Validate plugin structure, manifest, and component files for common issues
---

# Validate Plugin

Comprehensive validation of plugin structure, configuration, and components.

## Prerequisites

- Must be run from a plugin root directory (containing `.claude-plugin/plugin.json`)

## Instructions

### What This Command Does

Performs a thorough validation of the plugin:

1. **Structure validation**: Check directories and files exist
2. **Manifest validation**: Verify plugin.json is valid and complete
3. **Component validation**: Check commands, agents, skills, hooks
4. **Path validation**: Ensure all paths are relative and resolve correctly
5. **Naming validation**: Verify kebab-case conventions
6. **Common issues**: Flag typical mistakes

### Validation Steps

#### 1. Check Core Structure

Verify these exist:
```
□ .claude-plugin/plugin.json
□ At least one component directory (commands/, agents/, skills/, or hooks/)
```

#### 2. Validate plugin.json

Read and check:
- **Valid JSON**: Can parse without errors
- **Required fields present**: `name`, `version`, `description`
- **Name format**: kebab-case (lowercase with hyphens)
- **Version format**: Valid SemVer (e.g., "1.0.0")
- **Paths are relative**: Start with `./` not `/`
- **Author format**: If present, valid object or string

Example valid structure:
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "What the plugin does",
  "author": {
    "name": "Your Name"
  },
  "license": "MIT",
  "keywords": ["keyword1"],
  "commands": "./commands/",
  "agents": "./agents/",
  "hooks": "./hooks/hooks.json"
}
```

#### 3. Validate Component Paths

For each path in plugin.json:
- **commands**: Check directory exists, contains .md files
- **agents**: Check directory exists, contains .md files
- **skills**: Check directory exists, contains skill folders with SKILL.md
- **hooks**: Check file exists and is valid JSON

#### 4. Validate Commands

For each file in `commands/`:
- **File extension**: Must be .md
- **Frontmatter present**: Has `---` delimiters
- **Description field**: Frontmatter includes `description`
- **Naming**: kebab-case filename
- **Content**: Not empty after frontmatter

#### 5. Validate Skills

For each directory in `skills/`:
- **SKILL.md exists**: In uppercase
- **Frontmatter present**: Has `---` delimiters
- **Required fields**: `name` and `description` present
- **Name matches directory**: Exact match, kebab-case
- **Description is specific**: Includes when/why to use

#### 6. Validate Agents

For each file in `agents/`:
- **File extension**: Must be .md
- **Frontmatter present**: Has `---` delimiters
- **Description field**: Present in frontmatter
- **Naming**: kebab-case filename
- **Content**: Not empty after frontmatter

#### 7. Validate Hooks

If `hooks.json` exists:
- **Valid JSON**: Can parse without errors
- **Proper structure**: Has `hooks` object
- **Event names**: Valid events (PreToolUse, PostToolUse, etc.)
- **Hook commands**: Scripts use `${CLAUDE_PLUGIN_ROOT}`
- **Scripts exist**: Referenced scripts are present
- **Scripts executable**: Have execute permissions

### Validation Output Format

Report findings in this structure:

```
🔍 Validating plugin: <plugin-name>

✅ Structure
  ✓ .claude-plugin/plugin.json exists
  ✓ Component directories present

✅ Manifest (plugin.json)
  ✓ Valid JSON
  ✓ Required fields: name, version, description
  ✓ Name format: kebab-case
  ✓ Version format: SemVer
  ✓ Paths are relative

✅ Commands (3 files)
  ✓ commands/init.md
  ✓ commands/validate.md
  ✓ commands/test-local.md

✅ Skills (1 skill)
  ✓ skills/plugin-authoring/SKILL.md
    - name matches directory: ✓
    - description present: ✓

✅ Agents (1 agent)
  ✓ agents/plugin-reviewer.md

✅ Hooks
  ✓ hooks/hooks.json is valid
  ✓ Scripts exist and are executable

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Validation passed: 0 errors, 0 warnings
```

### Error Reporting

If issues are found, report clearly:

```
❌ Errors Found

1. Manifest: plugin.json missing required field "version"
   Fix: Add "version": "1.0.0" to .claude-plugin/plugin.json

2. Command: commands/myCommand.md uses camelCase
   Fix: Rename to commands/my-command.md (kebab-case)

3. Skill: skills/MySkill/SKILL.md name doesn't match directory
   Fix: Change frontmatter 'name' to "my-skill" (matches directory)

⚠️  Warnings

1. No README.md found
   Suggestion: Create README.md with usage documentation

2. No keywords in plugin.json
   Suggestion: Add keywords array for discoverability

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ Validation failed: 3 errors, 2 warnings
```

## Validation Categories

### Critical (Must Fix)

- Missing plugin.json
- Invalid JSON in config files
- Missing required fields (name, version, description)
- Absolute paths in configuration
- Component name mismatches (skill name ≠ directory)
- Non-executable hook scripts

### Warnings (Should Fix)

- Missing README.md
- No keywords in plugin.json
- Empty component directories
- Commands missing argument-hint
- Skills without progressive disclosure structure

### Suggestions (Nice to Have)

- Add CHANGELOG.md
- Include examples directory
- Add more descriptive descriptions
- Use consistent naming patterns

## Common Issues Detected

### Issue: Paths Not Relative

```json
❌ "commands": "/Users/you/plugin/commands/"
✅ "commands": "./commands/"
```

### Issue: Name Mismatch

```
Directory: skills/code-review/
Frontmatter: name: codeReview
❌ Names don't match

Fix: Change frontmatter to name: code-review
```

### Issue: Missing Frontmatter

```markdown
# My Command

Instructions...
```
❌ No frontmatter with description

```markdown
---
description: What this command does
---

# My Command

Instructions...
```
✅ Has required frontmatter

### Issue: Hook Script Not Executable

```bash
$ ls -l scripts/validate.sh
-rw-r--r--  validate.sh
❌ Not executable

$ chmod +x scripts/validate.sh
✅ Now executable
```

## Validation Checklist

Complete checklist used for validation:

```
Structure:
□ .claude-plugin/plugin.json exists
□ At least one component directory present
□ README.md exists

Manifest:
□ Valid JSON syntax
□ name field: present, kebab-case
□ version field: present, valid SemVer
□ description field: present, non-empty
□ Paths are relative (start with ./)
□ Referenced paths exist

Commands:
□ .md extension
□ Frontmatter with description
□ kebab-case naming
□ Non-empty content

Skills:
□ Directory structure (skill-name/SKILL.md)
□ SKILL.md in uppercase
□ Frontmatter with name and description
□ Name matches directory (exact, kebab-case)

Agents:
□ .md extension
□ Frontmatter with description
□ kebab-case naming
□ Non-empty content

Hooks:
□ hooks.json valid JSON
□ Proper structure (hooks object)
□ Valid event names
□ Scripts use ${CLAUDE_PLUGIN_ROOT}
□ Scripts exist
□ Scripts are executable (chmod +x)
```

## After Validation

### If Validation Passes

```
✅ Plugin is valid and ready for testing!

Next steps:
1. Test locally: /plugin-development:test-local
2. Create dev marketplace and install
3. Test all commands and features
4. Register in team marketplace when ready
```

### If Validation Fails

```
❌ Please fix the errors above before testing.

Need help?
- Review error messages for specific fixes
- Check best practices: /plugin-development:help
- Common issues documented in examples
```

## Example Usage

**Input**: `/plugin-development:validate`

**Output**:
```
🔍 Validating plugin: my-awesome-plugin

✅ All checks passed
✓ Structure correct
✓ Manifest valid
✓ 5 commands validated
✓ 2 skills validated
✓ 1 agent validated
✓ Hooks configured correctly

✅ Plugin ready for testing!
```

## Best Practices

1. **Validate often**: Run before testing or commits
2. **Fix errors first**: Address critical issues before warnings
3. **Read messages carefully**: Each error includes fix instructions
4. **Use debug mode**: Run `claude --debug` for deep inspection
5. **Incremental fixes**: Fix and re-validate one issue at a time

## Notes

- This command only reads files (no modifications)
- Validation is comprehensive but not exhaustive
- Some issues may only appear during runtime testing
- Always test in a dev marketplace after validation passes
