# AGENTS.md

## Project Identity

This repository is a mobile-first graduation invitation website for **Phạm Như Quỳnh**.

The project is a personal digital invitation / memory website, not a corporate landing page. It should feel elegant, emotional, soft, and intimate.

Current project stage:
- Static HTML/CSS/JS.
- Supabase is configured for public guestbook inserts and authorized admin guestbook reads.
- Admin login uses Supabase Google Auth plus `admin_users` permissions.
- Private gift content is still guarded only by demo `sessionStorage` logic and must be protected before production gift release.

## Current Source Files

Core files:
- `index.html` — public invitation page.
- `admin.html` — admin login/dashboard page using Supabase Google Auth for guestbook reading.
- `gift.html` — private gift page, currently guarded only by demo session logic.
- `config.js` — editable invitation text configuration.
- `script.js` — UI behavior, countdown, menu, music, Supabase guestbook insert/read, admin auth, and demo gift guard.
- `style.css` — all visual styling, including many accumulated override sections.

Important:
- Do not assume older requirements are still current.
- The current `index.html` is simplified. It currently contains hero, name, quote, event information, guestbook, countdown, and thank-you sections.
- Do not re-add old sections such as full calendar, full timeline, or album unless explicitly requested.

## Current Public Page Structure

`index.html` currently includes:
- Background music audio element: `assets/music.mp3`.
- Topbar with:
  - UEB logo/home link.
  - toolbar title `Phạm Như Quỳnh`.
  - light/dark theme toggle.
  - music button.
  - hamburger menu.
- Side menu with:
  - Trang chủ
  - Thời gian - Địa điểm
  - Sổ lưu bút
  - Đếm ngược
  - Admin
- Hero section:
  - `assets/photo1.jpg`
  - `assets/graduation-ceremony-text-crop.png`
  - `02 . 08 . 2026`
- Separate name section:
  - `Phạm Như Quỳnh`
- Intro quote section.
- Event information section:
  - Chủ nhật
  - August 02 2026
  - current displayed time: `10:00 - 12:00`
  - location: Trường Đại học Kinh tế - Đại học Quốc gia Hà Nội
  - hall: Hội trường MMH
  - address: Số 57 Phạm Hùng, Nam Từ Liêm, Hà Nội
  - Google Maps direction button.
- Guestbook form:
  - name
  - message
  - attendance select
  - submit button
- Countdown section.
- Thank-you image section.

## Current Admin Page Structure

`admin.html` currently includes:
- Login card with Google Login.
- Supabase Auth session/permission check.
- Dashboard card after login:
  - greeting
  - open invitation button
  - logout button
  - stats: total, attending, maybe, cannot attend
  - open gift button
  - guestbook list loaded from Supabase for authorized users

Production rule:
- No hard-coded credentials in frontend.
- No frontend-only hash/password check as real security.

## Current Gift Page Structure

`gift.html` currently includes:
- `giftGuard`: shown when unauthorized.
- `giftLocked`: countdown/locked state.
- `giftOpen`: future placeholder for private gift content.

Current demo access:
- `gift.html?from=admin` sets session access in `sessionStorage`.
- This is only demo logic and is not production security.

Production rule:
- Gift content must not be exposed to unauthorized users.
- Final gift access should require a valid authenticated user and role/permission.
- Quỳnh should have permission to view the final gift.
- The site creator/admin may have permission to preview/manage only if explicitly allowed.

## Security Direction

Never implement production security only in frontend JavaScript.

Do not use:
- hard-coded username/password in JS
- hard-coded password hashes in JS as real security
- `localStorage` as real database
- `sessionStorage` as real authorization
- private gift content hidden only by CSS/JS
- public GitHub repository containing secrets or private configuration

Target production architecture:
- Supabase Auth.
- Google Login preferred for admin users.
- Supabase Database for guestbook entries.
- Supabase RLS enabled.
- Public visitors can submit guestbook messages.
- Public visitors cannot read the full guestbook.
- Authorized users can read guestbook messages.
- Authorized users are managed in an `admin_users` or `profiles` table.
- Roles:
  - `owner`: Quỳnh.
  - `admin`: website creator.
  - public guest: no login.

## Design Direction

Style keywords:
- mobile-first
- elegant
- emotional
- soft
- feminine but not childish
- clean
- minimal
- photo-focused
- graduation-themed
- close to a premium digital invitation/card

Visual direction:
- White / cream / soft gray.
- Black/charcoal text.
- Soft rose/pink accent only when needed.
- Thin lines, soft contrast, controlled whitespace.
- Handwritten font for emotional display text.
- Condensed/sans fonts for small structured labels.
- Avoid loud colors, thick borders, heavy shadows, or childish icon spam.

Current design direction in code:
- `style.css` has multiple historical styling layers and many final override sections.
- Later rules near the end of `style.css` often override earlier rules.
- Be careful when editing because old selectors may still exist for removed/unused sections.

## Development Rules for Codex

Before editing:
1. Read this file.
2. Read `PROJECT_BRIEF.md`.
3. Read `SECURITY_PLAN.md` if the task touches login, admin, guestbook, gift, Supabase, or deployment.
4. Read `STYLE_GUIDE.md` if the task touches layout, CSS, animation, typography, images, or mobile behavior.
5. Read `ROADMAP.md` to understand current priority.

When starting a task:
- Summarize the task in 3-5 bullet points.
- List the files you plan to modify.
- State what you will not touch.
- Ask only if the requirement is ambiguous enough to risk breaking the project.

When editing:
- Keep changes focused.
- Do not rewrite the whole project for a small task.
- Do not rename sections/classes unless necessary.
- Do not remove working features unless explicitly requested.
- Do not reintroduce removed old sections unless explicitly requested.
- Preserve mobile-first layout.
- Preserve Vietnamese copy and tone.
- Preserve `data-config-text` / `data-config-html` patterns when editing configurable text.
- Keep public page fast and smooth on mobile.
- Do not add dependencies casually.

When editing `style.css`:
- Prefer adding a clearly labeled override section at the end for small fixes.
- For large cleanup, first propose a refactor plan.
- Beware of repeated selectors and `!important` rules.
- Do not delete earlier CSS blocks unless you verified they are unused or replaced.

When editing `script.js`:
- Current file is compact/minified-like. Avoid making hidden behavior harder to maintain.
- Prefer moving toward readable modular code when a larger refactor is requested.
- Keep `escapeHtml()` or equivalent sanitization when rendering user messages.
- Do not add unsafe `innerHTML` rendering for user-provided content.

After editing:
- Summarize changed files.
- Explain how to test locally.
- Mention any known limitation honestly.
- If security is still demo-only, explicitly say so.

## Local Testing

Static local test:
- Open the project with VS Code.
- Run Live Server.
- Test desktop width and mobile width.
- Test on phone using PC Wi-Fi IPv4 and Live Server port.
- Test menu open/close.
- Test music button.
- Test theme toggle.
- Test guestbook submit.
- Test admin login demo.
- Test dashboard stats.
- Test clear guestbook.
- Test gift access from admin and direct access.

Production security test later:
- Test Google login.
- Test unauthorized user blocked from admin data.
- Test public guestbook insert.
- Test public select blocked.
- Test admin/owner select allowed.
- Test gift access permissions.
- Test logout clears protected view.
