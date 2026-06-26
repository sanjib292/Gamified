-- =============================================================================
-- 19_embeddings.sql
-- Centralised content embeddings store for semantic search
-- Requires: pgvector extension (01_extensions_and_enums.sql)
-- =============================================================================

CREATE TABLE IF NOT EXISTS embeddings (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    source_type     TEXT        NOT NULL CHECK (source_type IN ('book', 'lesson', 'lesson_content')),
    source_id       UUID        NOT NULL,
    content_text    TEXT        NOT NULL,
    embedding       vector(1536) NOT NULL,
    model           TEXT        NOT NULL DEFAULT 'text-embedding-3-small',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- One embedding row per (source_type, source_id) pair
    CONSTRAINT embeddings_source_unique UNIQUE (source_type, source_id),

    CONSTRAINT embeddings_content_not_empty CHECK (char_length(trim(content_text)) > 0),
    CONSTRAINT embeddings_model_not_empty   CHECK (char_length(trim(model)) > 0)
);

-- Index to look up embedding by source
CREATE INDEX IF NOT EXISTS idx_embeddings_source
    ON embeddings (source_type, source_id);

-- Partial indexes per source_type to speed up type-scoped semantic queries
CREATE INDEX IF NOT EXISTS idx_embeddings_source_type_book
    ON embeddings (source_id)
    WHERE source_type = 'book';

CREATE INDEX IF NOT EXISTS idx_embeddings_source_type_lesson
    ON embeddings (source_id)
    WHERE source_type = 'lesson';

CREATE INDEX IF NOT EXISTS idx_embeddings_source_type_lesson_content
    ON embeddings (source_id)
    WHERE source_type = 'lesson_content';

-- IVFFlat approximate nearest-neighbour index for cosine similarity search.
-- lists=100 suitable for up to ~1 million rows; scale to lists=200+ beyond that.
-- Rebuild index periodically after large batch ingestion for best recall.
CREATE INDEX IF NOT EXISTS idx_embeddings_embedding_ivfflat
    ON embeddings
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

COMMENT ON TABLE  embeddings              IS 'Pre-computed content embeddings for books, lessons, and lesson_content rows.';
COMMENT ON COLUMN embeddings.source_type  IS 'Discriminator: book | lesson | lesson_content.';
COMMENT ON COLUMN embeddings.source_id    IS 'UUID of the referenced row in the corresponding table.';
COMMENT ON COLUMN embeddings.content_text IS 'The text that was embedded (used for re-embedding detection and display).';
COMMENT ON COLUMN embeddings.embedding    IS '1536-dim vector produced by the configured embedding model.';
COMMENT ON COLUMN embeddings.model        IS 'Name of the OpenAI embedding model used, e.g. text-embedding-3-small.';
