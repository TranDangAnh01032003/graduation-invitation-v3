# Supabase

This folder keeps database SQL used to set up the production Supabase project.

## migrations

- `20260628_guestbook_policy_fix.sql` fixes guestbook row-level security policies.
- `20260628_site_settings.sql` creates and seeds central site settings.

Do not commit service role keys, database passwords, or other private secrets here.
