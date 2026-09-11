# Appliify — Event Catalog

> The **authoritative** event taxonomy and envelope live in [`../SRS.md`](../SRS.md) §26–§27. This file is a convenience index; keep it in sync (RULE P).

## Envelope
See SRS §26.1 — fields: `event_id` (idempotency), `type`, `version`, `tenant_id`, `occurred_at`, `correlation_id`, `causation_id`, `identity{installation_id, shopper_id, session_id, is_anonymous}`, `properties`.

## Behavioral (client) events
`app_open`, `session_start`, `session_end`, `product_view`, `add_to_cart`, `remove_from_cart`, `checkout_start`, `purchase`, `wishlist_add`, `wishlist_remove`, `notification_received`, `notification_opened`, `campaign_clicked`, `cro_feature_impression`, `cro_feature_interaction`.

## Backend-detected events
`cart_abandoned`, `back_in_stock`.

## Domain events
`store.connected`, `store.disconnected`, `sync.enqueued`, `sync.completed`, `catalog.synced`, `inventory.updated`, `order.created`, `order.attributed`, `identity.merged`, `segment.evaluated`, `campaign.created`, `notification.sent`, `notification.opened`, `subscription.changed`, `feature_flag.changed`.

## Semantics
At-least-once delivery; idempotent on `event_id`; deterministic where ordering matters; partitioned retention per SRS §23. Full per-event producer/consumer/property tables: SRS §27. **Deferred pass D4/D5** will add per-event JSON schemas.
