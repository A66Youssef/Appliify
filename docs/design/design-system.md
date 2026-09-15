# Appliify — Design System & Visual Identity (UI/UX Specification)

> Companion to [`../SRS.md`](../SRS.md) §77. Covers what §47 (Mobile Application SRS) and §49 (Merchant Dashboard) deliberately left out: the **visual layer** — design tokens, the full component library, and screen-level wireframe intent for every screen already named in §47.1 and the §49 screen table. This document does not introduce new screens or new functional requirements; it specifies how the existing, already-approved screen list should look, feel, and behave visually in every state.
>
> **Status:** v1.0 — Draft, pending stakeholder sign-off. No visual asset library existed before this pass; this document is the first formal design specification for Appliify.

---

## 1. Design Philosophy

Appliify's positioning (BRD §1) is "growth infrastructure with a real proof point," aimed at merchants who already pay for web-based CRO tools (Tooliify) and expect a professional, trustworthy product — not a templated store-to-app wrapper. The visual identity is built around one idea:

**"Quiet Wealth"** — a boutique-fintech / private-banking aesthetic applied to e-commerce growth tooling. Calm, dark, generously spaced, with a single restrained metallic accent instead of loud brand colors. The product should look like it belongs in the same category as a premium analytics or banking tool, not a generic app-builder SaaS.

### 1.1 Principles

1. **Restraint over decoration.** One accent color (antique gold), used sparingly and only for meaningful actions/values — never as background filler, never as a decorative flourish.
2. **Evidence-first hierarchy.** Every screen that reports a number Appliify is proud of (attribution %, revenue, open rate) gives that number the largest, highest-contrast treatment on the screen — this is the product's core sales argument (PRD §4.2, FR-E00) and the UI must reflect that priority visually, not just functionally.
3. **Disclosure is a first-class UI element, not a footnote.** Because BR-040/FR-E00's attribution figure is explicitly a *simplified* methodology (§30), every screen showing it must render its methodology disclosure with real visual weight (a bordered note, not grey 10px fine print) — this is a compliance/trust requirement carried over from the business documents, not a stylistic choice.
4. **Consistency over novelty per screen.** Every screen reuses the same token set (background, surface, accent, secondary accent, two text colors) and the same handful of components. No screen invents its own pattern, its own shade of gold, or its own card shape.
5. **Silence is a feature.** Empty states, loading states, and low-data states are treated as designed moments, not afterthoughts — a merchant's first day using the product (zero data) must feel as considered as their busiest day.
6. **One primary action per screen.** If a screen has more than one gold pill button competing for attention, the hierarchy has failed — demote everything except the single most important action to a ghost/secondary treatment.
7. **Numbers earn their format.** Currency, percentages, and counts each have one canonical display format (§2.4) used everywhere — a merchant should never see "17%" in one place and "17.00%" in another for the same metric.

### 1.2 Brand voice (for UI copy, not just visuals)

| Attribute | Do | Avoid |
|---|---|---|
| Tone | Calm, precise, confident | Hype, exclamation marks, growth-hacker slang |
| Numbers | State the figure plainly, then the caveat if one exists | Round up optimistically, bury the caveat |
| Errors | Explain what happened and what to do next | Blame the user, show raw stack traces |
| Empty states | Frame as an opportunity ("Send your first push") | Apologize ("Sorry, nothing here yet") |

---

## 2. Design Tokens

Tokens are the single source of truth for every visual value used anywhere in the product. No screen, component, or one-off style should use a raw hex value or pixel size that isn't listed here — if a new value is needed, it is added to this table first, then used.

### 2.1 Color — core palette

