# ADR 0002 — Maven Wrapper pinned to Maven 3.9.16

Status: Accepted (owner, 2026-11-12) · Stage 1

## Context
Maven is not installed on the owner's machine. CI and every agent session must use the same Maven.

## Decision
- Commit the Maven Wrapper 3.3.4 (`mvnw`, `mvnw.cmd`, `.mvn/wrapper/maven-wrapper.properties`).
- Type `only-script`: no `maven-wrapper.jar` (the repo ignores `*.jar`); the script downloads Maven.
- Maven 3.9.16 (mature 3.9 line; 3.10.0 exists but was not needed).
- `distributionSha256Sum` is pinned; it was checked against the SHA-512 on Maven Central.

## Consequences
- Use `./mvnw`, never a global `mvn`. First run downloads Maven into `~/.m2/wrapper`.
- Upgrading Maven = change two lines in `maven-wrapper.properties` (URL and checksum).
