# Appliify — Design System & Visual Identity (UI/UX Specification)

> Companion to [`../SRS.md`](../SRS.md) §77. Covers what §47 (Mobile Application SRS) and §49 (Merchant Dashboard) deliberately left out: the **visual and interaction layer** — the token architecture, the full component library, native-shell interaction behavior, and screen-level wireframe intent for every screen already named in §47.1 and the §49 screen table. This document does not introduce new screens or new functional requirements; it specifies how the existing, already-approved screen list should look, feel, and behave, in every state, on every platform (Salla, Shopify, Zid, WooCommerce, or any future connector).
>
> **On color and typography:** this document deliberately defines **no fixed color values and no fixed typeface choices**. Appliify's own brand identity (used by the Merchant Dashboard) and the white-label branding system (used by the Shopper Mobile App, per merchant) are being defined separately and are out of scope here. What follows is the *token architecture* — the named slots, their roles, and the rules governing how they're used — so that whatever palette and type choices are supplied later, the system already knows exactly where they plug in and how every component behaves in every state. A developer should be able to build 100% of the interaction and layout logic in this document today, and drop in real values the moment they exist, with zero rework.
>
> **Status:** v2.0 — token-architecture pass. Supersedes v1.0, which incorrectly hardcoded a specific palette; that palette has been fully removed.

---

## 1. Core Product Mechanic (read this first)

Everything below assumes the same underlying mechanic, stated plainly so no screen or component spec drifts from it:

- The Shopper Mobile App is a **native app shell wrapping a WebView** that renders the merchant's actual live store (Salla, Shopify, Zid, WooCommerce, or any future platform connector). The store's product catalog, pricing, and checkout are the store's own web content, loaded live inside the shell.
- Native UI — navigation, CRO overlays, push notifications, status bar/system chrome — is layered **on top of** that WebView by the native shell, via the mobile bridge (SRS §48). None of the native layer lives inside the web page itself.
- Every merchant gets **their own compiled app** (their own package/bundle identity, their own branding baked in at build time), delivered as an installable Android package within a 42–48 hour turnaround from onboarding, then published under the merchant's own developer/publisher identity. This is a **per-merchant build model**, not one shared app shell serving all merchants (this resolves SRS §33 open question OQ-01 in favor of per-merchant builds).
- The product requirement driving this entire document: **the result must feel like a genuinely native mobile app to the shopper — never like a browser or a wrapped website.** Every section below exists to make that true in a concrete, buildable way, not as a slogan.

---

## 2. Design Philosophy

1. **Evidence-first hierarchy.** Every screen that reports a number Appliify is proud of (attribution %, revenue, open rate) gives that number the largest, highest-contrast treatment on the screen — this is the product's core sales argument (PRD §4.2, FR-E00), and layout must reflect that priority regardless of which palette is applied later.
2. **Disclosure is a first-class UI element, not a footnote.** Because BR-040/FR-E00's attribution figure is explicitly a *simplified* methodology (§30), every screen showing it must render its methodology disclosure with real visual weight (a bordered, legible note — never fine print small enough to be skimmed past).
3. **Consistency over novelty per screen.** Every screen reuses the same token set and the same handful of components. No screen invents its own spacing, its own card shape, or its own one-off pattern.
4. **Silence is a feature.** Empty states, loading states, and low-data states are designed moments, not afterthoughts — a merchant's first day using the product (zero data) must feel as considered as their busiest day.
5. **One primary action per screen.** If a screen has more than one competing primary-emphasis button, the hierarchy has failed — demote everything except the single most important action to a secondary/tertiary treatment.
6. **Numbers earn their format.** Currency, percentages, and counts each have one canonical display format (§4.5) used everywhere — a merchant should never see "17%" in one place and "17.00%" in another for the same metric.
7. **Native feel is the default assumption, not an enhancement.** Every interaction spec in this document (§5, §6) assumes the shopper should never be able to tell that a WebView is involved at all.

### 2.1 Brand voice (for UI copy, not just visuals)

| Attribute | Do | Avoid |
|---|---|---|
| Tone | Calm, precise, confident | Hype, exclamation marks, growth-hacker slang |
| Numbers | State the figure plainly, then the caveat if one exists | Round up optimistically, bury the caveat |
| Errors | Explain what happened and what to do next | Blame the user, show raw stack traces |
| Empty states | Frame as an opportunity ("Send your first push") | Apologize ("Sorry, nothing here yet") |

---

## 3. Token Architecture

Tokens are named slots, not values. No component or screen spec below references a raw color or a specific typeface — every visual property is a token reference, resolved at build/config time from one of two sources:

