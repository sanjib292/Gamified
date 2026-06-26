-- =============================================================================
-- 24_lesson_attempts.sql
-- Append-only log of every lesson attempt (raw attempts, not best state)
-- Best / current progress state lives in user_progress.
-- =============================================================================

CREATE TABLE IF NOT EXISTS IF NOT EXISTS lesson_attempts (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    lesson_id        UUID        NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    score_pct        SMALLINT,
    xp_earned        SMALLINT    NOT NULL DEFAULT 0,
    duration_seconds INT         NOT NULL DEFAULT 0,
    answers          JSONB       NOT NULL DEFAULT '{}',
    completed        BOOLEAN     NOT NULL DEFAULT false,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- score_pct is 0–100 when present
    CONSTRAINT lesson_attempts_score_pct_range
        CHECK (score_pct IS NULL OR (score_pct BETWEEN 0 AND 100)),
    CONSTRAINT lesson_attempts_xp_non_negative
        CHECK (xp_earned >= 0),
    CONSTRAINT lesson_attempts_duration_non_negative
        CHECK (duration_seconds >= 0)

    -- NOTE: No updated_at — this table is append-only.
    -- Do not add UPDATE triggers or RLS UPDATE policies.
);

-- Per-user attempt history for a lesson (e.g. "show my previous attempts")
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_lesson_attempts_user_lesson_created
    ON lesson_attempts (user_id, lesson_id, created_at DESC);

-- Per-user full attempt history (e.g. "my recent activity")
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_lesson_attempts_user_created
    ON lesson_attempts (user_id, created_at DESC);

-- Analytics: attempts per lesson across all users
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_lesson_attempts_lesson_id
    ON lesson_attempts (lesson_id, created_at DESC);

-- Filter completed attempts only
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_lesson_attempts_completed
    ON lesson_attempts (user_id, completed, created_at DESC)
    WHERE completed = true;

COMMENT ON TABLE  lesson_attempts                  IS 'Append-only attempt log. Every time a user submits a lesson, one row is inserted. Best state is denormalised into user_progress.';
COMMENT ON COLUMN lesson_attempts.score_pct        IS 'Percentage score (0–100). NULL if the lesson has no scoring.';
COMMENT ON COLUMN lesson_attempts.xp_earned        IS 'XP awarded for this specific attempt.';
COMMENT ON COLUMN lesson_attempts.duration_seconds IS 'Active time the user spent on this attempt.';
COMMENT ON COLUMN lesson_attempts.answers          IS 'Snapshot of user answers, keyed by question_id.';
COMMENT ON COLUMN lesson_attempts.completed        IS 'True if the user reached the end of the lesson content.';
