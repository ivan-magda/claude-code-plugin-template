#!/usr/bin/env bash
# validate-plugin.sh - Basic plugin structure validation
# Exit codes: 0=OK, 1=warning (non-blocking), 2=error (blocking)

set -euo pipefail

# Read JSON input from stdin to get the file being written/edited
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# If no file path, skip validation
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip validation for project-level skills (.claude/skills/)
if [[ "$FILE_PATH" == */.claude/skills/* ]] || [[ "$FILE_PATH" == .claude/skills/* ]]; then
  exit 0
fi

# Find the plugin root by looking for .claude-plugin/plugin.json
# Walk up from the file's directory
FILE_DIR=$(dirname "$FILE_PATH")

# Convert to absolute path if relative
if [[ "$FILE_DIR" != /* ]]; then
  FILE_DIR="$PWD/$FILE_DIR"
fi

# Normalize path (remove .. and .)
FILE_DIR=$(cd "$FILE_DIR" 2>/dev/null && pwd || echo "$FILE_DIR")

PLUGIN_ROOT=""
CHECK_DIR="$FILE_DIR"

while [ "$CHECK_DIR" != "/" ]; do
  if [ -f "$CHECK_DIR/.claude-plugin/plugin.json" ]; then
    PLUGIN_ROOT="$CHECK_DIR"
    break
  fi
  CHECK_DIR=$(dirname "$CHECK_DIR")
done

# If not inside a plugin directory, skip validation
if [ -z "$PLUGIN_ROOT" ]; then
  exit 0
fi

# Now validate the plugin structure
cd "$PLUGIN_ROOT"

ERRS=()

# Check for core plugin structure
[ -f ".claude-plugin/plugin.json" ] || ERRS+=("Missing .claude-plugin/plugin.json")

# Check for at least one component directory (commands, agents, skills, or hooks)
if [ ! -d "commands" ] && [ ! -d "agents" ] && [ ! -d "skills" ] && [ ! -d "hooks" ]; then
  ERRS+=("No component directories found (commands/, agents/, skills/, or hooks/)")
fi

# If errors found, output them and exit with code 2 to block
if [ "${#ERRS[@]}" -gt 0 ]; then
  printf "❌ Plugin validation failed:\n" 1>&2
  printf "  %s\n" "${ERRS[@]}" 1>&2
  printf "\nRun /plugin-development:validate for detailed checks\n" 1>&2
  exit 2
fi

# Validation passed
exit 0
