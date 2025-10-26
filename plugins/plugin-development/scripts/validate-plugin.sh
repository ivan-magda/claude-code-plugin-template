#!/usr/bin/env bash
# validate-plugin.sh - Basic plugin structure validation
# Exit codes: 0=OK, 1=warning (non-blocking), 2=error (blocking)

set -euo pipefail

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
