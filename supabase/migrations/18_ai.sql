-- =============================================================================
-- 18_ai.sql
-- AI conversation threads and message history with vector embeddings
-- Requires: pgvector extension (01_extensions_and_enums.sql)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ai_conversations
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ai_conversations (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    lesson_id       UUID        REFERENCES lessons(id) ON DELETE SET NULL,
    book_id         UUID        REFERENCES books(id) ON DELETE SET NULL,
    title           TEXT        NOT NULL,
    message_count   INT         NOT NULL DEFAULT 0,
    last_message_at TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ai_conversations_message_count_non_neg CHECK (message_count >= 0),
    CONSTRAINT ai_conversations_title_not_empty       CHECK (char_length(trim(title)) > 0)
);

CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_id
    ON ai_conversations (user_id);

CREATE INDEX IF NOT EXISTS idx_ai_conversations_lesson_id
    ON ai_conversations (lesson_id)
    WHERE lesson_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_ai_conversations_book_id
    ON ai_conversations (book_id)
    WHERE book_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_ai_conversations_last_message_at
    ON ai_conversations (user_id, last_message_at DESC NULLS LAST);

COMMENT ON TABLE  ai_conversations                  IS 'AI chat sessions optionally scoped to a lesson or book.';
COMMENT ON COLUMN ai_conversations.lesson_id        IS 'Optional lesson context for this conversation.';
COMMENT ON COLUMN ai_conversations.book_id          IS 'Optional book context for this conversation.';
COMMENT ON COLUMN ai_conversations.message_count    IS 'Denormalised count maintained by trigger increment_ai_message_count.';
COMMENT ON COLUMN ai_conversations.last_message_at  IS 'Timestamp of the most recent message; maintained by trigger.';

-- -----------------------------------------------------------------------------
-- ai_messages
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ai_messages (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID        NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
    role            TEXT        NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content         TEXT        NOT NULL,
    embedding       vector(1536),
    intent          TEXT,
    tokens_used     INT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ai_messages_content_not_empty   CHECK (char_length(trim(content)) > 0),
    CONSTRAINT ai_messages_tokens_non_negative CHECK (tokens_used IS NULL OR tokens_used >= 0)
);

-- Covering index for conversation message list (most common query pattern)
CREATE INDEX IF NOT EXISTS idx_ai_messages_conversation_created
    ON ai_messages (conversation_id, created_at DESC);

-- Partial index for filtering by role
CREATE INDEX IF NOT EXISTS idx_ai_messages_role
    ON ai_messages (role, created_at DESC);

-- IVFFlat approximate nearest-neighbour index for semantic search over message embeddings.
-- lists=100 is appropriate for tables expected to grow into the hundreds of thousands of rows.
-- Re-run ANALYZE after bulk inserts for optimal probe count.
CREATE INDEX IF NOT EXISTS idx_ai_messages_embedding_ivfflat
    ON ai_messages
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

COMMENT ON TABLE  ai_messages           IS 'Individual turns within an ai_conversations thread.';
COMMENT ON COLUMN ai_messages.role      IS 'OpenAI-compatible role: user | assistant | system.';
COMMENT ON COLUMN ai_messages.embedding IS '1536-dim OpenAI text-embedding-3-small vector for semantic retrieval.';
COMMENT ON COLUMN ai_messages.intent    IS 'Classified intent label, e.g. "explain_concept", "quiz_me".';
COMMENT ON COLUMN ai_messages.tokens_used IS 'Total tokens consumed by this turn (prompt + completion).';
