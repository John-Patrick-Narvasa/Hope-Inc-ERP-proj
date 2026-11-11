// reports.service.ts (Read-Only Service)
// getTopCustomersReport() - require REP_TOPCUST right; execute top N customers query by sales volume
// getProductMasterListReport() - require REP_PRODMASTER right; list active products with current pricing
// getTopProductsReport() - require REP_TOPPROD right; calculate top selling products by quantity & amount
// getActiveEmployeesReport() - require REP_ACTEMP right; list current active employees (sepDate is null)
// getAllEmployeesReport() - require REP_ALLEMP right; list all active & separated employees
// getEmployeeJobHistoryReport() - require REP_JOBHIST & JHIST_VIEW rights; detailed career and salary history
// getTopSalesReport() - require REP_TOPSALES right; list top individual sales transactions in date range