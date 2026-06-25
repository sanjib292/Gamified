-- =============================================================================
-- 29_functions.sql
-- PL/pgSQL utility and business-logic functions
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. calculate_level(xp_total INT) → SMALLINT
--    Level = max(1, floor(sqrt(xp / 100)) + 1)
--    XP thresholds (approx): L2=100, L5=1600, L10=8100, L25=57600, L50=240100
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_level(xp_total INT)
RETURNS SMALLINT
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
    SELECT GREATEST(1, floor(sqrt(xp_total::float / 100.0))::smallint + 1);
$$;

COMMENT ON FUNCTION calculate_level(INT) IS
    'Converts a raw XP total to a level number (1-based, minimum 1).';

-- ---------------------------------------------------------------------------
-- 2. get_level_title(level SMALLINT) → TEXT
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_level_title(level SMALLINT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
    SELECT CASE
        WHEN level BETWEEN  1 AND  10 THEN 'Explorer'
        WHEN level BETWEEN 11 AND  25 THEN 'Learner'
        WHEN level BETWEEN 26 AND  50 THEN 'Scholar'
        WHEN level BETWEEN 51 AND  75 THEN 'Sage'
        WHEN level BETWEEN 76 AND 100 THEN 'Legend'
        ELSE 'Legend'
    END;
$$;

COMMENT ON FUNCTION get_level_title(SMALLINT) IS
    'Returns the display title for a given level number.';

-- ---------------------------------------------------------------------------
-- 3. is_admin() → BOOL  (SECURITY DEFINER — reads admin_users as service role)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM   admin_users
        WHERE  user_id   = auth.uid()
          AND  is_active = true
    );
END;
$$;

COMMENT ON FUNCTION is_admin() IS
    'Returns true when the current JWT user has an active admin_users row.';

-- ---------------------------------------------------------------------------
-- 4. has_active_subscription() → BOOL  (SECURITY DEFINER)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION has_active_subscription()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM   subscriptions
        WHERE  user_id = auth.uid()
          AND  status  = 'active'
          AND  (current_period_end IS NULL OR current_period_end > now())
    );
END;
$$;

COMMENT ON FUNCTION has_active_subscription() IS
    'Returns true when the current user has an active, non-expired subscription.';

