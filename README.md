# scrum_3BSCS-2

This is a test repository setup for the **3BSCS-2** group project.

---

##  The bAI Group Team members


| Role | Name |
| :--- | :--- |
| **Scrum Master** | John Patrick Narvasa |
| **UI/UX Developer** | Nathaniel Ashley Ellacer |
| **Backend Engineer** | Keith Marlou Aldueza |
| **DevSecOps & Test Engineer** | Ivan Abduhadi |

---

## Tech Stack & Tools

| Category | Tech / Tool | 
| :--- | :--- | 
| **Frontend** | Next.js (App Router), React.js, Tailwind CSS | 
| **Backend** | Next.js Server Actions / API Routes, Supabase Auth | 
| **Database** | PostgreSQL (Supabase), Supabase RLS (Row Level Security) | 
| **DevSecOps / CI/CD**| Git, GitHub Actions / Branch Protection Policies |
| **Testing** | Jest / Playwright (Automated Testing), Manual Security / RLS Audit Suites |

---

## Database Development Setup (Hosted Supabase)

The project uses Supabase PostgreSQL for its database and Supabase Auth for authentication. Each developer should use their own hosted Supabase project for individual development. Docker and a local Supabase database are not required.

### Prerequisites

- Node.js and npm
- Git
- A Supabase account
- PowerShell (for the migration runner)

### 1. Install Dependencies

From the repository root, run:

```powershell
npm install
```

### 2. Configure Environment Variables

Create a `.env.local` file in the repository root if one does not already exist.

Add your personal Supabase project URL and publishable key:

```env
NEXT_PUBLIC_SUPABASE_URL=YOUR_SUPABASE_PROJECT_URL
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

Each developer must use their own credentials. Do not commit `.env.local` or expose secret keys.

### 3. Authenticate the Supabase CLI

```powershell
npx supabase login
```

Follow the CLI instructions to authenticate your Supabase account.

### 4. Link Your Personal Supabase Project

```powershell
npx supabase link --project-ref YOUR_PERSONAL_PROJECT_REF
```

Replace the placeholder with your hosted project's reference ID.

Do not link your personal development environment to the shared integration project unless authorized.

### 5. Preview Database Migrations

```powershell
npm run db:migrate -- -ExpectedProjectRef YOUR_PERSONAL_PROJECT_REF
```

This checks the linked project, displays migration status, and previews pending migrations. It does not apply them.

### 6. Apply Database Migrations

Only after the migration files have been reviewed and approved:

```powershell
npm run db:migrate:apply -- -ExpectedProjectRef YOUR_PERSONAL_PROJECT_REF
```

The script asks you to enter the exact project reference before applying pending migrations.

Do not apply migrations to the shared integration database without authorization from the assigned Database Administrator.

### 7. Generate TypeScript Database Types

After the database schema has been applied to your linked project:

```powershell
npm run db:types
```

This generates TypeScript definitions from the linked project's `public` schema at:

`src/types/database.types.ts`

Regenerate the types when relevant database schema changes are applied.

### Database Migration Guidelines

- Store migrations in `supabase/migrations/`.
- Use ordered migration filenames, such as `004_add_customer_fields.sql`.
- Prefer additive schema changes.
- Do not edit migrations already applied to a shared environment.
- Review SQL before applying migrations.
- Do not use `supabase db reset` against the shared integration project.
- Never commit passwords, access tokens, or service role keys.

### Shared Database Workflow

Each developer may use an individual hosted Supabase project for development and testing.

Changes intended for team integration must follow the repository workflow and be reviewed before being applied to the shared integration project.

Only the assigned Database Administrator should make changes to the shared integration database after the relevant work has been reviewed and merged.
