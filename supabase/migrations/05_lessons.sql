-- ============================================================
-- MindQuest: Lessons
-- ============================================================

CREATE TABLE lessons (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    learning_path_id    UUID        NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
    -- Denormalized for fast queries without joining learning_paths
    book_id             UUID        NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    title               TEXT        NOT NULL,
    subtitle            TEXT,
    key_concepts        TEXT[]      NOT NULL DEFAULT '{}',
    summary             TEXT,
    sort_order          SMALLINT    NOT NULL DEFAULT 0,
    estimated_minutes   SMALLINT    NOT NULL DEFAULT 5,
    xp_reward           SMALLINT    NOT NULL DEFAULT 20,
    is_free_preview     BOOL        NOT NULL DEFAULT false,
    is_published        BOOL        NOT NULL DEFAULT false,
    thumbnail_url       TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_lessons_updated_at
    BEFORE UPDATE ON lessons
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX idx_lessons_learning_path_id ON lessons (learning_path_id);
CREATE INDEX idx_lessons_book_id          ON lessons (book_id);
CREATE INDEX idx_lessons_is_published     ON lessons (is_published);
CREATE INDEX idx_lessons_sort_order       ON lessons (learning_path_id, sort_order);
CREATE INDEX idx_lessons_xp_reward        ON lessons (xp_reward);

-- Full-text / trigram index on title for fuzzy search
CREATE INDEX idx_lessons_title_trgm       ON lessons USING GIN (title gin_trgm_ops);

-- GIN index on key_concepts array for containment queries
CREATE INDEX idx_lessons_key_concepts_gin ON lessons USING GIN (key_concepts);
