-- =====================================================================
-- 007_views_fn.sql : Effective Price Calculator & Computed Financial Views
-- =====================================================================

-- 1. Helper: Calculate unit price in force for product as of specific transaction date
CREATE OR REPLACE FUNCTION get_price_as_of(p_prodcode VARCHAR, p_as_of_date DATE)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_price DECIMAL(10,2);
BEGIN
    SELECT unitprice INTO v_price
    FROM public.pricehist
    WHERE prodcode = p_prodcode 
      AND effdate <= p_as_of_date 
      AND NOT is_deleted
    ORDER BY effdate DESC
    LIMIT 1;

    IF v_price IS NULL THEN
        -- Fallback to oldest known price if date precedes initial price history
        SELECT unitprice INTO v_price
        FROM public.pricehist
        WHERE prodcode = p_prodcode AND NOT is_deleted
        ORDER BY effdate ASC
        LIMIT 1;
    END IF;

    RETURN COALESCE(v_price, 0.00);
END;
$$;

-- 2. View: Sales Detail Line with Effective Unit Price and Extended Amount
CREATE OR REPLACE VIEW v_saleline WITH (security_invoker = true) AS
SELECT 
    sd.transno,
    sd.prodcode,
    p.description,
    p.unit,
    sd.quantity,
    get_price_as_of(sd.prodcode, s.salesdate) AS unitprice,
    ROUND(sd.quantity * get_price_as_of(sd.prodcode, s.salesdate), 2) AS amount,
    sd.is_deleted,
    sd.stamp
FROM public.salesdetail sd
JOIN public.sales s ON sd.transno = s.transno
JOIN public.product p ON sd.prodcode = p.prodcode;

-- 3. View: Aggregated Total Sales Header Amounts
CREATE OR REPLACE VIEW v_sale_total WITH (security_invoker = true) AS
SELECT 
    s.transno,
    s.salesdate,
    s.custno,
    s.empno,
    COALESCE(SUM(vl.amount), 0.00) AS total_amount,
    s.is_deleted,
    s.stamp
FROM public.sales s
LEFT JOIN public.v_saleline vl ON s.transno = vl.transno AND NOT vl.is_deleted
GROUP BY s.transno, s.salesdate, s.custno, s.empno, s.is_deleted, s.stamp;

-- 4. View: Sales Balances (Total Amount vs Paid Amount vs Open Balance)
CREATE OR REPLACE VIEW v_sale_balance WITH (security_invoker = true) AS
SELECT 
    st.transno,
    st.salesdate,
    st.custno,
    st.empno,
    st.total_amount,
    COALESCE(p.paid_amount, 0.00) AS paid_amount,
    ROUND(st.total_amount - COALESCE(p.paid_amount, 0.00), 2) AS open_balance,
    st.is_deleted,
    st.stamp
FROM public.v_sale_total st
LEFT JOIN (
    SELECT transno, SUM(amount) AS paid_amount
    FROM public.payment
    WHERE NOT is_deleted
    GROUP BY transno
) p ON st.transno = p.transno;

-- 5. View: Customer Balance Aggregation
CREATE OR REPLACE VIEW v_customer_balance WITH (security_invoker = true) AS
SELECT 
    c.custno,
    c.custname,
    c.payterm,
    COALESCE(SUM(sb.total_amount), 0.00) AS total_sales,
    COALESCE(SUM(sb.paid_amount), 0.00)  AS total_paid,
    COALESCE(SUM(sb.open_balance), 0.00) AS total_balance,
    c.is_deleted
FROM public.customer c
LEFT JOIN public.v_sale_balance sb ON c.custno = sb.custno AND NOT sb.is_deleted
GROUP BY c.custno, c.custname, c.payterm, c.is_deleted;