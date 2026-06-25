-- ============================================================
-- MindQuest: Simulations
-- ============================================================

-- A simulation is an interactive scenario attached to a lesson.
-- The engine stores its state machine in JSONB columns so the
-- front-end can render any decision-tree or step-by-step scenario
-- without schema changes.

CREATE TABLE simulations (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id       UUID        NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title           TEXT        NOT NULL,
    description     TEXT,
    -- Starting state of the simulation (variables, scene, inventory, etc.)
    initial_state   JSONB       NOT NULL,
    -- Conditions that must be satisfied for the user to "win"
    -- e.g. {"type":"all_of","conditions":[{"var":"budget_saved","gte":1000}]}
    win_condition   JSONB       NOT NULL,
    max_steps       SMALLINT    NOT NULL DEFAULT 10,
    xp_reward       SMALLINT    NOT NULL DEFAULT 50,
    -- Ordered list of step definitions: [{"id":"s1","prompt":"...","choices":[...]}]
    steps           JSONB       NOT NULL DEFAULT '[]',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_simulations_max_steps CHECK (max_steps > 0),
    CONSTRAINT chk_simulations_win_condition_not_empty CHECK (win_condition <> '{}'::jsonb),
    CONSTRAINT chk_simulations_initial_state_not_empty CHECK (initial_state <> '{}'::jsonb)
);

CREATE TRIGGER trg_simulations_updated_at
    BEFORE UPDATE ON simulations
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX idx_simulations_lesson_id      ON simulations (lesson_id);
CREATE INDEX idx_simulations_steps_gin      ON simulations USING GIN (steps);
CREATE INDEX idx_simulations_win_cond_gin   ON simulations USING GIN (win_condition);