- **Dashboard tokens** resolve from Appliify's own brand guidelines (a single fixed set, maintained outside this document, applied once across the whole Merchant Dashboard).
- **Mobile App tokens** resolve **per merchant**, supplied through the Branding & Appearance screen (§8.6) and baked into that merchant's build at APK-generation time. The same token name can therefore render differently for every merchant's installed app — that is the intended behavior of a white-label product, not a bug.

A developer implementing against this document needs a token-resolution layer (e.g. CSS custom properties / a theme object) that maps every token name below to a real value per surface, rather than any component hardcoding a value directly.

### 3.1 Color role tokens (names and usage rules only — no values)

| Token | Role | Usage rule |
|---|---|---|
| `color/bg/base` | Primary background | App/dashboard background |
| `color/bg/surface` | Card/container background | Cards, sidebars, modals, table rows — must be visually distinct from `bg/base` by contrast or a subtle tone shift, however the two are ultimately colored |
| `color/bg/surface-raised` | Elevated container background | Popovers, dropdown menus, anything that sits visually above a card |
| `color/bg/overlay-scrim` | Modal/sheet dimming layer | Always a translucent version of `bg/base`, never a flat unrelated color |
| `color/accent/primary` | Primary brand accent | Primary buttons, active nav state, key numbers/metrics, focus rings, links. Reserved for meaningful actions/values — never used as decorative fill. |
| `color/accent/primary-hover` | Primary accent, interaction state | Hover/pressed state of any `accent/primary` element |
| `color/accent/primary-muted` | Primary accent, low-emphasis fill | Selected-chip backgrounds, subtle highlight washes |
| `color/accent/secondary` | Positive/success signal | Stock-available, success, positive-delta indicators **only** — never used as a general-purpose second brand color |
| `color/accent/secondary-muted` | Positive signal, low-emphasis fill | Success badge backgrounds |
| `color/accent/danger` | Negative/error signal | Errors, destructive-action confirmation, failed states **only** |
| `color/accent/danger-muted` | Negative signal, low-emphasis fill | Error banner backgrounds |
| `color/text/primary` | Primary text | Headings, primary body text — must meet WCAG AA against `bg/base` and `bg/surface` regardless of the values chosen |
| `color/text/secondary` | Secondary text | Captions, timestamps, helper text — must independently meet WCAG AA at the sizes it's actually used at (§7.1); do not assume a value is safe just because `text/primary` passes |
| `color/text/disabled` | Disabled-state text | Disabled labels, inactive nav items |
| `color/text/on-accent` | Text rendered on a solid `accent/primary` fill | Must be contrast-checked against the actual chosen `accent/primary` value — do not assume white or black is automatically safe; whichever passes contrast for that specific accent value is correct |
| `color/border/hairline` | Default low-emphasis border | Card/divider borders — the default depth cue; this system uses borders instead of drop shadows for all elevation (§4.4) |
| `color/border/hairline-strong` | Emphasized border | Focused/active/selected card and input borders |
| `color/border/neutral` | Structural divider | Table row separators, list dividers where a brand-accent border would be visual noise rather than meaningful signal |

**Mandatory validation rule:** whatever real values are eventually assigned to these tokens (Appliify's own brand for the dashboard; each merchant's chosen brand for their app), every `text/*` vs `bg/*` and `text/on-accent` vs `accent/primary` pairing **must pass an automated WCAG AA contrast check before being allowed to go live** — this applies especially to the Branding & Appearance screen (§8.6), which must run this check on whatever colors a merchant picks and block APK generation until it passes, or show a clear warning if the merchant proceeds anyway.

### 3.2 Typography tokens (roles only — no typeface names)

| Token | Role | Notes |
|---|---|---|
| `type/display-l` | Hero metric numbers (attribution %, revenue figures) | Largest, highest-emphasis number style on any screen it appears on (§2, principle 1) |
| `type/display-m` | Screen-level headlines | |
| `type/display-s` | Section headings within a screen | |
| `type/body-l` | Primary reading text, form labels | |
| `type/body-m` | Default UI text, table cells, list items | |
| `type/body-s` | Captions, timestamps, helper/error text | |
| `type/label` | Button labels, nav labels, badge text | Distinguish from `body-*` by weight/tracking, not necessarily size |
| `type/mono` | Order IDs, correlation IDs, audit-log technical values only | A monospaced typeface is required here regardless of brand choice, for scannability of IDs |

Whether `display-*` tokens use a different typeface family from `body-*`/`label` tokens, or the same family at different weights, is a brand decision made outside this document — the role separation above must be preserved either way (dense UI text — forms, tables — should never use whatever typeface is chosen for hero numbers if that choice hurts scanability at small sizes).

### 3.3 Spacing scale

A single 4px base unit, used consistently instead of ad-hoc padding values — this is a structural system, independent of brand:

