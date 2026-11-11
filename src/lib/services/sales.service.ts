// ==========================================
// SALES SERVICE
// ==========================================

// getSales() - list sales headers with calculated totals (reads v_sale_total)
// getSaleByTransNo() - fetch single sales header by transNo
// getSaleDetails() - require SDTL_VIEW right; fetch detail lines (v_saleline) for a sale
// getSalesLookups() - fetch lightweight active customer, employee, and product dropdown items for sales form

// createSale() - RPC create_sale wrapper (auto-generates transNo, validates active employee, fetches effective price on salesDate, inserts header + lines in single transaction)
// updateSaleHeader() - update customer/employee/salesDate header details
// softDeleteSale() - soft-delete sales header and details (retains historical links)
// restoreSale() - restore sales header and detail lines

// addSaleLine() - insert new line item using price in force at salesDate
// updateSaleLine() - RPC update_sale_line wrapper (adjusts quantity, verifies total >= sum of active payments)
// softDeleteSaleLine() - RPC delete_sale_line wrapper (soft-deletes line, verifies total >= sum of active payments)
// restoreSaleLine() - restore detail line item