| Token | Hex / Value | Usage |
|---|---|---|
| `color/bg/base` | `#0E0E10` | App/dashboard background |
| `color/bg/surface` | `#18181C` | Cards, sidebars, modals, table rows |
| `color/bg/surface-raised` | `#202024` | Popovers, dropdown menus, elements that sit visually above a card |
| `color/bg/overlay-scrim` | `rgba(14,14,16,0.72)` | Dimming layer behind modals and bottom sheets |
| `color/accent/primary` (antique gold) | `#B08D57` | Primary buttons, active nav state, key numbers, chart highlight, focus rings, links |
| `color/accent/primary-hover` | `#C29B62` | Hover/pressed state of gold elements |
| `color/accent/primary-muted` | `rgba(176,141,87,0.12)` | Subtle gold background fills (e.g. selected chip background) |
| `color/accent/secondary` (emerald) | `#1F6F54` | Positive/success/stock-available signals only |
| `color/accent/secondary-muted` | `rgba(31,111,84,0.14)` | Success badge backgrounds |
| `color/accent/danger` | `#A83232` | Errors, destructive-action confirmation, failed states only |
| `color/accent/danger-muted` | `rgba(168,50,50,0.14)` | Error banner backgrounds |
| `color/text/primary` | `#F5F1E8` | Headings, primary body text (warm ivory, not pure white) |
| `color/text/secondary` | `#ACACB0` | Captions, timestamps, helper text (lightened from initial draft — see §7.1) |
| `color/text/disabled` | `#5C5C60` | Disabled form labels and inactive nav items |
| `color/text/on-accent` | `#1A1408` | Text rendered on top of a solid gold fill (buttons) — near-black, not white, for correct contrast against gold |
| `color/border/hairline` | `rgba(176,141,87,0.25)` | 1px card/divider borders — replaces drop shadows everywhere |
| `color/border/hairline-strong` | `rgba(176,141,87,0.45)` | Focused/active card borders, selected states |
| `color/border/neutral` | `rgba(245,241,232,0.08)` | Non-brand dividers (table row separators, list dividers) where gold would be visual noise |

### 2.2 Typography — full type scale

| Token | Size / Line-height | Weight | Family | Usage |
|---|---|---|---|---|
| `type/display-l` | 40px / 48px | 500 | `font/display` (serif) | Hero metric numbers (attribution %, revenue figures) |
| `type/display-m` | 32px / 40px | 500 | `font/display` | Screen-level headlines ("Your app is live in preview") |
| `type/display-s` | 24px / 32px | 500 | `font/display` | Section headings within a screen |
| `type/body-l` | 17px / 26px | 400 | `font/body` (sans) | Primary reading text, form labels |
| `type/body-m` | 15px / 22px | 400 | `font/body` | Default UI text, table cells, list items |
| `type/body-s` | 13px / 18px | 400 | `font/body` | Captions, timestamps, helper/error text |
| `type/label` | 13px / 16px | 600 | `font/body` | Button labels, nav labels, badge text — uppercase tracking +0.02em |
| `type/mono` | 14px / 20px | 400 | Monospace (e.g. JetBrains Mono) | Order IDs, correlation IDs, audit log technical values only |

`font/display` = an elegant serif (e.g. Fraunces / Canela-class). `font/body` = a humanist sans (e.g. Inter / General Sans). Serif is reserved for `display-*` tokens only — never for dense UI text (forms, tables), where a serif hurts scanability.

### 2.3 Spacing scale

A single 4px base unit, used consistently instead of ad-hoc padding values:

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

### 2.4 Shape, elevation, iconography

| Token | Value |
|---|---|
| `radius/card` | 16–20px |
| `radius/button` | 12px (pill-shaped primary CTAs use a fully rounded 999px radius instead) |
| `radius/input` | 10px |
| `radius/chip-badge` | 999px (fully rounded) |
| `radius/sheet-top` | 24px (mobile bottom sheets, top corners only) |
| `elevation` | No drop shadows anywhere in the product. Depth is communicated exclusively through `border/hairline` (default) and `border/hairline-strong` (focused/raised) plus a one-step lightening of background (`bg/surface` → `bg/surface-raised`). |
| `icon/style` | Line icons only, 1.5px stroke, no filled/solid icons anywhere in the product |
| `icon/size/s` | 16px — inline with body text |
| `icon/size/m` | 20px — default UI icon (nav, buttons) |
| `icon/size/l` | 28px — empty-state illustrations, feature icons |
| `touch-target/min` | 44×44px minimum for any tappable element on mobile, regardless of visible icon size |