| Token | Value | Typical usage |
|---|---|---|
| `space/1` | 4px | Icon-to-label gap |
| `space/2` | 8px | Tight internal padding (chip, badge) |
| `space/3` | 12px | Form field internal padding |
| `space/4` | 16px | Default gap between related elements |
| `space/6` | 24px | Card internal padding (minimum) |
| `space/8` | 32px | Gap between distinct sections on a screen |
| `space/12` | 48px | Page-level top/bottom margins (dashboard) |
| `space/16` | 64px | Generous hero-section breathing room |

### 3.4 Shape, elevation, iconography

| Token | Suggested default | Notes |
|---|---|---|
| `radius/card` | 16–20px | Override per brand if needed; keep consistent across all cards on a given surface |
| `radius/button` | 12px (or a fully rounded 999px pill) | Pick one button shape system-wide, don't mix |
| `radius/input` | 10px | |
| `radius/chip-badge` | 999px (fully rounded) | |
| `radius/sheet-top` | 24px (mobile bottom sheets, top corners only) | |
| `elevation` | Border-based, not shadow-based | Depth is communicated via `border/hairline` (default) and `border/hairline-strong` (focused/raised) plus a one-step lightening from `bg/surface` to `bg/surface-raised` — no drop shadows, regardless of brand |
| `icon/style` | Consistent stroke-width line icons OR consistent filled icons — pick one system-wide | Never mix line and filled icon styles on the same surface |
| `icon/size/s` | 16px — inline with body text | |
| `icon/size/m` | 20px — default UI icon (nav, buttons) | |
| `icon/size/l` | 28px — empty-state illustrations, feature icons | |
| `touch-target/min` | 44×44px minimum for any tappable element on mobile | Non-negotiable regardless of visible icon size — see §7.3 |

### 3.5 Motion

| Token | Value | Usage |
|---|---|---|
| `motion/duration/fast` | 120ms | Toggle switches, button press feedback |
| `motion/duration/base` | 200ms | Screen transitions, modal open/close |
| `motion/duration/slow` | 320ms | Chart animations, hero-number count-up |
| `motion/easing/standard` | cubic-bezier(0.2, 0, 0, 1) | Default for all transitions |
| `motion/reduced` | Collapses all of the above to an 80ms fade | Applied automatically when the OS-level "reduce motion" accessibility setting is on (§7.4) |

### 3.6 Number and currency formatting

| Data type | Canonical format | Example |
|---|---|---|
| Attribution / percentage metrics | One decimal place, always | `17.4%` |
| Currency | Merchant's store currency symbol, thousands separator, no decimals for whole amounts | `SAR 12,480` |
| Counts (installs, users) | Abbreviated above 10,000 | `1,204` / `12.4K` |
| Dates in tables | `DD Mon YYYY` | `14 Sep 2026` |
| Relative timestamps (notifications) | Relative under 24h, absolute after | `3 hours ago` → `12 Sep, 4:02 PM` |

---

## 4. Component Library

Every component below is specified across its required states: **default, hover (web only), pressed/active, focus, disabled, loading, and error** where applicable, using token references only. A component is not implementation-complete until every listed state exists.

### 4.1 Buttons

| Variant | Default | Hover/Press | Disabled | Loading |
|---|---|---|---|---|
| Primary | `accent/primary` fill (using `accent/primary-hover` on interaction), `text/on-accent` label | Fill shifts to `accent/primary-hover` | ~40% opacity, not tappable | Label replaced by a spinner in `text/on-accent`, button width unchanged |
| Secondary (ghost) | Transparent fill, `border/hairline-strong`, `text/primary` label | Fill becomes `accent/primary-muted` | Border becomes `border/neutral`, label `text/disabled` | Same spinner treatment in `text/primary` |
| Tertiary (text link) | `accent/primary` text, no border/fill | Underline appears | `text/disabled`, no underline | N/A — tertiary actions never carry async loading |
| Icon button | 44×44px touch target (§3.4), `icon/size/m` centered, transparent | Background becomes `bg/surface-raised` | Icon becomes `text/disabled` | Icon replaced by spinner at same size |
| Destructive | Same shape as Primary, fill uses `accent/danger` instead of `accent/primary` | Darkens slightly | Same disabled treatment | Same spinner, contrast-checked against `accent/danger` |

**Rule:** exactly one Primary button visible per screen or modal at a time (§2, principle 5). Everything else demotes to Secondary or Tertiary.

### 4.2 Form inputs

