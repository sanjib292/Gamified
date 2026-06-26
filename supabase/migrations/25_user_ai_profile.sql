-- =============================================================================
-- 25_user_ai_profile.sql
-- Per-user AI personalisation profile (1:1 with profiles)
-- =============================================================================

CREATE TABLE IF NOT EXISTS IF NOT EXISTS user_ai_profile (
    user_id                 UUID        PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    learning_style          TEXT        NOT NULL DEFAULT 'balanced'
                                        CHECK (learning_style IN (
                                            'visual', 'auditory', 'reading', 'kinesthetic', 'balanced'
                                        )),
    preferred_topics        TEXT[]      NOT NULL DEFAULT '{}',
    difficulty_preference   TEXT        NOT NULL DEFAULT 'adaptive'
                                        CHECK (difficulty_preference IN ('easy', 'adaptive', 'hard')),
    interaction_count       INT         NOT NULL DEFAULT 0,
    last_quiz_topics        TEXT[]      NOT NULL DEFAULT '{}',
    feedback_history        JSONB       NOT NULL DEFAULT '[]',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT user_ai_profile_interaction_count_non_neg CHECK (interaction_count >= 0)
);

-- No secondary indexes needed — access is always by primary key (user_id).
-- Add indexes here if analytics queries require aggregating by learning_style etc.

COMMENT ON TABLE  user_ai_profile                         IS 'AI tutor personalisation state for each user; 1:1 with profiles.';
COMMENT ON COLUMN user_ai_profile.learning_style          IS 'Preferred modality inferred or set by the user: visual | auditory | reading | kinesthetic | balanced.';
COMMENT ON COLUMN user_ai_profile.preferred_topics        IS 'Array of topic slugs the user has expressed interest in.';
COMMENT ON COLUMN user_ai_profile.difficulty_preference   IS 'Desired challenge level: easy | adaptive | hard.';
COMMENT ON COLUMN user_ai_profile.interaction_count       IS 'Lifetime count of AI turns; used to gate personalisation features.';
COMMENT ON COLUMN user_ai_profile.last_quiz_topics        IS 'Topics covered in the most recent quiz session for continuity.';
COMMENT ON COLUMN user_ai_profile.feedback_history        IS 'Array of {rating, comment, at} objects from explicit user feedback.';
