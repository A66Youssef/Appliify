-- =====================================================================
-- Appliify — Production PostgreSQL Schema (V1.0 Core Foundation)
-- Authoritative DDL referenced by docs/SRS.md §25.
-- Consistency rule (RULE P): this file, the Data Dictionary (SRS §20),
-- and the ERD (SRS §24) must change together.
--
-- Conventions:
--   * uuid PKs via gen_random_uuid() (pgcrypto)
--   * timestamptz stored UTC
--   * soft delete via deleted_at
--   * every tenant-owned table carries tenant_id + an RLS policy
--   * partitioned tables: events, revenue_events, notification_deliveries,
--     notification_opens, attribution_touchpoints, audit_logs
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------
-- 1. ENUM TYPES
-- ---------------------------------------------------------------------
CREATE TYPE tenant_status        AS ENUM ('active','suspended','deleted');
CREATE TYPE merchant_role        AS ENUM ('admin','staff');
CREATE TYPE user_status          AS ENUM ('active','disabled');
CREATE TYPE session_subject      AS ENUM ('merchant_user','shopper');
CREATE TYPE subscription_status  AS ENUM ('trialing','active','past_due','canceled');
CREATE TYPE invoice_status       AS ENUM ('open','paid','void');
CREATE TYPE platform_type        AS ENUM ('salla','zid','woocommerce','shopify');
CREATE TYPE store_status         AS ENUM ('connected','degraded','reauth_required','disconnected');
CREATE TYPE connection_status    AS ENUM ('active','degraded','reauth_required','disconnected');
CREATE TYPE device_os            AS ENUM ('ios','android');
CREATE TYPE installation_status  AS ENUM ('active','uninstalled');
CREATE TYPE push_provider        AS ENUM ('fcm','apns');
CREATE TYPE identifier_type      AS ENUM ('email_hash','phone_hash','external');
CREATE TYPE product_status       AS ENUM ('active','archived');
CREATE TYPE cart_status          AS ENUM ('active','abandoned','converted');
CREATE TYPE order_channel        AS ENUM ('app','web','unknown');
CREATE TYPE order_status         AS ENUM ('created','paid','refunded','partially_refunded','cancelled');
CREATE TYPE feature_status       AS ENUM ('ga','beta','deprecated');
CREATE TYPE campaign_status      AS ENUM ('draft','scheduled','sending','sent','cancelled');
CREATE TYPE notification_status  AS ENUM ('draft','scheduled','queued','sending','sent','cancelled','suppressed','expired','failed');
CREATE TYPE delivery_status      AS ENUM ('queued','sending','sent','failed','suppressed');
CREATE TYPE touchpoint_type      AS ENUM ('app_session','notification_open','campaign_click','cro_interaction');
CREATE TYPE attribution_model    AS ENUM ('last_non_direct');
CREATE TYPE revenue_event_type   AS ENUM ('sale','refund','cancellation','partial_refund');
CREATE TYPE webhook_status       AS ENUM ('received','processed','failed','dead');
CREATE TYPE sync_kind            AS ENUM ('catalog','inventory','orders','customers');
CREATE TYPE sync_status          AS ENUM ('pending','running','completed','failed','partial');
CREATE TYPE flag_scope           AS ENUM ('global','tenant');

-- ---------------------------------------------------------------------
-- 2. TENANCY HELPER (RLS)
--    Session sets: SET LOCAL app.tenant_id = '<uuid>';
--    current_tenant() returns NULL when unset -> policies match no rows.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION current_tenant() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT nullif(current_setting('app.tenant_id', true), '')::uuid
$$;

-- Convenience macro (documentation): apply to every tenant-owned table
--   ALTER TABLE <t> ENABLE ROW LEVEL SECURITY;
--   CREATE POLICY <t>_isolation ON <t> USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 3. TENANT / BILLING
-- ---------------------------------------------------------------------
CREATE TABLE plans (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code        text NOT NULL UNIQUE,
  name        text NOT NULL,
  price_cents int  NOT NULL CHECK (price_cents >= 0),
  currency    text NOT NULL,
  features    jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  deleted_at  timestamptz
);