| Component | Default | Focus | Error | Disabled |
|---|---|---|---|---|
| Text field | `bg/surface`, `radius/input`, `border/neutral`, `text/primary` value, `text/secondary` placeholder | Border becomes `border/hairline-strong` with a focus ring in `accent/primary` | Border becomes `accent/danger`, helper text below in `accent/danger` | `bg/surface` at reduced opacity, `text/disabled` |
| Dropdown / select | Same as text field + chevron icon | Same focus ring; open state shows options on `bg/surface-raised` | Same error border | Same disabled treatment, chevron in `text/disabled` |
| Checkbox | Outlined square, `border/neutral`, small radius | Focus ring in `accent/primary` | N/A | Outline `text/disabled`, no fill |
| Checked checkbox | `accent/primary` fill, `text/on-accent` check glyph | — | — | `accent/primary` at reduced opacity |
| Toggle switch | Track outlined only when off; `accent/primary` fill when on. **Always paired with an explicit "On"/"Off" text label** — never a color-only signal (§7.2) | Focus ring around the whole switch | N/A | Track and label at `text/disabled` |
| Slider (e.g. price range filter) | `accent/primary` fill up to handle position, `border/neutral` remainder | Handle shows emphasis while dragging | N/A | Entire track/handle at `text/disabled` |
| Date/time picker | Text-field trigger + calendar popover on `bg/surface-raised`, selected date in `accent/primary-muted` fill | Focus ring on trigger field | Same error pattern as text field | Same disabled treatment |

### 4.3 Cards

| Type | Spec |
|---|---|
| Standard card | `bg/surface`, `radius/card`, `border/hairline`, minimum `space/6` internal padding |
| Interactive card (tappable/clickable) | Adds `border/hairline-strong` and a subtle upward translate on hover (web) or press (mobile) |
| Selected card (e.g. platform-selection during onboarding) | `border/hairline-strong` + `accent/primary-muted` background wash |
| Metric/KPI card | Standard card + a `type/display-s` or `type/display-l` number as the dominant element, label above/below in `type/body-s`/`text/secondary`, optional trend indicator (small directional arrow in `accent/primary` or `accent/secondary`) |

### 4.4 Navigation

| Component | Spec |
|---|---|
| Mobile bottom navigation | 5 icons max (`icon/size/m`), fixed to bottom, `bg/surface` with a `border/neutral` top hairline. Active item: icon/label in `accent/primary` plus a small underline indicator. Inactive: `text/secondary`. Must be a **native** component, not rendered inside the WebView (§5). |
| Dashboard sidebar | Fixed left, `bg/surface`, wordmark/logo at top, vertical list of icon + label rows. Active item: `accent/primary-muted` background wash, `accent/primary` left-border accent, `accent/primary` icon/label. Collapses to icon-only rail at the tablet breakpoint (§9). |
| Tab bar (e.g. Push Composer vs Push History) | Underline-style tabs, active tab in `accent/primary` with an underline, inactive in `text/secondary` |
| Breadcrumb (dashboard drill-down views) | `text/secondary` separated by `/`, current page in `text/primary`, `accent/primary` only on hover of a clickable crumb |

### 4.5 Overlays

| Component | Spec |
|---|---|
| Modal (desktop) | Centered, `bg/surface`, `radius/card`, max-width 480–640px depending on content, `bg/overlay-scrim` behind, always shows an explicit close affordance (never dismiss-on-outside-click only) |
| Bottom sheet (mobile) | Slides up from bottom, `radius/sheet-top` on top corners only, `bg/overlay-scrim` behind, drag-handle indicator at top center. **Native component**, not a WebView-rendered sheet. |
| Toast / inline confirmation | Top (mobile) or bottom-right (dashboard), `bg/surface-raised`, `border/hairline`, auto-dismisses after 4s unless it carries an action (e.g. "Undo") |
| Tooltip | `bg/surface-raised`, `type/body-s`, hover (web) or long-press (mobile); never the sole carrier of required information (§7.2) |

### 4.6 Data display

| Component | Spec |
|---|---|
| Table | `bg/surface` rows separated by `border/neutral` (structural, not brand-accent), header row in `type/label`/`text/secondary`, sortable columns show a chevron on hover |
| Chart | One consistent color for the "Appliify/app" data series (`accent/primary`), one consistent neutral color for the "baseline/total store" comparison series (`text/secondary`-derived); `accent/secondary` reserved for a single positive-delta annotation only, never a full series |
| Badge / tag | `radius/chip-badge`, outlined by default; semantic fill only when meaningful: `accent/secondary-muted` = positive, `accent/primary-muted` = neutral highlight, `accent/danger-muted` = negative |
| Progress indicator (e.g. onboarding steps) | Connected dots/line, completed steps solid `accent/primary`, current step outlined `accent/primary`, upcoming steps `border/neutral` |
| Avatar | Circular, initials on an `accent/primary-muted` background when no image is set — never a generic grey silhouette |

### 4.7 Feedback states (every data screen requires all four)

