-- =============================================================================
-- 22_admin_users.sql
-- Admin role assignments; references auth.users directly for bootstrapping
-- =============================================================================

CREATE TABLE IF NOT EXISTS IF NOT EXISTS admin_users (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    role        TEXT        NOT NULL DEFAULT 'content_editor'
                            CHECK (role IN ('super_admin', 'content_editor', 'analyst')),
    created_by  UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
    is_active   BOOLEAN     NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Lookup by user_id (covered by UNIQUE; explicit index for partial queries)
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_admin_users_user_id
    ON admin_users (user_id);

-- Filter active admins by role (used in permission checks)
CREATE INDEX IF NOT EXISTS IF NOT EXISTS idx_admin_users_role_active
    ON admin_users (role, is_active)
    WHERE is_active = true;

COMMENT ON TABLE  admin_users               IS 'Back-office role assignments. References auth.users (not profiles) so admins can be granted before their profile row is created.';
COMMENT ON COLUMN admin_users.user_id       IS 'auth.users.id of the admin; UNIQUE ensures one role per user.';
COMMENT ON COLUMN admin_users.role          IS 'super_admin: full access. content_editor: CRUD on content. analyst: read-only analytics.';
COMMENT ON COLUMN admin_users.created_by    IS 'auth.users.id of the admin who granted this role; NULL for seed/bootstrap rows.';
COMMENT ON COLUMN admin_users.is_active     IS 'Soft-deactivation flag; preferred over hard-delete for audit trails.';
