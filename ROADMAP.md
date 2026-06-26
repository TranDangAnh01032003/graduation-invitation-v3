# ROADMAP.md

## Current Status

The project is currently a static, mobile-first graduation invitation website.

Current working parts:
- public invitation page
- music button
- theme toggle
- side menu
- event information
- guestbook form using localStorage demo
- admin dashboard using fake login demo
- gift page using sessionStorage demo guard
- countdown

Main risk:
- Current admin/gift/guestbook security is demo-only and not production-safe.

## Phase 0 — Preserve Current Direction

Status: Active

Goal:
- Prevent Codex from using outdated requirements.
- Preserve current simplified layout.
- Document the actual project state.

Tasks:
- [x] Create `AGENTS.md`.
- [x] Create `PROJECT_BRIEF.md`.
- [x] Create `SECURITY_PLAN.md`.
- [x] Create `STYLE_GUIDE.md`.
- [x] Create `ROADMAP.md`.
- [ ] Keep these files updated whenever the project direction changes.

Do not:
- re-add old sections without explicit request
- rewrite the entire design
- treat old prompts as current truth

## Phase 1 — Static UI Stabilization

Status: In progress

Goal:
- Finish and stabilize the current static version before adding real backend/auth.

Tasks:
- [x] Confirm event time: visible page and countdown use `10:00 - 12:00` / `2026-08-02T10:00:00+07:00`.
- [x] Decide final event time and update all places consistently.
- [ ] Test current page on mobile phone.
- [ ] Check topbar spacing at 360px/390px.
- [ ] Check hero photo crop.
- [ ] Check guestbook form spacing and thank-you behavior.
- [ ] Check dark mode readability.
- [ ] Check gift page direct access and admin access.
- [ ] Check admin dashboard layout on mobile.
- [ ] Clean obvious unused/contradictory CSS only if safe.

Definition of done:
- Public page looks stable on phone.
- No broken layout at common mobile widths.
- Demo guestbook/admin/gift flow still works.

## Phase 2 — CSS/JS Maintainability

Status: Planned

Goal:
- Make the project easier for Codex and future editing.

Tasks:
- [ ] Format `script.js` into readable multi-line code.
- [ ] Add comments around major JS modules:
  - config text injection
  - toolbar/theme
  - countdown
  - menu
  - guestbook
  - admin demo
  - gift demo
- [ ] Reduce CSS conflicts carefully.
- [ ] Move page-specific CSS into clear sections.
- [ ] Remove unused CSS only after verifying current pages.

Rules:
- Do not do this phase in the same task as a visual redesign.
- Create a backup/commit before refactor.
- Verify `index.html`, `admin.html`, and `gift.html` after each step.

## Phase 3 — Supabase Project Setup

Status: Planned

Goal:
- Prepare real backend/auth.

Tasks:
- [ ] Create Supabase project.
- [ ] Configure production URL and local URL.
- [ ] Enable Google provider.
- [ ] Add authorized redirect URLs.
- [ ] Create `guestbook_entries` table.
- [ ] Create `admin_users` table.
- [ ] Enable RLS.
- [ ] Add policies from `SECURITY_PLAN.md`.
- [ ] Add Quỳnh as `owner`.
- [ ] Add website creator as `admin`.

Definition of done:
- Supabase Auth works.
- Authorized accounts are recognized.
- Public cannot read guestbook data.

## Phase 4 — Replace Demo Guestbook

Status: Planned

Goal:
- Move guestbook from localStorage to Supabase.

Tasks:
- [ ] Keep public form in `index.html`.
- [ ] On submit, insert to Supabase `guestbook_entries`.
- [ ] Add loading state.
- [ ] Add success state.
- [ ] Add error state.
- [ ] Keep form fields minimal.
- [ ] Remove default demo guests from production path.
- [ ] Keep `escapeHtml()` or equivalent for dashboard rendering.

Definition of done:
- Guest can submit message from public page.
- Guest cannot read all messages.
- Admin/owner can read messages after login.

## Phase 5 — Replace Demo Admin Login

Status: Planned

Goal:
- Replace `fakeLogin()` with real Supabase Auth.

Tasks:
- [ ] Replace username/password demo or keep as visual only until converted.
- [ ] Add Google Login button.
- [ ] Implement auth state listener.
- [ ] Load current user's `admin_users` permission row.
- [ ] If unauthorized, show access denied.
- [ ] If authorized, show dashboard.
- [ ] Implement logout.
- [ ] Remove `fakeLogin()` from production path.

Definition of done:
- Public sees login page.
- Unauthorized users cannot access dashboard data.
- Quỳnh and admin can access guestbook dashboard.

## Phase 6 — Protect Gift Page

Status: Planned

Goal:
- Replace `gift.html?from=admin` and `sessionStorage` with real permission checks.

Tasks:
- [ ] Decide who can view final gift:
  - Quỳnh only
  - or Quỳnh + creator/admin preview
- [ ] Check auth session on `gift.html`.
- [ ] Check permission:
  - `can_view_gift`
  - or `can_preview_gift`
- [ ] Keep countdown/locked state.
- [ ] Load private gift content only after permission check.
- [ ] Remove URL parameter access as production authorization.
- [ ] Do not expose private assets publicly if they must remain secret.

Definition of done:
- Direct public access cannot reveal gift.
- Authorized account can view when allowed.
- Unauthorized account is blocked.

## Phase 7 — Deployment

Status: Planned

Goal:
- Deploy safely to production.

Recommended hosting:
- Vercel or Netlify.

Domain:
- `phamnhuquynh.site`

Tasks:
- [ ] Deploy static/prod build.
- [ ] Configure custom domain.
- [ ] Enable HTTPS.
- [ ] Configure Supabase redirect URLs for domain.
- [ ] Test Google Login on production domain.
- [ ] Test guestbook insert.
- [ ] Test admin read.
- [ ] Test unauthorized access blocked.
- [ ] Test gift permission.
- [ ] Test on phone using mobile data and Wi-Fi.
- [ ] Check page speed and image sizes.

Definition of done:
- Public site works.
- Admin login works.
- Data access is protected.
- No secrets are exposed.

## Phase 8 — Optional Polish

Status: Optional

Ideas:
- [ ] Add gentle silk CSS background if `bg-silk.png` is missing.
- [ ] Add subtle reveal-on-scroll.
- [ ] Add spam protection.
- [ ] Add export guestbook to CSV for admin.
- [ ] Add moderation/hide message.
- [ ] Add private letter/video/album gift content.
- [ ] Add Open Graph preview image.
- [ ] Add favicon polish.

## Task Discipline for Codex

Every Codex task should state:
- phase
- objective
- allowed files
- forbidden files
- expected test steps

Example:
```text
Phase 1 task:
Only fix topbar spacing on mobile.
Allowed files: index.html, style.css.
Do not touch admin.html, gift.html, script.js, config.js.
Test at 360px and 390px.
```

Avoid broad prompts:
```text
Make the whole website better.
```

Use narrow prompts:
```text
Improve the guestbook form spacing on mobile without changing behavior.
```
