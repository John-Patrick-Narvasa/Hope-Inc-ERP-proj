# AI Prompting Format — Hope, Inc. ERP

> Save as `docs/AI_PROMPTING.md`. Everyone uses the same skeleton so that prompts are reviewable, repeatable and traceable to a task.

## 1. The universal skeleton

Every prompt has these seven fields, in this order. Delete a field only if it truly does not apply.

```
TASK:        S{n}-{ROLE}-{nn}  (one task per prompt)
GOAL:        One sentence: what must exist when we are done.
CONTEXT:     Tables, files, rights, accounts involved. PASTE the real schema/code/error, do not describe it.
CONSTRAINTS: Sprint scope, rules from copilot-instructions.md that apply, things NOT to touch.
ACCEPTANCE:  Given / When / Then, copied from the issue (max ~5).
OUTPUT:      Exactly what to return (files, tests, steps, format).
ASK FIRST:   Questions the AI must answer back before writing anything, if a requirement is unclear.
```

## 2. Session starter (first message of every new chat)

```
Read .github/copilot-instructions.md and your role file in .github/agents/.
Before doing anything, list the three rules from those files that matter most for task <TASK-ID>,
and list any assumption you would have to make. Wait for my confirmation.
```

This makes the AI show its understanding, and any misunderstanding costs you one message instead of one pull request.

## 3. Ground rules

1. **One task, one prompt, one PR.** If the answer needs "and also", open another task.
2. **Paste artifacts, not summaries.** "The customer table" is a guess; the `CREATE TABLE` text is a fact.
3. **Name the account.** Say whether behaviour is for `anon`, pending, `user`, `admin` or `superadmin`.
4. **Demand the verification.** Every prompt asks for how to prove it works, including one case that should fail.
5. **Never paste secrets.** No `.env` values, service-role keys, passwords or real personal data. Use seed data only.
6. **You own the output.** AI text is a draft. Run it, read it, and be able to explain every line in review.
7. **Disclose in the PR.** Add one line: `AI assistance: yes — prompt saved in docs/prompts/<TASK-ID>.md` (or `no`). Keep the prompt that produced the final code.
8. **Fix the prompt, not the output.** If the answer is wrong, edit your prompt and rerun; do not patch five mistakes by hand and lose the trail.

## 4. Reviewing AI output (all roles, before committing)

- [ ] Does it stay inside the task and the current sprint?
- [ ] Any table, column, right code or function that is not in the ERD or §5 list? (Invented names are the most common failure.)
- [ ] Is authorization enforced on the server and in RLS, not only in the UI?
- [ ] Any `DELETE`, `MAX()+1`, float money, stored total/balance, or hard-coded superadmin?
- [ ] Any secret, key or password in the diff?
- [ ] Did you run it as a non-superadmin account?
- [ ] Is there a test, including a case that must be refused?

## 5. Bad vs good

**Bad:** `make the customer page with delete`

**Good:**
```
TASK: S2-DEV-03
GOAL: Soft delete and restore for customers.
CONTEXT: [paste customer table DDL] [paste customer.service.ts] Rights: CUST_DEL. Roles: admin/superadmin see INACTIVE rows; user does not.
CONSTRAINTS: No .delete(). Refuse if the customer has ACTIVE sales (DB trigger from S2-DBA-04 already exists). Stamp is written by trigger, do not build it in code.
ACCEPTANCE: Given an admin with CUST_DEL, when they delete a customer with no active sales, then record_status = INACTIVE and the row is shaded. Given the customer has active sales, then the action returns a clear error and nothing changes.
OUTPUT: changed files, the action + service code, manual test steps for user/admin/superadmin, tests for Tester.
ASK FIRST: Is restore gated by CUST_DEL or a separate right?
```

---

## 6. Role templates with filled examples

### 6.1 Scrum Master (John Patrick Narvasa)

**Use for:** issues, sprint board, dependency checks, retros, git help.

```
TASK:        S{n}-SM-{nn}
GOAL:        <planning/issue/report to produce>
CONTEXT:     <paste sprint task rows or the git status / git log output>
CONSTRAINTS: One-PR tasks; ≤5 acceptance criteria; sprint scope only.
OUTPUT:      <issue text | board stories | impediment row | numbered git steps>
ASK FIRST:   <any ambiguity>
```

**Example**
```
TASK: S1-SM-02
GOAL: Turn the Sprint 1 Developer and DB Admin tasks into board stories with acceptance criteria.
CONTEXT: [paste S1-DEV-01…08 and S1-DBA-01…06 rows with due days]
CONSTRAINTS: Each story fits one PR. Mark any task due the same day as its dependency.
OUTPUT: A table: Task ID | User story | 3–5 Given/When/Then | Depends on | Risk flag.
ASK FIRST: Is Supabase Auth replacing the custom password-hash tasks (S1-DEV-04/05, S1-DBA-04)?
```

### 6.2 DB Admin (Keith Marlou Aldueza)

**Use for:** migrations, RLS, triggers, functions, views, seeds, pgTAP.

```
TASK:        S{n}-DBA-{nn}
GOAL:        <migration/policy/function that must exist>
CONTEXT:     <paste existing DDL for touched tables, existing helper functions, migration list>
CONSTRAINTS: Additive migration NNN_name.sql; RLS enabled; no DELETE grants; derived data as view/function.
ACCEPTANCE:  <Given/When/Then, including a negative case per role>
OUTPUT:      1) migration SQL 2) pgTAP tests 3) supabase commands to verify 4) risks
ASK FIRST:   <ambiguity>
```

