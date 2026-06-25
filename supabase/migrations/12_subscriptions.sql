-- ============================================================
-- MindQuest: Subscriptions
-- ============================================================

CREATE TABLE subscriptions (
    id                      UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    -- UNIQUE: only one subscription record per user
    user_id                 UUID                NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    tier                    subscription_tier   NOT NULL DEFAULT 'free',
    status                  subscription_status NOT NULL DEFAULT 'active',
    stripe_subscription_id  TEXT,
    stripe_customer_id      TEXT,
    current_period_start    TIMESTAMPTZ,
    current_period_end      TIMESTAMPTZ,
    cancel_at_period_end    BOOL                NOT NULL DEFAULT false,
    cancelled_at            TIMESTAMPTZ,
    trial_end               TIMESTAMPTZ,
    created_at              TIMESTAMPTZ         NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ         NOT NULL DEFAULT now(),

    -- If cancelled, cancelled_at must be set
    CONSTRAINT chk_subscriptions_cancelled_at CHECK (
        status <> 'cancelled' OR cancelled_at IS NOT NULL
    ),
    -- period end must be after period start when both are provided
    CONSTRAINT chk_subscriptions_period_order CHECK (
        current_period_start IS NULL
        OR current_period_end IS NULL
        OR current_period_end > current_period_start
    )
);

CREATE TRIGGER trg_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX idx_subscriptions_user_id               ON subscriptions (user_id);
CREATE INDEX idx_subscriptions_status                ON subscriptions (status);
CREATE INDEX idx_subscriptions_stripe_subscription   ON subscriptions (stripe_subscription_id) WHERE stripe_subscription_id IS NOT NULL;
CREATE INDEX idx_subscriptions_stripe_customer       ON subscriptions (stripe_customer_id)      WHERE stripe_customer_id IS NOT NULL;
CREATE INDEX idx_subscriptions_period_end            ON subscriptions (current_period_end)       WHERE status = 'active';