### 2.5 Motion

| Token | Value | Usage |
|---|---|---|
| `motion/duration/fast` | 120ms | Toggle switches, button press feedback |
| `motion/duration/base` | 200ms | Screen transitions, modal open/close |
| `motion/duration/slow` | 320ms | Chart animations, hero-number count-up |
| `motion/easing/standard` | cubic-bezier(0.2, 0, 0, 1) | Default for all transitions |
| `motion/reduced` | All of the above collapse to a single 80ms fade | Applied automatically when the OS-level "reduce motion" accessibility setting is on (§7.4) |

### 2.6 Number and currency formatting

| Data type | Canonical format | Example |
|---|---|---|
| Attribution / percentage metrics | One decimal place, always | `17.4%` |
| Currency | Merchant's store currency symbol, thousands separator, no decimals for whole amounts | `SAR 12,480` |
| Counts (installs, users) | Abbreviated above 10,000 | `1,204` / `12.4K` |
| Dates in tables | `DD Mon YYYY` | `14 Sep 2026` |
| Relative timestamps (notifications) | Relative under 24h, absolute after | `3 hours ago` → `12 Sep, 4:02 PM` |

---

## 3. Component Library

Every component below is specified across its required states: **default, hover (web only), pressed/active, focus, disabled, loading, and error** where applicable. A component is not implementation-complete until every listed state exists.

### 3.1 Buttons

| Variant | Default | Hover/Press | Disabled | Loading |
|---|---|---|---|---|
| Primary (pill) | Gold gradient fill (`accent/primary` → `accent/primary-hover`), `text/on-accent` label, subtle gold glow | Glow intensifies, fill shifts to `accent/primary-hover` | 40% opacity, no glow, not tappable | Label replaced by a thin gold spinner arc, button width unchanged |
| Secondary (ghost) | Transparent fill, `border/hairline-strong`, `text/primary` label | Fill becomes `accent/primary-muted` | Border becomes `border/neutral`, label `text/disabled` | Same spinner treatment in `text/primary` color |
| Tertiary (text link) | `accent/primary` text, no border/fill | Underline appears | `text/disabled`, no underline on hover | N/A — tertiary actions never carry async loading |
| Icon button | 44×44px touch target, `icon/size/m` centered, transparent | Background becomes `bg/surface-raised` | Icon becomes `text/disabled` | Icon replaced by spinner at same size |
| Destructive | Same shape as Primary, fill uses `accent/danger` instead of gold | Darkens slightly | Same disabled treatment | Same spinner, in `accent/danger`-safe contrast color |

**Rule:** exactly one Primary button visible per screen or modal at a time (§1.1 principle 6). Everything else demotes to Secondary or Tertiary.

### 3.2 Form inputs

