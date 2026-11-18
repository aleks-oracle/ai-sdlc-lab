# Template — copy a block below into `requirements/<area>.md` or `invariants.md`

This file is a template, not a requirement. Text in `<angle brackets>` is to be replaced.
The Stage 3 linter will skip this file.
Conventions: `spec/README.md`. Review criteria: `spec/REVIEW_CHECKLIST.md` (RC-xx references below).

---

## REQ-<AREA>-<NNN> — <short title>

| Field | Value |
|---|---|
| Priority | <Must \| Should \| Could> |
| Status | <Draft \| In review \| Ready \| Withdrawn> |
| Rationale / source | <why this exists; RC-01, RC-18> |
| Invariants | <INV-NNN, ... or "none"; RC-20> |
| OpenAPI operations | <operationId, ... or "none"; RC-20> |

**Statement** (one behavior, one `shall`; RC-02, RC-03, RC-10)

The <actor> shall <observable behavior> when <condition>.

**Examples** (at least two, explicit data values, no placeholders; RC-21, RC-24)

- `REQ-<AREA>-<NNN>-EX01` — <name>
  - Given <state with concrete values>
  - When <action with concrete values>
  - Then <exact observable outcome>
- `REQ-<AREA>-<NNN>-EX02` — <name>
  - Given …
  - When …
  - Then …

**Boundaries and classes** (RC-22)

| Input | Valid classes / boundaries | Invalid classes / boundaries |
|---|---|---|
| <field> | <e.g. 0.01, max value> | <e.g. 0, -0.01, too many decimals, empty> |

**Negative cases** (exact outcome: status code, error code, state unchanged; RC-23)

| Case | Expected outcome |
|---|---|
| <invalid input or state> | <HTTP status, error code, what stays unchanged> |

**Open questions** (must be empty before status `Ready`)

- <question for the owner>

---

## INV-<NNN> — <short title>

| Field | Value |
|---|---|
| Status | <Draft \| In review \| Ready \| Withdrawn> |
| Rationale / source | <why this must always hold> |
| Referenced by | <REQ-..., ...; RC-20> |

**Rule** (precise, checkable at any time)

For every <entity>, <condition that always holds>.

**Examples** (at least one that holds and one that would violate it, with numbers; RC-21, RC-24)

- `INV-<NNN>-EX01` holds: <concrete data>
- `INV-<NNN>-EX02` violated (must be impossible to reach): <concrete data>
