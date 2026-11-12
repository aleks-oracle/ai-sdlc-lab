# REVIEW_CHECKLIST — requirements review criteria

Location in repo: `spec/REVIEW_CHECKLIST.md` (PROTECTED: only the owner changes it).

## 0. Purpose and limits

This checklist is applied by the `spec-reviewer` role to the requirements in `spec/` **before** implementation starts.

- The criteria are written in our own words. They are informed by well-known requirements-engineering and testing sources (see section 6), but this is **not** a compliance check against any standard, and the review does not certify anything.
- The review checks **form, consistency, completeness and testability**. It cannot confirm that a domain rule is *correct* (for example, which rounding mode is right). Such questions go to the owner in a separate section of the report.
- Verification ("is the spec written well?") and validation ("is it the right spec?") are different. This checklist covers verification and surfaces validation questions for the owner.

## 1. How to review

1. Work in a fresh session. Read only `spec/`, `PROJECT_BRIEF.md`, `CLAUDE.md` and this file. Do not read code. Do not use drafts or conversation history that produced the spec.
2. Apply every criterion to every requirement (set-level criteria to the whole spec). Do not skip criteria because the spec is short.
3. Support every finding with a short evidence reference: requirement ID and a few words from the text. Do not paraphrase the text into something it does not say.
4. Check arithmetic in examples by calculating it, not by eye.
5. Never edit `spec/`. Report findings and ask questions. Never invent requirements to fill gaps: describe the gap and ask.

## 2. Criteria

Severity guide: **B** = Blocker (spec cannot be Ready), **M** = Major (needs an owner decision recorded), **m** = Minor (fix when convenient).

### A. Single-requirement quality

| ID | Criterion | Typical failure | Sev. |
|---|---|---|---|
| RC-01 | **Necessary.** The requirement has a stated purpose or source; removing it would leave a real gap | Requirement with no rationale, gold-plating | m |
| RC-02 | **Unambiguous.** Only one reasonable reading | "Amount is rounded" (how? at which step?) | B |
| RC-03 | **Atomic.** One requirement states one thing | Several behaviors joined by "and", "or", "as well as" | M |
| RC-04 | **Feasible.** Achievable within stated constraints | Demands exact results with unlimited precision | M |
| RC-05 | **Verifiable.** An objective pass/fail check exists | "Shall handle errors gracefully" | B |
| RC-06 | **Implementation-free.** States what, not how, unless a design constraint is explicit and justified | Mandates a class, table or algorithm without reason | m |
| RC-07 | **Consistent terminology.** Uses the glossary terms with one meaning each | "Entry", "posting", "line" used interchangeably | M |

### B. Language quality

| ID | Criterion | Typical failure | Sev. |
|---|---|---|---|
| RC-08 | **No vague or unmeasurable words** | fast, sufficient, appropriate, user-friendly, flexible, significant | M |
| RC-09 | **No unresolved placeholders** | TBD, TBC, "to be defined", empty sections | B |
| RC-10 | **Clear actor and obligation.** Who or what does it, and the obligation level (shall / should / may) follows the convention defined in `spec/README.md` | Passive voice hiding the actor; mixed modal verbs | m |
| RC-11 | **No escape clauses or open lists** | "if possible", "etc.", "and so on", "as needed" | M |

### C. Set-level quality

| ID | Criterion | Typical failure | Sev. |
|---|---|---|---|
| RC-12 | **Complete.** Normal, alternative and failure flows are covered for each operation; every operation states what happens on invalid input | Create-account has no duplicate or invalid-currency behavior | B |
| RC-13 | **Consistent.** No contradictions among requirements, invariants, examples and the OpenAPI draft | Example says 422, OpenAPI says 400 | B |
| RC-14 | **No duplicates or overlaps** | Same rule stated twice with slightly different wording | M |
| RC-15 | **Glossary complete.** Every domain term (money, minor unit, posting, balance, idempotency key, ...) is defined once | Term used but never defined | M |
| RC-16 | **Scope, exclusions, assumptions and constraints are explicit.** "What we do not do" is listed | Fees, FX rates, concurrency limits silently assumed | M |

### D. Traceability and management

| ID | Criterion | Typical failure | Sev. |
|---|---|---|---|
| RC-17 | **Unique, stable ID** in the scheme from `spec/README.md`; never reused or renumbered | Duplicate or renumbered IDs | B |
| RC-18 | **Source or rationale recorded** for each requirement | "Why does this exist?" has no answer | m |
| RC-19 | **Priority and status recorded** for each requirement | Missing status, no Ready/Draft marker | M |
| RC-20 | **Cross-references hold.** Each `INV-*` is referenced by at least one `REQ-*` and vice versa where relevant; each OpenAPI operation maps to a requirement | Orphan invariant, OpenAPI operation with no requirement | M |

### E. Testability

| ID | Criterion | Typical failure | Sev. |
|---|---|---|---|
| RC-21 | **Concrete examples.** Each requirement has at least two examples in given/when/then form with explicit data values | Prose only, or examples with placeholders | B |
| RC-22 | **Boundaries and classes identified** for numeric, string and enum inputs (zero, minimum, maximum, just above/below, negative, empty, too long, unsupported currency, rounding boundaries) | Only the happy path is exemplified | M |
| RC-23 | **Negative cases specified** with an exact expected outcome (status code, error code, state unchanged) | "Request is rejected" without saying how | M |
| RC-24 | **Examples are correct.** Arithmetic is right, examples agree with the rule text and with each other | Example sums do not balance; rounding result contradicts the stated rule | B |
| RC-25 | **Non-functional constraints are measurable** (precision, idempotency retention, ordering guarantees), or are explicitly out of scope | "High accuracy" with no number | M |

## 3. Questions for the owner (validation)

Reported in a **separate section**, never mixed into findings. Examples of what belongs here:
- A rule is well-formed but the reviewer doubts it matches real domain practice.
- Two reasonable domain choices exist and the spec does not say which was intended.
- A behavior appears to be missing because the owner may have decided to exclude it.

The reviewer asks. It does not answer these questions and does not rewrite the rule.

## 4. Report format

File: `experiments/spec-reviews/YYYY-MM-DD-spec-vN.md`

```
# Spec review — spec vN — YYYY-MM-DD

Reviewed: <list of files and the git commit hash>
Checklist version: <hash of spec/REVIEW_CHECKLIST.md>
Verdict: READY | NOT READY

## Summary
<counts by severity; 3-5 lines>

## Findings
| # | Req / location | Criterion | Sev. | Evidence (short) | Question or suggested direction |

## Questions for the owner (validation)
1. ...

## Criteria with no findings
<list of criteria checked and passed, so coverage is visible>

## Not checked
<anything the reviewer could not assess and why>
```

## 5. Verdict rules

- **NOT READY** if any Blocker is open.
- **READY** only when there are no open Blockers and every Major has a recorded owner decision (fix, reject with reason, or defer with reason).
- Minor findings never block.
- A re-review after changes must reference the previous report and list which findings were closed.

## 6. Sources the criteria draw on (by name, not quoted)

- ISO/IEC/IEEE 29148, requirements engineering processes and products (supersedes IEEE 830).
- BABOK Guide (IIBA): requirements life cycle management, traceability, verification versus validation.
- Karl Wiegers and Joy Beatty, *Software Requirements*: requirement quality attributes, common problem words.
- ISTQB Foundation Level syllabus: testability, test basis, boundary value analysis, equivalence partitioning, reviews.

These are named for orientation only. If any criterion here disagrees with a source, the owner decides which wins.
