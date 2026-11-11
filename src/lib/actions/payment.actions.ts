// ==========================================
// PAYMENT ACTIONS
// ==========================================
// import payment schema validation rules

// RECEIPT & PAYMENT TRANSACTIONS
// recordPaymentAction - require PAY_ADD right; execute record_payment RPC (verifies balance & payDate)
// updatePaymentAction - require PAY_EDIT right; execute update_payment RPC
// deletePaymentAction - require PAY_DEL right; soft-delete official receipt (OR)
// restorePaymentAction - require Admin/Superadmin role & PAY_DEL right; restore payment record