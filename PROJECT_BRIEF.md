# PROJECT_BRIEF.md

## Project Name

Graduation Invitation Website for Phạm Như Quỳnh

## One-Sentence Summary

A mobile-first graduation invitation and memory website where guests can view the invitation and send wishes, while authorized users can log in to read the guestbook and access/manage a private gift page.

## Recipient

Name:
- Phạm Như Quỳnh

Event:
- Graduation Ceremony

Current public display:
- Date: 02 . 08 . 2026
- Day: Chủ nhật
- Month display: August
- Year: 2026
- Current event time displayed in `index.html`: 10:00 - 12:00
- Countdown date in `script.js`: `2026-08-02T10:00:00+07:00`

Location:
- Trường Đại học Kinh tế - Đại học Quốc gia Hà Nội
- Hội trường MMH
- Số 57 Phạm Hùng, Nam Từ Liêm, Hà Nội

Important content note:
- If changing ceremony time, update all places consistently:
  - `index.html` visible event time
  - `script.js` countdown date/time
  - any future Supabase/event config
  - text in `config.js` if used

## Current Project State

The current project is a static web project made of:
- HTML
- CSS
- JavaScript
- local image/audio assets

Current files:
- `index.html`
- `admin.html`
- `gift.html`
- `config.js`
- `script.js`
- `style.css`

The current version is partially connected to Supabase:
- public guestbook submissions insert into `guestbook_entries`
- admin login uses Supabase Google Auth
- authorized admin/owner users can read guestbook entries through RLS
- gift page access checks Supabase Auth and `can_view_gift` / `can_preview_gift`

## Public User Flow

A public guest can:
1. Open `index.html`.
2. View the graduation invitation.
3. View event date/time/location.
4. Open Google Maps direction.
5. Send a guestbook message.
6. Select attendance status:
   - Mình sẽ đến
   - Mình chưa chắc
   - Mình không đến được
7. See countdown.
8. Use music button and theme toggle.

A public guest should not:
- read all guestbook messages
- access admin dashboard data
- access private gift content

## Admin/Owner User Flow

Authorized users in the professional version:
- Quỳnh as `owner`
- Website creator as `admin`

They can:
1. Open the admin page from the public menu.
2. Log in with real authentication.
3. Read guestbook messages.
4. View guestbook statistics.
5. Manage or preview content depending on role.
6. Open the private gift page if permission allows.

Current admin page:
- uses Google Login through Supabase Auth
- checks `admin_users` permissions
- displays Supabase guestbook data for authorized users

## Private Gift Flow

Current gift flow:
- direct access to `gift.html` checks Supabase Auth.
- unauthenticated users see a guard with Google Login.
- authenticated users need `can_view_gift` or `can_preview_gift`.
- before unlock date, authorized users see the locked countdown.
- after countdown reaches zero, authorized users see placeholder gift content.

Production target:
- gift access now requires real auth and permission.
- final private gift content must not be exposed in static HTML or public assets.
- Quỳnh should be able to view the real gift.
- Admin preview may exist only if intentionally allowed.

## Current Public Page Sections

The current `index.html` has these sections:
1. Topbar and side menu.
2. Hero section with graduation image/text.
3. Name section.
4. Intro quote.
5. Event time and location.
6. Guestbook form.
7. Countdown.
8. Thank-you image.

Do not assume the page still includes:
- full August calendar
- full event timeline
- full album section
- old three-photo invitation section

Those older ideas may exist in CSS/config history, but they are not part of the current simplified page unless the user explicitly asks to restore them.

## Content Configuration

`config.js` contains `window.INVITATION_CONFIG.pageText`.

Current configurable text includes:
- quote
- introMessage
- inviteLine
- dateNote
- school
- hall
- address
- timelineNote
- albumTextA
- albumTextB
- formThanks

Note:
- Some keys may be leftovers from previous versions and may not be used in the current `index.html`.
- Do not remove config keys unless doing a deliberate cleanup.

## Design Intent

The website should feel:
- personal
- warm
- elegant
- emotional
- premium
- suitable for a graduation invitation

It should not feel:
- like a corporate landing page
- like a generic template
- childish
- noisy
- overloaded with animation

## Future Technical Direction

Recommended production stack:
- Frontend: current static pages or later refactor to Vite/React if needed.
- Auth: Supabase Auth.
- Login method: Google Login preferred.
- Database: Supabase Postgres.
- Permissions: Supabase RLS.
- Hosting: Vercel or Netlify.
- Domain: `phamnhuquynh.site`.

## Success Criteria

A successful final version should:
- load beautifully on phone
- work smoothly on mobile browser
- let guests submit wishes
- protect guestbook reading
- protect gift content
- support Quỳnh and the creator as authorized readers
- avoid exposing secrets in frontend code
- be easy for Codex/future maintainers to understand
