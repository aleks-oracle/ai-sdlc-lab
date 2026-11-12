# CLAUDE.md — ai-sdlc-lab

Public learning experiment, not a product: a simulated AI-driven SDLC around a small double-entry
ledger service. Never describe it as production experience. Full context: `PROJECT_BRIEF.md`.

<!-- ===== RULES — PROTECTED (PROJECT_BRIEF section 6). Change only with explicit owner approval. ===== -->

## Session start and end
- **Start:** read `PROJECT_BRIEF.md`, this file, `PLAN.md`, the latest entries of
  `experiments/journal.md` (not for the test and spec-reviewer roles), then say in 3–5 lines where
  we stand and what is next.
- **End:** append to `experiments/journal.md`: done, broke, decisions (with reasons), next step.
  Test and spec-reviewer sessions report in chat instead; the owner session records it.

## Roles (PROJECT_BRIEF section 5)
Start a role in a fresh session from the repo root: `scripts/claude-role.sh <role>`.

| Role | Writes | Must not read | Notes |
|---|---|---|---|
| dev | `ledger-core/`, `ledger-app/`, non-protected build files, `PLAN.md`, `docs/adr/`, `experiments/journal.md` | `blackbox-tests/` | `spec/` read-only |
| test | `blackbox-tests/` | `ledger-core/`, `ledger-app/`, build output, `experiments/` | sources: `spec/`, OpenAPI, brief, this file, `PLAN.md`, `docs/adr/` |
| auditor | findings in `experiments/` (not `spec-reviews/`) | — (reads everything) | never changes code, tests, spec or git state |
| spec-reviewer | new reports in `experiments/spec-reviews/` | everything except `spec/`, `PROJECT_BRIEF.md`, this file, earlier reports | fresh session only; applies `spec/REVIEW_CHECKLIST.md`; never edits `spec/` |

Enforcement (ADR 0004): `.claude/hooks/role-guard.sh` + `.claude/settings.json` + agent definitions
in `.claude/agents/` + OS sandbox via `.claude/roles/<role>.json`. If a tool call is blocked, do not
work around it; report it. Known gaps are tracked in `experiments/EXP-001-role-enforcement.md`.

## Protected paths
Do not modify without explicit owner approval in chat. If one seems wrong, propose the change and stop.
- `spec/**` — only the owner writes here (denied for all Claude sessions), incl. `spec/REVIEW_CHECKLIST.md`
- `PROJECT_BRIEF.md`; the rules sections of this file (between the PROTECTED markers)
- `.github/workflows/**` and any file that defines quality-gate thresholds (coverage, mutation score, ...)
- Root `pom.xml` **enforcer configuration** (between the `ENFORCER RULES` markers) and the
  `ledger.rules.*` properties; only `ledger-app/pom.xml` may opt out of those rules
- Role enforcement: `.claude/settings.json`, `.claude/hooks/**`, `.claude/agents/**`,
  `.claude/roles/**`, `scripts/claude-role.sh`

## Anti-cheating rules (PROJECT_BRIEF section 7, non-negotiable)
Never, to make a build or test pass: weaken/remove assertions, widen tolerances, change expected values
to match actual output; add `@Disabled`/skips/exclusions; mock the unit under test or over-mock; delete
or shrink tests or reduce test/assertion counts; lower thresholds or exclude code from coverage or
mutation analysis. If a test fails, say whether the code or the spec is wrong.

## Spec readiness (PROJECT_BRIEF section 8a)
No implementation or test for a requirement until its status is `Ready`: owner writes spec → linter
(Stage 3) → spec-reviewer report → owner decides every Blocker and Major.

## Working agreements
- Small steps, one logical change per commit, clear messages; branches + pull requests, not pushes to `main`.
- Ask before architectural decisions, new dependencies or deviations from the brief; record ADRs in `docs/adr/`.
- Verify Java 25 support of every tool/library before adding it. If incompatible, stop and report options.
- Be economical with tokens: focused tasks, no full-repo scans, no re-reading large files.
- Never commit secrets, tokens, local paths or agent logs without review.
- Report real numbers, including bad ones. Be honest about uncertainty.
- Plain English (owner's English is B2); reply in the language the owner writes in.

<!-- ===== END RULES ===== -->

## Build
- Maven via wrapper only: `./mvnw -B -ntp verify` (Maven 3.9.16, Java 25).
- Per module: `./mvnw -B -ntp -pl ledger-core,ledger-app verify` (dev), `-pl blackbox-tests` (test).
- Role-guard script check: `.claude/hooks/tests/run-role-guard-tests.sh`.

## Layout
- `spec/` requirements (conventions in `spec/README.md`), `ledger-core/` domain (no Spring),
  `ledger-app/` Spring Boot 4.1.2, `blackbox-tests/` HTTP tests, `experiments/` evidence,
  `docs/adr/` decisions.
- Packages: `io.github.aleks_oracle.ledger.{core,app,blackbox}` (groupId `io.github.aleks-oracle`;
  `-` is not allowed in Java package names, so it becomes `_`).
- Current stage and next steps: `PLAN.md`.
