#!/bin/bash
# role-guard.sh — PreToolUse hook that enforces the role access rules of PROJECT_BRIEF section 5.
#
# PROTECTED (CLAUDE.md). Registered in .claude/settings.json for every tool ("*").
#
# How it works
#   Claude Code sends the pending tool call as JSON on stdin. The field "agent_type" names the role
#   when the session was started with `claude --agent <role>` or the call comes from a subagent.
#   No agent_type (owner session) or an unknown one (built-in Explore, Plan, ...) -> no extra rules here;
#   the shared deny/ask rules in .claude/settings.json still apply.
#   For a role, the call is checked against:
#     1. a TOOL allowlist     (unknown tools, MCP tools and delegation tools are denied)
#     2. a READ/WRITE path policy for file tools (paths are normalised and symlinks resolved)
#     3. a BASH policy        (allowlist for test and spec-reviewer, denylist for dev and auditor)
#   Deny = exit code 2 with a reason on stderr (Claude Code blocks the call and shows the reason).
#
# Limits (see experiments/EXP-001): Bash text checks are best effort; a process started by an allowed
# command (e.g. a test that opens files itself) is not seen by this hook. OS-level limits for that
# come from the sandbox settings in .claude/roles/<role>.json (scripts/claude-role.sh).
#
# Requires: bash 3.2+ (macOS default), jq.

set -u

deny() {
  echo "role-guard [${ROLE:-?}]: BLOCKED $TOOL — $1" >&2
  exit 2
}

if ! command -v jq >/dev/null 2>&1; then
  echo "role-guard: jq is required (brew install jq). Failing closed." >&2
  exit 2
fi

INPUT=$(cat)
ROLE=$(jq -r '.agent_type // empty' <<<"$INPUT")
TOOL=$(jq -r '.tool_name // empty' <<<"$INPUT")

case "$ROLE" in
  dev|test|auditor|spec-reviewer) ;;
  *) exit 0 ;;   # not a project role: no decision, normal permission flow
esac

CWD=$(jq -r '.cwd // empty' <<<"$INPUT")
TRANSCRIPT=$(jq -r '.transcript_path // empty' <<<"$INPUT")
SCRATCH=$(jq -r '.scratchpad_dir // empty' <<<"$INPUT")
PROJECT=${CLAUDE_PROJECT_DIR:-$CWD}
PROJECT=$(cd "$PROJECT" 2>/dev/null && pwd -P) || deny "cannot resolve project dir"
[ -n "$CWD" ] || CWD=$PROJECT

# ---------- helpers ----------

# Absolute, symlink-resolved path. Works for files that do not exist yet (resolves the existing parent).
abspath() {
  local p=$1 d b
  case "$p" in
    "~") p=$HOME ;;
    "~/"*) p="$HOME/${p#\~/}" ;;
    /*) ;;
    *) p="$CWD/$p" ;;
  esac
  d=$(dirname "$p"); b=$(basename "$p")
  while [ ! -d "$d" ]; do b="$(basename "$d")/$b"; d=$(dirname "$d"); done
  d=$(cd "$d" && pwd -P)
  if [ -d "$d/$b" ]; then (cd "$d/$b" && pwd -P); else echo "$d/$b"; fi
}

# Path relative to the project ("" = project root), or "OUTSIDE:<abs>" if outside the project.
relpath() {
  local a
  a=$(abspath "$1")
  case "$a" in
    "$PROJECT") echo "" ;;
    "$PROJECT"/*) echo "${a#"$PROJECT"/}" ;;
    *) echo "OUTSIDE:$a" ;;
  esac
}

# The session's own scratch areas (tool results that are too big for the context, scratchpad).
own_session_area() {
  local a=$1 sess
  if [ -n "$TRANSCRIPT" ]; then
    sess=${TRANSCRIPT%.jsonl}
    sess=$(abspath "$sess")
    case "$a" in "$sess"/*) return 0 ;; esac
  fi
  if [ -n "$SCRATCH" ]; then
    case "$a" in "$(abspath "$SCRATCH")"|"$(abspath "$SCRATCH")"/*) return 0 ;; esac
  fi
  return 1
}

# under <rel> <prefix>...  -> true if rel equals a prefix or is below it ("dir/" prefixes or exact files)
under() {
  local r=$1; shift
  local p
  for p in "$@"; do
    case "$p" in
      */) [ "$r" = "${p%/}" ] && return 0; case "$r" in "$p"*) return 0 ;; esac ;;
      *)  [ "$r" = "$p" ] && return 0 ;;
    esac
  done
  return 1
}

