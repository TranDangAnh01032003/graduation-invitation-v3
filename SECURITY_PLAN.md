# SECURITY_PLAN.md

## Security Goal

The public invitation can be visible to everyone, but guestbook reading, admin dashboard, and private gift content must be protected in the production version.

Current state is demo-only:
- `fakeLogin()` in `script.js` is not authentication.
- `localStorage` is not a production database.
- `sessionStorage` is not authorization.
- `gift.html?from=admin` is only a local/demo convenience.

## Threat Model

Public users may:
- open any URL they know
- view frontend source code
- inspect JavaScript in DevTools
- call Supabase REST endpoints directly
- try to read guestbook data
- try to access `admin.html` or `gift.html`

Therefore:
- hiding links is not enough
- frontend password checks are not enough
- frontend hash checks are not enough
- sensitive/private content must not be shipped to unauthorized browsers

## Roles

Use role-based access, not a single hard-coded account.

Recommended roles:
- `owner`: Quỳnh
- `admin`: website creator
- public guest: unauthenticated visitor

Permissions:
- Public guest:
  - view invitation
  - insert guestbook message
  - cannot read full guestbook
  - cannot access admin dashboard
  - cannot access private gift
- Admin:
  - read guestbook
  - view dashboard statistics
  - optionally manage/delete guestbook if enabled
  - optionally preview gift if explicitly allowed
- Owner:
  - read guestbook
  - view dashboard
  - view final gift
  - optionally manage content

Recommended permission flags:
- `can_read_guestbook`
- `can_manage_guestbook`
- `can_view_gift`
- `can_preview_gift`

## Recommended Auth

Use Supabase Auth.

Preferred login:
- Google Login for admin/owner accounts.

Backup login:
- Magic Link by email.
- Email/password only if needed.

Do not:
- store passwords in JS
- store password hashes in JS as production security
- use localStorage/sessionStorage as proof of identity

## Recommended Database Tables

### `guestbook_entries`

Suggested columns:
```sql
id uuid primary key default gen_random_uuid(),
guest_name text not null,
message text not null,
attend_status text not null check (attend_status in ('Sẽ đến', 'Chưa chắc', 'Không đến được')),
created_at timestamptz not null default now(),
user_agent text,
ip_hint text,
is_hidden boolean not null default false
```

Notes:
- `user_agent` and `ip_hint` are optional.
- Do not collect more personal data than necessary.
- Avoid phone numbers unless the user explicitly needs them.

### `admin_users`

Suggested columns:
```sql
id uuid primary key default gen_random_uuid(),
user_id uuid references auth.users(id) on delete cascade,
email text unique not null,
role text not null check (role in ('owner', 'admin')),
can_read_guestbook boolean not null default true,
can_manage_guestbook boolean not null default false,
can_view_gift boolean not null default false,
can_preview_gift boolean not null default false,
created_at timestamptz not null default now()
```

Recommended initial records:
- Quỳnh:
  - role: `owner`
  - `can_read_guestbook = true`
  - `can_view_gift = true`
- Website creator:
  - role: `admin`
  - `can_read_guestbook = true`
  - `can_manage_guestbook = true` if needed
  - `can_view_gift = false` unless Quỳnh allows preview
  - `can_preview_gift = true` only if needed

## Row Level Security

Enable RLS on both tables.

```sql
alter table guestbook_entries enable row level security;
alter table admin_users enable row level security;
```

### Public insert policy for guestbook

Public visitors may insert guestbook messages.

```sql
create policy "Public can insert guestbook entries"
on guestbook_entries
for insert
to anon, authenticated
with check (
  char_length(trim(guest_name)) between 1 and 80
  and char_length(trim(message)) between 1 and 1000
  and attend_status in ('Sẽ đến', 'Chưa chắc', 'Không đến được')
);
```

### Block public guestbook read

Do not create a public `select` policy for `anon`.

### Authorized users can read guestbook

```sql
create policy "Authorized users can read guestbook"
on guestbook_entries
for select
to authenticated
using (
  exists (
    select 1
    from admin_users au
    where au.user_id = auth.uid()
      and au.can_read_guestbook = true
  )
);
```

### Authorized users can manage guestbook

Optional:

```sql
create policy "Authorized users can manage guestbook"
on guestbook_entries
for update
to authenticated
using (
  exists (
    select 1
    from admin_users au
    where au.user_id = auth.uid()
      and au.can_manage_guestbook = true
  )
)
with check (
  exists (
    select 1
    from admin_users au
    where au.user_id = auth.uid()
      and au.can_manage_guestbook = true
  )
);
```

Optional delete:

```sql
create policy "Authorized users can delete guestbook"
on guestbook_entries
for delete
to authenticated
using (
  exists (
    select 1
    from admin_users au
    where au.user_id = auth.uid()
      and au.can_manage_guestbook = true
  )
);
```

### Admin users can read their own permission record

```sql
create policy "Users can read own admin permission"
on admin_users
for select
to authenticated
using (user_id = auth.uid());
```

If the app needs to check whether current user is authorized, read the current user's own `admin_users` row.

## Frontend Security Rules

Frontend can:
- show/hide UI based on auth state
- redirect unauthorized users
- show friendly error messages

Frontend must not be the only protection:
- RLS must block unauthorized reads.
- Private gift content should be loaded only after auth/permission check.
- Do not include final private gift content in public static HTML if it must be secret before unlock.

## Private Gift Protection

Safer options:
1. Store gift content in Supabase and fetch only if `can_view_gift = true`.
2. Store encrypted gift content and decrypt only after authorized login.
3. Use serverless function to return gift content only after auth/role verification.

Minimum production rule:
- `gift.html` may show a public locked shell.
- final letter/video/album links should not be directly exposed to public users.
- direct asset URLs for private content should be protected or unguessable.
- If private video/image files are public assets, they are not truly private.

## Environment Variables

Never commit secrets.

Frontend may use:
- Supabase project URL
- Supabase anon key

Do not expose:
- Supabase service role key
- database password
- private API keys

Recommended `.env` names if refactoring to Vite:
```env
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=
```

## Anti-Spam

Basic options:
- honeypot hidden field
- rate limiting through Supabase Edge Function
- Turnstile/Captcha if spam appears
- length limits in RLS policy
- optional moderation flag `is_hidden`

Do not overcomplicate before public launch unless needed.

## Migration Plan

Phase 1:
- Keep current static demo working.
- Clearly label demo auth and demo storage.

Phase 2:
- Add Supabase client.
- Add Google Login.
- Replace `fakeLogin()`.
- Add logout and session restoration.

Phase 3:
- Replace localStorage guestbook with Supabase insert/select.
- Keep public insert.
- Use RLS to protect reads.

Phase 4:
- Protect gift content by auth + permission.
- Remove `gift.html?from=admin` as access control.

Phase 5:
- Deploy and test production access rules.

## Production Security Checklist

Before public launch:
- [ ] No hard-coded passwords in frontend.
- [ ] No fake login in production path.
- [ ] No private content exposed in public HTML.
- [ ] Supabase RLS enabled.
- [ ] Public can insert guestbook only.
- [ ] Public cannot select guestbook.
- [ ] Only authorized admin/owner can select guestbook.
- [ ] Owner/admin records created.
- [ ] Google Login redirect URLs configured.
- [ ] Logout tested.
- [ ] Unauthorized access tested.
- [ ] Domain HTTPS active.
- [ ] Repo does not expose secrets.
