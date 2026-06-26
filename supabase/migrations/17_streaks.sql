-- =============================================================================
-- 17_streaks.sql
-- User learning streaks tracking
-- =============================================================================

CREATE TABLE IF NOT EXISTS IF NOT EXISTS streaks (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID            NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    current_streak      INT             NOT NULL DEFAULT 0,
    longest_streak      INT             NOT NULL DEFAULT 0,
    last_activity_date  DATE,
    freeze_count        SMALLINT        NOT NULL DEFAULT 0,
    max_freezes         SMALLINT        NOT NULL DEFAULT 3,
    weekly_activity     JSONB           NOT NULL DEFAULT '{}',
    total_active_days   INT             NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT streaks_freeze_count_non_negative   CHECK (freeze_count >= 0),
    CONSTRAINT streaks_max_freezes_positive        CHECK (max_freezes > 0),
    CONSTRAINT streaks_freeze_within_max           CHECK (freeze_count <= max_freezes),
    CONSTRAINT streaks_current_streak_non_negative CHECK (current_streak >= 0),
    CONSTRAINT streaks_longest_streak_non_negative CHECK (longest_streak >= 0),
    CONSTRAINT streaks_longest_gte_current         CHECK (longest_streak >= current_streak),
    CONSTRAINT streaks_total_active_days_non_neg   CHECK (total_active_days >= 0)
);

-- Index for user lookup (covered by UNIQUE, kept explicit for clarity)
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_streaks_user_id
    ON streaks (user_id);

-- Index to support queries filtering/sorting by last activity date
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_streaks_last_activity_date
    ON streaks (last_activity_date);

COMMENT ON TABLE  streaks                       IS 'Tracks daily learning streak state per user.';
COMMENT ON COLUMN streaks.current_streak        IS 'Consecutive active days ending at last_activity_date.';
COMMENT ON COLUMN streaks.longest_streak        IS 'All-time record of consecutive active days.';
COMMENT ON COLUMN streaks.last_activity_date    IS 'The most recent calendar date the user completed a learning activity.';
COMMENT ON COLUMN streaks.freeze_count          IS 'Number of streak-freeze tokens the user has remaining.';
COMMENT ON COLUMN streaks.max_freezes           IS 'Maximum freeze tokens a user may accumulate.';
COMMENT ON COLUMN streaks.weekly_activity       IS 'Map of ISO date strings to activity counts for the current week, e.g. {"2025-01-06": 3}.';
COMMENT ON COLUMN streaks.total_active_days     IS 'Lifetime count of distinct active calendar days.';
