---
description: Add a new Skill to the current plugin with proper structure
argument-hint: [skill-name] ["description"]
---

# Add Skill

Create a new Skill folder with SKILL.md and supporting directories.

## Arguments

- `$1` (required): Skill name in kebab-case (e.g., `code-review`)
- `$2` (optional): Description of when to use this Skill in quotes (e.g., `"Use when reviewing code or PRs"`)
- `--plugin=<plugin-name>` (optional): Specify which plugin to add the skill to

**Usage:**
```
# From within a plugin directory, with description
/plugin-development:add-skill code-review "Use when reviewing code or analyzing pull requests"

# Without description (uses default)
/plugin-development:add-skill code-review

# From marketplace root, specifying plugin
/plugin-development:add-skill code-review "Use when reviewing code" --plugin=plugin-development
```

## Prerequisites

- Must be run from either:
  - A plugin root directory (containing `.claude-plugin/plugin.json`), OR
  - A marketplace root directory (containing `.claude-plugin/marketplace.json`)
- `skills/` directory will be created if needed

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
      - Present list to user: "Which plugin should I add the skill to?"
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
   - `$1` (skill name): Not empty, kebab-case format (lowercase with hyphens), no spaces or special characters, max 64 characters
   - `$2` (description): Optional. If not provided, use default: "$1 functionality for plugin development". If provided, must be max 1024 characters and should include both what the Skill does and when to use it

3. **Set working directory**:
   - If in plugin directory: Use current directory
   - If in marketplace root: Use `plugins/<plugin-name>/` as working directory

### Create Skill Structure

**Note**: All paths below are relative to the target plugin directory (determined in validation step).

1. Ensure `<plugin-dir>/skills/` directory exists (create if needed, use `require_user_approval: false`)
2. Create skill directory: `<plugin-dir>/skills/$1/`
3. Create supporting directories:
   - `<plugin-dir>/skills/$1/schemas/`
   - `<plugin-dir>/skills/$1/templates/`
   - `<plugin-dir>/skills/$1/examples/`
   - `<plugin-dir>/skills/$1/best-practices/`

### Create SKILL.md

Create `<plugin-dir>/skills/$1/SKILL.md` with this template:

```markdown
---
name: $1
description: $2
---

# $1 Skill

[Brief introduction to what this Skill provides and its purpose]

## When to Activate

This Skill activates when:
- [Condition 1: e.g., user mentions specific keywords]
- [Condition 2: e.g., working with specific file types]
- [Condition 3: e.g., certain files are present]

## Capabilities

What this Skill can help with:

1. [Capability 1]
2. [Capability 2]
3. [Capability 3]

## Quick Links (Progressive Disclosure)

- [Schemas](./schemas/)
- [Templates](./templates/)
- [Examples](./examples/)
- [Best Practices](./best-practices/)

## Workflow

How this Skill operates:

1. **Analyze**: [What to read and understand]
2. **Propose**: [What actions to suggest]
3. **Execute**: [How to carry out the work]
4. **Validate**: [How to verify success]

## Common Patterns

### Pattern 1: [Name]

[Description of common usage pattern]

### Pattern 2: [Name]

[Description of another pattern]

## Notes

- [Important consideration 1]
- [Important consideration 2]
- [Links to other Skills or commands if applicable]
```

### Update plugin.json (if needed)

**IMPORTANT**: Only needed if using custom (non-standard) paths.

- **Standard setup** (skills in `skills/` directory): No changes to `plugin.json` needed
- **Custom paths**: Skills cannot be specified with custom paths (must use standard `skills/` directory)

### Provide Feedback

After creating the Skill:

```
✓ Created <plugin-name>/skills/$1/SKILL.md
✓ Created supporting directories:
  - <plugin-name>/skills/$1/schemas/
  - <plugin-name>/skills/$1/templates/
  - <plugin-name>/skills/$1/examples/
  - <plugin-name>/skills/$1/best-practices/

Plugin: <plugin-name>
Skill: $1
Description: $2

Next steps:
1. Edit <plugin-name>/skills/$1/SKILL.md with specific guidance
2. Key frontmatter fields:
   - name: Must match directory name ($1)
   - description: When to use this Skill (include trigger conditions, max 1024 chars)
   - allowed-tools: (Optional) Restrict tools available to this Skill. If omitted, Claude asks for permission
3. Add support files:
   - schemas/: Document data formats
   - templates/: Provide reusable templates
   - examples/: Show usage examples
   - best-practices/: Detailed guidance
4. Keep SKILL.md concise (< 500 lines), use progressive disclosure
5. Test with /plugin-development:test-local

Claude will auto-discover this Skill when the plugin is installed.
```

## Example

