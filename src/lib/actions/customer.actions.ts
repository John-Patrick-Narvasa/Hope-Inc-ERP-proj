// ==========================================
// CUSTOMER ACTIONS
// ==========================================
// import customer schema validation rules

// CUSTOMER CRUD ACTIONS
// createCustomerAction - require CUST_ADD right; insert new customer record
// updateCustomerAction - require CUST_EDIT right; update customer details
// deleteCustomerAction - require CUST_DEL right; soft-delete customer (is_deleted = true)
// restoreCustomerAction - require Admin/Superadmin role & CUST_DEL right; restore soft-deleted customer