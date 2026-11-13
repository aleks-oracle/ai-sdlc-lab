# PLAN

**Current stage: 1 — skeleton** (branch `stage-1/skeleton`)

## Stages (PROJECT_BRIEF section 9)

| # | Stage | Status |
|---|---|---|
| 1 | Repo skeleton, spec template with IDs, spec-reviewer role and checklist, role enforcement, protected-path checks in CI | **in progress** |
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
- [x] Draft `experiments/EXP-001-role-enforcement.md`
- [ ] Owner review of the PR, incl. `spec/README.md` and `spec/requirements/_TEMPLATE.md` (protected)
- [ ] Run EXP-001 (fresh role sessions) and record results
- [ ] Step 3: propose CI workflow (build, protected-path check, test-integrity check) → owner approval → implement

## Role notes
- **spec-reviewer** (added in Stage 1): reviews `spec/` against `spec/REVIEW_CHECKLIST.md` before
  implementation; reports to `experiments/spec-reviews/`. First real review: Stage 2, spec v1.
  Start with `scripts/claude-role.sh spec-reviewer` in a fresh session.

## Decisions waiting for the owner
- ADR 0003: how blackbox-tests reach the app (Stage 2).
- Traceability mechanism: JUnit `@Tag` vs custom `@Requirement` annotation (Stage 3).
- jqwik test classes must match Surefire includes (`*Test`, `*Tests`, `Test*`, `*TestCase`) or the
  includes must be extended — found in the spike; decide in Stage 3.
