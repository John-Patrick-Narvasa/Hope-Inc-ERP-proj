-- =====================================================================
-- 004_authz.sql : Authorization Helpers & Enhanced Audit User Resolution
-- =====================================================================

-- Override audit_user() from 002 to resolve authenticated user's name
CREATE OR REPLACE FUNCTION audit_user() 
RETURNS TEXT
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
DECLARE
    v_name TEXT;
    v_uid  UUID;
BEGIN
    v_uid := auth.uid();
    IF v_uid IS NOT NULL THEN
        SELECT (firstname || ' ' || lastname) INTO v_name
        FROM public.app_user
        WHERE id = v_uid;
        
        IF v_name IS NOT NULL THEN
            RETURN v_name;
        END IF;
    END IF;

    -- Fallback to session variable or db user if unauthenticated background job
    RETURN COALESCE(NULLIF(current_setting('app.username', true), ''), session_user::text);
END;
$$;

-- Helper: Check if active user
CREATE OR REPLACE FUNCTION is_active(p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.app_user 
        WHERE id = p_user_id AND status = 'active'
    );
$$;

-- Helper: Check if user has Superadmin role
CREATE OR REPLACE FUNCTION is_superadmin(p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.app_user 
        WHERE id = p_user_id AND status = 'active' AND role = 'superadmin'
    );
$$;

-- Helper: Check if user has Admin or Superadmin role
CREATE OR REPLACE FUNCTION is_admin(p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.app_user 
        WHERE id = p_user_id AND status = 'active' AND role IN ('admin', 'superadmin')
    );
$$;

-- Helper: Universal permission check
CREATE OR REPLACE FUNCTION has_right(p_right_code VARCHAR, p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
BEGIN
    -- Superadmin and Admin bypass explicit rights checks
    IF is_admin(p_user_id) THEN
        RETURN TRUE;
    END IF;

    -- Standard User must be active and have explicitly granted right
    IF NOT is_active(p_user_id) THEN
        RETURN FALSE;
    END IF;

    RETURN EXISTS (
        SELECT 1 FROM public.user_right 
        WHERE user_id = p_user_id AND right_code = p_right_code
    );
END;
$$;

-- Helper: Get complete user access session context
CREATE OR REPLACE FUNCTION get_my_access(p_user_id UUID DEFAULT auth.uid())
RETURNS JSONB
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
DECLARE
    v_user public.app_user%ROWTYPE;
    v_modules JSONB;
    v_rights  JSONB;
BEGIN
    SELECT * INTO v_user FROM public.app_user WHERE id = p_user_id;
    IF v_user.id IS NULL THEN
        RETURN jsonb_build_object('authenticated', false);
    END IF;

    IF v_user.role IN ('admin', 'superadmin') THEN
        SELECT jsonb_agg(module_code) INTO v_modules FROM public.module;
        SELECT jsonb_agg(right_code)  INTO v_rights  FROM public.right_catalog;
    ELSE
        SELECT jsonb_agg(module_code) INTO v_modules FROM public.user_module WHERE user_id = p_user_id;
        SELECT jsonb_agg(right_code)  INTO v_rights  FROM public.user_right  WHERE user_id = p_user_id;
    END IF;

    RETURN jsonb_build_object(
        'user_id',    v_user.id,
        'email',      v_user.email,
        'firstname',  v_user.firstname,
        'lastname',   v_user.lastname,
        'role',       v_user.role,
        'status',     v_user.status,
        'modules',    COALESCE(v_modules, '[]'::jsonb),
        'rights',     COALESCE(v_rights,  '[]'::jsonb)
    );
END;
$$;