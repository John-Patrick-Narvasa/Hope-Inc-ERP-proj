// ==========================================
// PAYMENT SERVICE
// ==========================================

// getPayments() - require PAY_VIEW right; list payment receipts
// getPaymentByOrNo() - fetch details of a specific payment receipt
// getSaleBalance() - query v_sale_balance to determine open balance on a sale transaction
// getCustomerBalances() - query v_customer_balance for aggregated customer unpaid amounts
// recordPayment() - RPC record_payment wrapper (locks sale row FOR UPDATE, asserts amount <= open balance and payDate >= salesDate)
// updatePayment() - RPC update_payment wrapper (re-evaluates balance limits upon modification)
// softDeletePayment() - soft-delete receipt and recalculate sale balance
// restorePayment() - restore receipt (re-checks that total payments do not exceed sale total)