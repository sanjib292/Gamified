-- =============================================================================
-- 31_rls_policies.sql
-- Row-Level Security: enable RLS and define policies for every table
-- =============================================================================

-- =============================================================================
-- HELPER: reusable policy expressions
--   auth.uid() = <user_id_column>    → own-row filter
--   is_admin()                       → admin check (SECURITY DEFINER fn)
--   has_active_subscription()        → subscription check (SECURITY DEFINER fn)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------------
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles: users read own" ON profiles;
CREATE POLICY "profiles: users read own"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "profiles: admins read all" ON profiles;
CREATE POLICY "profiles: admins read all"
    ON profiles FOR SELECT
    USING (is_admin());

DROP POLICY IF EXISTS "profiles: users update own" ON profiles;
CREATE POLICY "profiles: users update own"
    ON profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- subscriptions
-- ---------------------------------------------------------------------------
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "subscriptions: users read own" ON subscriptions;
CREATE POLICY "subscriptions: users read own"
    ON subscriptions FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "subscriptions: service role insert" ON subscriptions;
CREATE POLICY "subscriptions: service role insert"
    ON subscriptions FOR INSERT
    WITH CHECK (auth.role() = 'service_role');

DROP POLICY IF EXISTS "subscriptions: service role update" ON subscriptions;
CREATE POLICY "subscriptions: service role update"
    ON subscriptions FOR UPDATE
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- ---------------------------------------------------------------------------
-- user_progress
-- ---------------------------------------------------------------------------
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_progress: users read own" ON user_progress;
CREATE POLICY "user_progress: users read own"
    ON user_progress FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "user_progress: users insert own" ON user_progress;
CREATE POLICY "user_progress: users insert own"
    ON user_progress FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "user_progress: users update own" ON user_progress;
CREATE POLICY "user_progress: users update own"
    ON user_progress FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- xp_logs
-- ---------------------------------------------------------------------------
ALTER TABLE xp_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "xp_logs: users read own" ON xp_logs;
CREATE POLICY "xp_logs: users read own"
    ON xp_logs FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "xp_logs: service role insert" ON xp_logs;
CREATE POLICY "xp_logs: service role insert"
    ON xp_logs FOR INSERT
    WITH CHECK (auth.role() = 'service_role');

-- ---------------------------------------------------------------------------
-- user_achievements
-- ---------------------------------------------------------------------------
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_achievements: users read own" ON user_achievements;
CREATE POLICY "user_achievements: users read own"
    ON user_achievements FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "user_achievements: service role insert" ON user_achievements;
CREATE POLICY "user_achievements: service role insert"
    ON user_achievements FOR INSERT
    WITH CHECK (auth.role() = 'service_role');

-- ---------------------------------------------------------------------------
-- user_badges
-- ---------------------------------------------------------------------------
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_badges: users read own" ON user_badges;
CREATE POLICY "user_badges: users read own"
    ON user_badges FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "user_badges: service role insert" ON user_badges;
CREATE POLICY "user_badges: service role insert"
    ON user_badges FOR INSERT
    WITH CHECK (auth.role() = 'service_role');

-- ---------------------------------------------------------------------------
-- streaks
-- ---------------------------------------------------------------------------
ALTER TABLE streaks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "streaks: users read own" ON streaks;
CREATE POLICY "streaks: users read own"
    ON streaks FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "streaks: users update own" ON streaks;
CREATE POLICY "streaks: users update own"
    ON streaks FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "streaks: service role full" ON streaks;
CREATE POLICY "streaks: service role full"
    ON streaks FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- ---------------------------------------------------------------------------
-- ai_conversations
-- ---------------------------------------------------------------------------
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "ai_conversations: users crud own" ON ai_conversations;
CREATE POLICY "ai_conversations: users crud own"
    ON ai_conversations FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- ai_messages
-- ---------------------------------------------------------------------------
ALTER TABLE ai_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "ai_messages: users crud via conversation" ON ai_messages;
CREATE POLICY "ai_messages: users crud via conversation"
    ON ai_messages FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM ai_conversations c
             WHERE c.id      = conversation_id
               AND c.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM ai_conversations c
             WHERE c.id      = conversation_id
               AND c.user_id = auth.uid()
        )
    );

-- ---------------------------------------------------------------------------
-- notifications
-- ---------------------------------------------------------------------------
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "notifications: users read own" ON notifications;
CREATE POLICY "notifications: users read own"
    ON notifications FOR SELECT
    USING (auth.uid() = user_id);

-- Users can only update is_read / read_at (mark as read)
DROP POLICY IF EXISTS "notifications: users update own (mark read)" ON notifications;
CREATE POLICY "notifications: users update own (mark read)"
    ON notifications FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifications: service role insert" ON notifications;
CREATE POLICY "notifications: service role insert"
    ON notifications FOR INSERT
    WITH CHECK (auth.role() = 'service_role');

-- ---------------------------------------------------------------------------
-- bookmarks
-- ---------------------------------------------------------------------------
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "bookmarks: users crud own" ON bookmarks;
CREATE POLICY "bookmarks: users crud own"
    ON bookmarks FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- lesson_attempts (append-only for users)
