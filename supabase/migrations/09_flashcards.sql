-- ============================================================
-- MindQuest: Flashcard Decks & Flashcards
-- ============================================================

CREATE TABLE flashcard_decks (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id   UUID        NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title       TEXT        NOT NULL,
    -- 'standard' | 'spaced_repetition' | 'leitner'
    study_mode  TEXT        NOT NULL DEFAULT 'standard',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_flashcard_decks_study_mode CHECK (
        study_mode IN ('standard', 'spaced_repetition', 'leitner')
    )
);

CREATE TRIGGER trg_flashcard_decks_updated_at
    BEFORE UPDATE ON flashcard_decks
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE INDEX idx_flashcard_decks_lesson_id ON flashcard_decks (lesson_id);

-- ============================================================
-- Flashcards
-- ============================================================

CREATE TABLE flashcards (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    deck_id          UUID        NOT NULL REFERENCES flashcard_decks(id) ON DELETE CASCADE,
    front_text       TEXT        NOT NULL,
    front_image_url  TEXT,
    back_text        TEXT        NOT NULL,
    back_explanation TEXT,
    tags             TEXT[]      NOT NULL DEFAULT '{}',
    sort_order       SMALLINT    NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_flashcards_deck_id      ON flashcards (deck_id);
CREATE INDEX idx_flashcards_sort_order   ON flashcards (deck_id, sort_order);
CREATE INDEX idx_flashcards_tags_gin     ON flashcards USING GIN (tags);
