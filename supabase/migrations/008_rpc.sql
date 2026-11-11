-- =====================================================================
-- 008_rpc.sql : Transaction Stored Procedures & Admin RPC APIs
-- =====================================================================

-- 1. Create Sale Transaction Header + Line Items Atomically
CREATE OR REPLACE FUNCTION create_sale(
    p_custno VARCHAR(5),
    p_empno  VARCHAR(5),
    p_salesdate DATE,
    p_lines JSONB
)
RETURNS VARCHAR(8)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    v_transno VARCHAR(8);
    v_line RECORD;
BEGIN
    IF NOT has_right('SALE_ADD') THEN
        RAISE EXCEPTION 'Access Denied: Missing SALE_ADD permission.';
    END IF;

    -- Verify Active Employee
    IF NOT EXISTS (SELECT 1 FROM public.employee WHERE empno = p_empno AND NOT is_deleted) THEN
        RAISE EXCEPTION 'Invalid Employee ID % or employee is inactive.', p_empno;
    END IF;

    -- Generate ID
    v_transno := next_transno();

    -- Insert Sales Header
    INSERT INTO public.sales (transno, salesdate, custno, empno)
    VALUES (v_transno, p_salesdate, p_custno, p_empno);

    -- Insert Line Items
    FOR v_line IN SELECT * FROM jsonb_to_recordset(p_lines) AS x(prodcode VARCHAR(6), qty DECIMAL(10,2))
    LOOP
        INSERT INTO public.salesdetail (transno, prodcode, quantity)
        VALUES (v_transno, v_line.prodcode, v_line.qty);
    END LOOP;

    RETURN v_transno;
END;
$$;

-- 2. Record Payment with Balance Validation
-- CREATE OR REPLACE FUNCTION record_payment(
--     p_transno VARCHAR(8),
--     p_amount  DECIMAL(10,2),
--     p_paydate DATE,
--     p_paymode VARCHAR(10) DEFAULT 'CASH'
-- )
-- RETURNS VARCHAR(8)
-- LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
-- DECLARE
--     v_orno VARCHAR(8);
--     v_sale RECORD;
-- BEGIN
--     IF NOT has_right('PAY_ADD') THEN
--         RAISE EXCEPTION 'Access Denied: Missing PAY_ADD permission.';
--     END IF;

--     -- Lock and inspect sale balance
--     SELECT * INTO v_sale FROM public.v_sale_balance WHERE transno = p_transno FOR UPDATE;
    
--     IF v_sale.transno IS NULL THEN
--         RAISE EXCEPTION 'Sale transaction % not found.', p_transno;
--     END IF;

--     IF p_paydate < v_sale.salesdate THEN
--         RAISE EXCEPTION 'Payment date (%) cannot precede sales date (%).', p_paydate, v_sale.salesdate;
--     END IF;

--     IF p_amount > v_sale.open_balance THEN
--         RAISE EXCEPTION 'Payment amount (%). exceeds open balance (%).', p_amount, v_sale.open_balance;
--     END IF;

--     v_orno := next_orno();

--     INSERT INTO public.payment (orno, paydate, amount, transno)
--     VALUES (v_orno, p_paydate, p_amount, p_transno);

--     RETURN v_orno;
-- END;
-- $$;
CREATE OR REPLACE FUNCTION record_payment(
    p_transno VARCHAR(8),
    p_amount  DECIMAL(10,2),
    p_paydate DATE,
    p_paymode VARCHAR(10) DEFAULT 'CASH'
)
RETURNS VARCHAR(8)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    v_orno VARCHAR(8);
    v_sale RECORD;