| Component | Default | Focus | Error | Disabled |
|---|---|---|---|---|
| Text field | `bg/surface`, `radius/input`, `border/neutral`, `text/primary` value, `text/secondary` placeholder | Border becomes `border/hairline-strong` with a soft gold glow ring | Border becomes `accent/danger`, helper text below in `accent/danger` | `bg/surface` at 60% opacity, `text/disabled` |
| Dropdown / select | Same as text field + chevron icon right | Same focus ring; open state shows options list on `bg/surface-raised` | Same error border | Same disabled treatment, chevron in `text/disabled` |
| Checkbox | Outlined square, `border/neutral`, `radius` 4px | Focus ring in gold | N/A (checkboxes don't carry validation errors directly) | Outline `text/disabled`, no fill |
| Checked checkbox | Gold fill, `text/on-accent` check glyph | — | — | Gold fill at 40% opacity |
| Toggle switch | Track: outline only when off; gold fill when on. **Always paired with an explicit "On"/"Off" text label** — never color alone (§7.3) | Focus ring around the whole switch | N/A | Track and label at `text/disabled` |
| Slider (e.g. price range filter) | Gold track fill up to handle position, `border/neutral` track remainder, gold handle | Handle shows a soft glow while dragging | N/A | Entire track/handle at `text/disabled` |
| Date/time picker | Text field trigger + calendar popover on `bg/surface-raised`, selected date in gold fill | Focus ring on trigger field | Same error border pattern as text field | Same disabled treatment |

### 3.3 Cards

| Type | Spec |
|---|---|
| Standard card | `bg/surface`, `radius/card`, `border/hairline`, minimum `space/6` internal padding |
| Interactive card (tappable/clickable) | Adds `border/hairline-strong` and a very subtle upward 2px translate on hover (web) or press (mobile) |
| Selected card (e.g. platform-selection during onboarding) | `border/hairline-strong` + `accent/primary-muted` background wash |
| Metric/KPI card | Standard card + a `type/display-s` or `type/display-l` number as the dominant element, label in `type/body-s`/`text/secondary` above or below it, optional trend indicator (small gold or emerald arrow + percentage) |

### 3.4 Navigation

| Component | Spec |
|---|---|
| Mobile bottom navigation | 5 icons max (`icon/size/m`), fixed to bottom, `bg/surface` background with a `border/neutral` top hairline. Active item: icon and label in `accent/primary` plus a 2px gold underline indicator. Inactive: `text/secondary`. |
| Dashboard sidebar | Fixed left, `bg/surface`, serif wordmark at top, vertical list of line-icon + label rows. Active item: `accent/primary-muted` background wash, gold left-border accent (3px), gold icon and label. Collapses to icon-only rail at the tablet breakpoint (§6). |
| Tab bar (e.g. Push Composer vs Push History) | Underline-style tabs, active tab in `accent/primary` with a 2px underline, inactive in `text/secondary`, no pill backgrounds |
| Breadcrumb (dashboard drill-down views) | `text/secondary` separated by `/`, current page in `text/primary`, no gold except on hover of a clickable crumb |

### 3.5 Overlays

| Component | Spec |
|---|---|
| Modal (desktop) | Centered, `bg/surface`, `radius/card`, max-width 480–640px depending on content, `bg/overlay-scrim` behind it, closes on scrim click or explicit close icon (never on accidental outside-tap only — always show a visible close affordance) |
| Bottom sheet (mobile) | Slides up from bottom, `radius/sheet-top` on top corners only, `bg/overlay-scrim` behind, drag handle indicator (small horizontal bar) at the top center |
| Toast / inline confirmation | Appears at the top (mobile) or bottom-right (dashboard), `bg/surface-raised`, `border/hairline`, auto-dismisses after 4s unless it contains an action (e.g. "Undo") |
| Tooltip | `bg/surface-raised`, `type/body-s`, appears on hover (web) or long-press (mobile), never the sole carrier of required information (§7.2) |

### 3.6 Data display

| Component | Spec |
|---|---|
| Table | `bg/surface` rows separated by `border/neutral` (not gold — gold reserved for meaningful state, not structural dividers), header row in `type/label`/`text/secondary`, sortable columns show a small chevron on hover |
| Chart | Gold (`accent/primary`) for the "Appliify/app" data series, `text/secondary`-grey for the "baseline/total store" comparison series, `accent/secondary` (emerald) never used in charts except as a single positive-delta annotation, never as a full series color |
| Badge / tag | `radius/chip-badge`, outlined not filled by default; semantic fill only when meaningful: `accent/secondary-muted` = positive, `accent/primary-muted` = neutral highlight, `accent/danger-muted` = negative |
| Progress indicator (e.g. onboarding steps) | Connected dots/line, completed steps solid gold, current step outlined gold, upcoming steps `border/neutral` |
| Avatar | Circular, initials on a `accent/primary-muted` background when no image is set, never a generic grey silhouette icon |

### 3.7 Feedback states (every data screen requires all four)

| State | Spec |
|---|---|
| Loading | Skeleton screens matching the final layout's shape (grey pulsing blocks at `bg/surface-raised`), not spinners, for any screen showing data (Overview, Analytics, tables). Spinners are reserved for button-level async actions only. |
| Empty | Centered `icon/size/l` line illustration + `type/display-s` headline + one supporting sentence + exactly one Primary action (§1.1 principle 5). Never a blank white/dark space. |
| Error | A bordered notice card in `accent/danger-muted` background with `accent/danger` icon, plain-language explanation, a correlation ID in `type/mono` for support reference, and a "Retry" action where retrying is possible |
| Success | Brief toast (§3.5) or, for major actions (order placed, app connected), a full dedicated success screen with a gold checkmark treatment |

---

## 4. Screen-Level Wireframe Specification — Shopper Mobile App

Maps 1:1 to the screen list in SRS §47.1. No screen is added or removed here.

### 4.1 Splash
- **Layout:** full-bleed `bg/base`, centered lockup, no navigation chrome of any kind.
- **Elements:** serif wordmark in `text/primary`; a thin gold (`accent/primary`) progress line beneath it (not a spinner — reinforces the calm brand voice even at the first moment of the experience).
- **Duration/behavior:** dismisses on config load or a defined timeout (SRS §47.2); never blocks longer than the timeout.

### 4.2 Home (storefront)
- **Layout (top → bottom):** sticky header → hero promotional card → horizontal category chip row → 2-column product grid → bottom navigation.
- **Header:** serif wordmark left; search icon and cart icon (`icon/size/m`, line style) right, cart icon shows a small gold badge with item count when non-empty.
- **Hero card:** interactive card component (§3.3), rounded corners, may contain a single promotional message with a subtle serif overlay headline.
- **Category chips:** pill-shaped, `bg/surface` default, `accent/primary-muted` fill + gold text when selected.
- **Product grid:** each card shows product image, name (`type/body-m`, `text/primary`), price (`type/body-m`, `accent/primary`), and an optional stock-scarcity tag (`accent/secondary-muted` badge) when applicable.
- **Bottom nav:** Home / Search / Wishlist / Cart / Account, per §3.4.

### 4.3 Category / Search
- **Layout:** sticky header with the search field expanded and focused → filter chip row → 2-column product grid (identical card component to Home) → bottom nav.
- **Filter chips:** tapping opens the Filters bottom sheet (§3.5) with price range slider, category checkboxes, and an availability toggle.
- **Empty result state:** uses the standard Empty pattern (§3.7) with the action "Clear filters."

### 4.4 Product Detail
- **Layout:** full-width product image → floating back arrow + wishlist heart icon over the image → title/price/rating block → **mandatory CRO overlay zone** → expandable description accordion → sticky add-to-cart bar.
- **CRO overlay zone (non-negotiable, positioned directly under price):**
  - Countdown timer: a slim dark pill with gold digits, shown only while an active countdown exists for this product.
  - Stock scarcity: `type/body-s` text with a small emerald dot, shown only below the merchant-configured threshold.
  - Social proof: a floating card near the image's lower edge with a small avatar and recent-purchase text, auto-rotating if multiple events exist.
  - These three elements are the product's core competitive differentiator (BRD §2.3) and must never be omitted, generalized into a single "badge," or visually deprioritized relative to the rest of the screen.
- **Sticky bottom bar:** quantity stepper + full-width Primary "Add to Cart" button.

### 4.5 Cart
- **Layout:** vertical list of line-item cards → order summary block → sticky checkout bar.
- **Line item:** thumbnail, name, selected variant (`text/secondary`), quantity stepper, price (`accent/primary`), icon-button remove action.
- **Order summary:** subtotal → discount line (in `accent/secondary` if a coupon applies) → divider (`border/neutral`) → total in `type/display-s` gold.
- **Empty state:** standard pattern (§3.7), action "Start Shopping."

### 4.6 Checkout
- **Layout:** 3-step progress indicator (Shipping → Payment → Review, §3.6) → form (per §3.2 input specs) → collapsed order-summary accordion → sticky continue bar.
- **Note:** this screen wraps a store-native checkout flow (PRD §11); the native shell still must render the step indicator so the shopper never loses orientation mid-flow.

### 4.7 Order Confirmation
- **Layout:** centered success state (gold checkmark, §3.7) → order number and delivery estimate (`text/secondary`) → order summary card with an `accent/secondary-muted` "Payment confirmed" badge → two actions ("Track Order" primary, "Continue Shopping" tertiary).

### 4.8 Wishlist
- **Layout:** header → 2-column grid (same card component as Home, plus a filled gold heart top-right) → bottom nav.
- **Out-of-stock items:** show a Secondary "Notify me" button instead of a price/add-to-cart affordance.
- **Empty state:** standard pattern, action "Browse products."

### 4.9 Notification Inbox
- **Layout:** header → vertical list of notification cards → bottom nav.
- **Notification card:** small type-specific line icon (offer / restock / wishlist), `type/body-m` title, `type/body-s` relative timestamp, `border/neutral` divider between items, unread items marked with a small solid gold dot on the leading edge.

### 4.10 Notification Detail / deep link
- **Layout:** context label ("Reminder," `text/secondary`) → serif headline restating the offer → referenced product teaser card (reuses the Product Detail card pattern, with countdown if applicable) → sticky "Go to Cart" primary button.

### 4.11 Account / Profile
- **Layout:** avatar/name header → vertical menu list → bottom nav.
- **Menu rows:** Order History, Wishlist, Saved Addresses, Payment Methods, Notification Settings, Help & Support, Sign Out — each a list row with a leading `icon/size/m` line icon and a trailing chevron.
- **Optional:** loyalty-tier badge card (`accent/secondary-muted`) near the top if the merchant has such a program configured.

### 4.12 Sign In / Register
- **Layout:** serif headline → email/password fields (§3.2) → Primary "Sign In" button → tertiary "Create an account" link → tertiary "Continue as guest" link.

---

## 5. Screen-Level Wireframe Specification — Merchant Dashboard

Maps 1:1 to the screen table in SRS §49, including Segments, Settings, and Audit, which §49 lists as first-class screens.

### 5.1 Login / Auth
- **Layout:** centered card (max-width ~440px) on full-bleed background, serif wordmark above it.
- **Elements:** email/password fields, "Forgot password?" tertiary link, Primary "Sign In" button, tertiary "Create an account" link below the card.

### 5.2 Onboarding — Select Platform
- **Layout:** serif headline ("Which platform is your store on?") → three large selectable cards (Salla / Zid / WooCommerce, §3.3 selected-card treatment) → muted note about Shopify support arriving later → Primary "Continue" (disabled until a platform is chosen).

### 5.3 Onboarding — Connect Store
- **Layout:** numbered step list (gold circles, connected by a thin line) → Primary "Connect with [Platform]" button with the platform's icon → a `text/secondary` security note clarifying the scope of access requested.

### 5.4 Onboarding — App Preview Ready
- **Layout:** split screen — left: realistic phone-frame mockup showing the generated storefront app using the mobile visual identity (§4); right: serif headline, short description, `accent/secondary-muted` "Catalog synced — N products imported" badge, Primary "Continue to Dashboard" button.

### 5.5 Overview
- **Layout:** sidebar (§3.4) → top bar (platform-connection status pill + profile avatar) → row of KPI metric cards (§3.3: Installs, Active Users, Push Open Rate, App-Attributed Revenue) → trend chart (§3.6) → recent-activity list card.
- **Hierarchy rule:** the App-Attributed Revenue KPI card is always the visually largest of the four (§1.1 principle 2).
- **Day-1 / empty state:** KPI cards show em-dash placeholders with a `text/secondary` note ("Data will appear within 24 hours") and a centered prompt card driving toward "Compose your first push" — this state is mandatory, not an edge case to skip.

### 5.6 Branding & Appearance
- **Layout:** split screen — left: form (logo upload dropzone, color pickers as swatches, splash background picker, font-style preview selector); right: a live phone-frame preview that updates in real time as the merchant edits the form, not only on save.
- **Sub-screen — Splash Screen Customization:** focused single-purpose editor for the splash background/logo placement, with the same live preview pattern and a `text/secondary` note that changes apply without an app-store resubmission.

### 5.7 Store / Integration
- **Layout:** connected-platform card (platform name/icon, sync status, last-synced timestamp) → connect/disconnect/resync actions.
- **Mandatory element:** a plain-language notice (not a tooltip — a visible inline note, §1.1 principle 3 applied to compliance content) whenever a feature is limited by the connected platform's API (BR-015).

### 5.8 CRO Toolkit
- **Layout:** grid of tool cards (icon, name, one-line description, toggle switch per §3.2) for each CRO feature (Countdown Timer, Stock Scarcity Counter, Social Proof Popups, Abandoned Cart Recovery, Sticky Discount Bar, Wishlist Back-in-Stock Alerts).
- **Sub-screen — tool configuration:** opened by tapping an active tool card; form fields specific to that tool (e.g. countdown start/end/target product) plus a live preview of the resulting shopper-facing element, styled identically to how it renders in Product Detail (§4.4).

### 5.9 Push Composer & History
- **Composer layout:** form (title, body, optional image, deep-link target dropdown) on the left; a live notification preview styled like an actual OS notification on the right, updating as the merchant types; segment selector chips below the form.
- **History layout:** a table (§3.6) of sent notifications — title, sent date, delivery count, open rate, and attributed-conversion count where available — with date-range and segment filter controls above it.

### 5.10 Segments
- **Layout:** list of saved segments (name, member count) → a builder panel using the same condition-chip interaction pattern as the Composer's segment selector, for interface consistency across the two screens.

### 5.11 Analytics
- **Layout:** date-range control → grid of charts (funnel, engagement, session metrics), following the chart color rule in §3.6 throughout.

### 5.12 Attribution
- **Layout:** hero metric card (the attribution percentage, `type/display-l`, gold) → comparison chart (app-attributed vs. total revenue) → a bordered methodology-disclosure card with an expandable "How is this calculated?" link.
- **Mandatory:** the disclosure card must carry real visual weight — border, icon, legible body text — never rendered as small fine print (§1.1 principle 3). Any platform-specific limitation (e.g., a connector where order-session linkage is unsupported) is disclosed in this same card, not hidden in a separate help article.

### 5.13 Billing & Plan
- **Layout:** current-plan card (plan name, price, "Manage Subscription" secondary button) → invoice history table (date, amount, status badge) → team member list (avatar, name, role badge) → "Invite Team Member" Primary button.
- **Sub-screen — Invite Team Member modal:** email field, role selector presented as two selectable explainer cards (Admin vs. Staff, mapped exactly to SRS §9 RBAC — the copy on each card must match the actual permission boundaries, not a simplified marketing description of them).

### 5.14 Users
- **Layout:** member table with role badges (Admin: gold-outlined badge; Staff: neutral-outlined badge) matching §9 RBAC exactly, and a remove action per row (destructive, requires confirmation per §3.7/§47.2).

### 5.15 Settings
- **Layout:** grouped settings sections (store configuration fields per SRS §49) using standard form components (§3.2); any destructive action opens a confirmation modal before executing.

### 5.16 Audit
- **Layout:** filterable table (date range, actor, action type) reflecting the audit log fields defined in SRS §53 directly — timestamp, actor, action, target — with no reformatting that would hide or relabel a required field. Read-only; no actions are available from this screen.

**Cross-cutting rule (all dashboard screens):** every data screen renders the full loading/empty/error/success state set from §3.7 — this is a direct visual restatement of the functional rule already present in SRS §49, made explicit here as a design requirement rather than left implicit.

---

## 6. Responsive Behavior (Dashboard — web only)

| Breakpoint | Sidebar | Layout |
|---|---|---|
| ≥1280px (desktop) | Full width, icon + label | Multi-column layouts as specified per screen above (e.g. Branding's form + live-preview split) |
| 768–1279px (tablet / narrow desktop) | Collapses to an icon-only rail (labels hidden, tooltip on hover) | Two-column layouts stack vertically; KPI card rows wrap to 2 per row instead of 4 |
| <768px | Out of scope for V1 | Merchant dashboard is desktop/tablet-first; mobile-web merchant access is a future consideration, not a V1 requirement (mirrors PRD scope) |

The Shopper Mobile App has no breakpoints in the traditional sense — it targets a single native mobile form factor (Capacitor shell, SRS §47) and is designed at one reference width, with standard safe-area handling for notches/home indicators on iOS and gesture-navigation bars on Android.

---

## 7. Accessibility

Accessibility is treated as a design requirement with the same weight as the functional NFRs in SRS §57, not a post-launch pass.

### 7.1 Contrast

- `text/primary` (`#F5F1E8`) on `bg/base` (`#0E0E10`): passes WCAG AAA for body text.
- `text/secondary` was originally specified as `#9A9A9E`, which measured below WCAG AA (4.5:1) against `bg/base` for small text. It has been **lightened to `#ACACB0`** in this revision (§2.1), which passes AA at body sizes. This supersedes the earlier draft's unresolved flag.
- `color/text/on-accent` (`#1A1408`) against `accent/primary` (`#B08D57`) is specified as near-black rather than white specifically because white-on-gold fails contrast at this gold's luminance; near-black passes comfortably.
- Any new token added to this system must be contrast-checked against every background it will realistically sit on before being approved.

### 7.2 Non-color-dependent information

- Toggle switches (§3.2) always carry an explicit "On"/"Off" text label — the gold-fill-vs-outline distinction is a reinforcement, never the sole signal.
- Stock-scarcity and success/error states pair color with an icon and/or text, never color alone (relevant for red-green color-blind users, who are a meaningful share of any large user base).
- Tooltips (§3.5) never carry information required to complete a task — required information lives in visible, persistent copy.

### 7.3 Touch targets and focus

- Every tappable element on mobile meets the `touch-target/min` of 44×44px (§2.4), even where the visible icon is smaller — padding, not icon size, provides the target area.
- Every focusable element on the dashboard (web) has a visible focus ring using `border/hairline-strong` plus a soft gold glow, sufficient for keyboard-only navigation without relying on a mouse hover state.
- Tab order on every dashboard screen follows visual reading order (top-to-bottom, left-to-right); no positive `tabindex` values are used.

### 7.4 Motion and screen readers

- All motion tokens (§2.5) collapse to an 80ms fade when the OS "reduce motion" setting is active — this includes the hero-number count-up animation on the Attribution and Overview screens.
- Icon-only buttons (§3.1) always carry an accessible label (`aria-label` on web, `accessibilityLabel` on mobile) matching their function, not their icon name.
- Chart data (§3.6) is never presented visually only — every chart has an accompanying data table or textual summary available to screen-reader users, per the same principle that drives the plain-language attribution disclosure (§1.1 principle 3).

---

## 8. Open Items

| Item | Status |
|---|---|
| No production visual asset library (Figma or equivalent) has been created from this specification yet | Open — must be produced and linked here (e.g. `docs/design/assets/`) before engineering hand-off |
| Loyalty-tier badge system (§4.11) referenced but not fully specified | Open — depends on whether a loyalty program ships in V1 scope (currently out of scope per PRD §13) |
| Dark-mode-only assumption | Open — this entire specification assumes a single dark theme; no light-mode variant has been requested or designed. Confirm this is an intentional, permanent product decision before engineering treats it as fixed. |

---

*This document specifies the visual layer only. Functional behavior, permissions, and API bindings for every screen listed here remain governed by SRS §47 (Mobile) and §49 (Dashboard) — this file must never contradict those sections; if a conflict is found, §47/§49 win and this file is corrected.*
