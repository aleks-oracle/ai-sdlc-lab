# ADR 0003 — How blackbox-tests reach the application

Status: **Proposed — stub.** The decision belongs to Stage 2.

## Context
`blackbox-tests` must test the running service over HTTP, derived only from `spec/` and OpenAPI.
It must not depend on `ledger-core` or `ledger-app` (enforced by the root enforcer rule
`no-sut-modules`), and the test role must not read their sources. So the tests cannot start the
app in-process (for example with `@SpringBootTest`).

## Options to decide in Stage 2
1. **`BASE_URL` against an already running app.** Tests read `BASE_URL` (env or system property).
   Locally: `java -jar ledger-app/target/ledger-app-*.jar`; CI starts it before the tests.
   + simplest, no Docker; − start/stop is outside the test run, port and readiness handling needed.
2. **Testcontainers with an app image.** CI (or a Maven step) builds an image of `ledger-app`;
   tests start it (plus Postgres later) with Testcontainers by image name.
   + self-contained, same as later "production"; − needs Docker, slower, Testcontainers 2.x on
   Java 25 must be verified first.
3. **Failsafe + process start from Maven** (e.g. start the jar in `pre-integration-test`).
   + one `./mvnw verify`; − blackbox-tests' build then needs the app jar path, which couples builds.

In all options the contract between modules is: an HTTP base URL plus `spec/openapi/`.

## Open questions for the owner
- Is Docker required for every local test run, or only in CI?
- Is the app jar built in the same Maven reactor run, or by a separate CI job?
