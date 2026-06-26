-- ============================================================
-- MindQuest: User Progress
-- ============================================================

CREATE TABLE IF NOT EXISTS user_progress (
    id                  UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID          NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    lesson_id           UUID          NOT NULL REFERENCES lessons(id)  ON DELETE CASCADE,
    UNIQUE (user_id, lesson_id),
    status              lesson_status NOT NULL DEFAULT 'not_started',
    -- Score as a percentage (0–100) for the most recent attempt
    score_pct           SMALLINT,
    xp_earned           SMALLINT      NOT NULL DEFAULT 0,
    attempts_count      SMALLINT      NOT NULL DEFAULT 0,
    -- Best score ever achieved for this lesson
    best_score_pct      SMALLINT,
    -- Spaced-repetition state for flashcard-style recall
    -- e.g. {"ease_factor":2.5,"interval":1,"next_review":"2024-06-30T00:00:00Z"}
    srs_state           JSONB         NOT NULL DEFAULT '{}',
    started_at          TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    last_attempted_at   TIMESTAMPTZ,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),

    CONSTRAINT chk_user_progress_score_pct      CHECK (score_pct      IS NULL OR score_pct      BETWEEN 0 AND 100),
    CONSTRAINT chk_user_progress_best_score_pct CHECK (best_score_pct IS NULL OR best_score_pct BETWEEN 0 AND 100),
    CONSTRAINT chk_user_progress_xp_earned      CHECK (xp_earned >= 0),
    CONSTRAINT chk_user_progress_attempts       CHECK (attempts_count >= 0),
    -- completed_at only set when status is 'completed'
    CONSTRAINT chk_user_progress_completed_at   CHECK (
        status <> 'completed' OR completed_at IS NOT NULL
    )
);

DROP TRIGGER IF EXISTS trg_user_progress_updated_at ON user_progress;
CREATE TRIGGER trg_user_progress_updated_at
    BEFORE UPDATE ON user_progress
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_user_progress_user_id          ON user_progress (user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_lesson_id        ON user_progress (lesson_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_status           ON user_progress (user_id, status);
CREATE INDEX IF NOT EXISTS idx_user_progress_completed_at     ON user_progress (user_id, completed_at DESC) WHERE status = 'completed';
CREATE INDEX IF NOT EXISTS idx_user_progress_last_attempted   ON user_progress (user_id, last_attempted_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_progress_srs_gin          ON user_progress USING GIN (srs_state);
