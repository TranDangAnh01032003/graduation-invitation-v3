-- Phase: Central invitation settings in Supabase
-- Purpose:
--   Store important editable project information in Supabase instead of localStorage/frontend-only config.
--   This includes invitation profile, event time/location, public page text, and protected gift settings.
--
-- How to run:
--   Supabase Dashboard -> SQL Editor -> New query -> paste/run this file.
--   Run with the project owner's dashboard privileges. Do NOT put service_role keys in frontend code.

create table if not exists public.site_settings (
  key text primary key,
  value jsonb not null,
  is_public boolean not null default false,
  owner_can_update boolean not null default false,
  admin_can_update boolean not null default true,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id) on delete set null
);

comment on table public.site_settings is
  'Central settings for the static graduation invitation. Public rows may be read by visitors; protected rows require admin/owner permission.';

comment on column public.site_settings.key is
  'Stable setting group key, for example invitation_profile, event_details, page_text, gift_settings.';

comment on column public.site_settings.value is
  'JSON payload for the setting group.';

comment on column public.site_settings.is_public is
  'If true, anon/authenticated public visitors may read this setting.';

comment on column public.site_settings.owner_can_update is
  'If true, owner role may update this setting from the admin UI.';

comment on column public.site_settings.admin_can_update is
  'If true, admin role may update this setting from the admin UI.';

create index if not exists idx_site_settings_public
  on public.site_settings (is_public);

create or replace function public.set_site_settings_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  new.updated_by = auth.uid();
  return new;
end;
$$;

drop trigger if exists trg_site_settings_updated_at on public.site_settings;

create trigger trg_site_settings_updated_at
before update on public.site_settings
for each row
execute function public.set_site_settings_updated_at();

-- Helper: true only when the current authenticated user has the requested permission.
-- Uses EXISTS and always returns a boolean.
create or replace function public.has_admin_permission(permission_name text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users au
    where (
      au.user_id = auth.uid()
      or lower(au.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
    )
    and case permission_name
      when 'can_read_guestbook' then au.can_read_guestbook
      when 'can_manage_guestbook' then au.can_manage_guestbook
      when 'can_view_gift' then au.can_view_gift
      when 'can_preview_gift' then au.can_preview_gift
      else false
    end
  );
$$;

grant execute on function public.has_admin_permission(text) to anon, authenticated;

-- Helper: true only when the current authenticated user has a matching admin_users.role.
-- Uses EXISTS and always returns a boolean.
create or replace function public.has_admin_role(role_name text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users au
    where (
      au.user_id = auth.uid()
      or lower(au.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
    )
    and au.role = role_name
  );
$$;

grant execute on function public.has_admin_role(text) to anon, authenticated;

alter table public.site_settings enable row level security;

drop policy if exists "Public can read public site settings" on public.site_settings;
drop policy if exists "Authorized users can read protected site settings" on public.site_settings;
drop policy if exists "Owner can update owner editable settings" on public.site_settings;
drop policy if exists "Admin can update admin editable settings" on public.site_settings;
drop policy if exists "Admin can insert site settings" on public.site_settings;
drop policy if exists "Admin can delete site settings" on public.site_settings;

create policy "Public can read public site settings"
on public.site_settings
for select
to anon, authenticated
using (
  is_public = true
);

comment on policy "Public can read public site settings" on public.site_settings is
  'Allows visitors to read non-sensitive invitation settings such as name, event time/location, and public page text.';

create policy "Authorized users can read protected site settings"
on public.site_settings
for select
to authenticated
using (
  public.has_admin_role('owner')
  or public.has_admin_role('admin')
  or public.has_admin_permission('can_view_gift')
  or public.has_admin_permission('can_preview_gift')
);

comment on policy "Authorized users can read protected site settings" on public.site_settings is
  'Allows authorized owner/admin/gift users to read protected settings such as gift unlock configuration.';

create policy "Owner can update owner editable settings"
on public.site_settings
for update
to authenticated
using (
  owner_can_update = true
  and public.has_admin_role('owner')
)
with check (
  owner_can_update = true
  and public.has_admin_role('owner')
);

comment on policy "Owner can update owner editable settings" on public.site_settings is
  'Allows the owner to update invitation content only for rows marked owner_can_update, not protected gift settings.';

create policy "Admin can update admin editable settings"
on public.site_settings
for update
to authenticated
using (
  admin_can_update = true
  and public.has_admin_role('admin')
)
with check (
  admin_can_update = true
  and public.has_admin_role('admin')
);

comment on policy "Admin can update admin editable settings" on public.site_settings is
  'Allows the admin role to update admin-managed settings, including protected gift unlock configuration.';

create policy "Admin can insert site settings"
on public.site_settings
for insert
to authenticated
with check (
  public.has_admin_role('admin')
);

comment on policy "Admin can insert site settings" on public.site_settings is
  'Allows only admin users to create new setting groups from the admin UI if needed later.';

create policy "Admin can delete site settings"
on public.site_settings
for delete
to authenticated
using (
  public.has_admin_role('admin')
);

comment on policy "Admin can delete site settings" on public.site_settings is
  'Allows only admin users to delete setting groups. Normal app flow should rarely need this.';

insert into public.site_settings
  (key, value, is_public, owner_can_update, admin_can_update)
values
  (
    'invitation_profile',
    '{
      "full_name": "Phạm Như Quỳnh",
      "display_name": "Như Quỳnh",
      "toolbar_title": "Phạm Như Quỳnh",
      "page_title": "Phạm Như Quỳnh",
      "meta_description": "Thư mời dự lễ tốt nghiệp của Phạm Như Quỳnh"
    }'::jsonb,
    true,
    true,
    true
  ),
  (
    'event_details',
    '{
      "day": "02",
      "month": "August",
      "year": "2026",
      "start_time": "10:00",
      "end_time": "12:00",
      "timezone": "Asia/Ho_Chi_Minh",
      "school": "Trường Đại học Kinh tế - Đại học Quốc gia Hà Nội",
      "hall": "Hội trường MMH",
      "address": "Số 57 Phạm Hùng, Nam Từ Liêm, Hà Nội"
    }'::jsonb,
    true,
    true,
    true
  ),
  (
    'page_text',
    '{
      "quote": "“Hi vọng trong bức tranh thanh xuân của tớ sẽ có sự góp mặt của cậu.”",
      "form_thanks": "Cảm ơn bạn rất nhiều vì đã gửi những lời chúc mừng tốt đẹp nhất đến buổi lễ tốt nghiệp của mình."
    }'::jsonb,
    true,
    true,
    true
  ),
  (
    'gift_settings',
    '{
      "enabled": true,
      "unlock_at": null,
      "recipient_name": "Như Quỳnh",
      "title": "Món quà dành cho Quỳnh"
    }'::jsonb,
    false,
    false,
    true
  ),
  (
    'invitation_media',
    '{
      "hero_image": "",
      "guestbook_image": "",
      "thank_image": "",
      "admin_hero_image": ""
    }'::jsonb,
    true,
    true,
    true
  )
on conflict (key) do nothing;
