-- =====================================================================
-- 010_seed_fixes.sql : Seed Data Cleanups, Baseline Pricing, & User Rights
-- =====================================================================

-- 1. Ensure all seeded rows have non-null stamps
UPDATE public.employee    SET stamp = COALESCE(stamp, audit_stamp('ADD')) WHERE stamp IS NULL;
UPDATE public.department  SET stamp = COALESCE(stamp, audit_stamp('ADD')) WHERE stamp IS NULL;
UPDATE public.job         SET stamp = COALESCE(stamp, audit_stamp('ADD')) WHERE stamp IS NULL;
UPDATE public.jobhistory  SET stamp = COALESCE(stamp, audit_stamp('ADD')) WHERE stamp IS NULL;
UPDATE public.customer    SET stamp = COALESCE(stamp, audit_stamp('ADD')) WHERE stamp IS NULL;
UPDATE public.product     SET stamp = COALESCE(stamp, audit_stamp('ADD')) WHERE stamp IS NULL;
UPDATE public.pricehist   SET stamp = COALESCE(stamp, audit_stamp('ADD')) WHERE stamp IS NULL;
UPDATE public.sales       SET stamp = COALESCE(stamp, audit_stamp('ADD')) WHERE stamp IS NULL;
UPDATE public.salesdetail SET stamp = COALESCE(stamp, audit_stamp('ADD')) WHERE stamp IS NULL;
UPDATE public.payment     SET stamp = COALESCE(stamp, audit_stamp('ADD')) WHERE stamp IS NULL;

-- 2. Ensure every product has a baseline price history entry as of 2000-01-01
--    (Prevents get_price_as_of() from returning 0 for early sales transactions)
INSERT INTO public.pricehist (effdate, prodcode, unitprice)
SELECT '2000-01-01'::DATE, p.prodcode, 10.00
FROM public.product p
WHERE NOT EXISTS (
    SELECT 1 FROM public.pricehist ph WHERE ph.prodcode = p.prodcode
)
ON CONFLICT (effdate, prodcode) DO NOTHING;

-- 3. Provision Fixed UUID Test Accounts in app_user
--    (These mirror accounts created in Supabase Auth via Dashboard or API)
INSERT INTO public.app_user (id, email, firstname, lastname, role, status) VALUES
    ('d8fc60e4-0583-4e23-b092-82eb323c066d'::uuid, 'superadmin@hope.com', 'System', 'Superadmin', 'superadmin', 'active'),
    ('2671915e-c122-48e7-b25d-777aceb9d7c9'::uuid, 'admin.sales@hope.com', 'Sales', 'Manager',    'admin',      'active'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'user.clerk@hope.com',   'Clerk', 'User',       'user',       'active')
ON CONFLICT (id) DO UPDATE 
SET role = EXCLUDED.role, status = EXCLUDED.status, firstname = EXCLUDED.firstname, lastname = EXCLUDED.lastname;

-- 4. Grant explicit permission catalog to standard test user (user.clerk@hope.com)
--    Gives clerk permissions to view catalog, manage customers, create sales, and process payments
DELETE FROM public.user_right  WHERE user_id = '097bb0a8-39b3-4558-9420-0f0b93a497de';
DELETE FROM public.user_module WHERE user_id = '097bb0a8-39b3-4558-9420-0f0b93a497de';

INSERT INTO public.user_right (user_id, right_code) VALUES
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'CUST_VIEW'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'CUST_ADD'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'CUST_EDIT'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'PROD_VIEW'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'PRICE_VIEW'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'EMP_VIEW'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'SALE_VIEW'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'SALE_ADD'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'SDTL_VIEW'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'SDTL_ADD'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'PAY_VIEW'),
    ('097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, 'PAY_ADD')
ON CONFLICT DO NOTHING;

-- Auto-assign corresponding modules for granted rights
INSERT INTO public.user_module (user_id, module_code)
SELECT DISTINCT '097bb0a8-39b3-4558-9420-0f0b93a497de'::uuid, module_code
FROM public.right_catalog
WHERE right_code IN (
    'CUST_VIEW','CUST_ADD','CUST_EDIT','PROD_VIEW','PRICE_VIEW',
    'EMP_VIEW','SALE_VIEW','SALE_ADD','SDTL_VIEW','SDTL_ADD','PAY_VIEW','PAY_ADD'
)
ON CONFLICT DO NOTHING;