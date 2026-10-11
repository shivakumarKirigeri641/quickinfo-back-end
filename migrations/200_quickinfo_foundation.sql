-- 200_quickinfo_foundation.sql — QuickInfo platform, phase one.
--
-- QuickInfo shares this database with serverpe-back-end and the other ServerPe
-- products. Its migrations are numbered from 200 and every table it owns is
-- prefixed quickinfo_, so nothing here can collide with or alter another
-- product's tables.
--
-- The one shared table QuickInfo reads is contact_query_types (the contact-form
-- dropdown). It is referenced, never altered.

BEGIN;

/* Keeps updated_at honest on every UPDATE. */
CREATE OR REPLACE FUNCTION quickinfo_touch_updated_at() RETURNS trigger AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/* ══════════════════════════════════════════════════════════════ services */
-- The solutions QuickInfo offers, shown on the landing page and offered in
-- the contact form. channel says where the customer uses the solution.

CREATE TABLE IF NOT EXISTS quickinfo_services (
  id             serial      PRIMARY KEY,
  slug           text        NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  name           text        NOT NULL CHECK (char_length(name) BETWEEN 2 AND 80),
  channel        text        NOT NULL CHECK (channel IN ('whatsapp', 'web', 'whatsapp_web')),
  summary        text        NOT NULL,
  features       jsonb       NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(features) = 'array'),
  display_order  integer     NOT NULL DEFAULT 0,
  is_active      boolean     NOT NULL DEFAULT true,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

/* ═══════════════════════════════════════════════════════ legal documents */
-- One row per section. The public page lists active rows by display_order and
-- shows the latest updated_at as the policy's "last updated" date, so editing a
-- section moves that date automatically.

CREATE TABLE IF NOT EXISTS quickinfo_privacy_policy (
  id             serial      PRIMARY KEY,
  title          text        NOT NULL,
  description    text        NOT NULL,
  display_order  integer     NOT NULL DEFAULT 0,
  is_active      boolean     NOT NULL DEFAULT true,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS quickinfo_terms_conditions (
  id             serial      PRIMARY KEY,
  title          text        NOT NULL,
  description    text        NOT NULL,
  display_order  integer     NOT NULL DEFAULT 0,
  is_active      boolean     NOT NULL DEFAULT true,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

/* ═══════════════════════════════════════════════════════ contact queries */
-- Kept apart from serverpe's contact_queries so QuickInfo leads never mix
-- with ServerPe's. Records the moment the visitor accepted the policies and
-- whether they agreed to WhatsApp updates (consent under the DPDP Act).

CREATE TABLE IF NOT EXISTS quickinfo_contact_queries (
  id                  bigserial   PRIMARY KEY,
  user_name           varchar(100) NOT NULL,
  mobile_number       varchar(10)  NOT NULL CHECK (mobile_number ~ '^[6-9][0-9]{9}$'),
  email               varchar(254),
  business_name       varchar(120),
  query_type_id       bigint      NOT NULL REFERENCES contact_query_types (id),
  service_id          integer     REFERENCES quickinfo_services (id),
  message             text        NOT NULL CHECK (char_length(message) BETWEEN 10 AND 1000),
  whatsapp_opt_in     boolean     NOT NULL DEFAULT false,
  policy_accepted_at  timestamptz NOT NULL,
  is_resolved         boolean     NOT NULL DEFAULT false,
  ip_address          inet,
  user_agent          text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS quickinfo_contact_queries_created_idx
  ON quickinfo_contact_queries (created_at DESC);
CREATE INDEX IF NOT EXISTS quickinfo_contact_queries_mobile_idx
  ON quickinfo_contact_queries (mobile_number);

/* ══════════════════════════════════════════════════════════════ triggers */

DROP TRIGGER IF EXISTS quickinfo_services_touch ON quickinfo_services;
CREATE TRIGGER quickinfo_services_touch BEFORE UPDATE ON quickinfo_services
  FOR EACH ROW EXECUTE FUNCTION quickinfo_touch_updated_at();

DROP TRIGGER IF EXISTS quickinfo_privacy_policy_touch ON quickinfo_privacy_policy;
CREATE TRIGGER quickinfo_privacy_policy_touch BEFORE UPDATE ON quickinfo_privacy_policy
  FOR EACH ROW EXECUTE FUNCTION quickinfo_touch_updated_at();

DROP TRIGGER IF EXISTS quickinfo_terms_conditions_touch ON quickinfo_terms_conditions;
CREATE TRIGGER quickinfo_terms_conditions_touch BEFORE UPDATE ON quickinfo_terms_conditions
  FOR EACH ROW EXECUTE FUNCTION quickinfo_touch_updated_at();

DROP TRIGGER IF EXISTS quickinfo_contact_queries_touch ON quickinfo_contact_queries;
CREATE TRIGGER quickinfo_contact_queries_touch BEFORE UPDATE ON quickinfo_contact_queries
  FOR EACH ROW EXECUTE FUNCTION quickinfo_touch_updated_at();

COMMIT;
