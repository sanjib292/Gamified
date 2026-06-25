-- =============================================================================
-- 20_notifications.sql
-- In-app notification inbox for users
-- Requires: notification_type enum (01_extensions_and_enums.sql)
-- =============================================================================

CREATE TABLE IF NOT EXISTS notifications (
    id          UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID                NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type        notification_type   NOT NULL,
    title       TEXT                NOT NULL,
    body        TEXT                NOT NULL,
    data        JSONB               NOT NULL DEFAULT '{}',
    is_read     BOOLEAN             NOT NULL DEFAULT false,
    read_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ         NOT NULL DEFAULT now(),

    CONSTRAINT notifications_title_not_empty CHECK (char_length(trim(title)) > 0),
    CONSTRAINT notifications_body_not_empty  CHECK (char_length(trim(body)) > 0),
    -- If is_read is true, read_at must be populated; and vice-versa
    CONSTRAINT notifications_read_consistency
        CHECK (
            (is_read = false AND read_at IS NULL) OR
            (is_read = true  AND read_at IS NOT NULL)
        )
);

-- Primary inbox query: unread notifications for a user, newest first
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
    ON notifications (user_id, created_at DESC)
    WHERE is_read = false;

-- Full inbox (read + unread), newest first
CREATE INDEX IF NOT EXISTS idx_notifications_user_created
    ON notifications (user_id, created_at DESC);

-- Filter by type within a user's inbox
CREATE INDEX IF NOT EXISTS idx_notifications_user_type
    ON notifications (user_id, type, created_at DESC);

-- Support bulk mark-read queries on the is_read flag
CREATE INDEX IF NOT EXISTS idx_notifications_is_read
    ON notifications (is_read)
    WHERE is_read = false;

COMMENT ON TABLE  notifications         IS 'In-app notification inbox; one row per notification per user.';
COMMENT ON COLUMN notifications.type    IS 'Enum value defining the notification category (see notification_type).';
COMMENT ON COLUMN notifications.data    IS 'Arbitrary payload for deep-link routing, e.g. {"lesson_id": "..."}.';
COMMENT ON COLUMN notifications.is_read IS 'Toggled to true (with read_at) when the user views the notification.';
COMMENT ON COLUMN notifications.read_at IS 'Exact timestamp the notification was marked read.';
