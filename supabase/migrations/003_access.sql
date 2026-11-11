-- =====================================================================
-- 003_access.sql : Access Tables, Module Catalog, & Auth Sync Trigger
-- =====================================================================

-- 1. App User Table (linked 1:1 with Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.app_user (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email       VARCHAR(255) NOT NULL UNIQUE,
    firstname   VARCHAR(50) NOT NULL,
    lastname    VARCHAR(50) NOT NULL,
    role        VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('superadmin', 'admin', 'user')),
    status      VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'blocked')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. System Module Catalog
CREATE TABLE IF NOT EXISTS public.module (
    module_code VARCHAR(10) PRIMARY KEY,
    module_name VARCHAR(50) NOT NULL
);

-- 3. System Right Catalog
CREATE TABLE IF NOT EXISTS public.right_catalog (
    right_code  VARCHAR(30) PRIMARY KEY,
    module_code VARCHAR(10) NOT NULL REFERENCES public.module(module_code) ON DELETE CASCADE,
    description VARCHAR(100) NOT NULL
);

-- 4. User Granted Modules Junction
CREATE TABLE IF NOT EXISTS public.user_module (
    user_id     UUID NOT NULL REFERENCES public.app_user(id) ON DELETE CASCADE,
    module_code VARCHAR(10) NOT NULL REFERENCES public.module(module_code) ON DELETE CASCADE,
    PRIMARY KEY (user_id, module_code)
);

-- 5. User Granted Rights Junction
CREATE TABLE IF NOT EXISTS public.user_right (
    user_id    UUID NOT NULL REFERENCES public.app_user(id) ON DELETE CASCADE,
    right_code VARCHAR(30) NOT NULL REFERENCES public.right_catalog(right_code) ON DELETE CASCADE,
    PRIMARY KEY (user_id, right_code)
);

-- Seed System Modules
INSERT INTO public.module (module_code, module_name) VALUES
    ('CUST',  'Customer Management'),
    ('PROD',  'Product Catalog'),
    ('PRICE', 'Price History Management'),
    ('EMP',   'Employee Records'),
    ('DEPT',  'Department Management'),
    ('JOB',   'Job Titles'),
    ('JHIST', 'Job History'),
    ('SALE',  'Sales Orders'),
    ('SDTL',  'Sales Line Items'),
    ('PAY',   'Payments & Receipts'),
    ('REP',   'Reports & Analytics'),
    ('ADM',   'System Administration')
ON CONFLICT (module_code) DO NOTHING;

-- Seed System Rights Catalog (40 distinct permissions)
INSERT INTO public.right_catalog (right_code, module_code, description) VALUES
    -- Customers
    ('CUST_VIEW', 'CUST', 'View customer list and details'),
    ('CUST_ADD',  'CUST', 'Create new customer record'),
    ('CUST_EDIT', 'CUST', 'Edit existing customer record'),
    ('CUST_DEL',  'CUST', 'Soft-delete customer record'),
    -- Products
    ('PROD_VIEW', 'PROD', 'View product catalog'),
    ('PROD_ADD',  'PROD', 'Add new product code'),
    ('PROD_EDIT', 'PROD', 'Edit product details'),
    ('PROD_DEL',  'PROD', 'Soft-delete product item'),
    -- Price History
    ('PRICE_VIEW', 'PRICE', 'View effective price history'),
    ('PRICE_ADD',  'PRICE', 'Add new price entry'),
    ('PRICE_EDIT', 'PRICE', 'Edit price entry'),
    ('PRICE_DEL',  'PRICE', 'Soft-delete price entry'),
    -- Employees
    ('EMP_VIEW', 'EMP', 'View employee details'),
    ('EMP_ADD',  'EMP', 'Add new employee'),
    ('EMP_EDIT', 'EMP', 'Edit employee record'),
    ('EMP_DEL',  'EMP', 'Soft-delete employee record'),
    -- Departments
    ('DEPT_VIEW', 'DEPT', 'View department list'),
    ('DEPT_ADD',  'DEPT', 'Create department'),
    ('DEPT_EDIT', 'DEPT', 'Edit department details'),
    ('DEPT_DEL',  'DEPT', 'Soft-delete department'),
    -- Jobs
    ('JOB_VIEW', 'JOB', 'View job catalog'),
    ('JOB_ADD',  'JOB', 'Add job position'),
    ('JOB_EDIT', 'JOB', 'Edit job position'),
    ('JOB_DEL',  'JOB', 'Soft-delete job position'),
    -- Job History
    ('JHIST_VIEW', 'JHIST', 'View career timeline and salary'),
    ('JHIST_ADD',  'JHIST', 'Add job history entry'),
    ('JHIST_EDIT', 'JHIST', 'Edit job history entry'),
    ('JHIST_DEL',  'JHIST', 'Soft-delete job history entry'),
    -- Sales Header
    ('SALE_VIEW', 'SALE', 'View sales orders'),
    ('SALE_ADD',  'SALE', 'Create new sales order'),
    ('SALE_EDIT', 'SALE', 'Edit sales order header'),
    ('SALE_DEL',  'SALE', 'Soft-delete sales order'),
    -- Sales Detail
    ('SDTL_VIEW', 'SDTL', 'View transaction line items'),
    ('SDTL_ADD',  'SDTL', 'Add line item to order'),
    ('SDTL_EDIT', 'SDTL', 'Edit line item quantity'),
    ('SDTL_DEL',  'SDTL', 'Soft-delete transaction line item'),
    -- Payments
    ('PAY_VIEW', 'PAY', 'View payment receipts'),
    ('PAY_ADD',  'PAY', 'Record new payment'),
    ('PAY_EDIT', 'PAY', 'Update payment details'),
    ('PAY_DEL',  'PAY', 'Soft-delete payment receipt'),
    -- Reports
    ('REP_TOPCUST',    'REP', 'View Top Customers Report'),
    ('REP_PRODMASTER', 'REP', 'View Product Master List Report'),
    ('REP_TOPPROD',    'REP', 'View Top Selling Products Report'),
    ('REP_ACTEMP',     'REP', 'View Active Employees Report'),
    ('REP_ALLEMP',     'REP', 'View All Employees Report'),
    ('REP_JOBHIST',    'REP', 'View Employee Job History Report'),
    ('REP_TOPSALES',   'REP', 'View Top Sales Report'),
    -- Admin
    ('ADM_USERS',  'ADM', 'Manage user approval & status'),
    ('ADM_RIGHTS', 'ADM', 'Assign user permissions & roles'),
    ('ADM_AUDIT',  'ADM', 'View complete system audit logs')
ON CONFLICT (right_code) DO NOTHING;

-- Trigger Function: Auto-provision app_user on Supabase Auth Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    INSERT INTO public.app_user (id, email, firstname, lastname, role, status)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'firstname', NEW.raw_user_meta_data->>'first_name', 'Firstname'),
        COALESCE(NEW.raw_user_meta_data->>'lastname',  NEW.raw_user_meta_data->>'last_name',  'Lastname'),
        'user',
        'pending'
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

-- Drop existing trigger if present
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger on auth.users table
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();