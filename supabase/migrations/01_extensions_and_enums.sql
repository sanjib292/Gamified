-- ============================================================
-- MindQuest: Extensions and Enums
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- ============================================================
-- Enums
-- ============================================================

CREATE TYPE content_type AS ENUM (
    'quiz',
    'flashcard',
    'story_mission',
    'simulation',
    'challenge',
    'video',
    'article'
);

CREATE TYPE difficulty_level AS ENUM (
    'beginner',
    'intermediate',
    'advanced',
    'expert'
);

CREATE TYPE subscription_tier AS ENUM (
    'free',
    'premium',
    'premium_plus'
);

CREATE TYPE subscription_status AS ENUM (
    'active',
    'cancelled',
    'expired',
    'trial'
);

CREATE TYPE achievement_category AS ENUM (
    'learning',
    'streak',
    'social',
    'mastery',
    'exploration'
);

CREATE TYPE notification_type AS ENUM (
    'streak_reminder',
    'achievement_unlocked',
    'new_book',
    'level_up',
    'challenge_available',
    'social'
);

CREATE TYPE lesson_status AS ENUM (
    'not_started',
    'in_progress',
    'completed',
    'locked'
);

CREATE TYPE period_type AS ENUM (
    'daily',
    'weekly',
    'monthly',
    'all_time'
);
