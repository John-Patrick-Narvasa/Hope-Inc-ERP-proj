// ==========================================
// SALES SCHEMA VALIDATION
// ==========================================

// Transaction Header Schema (salesDate, custNo, empNo)
// Transaction Line Detail Schema (prodCode, quantity)
// Create Sale Schema (header: Transaction Header Schema, lines: array of Line Detail Schema)

// Update Sale Header Schema (transNo, salesDate, custNo, empNo)
// Soft Delete / Restore Sale Schema (transNo)

// Add Sale Line Schema (transNo, prodCode, quantity)
// Update Sale Line Schema (transNo, prodCode, quantity)
// Soft Delete Sale Line Schema (transNo, prodCode)
// Restore Sale Line Schema (transNo, prodCode)