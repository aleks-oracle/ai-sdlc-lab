# PLAN

**Current stage: 1 — skeleton** (branch `stage-1/skeleton`, PR #1 open, not merged)

## Resume here (updated 2026-11-18)

- PR #1 https://github.com/aleks-oracle/ai-sdlc-lab/pull/1 is waiting for the owner's review. **Do not merge or
  push without the owner's instruction.**
- Next, in this order, when the owner says so:
  1. Owner reviews and merges PR #1.
  2. Step 3: propose the CI workflow (build, protected-path check, test-integrity check). Proposal only, then wait.
  3. Run EXP-001 (owner starts fresh role sessions with `scripts/claude-role.sh <role>`).
- Local-only state (not on GitHub): branch `spike/junit6-jqwik-pit` (spike evidence); branch
  `backup/stage-1-before-brief-removal` and `refs/original/` (old history that still contains `PROJECT_BRIEF.md`;
  delete when the owner confirms). `PROJECT_BRIEF.md` is gitignored and exists only on the owner's machine.

## Stages (PROJECT_BRIEF section 9)

| # | Stage | Status |
|---|---|---|
| 1 | Repo skeleton, spec template with IDs, spec-reviewer role and checklist, role enforcement, protected-path checks in CI | **in progress** (PR #1 in review; CI is Step 3) |
| 2 | Spec v1 by the owner → spec readiness gate (8a) → first slice: dev agent (code) + test agent (tests from spec only) | not started |
| 3 | Quality gates: PIT, jqwik, integrity checks, traceability, spec linter | not started |
| 4 | Experiments: cheating pressure, seeded-bug audit, test independence, flawed spec | not started |
| 5 | Small LLM-powered feature with evals (optional) | not started |
| 6 | Simulated "production": docker-compose, flags, canary, observability, incident + post-mortem | not started |
| 7 | Final report with metrics | not started |

## Stage 1 checklist

- [x] Step 1: module skeleton proposed and approved
- [x] Spike: JUnit 6 + jqwik 1.10.2 + PIT 1.30.2 on Java 25 (branch `spike/junit6-jqwik-pit`, local only)
- [x] Step 2: Maven multi-module skeleton (Boot 4.1.2 BOM, enforcer rules), Maven Wrapper
- [x] Step 2: `CLAUDE.md`, `PLAN.md`, `experiments/journal.md`, spec conventions + template
- [x] Step 4: spec-reviewer role (agent definition, enforcement, `experiments/spec-reviews/README.md`)
- [x] Agent definitions and role guard for dev, test, auditor, spec-reviewer (ADR 0004)
- [x] ADRs 0001–0004 (0003 is a stub for Stage 2)
- [x] Draft `experiments/EXP-001-role-enforcement.md` (now 44 cases incl. R09, R10, T20)
- [x] PR #1 opened; review changes: packages → `io.github.aleksai.*`, `PROJECT_BRIEF.md` removed from history
- [x] `spec/REVIEW_CHECKLIST.md` v2 (owner-approved; RC-01..RC-25 stable, RC-26..RC-33 new)
- [x] Role guard fix: exact-command Bash allowlists for test and spec-reviewer, `..` rejection (hook check 81/81)
- [ ] Owner review and merge of PR #1, incl. `spec/README.md` and `spec/requirements/_TEMPLATE.md` (protected)
- [ ] Step 3: propose CI workflow (build, protected-path check, test-integrity check) → owner approval → implement
- [ ] Run EXP-001 (fresh role sessions) and record results

## Role notes
- **spec-reviewer** (added in Stage 1): reviews `spec/` against `spec/REVIEW_CHECKLIST.md` (v2) before
  implementation; reports to `experiments/spec-reviews/`. First real review: Stage 2, spec v1.
  Start with `scripts/claude-role.sh spec-reviewer` in a fresh session.
- Agents cannot write in `spec/` (settings deny). When the owner wants spec text from an agent, the agent writes
  the file in the repo root and the owner moves it into `spec/`.

## Decisions waiting for the owner
- ADR 0003: how blackbox-tests reach the app (Stage 2).
- Traceability mechanism: JUnit `@Tag` vs custom `@Requirement` annotation (Stage 3).
- jqwik test classes must match Surefire includes (`*Test`, `*Tests`, `Test*`, `*TestCase`) or the
  includes must be extended — found in the spike; decide in Stage 3.
- Owner to-do for spec v1 (Stage 2): add `spec/CHANGELOG.md` and its row in the `spec/README.md` file table
  (checklist RC-33); fill the area table in `spec/README.md`; create tag `spec-v1` before the review.
- When to delete the local backup branch and `refs/original/`.
