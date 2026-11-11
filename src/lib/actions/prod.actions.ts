// ==========================================
// PRODUCT ACTIONS
// ==========================================
// import product & price history schema validation rules

// PRODUCT CATALOG MANAGEMENT
// createProductAction - require PROD_ADD right; add new product item
// updateProductAction - require PROD_EDIT right; edit description or unit
// deleteProductAction - require PROD_DEL right; soft-delete product (checks for active price history)
// restoreProductAction - require Admin/Superadmin role & PROD_DEL right; restore soft-deleted product

// PRICE HISTORY MANAGEMENT
// addPriceAction - require PRICE_ADD right; invoke add_price RPC to attach effective price
// updatePriceAction - require PRICE_EDIT right; update price history entry
// deletePriceAction - require PRICE_DEL right; soft-delete price history record
// restorePriceAction - require Admin/Superadmin role & PRICE_DEL right; restore price history row