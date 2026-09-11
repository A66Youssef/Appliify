# Architecture Decision Records

The full ADRs (ADR-001 … ADR-012) are authored inline in [`../../SRS.md`](../../SRS.md) §31 to keep context, alternatives, and consequences next to the specification they govern.

| ADR | Title |
|---|---|
| ADR-001 | Modular Monolith |
| ADR-002 | PostgreSQL as primary datastore |
| ADR-003 | REST APIs |
| ADR-004 | Redis for cache + rate-limit + queue backing |
| ADR-005 | Queue architecture (BullMQ → managed queue at scale) |
| ADR-006 | Event-driven processing |
| ADR-007 | Shared-database multi-tenancy |
| ADR-008 | PostgreSQL RLS for tenant isolation |
| ADR-009 | Capacitor native shell + WebView storefront |
| ADR-010 | CRO configuration architecture (schema-validated plugin model) |
| ADR-011 | Attribution model = last non-direct touch (V1.0) |
| ADR-012 | Platform-agnostic connector abstraction |
