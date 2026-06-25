-- ============================================================
-- MindQuest: Badges & User Badges
-- ============================================================

-- Badges are collectible display items (shown on profile).
-- They differ from achievements in that they are purely cosmetic
-- and can be toggled on/off by the user.

CREATE TABLE badges (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    slug        TEXT        UNIQUE NOT NULL,
    title       TEXT        NOT NULL,
    description TEXT,
    icon_url    TEXT,
    color_hex   CHAR(7)     NOT NULL DEFAULT '#6C5CE7',
    -- Tier 1 = common, 2 = rare, 3 = epic, 4 = legendary
    tier        SMALLINT    NOT NULL DEFAULT 1,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_badges_tier CHECK (tier BETWEEN 1 AND 4)
);

CREATE INDEX idx_badges_slug ON badges (slug);
CREATE INDEX idx_badges_tier ON badges (tier);

-- ============================================================
-- User Badges (join table)
-- ============================================================

CREATE TABLE user_badges (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    badge_id     UUID        NOT NULL REFERENCES badges(id)   ON DELETE CASCADE,
    UNIQUE (user_id, badge_id),
    earned_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- Whether the badge is shown on the user's public profile
    is_displayed BOOL        NOT NULL DEFAULT true
);

CREATE INDEX idx_user_badges_user_id    ON user_badges (user_id);
CREATE INDEX idx_user_badges_badge_id   ON user_badges (badge_id);
CREATE INDEX idx_user_badges_displayed  ON user_badges (user_id, is_displayed) WHERE is_displayed = true;
CREATE INDEX idx_user_badges_earned_at  ON user_badges (user_id, earned_at DESC);

-- ============================================================
-- Seed: starter badge set
-- ============================================================

INSERT INTO badges (slug, title, description, color_hex, tier) VALUES
    ('early_adopter',       'Early Adopter',        'Joined MindQuest in the founding cohort.',               '#F39C12', 3),
    ('first_lesson_badge',  'First Lesson',         'Completed a first lesson on the platform.',              '#27AE60', 1),
    ('streak_7_badge',      '7-Day Streak',         'Kept a 7-day learning streak.',                          '#E67E22', 2),
    ('streak_30_badge',     '30-Day Streak',        'Kept a 30-day learning streak.',                         '#C0392B', 3),
    ('book_finisher',       'Book Finisher',        'Finished an entire book on MindQuest.',                  '#8E44AD', 2),
    ('quiz_ace',            'Quiz Ace',             'Scored 100% on a quiz.',                                 '#2980B9', 2),
    ('speed_learner',       'Speed Learner',        'Completed a lesson in record time.',                     '#16A085', 2),
    ('night_owl',           'Night Owl',            'Studied after midnight.',                                 '#2C3E50', 1),
    ('social_butterfly',    'Social Butterfly',     'Shared progress with friends 5 times.',                  '#E74C3C', 2),
    ('legend',              'MindQuest Legend',     'Reached the highest level on the platform.',             '#FFD700', 4);
