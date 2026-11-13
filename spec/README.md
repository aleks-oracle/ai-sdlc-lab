# spec/ — requirements for the ledger service

**PROTECTED.** Only the owner changes files in `spec/` (PROJECT_BRIEF sections 5, 6, 8a).
Agents may propose text in chat or in a report, but never edit these files.

This README defines the conventions that `REVIEW_CHECKLIST.md` refers to (IDs, obligation words,
status, priority). It was drafted by an agent in Stage 1 on the owner's request and must be
approved by the owner.

## 1. Files

| Path | Content |
|---|---|
| `README.md` | This file: conventions |
| `REVIEW_CHECKLIST.md` | Criteria for the spec-reviewer role (owner-supplied) |
| `requirements/_TEMPLATE.md` | Copy this to write a new requirement or invariant. Not a requirement itself |
| `requirements/<area>.md` | Requirements of one area, e.g. `requirements/accounts.md` (from Stage 2) |
| `invariants.md` | `INV-*` rules that must always hold (from Stage 2) |
| `glossary.md` | Every domain term, defined once (from Stage 2) |
| `openapi/` | OpenAPI contract (from Stage 2) |

## 2. Identifiers

- Requirement: `REQ-<AREA>-<NNN>`, for example `REQ-TXN-001`.
  - `<AREA>`: 2–5 upper-case letters. The owner keeps the list of areas in the table below.
  - `<NNN>`: three digits, starting at `001`, unique within the area.
- Invariant: `INV-<NNN>`, for example `INV-001`.
- Regex (the Stage 3 linter will use these): `^REQ-[A-Z]{2,5}-[0-9]{3}$` and `^INV-[0-9]{3}$`.
- **IDs are never reused or renumbered.** A removed requirement stays in the file with status
  `Withdrawn` and a reason. A changed requirement keeps its ID; its history lives in git.
- Example IDs inside a requirement: `<REQ-ID>-EX<NN>`, for example `REQ-TXN-001-EX01`.
  Tests may reference an example ID to show which example they cover.

| Area | Meaning |
|---|---|
| *(owner fills in Stage 2)* | |

## 3. Obligation words

| Word | Meaning | Testable? |
|---|---|---|
| **shall** | Mandatory. Failing it is a defect. | Yes, every `shall` needs examples |
| **shall not** | Mandatory prohibition. | Yes |
| **should** | Recommended; deviation needs a recorded reason. | Only if the owner adds examples |
| **may** | Optional, allowed behavior. | No |

Other modal verbs (`must`, `will`, `can`, `needs to`) are not used in requirement statements.
The actor is always named: "The service shall …", not "It shall be …".

## 4. Priority and status

- **Priority:** `Must` | `Should` | `Could`.
- **Status:** `Draft` → `In review` → `Ready` (or `Withdrawn` at any point).
  - `Draft`: being written by the owner.
  - `In review`: frozen for the spec readiness gate (PROJECT_BRIEF section 8a).
  - `Ready`: the review report has no open Blocker, and every Major has an owner decision.
    Only `Ready` requirements may be implemented or tested.
  - `Withdrawn`: kept for traceability, never implemented, ID never reused.

## 5. What every requirement contains

See `requirements/_TEMPLATE.md`. In short: ID, title, priority, status, statement, rationale or
source, related invariants, related OpenAPI operations, at least two given/when/then examples with
explicit data values, boundaries and classes, negative cases with an exact outcome, and open
questions (must be empty before `Ready`).

## 6. Traceability

Every test must reference the requirement (or invariant) it verifies. The exact mechanism
(a JUnit tag or a custom annotation) is decided in Stage 3.