CREATE TABLE tenants (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text NOT NULL,
  slug       text NOT NULL UNIQUE,
  status     tenant_status NOT NULL DEFAULT 'active',
  plan_id    uuid REFERENCES plans(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE TABLE merchants (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL UNIQUE REFERENCES tenants(id),
  legal_name    text,
  country       text,
  contact_email text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  deleted_at    timestamptz
);
ALTER TABLE merchants ENABLE ROW LEVEL SECURITY;
CREATE POLICY merchants_isolation ON merchants USING (tenant_id = current_tenant());

CREATE TABLE merchant_users (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          uuid NOT NULL REFERENCES tenants(id),
  email              text NOT NULL,
  password_hash      text NOT NULL,
  role               merchant_role NOT NULL DEFAULT 'staff',
  status             user_status NOT NULL DEFAULT 'active',
  last_login_at      timestamptz,
  failed_login_count int  NOT NULL DEFAULT 0,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  deleted_at         timestamptz,
  UNIQUE (tenant_id, email)
);
ALTER TABLE merchant_users ENABLE ROW LEVEL SECURITY;
CREATE POLICY merchant_users_isolation ON merchant_users USING (tenant_id = current_tenant());

CREATE TABLE subscriptions (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES tenants(id),
  plan_id             uuid NOT NULL REFERENCES plans(id),
  status              subscription_status NOT NULL DEFAULT 'trialing',
  current_period_end  timestamptz,
  external_ref        text,                       -- billing provider id (TO VERIFY)
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  deleted_at          timestamptz
);
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY subscriptions_isolation ON subscriptions USING (tenant_id = current_tenant());

CREATE TABLE invoices (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants(id),
  subscription_id uuid NOT NULL REFERENCES subscriptions(id),
  amount_cents    int  NOT NULL CHECK (amount_cents >= 0),
  currency        text NOT NULL,
  status          invoice_status NOT NULL DEFAULT 'open',
  issued_at       timestamptz NOT NULL DEFAULT now(),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  deleted_at      timestamptz
);
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
CREATE POLICY invoices_isolation ON invoices USING (tenant_id = current_tenant());

CREATE TABLE branding_configs (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL UNIQUE REFERENCES tenants(id),
  logo_url       text,
  primary_color  text CHECK (primary_color   IS NULL OR primary_color   ~ '^#[0-9A-Fa-f]{6}$'),
  secondary_color text CHECK (secondary_color IS NULL OR secondary_color ~ '^#[0-9A-Fa-f]{6}$'),
  splash_config  jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now(),
  deleted_at     timestamptz
);
ALTER TABLE branding_configs ENABLE ROW LEVEL SECURITY;
CREATE POLICY branding_isolation ON branding_configs USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 4. SESSIONS (dashboard + shopper; subject_type distinguishes)
-- ---------------------------------------------------------------------
CREATE TABLE sessions (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          uuid NOT NULL REFERENCES tenants(id),
  subject_type       session_subject NOT NULL,
  subject_id         uuid NOT NULL,
  refresh_token_hash text,
  token_family_id    uuid,
  ip                 inet,
  user_agent         text,
  expires_at         timestamptz NOT NULL,
  revoked_at         timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX sessions_refresh_idx ON sessions (refresh_token_hash);
CREATE INDEX sessions_family_idx  ON sessions (token_family_id);
CREATE INDEX sessions_subject_idx ON sessions (subject_type, subject_id);
CREATE INDEX sessions_expiry_idx  ON sessions (expires_at);
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY sessions_isolation ON sessions USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 5. STORE + INTEGRATION
-- ---------------------------------------------------------------------
CREATE TABLE stores (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES tenants(id),
  platform          platform_type NOT NULL,
  external_store_id text NOT NULL,
  name              text,
  status            store_status NOT NULL DEFAULT 'connected',
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  deleted_at        timestamptz,
  UNIQUE (tenant_id, platform, external_store_id)
);
CREATE INDEX stores_status_idx ON stores (tenant_id, status);
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
CREATE POLICY stores_isolation ON stores USING (tenant_id = current_tenant());

CREATE TABLE integration_connections (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          uuid NOT NULL REFERENCES tenants(id),
  store_id           uuid NOT NULL REFERENCES stores(id),
  platform           platform_type NOT NULL,
  access_token_enc   bytea NOT NULL,
  refresh_token_enc  bytea,
  token_expires_at   timestamptz,
  webhook_secret_enc bytea,
  scopes             text[],
  status             connection_status NOT NULL DEFAULT 'active',
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  deleted_at         timestamptz
);
-- BR-SYNC-01: one active connection per store
CREATE UNIQUE INDEX integ_one_active_per_store
  ON integration_connections (store_id)
  WHERE status <> 'disconnected';
CREATE INDEX integ_token_expiry_idx ON integration_connections (token_expires_at);
ALTER TABLE integration_connections ENABLE ROW LEVEL SECURITY;
CREATE POLICY integ_isolation ON integration_connections USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 6. CATALOG
-- ---------------------------------------------------------------------
CREATE TABLE products (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES tenants(id),
  store_id            uuid NOT NULL REFERENCES stores(id),
  platform            platform_type NOT NULL,
  external_id         text NOT NULL,
  title               text NOT NULL,
  status              product_status NOT NULL DEFAULT 'active',
  updated_at_external timestamptz,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  deleted_at          timestamptz,
  UNIQUE (tenant_id, platform, external_id)
);
CREATE INDEX products_store_status_idx ON products (tenant_id, store_id, status);
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY products_isolation ON products USING (tenant_id = current_tenant());

CREATE TABLE product_variants (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES tenants(id),
  product_id  uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  external_id text NOT NULL,
  sku         text,
  price_cents int CHECK (price_cents IS NULL OR price_cents >= 0),
  currency    text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  deleted_at  timestamptz,
  UNIQUE (tenant_id, product_id, external_id)
);
CREATE INDEX variants_sku_idx ON product_variants (sku);
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
CREATE POLICY variants_isolation ON product_variants USING (tenant_id = current_tenant());

CREATE TABLE inventory (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id  uuid NOT NULL REFERENCES tenants(id),
  variant_id uuid NOT NULL UNIQUE REFERENCES product_variants(id) ON DELETE CASCADE,
  quantity   int NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  in_stock   boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX inventory_instock_idx ON inventory (tenant_id, in_stock);
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
CREATE POLICY inventory_isolation ON inventory USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 7. SHOPPER / DEVICE / IDENTITY
-- ---------------------------------------------------------------------
CREATE TABLE shopper_profiles (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id            uuid NOT NULL REFERENCES tenants(id),
  is_anonymous         boolean NOT NULL DEFAULT true,
  external_customer_id text,
  email                text,
  phone                text,
  display_name         text,
  merged_into_id       uuid REFERENCES shopper_profiles(id),
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  deleted_at           timestamptz
);
-- authenticated identity uniqueness (partial: only when external id present & not merged)
CREATE UNIQUE INDEX shopper_external_uniq
  ON shopper_profiles (tenant_id, external_customer_id)
  WHERE external_customer_id IS NOT NULL AND merged_into_id IS NULL;
CREATE INDEX shopper_anon_idx   ON shopper_profiles (tenant_id, is_anonymous);
CREATE INDEX shopper_merged_idx ON shopper_profiles (merged_into_id);
ALTER TABLE shopper_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY shopper_isolation ON shopper_profiles USING (tenant_id = current_tenant());

CREATE TABLE shopper_identifiers (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id  uuid NOT NULL REFERENCES tenants(id),
  shopper_id uuid NOT NULL REFERENCES shopper_profiles(id) ON DELETE CASCADE,
  id_type    identifier_type NOT NULL,
  id_value   text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, id_type, id_value)
);
CREATE INDEX shopper_ids_shopper_idx ON shopper_identifiers (shopper_id);
ALTER TABLE shopper_identifiers ENABLE ROW LEVEL SECURITY;
CREATE POLICY shopper_ids_isolation ON shopper_identifiers USING (tenant_id = current_tenant());

CREATE TABLE devices (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES tenants(id),
  fingerprint text NOT NULL,
  platform_os device_os NOT NULL,
  model       text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, fingerprint)
);
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;
CREATE POLICY devices_isolation ON devices USING (tenant_id = current_tenant());

CREATE TABLE app_installations (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          uuid NOT NULL REFERENCES tenants(id),
  device_id          uuid NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  install_token_hash text NOT NULL UNIQUE,
  app_version        text,
  status             installation_status NOT NULL DEFAULT 'active',
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX installations_device_idx ON app_installations (device_id);
CREATE INDEX installations_status_idx ON app_installations (tenant_id, status);
ALTER TABLE app_installations ENABLE ROW LEVEL SECURITY;
CREATE POLICY installations_isolation ON app_installations USING (tenant_id = current_tenant());

CREATE TABLE device_push_tokens (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants(id),
  installation_id uuid NOT NULL REFERENCES app_installations(id) ON DELETE CASCADE,
  provider        push_provider NOT NULL,
  token           text NOT NULL UNIQUE,
  valid           boolean NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX push_tokens_valid_idx ON device_push_tokens (tenant_id, valid);
ALTER TABLE device_push_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY push_tokens_isolation ON device_push_tokens USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 8. COMMERCE
-- ---------------------------------------------------------------------
CREATE TABLE carts (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid NOT NULL REFERENCES tenants(id),
  shopper_id   uuid NOT NULL REFERENCES shopper_profiles(id),
  session_id   uuid REFERENCES sessions(id),
  status       cart_status NOT NULL DEFAULT 'active',
  abandoned_at timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  deleted_at   timestamptz
);
CREATE INDEX carts_shopper_status_idx ON carts (tenant_id, shopper_id, status);
CREATE INDEX carts_abandon_sweep_idx  ON carts (status, abandoned_at);
ALTER TABLE carts ENABLE ROW LEVEL SECURITY;
CREATE POLICY carts_isolation ON carts USING (tenant_id = current_tenant());

CREATE TABLE cart_items (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid NOT NULL REFERENCES tenants(id),
  cart_id          uuid NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
  variant_id       uuid NOT NULL REFERENCES product_variants(id),
  quantity         int NOT NULL CHECK (quantity > 0),
  unit_price_cents int CHECK (unit_price_cents IS NULL OR unit_price_cents >= 0),
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX cart_items_cart_idx ON cart_items (cart_id);
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY cart_items_isolation ON cart_items USING (tenant_id = current_tenant());

CREATE TABLE orders (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES tenants(id),
  store_id          uuid NOT NULL REFERENCES stores(id),
  platform          platform_type NOT NULL,
  external_order_id text NOT NULL,
  shopper_id        uuid REFERENCES shopper_profiles(id),
  session_id        uuid REFERENCES sessions(id),   -- app session at checkout (TO VERIFY per platform)
  channel           order_channel NOT NULL DEFAULT 'unknown',
  gross_cents       int  NOT NULL CHECK (gross_cents    >= 0),
  discount_cents    int  NOT NULL DEFAULT 0 CHECK (discount_cents >= 0),
  net_cents         int  NOT NULL CHECK (net_cents      >= 0),
  currency          text NOT NULL,
  status            order_status NOT NULL DEFAULT 'created',
  placed_at         timestamptz NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  deleted_at        timestamptz,
  UNIQUE (tenant_id, platform, external_order_id)   -- BR-ATTR-07
);
CREATE INDEX orders_shopper_idx ON orders (tenant_id, shopper_id);
CREATE INDEX orders_time_idx    ON orders (tenant_id, placed_at);
CREATE INDEX orders_session_idx ON orders (session_id);
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY orders_isolation ON orders USING (tenant_id = current_tenant());

CREATE TABLE order_items (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid NOT NULL REFERENCES tenants(id),
  order_id         uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  variant_id       uuid REFERENCES product_variants(id),
  quantity         int NOT NULL CHECK (quantity > 0),
  unit_price_cents int NOT NULL CHECK (unit_price_cents >= 0),
  created_at       timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX order_items_order_idx ON order_items (order_id);
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY order_items_isolation ON order_items USING (tenant_id = current_tenant());

CREATE TABLE wishlists (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id  uuid NOT NULL REFERENCES tenants(id),
  shopper_id uuid NOT NULL REFERENCES shopper_profiles(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, shopper_id)
);
ALTER TABLE wishlists ENABLE ROW LEVEL SECURITY;
CREATE POLICY wishlists_isolation ON wishlists USING (tenant_id = current_tenant());

CREATE TABLE wishlist_items (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES tenants(id),
  wishlist_id uuid NOT NULL REFERENCES wishlists(id) ON DELETE CASCADE,
  variant_id  uuid NOT NULL REFERENCES product_variants(id),
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (wishlist_id, variant_id)
);
ALTER TABLE wishlist_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY wishlist_items_isolation ON wishlist_items USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 9. CRO
-- ---------------------------------------------------------------------
CREATE TABLE cro_features (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code          text NOT NULL UNIQUE,
  name          text NOT NULL,
  config_schema jsonb NOT NULL,
  version       int NOT NULL DEFAULT 1,
  status        feature_status NOT NULL DEFAULT 'ga',
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE feature_configurations (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id  uuid NOT NULL REFERENCES tenants(id),
  feature_id uuid NOT NULL REFERENCES cro_features(id),
  enabled    boolean NOT NULL DEFAULT false,
  config     jsonb NOT NULL DEFAULT '{}'::jsonb,
  priority   int NOT NULL DEFAULT 100,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, feature_id)
);
CREATE INDEX feature_cfg_enabled_idx ON feature_configurations (tenant_id, enabled);
ALTER TABLE feature_configurations ENABLE ROW LEVEL SECURITY;
CREATE POLICY feature_cfg_isolation ON feature_configurations USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 10. SEGMENTATION
-- ---------------------------------------------------------------------
CREATE TABLE segments (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid NOT NULL REFERENCES tenants(id),
  name              text NOT NULL,
  rule              jsonb NOT NULL,
  status            text NOT NULL DEFAULT 'active',
  last_evaluated_at timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  deleted_at        timestamptz
);
ALTER TABLE segments ENABLE ROW LEVEL SECURITY;
CREATE POLICY segments_isolation ON segments USING (tenant_id = current_tenant());

CREATE TABLE segment_memberships (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id  uuid NOT NULL REFERENCES tenants(id),
  segment_id uuid NOT NULL REFERENCES segments(id) ON DELETE CASCADE,
  shopper_id uuid NOT NULL REFERENCES shopper_profiles(id) ON DELETE CASCADE,
  added_at   timestamptz NOT NULL DEFAULT now(),
  UNIQUE (segment_id, shopper_id)
);
CREATE INDEX seg_mem_shopper_idx ON segment_memberships (tenant_id, shopper_id);
ALTER TABLE segment_memberships ENABLE ROW LEVEL SECURITY;
CREATE POLICY seg_mem_isolation ON segment_memberships USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 11. CAMPAIGNS + NOTIFICATIONS
-- ---------------------------------------------------------------------
CREATE TABLE campaigns (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES tenants(id),
  name        text NOT NULL,
  type        text NOT NULL DEFAULT 'broadcast',   -- broadcast | triggered
  template    jsonb NOT NULL DEFAULT '{}'::jsonb,
  schedule_at timestamptz,
  status      campaign_status NOT NULL DEFAULT 'draft',
  goal        jsonb,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  deleted_at  timestamptz
);
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
CREATE POLICY campaigns_isolation ON campaigns USING (tenant_id = current_tenant());

CREATE TABLE campaign_segments (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES tenants(id),
  campaign_id uuid NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  segment_id  uuid NOT NULL REFERENCES segments(id),
  UNIQUE (campaign_id, segment_id)
);
ALTER TABLE campaign_segments ENABLE ROW LEVEL SECURITY;
CREATE POLICY campaign_segments_isolation ON campaign_segments USING (tenant_id = current_tenant());

CREATE TABLE notifications (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid NOT NULL REFERENCES tenants(id),
  campaign_id  uuid REFERENCES campaigns(id),   -- null for system-generated
  title        text NOT NULL,
  body         text NOT NULL,
  deep_link    text,
  image_url    text,
  status       notification_status NOT NULL DEFAULT 'draft',
  scheduled_at timestamptz,
  sent_at      timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX notifications_status_idx ON notifications (tenant_id, status);
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY notifications_isolation ON notifications USING (tenant_id = current_tenant());

-- Partitioned by month on sent_at (high fan-out volume)
CREATE TABLE notification_deliveries (
  id                  uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id           uuid NOT NULL REFERENCES tenants(id),
  notification_id     uuid NOT NULL,
  installation_id     uuid NOT NULL,
  push_token_id       uuid,
  provider            push_provider NOT NULL,
  status              delivery_status NOT NULL DEFAULT 'queued',
  provider_message_id text,
  failed_reason       text,
  sent_at             timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (id, sent_at)
) PARTITION BY RANGE (sent_at);
CREATE INDEX nd_notification_idx ON notification_deliveries (tenant_id, notification_id);
CREATE INDEX nd_installation_idx ON notification_deliveries (installation_id);
CREATE INDEX nd_status_idx       ON notification_deliveries (status);
ALTER TABLE notification_deliveries ENABLE ROW LEVEL SECURITY;
CREATE POLICY nd_isolation ON notification_deliveries USING (tenant_id = current_tenant());

CREATE TABLE notification_opens (
  id                 uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id          uuid NOT NULL REFERENCES tenants(id),
  delivery_id        uuid NOT NULL,
  opened_at          timestamptz NOT NULL DEFAULT now(),
  resulted_conversion boolean NOT NULL DEFAULT false,
  PRIMARY KEY (id, opened_at)
) PARTITION BY RANGE (opened_at);
CREATE INDEX no_delivery_idx ON notification_opens (tenant_id, delivery_id);
ALTER TABLE notification_opens ENABLE ROW LEVEL SECURITY;
CREATE POLICY no_isolation ON notification_opens USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 12. ATTRIBUTION + REVENUE
-- ---------------------------------------------------------------------
-- Partitioned touchpoints (look-back source)
CREATE TABLE attribution_touchpoints (
  id          uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES tenants(id),
  shopper_id  uuid NOT NULL,
  type        touchpoint_type NOT NULL,
  ref_id      uuid,                      -- session/delivery/campaign/cro id
  occurred_at timestamptz NOT NULL,
  is_direct   boolean NOT NULL DEFAULT false,
  PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);
CREATE INDEX at_shopper_time_idx ON attribution_touchpoints (tenant_id, shopper_id, occurred_at);
CREATE INDEX at_type_ref_idx     ON attribution_touchpoints (type, ref_id);
ALTER TABLE attribution_touchpoints ENABLE ROW LEVEL SECURITY;
CREATE POLICY at_isolation ON attribution_touchpoints USING (tenant_id = current_tenant());

CREATE TABLE attribution_conversions (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id             uuid NOT NULL REFERENCES tenants(id),
  order_id              uuid NOT NULL REFERENCES orders(id),
  winning_touchpoint_id uuid,           -- FK to partitioned touchpoints (app-enforced)
  model                 attribution_model NOT NULL DEFAULT 'last_non_direct',
  window_days           int NOT NULL DEFAULT 7,
  attributed_channel    order_channel NOT NULL,
  computed_at           timestamptz NOT NULL DEFAULT now(),
  recompute_reason      text,
  UNIQUE (order_id)
);
CREATE INDEX ac_recompute_idx ON attribution_conversions (tenant_id, computed_at);
ALTER TABLE attribution_conversions ENABLE ROW LEVEL SECURITY;
CREATE POLICY ac_isolation ON attribution_conversions USING (tenant_id = current_tenant());

-- Partitioned signed revenue events
CREATE TABLE revenue_events (
  id                 uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id          uuid NOT NULL REFERENCES tenants(id),
  order_id           uuid NOT NULL REFERENCES orders(id),
  type               revenue_event_type NOT NULL,
  amount_cents       int NOT NULL,          -- signed; refunds/cancellations negative
  currency           text NOT NULL,
  attributed_channel order_channel NOT NULL DEFAULT 'unknown',
  occurred_at        timestamptz NOT NULL,
  PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);
CREATE INDEX re_time_idx    ON revenue_events (tenant_id, occurred_at);
CREATE INDEX re_order_idx   ON revenue_events (order_id);
CREATE INDEX re_channel_idx ON revenue_events (tenant_id, attributed_channel, occurred_at);
ALTER TABLE revenue_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY re_isolation ON revenue_events USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 13. EVENT STORE (partitioned, idempotent)
-- ---------------------------------------------------------------------
CREATE TABLE events (
  id              uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants(id),
  event_id        uuid NOT NULL,               -- client idempotency key
  type            text NOT NULL,
  shopper_id      uuid,
  installation_id uuid,
  session_id      uuid,
  properties      jsonb NOT NULL DEFAULT '{}'::jsonb,
  occurred_at     timestamptz NOT NULL,
  received_at     timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (id, occurred_at),
  UNIQUE (tenant_id, event_id, occurred_at)     -- BR-EVENT-01
) PARTITION BY RANGE (occurred_at);
CREATE INDEX events_type_time_idx  ON events (tenant_id, type, occurred_at);
CREATE INDEX events_shopper_idx    ON events (shopper_id, occurred_at);
CREATE INDEX events_session_idx    ON events (session_id);
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
CREATE POLICY events_isolation ON events USING (tenant_id = current_tenant());

-- ---------------------------------------------------------------------
-- 14. PLATFORM PLUMBING
-- ---------------------------------------------------------------------
CREATE TABLE webhook_events (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid,                      -- nullable until resolved
  platform          platform_type NOT NULL,
  external_event_id text NOT NULL,
  signature_valid   boolean NOT NULL DEFAULT false,
  raw               jsonb NOT NULL,
  status            webhook_status NOT NULL DEFAULT 'received',
  received_at       timestamptz NOT NULL DEFAULT now(),
  UNIQUE (platform, external_event_id)         -- dedup
);
CREATE INDEX webhook_status_idx ON webhook_events (status, received_at);

CREATE TABLE sync_jobs (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES tenants(id),
  store_id    uuid NOT NULL REFERENCES stores(id),
  kind        sync_kind NOT NULL,
  status      sync_status NOT NULL DEFAULT 'pending',
  watermark   text,
  attempts    int NOT NULL DEFAULT 0,
  last_error  text,
  started_at  timestamptz,
  finished_at timestamptz,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX sync_jobs_ctrl_idx ON sync_jobs (tenant_id, store_id, kind, status);
CREATE INDEX sync_jobs_mon_idx  ON sync_jobs (status, started_at);
ALTER TABLE sync_jobs ENABLE ROW LEVEL SECURITY;
CREATE POLICY sync_jobs_isolation ON sync_jobs USING (tenant_id = current_tenant());

-- Append-only audit, partitioned by month
CREATE TABLE audit_logs (
  id             uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id      uuid,                          -- nullable for internal-global actions
  actor_type     text NOT NULL,
  actor_id       uuid,
  action         text NOT NULL,
  target_type    text,
  target_id      uuid,
  before         jsonb,
  after          jsonb,
  ip             inet,
  reason         text,
  correlation_id uuid,
  created_at     timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);
CREATE INDEX audit_tenant_time_idx ON audit_logs (tenant_id, created_at);
CREATE INDEX audit_corr_idx        ON audit_logs (correlation_id);

CREATE TABLE feature_flags (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key         text NOT NULL UNIQUE,
  scope       flag_scope NOT NULL DEFAULT 'global',
  tenant_id   uuid REFERENCES tenants(id),
  enabled     boolean NOT NULL DEFAULT false,
  rollout_pct int NOT NULL DEFAULT 0 CHECK (rollout_pct BETWEEN 0 AND 100),
  ttl_at      timestamptz,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- 15. INITIAL PARTITIONS (example — a scheduled job maintains a rolling window)
-- ---------------------------------------------------------------------
-- Example for events (repeat pattern per partitioned table + month):
CREATE TABLE events_2026_09 PARTITION OF events
  FOR VALUES FROM ('2026-09-01') TO ('2026-10-01');
CREATE TABLE events_2026_10 PARTITION OF events
  FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');
-- A partition-maintenance job (pg_partman or equivalent) must pre-create
-- the next N months for: events, revenue_events, notification_deliveries,
-- notification_opens, attribution_touchpoints, audit_logs. See SRS §23.

-- =====================================================================
-- End of schema.sql (V1.0 Core Foundation). TO VERIFY items per SRS §33
-- (platform auth/webhook/linkage specifics) do not affect this schema;
-- they affect connector behavior, not table shape.
-- =====================================================================
