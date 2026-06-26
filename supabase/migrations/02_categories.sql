-- ============================================================
-- MindQuest: Categories
-- ============================================================

CREATE TABLE IF NOT EXISTS categories (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT        UNIQUE NOT NULL,
    slug        TEXT        UNIQUE NOT NULL,
    description TEXT,
    icon_url    TEXT,
    color_hex   CHAR(7),
    sort_order  INT         NOT NULL DEFAULT 0,
    is_active   BOOL        NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_categories_slug      ON categories (slug);
CREATE INDEX IF NOT EXISTS idx_categories_is_active ON categories (is_active);
CREATE INDEX IF NOT EXISTS idx_categories_sort      ON categories (sort_order);

-- ============================================================
-- Seed: 10 default categories
-- ============================================================

INSERT INTO categories (name, slug, description, color_hex, sort_order) VALUES
    ('Personal Finance', 'personal-finance',  'Master money management, investing, and building wealth.',          '#27AE60',  1),
    ('Productivity',     'productivity',       'Boost efficiency, manage time, and achieve peak performance.',      '#2980B9',  2),
    ('Psychology',       'psychology',         'Understand the human mind, behaviour, and mental models.',          '#8E44AD',  3),
    ('Business',         'business',           'Entrepreneurship, strategy, and business fundamentals.',            '#E67E22',  4),
    ('Leadership',       'leadership',         'Inspire teams, make decisions, and grow as a leader.',             '#C0392B',  5),
    ('Science',          'science',            'Explore scientific principles, discoveries, and innovations.',      '#16A085',  6),
    ('Philosophy',       'philosophy',         'Examine ideas, ethics, logic, and life''s big questions.',          '#2C3E50',  7),
    ('Health',           'health',             'Physical and mental well-being, nutrition, and longevity.',         '#E74C3C',  8),
    ('Technology',       'technology',         'Software, AI, hardware trends, and the digital future.',           '#2ECC71',  9),
    ('Creativity',       'creativity',         'Unlock creative thinking, design, and artistic expression.',       '#F39C12', 10)
ON CONFLICT (slug) DO NOTHING;