| State | Spec |
|---|---|
| Loading | Skeleton screens matching the final layout's shape (`bg/surface-raised` pulsing blocks), not spinners, for any screen showing data (Overview, Analytics, tables). Spinners are reserved for button-level async actions only. |
| Empty | Centered `icon/size/l` illustration + `type/display-s` headline + one supporting sentence + exactly one Primary action (§2, principle 4). Never a blank space. |
| Error | A bordered notice card (`accent/danger-muted` background, `accent/danger` icon), plain-language explanation, a correlation ID in `type/mono` for support reference, and a "Retry" action where retrying is possible |
| Success | Brief toast (§4.5) or, for major actions (order placed, app connected), a full dedicated success screen |

---

## 5. Native-Feel WebView Architecture (mandatory interaction rules)

This section exists specifically because the product must never read as a wrapped website. Every rule below is a concrete, testable requirement — not a stylistic aspiration.

| Concern | Requirement |
|---|---|
| Browser chrome | No address bar, no default browser navigation buttons, no visible WebView frame border of any kind. The WebView renders only the store's content area. |
| Status bar & system nav bar | Must adopt the current screen's brand background color (light or dark status-bar icon variant chosen automatically based on the background's luminance) — a merchant's app should never show a mismatched system-default status bar color while their own brand color runs beneath it. |
| Splash → content handoff | The native splash screen's background must exactly match the app's brand background token, so there is zero flash or color mismatch during the handoff into the loaded WebView content. |
| Overscroll / bounce | Native pull-to-refresh only, with a native indicator — the browser's default overscroll bounce/rubber-banding must be disabled at the WebView level. |
| Bottom navigation, header, CRO overlays | All rendered as **native components** layered over the WebView via the mobile bridge (SRS §48), never as DOM elements inside the web page — this guarantees consistent 60fps behavior independent of the underlying store site's own performance or theme, and guarantees the CRO overlays (countdown, stock scarcity, social proof — §8.4) look and behave identically across every merchant regardless of how their underlying store's own website is built. |
| Back navigation | Hardware back button (Android) and edge-swipe-back (iOS) must first navigate the app's own native stack (close a modal, pop a native screen); only fall through to WebView history when there is a real underlying page to return to. A WebView with no further back-history must never leave the shopper stuck on a dead page — it should return to Home. |
| Loading transitions | A native skeleton (§4.7) is shown by the shell while the WebView content is fetching; a bare blank/white WebView flash must never be visible. |
| Connectivity loss | A native offline-state screen (icon, message, Retry button — §4.7 Empty/Error pattern) replaces the browser's default "no internet" page when the store site is unreachable. |
| Deep links (from push notifications, §6.10 in SRS §47) | Always route through the native shell's own navigation layer, which then resolves the correct in-app destination — never a raw external URL open that would expose browser chrome even momentarily. |
| Session/session continuity | Returning to the app after backgrounding must resume exactly where the shopper left off (native state), not reload the WebView from scratch, unless the underlying session has genuinely expired. |

---

## 6. Per-Merchant App Identity & Branding Asset Pipeline

Because every merchant receives their own compiled, independently branded app (§1), the Branding & Appearance screen (§8.6) is not just a preferences panel — it is the **required input gate** for the APK build pipeline. Nothing below is optional; an incomplete submission here should block build generation rather than produce a broken or generically-branded app.

### 6.1 Required assets per merchant, before a build can be generated

| Asset | Notes |
|---|---|
| App display name | Shown under the icon on the shopper's home screen |
| Unique package / bundle identifier | System-generated suggestion from the merchant's store name, with merchant override allowed; must be validated as unique before build |
| App icon | Full required size set for both the Android adaptive-icon format and the iOS icon set — a single low-res upload is not sufficient input |
| Splash logo asset | Vector or high-resolution raster; used against the `color/bg/base` value this merchant has chosen |
| Brand color values | At minimum `accent/primary` (§3.1); the Branding screen should offer sensible token defaults for everything else so a merchant isn't forced to configure all ~15 color tokens individually, while still allowing full override |
| Contrast validation pass | Every color the merchant picks is checked against the WCAG rule in §3.1 before "Generate App" is enabled; a failing pair blocks the action with a plain-language explanation, not just a color-picker warning icon |

### 6.2 Build/delivery status visibility

The merchant-facing product commits to a 42–48 hour turnaround for producing the app build. This is a build-and-signing SLA, and is **distinct from store review/approval time**, which Appliify does not control (Google Play's first-time publisher review and Apple's App Store review both run on their own timelines, frequently longer than 48 hours). To avoid setting an incorrect expectation, the dashboard must show a multi-step status, not a single "delivered" state:

1. **Building** — assets validated, app compiling
2. **Built & signed** — installable package ready (this is what the 42–48h commitment covers)
3. **Submitted for store review** — handed to the relevant store's review process
4. **Live** — published and installable by end shoppers

