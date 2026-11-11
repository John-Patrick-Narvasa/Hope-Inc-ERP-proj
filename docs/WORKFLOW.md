# Hope, Inc. ERP — Team Workflow

> Save as `docs/WORKFLOW.md`. Read with `.github/copilot-instructions.md` (rules), `docs/AI_PROMPTING.md` (prompts) and the sprint board (tasks). If this file and the system prompt disagree, the system prompt wins.

## 1. The pattern in one page

Four sprints, two weeks each, ten sprint days per sprint. The same cycle repeats every sprint; only the content changes.

| Phase | Days | Owner | Output |
|---|---|---|---|
| Plan | 1 | Scrum Master | Board, stories, acceptance criteria, dependency check |
| Design | 1–4 | UI/UX | Wireframes, then hi-fi + handoff notes |
| Schema | 1–5 | DB Admin | Migrations, RLS, functions, views, seeds, pgTAP tests |
| Build | 2–9 | Developer | One PR per task, in dependency order |
| Verify | 3–10 | Tester | Test plan early; cases run as each feature merges |
| Close | 5, 8, 10 | Scrum Master | Mid-sprint check, risk update, review and retro |

**Three laws**
1. **Dependency before dependent.** Nothing is due the same day as the thing it needs.
2. **Nobody verifies their own work.** Author ≠ reviewer ≠ final verifier.
3. **Merge the day it is due, or raise a blocker that day.** Silent slippage becomes carryover.

## 2. Roles, owners and who checks whom

| Role | Person | Task prefix | PR reviewed by |
|---|---|---|---|
| Developer | Ivan Abduhadi | `DEV` | Keith (primary), John (backup) |
| DB Admin | Keith Marlou Aldueza | `DBA` | Ivan |
| UI/UX Designer | Nathaniel Ashley Ellacer | `UIX` | Ivan (code), John (docs/design files) |
| Tester | Ivan Abduhadi | `TST` | Keith or Nathaniel |
| Scrum Master | John Patrick Narvasa | `SM` | Keith |

**Independence rule.** Ivan is both Developer and Tester. For any `DEV` task Ivan wrote, the Tester pass (matrix, regression, sign-off) is performed or countersigned by **Keith or Nathaniel**. A `TST` task Ivan wrote is reviewed by Keith or Nathaniel. Reassigning the Tester role is the better fix; until then this rule is mandatory.

## 3. Task lifecycle (every role, every task)

Board columns: `Backlog → Ready → In progress → In review → Testing → Done` (plus `Blocked`).

1. **Ready.** Issue exists from the template, ≤5 Given/When/Then criteria, dependencies merged or scheduled. If not, it is not Ready.
2. **Branch** from `main`: `<type>/<TASK-ID>-<kebab-description>`.
3. **Prompt.** Open the AI session with the session starter, then the seven-field task prompt. Save it to `docs/prompts/<TASK-ID>.md`.
4. **Build.** Small commits, `type(scope): summary` with `Refs: <TASK-ID>`.
5. **Pull request** from the template. State `AI assistance: yes/no`. Attach screenshots for UI.
6. **Review** by the person in §2. Checklist: scope, invented names, server-side permission, RLS touched, secrets, non-superadmin run.
7. **Merge** (squash) only when CI is green (`ci-cd.yml`, `rls-security-check.yml`) and one non-author approved. Delete the branch.
8. **Testing.** Tester runs the permission matrix against `main`. Failures become bug reports linked to the task.
9. **Done** = merged + tested + board updated. Not before.

## 4. Handoffs (what "finished" means between roles)

| From → To | The handoff is complete when |
|---|---|
| DB Admin → Developer | Migration merged, `supabase gen types` committed, comment on the issue naming new tables/functions/error strings |
| UI/UX → Developer | Handoff note on the issue: data each component needs, rights involved, all states (loading, empty, error, confirm-delete, denied), role variants |
| Developer → Tester | Comment "ready for test": manual steps per role, which accounts, expected results, known limits |
| Tester → Developer | Bug report in the repo format, severity, security flag, evidence |
| Anyone → Scrum Master | Blocker logged same day: `Date | Task | Blocker | Owner | Needed from | Status` |

