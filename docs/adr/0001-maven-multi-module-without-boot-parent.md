# ADR 0001 — Maven multi-module build without the Spring Boot parent

Status: Accepted (owner, 2026-11-12) · Stage 1

## Context
PROJECT_BRIEF section 4 asks for modules `ledger-core` (pure Java), `ledger-app` (Spring Boot) and
`blackbox-tests` (sees only `spec/` and HTTP). The usual Spring Boot setup makes
`spring-boot-starter-parent` the parent POM of the application. With several modules, that would
either make Spring the parent of everything or break the shared parent chain.

## Decision
- The root `pom.xml` is our own parent and the reactor. It does **not** inherit from the Boot parent.
- The root imports the Spring Boot BOM (`spring-boot-dependencies`, scope `import`) in
  `dependencyManagement`. A BOM manages versions only and adds no dependencies, so JUnit (6.0.3),
  AssertJ (3.27.7) and Spring versions are aligned in all modules.
- What the Boot parent would do for us is configured explicitly: Java release 25, UTF-8,
  `maven.compiler.parameters=true`, plugin versions, and the `spring-boot-maven-plugin`
  `repackage` execution in `ledger-app`.
- Module boundaries are enforced by `maven-enforcer-plugin` rules in the root POM (protected):
  no Spring outside `ledger-app`; no dependency on `ledger-core`/`ledger-app` outside `ledger-app`.
  Rules are ON by default; only `ledger-app` opts out.
- `spec/` and `experiments/` are plain folders, not Maven modules.

## Consequences
- + Spring cannot leak into `ledger-core` or `blackbox-tests` without a red build (checked by
  adding a violating dependency on 2026-11-12: both rules failed the build).
- + One place for shared build rules.
- − About 15 extra lines of plugin configuration that the Boot parent would have hidden.
- − Boot's resource filtering and some plugin defaults are not inherited; add them when needed.