-- ---------------------------------------------------------------------------
-- 5. check_and_award_achievements(p_user_id UUID) → VOID  (SECURITY DEFINER)
--    Evaluates all achievement conditions against live user stats and inserts
--    any newly-earned achievements + corresponding XP log entries.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_and_award_achievements(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_lessons_completed  INT;
    v_current_streak     INT;
    v_xp_total           INT;
    v_books_completed    INT;
    v_level              SMALLINT;
    v_quiz_perfect_count INT;
    v_ach                RECORD;
    v_condition_met      BOOLEAN;
BEGIN
    -- ── Gather user stats ────────────────────────────────────────────────────
    SELECT p.lessons_completed, p.xp_total, calculate_level(p.xp_total)
      INTO v_lessons_completed, v_xp_total, v_level
      FROM profiles p
     WHERE p.id = p_user_id;

    SELECT COALESCE(s.current_streak, 0)
      INTO v_current_streak
      FROM streaks s
     WHERE s.user_id = p_user_id;

    -- Books completed = books where every lesson has a completed user_progress row
    SELECT COUNT(DISTINCT up.lesson_id)
      INTO v_books_completed
      FROM user_progress up
      JOIN lessons l ON l.id = up.lesson_id
     WHERE up.user_id = p_user_id
       AND up.status  = 'completed'
       AND NOT EXISTS (
               SELECT 1
                 FROM lessons l2
                WHERE l2.book_id = l.book_id
                  AND NOT EXISTS (
                          SELECT 1
                            FROM user_progress up2
                           WHERE up2.user_id    = p_user_id
                             AND up2.lesson_id  = l2.id
                             AND up2.status     = 'completed'
                      )
           );

    -- Perfect quiz attempts = score_pct = 100 AND completed
    SELECT COUNT(*)
      INTO v_quiz_perfect_count
      FROM lesson_attempts la
     WHERE la.user_id   = p_user_id
       AND la.score_pct = 100
       AND la.completed = true;

    -- ── Iterate achievements not yet earned ──────────────────────────────────
    FOR v_ach IN
        SELECT a.*
          FROM achievements a
         WHERE NOT EXISTS (
                   SELECT 1
                     FROM user_achievements ua
                    WHERE ua.user_id        = p_user_id
                      AND ua.achievement_id = a.id
               )
    LOOP
        v_condition_met := false;

        CASE v_ach.condition_type
            WHEN 'lessons_completed' THEN
                v_condition_met := v_lessons_completed >= v_ach.condition_value;

            WHEN 'lesson_streak' THEN
                v_condition_met := v_current_streak >= v_ach.condition_value;

            WHEN 'quiz_perfect_count' THEN
                v_condition_met := v_quiz_perfect_count >= v_ach.condition_value;

            WHEN 'books_completed' THEN
                v_condition_met := v_books_completed >= v_ach.condition_value;

            WHEN 'level' THEN
                v_condition_met := v_level >= v_ach.condition_value;

            WHEN 'xp_total' THEN
                v_condition_met := v_xp_total >= v_ach.condition_value;

            ELSE
                -- Unknown condition types are skipped (forward-compatible)
                v_condition_met := false;
        END CASE;

        IF v_condition_met THEN
            -- Award achievement
            INSERT INTO user_achievements (user_id, achievement_id, earned_at)
            VALUES (p_user_id, v_ach.id, now())
            ON CONFLICT (user_id, achievement_id) DO NOTHING;

            -- Award XP for the achievement if it has a reward
            IF v_ach.xp_reward > 0 THEN
                INSERT INTO xp_logs (user_id, amount, source, source_id, description)
                VALUES (
                    p_user_id,
                    v_ach.xp_reward,
                    'achievement',
                    v_ach.id,
                    'Achievement unlocked: ' || v_ach.title
                );
            END IF;
        END IF;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION check_and_award_achievements(UUID) IS
    'Evaluates all un-earned achievements for a user and inserts rows into user_achievements and xp_logs for each newly satisfied condition.';

-- ---------------------------------------------------------------------------
-- 6. search_books_semantic(query_embedding, match_count, min_similarity)
--    Returns source rows ordered by cosine similarity.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION search_books_semantic(
    query_embedding vector(1536),
    match_count     INT     DEFAULT 10,
    min_similarity  FLOAT   DEFAULT 0.5
)
RETURNS TABLE (
    source_id   UUID,
    source_type TEXT,
    similarity  FLOAT
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        e.source_id,
        e.source_type,
        (1.0 - (e.embedding <=> query_embedding))::FLOAT AS similarity
    FROM embeddings e
    WHERE
        (1.0 - (e.embedding <=> query_embedding)) >= min_similarity
    ORDER BY
        e.embedding <=> query_embedding   -- ascending distance = descending similarity
    LIMIT match_count;
$$;

COMMENT ON FUNCTION search_books_semantic(vector, INT, FLOAT) IS
    'Returns up to match_count embedding rows whose cosine similarity to query_embedding meets or exceeds min_similarity, ordered best-first.';

-- ---------------------------------------------------------------------------
-- 7. get_next_lesson(p_user_id UUID, p_book_id UUID) → UUID
--    Returns the UUID of the first incomplete lesson in the book.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_next_lesson(p_user_id UUID, p_book_id UUID)
RETURNS UUID
LANGUAGE sql
STABLE
AS $$
    SELECT l.id
      FROM learning_paths lp
      JOIN lessons        l  ON l.learning_path_id = lp.id
     WHERE lp.book_id = p_book_id
       AND NOT EXISTS (
               SELECT 1
                 FROM user_progress up
                WHERE up.user_id   = p_user_id
                  AND up.lesson_id = l.id
                  AND up.status    = 'completed'
           )
     ORDER BY lp.sort_order ASC, l.sort_order ASC
     LIMIT 1;
$$;

COMMENT ON FUNCTION get_next_lesson(UUID, UUID) IS
    'Returns the first incomplete lesson UUID for a user within a book, ordered by learning_path sort_order then lesson sort_order.';

-- ---------------------------------------------------------------------------
-- 8. refresh_leaderboard_snapshot(p_period_type, p_period_key) → VOID
--    Atomically replaces the snapshot for a given period.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION refresh_leaderboard_snapshot(
    p_period_type period_type,
    p_period_key  TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_period_start  TIMESTAMPTZ;
    v_period_end    TIMESTAMPTZ;
BEGIN
    -- ── Derive period boundaries for XP aggregation ──────────────────────────
    CASE p_period_type
        WHEN 'weekly' THEN
            -- p_period_key format: '2025-W01'
            v_period_start := date_trunc('week',
                                  to_date(
                                      split_part(p_period_key, '-W', 1) || '-' ||
                                      lpad(split_part(p_period_key, '-W', 2), 2, '0') || '-1',
                                      'IYYY-IW-ID'
                                  )
                              );
            v_period_end := v_period_start + INTERVAL '7 days';

        WHEN 'monthly' THEN
            -- p_period_key format: '2025-01'
            v_period_start := date_trunc('month', to_date(p_period_key || '-01', 'YYYY-MM-DD'));
            v_period_end   := v_period_start + INTERVAL '1 month';

        WHEN 'all_time' THEN
            v_period_start := '-infinity'::TIMESTAMPTZ;
            v_period_end   := 'infinity'::TIMESTAMPTZ;

        ELSE
            RAISE EXCEPTION 'Unknown period_type: %', p_period_type;
    END CASE;

    -- ── Delete stale snapshot ────────────────────────────────────────────────
    DELETE FROM leaderboards
     WHERE period_type = p_period_type
       AND period_key  = p_period_key;

    -- ── Insert fresh top-100 snapshot ────────────────────────────────────────
    INSERT INTO leaderboards (
        period_type, period_key, user_id, display_name, avatar_url,
        xp_earned, rank, snapshot_at
    )
    SELECT
        p_period_type,
        p_period_key,
        p.id                        AS user_id,
        p.display_name,
        p.avatar_url,
        COALESCE(SUM(xl.amount), 0) AS xp_earned,
        ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(xl.amount), 0) DESC) AS rank,
        now()
    FROM profiles p
    LEFT JOIN xp_logs xl
           ON xl.user_id    = p.id
          AND xl.created_at >= v_period_start
          AND xl.created_at <  v_period_end
    GROUP BY p.id, p.display_name, p.avatar_url
    ORDER BY xp_earned DESC
    LIMIT 100;
END;
$$;

COMMENT ON FUNCTION refresh_leaderboard_snapshot(period_type, TEXT) IS
    'Atomically deletes and rebuilds the leaderboard snapshot for a given (period_type, period_key). Inserts top 100 users ranked by XP earned in the period.';
