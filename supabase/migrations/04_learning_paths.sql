-- ============================================================
-- MindQuest: Learning Paths
-- ============================================================

CREATE TABLE IF NOT EXISTS learning_paths (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id             UUID        NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    title               TEXT        NOT NULL,
    description         TEXT,
    sort_order          SMALLINT    NOT NULL DEFAULT 0,
    estimated_minutes   SMALLINT,
    is_premium          BOOL        NOT NULL DEFAULT false,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_learning_paths_updated_at ON learning_paths;
CREATE TRIGGER trg_learning_paths_updated_at
    BEFORE UPDATE ON learning_paths
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_learning_paths_book_id    ON learning_paths (book_id);
CREATE INDEX IF NOT EXISTS idx_learning_paths_sort_order ON learning_paths (book_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_learning_paths_is_premium ON learning_paths (is_premium);