**Input**: 
```
/plugin-development:add-skill code-review "Use when reviewing code or analyzing pull requests"
```

**Arguments**:
- `$1` = `code-review`
- `$2` = `Use when reviewing code or analyzing pull requests`

**Result**:
- Creates `skills/code-review/` directory
- Creates `SKILL.md` with frontmatter `name: code-review`
- Frontmatter description: "Use when reviewing code or analyzing pull requests"
- Creates supporting directories (schemas/, templates/, examples/, best-practices/)
- Ready to add guidance and reference files

**For complete details on Skills**, see:
- [Agent Skills documentation](/en/docs/claude-code/skills)
- [Agent Skills overview](/en/docs/agents-and-tools/agent-skills/overview)
- [Skills best practices](/en/docs/agents-and-tools/agent-skills/best-practices)

## Skill Frontmatter

### Required Fields

```yaml
---
name: skill-name          # Must match directory, kebab-case
description: When and how to use this Skill (be specific about triggers)
---
```

### Optional Fields

```yaml
---
name: skill-name
description: Detailed description
allowed-tools: Read, Grep, Glob    # Restrict tool access (if omitted, Claude asks for permission)
---
```

**Important**: `allowed-tools` is optional. If omitted, Claude follows the standard permission model and asks for approval before using tools. Only add `allowed-tools` when you want to restrict available tools (e.g., read-only Skills).

### allowed-tools Options

Restrict to read-only for safety:
```yaml
allowed-tools: Read, Grep, Glob
```

Allow specific tools:
```yaml
allowed-tools: Read, Write, Edit, Bash(npm:*)
```

## Description Best Practices

The `description` field is critical for Claude to discover when to use your Skill. Requirements:
- **Max length**: 1024 characters
- **Include both**: what the Skill does AND when to use it
- **Be specific**: Include trigger keywords users would naturally mention

✅ **Good** (specific triggers):
```yaml
description: Review code for best practices, detect bugs, and suggest improvements. Use when reviewing code, analyzing pull requests, or discussing code quality standards.
```

❌ **Bad** (too vague):
```yaml
description: Helps with code
```

✅ **Good** (context-based):
```yaml
description: Create and manage React components following best practices. Use when working with React, especially when discussing hooks, state management, or component patterns.
```

## Progressive Disclosure Pattern

Keep SKILL.md concise by linking to support files:

### In SKILL.md:
```markdown
## Quick Links
- [API Schema](./schemas/api-schema.md)
- [Component Templates](./templates/)
```

### In Support Files:
- `schemas/api-schema.md`: Detailed schema documentation
- `templates/component.tsx`: Reusable template files

This keeps SKILL.md under 500 lines while providing deep reference material.

## Skill Structure Example

```
skills/
└── code-review/
    ├── SKILL.md                    # Main skill (concise)
    ├── schemas/
    │   └── review-checklist.md     # Review criteria
    ├── templates/
    │   └── review-comment.md       # Comment templates
    ├── examples/
    │   ├── basic-review.md         # Simple example
    │   └── security-review.md      # Advanced example
    └── best-practices/
        ├── review-process.md       # Detailed guidance
        └── common-issues.md        # Issue catalog
```

## Advanced: Tool Restrictions

For read-only Skills (safest):
```yaml
allowed-tools: Read, Grep, Glob
```

For Skills that propose changes but don't execute:
```yaml
allowed-tools: Read, Grep, Glob
```
(Propose commands for user to run)

For Skills that need to write:
```yaml
allowed-tools: Read, Write, Edit, Grep, Glob
```

## Best Practices

1. **Concise SKILL.md**: Keep main file < 500 lines
2. **Progressive disclosure**: Link to detailed support files
3. **Specific triggers**: Clear description of when to activate
4. **Tool restrictions**: Only add `allowed-tools` when restricting is necessary (e.g., read-only Skills)
5. **Organized support**: Use all subdirectories for comprehensive guidance

## Common Mistakes to Avoid

❌ **Name doesn't match directory**
```
Directory: skills/code-review/
Frontmatter: name: codeReview    # Wrong case!
```

✅ **Name matches directory**
```
Directory: skills/code-review/
Frontmatter: name: code-review
```

❌ **Vague description**
```yaml
description: A helpful Skill
```

✅ **Specific triggers**
```yaml
description: Use when reviewing code, analyzing PRs, or discussing code quality
```

## Validation Checklist

After creating a Skill:
```
□ SKILL.md created in skills/<name>/ directory
□ Frontmatter name matches directory name (kebab-case, max 64 chars)
□ Description includes specific trigger conditions (max 1024 chars)
□ Description includes both what the Skill does AND when to use it
□ SKILL.md is uppercase
□ Supporting directories created
□ If using allowed-tools, it restricts tools appropriately
```
