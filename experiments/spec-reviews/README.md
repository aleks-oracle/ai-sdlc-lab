# Spec reviews

Reports written by the **spec-reviewer** role (PROJECT_BRIEF sections 5 and 8a).
No review has been run yet: no spec exists in Stage 1.

## How a review is run

1. The owner sets the requirements to review to status `In review` and commits them.
2. The owner starts a **fresh** session as the reviewer:
   `scripts/claude-role.sh spec-reviewer`
   and asks it to review spec vN. No drafts, no history, no `--continue`/`--resume`.
3. The reviewer applies `spec/REVIEW_CHECKLIST.md` and writes one new file here.
4. The owner answers every Blocker and Major (fix / reject with reason / defer with reason),
   in an "Owner decisions" section appended to the report or in a follow-up file.
5. Only then may requirements get status `Ready`.

## Files

- `YYYY-MM-DD-spec-vN.md`: one report per review, in the format of checklist section 4.
- Reports are never overwritten (the role guard blocks it). A re-review is a new file that
  references the previous report and lists which findings were closed.

## Limits

The review checks form, consistency, completeness and testability against a checklist. It is not a
certification of compliance with any standard, and it cannot confirm that a domain rule is correct.
