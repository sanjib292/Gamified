-- ============================================================
-- MindQuest: User Profiles
-- ============================================================

-- Mirrors auth.users 1-to-1. Row is created via trigger or
-- application code immediately after a user signs up.

CREATE TABLE profiles (
    id                          UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email                       TEXT        UNIQUE NOT NULL,
    display_name                TEXT,
    avatar_url                  TEXT,
    bio                         TEXT,
    xp_total                    INT         NOT NULL DEFAULT 0,
    level                       SMALLINT    NOT NULL DEFAULT 1,
    level_title                 TEXT        NOT NULL DEFAULT 'Explorer',
    -- Concepts the user has struggled with (from quiz analysis)
    weak_concepts               TEXT[]      NOT NULL DEFAULT '{}',
    -- User-set learning goals, e.g. ["Read 2 books/month","Improve investing skills"]
    learning_goals              TEXT[]      NOT NULL DEFAULT '{}',
    daily_goal_minutes          SMALLINT    NOT NULL DEFAULT 15,
    timezone                    TEXT        NOT NULL DEFAULT 'UTC',
    is_onboarded                BOOL        NOT NULL DEFAULT false,
    -- Denormalized counters kept in sync by application / triggers
    books_completed             INT         NOT NULL DEFAULT 0,
    lessons_completed           INT         NOT NULL DEFAULT 0,
    total_study_time_minutes    INT         NOT NULL DEFAULT 0,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_profiles_xp_total           CHECK (xp_total >= 0),
    CONSTRAINT chk_profiles_level              CHECK (level >= 1),
    CONSTRAINT chk_profiles_daily_goal_minutes CHECK (daily_goal_minutes > 0)
);

CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================
-- Auto-create profile row when a new user signs up
-- ============================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    INSERT INTO public.profiles (id, email)
    VALUES (NEW.id, NEW.email)
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX idx_profiles_xp_total   ON profiles (xp_total DESC);
CREATE INDEX idx_profiles_level      ON profiles (level);
CREATE INDEX idx_profiles_created_at ON profiles (created_at DESC);
