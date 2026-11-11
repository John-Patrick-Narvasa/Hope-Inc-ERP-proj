// admin.actions.ts
// approveUserAccountAction - require Superadmin role; activate pending user
// setUserBlockStatusAction - require Admin/Superadmin role; block or unblock account
// setUserRoleAction - require Superadmin role; change role (guarded against demoting last Superadmin)
// setUserRightsAction - require Admin/Superadmin role; update granted modules & rights (guarded by caller's own permissions)