Each step is a distinct, visible state in the dashboard (reusing the state patterns in §4.7), so a merchant checking on day 2 sees exactly where their app is, rather than inferring it from silence.

---

## 7. Screen-Level Wireframe Specification — Shopper Mobile App

Maps 1:1 to the screen list in SRS §47.1. Every element below references tokens (§3) only.

### 7.1 Splash
- **Layout:** full-bleed `bg/base`, centered lockup, no navigation chrome.
- **Elements:** merchant's logo/wordmark in `text/primary`; a slim progress indicator in `accent/primary`.
- **Behavior:** background must exactly match the value used immediately after in the Home screen's `bg/base`, per §5.

### 7.2 Home (storefront)
- **Layout (top → bottom):** sticky header → hero promotional card → horizontal category chip row → product grid → bottom navigation.
- **Header:** merchant logo/wordmark left; search icon and cart icon (`icon/size/m`) right, cart icon shows an `accent/primary` badge with item count when non-empty.
- **Hero card:** interactive card (§4.3), may contain a promotional message.
- **Category chips:** pill-shaped, `bg/surface` default, `accent/primary-muted` fill + `accent/primary` text when selected.
- **Product grid:** each card shows product image, name (`type/body-m`, `text/primary`), price (`type/body-m`, `accent/primary`), and an optional stock-scarcity tag (`accent/secondary-muted` badge) when applicable.
- **Bottom nav:** Home / Search / Wishlist / Cart / Account, per §4.4.

### 7.3 Category / Search
- **Layout:** sticky header with the search field expanded and focused → filter chip row → product grid (identical card component to Home) → bottom nav.
- **Filter chips:** tapping opens the Filters bottom sheet (§4.5) with a price-range slider, category checkboxes, and an availability toggle.
- **Empty result state:** standard Empty pattern (§4.7), action "Clear filters."

### 7.4 Product Detail
- **Layout:** full-width product image → floating back/wishlist icons over the image → title/price/rating block → **mandatory CRO overlay zone** → expandable description accordion → sticky add-to-cart bar.
- **CRO overlay zone (non-negotiable, positioned directly under price, rendered as a native overlay per §5):**
  - Countdown timer: a pill showing remaining time, shown only while an active countdown exists for this product.
  - Stock scarcity: `type/body-s` text with an `accent/secondary` indicator dot, shown only below the merchant-configured threshold.
  - Social proof: a floating card near the image's lower edge with an avatar and recent-purchase text, auto-rotating if multiple events exist.
  - These three elements are the product's core competitive differentiator (BRD §2.3) and must never be omitted, generalized into a single generic badge, or visually deprioritized relative to the rest of the screen.
- **Sticky bottom bar:** quantity stepper + full-width Primary "Add to Cart" button.

### 7.5 Cart
- **Layout:** vertical list of line-item cards → order summary block → sticky checkout bar.
- **Line item:** thumbnail, name, selected variant (`text/secondary`), quantity stepper, price (`accent/primary`), icon-button remove action.
- **Order summary:** subtotal → discount line (`accent/secondary` if a coupon applies) → divider (`border/neutral`) → total in `type/display-s`.
- **Empty state:** standard pattern (§4.7), action "Start Shopping."

### 7.6 Checkout
- **Layout:** 3-step progress indicator (Shipping → Payment → Review, §4.6) → form (§4.2) → collapsed order-summary accordion → sticky continue bar.
- **Note:** this screen wraps the store's native checkout flow (PRD §11); the shell still renders the step indicator natively so the shopper never loses orientation mid-flow, and never sees raw store-site checkout chrome unstyled by the shell.

### 7.7 Order Confirmation
- **Layout:** centered success state (§4.7) → order number and delivery estimate (`text/secondary`) → order summary card with an `accent/secondary-muted` "Payment confirmed" badge → two actions ("Track Order" primary, "Continue Shopping" tertiary).

### 7.8 Wishlist
- **Layout:** header → product grid (same card as Home, plus a filled `accent/primary` heart icon top-right) → bottom nav.
- **Out-of-stock items:** show a Secondary "Notify me" button instead of a price/add-to-cart affordance.
- **Empty state:** standard pattern, action "Browse products."

### 7.9 Notification Inbox
- **Layout:** header → vertical list of notification cards → bottom nav.
- **Notification card:** type-specific icon (offer / restock / wishlist), `type/body-m` title, `type/body-s` relative timestamp, `border/neutral` divider between items, unread items marked with an `accent/primary` dot on the leading edge.

### 7.10 Notification Detail / deep link
- **Layout:** context label ("Reminder," `text/secondary`) → headline restating the offer → referenced product teaser card (reuses the Product Detail card pattern, with countdown if applicable) → sticky "Go to Cart" primary button.
- **Behavior:** reached exclusively through the native deep-link routing described in §5, never a raw URL open.

