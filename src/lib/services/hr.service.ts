// ==========================================
// HUMAN RESOURCES SERVICE
// ==========================================

// DEPARTMENT & JOB LOOKUPS
// getDepartments() - list active/all departments
// createDepartment() / updateDepartment() / softDeleteDepartment() / restoreDepartment()
// getJobs() - list active/all job titles
// createJob() / updateJob() / softDeleteJob() / restoreJob()

// EMPLOYEE MANAGEMENT
// getEmployees() - list employees (masks birthdate based on JHIST_VIEW permission)
// getEmployeeByEmpNo() - fetch single employee details
// getEmployeeProfileTimeline() - fetch employee career timeline and job history
// createEmployee() - generate empNo sequence and insert employee record
// updateEmployee() - update employee info (validates sepDate >= hireDate rule)
// softDeleteEmployee() - soft-delete employee record
// restoreEmployee() - restore soft-deleted employee

// JOB HISTORY MANAGEMENT
// getEmployeeJobHistory() - list history records for employee (masks salary unless JHIST_VIEW held)
// addJobHistory() - insert new job history row
// updateJobHistory() - edit salary or position assignment
// softDeleteJobHistory() - soft-delete job history record
// restoreJobHistory() - restore job history record