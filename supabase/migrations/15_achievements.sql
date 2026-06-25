-- ============================================================
-- MindQuest: Achievements & User Achievements
-- ============================================================

CREATE TABLE achievements (
    id               UUID                  PRIMARY KEY DEFAULT gen_random_uuid(),
    slug             TEXT                  UNIQUE NOT NULL,
    title            TEXT                  NOT NULL,
    description      TEXT                  NOT NULL,
    category         achievement_category  NOT NULL DEFAULT 'learning',
    icon_url         TEXT,
    badge_color      TEXT                  NOT NULL DEFAULT '#6C5CE7',
    xp_reward        SMALLINT              NOT NULL DEFAULT 50,
    -- Type of condition to evaluate, e.g. 'lessons_completed', 'streak_days',
    -- 'books_completed', 'xp_total', 'quiz_perfect_count', 'social_shares'
    condition_type   TEXT                  NOT NULL,
    -- Structured condition parameters, e.g. {"count":10} or {"streak":7}
    condition_value  JSONB                 NOT NULL,
    -- Secret achievements are not shown until unlocked
    is_secret        BOOL                  NOT NULL DEFAULT false,
    sort_order       INT                   NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ           NOT NULL DEFAULT now(),

    CONSTRAINT chk_achievements_xp_reward          CHECK (xp_reward >= 0),
    CONSTRAINT chk_achievements_condition_not_empty CHECK (condition_value <> '{}'::jsonb)
);

CREATE INDEX idx_achievements_slug     ON achievements (slug);
CREATE INDEX idx_achievements_category ON achievements (category);
CREATE INDEX idx_achievements_sort     ON achievements (sort_order);
CREATE INDEX idx_achievements_cond_gin ON achievements USING GIN (condition_value);

-- ============================================================
-- User Achievements (join table)
-- ============================================================

CREATE TABLE user_achievements (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID        NOT NULL REFERENCES profiles(id)     ON DELETE CASCADE,
    achievement_id UUID        NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    UNIQUE (user_id, achievement_id),
    earned_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_achievements_user_id        ON user_achievements (user_id);
CREATE INDEX idx_user_achievements_achievement_id ON user_achievements (achievement_id);
CREATE INDEX idx_user_achievements_earned_at      ON user_achievements (user_id, earned_at DESC);

-- ============================================================
-- Seed: common achievements
-- ============================================================

INSERT INTO achievements (slug, title, description, category, badge_color, xp_reward, condition_type, condition_value, sort_order) VALUES
    ('first_lesson',       'First Step',          'Complete your very first lesson.',               'learning',    '#27AE60',  50,  'lessons_completed',  '{"count": 1}',    1),
    ('ten_lessons',        'On A Roll',           'Complete 10 lessons.',                           'learning',    '#2980B9',  100, 'lessons_completed',  '{"count": 10}',   2),
    ('fifty_lessons',      'Knowledge Seeker',    'Complete 50 lessons.',                           'learning',    '#8E44AD',  250, 'lessons_completed',  '{"count": 50}',   3),
    ('first_book',         'Book Worm',           'Finish your first complete book.',               'mastery',     '#E67E22',  150, 'books_completed',    '{"count": 1}',    4),
    ('five_books',         'Avid Reader',         'Finish 5 complete books.',                       'mastery',     '#C0392B',  500, 'books_completed',    '{"count": 5}',    5),
    ('streak_7',           'Week Warrior',        'Maintain a 7-day learning streak.',             'streak',      '#F39C12',  100, 'streak_days',         '{"days": 7}',     6),
    ('streak_30',          'Month Master',        'Maintain a 30-day learning streak.',            'streak',      '#E74C3C',  300, 'streak_days',         '{"days": 30}',    7),
    ('perfect_quiz',       'Perfectionist',       'Score 100% on any quiz.',                       'mastery',     '#16A085',   75, 'quiz_perfect_count', '{"count": 1}',    8),
    ('ten_perfect_quizzes','Quiz Champion',       'Score 100% on 10 different quizzes.',           'mastery',     '#6C5CE7',  200, 'quiz_perfect_count', '{"count": 10}',   9),
    ('xp_1000',            'XP Hunter',           'Earn a total of 1,000 XP.',                     'learning',    '#2ECC71',   50, 'xp_total',           '{"amount": 1000}',10);
