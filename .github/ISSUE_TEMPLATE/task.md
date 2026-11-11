Conventions come first. Teams that skip them end up with branches named `fix2` and commits that say "stuff," and nobody can trace a bug back to the task that caused it.

## 1. Branch naming

```
<type>/<TASK-ID>-<short-kebab-description>
```

- `feature/S1-DEV-02-register-form`
- `fix/S1-TST-06-login-redirect-loop`
- `chore/S1-SM-01-repo-setup`

Branch from `main`. Never commit directly to `main`. Delete the branch after the PR merges.

## 2. Commit messages (Conventional Commits)

```
<type>(<scope>): <imperative summary, max 72 chars>

<optional body: why, not what>

Refs: S1-DEV-02
```

**Types:** `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `db` (migrations and seeds), `style` (UI-only changes), `ci`

**Scopes** (match the modules in the project):

| Scope | Covers |
|---|---|
| `auth` | Register, login, reset, set-password |
| `rights` | Module and right assignment, `UserModule_Rights` |
| `customer` | Customer CRUD |
| `product` | Product CRUD, `priceHist` |
| `hr` | Employee, job, department, job history |
| `sales` | Sales header, detail lines |
| `payment` | Payments and balances |
| `reports` | Report queries and screens |
| `db` | Schema, migrations, views, indexes |
| `ui` | Components, Tailwind, design tokens |

**Good examples:**
```
feat(auth): hash passwords with bcrypt on registration

Refs: S1-DEV-02
```
```
db(sales): add foreign key from salesDetail to product

Refs: S1-DBA-03
```

**Bad examples:** `fixed stuff`, `WIP`, `updates`, `Fix bug and add button and change color`

**Rules:**
- One logical change per commit. If the summary needs "and," split the commit.
- Imperative mood: "add," not "added."
- Every commit references a task ID in the footer.

## 3. Issue template

Save as `.github/ISSUE_TEMPLATE/task.md`:

```markdown
---
name: Sprint Task
about: A single PR-sized task from the sprint board
title: "[S{sprint}-{ROLE}-{nn}] "
labels: ["task"]
---

**Task ID:** S_-___-__
**Sprint / Sprint day due:** Sprint _ / Day _
**Role:** Developer | DB Admin | Tester | UI/UX | Scrum Master
**Assignee:**
**Module:** auth | rights | customer | product | hr | sales | payment | reports | db | ui

## User story
As a <role>, I want <capability>, so that <benefit>.

## Acceptance criteria
- [ ] Given ___, when ___, then ___
- [ ] Given ___, when ___, then ___

## Permission impact
- [ ] Server-side check added (not just a hidden button)
- [ ] Superadmin / Admin / User behavior specified: ___

## Dependencies
Blocked by: #___ (or "none")

## Definition of Done
- [ ] Code merged via PR with at least one reviewer approval
- [ ] Tests written and passing (Tester role)
- [ ] No secrets or passwords committed
- [ ] Migration included if the schema changed
- [ ] Sprint board updated
```

Every task must fit in one PR. If the acceptance criteria exceed about five items, split the issue.

## 4. Pull request template

Save as `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Summary
What changed and why, in 2–3 sentences.

## Linked task
Closes #___ · Task ID: S_-___-__

## Type of change
- [ ] feat  - [ ] fix  - [ ] db  - [ ] docs  - [ ] refactor  - [ ] chore

## How to test
1. Sign in as ___
2. Go to ___
3. Expect ___

## Checklist
- [ ] Commits follow the convention (`type(scope): summary`)
- [ ] Acceptance criteria in the linked issue are met
- [ ] Permission checks run on the server, not only in the UI
- [ ] RLS policies reviewed if a table was touched
- [ ] Migration is additive and runs from a clean database
- [ ] No passwords, keys, or `.env` values in the diff
- [ ] Screenshots attached for UI changes
```

## Two things I'd fix before you lock these in

1. **The db-admin agent says to default all developers to `superadmin`.** That contradicts Sprint 1, where new users start as pending and only a superadmin can approve them. It also means your RLS tests will pass for the wrong reason, because a superadmin bypasses almost everything. Developers should get a non-admin test role, and superadmin should be a deliberate, audited grant.
2. **Your `userlist` seed uses `SUPERADMIN / NEWUSER / ADMIN`, but the sprint and the guide describe `superadmin / admin / user`.** Pick one vocabulary now. Retrofitting a role name across migrations later is expensive.

