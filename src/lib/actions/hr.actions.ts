// ==========================================
// HUMAN RESOURCES ACTIONS
// ==========================================
// import HR schema validation rules

// DEPARTMENT ACTIONS
// createDepartmentAction - require DEPT_ADD right; create new department record
// updateDepartmentAction - require DEPT_EDIT right; modify department details
// deleteDepartmentAction - require DEPT_DEL right; soft-delete department
// restoreDepartmentAction - require Admin/Superadmin role & DEPT_DEL right; restore department

// JOB ACTIONS
// createJobAction - require JOB_ADD right; add new job designation
// updateJobAction - require JOB_EDIT right; edit job description
// deleteJobAction - require JOB_DEL right; soft-delete job row
// restoreJobAction - require Admin/Superadmin role & JOB_DEL right; restore job row

// EMPLOYEE ACTIONS
// createEmployeeAction - require EMP_ADD right; register new employee
// updateEmployeeAction - require EMP_EDIT right; update personnel profile
// deleteEmployeeAction - require EMP_DEL right; soft-delete employee record
// restoreEmployeeAction - require Admin/Superadmin role & EMP_DEL right; restore employee record

// JOB HISTORY ACTIONS
// addJobHistoryAction - require JHIST_ADD right; record promotion, transfer, or salary adjustment
// updateJobHistoryAction - require JHIST_EDIT right; modify job history entry
// deleteJobHistoryAction - require JHIST_DEL right; soft-delete job history entry
// restoreJobHistoryAction - require Admin/Superadmin role & JHIST_DEL right; restore entry