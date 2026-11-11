-- =====================================================================
-- 006_ids.sql : Sequence Generators for Formatted Identifiers
-- =====================================================================

-- Next Customer Number: C0001 format
CREATE OR REPLACE FUNCTION next_custno() RETURNS VARCHAR(5)
LANGUAGE plpgsql AS $$
DECLARE
    v_max INT;
BEGIN
    SELECT COALESCE(MAX(SUBSTRING(custno FROM 2)::INT), 0) + 1 INTO v_max FROM public.customer;
    RETURN 'C' || LPAD(v_max::TEXT, 4, '0');
END;
$$;

-- Next Employee Number: 00001 format
CREATE OR REPLACE FUNCTION next_empno() RETURNS VARCHAR(5)
LANGUAGE plpgsql AS $$
DECLARE
    v_max INT;
BEGIN
    SELECT COALESCE(MAX(empno::INT), 0) + 1 INTO v_max FROM public.employee;
    RETURN LPAD(v_max::TEXT, 5, '0');
END;
$$;

-- Next Transaction Number: TR000001 format
CREATE OR REPLACE FUNCTION next_transno() RETURNS VARCHAR(8)
LANGUAGE plpgsql AS $$
DECLARE
    v_max INT;
BEGIN
    SELECT COALESCE(MAX(SUBSTRING(transno FROM 3)::INT), 0) + 1 INTO v_max FROM public.sales;
    RETURN 'TR' || LPAD(v_max::TEXT, 6, '0');
END;
$$;

-- Next Official Receipt Number: OR000001 format
CREATE OR REPLACE FUNCTION next_orno() RETURNS VARCHAR(8)
LANGUAGE plpgsql AS $$
DECLARE
    v_max INT;
BEGIN
    SELECT COALESCE(MAX(SUBSTRING(orno FROM 3)::INT), 0) + 1 INTO v_max FROM public.payment;
    RETURN 'OR' || LPAD(v_max::TEXT, 6, '0');
END;
$$;

-- Next Product Code: AD0001 / custom prefix format
CREATE OR REPLACE FUNCTION next_prodcode(p_prefix VARCHAR DEFAULT 'PR') RETURNS VARCHAR(6)
LANGUAGE plpgsql AS $$
DECLARE
    v_max INT;
BEGIN
    SELECT COALESCE(MAX(SUBSTRING(prodcode FROM 3)::INT), 0) + 1 
    FROM public.product 
    WHERE prodcode LIKE p_prefix || '%' INTO v_max;
    
    RETURN UPPER(p_prefix) || LPAD(v_max::TEXT, 4, '0');
END;
$$;