# ---------- role policy tables ----------
# Prefixes ending in "/" are directories; others are exact files. "" (project root) is never allowed
# for allowlist roles, so a search with no path cannot sweep the whole repo.

TEST_READ=(spec/ blackbox-tests/ docs/adr/ PROJECT_BRIEF.md CLAUDE.md PLAN.md pom.xml mvnw .mvn/)
TEST_WRITE=(blackbox-tests/)
REVIEWER_READ=(spec/ experiments/spec-reviews/ PROJECT_BRIEF.md CLAUDE.md)
REVIEWER_WRITE=(experiments/spec-reviews/)
DEV_NO_READ=(blackbox-tests/)
DEV_WRITE=(ledger-core/ ledger-app/ pom.xml PLAN.md experiments/journal.md docs/adr/)
AUDITOR_WRITE=(experiments/)
AUDITOR_NO_WRITE=(experiments/spec-reviews/)

# Own build artifacts in the local Maven repo would expose compiled implementation classes.
M2_OWN="$HOME/.m2/repository/io/github/aleks-oracle"

check_read() {   # $1 = raw path ("" means project root / current directory)
  local raw=${1:-$CWD} r a
  r=$(relpath "$raw")
  if [ "${r#OUTSIDE:}" != "$r" ]; then
    a=${r#OUTSIDE:}
    case "$a" in "$M2_OWN"|"$M2_OWN"/*) deny "local Maven artifacts of this project are off limits ($a)" ;; esac
    case "$ROLE" in
      test|spec-reviewer) own_session_area "$a" || deny "reading outside the project is not allowed for $ROLE ($a)" ;;
    esac
    return 0
  fi
  case "$ROLE" in
    test)          under "$r" "${TEST_READ[@]}"     || deny "test may read only: ${TEST_READ[*]} (asked: '${r:-.}')" ;;
    spec-reviewer) under "$r" "${REVIEWER_READ[@]}" || deny "spec-reviewer may read only: ${REVIEWER_READ[*]} (asked: '${r:-.}')" ;;
    dev)           ! under "$r" "${DEV_NO_READ[@]}" || deny "dev must not read blackbox-tests/ (asked: '$r')"
                   [ -n "$r" ] || [ "$TOOL" = Read ] || deny "dev: give Grep/Glob an explicit path that excludes blackbox-tests/" ;;
    auditor) ;;
  esac
  case "$r" in .git|.git/*) [ "$ROLE" = auditor ] || deny "direct reads of .git/ are not allowed for $ROLE" ;; esac
  return 0
}

check_write() {  # $1 = raw path
  local r
  r=$(relpath "$1")
  [ "${r#OUTSIDE:}" = "$r" ] || deny "writing outside the project is not allowed for roles (${r#OUTSIDE:})"
  case "$ROLE" in
    test)          under "$r" "${TEST_WRITE[@]}" || deny "test may write only: ${TEST_WRITE[*]} (asked: '$r')" ;;
    spec-reviewer) under "$r" "${REVIEWER_WRITE[@]}" || deny "spec-reviewer may write only new reports in experiments/spec-reviews/ (asked: '$r')"
                   [ ! -e "$PROJECT/$r" ] || deny "spec-reviewer must not overwrite an existing file ($r); write a new report" ;;
    dev)           under "$r" "${DEV_WRITE[@]}" || deny "dev may write only: ${DEV_WRITE[*]} (asked: '$r')" ;;
    auditor)       { under "$r" "${AUDITOR_WRITE[@]}" && ! under "$r" "${AUDITOR_NO_WRITE[@]}"; } \
                     || deny "auditor may write only experiments/ (not spec-reviews/) (asked: '$r')" ;;
  esac
  return 0
}

# ---------- Bash ----------

SAFE_TOKEN='^[A-Za-z0-9._/,:=@#*+-]+$'

all_paths_under() {  # all_paths_under <prefix-array-name> tokens...
  local arr=$1; shift
  local t r
  for t in "$@"; do
    [[ "$t" =~ $SAFE_TOKEN ]] || return 1
    r=$(relpath "$t")
    eval "under \"\$r\" \"\${${arr}[@]}\"" || return 1
  done
  return 0
}

check_bash_test() {
  local c=$1 toks t i has_pl=0 has_phase=0
  read -ra toks <<<"$c"
  case "$c" in
    "./mvnw "*)
      i=1
      while [ $i -lt ${#toks[@]} ]; do
        t=${toks[$i]}
        case "$t" in
          -B|-q|-e|-o|-ntp|--batch-mode|--quiet|--errors|--offline|--no-transfer-progress) ;;
          -pl) i=$((i+1)); [ "${toks[$i]:-}" = blackbox-tests ] || deny "mvnw for test: only '-pl blackbox-tests'"; has_pl=1 ;;
          -D*) [[ "$t" =~ ^-D[A-Za-z0-9._-]+(=[A-Za-z0-9._,#*-]*)?$ ]] || deny "mvnw for test: unsupported property '$t'" ;;
          clean|validate|compile|test-compile|test|verify) has_phase=1 ;;
          *) deny "mvnw for test: '$t' not allowed (lifecycle phases only)" ;;
        esac
        i=$((i+1))
      done
      [ $has_pl = 1 ] && [ $has_phase = 1 ] || deny "mvnw for test needs '-pl blackbox-tests' and a lifecycle phase"
      return 0 ;;
    "git status"|"git status -s"|"git status --short"|"git status -sb") return 0 ;;
    "git diff "*|"git add "*|"ls"|"ls "*)
      local args=() seen_dd=0
      for t in "${toks[@]:2}"; do
        case "$t" in
          --) seen_dd=1 ;;
          -*) [[ "$t" =~ ^(--stat|--cached|--staged|--name-only|-l|-la|-a)$ ]] || deny "flag '$t' not allowed" ;;
          *) args+=("$t") ;;
        esac
      done
      [ "${toks[0]}" = ls ] && args=() && for t in "${toks[@]:1}"; do case "$t" in -*) ;; *) args+=("$t") ;; esac; done
      [ ${#args[@]} -gt 0 ] || deny "give explicit paths under spec/ or blackbox-tests/"
      if [ "${toks[1]:-}" = add ]; then
        all_paths_under TEST_WRITE "${args[@]}" || deny "git add: only paths under blackbox-tests/"
      else
        all_paths_under TEST_READ "${args[@]}" || deny "only paths the test role may read"
      fi
      return 0 ;;
    "git commit -m "*|"git commit -q -m "*) return 0 ;;
  esac
  deny "command not on the test role allowlist (see .claude/hooks/role-guard.sh)"
}

check_bash_reviewer() {
  local c=$1
  case "$c" in
    "git rev-parse HEAD"|"git rev-parse --short HEAD"|"git hash-object spec/REVIEW_CHECKLIST.md"|"date"|"date +%F") return 0 ;;
    "ls spec"*|"ls experiments/spec-reviews"*)
      local toks; read -ra toks <<<"$c"
      all_paths_under REVIEWER_READ "${toks[@]:1}" || deny "ls: only spec/ or experiments/spec-reviews/"
      return 0 ;;
  esac
  deny "command not on the spec-reviewer allowlist (git rev-parse HEAD, git hash-object spec/REVIEW_CHECKLIST.md, ls spec, date)"
}

check_bash() {
  local c=$1
  # Never fetch this project's own repository from the network (it would expose the hidden code/tests).
  case "$c" in *aleks-oracle/ai-sdlc-lab*) deny "fetching this repository over the network is not allowed for roles" ;; esac
  case "$ROLE" in
    test|spec-reviewer)
      case "$c" in
        *';'*|*'&'*|*'|'*|*'`'*|*'$('*|*'>'*|*'<'*|*$'\n'*) deny "compound commands, pipes, redirects and substitutions are not allowed for $ROLE" ;;
      esac
      [ "$ROLE" = test ] && check_bash_test "$c"
      [ "$ROLE" = spec-reviewer ] && check_bash_reviewer "$c"
      ;;
    dev)
      case "$c" in *blackbox-tests*) deny "dev must not touch blackbox-tests/" ;; esac
      case "$c" in
        *mvnw*) [[ "$c" =~ (^|[[:space:]])-pl[[:space:]] ]] || deny "dev: run Maven with -pl ledger-core,ledger-app (a full build would show blackbox test sources/results)" ;;
      esac
      ;;
    auditor)
      [[ "$c" =~ (^|[^0-9\&])[\>]([^\&]|$) ||"$c" =~ (^|[[:space:]])(tee|rm|mv|cp|touch|mkdir|chmod|truncate)[[:space:]] || "$c" =~ sed[[:space:]]+(-[a-zA-Z]*i) ]] \
        && deny "auditor is read-only in code: no redirects, tee, rm, mv, cp, touch, mkdir, chmod, sed -i"
      [[ "$c" =~ git[[:space:]]+(commit|push|add|reset|checkout|switch|merge|rebase|restore|stash|clean|tag|apply|am|cherry-pick) ]] \
        && deny "auditor must not change git state"
      [[ "$c" =~ mvnw.*(install|deploy) ]] && deny "auditor must not install or deploy artifacts"
      ;;
  esac
  return 0
}

# ---------- 1. tool allowlist ----------
BASE_TOOLS=" Read Glob Grep Bash TodoWrite TaskCreate TaskGet TaskList TaskUpdate TaskOutput AskUserQuestion ToolSearch "
case "$ROLE" in
  dev)           ALLOWED="$BASE_TOOLS Edit Write MultiEdit NotebookEdit WebFetch WebSearch " ;;
  test)          ALLOWED="$BASE_TOOLS Edit Write MultiEdit " ;;
  auditor)       ALLOWED="$BASE_TOOLS Edit Write WebFetch WebSearch " ;;
  spec-reviewer) ALLOWED="$BASE_TOOLS Write " ;;
esac
case "$ALLOWED" in
  *" $TOOL "*) ;;
  *) deny "tool not on the $ROLE allowlist (no MCP, no subagents/messages to other sessions)" ;;
esac

# ---------- 2./3. per-tool checks ----------
case "$TOOL" in
  Read)                 check_read  "$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")" ;;
  Glob|Grep)            check_read  "$(jq -r '.tool_input.path // empty' <<<"$INPUT")"
                        # a glob pattern must not climb out of the searched directory
                        case "$(jq -r '.tool_input.pattern // empty' <<<"$INPUT")" in *..*|/*|~*) [ "$TOOL" = Glob ] && deny "Glob pattern must be relative and must not contain '..'" ;; esac
                        g=$(jq -r '.tool_input.glob // empty' <<<"$INPUT")
                        case "$g" in *..*|/*) deny "Grep glob must be relative and must not contain '..'" ;; esac ;;
  Edit|Write|MultiEdit) p=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")
                        check_read "$p"; check_write "$p" ;;
  NotebookEdit)         p=$(jq -r '.tool_input.notebook_path // empty' <<<"$INPUT")
                        check_read "$p"; check_write "$p" ;;
  Bash)                 check_bash "$(jq -r '.tool_input.command // empty' <<<"$INPUT")" ;;
  WebFetch)             case "$(jq -r '.tool_input.url // empty' <<<"$INPUT")" in
                          *aleks-oracle/ai-sdlc-lab*) deny "fetching this repository over the network is not allowed for roles" ;;
                        esac ;;
esac

exit 0
