-- ============================================================
-- MindQuest: Lesson Content
-- ============================================================

CREATE TABLE IF NOT EXISTS lesson_content (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    -- One content record per lesson (UNIQUE enforces 1:1)
    lesson_id    UUID         NOT NULL UNIQUE REFERENCES lessons(id) ON DELETE CASCADE,
    content_type content_type NOT NULL,
    content      JSONB        NOT NULL DEFAULT '{}',
    version      SMALLINT     NOT NULL DEFAULT 1,
    is_active    BOOL         NOT NULL DEFAULT true,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),

    -- Ensure content is never an empty JSON object
    CONSTRAINT chk_lesson_content_not_empty CHECK (content <> '{}'::jsonb)
);

DROP TRIGGER IF EXISTS trg_lesson_content_updated_at ON lesson_content;
CREATE TRIGGER trg_lesson_content_updated_at
    BEFORE UPDATE ON lesson_content
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_lesson_content_lesson_id    ON lesson_content (lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_content_type         ON lesson_content (content_type);
CREATE INDEX IF NOT EXISTS idx_lesson_content_is_active    ON lesson_content (is_active);
CREATE INDEX IF NOT EXISTS idx_lesson_content_content_gin  ON lesson_content USING GIN (content);