-- ---------------------------------------------------------------------------
ALTER TABLE lesson_attempts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "lesson_attempts: users read own" ON lesson_attempts;
CREATE POLICY "lesson_attempts: users read own"
    ON lesson_attempts FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "lesson_attempts: users insert own" ON lesson_attempts;
CREATE POLICY "lesson_attempts: users insert own"
    ON lesson_attempts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- No UPDATE / DELETE for users — append-only log.

-- ---------------------------------------------------------------------------
-- user_ai_profile
-- ---------------------------------------------------------------------------
ALTER TABLE user_ai_profile ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_ai_profile: users read own" ON user_ai_profile;
CREATE POLICY "user_ai_profile: users read own"
    ON user_ai_profile FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "user_ai_profile: users update own" ON user_ai_profile;
CREATE POLICY "user_ai_profile: users update own"
    ON user_ai_profile FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "user_ai_profile: service role full" ON user_ai_profile;
CREATE POLICY "user_ai_profile: service role full"
    ON user_ai_profile FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- ---------------------------------------------------------------------------
-- recommendations
-- ---------------------------------------------------------------------------
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;

-- Users see their own, undismissed, non-expired recommendations
DROP POLICY IF EXISTS "recommendations: users read own active" ON recommendations;
CREATE POLICY "recommendations: users read own active"
    ON recommendations FOR SELECT
    USING (
        auth.uid() = user_id
        AND is_dismissed = false
        AND (expires_at IS NULL OR expires_at > now())
    );

DROP POLICY IF EXISTS "recommendations: service role insert" ON recommendations;
CREATE POLICY "recommendations: service role insert"
    ON recommendations FOR INSERT
    WITH CHECK (auth.role() = 'service_role');

DROP POLICY IF EXISTS "recommendations: service role update" ON recommendations;
CREATE POLICY "recommendations: service role update"
    ON recommendations FOR UPDATE
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Users may dismiss a recommendation (set is_dismissed = true)
DROP POLICY IF EXISTS "recommendations: users dismiss own" ON recommendations;
CREATE POLICY "recommendations: users dismiss own"
    ON recommendations FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- leaderboards (public read-only)
-- ---------------------------------------------------------------------------
ALTER TABLE leaderboards ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "leaderboards: public read" ON leaderboards;
CREATE POLICY "leaderboards: public read"
    ON leaderboards FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "leaderboards: service role full" ON leaderboards;
CREATE POLICY "leaderboards: service role full"
    ON leaderboards FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- ---------------------------------------------------------------------------
-- user_learning_stats
-- ---------------------------------------------------------------------------
ALTER TABLE user_learning_stats ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_learning_stats: users read own" ON user_learning_stats;
CREATE POLICY "user_learning_stats: users read own"
    ON user_learning_stats FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "user_learning_stats: users update own" ON user_learning_stats;
CREATE POLICY "user_learning_stats: users update own"
    ON user_learning_stats FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "user_learning_stats: service role full" ON user_learning_stats;
CREATE POLICY "user_learning_stats: service role full"
    ON user_learning_stats FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- ---------------------------------------------------------------------------
-- analytics_events (INSERT-only for authenticated users, no SELECT)
-- ---------------------------------------------------------------------------
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Authenticated users may only INSERT their own events
DROP POLICY IF EXISTS "analytics_events: users insert" ON analytics_events;
CREATE POLICY "analytics_events: users insert"
    ON analytics_events FOR INSERT
    WITH CHECK (
        auth.uid() = user_id OR user_id IS NULL
    );

-- Service role has full access for ETL pipelines
DROP POLICY IF EXISTS "analytics_events: service role full" ON analytics_events;
CREATE POLICY "analytics_events: service role full"
    ON analytics_events FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Admins may read analytics
DROP POLICY IF EXISTS "analytics_events: admins read" ON analytics_events;
CREATE POLICY "analytics_events: admins read"
    ON analytics_events FOR SELECT
    USING (is_admin());

-- ---------------------------------------------------------------------------
-- admin_users
-- ---------------------------------------------------------------------------
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Any active admin can read the admin roster
DROP POLICY IF EXISTS "admin_users: admins read" ON admin_users;
CREATE POLICY "admin_users: admins read"
    ON admin_users FOR SELECT
    USING (is_admin());

-- Only super_admins can grant/modify/revoke admin roles
DROP POLICY IF EXISTS "admin_users: super_admin insert" ON admin_users;
CREATE POLICY "admin_users: super_admin insert"
    ON admin_users FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM admin_users au
             WHERE au.user_id = auth.uid()
               AND au.role    = 'super_admin'
               AND au.is_active = true
        )
    );

DROP POLICY IF EXISTS "admin_users: super_admin update" ON admin_users;
CREATE POLICY "admin_users: super_admin update"
    ON admin_users FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM admin_users au
             WHERE au.user_id = auth.uid()
               AND au.role    = 'super_admin'
               AND au.is_active = true
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM admin_users au
             WHERE au.user_id = auth.uid()
               AND au.role    = 'super_admin'
               AND au.is_active = true
        )
    );

