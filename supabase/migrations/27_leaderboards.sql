-- =============================================================================
-- 27_leaderboards.sql
-- Periodic leaderboard snapshots (weekly, monthly, all_time)
-- Requires: period_type enum (01_extensions_and_enums.sql)
-- =============================================================================

CREATE TABLE IF NOT EXISTS IF NOT EXISTS leaderboards (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    period_type     period_type     NOT NULL,
    -- Human-readable period key:
    --   weekly     → '2025-W01'
    --   monthly    → '2025-01'
    --   all_time   → 'all_time'
    period_key      TEXT            NOT NULL,
    user_id         UUID            NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    display_name    TEXT            NOT NULL,
    avatar_url      TEXT,
    xp_earned       INT             NOT NULL DEFAULT 0,
    rank            INT,
    snapshot_at     TIMESTAMPTZ     NOT NULL DEFAULT now(),

    -- One row per user per (period_type, period_key) snapshot
    CONSTRAINT leaderboards_period_user_unique UNIQUE (period_type, period_key, user_id),

    CONSTRAINT leaderboards_xp_non_negative      CHECK (xp_earned >= 0),
    CONSTRAINT leaderboards_rank_positive         CHECK (rank IS NULL OR rank > 0),
    CONSTRAINT leaderboards_display_name_not_empty CHECK (char_length(trim(display_name)) > 0),
    CONSTRAINT leaderboards_period_key_not_empty   CHECK (char_length(trim(period_key)) > 0)
);

-- Primary leaderboard read query: ranked list for a given period
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_leaderboards_period_rank
    ON leaderboards (period_type, period_key, rank ASC NULLS LAST);

-- Per-user history: "what was my rank in past periods?"
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_leaderboards_user_period
    ON leaderboards (user_id, period_type, snapshot_at DESC);

COMMENT ON TABLE  leaderboards              IS 'Point-in-time leaderboard snapshots computed by refresh_leaderboard_snapshot().';
COMMENT ON COLUMN leaderboards.period_type  IS 'Granularity enum: weekly | monthly | all_time.';
COMMENT ON COLUMN leaderboards.period_key   IS 'String key identifying the period, e.g. 2025-W01 (weekly), 2025-01 (monthly), all_time.';
COMMENT ON COLUMN leaderboards.display_name IS 'Denormalised display name at snapshot time (user may rename later).';
COMMENT ON COLUMN leaderboards.avatar_url   IS 'Denormalised avatar URL at snapshot time.';
COMMENT ON COLUMN leaderboards.xp_earned    IS 'XP earned within this period (not cumulative lifetime XP for weekly/monthly).';
COMMENT ON COLUMN leaderboards.rank         IS 'Rank within (period_type, period_key); 1 = top. NULL until refresh runs.';
COMMENT ON COLUMN leaderboards.snapshot_at  IS 'When the snapshot was last computed for this row.';
