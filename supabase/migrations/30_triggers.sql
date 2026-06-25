-- =============================================================================
-- 30_triggers.sql
-- All trigger functions and their bindings
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. set_updated_at()
--    Generic BEFORE UPDATE trigger that stamps updated_at = now().
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION set_updated_at() IS
    'Sets NEW.updated_at = now() on every UPDATE. Attach as BEFORE UPDATE trigger.';

-- Helper macro: create the trigger on a table if it does not already exist.
-- We use DO blocks so re-running the migration is idempotent.

DO $$ BEGIN
    CREATE TRIGGER trg_books_updated_at
        BEFORE UPDATE ON books
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_learning_paths_updated_at
        BEFORE UPDATE ON learning_paths
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_lessons_updated_at
        BEFORE UPDATE ON lessons
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_lesson_content_updated_at
        BEFORE UPDATE ON lesson_content
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_quizzes_updated_at
        BEFORE UPDATE ON quizzes
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_simulations_updated_at
        BEFORE UPDATE ON simulations
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_flashcard_decks_updated_at
        BEFORE UPDATE ON flashcard_decks
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_story_missions_updated_at
        BEFORE UPDATE ON story_missions
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_profiles_updated_at
        BEFORE UPDATE ON profiles
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_subscriptions_updated_at
        BEFORE UPDATE ON subscriptions
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_user_progress_updated_at
        BEFORE UPDATE ON user_progress
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_streaks_updated_at
        BEFORE UPDATE ON streaks
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_ai_conversations_updated_at
        BEFORE UPDATE ON ai_conversations
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_notifications_updated_at
        BEFORE UPDATE ON notifications
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_admin_users_updated_at
        BEFORE UPDATE ON admin_users
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_user_ai_profile_updated_at
        BEFORE UPDATE ON user_ai_profile
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_bookmarks_updated_at
        BEFORE UPDATE ON bookmarks
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_recommendations_updated_at
        BEFORE UPDATE ON recommendations
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_leaderboards_updated_at
        BEFORE UPDATE ON leaderboards
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TRIGGER trg_user_learning_stats_updated_at
        BEFORE UPDATE ON user_learning_stats
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- 2. handle_new_user()
--    Bootstraps all per-user rows when a new auth.users record is created.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- profiles
    INSERT INTO profiles (id, email, display_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name',
            split_part(NEW.email, '@', 1)
        ),
        NEW.raw_user_meta_data->>'avatar_url'
    )
    ON CONFLICT (id) DO NOTHING;

    -- streaks (initialised at zero)
    INSERT INTO streaks (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;

    -- subscriptions (free tier by default)
    INSERT INTO subscriptions (user_id, tier, status)
    VALUES (NEW.id, 'free', 'active')
    ON CONFLICT (user_id) DO NOTHING;

    -- ai profile
    INSERT INTO user_ai_profile (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;

    -- learning stats
    INSERT INTO user_learning_stats (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION handle_new_user() IS
    'Bootstraps profiles, streaks, subscriptions, user_ai_profile, and user_learning_stats rows for every new auth.users entry.';

DO $$ BEGIN
    CREATE TRIGGER trg_on_auth_user_created
        AFTER INSERT ON auth.users
        FOR EACH ROW EXECUTE FUNCTION handle_new_user();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- 3. sync_xp_to_profile()
--    Increments profiles.xp_total whenever a new xp_logs row is inserted.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sync_xp_to_profile()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE profiles
       SET xp_total = xp_total + NEW.amount
     WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION sync_xp_to_profile() IS
    'Adds NEW.amount to profiles.xp_total after each xp_logs INSERT.';

DO $$ BEGIN
    CREATE TRIGGER trg_xp_logs_sync_profile
        AFTER INSERT ON xp_logs
        FOR EACH ROW EXECUTE FUNCTION sync_xp_to_profile();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- 4. update_profile_level()
--    Recalculates level and level_title after xp_total changes on profiles.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_profile_level()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_level       SMALLINT;
    v_level_title TEXT;
BEGIN
    -- Only recalculate if xp_total actually changed
    IF NEW.xp_total IS NOT DISTINCT FROM OLD.xp_total THEN
        RETURN NEW;
    END IF;

    v_level       := calculate_level(NEW.xp_total);
    v_level_title := get_level_title(v_level);

    NEW.level       := v_level;
    NEW.level_title := v_level_title;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION update_profile_level() IS
    'Recomputes level and level_title on profiles whenever xp_total changes.';

DO $$ BEGIN
    CREATE TRIGGER trg_profiles_level_update
        BEFORE UPDATE OF xp_total ON profiles
        FOR EACH ROW EXECUTE FUNCTION update_profile_level();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- 5. sync_lesson_count_on_book()
--    Keeps books.total_lessons in sync when lessons are inserted/updated/deleted.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sync_lesson_count_on_book()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_book_id UUID;
BEGIN
    -- Determine the affected book_id from OLD or NEW as appropriate
    IF TG_OP = 'DELETE' THEN
        v_book_id := OLD.book_id;
    ELSE
        v_book_id := NEW.book_id;
    END IF;

    UPDATE books
       SET total_lessons = (
               SELECT COUNT(*)
                 FROM lessons
                WHERE book_id = v_book_id
           )
     WHERE id = v_book_id;

    -- On UPDATE if book_id changed, fix the old book too
    IF TG_OP = 'UPDATE' AND OLD.book_id IS DISTINCT FROM NEW.book_id THEN
        UPDATE books
           SET total_lessons = (
                   SELECT COUNT(*)
                     FROM lessons
                    WHERE book_id = OLD.book_id
               )
         WHERE id = OLD.book_id;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$;

COMMENT ON FUNCTION sync_lesson_count_on_book() IS
    'Recalculates books.total_lessons from the live lessons table after any lesson INSERT/UPDATE/DELETE.';

DO $$ BEGIN
    CREATE TRIGGER trg_lessons_sync_book_count
        AFTER INSERT OR UPDATE OR DELETE ON lessons
        FOR EACH ROW EXECUTE FUNCTION sync_lesson_count_on_book();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- 6. increment_ai_message_count()
--    Keeps ai_conversations.message_count and last_message_at current.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION increment_ai_message_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE ai_conversations
       SET message_count   = message_count + 1,
           last_message_at = now()
     WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION increment_ai_message_count() IS
    'Increments ai_conversations.message_count and refreshes last_message_at after each ai_messages INSERT.';

DO $$ BEGIN
    CREATE TRIGGER trg_ai_messages_increment_count
        AFTER INSERT ON ai_messages
        FOR EACH ROW EXECUTE FUNCTION increment_ai_message_count();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- 7. update_profile_stats_on_progress()
--    Increments profiles.lessons_completed when a user_progress row transitions
--    to 'completed'.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_profile_stats_on_progress()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Only act on transitions to 'completed'
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status <> 'completed') THEN
        UPDATE profiles
           SET lessons_completed = lessons_completed + 1
         WHERE id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION update_profile_stats_on_progress() IS
    'Increments profiles.lessons_completed when user_progress.status transitions to ''completed''.';

DO $$ BEGIN
    CREATE TRIGGER trg_user_progress_completed
        AFTER UPDATE OF status ON user_progress
        FOR EACH ROW EXECUTE FUNCTION update_profile_stats_on_progress();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
