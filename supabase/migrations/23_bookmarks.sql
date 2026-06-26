-- =============================================================================
-- 23_bookmarks.sql
-- User bookmarks for books and lessons
-- =============================================================================

CREATE TABLE IF NOT EXISTS IF NOT EXISTS bookmarks (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    target_type TEXT        NOT NULL CHECK (target_type IN ('book', 'lesson')),
    target_id   UUID        NOT NULL,
    notes       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- A user may bookmark the same item only once
    CONSTRAINT bookmarks_user_target_unique UNIQUE (user_id, target_type, target_id),

    CONSTRAINT bookmarks_notes_length CHECK (notes IS NULL OR char_length(notes) <= 2000)
);

-- Primary query: all bookmarks for a user, newest first
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_bookmarks_user_created
    ON bookmarks (user_id, created_at DESC);

-- Filter by content type within a user's bookmarks
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_bookmarks_user_type
    ON bookmarks (user_id, target_type, created_at DESC);

-- Reverse lookup: which users bookmarked a given item
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_bookmarks_target
    ON bookmarks (target_type, target_id);

COMMENT ON TABLE  bookmarks              IS 'User-saved bookmarks pointing to a book or lesson.';
COMMENT ON COLUMN bookmarks.target_type  IS 'Discriminator: book | lesson.';
COMMENT ON COLUMN bookmarks.target_id    IS 'UUID of the bookmarked row in the corresponding table.';
COMMENT ON COLUMN bookmarks.notes        IS 'Optional free-text note attached by the user to this bookmark.';
