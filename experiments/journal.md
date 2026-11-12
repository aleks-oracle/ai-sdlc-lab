# Journal

Newest entry at the bottom. Each entry: done, broke, decisions (with reasons), next.

---

## 2026-11-12 — Stage 1: skeleton, roles, spike

**Done**
- Checked versions on Maven Central and in the docs: Spring Boot 4.1.2 (docs: Java 17 up to 27), Maven 3.9.16,
  compiler 3.15.0, Surefire/Failsafe 3.5.6, enforcer 3.6.3 (the plugin versions the Boot 4.1.2 BOM uses).
- Spike on branch `spike/junit6-jqwik-pit` (local only, throwaway): Java 25.0.5 + JUnit 6.0.3 (Boot BOM) +
  jqwik 1.10.2 + PIT 1.30.2 with pitest-junit5-plugin 1.2.3. Jupiter test and jqwik property (1000 tries) ran;
  PIT generated 4 mutants, killed 4, and one of them could only be killed by the jqwik property, so PIT runs
  jqwik too. Repeated with JUnit 6.1.3: same result. jqwik 1.10.2 declares JUnit Platform 1.14.4 in its POM, but
  runs on Platform 6.0.3 and 6.1.3 in this setup.
- Maven multi-module skeleton on branch `stage-1/skeleton` (ADR 0001): root POM without Boot parent, Boot BOM
  import, enforcer rules (protected), Maven Wrapper 3.3.4 only-script with pinned SHA-256 (ADR 0002).
  `./mvnw verify` green: 1 test (context loads), executable jar 9.1 MB.
- Negative checks of the enforcer rules: added Spring to ledger-core → build failed; added ledger-core to
  blackbox-tests → build failed. Changes reverted.
- Role enforcement (ADR 0004): agent definitions for dev, test, auditor, spec-reviewer; `role-guard.sh` hook;
  shared settings; sandbox settings and launcher for test and spec-reviewer. Hook script check: 58/58 cases.
- `CLAUDE.md`, `PLAN.md`, spec conventions and template, `experiments/spec-reviews/README.md`,
  ADR 0003 stub, EXP-001 draft.

**Broke / surprises**
- `mvn` is not installed → Maven Wrapper (owner decision).
- The Boot 4.1.2 BOM manages JUnit **6.0.3**, not 6.1.x. We use 6.0.3 to stay aligned with the BOM.
- In the spike, the jqwik class `MoneyProperties` was silently not run: Surefire's default includes match only
  `*Test`, `*Tests`, `Test*`, `*TestCase`. 0 tests from a class without an error is exactly the kind of silent
  gap the test-integrity gate must catch. Decide naming or includes in Stage 3.
- My first hook test harness had a bug (bash `read` with a tab IFS collapses empty fields), so one case looked
  like a pass for the wrong reason. Fixed with an explicit `<none>` marker.
- `spring-boot-starter-test` prints a JDK warning about a dynamically loaded agent (Byte Buddy / Mockito).
  Harmless now; fix later with `-javaagent` in Surefire if we use Mockito.

**Decisions (owner, this session)**
- Boot 4.1.2 in ledger-app now, only an empty app + context-loads test.
- groupId `io.github.aleks-oracle`; packages `io.github.aleks_oracle.ledger.*` (`-` is illegal in Java packages;
  the JLS convention is `_`).
- IDs `REQ-<AREA>-<NNN>`, `INV-<NNN>`, never reused or renumbered. Tag vs annotation: Stage 3.
- Enforcer rules in the root POM, protected.

**Decisions (agent, need owner review)**
- `spec/README.md` and `spec/requirements/_TEMPLATE.md` were written by the agent (brief §11.2 asked for a
  template) although `spec/` is owner-only. Review them in the PR.
- Test and spec-reviewer roles do not read or write this journal (it may describe the implementation); they
  report in chat. This differs from brief §10.
- Protected paths other than `spec/` are `ask` rules (approval prompt), not `deny`, because the brief allows
  changes "with explicit owner approval". `spec/` is `deny` (owner edits it outside Claude).

**Next**
- Owner reviews the PR. `gh` is not installed, so the PR is not opened yet.
- Run EXP-001 in fresh role sessions.
- Step 3: propose the CI workflow (build, protected-path check, test-integrity check).
