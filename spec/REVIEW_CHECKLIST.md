# REVIEW_CHECKLIST — requirements review criteria

Location in repo: `spec/REVIEW_CHECKLIST.md` (PROTECTED: only the owner changes it).
Version: v2 (changes in section 8).

## 0. Purpose and limits

This checklist is applied by the `spec-reviewer` role to the requirements in `spec/` **before** implementation starts (PROJECT_BRIEF section 8a).

- The criteria are written in our own words. They are informed by well-known requirements-engineering and testing sources (section 7), but this is **not** a compliance check against any standard, and the review does not certify anything.
- The review checks **form, consistency, completeness and testability**. It cannot confirm that a domain rule is *correct* (for example, which rounding mode is right). Such questions go to the owner in a separate section of the report.
- Verification ("is the spec written well?") and validation ("is it the right spec?") are different. This checklist covers verification and surfaces validation questions for the owner.

## 1. How to review

1. Work in a fresh session. Read only `spec/`, `PROJECT_BRIEF.md`, `CLAUDE.md`, this checklist and, for a re-review, earlier reports in `experiments/spec-reviews/`. Do not read code. Do not use drafts or the conversation history that produced the spec.
2. Apply every criterion to every requirement and invariant; apply set-level criteria (sections C and D) to the whole spec. Do not skip criteria because the spec is short.
3. Support every finding with a short evidence reference: requirement ID and a few words from the text. Do not paraphrase the text into something it does not say.
4. Check arithmetic in examples by calculating it, not by eye.
5. Never edit `spec/`. Report findings and ask questions. Never invent requirements to fill gaps: describe the gap and ask.
6. Keep verification findings and validation questions apart (section 3). The reviewer asks; the owner decides.
7. **One defect, one finding.** If a defect matches several criteria, report it once under the most specific criterion and list the others in the "Also" column. This keeps counts comparable between reviews.
8. A criterion that cannot apply to this spec (its condition is not met) is listed under "Not checked" with the reason, not under "Criteria with no findings".

## 2. Criteria

Severity: **B** = Blocker (spec cannot be Ready), **M** = Major (needs an owner decision recorded), **m** = Minor (fix when convenient).

Criterion IDs are stable: they are never renumbered or reused. A new criterion gets the next free number, so numbers inside a section are not always consecutive.

### A. Single-requirement quality

| ID | Criterion | Typical failure | Sev. |
| --- | --- | --- | --- |
| RC-01 | **Necessary.** Has a stated purpose or source; removing it would leave a real gap | Requirement with no rationale, gold-plating | m |
| RC-02 | **Unambiguous.** Only one reasonable reading | "Amount is rounded" (how? at which step?) | B |
| RC-03 | **Atomic.** One requirement states one behavior. (Several conditions for *one* behavior are RC-28, not RC-03.) | Several behaviors joined by "and", "or", "as well as" | M |
| RC-04 | **Feasible.** Achievable within the scope, assumptions and constraints stated in the spec | Demands exact results with unlimited precision | M |
| RC-05 | **Verifiable.** An objective pass/fail check exists | "Shall handle errors gracefully" | B |
| RC-06 | **Implementation-free.** States what, not how, unless a design constraint is explicit and justified | Mandates a class, table or algorithm without reason | m |
| RC-07 | **Consistent terminology.** Uses glossary terms only; one term has one meaning and one meaning has one term | "Entry", "posting", "line" used interchangeably | M |
| RC-26 | **Self-contained.** The requirement itself states, or references by ID, its trigger or condition, actor, inputs and expected result. (Whether failure flows exist for the operation is RC-12.) | "The account is closed" (when? by whom? with what balance?) | M |

### B. Language quality

| ID | Criterion | Typical failure | Sev. |
| --- | --- | --- | --- |
| RC-08 | **No vague or unmeasurable words**, including a quality expressed only as its negation | fast, sufficient, appropriate, user-friendly, flexible, significant; "shall not be slow" | M |
| RC-09 | **No unresolved placeholders** | TBD, TBC, "to be defined", empty sections | B |
| RC-10 | **Clear actor and obligation.** Active voice, actor named ("The service shall ..."); obligation level (shall / shall not / should / may) follows the convention in `spec/README.md`. A `shall not` that names an observable behavior is valid ("The service shall not modify a posting") | Passive voice hiding the actor ("A notification is sent"); mixed modal verbs | m |
| RC-11 | **No escape clauses or open lists** | "if possible", "etc.", "and so on", "as needed", "where applicable" | M |
| RC-27 | **Absolutes and comparatives.** "All", "any", "always", "never" only where a test can check them; a comparative ("faster", "more accurate") carries a baseline and a number | "Always responds quickly"; "faster than before" | M |
| RC-28 | **Short, plain sentences.** One sentence per requirement statement, no stacked conditions ("unless", "provided that", "except when" in one sentence) | One sentence with three nested conditions | m |
| RC-29 | **Units and formats explicit and uniform.** Amounts carry currency and unit (major or minor); dates, time zones, percentages, sizes and durations use one format per kind of value | "Fee is 2" (2 what?); dates written as 01/02/26 and 2026-02-01 in one spec | M |