**Standing test accounts** (seeded, no passwords in repo): `anon`, `pending1`, `blocked1`, `user_norights`, `user_some`, `admin1`, `super1`. Developers work as `user_some` or `admin1` by default, never as superadmin.

## 5. Rhythm and ceremonies

| When | What | Owner | Length |
|---|---|---|---|
| Day 1 | Planning: confirm board, dependencies, carryover | SM | 45 min |
| Daily | Async stand-up in the board thread: done / doing / blocked | Everyone | 3 lines |
| Day 5 | Mid-sprint check: at-risk tasks, impediment log | SM | 30 min |
| Day 8 | Velocity update, next-sprint risk register | SM | 30 min |
| End of day 9 | **Feature freeze.** Only bug fixes merge after this | SM | — |
| Day 10 | Fix verification, sign-off, demo, review, retro | All | 90 min |

**Carryover.** Unfinished tasks go to the top of the next sprint's board on day 1 and are re-prioritised there. They are recorded in the retro, not hidden.

## 6. Environments (no Docker)

The sprint plan says "no Docker", and the local Supabase stack needs Docker. So:

- Each student works against **their own hosted Supabase project** (free tier) for development and migration testing.
- One shared **integration project** runs only merged `main`. It is changed only by the DB Admin through the migration runner script.
- **Never run a database reset against the shared project.** Rebuild-from-empty checks (S4-DBA-06) use a scratch project.
- Secrets live in each person's untracked env file. `.env.example` lists names only. The service-role key is never used by the app and never leaves the DB Admin's machine.
- Before relying on pgTAP in CI, confirm the exact `supabase test db` options for a linked remote project in the current CLI docs.

## 7. Schedule conflicts in the current sprint plan, and the fix

These are due-day collisions in the plan as written. Recommended changes need the Scrum Master's approval on day 1; they do not alter scope.