### 7.11 Account / Profile
- **Layout:** avatar/name header → vertical menu list → bottom nav.
- **Menu rows:** Order History, Wishlist, Saved Addresses, Payment Methods, Notification Settings, Help & Support, Sign Out — each a list row with a leading icon and trailing chevron.

### 7.12 Sign In / Register
- **Layout:** headline → email/password fields (§4.2) → Primary "Sign In" button → tertiary "Create an account" link → tertiary "Continue as guest" link.

---

## 8. Screen-Level Wireframe Specification — Merchant Dashboard

Maps 1:1 to the screen table in SRS §49, including Segments, Settings, and Audit.

### 8.1 Login / Auth
- **Layout:** centered card (max-width ~440px) on full-bleed background, wordmark above it.
- **Elements:** email/password fields, "Forgot password?" tertiary link, Primary "Sign In" button, tertiary "Create an account" link below the card.

### 8.2 Onboarding — Select Platform
- **Layout:** headline ("Which platform is your store on?") → selectable cards for each supported platform (Salla / Shopify / Zid / WooCommerce / others as connectors ship, §4.3 selected-card treatment) → Primary "Continue" (disabled until a platform is chosen).

### 8.3 Onboarding — Connect Store
- **Layout:** numbered step list → Primary "Connect with [Platform]" button with the platform's icon → a `text/secondary` security note clarifying the scope of access requested.

### 8.4 Onboarding — App Preview Ready
- **Layout:** split screen — left: realistic phone-frame mockup showing the generated storefront app; right: headline, short description, `accent/secondary-muted` "Catalog synced — N products imported" badge, Primary "Continue to Dashboard" button.

### 8.5 Overview
- **Layout:** sidebar (§4.4) → top bar (platform-connection status pill + profile avatar) → row of KPI metric cards (§4.3: Installs, Active Users, Push Open Rate, App-Attributed Revenue) → trend chart (§4.6) → recent-activity list card.
- **Hierarchy rule:** the App-Attributed Revenue KPI card is always the visually largest of the four (§2, principle 1).
- **Day-1 / empty state:** KPI cards show placeholders with a `text/secondary` note ("Data will appear within 24 hours") and a centered prompt card driving toward "Compose your first push" — mandatory, not an edge case to skip.

### 8.6 Branding & Appearance
- **Layout:** split screen — left: form covering every asset in §6.1 (logo/icon upload, color token pickers, splash logo, app name, package identifier); right: a live phone-frame preview that updates in real time as the merchant edits the form.
- **Sub-screen — App Identity & Build:** shows the §6.2 build-status stepper (Building → Built & signed → Submitted → Live) and a "Generate App" action that is disabled until the §3.1 contrast-validation pass succeeds on all chosen colors.

### 8.7 Store / Integration
- **Layout:** connected-platform card (platform name/icon, sync status, last-synced timestamp) → connect/disconnect/resync actions.
- **Mandatory element:** a visible plain-language notice whenever a feature is limited by the connected platform's API (BR-015) — never hidden in a tooltip.

### 8.8 CRO Toolkit
- **Layout:** grid of tool cards (icon, name, one-line description, toggle switch per §4.2) for each CRO feature (Countdown Timer, Stock Scarcity Counter, Social Proof Popups, Abandoned Cart Recovery, Sticky Discount Bar, Wishlist Back-in-Stock Alerts).
- **Sub-screen — tool configuration:** opened by tapping an active tool card; form fields specific to that tool (e.g. countdown start/end/target product) plus a live preview styled identically to how it renders in Product Detail (§7.4).

### 8.9 Push Composer & History
- **Composer layout:** form (title, body, optional image, deep-link target dropdown) on the left; a live notification preview on the right, updating as the merchant types; segment selector chips below the form.
- **History layout:** a table (§4.6) of sent notifications — title, sent date, delivery count, open rate, attributed-conversion count — with date-range and segment filter controls above it.

### 8.10 Segments
- **Layout:** list of saved segments (name, member count) → a builder panel using the same condition-chip interaction pattern as the Composer's segment selector.

### 8.11 Analytics
- **Layout:** date-range control → grid of charts (funnel, engagement, session metrics), following the chart color rule in §4.6 throughout.

### 8.12 Attribution
- **Layout:** hero metric card (attribution percentage, `type/display-l`) → comparison chart (app-attributed vs. total revenue) → a bordered methodology-disclosure card with an expandable "How is this calculated?" link.
- **Mandatory:** the disclosure card carries real visual weight — border, icon, legible body text — never rendered as small fine print (§2, principle 2). Any platform-specific limitation (e.g. a connector where order-session linkage is unsupported) is disclosed in this same card, not a separate help article.

