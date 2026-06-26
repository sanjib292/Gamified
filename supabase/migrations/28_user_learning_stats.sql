-- =============================================================================
-- 28_user_learning_stats.sql
-- Rolling daily / weekly learning statistics per user (reset by cron)
-- =============================================================================

CREATE TABLE IF NOT EXISTS IF NOT EXISTS user_learning_stats (
    user_id                 UUID        PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    lessons_today           SMALLINT    NOT NULL DEFAULT 0,
    lessons_this_week       SMALLINT    NOT NULL DEFAULT 0,
    time_today_seconds      INT         NOT NULL DEFAULT 0,
    time_this_week_seconds  INT         NOT NULL DEFAULT 0,
    current_daily_goal_pct  SMALLINT    NOT NULL DEFAULT 0,
    last_daily_reset_at     DATE        NOT NULL DEFAULT CURRENT_DATE,
    last_weekly_reset_at    DATE        NOT NULL DEFAULT date_trunc('week', CURRENT_DATE)::DATE,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uls_lessons_today_non_neg          CHECK (lessons_today >= 0),
    CONSTRAINT uls_lessons_week_non_neg           CHECK (lessons_this_week >= 0),
    CONSTRAINT uls_time_today_non_neg             CHECK (time_today_seconds >= 0),
    CONSTRAINT uls_time_week_non_neg              CHECK (time_this_week_seconds >= 0),
    CONSTRAINT uls_daily_goal_pct_range           CHECK (current_daily_goal_pct BETWEEN 0 AND 100),
    -- Weekly totals must be >= daily totals (daily is a subset of weekly)
    CONSTRAINT uls_lessons_week_gte_today         CHECK (lessons_this_week >= lessons_today),
    CONSTRAINT uls_time_week_gte_today            CHECK (time_this_week_seconds >= time_today_seconds)
);

-- No secondary indexes needed — access is always by primary key.
-- If aggregation queries are needed (e.g. total active learners today),
-- add a partial index on lessons_today > 0.

COMMENT ON TABLE  user_learning_stats                       IS 'Rolling daily and weekly counters per user, reset by scheduled jobs.';
COMMENT ON COLUMN user_learning_stats.lessons_today         IS 'Lessons completed since last_daily_reset_at.';
COMMENT ON COLUMN user_learning_stats.lessons_this_week     IS 'Lessons completed since last_weekly_reset_at.';
COMMENT ON COLUMN user_learning_stats.time_today_seconds    IS 'Active learning seconds accumulated today.';
COMMENT ON COLUMN user_learning_stats.time_this_week_seconds IS 'Active learning seconds accumulated this week.';
COMMENT ON COLUMN user_learning_stats.current_daily_goal_pct IS 'Progress toward the user''s daily lesson goal (0–100).';
COMMENT ON COLUMN user_learning_stats.last_daily_reset_at   IS 'Date of the last daily counter reset; cron compares to CURRENT_DATE.';
COMMENT ON COLUMN user_learning_stats.last_weekly_reset_at  IS 'Date of the last weekly counter reset; cron compares to date_trunc(''week'', CURRENT_DATE).';
