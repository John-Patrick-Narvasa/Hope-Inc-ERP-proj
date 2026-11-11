// ==========================================
// CUSTOMER SERVICE
// ==========================================

// getCustomers() - list customers filtered by role visibility (Active only for User; All for Admin)
// getCustomerByCustNo() - retrieve single customer by primary key
// createCustomer() - generate custNo sequence, validate FK rules, and insert row
// updateCustomer() - update customer details and write stamp audit log
// softDeleteCustomer() - set is_deleted = true and write DELETE stamp log
// restoreCustomer() - set is_deleted = false and write RESTORE stamp log