**Example**
```
TASK: S1-DBA-03
GOAL: Create app_user, role, module and user_permission with soft delete and RLS.
CONTEXT: [paste hopedb.sql userlist/Module/user_module DDL] [paste list of existing migrations]
CONSTRAINTS: Roles superadmin/admin/user; account_status pending/active/blocked; new registrations are user+pending; trigger blocks removing, demoting or blocking the last active superadmin; no dev seeded as superadmin.
ACCEPTANCE: Given a pending account, when it selects from any business table, then 0 rows. Given the only active superadmin, when an update demotes or blocks it, then the statement fails.
OUTPUT: 003_access_tables.sql, supabase/tests/access_tables.test.sql, verify steps, risks.
ASK FIRST: Should app_user.empno be nullable now (S3-DBA-03 links it later)?
```

### 6.3 Developer (Ivan Abduhadi)

**Use for:** server actions, services, Zod schemas, wiring UI to Supabase.

```
TASK:        S{n}-DEV-{nn}
GOAL:        <behaviour to implement>
CONTEXT:     <paste relevant DDL/types, existing service/action files, the UI component to connect>
CONSTRAINTS: Layers page→action→service→supabase; requireRight('CODE') in the service; Zod in the action; rpc() for multi-row writes; no float money.
ACCEPTANCE:  <Given/When/Then per role>
OUTPUT:      files changed, code, manual test steps per role, tests for Tester, commit message(s)
ASK FIRST:   <missing table/function? ask the DB Admin, do not invent it>
```

**Example**
```
TASK: S1-DEV-06
GOAL: Superadmin can approve pending users and designate admins; the last superadmin cannot be removed or disabled.
CONTEXT: [paste app_user DDL + trigger from S1-DBA-03] [paste auth.service.ts] [paste users page component]
CONSTRAINTS: Role check is server-side (admin cannot see or change superadmin rows); the last-superadmin rule is enforced by the DB trigger, the action only surfaces its error; log via audit_log (S1-DBA-06).
ACCEPTANCE: Given a superadmin, when they approve a pending user, then account_status = active. Given an admin, when they try to change a superadmin, then the action returns forbidden and RLS also refuses a direct call.
OUTPUT: users.actions.ts, users.service.ts, user.schema.ts, test steps as superadmin/admin/user, tests for Tester, commit message with Refs: S1-DEV-06.
ASK FIRST: Does audit_log exist yet, or should the action skip logging until S1-DBA-06 merges?
```

### 6.4 UI/UX Designer (Nathaniel Ashley Ellacer)

**Use for:** wireframes, components, states, usability review, handoff.

```
TASK:        S{n}-UIX-{nn}
GOAL:        <screen/component/review to produce>
CONTEXT:     <paste user stories, field list from the ERD, rights involved, existing components>
CONSTRAINTS: Leafy Green tokens only; Inter; both role variants (admin vs user); required states; WCAG contrast, labels, keyboard.
OUTPUT:      <layout description or React+Tailwind code> + states checklist + handoff notes
ASK FIRST:   <ambiguity>
```

**Example**
```
TASK: S1-UIX-03
GOAL: Wireframe the main page and the user-rights management screen.
CONTEXT: Modules: customer, product, hr, sales, reports, admin. Rights matrix: [paste right-code table from system prompt §5]. Admin cannot see superadmin accounts. Pending users see only a "waiting for approval" page.
CONSTRAINTS: Tiles shown only for modules the user has; module switch on top, rights checkboxes grouped beneath, All/None shortcuts; blocked/pending/active badges use the status mapping.
OUTPUT: Layout for desktop and 375px; states (loading, empty, error, permission-denied, confirm-save); handoff notes listing data each component needs.
ASK FIRST: Where do the 4 payment rights appear: under Sales or their own group?
```

### 6.5 Tester (Ivan Abduhadi, see independence rule)

**Use for:** test plans, matrices, RLS checks, automated tests, bug reports.

```
TASK:        S{n}-TST-{nn}
GOAL:        <what to prove or break>
CONTEXT:     <paste acceptance criteria, rights list, the PR or code under test, seeded test accounts>
CONSTRAINTS: Test as anon, pending, blocked, user (no rights), user (some rights), admin, superadmin. UI, server action and direct DB path must each be checked.
OUTPUT:      test case table or automated test files, plus bug reports in the repo format
ASK FIRST:   <missing test accounts or ambiguous expectations>
```

**Example**
```
TASK: S1-TST-04
GOAL: Permission matrix tests for superadmin/admin/user × view/edit/delete.
CONTEXT: [paste rights table] [paste RLS policies from 002_rls_policies.sql] Test accounts: anon, pending1, blocked1, user_norights, user_some, admin1, super1.
CONSTRAINTS: Each cell verified through the UI, the server action, and a direct Supabase call with that user's token. At least one must-fail case per row. Not the author of the code under test.
OUTPUT: Matrix (account × right × UI/Action/RLS result), Playwright specs for the UI path, pgTAP cases for RLS, bug reports for any mismatch.
ASK FIRST: Which seeded accounts have which rights? I will not assume.
```

---

## 7. Keep your prompts

Save each prompt that produced merged work as `docs/prompts/<TASK-ID>.md`. Reviewers read the prompt and the diff together, and the next sprint reuses what worked.

## 8. Suggested additions to repo files

Add to `.github/PULL_REQUEST_TEMPLATE.md` checklist:
```
- [ ] AI assistance: yes / no — prompt saved in docs/prompts/<TASK-ID>.md
- [ ] I ran the output as a non-superadmin account and can explain every line
```