### C. Set-level quality

| ID | Criterion | Typical failure | Sev. |
| --- | --- | --- | --- |
| RC-12 | **Complete.** Normal, alternative and failure flows are covered for each operation; every operation states what happens on invalid input. RC-12 checks that the behavior *exists*; RC-23 checks that its outcome is *exact* | Create-account has no duplicate or invalid-currency behavior | B |
| RC-13 | **Consistent.** No contradictions among requirements, invariants, examples, the OpenAPI draft and the glossary | Example says 422, OpenAPI says 400 | B |
| RC-14 | **No duplicates or overlaps.** A rule is stated in one place and referenced by ID elsewhere, so changing it takes one edit | Same rule stated twice with slightly different wording | M |
| RC-15 | **Glossary complete.** Every domain term and every abbreviation (money, minor unit, posting, balance, idempotency key, ...) is defined once | Term or abbreviation used but never defined | M |
| RC-16 | **Scope, exclusions, assumptions and constraints are explicit.** "What we do not do" is listed | Fees, FX rates, concurrency limits silently assumed | M |
| RC-30 | **Levels aligned.** *Applies only if `spec/README.md` defines requirement levels* (e.g. business / user / functional). Each lower-level requirement traces to a higher-level one and none contradicts it | Functional requirement that serves no stated goal, or contradicts one | M |
| RC-31 | **Structure and readability.** Requirements are grouped logically (by area or operation); rationale and notes are kept apart from the requirement statement | Rationale mixed into "shall" sentences; one area's rules spread over several files | m |

### D. Traceability and management

| ID | Criterion | Typical failure | Sev. |
| --- | --- | --- | --- |
| RC-17 | **Unique, stable ID** in the scheme from `spec/README.md`; never reused or renumbered | Duplicate or renumbered IDs | B |
| RC-18 | **Source or rationale recorded** for each requirement | "Why does this exist?" has no answer | m |
| RC-19 | **Priority and status recorded** for each requirement, with values from `spec/README.md` | Missing status, no Ready/Draft marker, no priority | M |
| RC-20 | **Cross-references hold.** Each `INV-*` is referenced by at least one `REQ-*` and vice versa where the requirement depends on it; each OpenAPI operation maps to a requirement | Orphan invariant, OpenAPI operation with no requirement | M |
| RC-32 | **References by ID only.** Cross-references use IDs, never "see above", "as described earlier" or "the previous section" | "See above" left behind after a section was moved | m |
| RC-33 | **Version and change history.** The reviewed commit carries the annotated tag `spec-vN` (check: `git describe --tags --exact-match HEAD`), and `spec/CHANGELOG.md` has an entry for vN that lists the changed IDs since the previous version, each with a reason | Review of "latest" with no tag; silent edits after review; changelog entry missing | m |

### E. Testability

| ID | Criterion | Typical failure | Sev. |
| --- | --- | --- | --- |
| RC-21 | **Concrete examples.** Each requirement has at least two examples in given/when/then form with explicit data values. Each invariant has at least one example that satisfies it and one that violates it, with the expected rejection or detection | Prose only, or examples with placeholders | B |
| RC-22 | **Boundaries and classes identified** for numeric, string and enum inputs (zero, minimum, maximum, just above/below, negative, empty, too long, unsupported currency, rounding boundaries) | Only the happy path is exemplified | M |
| RC-23 | **Negative cases specified** with an exact expected outcome (status code, error code, state unchanged) | "Request is rejected" without saying how | M |
| RC-24 | **Examples are correct.** Arithmetic is right; examples agree with the rule text and with each other | Example sums do not balance; rounding result contradicts the stated rule | B |
| RC-25 | **Non-functional constraints are measurable** (precision, idempotency retention, ordering guarantees), or are explicitly out of scope | "High accuracy" with no number | M |

