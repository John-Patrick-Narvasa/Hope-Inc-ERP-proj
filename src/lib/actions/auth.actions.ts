// ==========================================
// AUTHENTICATION ACTIONS
// ==========================================
// import auth schema validation rules

// ACCOUNT SESSION & ACCESS
// registerAction - handle new user registration (creates user with 'pending' status)
// loginAction - verify credentials, validate active status, and initiate session
// logoutAction - revoke session and clear tokens
// getSessionAction - fetch current authenticated session context

// PASSWORD & SECURITY MANAGEMENT
// requestPasswordResetAction - initiate reset flow (sends email link via provider)
// resetPasswordAction - update password using recovery token
// setPasswordAction - set initial password for invited/provisioned users

// OAUTH INTEGRATION
// signInWithGoogleAction - initiate Google OAuth PKCE flow
// handleGoogleCallbackAction - handle OAuth callback redirect and provisioning check