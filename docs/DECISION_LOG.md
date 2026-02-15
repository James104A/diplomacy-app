# Decision Log

Implementation decisions made during development that deviate from, extend, or clarify the spec documents. This serves as the living appendix to the PRD (Context/Diplomacy_Mobile_App_PRD.docx).

## Infrastructure & Tooling

| # | Date | Decision | Context | Alternatives Considered |
|---|------|----------|---------|------------------------|
| D-001 | 2026-02-14 | **Terraform** for IaC (not AWS CDK) | E0-S5: Simpler declarative HCL, no build step, easier team onboarding | AWS CDK (TypeScript) |
| D-002 | 2026-02-14 | **Full VPC with private subnets** for staging | E0-S5: RDS and ElastiCache in private subnets for security parity with production. Single NAT gateway to reduce cost (~$32/mo) | Default VPC (cheaper but all resources on public subnets) |
| D-003 | 2026-02-14 | **Spring Boot** (not Ktor) for backend framework | E0-S2: Mature ecosystem, built-in R2DBC/Redis/Flyway/Actuator/Security integration, broader hiring pool | Ktor (lighter weight, more idiomatic Kotlin) |
| D-004 | 2026-02-14 | **Spring WebFlux** (reactive) over Spring MVC (blocking) | E0-S2: Non-blocking I/O suits the WebSocket-heavy game server and R2DBC Postgres driver | Spring MVC with virtual threads |

## Database & Schema

| # | Date | Decision | Context | Alternatives Considered |
|---|------|----------|---------|------------------------|
| D-005 | 2026-02-14 | **VARCHAR with CHECK constraints** for enums (not Postgres ENUM types) | E1-S1: Per Data Models spec Section 1.2 — allows additive changes without migrations | PostgreSQL ENUM types |
| D-006 | 2026-02-14 | **Flyway migration numbering starts at V1**, not V001 | E1-S1: Flyway treats both as valid; simpler numbering. Spec suggested V001 but functional behavior is identical | Zero-padded V001 numbering |
| D-007 | 2026-02-14 | **82 territory rows** in seed data (not 75) | E1-S5: 75 base territories + 6 multi-coast sub-entries (STP_NC/SC, SPA_NC/SC, BUL_EC/SC) + NAO (North Atlantic Ocean, standard in Classic map but not counted in some references). The spec's "75 territories" counts multi-coast parents as single territories | N/A |
| D-008 | 2026-02-14 | **Bidirectional adjacencies via temp table mirroring** | E1-S5: Insert one direction, then `INSERT ... SELECT` to mirror. Avoids error-prone manual duplication of ~450 rows | Manual bidirectional inserts |
| D-009 | 2026-02-14 | **Separate `territories`, `adjacencies`, `starting_positions` tables** for map data | E1-S5: Relational structure supports future variant maps and is queryable by the adjudication engine. Spec showed JSONB-based map structure for API transport, but relational is better for persistence | Single JSONB column on a `maps` table |

## Authentication & Security

| # | Date | Decision | Context | Alternatives Considered |
|---|------|----------|---------|------------------------|
| D-010 | 2026-02-14 | **JJWT library** for JWT signing/validation | E2-S1: Most popular Java JWT library, supports HMAC-SHA256, actively maintained | Spring Security OAuth2 resource server, Nimbus JOSE |
| D-011 | 2026-02-14 | **HMAC-SHA256** for JWT signing (symmetric key) | E2-S1: Single backend service doesn't need asymmetric keys. Simpler config. Can migrate to RSA when adding separate API gateway | RSA-256 (asymmetric, needed for multi-service JWT validation) |
| D-012 | 2026-02-14 | **Refresh token rotation via Redis `setIfAbsent`** | E2-S4: Each refresh token has a unique JTI. On use, JTI is written to Redis with TTL. If already present, token was reused → 401. Simple, no separate token table needed | Database-backed refresh token table, Redis SET with token hash |
| D-013 | 2026-02-14 | **Apple Sign In verifies JWKS from appleid.apple.com** | E2-S3: Fetches Apple's public keys at runtime, validates RS256 signature. Creates player on first use, links on subsequent logins via email match | Static key pinning, third-party Apple auth library |
| D-014 | 2026-02-14 | **`DELETE /v1/auth/account` is soft-delete only** | E2-S6: Sets `deleted_at` timestamp per GDPR spec. Hard deletion handled by background job within 30 days (not yet implemented) | Immediate hard delete |
| D-015 | 2026-02-14 | **Google Sign In deferred** | E2-S3: API spec lists Google as a provider but Epic 2 stories only specify Apple. Google can be added later using same pattern as Apple (OIDC token verification) | Implement all three providers simultaneously |
