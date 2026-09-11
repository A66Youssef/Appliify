# Appliify — Test Case Catalog (scaffold)

> Full catalog is **deferred pass D10** (SRS §34). Below are the headline cases already referenced by the SRS traceability matrix (§6) and security tests (§18.3). Each will be expanded to: preconditions · input · steps · expected · failure · security validation · related requirement IDs.

| Test ID | Requirement | What it proves |
|---|---|---|
| TC-AUTH-001 | FR-AUTH-001 | Valid login issues tenant-scoped token; refresh-token reuse revokes the family. |
| TC-TENANT-001 | §18.3 | Tenant A cannot read any Tenant B entity by id (all return 404). |
| TC-TENANT-002 | §18.3 | Worker without tenant context fails closed and dead-letters. |
| TC-TENANT-003 | §18.3 | Every table carrying `tenant_id` has an RLS policy (schema test). |
| TC-CONN-001 | FR-INTEGRATION-001 | New platform connector implements the full CommerceConnector contract. |
| TC-SALLA-001 | FR-STORE-001 | Salla OAuth → connection row (encrypted) + webhooks + initial sync enqueued. |
| TC-CATALOG-001 | FR-CATALOG-001 | Re-running initial sync produces no duplicates (idempotent upsert). |
| TC-EVENT-001 | FR-EVENT-001 | Same `event_id` twice ⇒ exactly one row; counters increment once. |
| TC-CRO-001 | FR-CRO-001..004 | CRO config validates vs schema; renders only when eligible + enabled. |
| TC-PUSH-001 | FR-PUSH-001 | Broadcast respects opt-out/permission and frequency cap. |
| TC-ATTR-001 | FR-ATTR-001 | Order in app session ⇒ tagged `app` via last-non-direct; recompute is deterministic/idempotent; no-linkage platform ⇒ `unknown` + disclosure shown. |
| TC-ATTR-002 | FR-ATTR-010 (FUTURE) | Full funnel attribution (Phase 2). |
