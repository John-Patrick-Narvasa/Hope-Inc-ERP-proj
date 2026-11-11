// ==========================================
// PRODUCT SERVICE
// ==========================================

// getProducts() - fetch products with computed current price (latest non-future effective price)
// getProductByCode() - retrieve product details
// createProduct() - insert new product record with status and stamp
// updateProduct() - update description/unit and log stamp
// softDeleteProduct() - check active price child dependency before soft-deleting
// restoreProduct() - restore inactive product record

// getPriceHistory() - list price entries for a given prodCode
// getPriceAsOfDate() - calculate effective unit price for a specific product as of sale date
// addProductPrice() - RPC add_price wrapper (prevents backdated price conflicts with past sales)
// updateProductPrice() - update price entry with historical conflict checks
// softDeleteProductPrice() - soft-delete price history row
// restoreProductPrice() - restore price history row