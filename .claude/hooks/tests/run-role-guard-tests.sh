#!/bin/bash
# Unit check of role-guard.sh: feeds synthetic PreToolUse JSON and compares allow/deny with the table.
# This tests the script only. Whether Claude Code really calls it, and what it misses, is EXP-001.
cd "$(dirname "$0")/../../.." || exit 1
export CLAUDE_PROJECT_DIR=$PWD
pass=0; fail=0
while IFS=$'\t' read -r exp role tool field value note; do
  case "$exp" in ''|'#'*) continue ;; esac
  json=$(jq -n --arg r "$role" --arg t "$tool" --arg f "$field" --arg v "$value" --arg cwd "$PWD" \
    '{cwd:$cwd, hook_event_name:"PreToolUse", tool_name:$t, tool_input:{($f):$v}} + (if $r == "-" then {} else {agent_type:$r} end)')
  # value <none> = field absent (e.g. Grep without path). Empty fields cannot be used: read collapses tabs.
  [ "$value" = "<none>" ] && json=$(jq 'del(.tool_input[])' <<<"$json")
  err=$(.claude/hooks/role-guard.sh <<<"$json" 2>&1 >/dev/null); code=$?
  got=allow; [ $code -eq 2 ] && got=deny
  if [ "$got" = "$exp" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: expected $exp, got $got — [$role] $tool $value ($note) ${err}"; fi
done < .claude/hooks/tests/role-guard-cases.tsv
echo "role-guard unit check: $pass passed, $fail failed"
[ $fail -eq 0 ]