### 8.13 Billing & Plan
- **Layout:** current-plan card (plan name, price, "Manage Subscription" secondary button) → invoice history table (date, amount, status badge) → team member list (avatar, name, role badge) → "Invite Team Member" Primary button.
- **Sub-screen — Invite Team Member modal:** email field, role selector presented as two selectable explainer cards (Admin vs. Staff, mapped exactly to SRS §9 RBAC).

### 8.14 Users
- **Layout:** member table with role badges (Admin: `accent/primary`-outlined; Staff: neutral-outlined) matching §9 RBAC exactly, and a remove action per row (destructive, requires confirmation per §4.7/§47.2).

### 8.15 Settings
- **Layout:** grouped settings sections (store configuration fields per SRS §49) using standard form components (§4.2); any destructive action opens a confirmation modal before executing.

### 8.16 Audit
- **Layout:** filterable table (date range, actor, action type) reflecting the audit log fields defined in SRS §53 directly — timestamp, actor, action, target. Read-only; no actions are available from this screen.

**Cross-cutting rule (all dashboard screens):** every data screen renders the full loading/empty/error/success state set from §4.7.

---

## 9. Responsive Behavior (Dashboard — web only)

| Breakpoint | Sidebar | Layout |
|---|---|---|
| ≥1280px (desktop) | Full width, icon + label | Multi-column layouts as specified per screen above |
| 768–1279px (tablet / narrow desktop) | Collapses to an icon-only rail (labels hidden, tooltip on hover) | Two-column layouts stack vertically; KPI card rows wrap to 2 per row instead of 4 |
| <768px | Out of scope for V1 | Merchant dashboard is desktop/tablet-first (mirrors PRD scope) |

The Shopper Mobile App has no breakpoints in the traditional sense — it targets a single native mobile form factor (Capacitor shell, SRS §47) and is designed at one reference width, with standard safe-area handling for notches/home indicators on iOS and gesture-navigation bars on Android.

---

## 10. Accessibility

Accessibility is a design requirement with the same weight as the functional NFRs in SRS §57.

### 10.1 Contrast

- Every `text/*` token must independently meet WCAG AA against every `bg/*` token it is realistically shown on — this is checked against whatever real values are eventually assigned (Appliify's own for the dashboard, each merchant's for their app), not assumed safe by default (§3.1).
- The Branding & Appearance screen (§8.6) must run this check automatically on merchant-submitted colors and block "Generate App" on failure, per §6.1.

### 10.2 Non-color-dependent information

- Toggle switches (§4.2) always carry an explicit "On"/"Off" text label — color is a reinforcement, never the sole signal.
- Stock-scarcity and success/error states pair color with an icon and/or text, never color alone.
- Tooltips (§4.5) never carry information required to complete a task.

### 10.3 Touch targets and focus

- Every tappable element on mobile meets the 44×44px minimum (§3.4), even where the visible icon is smaller — padding, not icon size, provides the target area.
- Every focusable element on the dashboard has a visible focus ring (§4.2), sufficient for keyboard-only navigation.
- Tab order on every dashboard screen follows visual reading order; no positive `tabindex` values are used.

### 10.4 Motion and screen readers

- All motion tokens (§3.5) collapse to an 80ms fade when the OS "reduce motion" setting is active.
- Icon-only buttons (§4.1) always carry an accessible label matching their function, not their icon name.
- Chart data (§4.6) is never presented visually only — every chart has an accompanying data table or textual summary available to screen-reader users.

---

## 11. Open Items

| Item | Status |
|---|---|
| No color values or typefaces are defined anywhere in this document | Intentional — awaiting Appliify's own brand identity (dashboard) and the merchant-facing branding system's default/allowed value ranges (mobile app). This document is complete as a system; it is not complete as a rendered product until those values exist. |
| Apple App Store review timeline vs. the 42–48h build SLA (§6.2) | Needs explicit product/marketing communication so merchants don't read "42–48 hours" as "your app will be live on the App Store" — the build-status stepper in §6.2 is the mitigation, but the marketing copy around the SLA should be reviewed too |
| No production visual asset library (Figma or equivalent) exists yet | Must be produced and linked here once real brand values are supplied |
| Light-mode support for the Shopper Mobile App | Open — since colors are now merchant-supplied rather than a fixed dark palette, decide whether a merchant can choose a light-background brand (this document's token system already supports it; it's a product/business decision, not a technical blocker) |
| Loyalty-tier badge system (§7.11) referenced but not fully specified | Depends on whether a loyalty program ships in V1 scope (currently out of scope per PRD §13) |

---

*This document specifies the visual and interaction layer only. Functional behavior, permissions, and API bindings for every screen listed here remain governed by SRS §47 (Mobile) and §49 (Dashboard) — this file must never contradict those sections; if a conflict is found, §47/§49 win and this file is corrected.*
