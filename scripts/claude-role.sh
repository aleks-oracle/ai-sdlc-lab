#!/bin/bash
# Start a NEW Claude Code session as one project role (PROJECT_BRIEF section 5).
#
#   scripts/claude-role.sh dev|test|auditor|spec-reviewer [extra claude args]
#
# - runs from the repository root, so the relative paths in the role rules resolve correctly;
# - `--agent <role>`: the session takes the role's prompt and tool list (.claude/agents/<role>.md),
#   and the hook .claude/hooks/role-guard.sh applies the role's path rules;
# - `--settings .claude/roles/<role>.json` (if present): extra settings for that role, today an OS
#   sandbox for Bash (test, spec-reviewer).
# Always a fresh session: do not pass --continue or --resume (the spec-reviewer must start clean).
# PROTECTED (CLAUDE.md).
set -euo pipefail

role=${1:-}
case "$role" in
  dev|test|auditor|spec-reviewer) shift ;;
  *) echo "usage: $0 dev|test|auditor|spec-reviewer [claude args...]" >&2; exit 1 ;;
esac
for a in "$@"; do
  case "$a" in -c|--continue|-r|--resume|--resume=*) echo "$0: role sessions must be fresh; drop $a" >&2; exit 1 ;; esac
done

cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
args=(--agent "$role")
[ -f ".claude/roles/$role.json" ] && args+=(--settings ".claude/roles/$role.json")
exec claude "${args[@]}" "$@"
