# ADR 0004 — Enforcing role access rules with Claude Code tooling

Status: Proposed (Stage 1). Effectiveness is measured in `experiments/EXP-001-role-enforcement.md`.

## Context
PROJECT_BRIEF section 5 defines roles with read/write limits. The owner requires that the limits be
enforced by tooling, not only by documentation. Claude Code (checked in the docs, 2026-11-12, CLI
2.1.322) offers:
- subagent / `--agent` definitions with a tool list, but **no per-agent path rules**;
- permission rules (`Read(...)`, `Edit(...)`, `Bash(...)`) that apply to the **whole session**;
- `PreToolUse` hooks, whose input includes `agent_type` for subagents and `--agent` sessions;
- an OS sandbox (Seatbelt on macOS) for Bash and its child processes, configured per settings file.

## Decision
Four layers:
1. **Shared rules** in `.claude/settings.json`: `Edit(/spec/**)` is denied for every session (only the
   owner edits `spec/`, outside Claude). Other protected paths are `ask` rules, so each edit needs the
   owner's approval.
2. **Role guard hook** `.claude/hooks/role-guard.sh` (settings-level, matcher `*`): per-role tool
   allowlist, path allowlists/denylists for file tools, Bash allowlist (test, spec-reviewer) or
   denylist (dev, auditor). Roles cannot call `Agent`, `SendMessage`, MCP tools or other unknown tools,
   so they cannot hand work to a less restricted agent.
3. **Agent definitions** `.claude/agents/<role>.md`: prompt plus tool list (defence in depth).
4. **Role launcher** `scripts/claude-role.sh <role>`: fresh session, `--agent <role>`, and for test and
   spec-reviewer a settings file with an OS sandbox that denies reads of implementation folders and
   limits network to Maven Central.

## Consequences / known gaps (see EXP-001 for measurements)
- A role run as a subagent inside an owner session gets layers 1–3 but **no sandbox** (sandbox is
  per session). Strong isolation needs the launcher.
- Hook Bash checks read the command text; a program started by an allowed command (e.g. test code
  run by Maven) is not seen by the hook. Only the sandbox covers that, and only in launcher sessions.
- `.git` holds all history: a role with general git access could read hidden code. The hook blocks
  `git show`/`log -p`/`diff` without allowed paths for test, but this is text-based.
- Auto-memory and user-level CLAUDE.md are loaded by Claude Code, not via tools; the hook cannot
  filter them. The spec-reviewer's "no drafts or history" rule depends on what those contain.
- A permission mode set by the owner (auto, acceptEdits, bypassPermissions) changes how `ask` rules
  and agent `permissionMode` behave; `bypassPermissions` must never be used for role sessions.
- The guard and settings are protected paths; Step 3 CI will flag any PR that changes them.
