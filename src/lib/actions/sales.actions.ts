// ==========================================
// SALES ACTIONS
// ==========================================
// import sales schema validation rules

// TRANSACTION HEADER ACTIONS
// createSaleAction - require SALE_ADD right; invoke create_sale RPC to create header and lines atomically
// updateSaleHeaderAction - require SALE_EDIT right; update sale header info
// deleteSaleAction - require SALE_DEL right; soft-delete sale transaction
// restoreSaleAction - require Admin/Superadmin role & SALE_DEL right; restore soft-deleted sale

// LINE DETAIL ACTIONS
// addSaleLineAction - require SDTL_ADD right; add new product line to existing sale
// updateSaleLineAction - require SDTL_EDIT right; invoke update_sale_line RPC (prevents total < active payments)
// deleteSaleLineAction - require SDTL_DEL right; invoke delete_sale_line RPC (soft-delete line)
// restoreSaleLineAction - require Admin/Superadmin role & SDTL_DEL right; restore detail line