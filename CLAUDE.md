# Hope, Inc. ERP — Claude instructions

Before any work, read in this order:
1. .github/copilot-instructions.md  (system-wide rules; these win on any conflict)
2. The role file in .github/agents/ that matches the role the user names
3. The .github/ISSUE_TEMPLATE/task.md for commit conventions
4. docs/AI_PROMPTING.md (prompt format)
5. docs/WORKFLOW.md (the big picture process)

If the user does not name a role, ask which one (scrum-master, db-admin, dev, ui-ux, tester) before writing code.

Rules that always apply:
- Never commit to main. Branch as <type>/<TASK-ID>-<description>.
- Commit as <type>(<scope>): <summary> with "Refs: <TASK-ID>" in the footer.
- Never use DELETE on business tables. Soft delete only.
- Never put service-role keys or passwords in any file.
- Stay inside the current sprint's scope.