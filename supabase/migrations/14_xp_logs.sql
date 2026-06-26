-- ============================================================
-- MindQuest: XP Logs  (append-only ledger — no UPDATE / DELETE)
-- ============================================================

CREATE TABLE IF NOT EXISTS xp_logs (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    amount      SMALLINT    NOT NULL,
    -- Source category: 'lesson_complete' | 'quiz_perfect' | 'streak_bonus'
    --                  | 'achievement' | 'challenge' | 'badge' | 'referral'
    source      TEXT        NOT NULL,
    -- Optional reference to the originating record (lesson, quiz, achievement…)
    source_id   UUID,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_xp_logs_amount_nonzero CHECK (amount <> 0)
);

-- ============================================================
-- Deny UPDATE and DELETE to preserve the ledger integrity
-- ============================================================

CREATE OR REPLACE FUNCTION deny_xp_logs_mutation()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'xp_logs is append-only — UPDATE and DELETE are not permitted.';
END;
$$;

DROP TRIGGER IF EXISTS trg_xp_logs_no_update ON xp_logs;
CREATE TRIGGER trg_xp_logs_no_update
    BEFORE UPDATE ON xp_logs
    FOR EACH ROW EXECUTE FUNCTION deny_xp_logs_mutation();

DROP TRIGGER IF EXISTS trg_xp_logs_no_delete ON xp_logs;
CREATE TRIGGER trg_xp_logs_no_delete
    BEFORE DELETE ON xp_logs
    FOR EACH ROW EXECUTE FUNCTION deny_xp_logs_mutation();

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_xp_logs_user_id    ON xp_logs (user_id);
CREATE INDEX IF NOT EXISTS idx_xp_logs_created_at ON xp_logs (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_xp_logs_source     ON xp_logs (source);
CREATE INDEX IF NOT EXISTS idx_xp_logs_source_id  ON xp_logs (source_id) WHERE source_id IS NOT NULL;
