-- ============================================================
-- MindQuest: Story Missions
-- ============================================================

-- A story mission is a branching narrative attached to a lesson.
-- The full node graph is stored as JSONB for flexibility.
-- Node shape: {"id":"n1","type":"dialogue|choice|outcome",
--              "text":"...","choices":[{"label":"...","next_node_id":"n2"}]}

CREATE TABLE story_missions (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id           UUID        NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title               TEXT        NOT NULL,
    -- ID of the first node the player sees
    start_node_id       TEXT        NOT NULL,
    -- Complete node graph keyed by node ID
    -- e.g. {"n1":{"type":"dialogue","text":"...","next":"n2"}, ...}
    nodes               JSONB       NOT NULL,
    total_nodes         SMALLINT    NOT NULL DEFAULT 0,
    -- Length of the shortest winning path through the graph
    optimal_path_length SMALLINT    NOT NULL DEFAULT 0,
    xp_reward           SMALLINT    NOT NULL DEFAULT 30,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_story_missions_nodes_not_empty CHECK (nodes <> '{}'::jsonb),
    CONSTRAINT chk_story_missions_total_nodes     CHECK (total_nodes >= 0),
    CONSTRAINT chk_story_missions_optimal_path    CHECK (optimal_path_length >= 0)
);

CREATE TRIGGER trg_story_missions_updated_at
    BEFORE UPDATE ON story_missions
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX idx_story_missions_lesson_id  ON story_missions (lesson_id);
CREATE INDEX idx_story_missions_nodes_gin  ON story_missions USING GIN (nodes);
