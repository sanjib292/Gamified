-- ============================================================
-- MindQuest: Books
-- ============================================================

CREATE TABLE books (
    id                  UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
    title               TEXT             NOT NULL,
    subtitle            TEXT,
    author              TEXT,
    cover_url           TEXT,
    description         TEXT,
    total_lessons       SMALLINT         NOT NULL DEFAULT 0,
    estimated_minutes   SMALLINT,
    difficulty          difficulty_level NOT NULL DEFAULT 'beginner',
    is_published        BOOL             NOT NULL DEFAULT false,
    is_featured         BOOL             NOT NULL DEFAULT false,
    published_at        TIMESTAMPTZ,
    isbn                TEXT,
    tags                TEXT[]           NOT NULL DEFAULT '{}',
    meta                JSONB            NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ      NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ      NOT NULL DEFAULT now()
);

-- Automatically maintain updated_at
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_books_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================
-- book_categories junction table
-- ============================================================

CREATE TABLE book_categories (
    book_id     UUID NOT NULL REFERENCES books(id)      ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, category_id)
);

CREATE INDEX idx_book_categories_category ON book_categories (category_id);

-- ============================================================
-- Indexes on books
-- ============================================================

CREATE INDEX idx_books_difficulty    ON books (difficulty);
CREATE INDEX idx_books_is_published  ON books (is_published);
CREATE INDEX idx_books_is_featured   ON books (is_featured);
CREATE INDEX idx_books_tags_gin      ON books USING GIN (tags);
CREATE INDEX idx_books_meta_gin      ON books USING GIN (meta);
CREATE INDEX idx_books_published_at  ON books (published_at DESC) WHERE is_published = true;
