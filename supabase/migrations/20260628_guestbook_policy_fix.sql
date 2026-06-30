-- Fix: make authorized guestbook reads rely on the shared permission helper.
-- Run this in Supabase SQL Editor if admin dashboard shows 0 messages
-- while rows still exist in public.guestbook_entries.

-- Ensure old rows without an explicit hidden flag are treated as visible.
update public.guestbook_entries
set is_hidden = false
where is_hidden is null;

alter table public.guestbook_entries
alter column is_hidden set default false;

-- Add an extra SELECT policy. It is intentionally additive so it does not
-- depend on the exact name of older policies already present in the project.
create policy "Authorized admins can read guestbook via permission helper"
on public.guestbook_entries
for select
to authenticated
using (
  public.has_admin_permission('can_read_guestbook') = true
);

comment on policy "Authorized admins can read guestbook via permission helper" on public.guestbook_entries is
  'Allows authenticated owner/admin users with can_read_guestbook to read guestbook entries, including accounts matched by user_id or email.';

-- Optional management policy for future moderation. It is additive and safe:
-- without can_manage_guestbook, update/delete still remains blocked.
create policy "Authorized admins can update guestbook via permission helper"
on public.guestbook_entries
for update
to authenticated
using (
  public.has_admin_permission('can_manage_guestbook') = true
)
with check (
  public.has_admin_permission('can_manage_guestbook') = true
);

comment on policy "Authorized admins can update guestbook via permission helper" on public.guestbook_entries is
  'Allows only users with can_manage_guestbook to update guestbook entries, for example hiding/moderating messages.';

create policy "Authorized admins can delete guestbook via permission helper"
on public.guestbook_entries
for delete
to authenticated
using (
  public.has_admin_permission('can_manage_guestbook') = true
);

comment on policy "Authorized admins can delete guestbook via permission helper" on public.guestbook_entries is
  'Allows only users with can_manage_guestbook to delete guestbook entries.';
