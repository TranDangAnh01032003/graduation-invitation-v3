# STYLE_GUIDE.md

## Visual Identity

This website is a personal graduation invitation for **Phạm Như Quỳnh**.

The visual tone should be:
- elegant
- soft
- emotional
- minimal
- mobile-first
- photo-focused
- premium invitation style

Avoid:
- corporate landing-page feeling
- heavy UI components
- childish icon decorations
- excessive animations
- bright saturated colors
- too many sections without emotional purpose

## Current Layout Direction

The current `index.html` is simplified and should be treated as the active design direction.

Current public sections:
1. Hero photo with graduation text image.
2. Name section.
3. Quote.
4. Event time/location block.
5. Guestbook form.
6. Countdown.
7. Thank-you image.

Do not automatically restore older sections:
- full calendar
- album section
- detailed timeline
- three-photo invitation section

Those may exist in previous CSS/config fragments, but they are not part of the current active page unless explicitly requested.

## Canvas and Responsiveness

Primary target:
- phone screen
- 390px visual width
- still responsive up to 430px
- desktop should center the mobile page

Current behavior:
- `.mobile-page` is the main phone-like canvas.
- Mobile viewport is more important than desktop.
- Topbar and floating buttons are optimized for small screens.

When editing:
- Test at 390px width.
- Test at 360px width.
- Do not create horizontal scrolling.
- Keep tap targets comfortable.

## Typography

Current fonts loaded:
- `Allura`
- `Great Vibes`
- `Playfair Display`
- `Be Vietnam Pro`
- `Oswald`
- `Roboto Condensed`

Usage guidance:
- Use `Allura` / `Great Vibes` for emotional display text.
- Use `Playfair Display` for elegant serif titles and countdown numbers.
- Use `Be Vietnam Pro` for readable Vietnamese body text.
- Use `Oswald` or `Roboto Condensed` for small uppercase labels if needed.

Avoid:
- too many font sizes in one section
- uppercase for long Vietnamese paragraphs
- script font for long text
- font sizes too small for mobile readability

## Color Direction

Core colors:
- white
- cream
- soft gray
- charcoal
- muted rose/pink accent

Suggested CSS color roles:
- background: `#fff`, `#f7f7f6`, `#fbfaf7`
- text: `#2f3033`, `#2b2d31`, `#3c3f44`
- muted text: `#70757c`, `#7c7f84`
- lines: `#cfd1d4`, `#9da1a6`
- rose accent: `#c9837c`, `#cf8d86`

Use rose accent sparingly:
- active date
- small labels
- highlight states
- statistics

## Images and Assets

Current referenced assets:
- `assets/ueb-logo-transparent.png`
- `assets/music.mp3`
- `assets/photo1.jpg`
- `assets/photo11.jpg`
- `assets/photo12.jpg`
- `assets/graduation-ceremony-text-crop.png`
- `assets/bg-silk.png` in CSS

Do not rename or move assets unless requested.

Image guidance:
- Hero image should stay emotional and full-width.
- Use `object-fit: cover`.
- Adjust `object-position` carefully.
- Avoid over-darkening hero.
- Keep overlay enough for text readability.

## Topbar

Current topbar includes:
- UEB logo home link
- toolbar title
- theme toggle
- music button
- hamburger button

Rules:
- Keep topbar stable on small screens.
- Avoid overlapping music/theme/menu buttons.
- Do not move Admin out of the menu unless explicitly requested.
- Menu may include Admin because production security will be handled by real auth.
- Do not rely on hiding the Admin menu as security.

## Music Button

Current music button:
- uses `assets/music.mp3`
- toggles between `♫` and `Ⅱ`
- handles browser playback failure with alert

Rules:
- Keep user-initiated playback.
- Do not autoplay audio.
- Do not break the button if the music file is missing.

## Theme Toggle

Current code stores theme preference in:
- `localStorage` key: `graduation-theme`

Rules:
- Keep dark mode readable.
- Do not let dark mode ruin photo overlays or form contrast.
- If changing colors, test both light and dark.

## Guestbook Design

Current guestbook includes:
- photo/card hero using `photo11.jpg`
- dark card label `Sổ lưu bút`
- name input
- message textarea
- attendance select
- submit button
- thank-you text

Rules:
- Keep form simple.
- Do not ask for phone/email unless explicitly requested.
- Keep copy warm and personal.
- Keep form controls easy to tap on mobile.
- Do not show public guestbook list on `index.html`.

## Countdown

Current countdown:
- heading `Time`
- format: days : hours : minutes : seconds
- no labels under each number

Rules:
- Keep minimal and elegant.
- If event time changes, update `script.js` and visible copy consistently.

## Admin Page Style

Admin page should feel connected to the public invitation:
- same soft/cream background
- same typography family
- clean card layout
- not like a generic admin panel

Current admin card:
- brand logo
- `Góc của Quỳnh`
- username/password demo inputs
- dashboard stats
- guestbook list

Future production:
- replace username/password demo with Google Login or real auth UI.
- show authorized user identity.
- keep UI warm and simple.

## Gift Page Style

Gift page should feel private and emotional:
- minimal text
- locked countdown state
- final message/card after unlock
- no clutter

Future production:
- keep public locked shell clean.
- load private content only after successful auth and permission check.

## Animation and Effects

Current style includes:
- old petal layer code, currently hidden in later CSS
- topbar title reveal
- active-day pulse code from older calendar
- possible silk background image usage
- smooth transitions

Rules:
- Animation must be subtle.
- Do not add heavy JavaScript animations.
- Use CSS animations only when light.
- Respect `prefers-reduced-motion` in new animation work.
- Avoid constantly animated elements over text.

## CSS Maintenance

Current `style.css` has many historical sections and overrides.

Rules for small tasks:
- Add a clearly labeled section near the end:
  ```css
  /* Feature/Fix: short description */
  ```
- Avoid editing old duplicated rules unless necessary.
- Use minimal `!important`.
- If using `!important`, explain why.

Rules for larger cleanup:
- First create a refactor plan.
- Separate base, layout, components, pages, utilities, and overrides.
- Verify no existing page breaks.

Suggested future organization:
```css
/* 1. Tokens */
:root {}

/* 2. Reset/Base */

/* 3. Shared Layout */

/* 4. Topbar/Menu */

/* 5. Index Sections */

/* 6. Guestbook */

/* 7. Admin */

/* 8. Gift */

/* 9. Dark Mode */

/* 10. Responsive */

/* 11. Temporary Overrides */
```

## Accessibility

Keep:
- meaningful `alt` text
- visible focus states
- readable contrast
- button `aria-label` where icon-only
- links/buttons semantically correct

Do not:
- use click handlers on non-interactive elements when a button/link is appropriate
- hide focus outlines without replacement
- make text too low contrast over images
