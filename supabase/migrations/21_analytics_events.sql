-- =============================================================================
-- 21_analytics_events.sql
-- Append-only analytics event log (client and server events)
--
-- Design notes:
--   • This table is intentionally append-only. There is no UPDATE/DELETE path
--     exposed via RLS. Historical data is immutable.
--   • user_id is nullable to support anonymous/pre-auth events.
--   • FUTURE: Partition by created_at (DATE range partitioning) once daily
--     row volume justifies it. Suggested partition key:
--         PARTITION BY RANGE (created_at)
--     with monthly or weekly child tables managed by pg_partman or a cron job.
--     The current unpartitioned layout is compatible with a zero-downtime
--     migration to partitioned tables via pg_partman attach/detach.
-- =============================================================================

CREATE TABLE IF NOT EXISTS IF NOT EXISTS analytics_events (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Nullable: anonymous events are captured before the user authenticates
    user_id     UUID        REFERENCES profiles(id) ON DELETE SET NULL,
    event_name  TEXT        NOT NULL,
    properties  JSONB       NOT NULL DEFAULT '{}',
    session_id  TEXT,
    platform    TEXT,
    app_version TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT analytics_events_event_name_not_empty CHECK (char_length(trim(event_name)) > 0)
);

-- Index for filtering events by name (e.g. funnel queries)
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_analytics_events_event_name
    ON analytics_events (event_name, created_at DESC);

-- Index for per-user event history
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_analytics_events_user_id
    ON analytics_events (user_id, created_at DESC)
    WHERE user_id IS NOT NULL;

-- Chronological scan index (used by time-range dashboards)
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_analytics_events_created_at
    ON analytics_events (created_at DESC);

-- GIN index for arbitrary property filtering (e.g. properties->>'source' = 'onboarding')
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_analytics_events_properties_gin
    ON analytics_events USING gin (properties);

COMMENT ON TABLE  analytics_events              IS 'Append-only structured event log. Never update or delete rows.';
COMMENT ON COLUMN analytics_events.user_id      IS 'NULL for anonymous events captured before authentication.';
COMMENT ON COLUMN analytics_events.event_name   IS 'Snake_case event identifier, e.g. lesson_started, quiz_completed.';
COMMENT ON COLUMN analytics_events.properties   IS 'Freeform event payload; schema is event-type-specific.';
COMMENT ON COLUMN analytics_events.session_id   IS 'Client-generated session UUID for grouping events within a session.';
COMMENT ON COLUMN analytics_events.platform     IS 'Client platform: ios | android | web.';
COMMENT ON COLUMN analytics_events.app_version  IS 'Semantic version string of the client app, e.g. 1.4.2.';

-- =============================================================================
-- FUTURE PARTITIONING HINT
-- =============================================================================
-- When monthly row count exceeds ~10M, convert to range-partitioned table:
--
--   ALTER TABLE analytics_events RENAME TO analytics_events_legacy;
--
--   CREATE TABLE analytics_events (
--       LIKE analytics_events_legacy INCLUDING ALL
--   ) PARTITION BY RANGE (created_at);
--
--   -- Attach existing data as the first partition
--   CREATE TABLE analytics_events_pre_partition
--       PARTITION OF analytics_events
--       FOR VALUES FROM (MINVALUE) TO ('2025-01-01');
--
--   -- Then create monthly partitions going forward via pg_partman:
--   SELECT partman.create_parent('public.analytics_events', 'created_at', 'native', 'monthly');
-- =============================================================================
