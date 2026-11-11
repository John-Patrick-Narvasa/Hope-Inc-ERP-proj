// admin.service.ts
// getUsersList() - list user accounts based on role scope (Admin sees role=user; Superadmin sees all)
// approveUserAccount() - change status from 'pending' to 'active'
// setUserBlockStatus() - update status ('blocked' / 'active') with last Superadmin protection
// setUserRole() - modify user role with last Superadmin protection
// getUserRightsCatalog() - fetch all 40 system rights grouped by module
// getUserAssignedRights() - fetch specific user's granted modules and rights
// updateUserRights() - execute atomic diff, update user_module & user_right tables, and write audit trail
// getAuditLogs() - require Superadmin role; query full system audit trail (audit_log)