BEGIN
    IF NOT has_right('PAY_ADD') THEN
        RAISE EXCEPTION 'Access Denied: Missing PAY_ADD permission.';
    END IF;

    -- 1. Lock the base sales table row directly to prevent race conditions
    PERFORM 1 FROM public.sales WHERE transno = p_transno FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale transaction % not found.', p_transno;
    END IF;

    -- 2. Inspect computed balance from the view without row locking
    SELECT * INTO v_sale FROM public.v_sale_balance WHERE transno = p_transno;

    IF p_paydate < v_sale.salesdate THEN
        RAISE EXCEPTION 'Payment date (%) cannot precede sales date (%).', p_paydate, v_sale.salesdate;
    END IF;

    IF p_amount > v_sale.open_balance THEN
        RAISE EXCEPTION 'Payment amount (%) exceeds open balance (%).', p_amount, v_sale.open_balance;
    END IF;

    v_orno := next_orno();

    INSERT INTO public.payment (orno, paydate, amount, transno)
    VALUES (v_orno, p_paydate, p_amount, p_transno);

    RETURN v_orno;
END;
$$;


-- 3. Update Sale Line Item with Payment Guard
CREATE OR REPLACE FUNCTION update_sale_line(
    p_transno VARCHAR(8),
    p_prodcode VARCHAR(6),
    p_quantity DECIMAL(10,2)
)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    v_old_qty DECIMAL(10,2);
    v_new_total DECIMAL(10,2);
    v_paid DECIMAL(10,2);
BEGIN
    IF NOT has_right('SDTL_EDIT') THEN
        RAISE EXCEPTION 'Access Denied: Missing SDTL_EDIT permission.';
    END IF;

    UPDATE public.salesdetail 
    SET quantity = p_quantity
    WHERE transno = p_transno AND prodcode = p_prodcode AND NOT is_deleted;

    -- Re-check sale total vs active payments
    SELECT total_amount, paid_amount INTO v_new_total, v_paid 
    FROM public.v_sale_balance 
    WHERE transno = p_transno;

    IF v_new_total < v_paid THEN
        RAISE EXCEPTION 'Cannot reduce line quantity: new order total (%) is less than paid amount (%).', v_new_total, v_paid;
    END IF;
END;
$$;

-- 4. Admin User Approval Procedure
CREATE OR REPLACE FUNCTION approve_user(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access Denied: Superadmin/Admin role required.';
    END IF;

    UPDATE public.app_user
    SET status = 'active', updated_at = now()
    WHERE id = p_user_id;
END;
$$;

-- 5. Admin Set User Role Procedure
CREATE OR REPLACE FUNCTION set_user_role(p_user_id UUID, p_role VARCHAR(20))
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    v_super_count INT;
    v_current_role VARCHAR(20);
BEGIN
    IF NOT is_superadmin() THEN
        RAISE EXCEPTION 'Access Denied: Superadmin role required.';
    END IF;

    SELECT role INTO v_current_role FROM public.app_user WHERE id = p_user_id;

    -- Guard against demoting last active Superadmin
    IF v_current_role = 'superadmin' AND p_role != 'superadmin' THEN
        SELECT COUNT(*) INTO v_super_count FROM public.app_user WHERE role = 'superadmin' AND status = 'active';
        IF v_super_count <= 1 THEN
            RAISE EXCEPTION 'Cannot demote user: system must retain at least one active Superadmin.';
        END IF;
    END IF;

    UPDATE public.app_user
    SET role = p_role, updated_at = now()
    WHERE id = p_user_id;
END;
$$;

-- 6. Admin Grant / Revoke Rights Catalog Mapping
CREATE OR REPLACE FUNCTION set_user_rights(p_user_id UUID, p_rights TEXT[])
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    r TEXT;
BEGIN
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Access Denied: Superadmin/Admin role required.';
    END IF;

    -- Clear existing explicit user rights
    DELETE FROM public.user_right WHERE user_id = p_user_id;
    DELETE FROM public.user_module WHERE user_id = p_user_id;

    -- Re-insert rights and auto-infer modules
    FOREACH r IN ARRAY p_rights
    LOOP
        INSERT INTO public.user_right (user_id, right_code)
        VALUES (p_user_id, r)
        ON CONFLICT DO NOTHING;

        INSERT INTO public.user_module (user_id, module_code)
        SELECT p_user_id, module_code 
        FROM public.right_catalog 
        WHERE right_code = r
        ON CONFLICT DO NOTHING;
    END LOOP;
END;
$$;