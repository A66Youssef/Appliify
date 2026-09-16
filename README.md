# Appliify — Technical Documentation

> In-App Growth & Conversion Platform for E-commerce Merchants (multi-platform: Salla, Zid, WooCommerce; Shopify fast-follow).

This repository holds the technical source of truth for **Appliify V1.0**, aligned to **BRD v1.1** and **PRD v1.1**.

## Documents

| Path | Status | Description |
|---|---|---|
| [`docs/SRS.md`](docs/SRS.md) | **COMPLETE (77 sections)** | Single technical source of truth — full spec: architecture, domains, data layer, APIs, attribution, push/CRO/segmentation, analytics/LTV, jobs/queues/cache, mobile & dashboard, security/privacy/audit/observability, NFRs, testing, deployment/DR, commercial analytics, design system & visual identity, and final audits + backlog. |
| [`docs/database/schema.sql`](docs/database/schema.sql) | **Complete (V1.0 core)** | Authoritative PostgreSQL DDL: 43 tables, RLS on every tenant-owned table, partitioning, indexes. |
| [`docs/api/openapi.yaml`](docs/api/openapi.yaml) | **Complete (D1)** | OpenAPI 3.1: 31 paths, 34 operations, 26 schemas, security schemes, standard errors. |
| [`docs/events/event-catalog.md`](docs/events/event-catalog.md) | Summary → deferred pass D4/D5 | Event taxonomy (authoritative copy lives in SRS §27). |
| [`docs/testing/test-catalog.md`](docs/testing/test-catalog.md) | Scaffold → deferred pass D10 | Test case catalog. |
| [`docs/architecture/integration-and-sync.md`](docs/architecture/integration-and-sync.md) | **Complete (D3)** | Salla reference connector, webhook pipeline, sync engine, reconciliation, outage handling — 39 explicit `TO VERIFY`. |
| [`docs/architecture/adr/`](docs/architecture/adr/) | In SRS §31 | Architecture Decision Records (ADR-001 … ADR-012). |
| [`docs/design/design-system.md`](docs/design/design-system.md) | **v1.0 — Draft, pending sign-off** | Design tokens, component rules, and screen-level wireframe intent for every SRS §47.1/§49 screen (Premium visual identity). |

## Reading order

1. `docs/SRS.md` §1–§5 — what/why/scope (note the resolved single-vs-multi-platform conflict in §4.5).
2. §13–§18 — domains, architecture, connector abstraction, multi-tenancy.
3. §20–§25 + `schema.sql` — the data layer.
4. §26–§30 — events, APIs, and the revenue-attribution differentiator.
5. §31–§34 — decisions, risks, open `TO VERIFY` items, and the roadmap for the remaining passes.

## Critical open items (see SRS §33)

The highest-risk unknowns are **platform API capabilities** — especially whether each platform (Salla/Zid/WooCommerce) exposes an **order → app-session linkage**, which the revenue-attribution feature depends on. These are marked `TO VERIFY` and must be confirmed against each platform's live developer documentation before its connector is certified.