DROP POLICY IF EXISTS "admin_users: super_admin delete" ON admin_users;
CREATE POLICY "admin_users: super_admin delete"
    ON admin_users FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM admin_users au
             WHERE au.user_id = auth.uid()
               AND au.role    = 'super_admin'
               AND au.is_active = true
        )
    );

-- ---------------------------------------------------------------------------
-- books  (public SELECT where published; admin full CRUD)
-- ---------------------------------------------------------------------------
ALTER TABLE books ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "books: public read published" ON books;
CREATE POLICY "books: public read published"
    ON books FOR SELECT
    USING (is_published = true);

DROP POLICY IF EXISTS "books: admins full" ON books;
CREATE POLICY "books: admins full"
    ON books FOR ALL
    USING (is_admin())
    WITH CHECK (is_admin());

-- ---------------------------------------------------------------------------
-- learning_paths  (public SELECT where book is published; admin full CRUD)
-- ---------------------------------------------------------------------------
ALTER TABLE learning_paths ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "learning_paths: public read via published book" ON learning_paths;
CREATE POLICY "learning_paths: public read via published book"
    ON learning_paths FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM books b
             WHERE b.id           = book_id
               AND b.is_published = true
        )
    );

DROP POLICY IF EXISTS "learning_paths: admins full" ON learning_paths;
CREATE POLICY "learning_paths: admins full"
    ON learning_paths FOR ALL
    USING (is_admin())
    WITH CHECK (is_admin());

-- ---------------------------------------------------------------------------
-- lessons  (public SELECT published free lessons OR subscriber premium;
--           admins full CRUD)
-- ---------------------------------------------------------------------------
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;

-- Free-preview lessons visible to all authenticated users
DROP POLICY IF EXISTS "lessons: public read free preview" ON lessons;
CREATE POLICY "lessons: public read free preview"
    ON lessons FOR SELECT
    USING (is_published = true AND is_free_preview = true);

-- Subscribers can see all published lessons
DROP POLICY IF EXISTS "lessons: subscribers read all published" ON lessons;
CREATE POLICY "lessons: subscribers read all published"
    ON lessons FOR SELECT
    USING (is_published = true AND has_active_subscription());

-- Admins can do everything
DROP POLICY IF EXISTS "lessons: admins full" ON lessons;
CREATE POLICY "lessons: admins full"
    ON lessons FOR ALL
    USING (is_admin())
    WITH CHECK (is_admin());

-- ---------------------------------------------------------------------------
-- lesson_content  (mirrors lessons access)
-- ---------------------------------------------------------------------------
ALTER TABLE lesson_content ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "lesson_content: public read via free preview lesson" ON lesson_content;
CREATE POLICY "lesson_content: public read via free preview lesson"
    ON lesson_content FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM lessons l
             WHERE l.id             = lesson_id
               AND l.is_published   = true
               AND l.is_free_preview = true
        )
    );

DROP POLICY IF EXISTS "lesson_content: subscribers read via published lesson" ON lesson_content;
CREATE POLICY "lesson_content: subscribers read via published lesson"
    ON lesson_content FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM lessons l
             WHERE l.id           = lesson_id
               AND l.is_published = true
        )
        AND has_active_subscription()
    );

DROP POLICY IF EXISTS "lesson_content: admins full" ON lesson_content;
CREATE POLICY "lesson_content: admins full"
    ON lesson_content FOR ALL
    USING (is_admin())
    WITH CHECK (is_admin());

-- ---------------------------------------------------------------------------
-- categories  (public read-only reference data)
-- ---------------------------------------------------------------------------
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "categories: public read" ON categories;
CREATE POLICY "categories: public read"
    ON categories FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "categories: admins full" ON categories;
CREATE POLICY "categories: admins full"
    ON categories FOR ALL
    USING (is_admin())
    WITH CHECK (is_admin());

-- ---------------------------------------------------------------------------
-- achievements  (public read-only catalogue)
-- ---------------------------------------------------------------------------
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "achievements: public read" ON achievements;
CREATE POLICY "achievements: public read"
    ON achievements FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "achievements: admins full" ON achievements;
CREATE POLICY "achievements: admins full"
    ON achievements FOR ALL
    USING (is_admin())
    WITH CHECK (is_admin());

-- ---------------------------------------------------------------------------
-- badges  (public read-only catalogue)
-- ---------------------------------------------------------------------------
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "badges: public read" ON badges;
CREATE POLICY "badges: public read"
    ON badges FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "badges: admins full" ON badges;
CREATE POLICY "badges: admins full"
    ON badges FOR ALL
    USING (is_admin())
    WITH CHECK (is_admin());

-- ---------------------------------------------------------------------------
-- embeddings  (service role only — not directly exposed to clients)
-- ---------------------------------------------------------------------------
ALTER TABLE embeddings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "embeddings: service role full" ON embeddings;
CREATE POLICY "embeddings: service role full"
    ON embeddings FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Allow authenticated users to call search_books_semantic() (SECURITY DEFINER fn).
-- Direct table SELECT remains restricted.
