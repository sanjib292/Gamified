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
-- Enums (idempotent — safe to re-run if types already exist)
-- ============================================================

DO $$ BEGIN
  CREATE TYPE content_type AS ENUM (
      'quiz', 'flashcard', 'story_mission', 'simulation', 'challenge', 'video', 'article'
  );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE difficulty_level AS ENUM (
      'beginner', 'intermediate', 'advanced', 'expert'
  );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE subscription_tier AS ENUM (
      'free', 'premium', 'premium_plus'
  );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE subscription_status AS ENUM (
      'active', 'cancelled', 'expired', 'trial'
  );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE achievement_category AS ENUM (
      'learning', 'streak', 'social', 'mastery', 'exploration'
  );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE notification_type AS ENUM (
      'streak_reminder', 'achievement_unlocked', 'new_book',
      'level_up', 'challenge_available', 'social'
  );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE lesson_status AS ENUM (
      'not_started', 'in_progress', 'completed', 'locked'
  );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE period_type AS ENUM (
      'daily', 'weekly', 'monthly', 'all_time'
  );
EXCEPTION WHEN duplicate_object THEN null;
END $$;
