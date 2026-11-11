-- =====================================================================
-- 005_rls.sql : Row Level Security Enforcement
-- =====================================================================

-- Enable RLS on core entities and access tables
ALTER TABLE public.customer    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pricehist   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.department  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobhistory  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.salesdetail ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_user    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log   ENABLE ROW LEVEL SECURITY;

-- Macro macro policies for App User table
CREATE POLICY app_user_self_select ON public.app_user
    FOR SELECT USING (id = auth.uid() OR is_admin());

CREATE POLICY app_user_admin_update ON public.app_user
    FOR UPDATE USING (is_admin());

-- Generic Read Policies: Active users read non-deleted rows; Admins read all
CREATE POLICY cust_select ON public.customer FOR SELECT
    USING (is_active() AND (is_admin() OR (has_right('CUST_VIEW') AND NOT is_deleted)));

CREATE POLICY prod_select ON public.product FOR SELECT
    USING (is_active() AND (is_admin() OR (has_right('PROD_VIEW') AND NOT is_deleted)));

CREATE POLICY price_select ON public.pricehist FOR SELECT
    USING (is_active() AND (is_admin() OR (has_right('PRICE_VIEW') AND NOT is_deleted)));

CREATE POLICY emp_select ON public.employee FOR SELECT
    USING (is_active() AND (is_admin() OR (has_right('EMP_VIEW') AND NOT is_deleted)));

CREATE POLICY dept_select ON public.department FOR SELECT
    USING (is_active() AND (is_admin() OR (has_right('DEPT_VIEW') AND NOT is_deleted)));

CREATE POLICY job_select ON public.job FOR SELECT
    USING (is_active() AND (is_admin() OR (has_right('JOB_VIEW') AND NOT is_deleted)));

CREATE POLICY jhist_select ON public.jobhistory FOR SELECT
    USING (is_active() AND (is_admin() OR (has_right('JHIST_VIEW') AND NOT is_deleted)));

CREATE POLICY sale_select ON public.sales FOR SELECT
    USING (is_active() AND (is_admin() OR (has_right('SALE_VIEW') AND NOT is_deleted)));

CREATE POLICY sdtl_select ON public.salesdetail FOR SELECT
    USING (is_active() AND (is_admin() OR (has_right('SDTL_VIEW') AND NOT is_deleted)));

CREATE POLICY pay_select ON public.payment FOR SELECT
    USING (is_active() AND (is_admin() OR (has_right('PAY_VIEW') AND NOT is_deleted)));

CREATE POLICY audit_select ON public.audit_log FOR SELECT
    USING (is_superadmin() OR has_right('ADM_AUDIT'));

-- Generic Insert Policies
CREATE POLICY cust_insert  ON public.customer    FOR INSERT WITH CHECK (has_right('CUST_ADD'));
CREATE POLICY prod_insert  ON public.product     FOR INSERT WITH CHECK (has_right('PROD_ADD'));
CREATE POLICY price_insert ON public.pricehist   FOR INSERT WITH CHECK (has_right('PRICE_ADD'));
CREATE POLICY emp_insert   ON public.employee    FOR INSERT WITH CHECK (has_right('EMP_ADD'));
CREATE POLICY dept_insert  ON public.department  FOR INSERT WITH CHECK (has_right('DEPT_ADD'));
CREATE POLICY job_insert   ON public.job         FOR INSERT WITH CHECK (has_right('JOB_ADD'));
CREATE POLICY jhist_insert ON public.jobhistory  FOR INSERT WITH CHECK (has_right('JHIST_ADD'));
CREATE POLICY sale_insert  ON public.sales       FOR INSERT WITH CHECK (has_right('SALE_ADD'));
CREATE POLICY sdtl_insert  ON public.salesdetail FOR INSERT WITH CHECK (has_right('SDTL_ADD'));
CREATE POLICY pay_insert   ON public.payment     FOR INSERT WITH CHECK (has_right('PAY_ADD'));

-- Generic Update Policies
CREATE POLICY cust_update  ON public.customer    FOR UPDATE USING (has_right('CUST_EDIT') OR has_right('CUST_DEL'));
CREATE POLICY prod_update  ON public.product     FOR UPDATE USING (has_right('PROD_EDIT') OR has_right('PROD_DEL'));
CREATE POLICY price_update ON public.pricehist   FOR UPDATE USING (has_right('PRICE_EDIT') OR has_right('PRICE_DEL'));
CREATE POLICY emp_update   ON public.employee    FOR UPDATE USING (has_right('EMP_EDIT') OR has_right('EMP_DEL'));
CREATE POLICY dept_update  ON public.department  FOR UPDATE USING (has_right('DEPT_EDIT') OR has_right('DEPT_DEL'));
CREATE POLICY job_update   ON public.job         FOR UPDATE USING (has_right('JOB_EDIT') OR has_right('JOB_DEL'));
CREATE POLICY jhist_update ON public.jobhistory  FOR UPDATE USING (has_right('JHIST_EDIT') OR has_right('JHIST_DEL'));
CREATE POLICY sale_update  ON public.sales       FOR UPDATE USING (has_right('SALE_EDIT') OR has_right('SALE_DEL'));
CREATE POLICY sdtl_update  ON public.salesdetail FOR UPDATE USING (has_right('SDTL_EDIT') OR has_right('SDTL_DEL'));
CREATE POLICY pay_update   ON public.payment     FOR UPDATE USING (has_right('PAY_EDIT') OR has_right('PAY_DEL'));