| Sprint | Conflict | Fix |
|---|---|---|
| 1 | DEV-02 register and DBA-03 `app_user` both due day 4 | DBA-03 → day 3 |
| 1 | DEV-01 scaffold and DBA-01 DB setup both day 2 | DBA-01 merges first thing day 2; DEV-01 connects after |
| 1 | TST-04/05/06 due day 9, same day as DEV-07/08 they verify | TST-04/05/06 → day 10 (feature freeze still end of day 9) |
| 1 | DEV-04/05 and DBA-04 build custom hashing/reset tokens; Supabase Auth already provides them | Reduce to configuration and the pending-approval gate (see system prompt §11 #1) |
| 2 | DEV-01, DBA-01, UIX-01 all day 2 | UIX-01 and DBA-01 → day 1 |
| 2 | DEV-03 soft delete (day 4) needs DBA-04 delete checks (day 6) | DBA-04 → day 3 |
| 2 | TST-04 permission tests (day 8) before DEV-08 permission checks (day 9) | TST-04 → day 10 |
| 3 | DEV-01 and UIX-01 both day 2 | UIX-01 → day 1 |
| 3 | DEV-01/02 include delete, but DBA-04 delete checks are day 6; DEV-05 employee soft delete also day 6 | DBA-04 → day 3 (dept, job), employee check merged by day 5 |
| 3 | TST-04 salary visibility (day 8) before DEV-08 salary restriction (day 9) | TST-04 → day 10 |
| 4 | DEV-01, DBA-01, UIX-01 all day 2 | DBA-01 and UIX-01 → day 1 |
| 4 | No task builds the atomic sale-save or the locked payment function; DEV-02/03/05 would loop inserts | **Add** `S4-DBA-07` sale-save RPC with sequence-based `transNo` (due day 2) and `S4-DBA-08` payment RPC with row lock and over-payment check (due day 4) |
| 4 | TST-05 regression and TST-06 sign-off both day 9, with DEV-08 also day 9 | TST-05 and TST-06 → day 10 |

## 8. Sprint playbooks

Dates below are the plan's due days with the fixes from §7 applied. Tasks marked ▲ moved; ✚ added.

### Sprint 1 — Auth and access (weeks 1–2)

**Goal.** A person can register, be approved by a superadmin, log in, and see only the modules they have been granted, with every rights change audited.
**Exit criteria.** Pending/blocked accounts get nothing; admin cannot touch superadmin; last superadmin protected; rights matrix tested as 7 account types; audit log records the logged-in user.
**Risk focus.** Authorization, not features. A bypass here undermines every later sprint.

| Day | Developer | DB Admin | UI/UX | Tester | Scrum Master |
|---|---|---|---|---|---|
| 1 | | | | | SM-01 repo setup, SM-02 board |
| 2 | DEV-01 scaffold | DBA-01 DB setup + runner | UIX-01 design system | | SM-03 agreement, DoD |
| 3 | | DBA-02 base tables ▲DBA-03 access tables | UIX-02 auth wireframes | TST-01 test plan | |
| 4 | DEV-02 register | | UIX-03 main + rights wireframes | | |
| 5 | DEV-03 login/logout | DBA-04 reset support, DBA-05 seeds | | TST-02 register/login cases | SM-04 mid-sprint |
| 6 | DEV-04 set-password | | UIX-04 hi-fi + handoff | | |
| 7 | DEV-05 reset password | | | TST-03 set/reset cases | |
| 8 | DEV-06 approve users, last-superadmin guard | DBA-06 `audit_user()` | | | |
| 9 | DEV-07 rights assignment, DEV-08 main page | | UIX-05 usability review | | **Freeze** |
| 10 | bug fixes | | fix list | ▲TST-04 matrix, ▲TST-05 smoke, ▲TST-06 bugs | SM-05 review + retro |

### Sprint 2 — Customers and products (weeks 3–4)

**Goal.** First full CRUD pattern (list, search, add, edit, soft delete, restore) on Customer, then Product with price history. Customer is the template every later module copies.
**Exit criteria.** Soft delete refused with active children; current price correct as of any date; User role sees no inactive rows, Status or Stamp.
**Risk focus.** Price lookup correctness; backdated price rows must not change old sales.

| Day | Developer | DB Admin | UI/UX | Tester | Scrum Master |
|---|---|---|---|---|---|
| 1 | | ▲DBA-01 active views, indexes | ▲UIX-01 customer wireframes | | SM-01 planning |
| 2 | DEV-01 customer list | | | | |
| 3 | DEV-02 customer form | ▲DBA-04 delete checks | UIX-02 product wireframes | TST-01 customer cases | SM-02 retro follow-up |
| 4 | DEV-03 customer soft delete/restore | DBA-02 price-as-of | | | |
| 5 | DEV-04 product list | DBA-03 constraints | UIX-03 hi-fi | TST-02 product + price cases | SM-03 mid-sprint |
| 6 | DEV-05 product form | | | | |
| 7 | DEV-06 product soft delete | DBA-05 demo data | UIX-04 empty/error/confirm states | TST-03 soft-delete tests | |
| 8 | DEV-07 price history | | | | SM-04 velocity |
| 9 | DEV-08 current price, permissions | DBA-06 search/index tuning | UIX-05 usability review | | **Freeze** |
| 10 | bug fixes | | | ▲TST-04 permissions, TST-05 regression S1, TST-06 bugs | SM-05 review + retro |

### Sprint 3 — Human Resources (weeks 5–6)

**Goal.** Departments and jobs (lookup tables), employees, and job history with a timeline, with salary and birth date visible only to people with `JHIST_VIEW`.
**Exit criteria.** No duplicate `(empno, effdate)`; separation date and soft delete behave independently; salary hidden at the query level for users without the right.
**Risk focus.** Privacy (RA 10173). The salary restriction gets the longest review.

| Day | Developer | DB Admin | UI/UX | Tester | Scrum Master |
|---|---|---|---|---|---|
| 1 | | | ▲UIX-01 dept/job wireframes | | SM-01 planning |
| 2 | DEV-01 department CRUD | DBA-01 current-job views | | | |
| 3 | DEV-02 job CRUD | ▲DBA-04 dept/job delete checks | UIX-02 employee wireframes | TST-01 dept/job cases | SM-02 carryover |
| 4 | DEV-03 employee list | DBA-02 effdate validation | UIX-03 timeline component | | |
| 5 | DEV-04 employee form | DBA-03 link `app_user.empno`, employee delete check | UIX-04 hi-fi | TST-02 employee cases | SM-03 mid-sprint |
| 6 | DEV-05 employee soft delete + separation | | | | |
| 7 | DEV-06 job history | DBA-05 HR demo data | | TST-03 job-history tests | |
| 8 | DEV-07 profile + timeline | | | | SM-04 velocity, S4 risk register |
| 9 | DEV-08 salary restriction | DBA-06 indexes, backup/restore | UIX-05 usability review | | **Freeze** |
| 10 | bug fixes | | | ▲TST-04 salary visibility, TST-05 regression S1–2, TST-06 bugs | SM-05 review + retro |

### Sprint 4 — Sales, payments, reports (weeks 7–8)

**Goal.** A sale (header + lines) with prices looked up as of the sale date, payments against it, balances, reports, and a superadmin audit-log viewer.
**Exit criteria.** End-to-end register → approve → login → sell → pay passes; reports agree with each other; concurrent payments cannot overpay; rebuild from migrations on a clean project succeeds.
**Risk focus.** Concurrency and money. This is the sprint where races and rounding show up.

| Day | Developer | DB Admin | UI/UX | Tester | Scrum Master |
|---|---|---|---|---|---|
| 1 | | ▲DBA-01 totals and line amounts | ▲UIX-01 sales wireframes | | SM-01 planning |
| 2 | DEV-01 sales list | ✚DBA-07 sale-save RPC + `transNo` sequence | | | |
| 3 | DEV-02 create sale | | UIX-02 payment/balance wireframes | TST-01 sales cases | |
| 4 | DEV-03 line items | DBA-02 balance view, ✚DBA-08 locked payment RPC | UIX-03 report + audit design | | |
| 5 | DEV-04 price auto-fill | DBA-03 report queries | UIX-04 hi-fi | TST-02 price-as-of tests | SM-02 mid-sprint |
| 6 | DEV-05 record payment | DBA-04 audit-log query | | | |
| 7 | DEV-06 balance views | DBA-05 delete rules | | TST-03 payment + balance tests (incl. concurrent) | |
| 8 | DEV-07 sales summary report | | | TST-04 end-to-end | SM-03 release checklist, demo script |
| 9 | DEV-08 audit-log viewer | DBA-06 final DB review | UIX-05 final consistency pass | | SM-04 peer evaluations, **Freeze** |
| 10 | bug fixes | | | ▲TST-05 full regression, ▲TST-06 sign-off | SM-05 final review + report |

## 9. Quality gates (what blocks a merge)

- CI red, or `rls-security-check` red.
- A table added or changed without RLS and a pgTAP test.
- A server action without a server-side permission check.
- Authorization present only in the UI.
- Any `DELETE` on a business table, any stored total/balance/current price, `MAX()+1`, float money.
- Secrets in the diff.
- Behaviour verified only as superadmin.
- No second person reviewed it.

## 10. Reference

| Need | File |
|---|---|
| Rules, ERD, rights list, tokens | `.github/copilot-instructions.md` |
| Role behaviour | `.github/agents/<role>.agent.md` |
| Prompt format and examples | `docs/AI_PROMPTING.md` |
| Saved prompts | `docs/prompts/<TASK-ID>.md` |
| Issue / PR templates | `.github/ISSUE_TEMPLATE/task.md`, `.github/PULL_REQUEST_TEMPLATE.md` |
