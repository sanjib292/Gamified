-- ============================================================
-- MindQuest: Quizzes & Quiz Questions
-- ============================================================

CREATE TABLE quizzes (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id           UUID        NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title               TEXT        NOT NULL,
    description         TEXT,
    passing_score_pct   SMALLINT    NOT NULL DEFAULT 70,
    xp_reward           SMALLINT    NOT NULL DEFAULT 10,
    xp_perfect_reward   SMALLINT    NOT NULL DEFAULT 15,
    time_limit_seconds  SMALLINT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_quizzes_passing_score CHECK (passing_score_pct BETWEEN 1 AND 100),
    CONSTRAINT chk_quizzes_perfect_ge_base CHECK (xp_perfect_reward >= xp_reward)
);

CREATE TRIGGER trg_quizzes_updated_at
    BEFORE UPDATE ON quizzes
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE INDEX idx_quizzes_lesson_id ON quizzes (lesson_id);

-- ============================================================
-- Quiz Questions
-- ============================================================

CREATE TABLE quiz_questions (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id             UUID        NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    question_text       TEXT        NOT NULL,
    -- 'multiple_choice' | 'true_false' | 'multi_select' | 'fill_in_blank'
    question_type       TEXT        NOT NULL DEFAULT 'multiple_choice',
    -- Array of answer options: [{"id":"a","text":"...","image_url":"..."}, ...]
    options             JSONB       NOT NULL,
    -- IDs from the options array that are correct
    correct_option_ids  TEXT[]      NOT NULL,
    explanation         TEXT,
    hint                TEXT,
    sort_order          SMALLINT    NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_quiz_questions_options_not_empty   CHECK (jsonb_array_length(options) > 0),
    CONSTRAINT chk_quiz_questions_correct_not_empty   CHECK (array_length(correct_option_ids, 1) > 0),
    CONSTRAINT chk_quiz_questions_type CHECK (
        question_type IN ('multiple_choice', 'true_false', 'multi_select', 'fill_in_blank')
    )
);

CREATE INDEX idx_quiz_questions_quiz_id    ON quiz_questions (quiz_id);
CREATE INDEX idx_quiz_questions_sort_order ON quiz_questions (quiz_id, sort_order);