## 3. Questions for the owner (validation)

Reported in a **separate section**, never mixed into findings. What belongs here:

- A rule is well-formed, but the reviewer doubts it matches real domain practice.
- Two reasonable domain choices exist and the spec does not say which was intended.
- A behavior appears to be missing, but the owner may have decided to exclude it.
- A requirement is clear and testable, but the reviewer cannot tell which need it serves.

The reviewer asks. It does not answer these questions and does not rewrite the rule.

## 4. Verdict rules

- The reviewer's verdict depends on Blockers only: **BLOCKERS FOUND** if any Blocker is open, otherwise **NO BLOCKERS**. The reviewer never declares a requirement `Ready`.
- `Ready` is a status the owner sets on a requirement in `spec/`, and only when there are no open Blockers and every Major has a decision recorded in the report's "Owner decisions" section (fix, reject with reason, or defer with reason).
- Minor findings never block.
- A re-review after changes must reference the previous report and list which findings were closed.

## 5. Report format

File: `experiments/spec-reviews/YYYY-MM-DD-spec-vN.md`. If a second review of the same version happens on the same day, add a suffix: `-r2`, `-r3`. `spec vN` means the annotated git tag `spec-vN`, created by the owner on the commit to be reviewed. The report also records the exact commit hash.

```markdown
# Spec review — spec vN — YYYY-MM-DD

Reviewed: <list of files>; commit <output of `git rev-parse HEAD`>; tag <output of `git describe --tags --exact-match HEAD`, or "none">
Checklist version: <output of `git hash-object spec/REVIEW_CHECKLIST.md`>
Previous report: <path, or "none">
Reviewer verdict: BLOCKERS FOUND | NO BLOCKERS

## Summary
<counts by severity; list of Majors awaiting an owner decision; 3-5 lines>

## Findings
| # | Req / location | Criterion | Also | Sev. | Evidence (short) | Question or suggested direction |

## Questions for the owner (validation)
1. ...

## Criteria with no findings
<criteria checked and passed, so coverage is visible>

## Not checked
<criteria that do not apply (with the unmet condition) and anything the reviewer could not assess, with the reason>

## Closed since previous report
<finding numbers closed in a re-review; empty for a first review>

## Owner decisions
<Left empty by the reviewer. The owner appends, after the review, a table:
finding # | decision (fix / reject with reason / defer with reason) | date>
```

## 6. Quick first pass

An aid for a fast first pass. It does not replace the criteria in section 2. Ask three questions about every requirement:

1. Can I write a test case with an expected result? (RC-05, RC-21)
2. Can two people read it differently? (RC-02, RC-08)
3. Could it conflict with another requirement, an example or the OpenAPI draft? (RC-13)

## 7. Sources the criteria draw on (by name, not quoted)

- ISO/IEC/IEEE 29148, requirements engineering processes and products (supersedes IEEE 830).
- BABOK Guide (IIBA): requirements life cycle management, traceability, verification versus validation.
- Karl Wiegers and Joy Beatty, *Software Requirements*: requirement quality attributes, common problem words.
- ISTQB Foundation Level syllabus: testability, test basis, boundary value analysis, equivalence partitioning, reviews.

These are named for orientation only. If any criterion here disagrees with a source, the owner decides which wins.

## 8. Change history

- **v2:** merged the "unified" draft into v1.
  - RC-01 to RC-25 keep their v1 IDs. Extended: RC-07, RC-08, RC-10, RC-12, RC-13, RC-14, RC-15, RC-19, RC-21.
  - New: RC-26 self-contained, RC-27 absolutes and comparatives, RC-28 short sentences, RC-29 units and formats, RC-30 levels aligned (conditional), RC-31 structure, RC-32 references by ID, RC-33 version and change history.
  - Dropped from the draft: "stated positively" (it overlapped RC-08 and RC-10, and immutability rules are naturally `shall not`); SMART/INVEST mnemonics (there are no goals with deadlines and no user stories in this spec).
  - Process: earlier reports may be read for a re-review; the reviewer's verdict covers Blockers only and the owner sets `Ready`; an "Owner decisions" section was added; checklist hash = `git hash-object`; `spec vN` = annotated tag; `-r2` suffix; one defect, one finding (the "Also" column); criteria that do not apply go to "Not checked".
- **v1:** first version (owner).
