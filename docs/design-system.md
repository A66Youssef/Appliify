# Appliify — Design System & Visual Identity (UI/UX Specification)

> Companion to [`../SRS.md`](../SRS.md) §77. Covers what §47 (Mobile Application SRS) and §49 (Merchant Dashboard) deliberately left out: the **visual layer** — design tokens, component rules, and screen-level wireframe intent for every screen already named in §47.1 and the §49 screen table. This document does not introduce new screens or new functional requirements; it specifies how the existing, already-approved screen list should look and feel.
>
> **Status:** v1.0 — Draft, pending stakeholder sign-off. No visual asset library (Figma/Stitch source of truth) existed before this pass; this document is the first formal design specification for Appliify.

---

## 1. Design Philosophy

Appliify's positioning (BRD §1) is "growth infrastructure with a real proof point," aimed at merchants who already pay for web-based CRO tools (Tooliify) and expect a professional, trustworthy product — not a templated store-to-app wrapper. The visual identity is built around one idea:

**"Quiet Wealth"** — a boutique-fintech / private-banking aesthetic applied to e-commerce growth tooling. Calm, dark, generously spaced, with a single restrained metallic accent instead of loud brand colors. The product should look like it belongs in the same category as a premium analytics or banking tool, not a generic app-builder SaaS.

Principles:
1. **Restraint over decoration.** One accent color (antique gold), used sparingly and only for meaningful actions/values — never as background filler.
2. **Evidence-first hierarchy.** Every screen that reports a number Appliify is proud of (attribution %, revenue, open rate) gives that number the largest, highest-contrast treatment on the screen — this is the product's core sales argument (PRD §4.2, FR-E00) and the UI must reflect that priority visually, not just functionally.
3. **Disclosure is a first-class UI element, not a footnote.** Because BR-040/FR-E00's attribution figure is explicitly a *simplified* methodology (§30), every screen showing it must render its methodology disclosure with real visual weight (a bordered note, not grey 10px fine print) — this is a compliance/trust requirement carried over from the business documents, not a stylistic choice.
4. **Consistency over novelty per screen.** Every screen reuses the same six tokens (background, surface, accent, secondary accent, two text colors) and the same handful of components. No screen invents its own pattern.

---

## 2. Design Tokens

### 2.1 Color

| Token | Hex | Usage |
|---|---|---|
| `color/bg/base` | `#0E0E10` | App/dashboard background |
| `color/bg/surface` | `#18181C` | Cards, sidebars, modals, table rows |
| `color/accent/primary` (gold) | `#B08D57` | Primary buttons, active nav state, key numbers, chart highlight, focus rings |
| `color/accent/secondary` (emerald) | `#1F6F54` | Positive/success/stock-available signals only |
| `color/accent/danger` | `#A83232` | Errors, destructive-action confirmation, failed states only |
| `color/text/primary` | `#F5F1E8` | Headings, primary body text (warm ivory, not pure white) |
| `color/text/secondary` | `#9A9A9E` | Captions, timestamps, helper text |
| `color/border/hairline` | `rgba(176,141,87,0.25)` | 1px card/divider borders — replaces drop shadows everywhere |

**Accessibility note (flagged, not yet resolved):** `text/secondary` (`#9A9A9E`) on `bg/base` (`#0E0E10`) measures under WCAG AA (4.5:1) for body text at small sizes. Two acceptable fixes, to be chosen during implementation: (a) restrict `text/secondary` to 14px+ non-critical captions only, or (b) lighten to `#ACACB0`. This must be resolved before accessibility sign-off (see §57 NFRs, WCAG target).

### 2.2 Typography

| Token | Family | Usage |
|---|---|---|
| `font/display` | Elegant serif (e.g. Fraunces / Canela-class) | All screen headlines, hero numbers (attribution %, revenue) |
| `font/body` | Humanist sans (e.g. Inter / General Sans) | Body copy, form fields, table data, nav labels |

Serif is reserved for headings and hero metrics only — never for dense UI text (forms, tables) where a serif would hurt scanability.

### 2.3 Shape, spacing, iconography

| Token | Value |
|---|---|
| `radius/card` | 16–20px |
| `radius/button` | 12px (pill-shaped primary CTAs) |
| `border/default` | 1px, `color/border/hairline` — replaces box-shadow as the default depth cue |
| `spacing/section` | 24px+ padding minimum inside cards; generous negative space is a brand requirement, not a nice-to-have |
| `icon/style` | Line icons only, 1.5px stroke — no filled/solid icons anywhere in the product |

---

## 3. Component Rules (applies to both surfaces)

| Component | Rule |
|---|---|
| Primary button | Pill shape, gold gradient fill, dark text, subtle gold glow on hover/press. One per screen/section max — "primary" loses meaning if repeated. |
| Secondary button | Ghost style: text + hairline border, no fill. |
| Card | Surface color, `radius/card`, hairline border instead of shadow. |
| Toggle (feature on/off — CRO Toolkit) | Gold fill = on, outline only = off. Must be distinguishable without relying on color alone (add a text label "On/Off") per accessibility. |
| Badge/tag | Small pill, outlined not filled, color follows semantic meaning only (emerald = positive, gold = neutral/highlight, red = negative). |
| Modal / bottom sheet | Dimmed charcoal overlay, rounded top corners on mobile bottom sheets (24px), centered card on desktop modals. |
| Empty state | Centered line-icon illustration + serif headline + one action — never a blank screen (carries over §47.2's "no silent blank screens" rule into the visual spec). |
| Loading state | Skeleton screens matching final layout, not spinners, for data-heavy screens (Overview, Analytics). Splash screen is the one exception (thin gold progress line, per its own spec). |
| Chart | Gold for the "app/Appliify" series, muted grey for the "baseline/total" comparison series — never mixes in the emerald or danger tokens. |

---

## 4. Screen-Level Wireframe Specification — Shopper Mobile App

Maps 1:1 to the screen list in SRS §47.1. No screen is added or removed here.

| Screen | Layout regions (top → bottom) | Key elements this screen must render (non-negotiable) |
|---|---|---|
| **Splash** | Full-bleed background, centered lockup | Wordmark, thin gold progress line. No nav, no chrome. |
| **Home (storefront)** | Sticky header → hero promo card → category chip row → product grid → bottom nav | Search + cart icons in header; horizontal category chips; 2-col product grid; bottom nav (Home/Search/Wishlist/Cart/Account) |
| **Category / Search** | Sticky header (search expanded) → filter chip row → product grid → bottom nav | Same product card component as Home; filter chips open the Filters sheet |
| **Product Detail** | Full-width image → floating back/wishlist icons → title/price/rating → CRO overlay zone → description accordion → sticky add-to-cart bar | **Mandatory CRO overlay zone directly under price:** countdown timer pill (if active), stock-scarcity line with emerald dot (if active), social-proof floating card (if active) — these three are the product's core differentiators and must never be omitted or reduced to generic badges |
| **Cart** | Line-item list → order summary → sticky checkout bar | Quantity stepper per item; subtotal/discount/total block in serif gold total |
| **Checkout** | Step indicator (Shipping/Payment/Review) → form → collapsed order summary → sticky continue bar | 3-step indicator is mandatory — checkout wraps a store-native flow (PRD) and the shell must still show progress |
| **Wishlist** | Header → 2-col grid → bottom nav | "Notify me" ghost button on out-of-stock items; empty state per §3 |
| **Notification Inbox** | Header → vertical notification list → bottom nav | Unread indicator dot; type icon per notification (offer/restock/wishlist) |
| **Account / Profile** | Avatar/name header → vertical menu list → bottom nav | Menu rows: Order History, Wishlist, Addresses, Payment Methods, Notification Settings, Help, Sign Out |

---

## 5. Screen-Level Wireframe Specification — Merchant Dashboard

Maps 1:1 to the screen table in SRS §49. Segments, Settings, and Audit are included below since §49 lists them as first-class screens even though earlier planning material undercounted them — this corrects that gap.

| Screen | Layout regions | Key elements this screen must render (non-negotiable) |
|---|---|---|
| **Login / Auth** | Centered card on full-bleed background | Email/password, "Forgot password", sign-up link |
| **Overview** | Sidebar → top bar (platform status + profile) → KPI card row → trend chart → recent-activity list | KPI cards: Installs, Active Users, Push Open Rate, App-Attributed Revenue (this one always visually largest — see §1.2); empty-state variant for day-1 merchants is mandatory, not optional |
| **Branding & Appearance** | Sidebar → split layout: form (left) + live phone preview (right) | Logo upload, color pickers, splash preview — preview must update live, not on save only |
| **Store / Integration** | Sidebar → connected-platform card → connect/disconnect actions | Platform status pill (Salla/Zid/WooCommerce), sync status, plain-language capability-limitation notice (BR-015) — this notice is a business requirement, must not be hidden in a tooltip |
| **CRO Toolkit** | Sidebar → tool card grid → detail/config panel | Each tool card: icon, name, one-line description, on/off toggle; clicking an active tool opens its config panel (e.g. countdown start/end/target) |
| **Push Composer & History** | Sidebar → composer form (left) + live notification preview (right); separate History tab/table | Segment selector chips (All/Abandoned Cart/Wishlist/Inactive N days); History table with delivery count, open rate, attributed conversions |
| **Segments** | Sidebar → segment list → builder panel | List of saved segments with member count; builder uses the same condition-chip pattern as the composer's segment selector for consistency |
| **Analytics** | Sidebar → date range control → chart grid | Funnel/engagement charts use the chart color rule in §3 |
| **Attribution** | Sidebar → hero metric card → comparison chart → methodology disclosure | Hero % in large serif gold text; methodology disclosure rendered as a bordered note card (not fine print) with a "How is this calculated?" expandable link — mandatory per §1.3 |
| **Billing & Plan** | Sidebar → current plan card → invoice table → team member list | Invite-teammate action opens a role-explainer modal (Admin vs Staff, per §9 RBAC) |
| **Users** | Sidebar → member table | Role badges (Admin gold-outlined, Staff grey-outlined) matching §9 RBAC exactly |
| **Settings** | Sidebar → grouped settings sections | Store configuration fields per §49; destructive actions require confirmation dialog per §47.2/§49 cross-cutting rule |
| **Audit** | Sidebar → filterable audit log table | Read-only; timestamp, actor, action, target — reflects §53 audit logging fields directly, no reformatting that would hide required fields |

**Cross-cutting (all dashboard screens):** every data screen must render explicit loading (skeleton), empty (guidance to first action), error (retryable, shows correlation id), and success states — this is a direct visual restatement of the rule already in SRS §49, not a new requirement.

---

## 6. Responsive Behavior (Dashboard only — web)

| Breakpoint | Behavior |
|---|---|
| ≥1280px (desktop) | Full sidebar + multi-column layouts as specified above |
| 768–1279px (tablet/narrow desktop) | Sidebar collapses to icon-only rail; two-column layouts (e.g. Branding split view) stack vertically |
| <768px | Out of scope for V1 — merchant dashboard is desktop/tablet-first; mobile-web merchant access is a future consideration, not a V1 requirement |

---

## 7. Generation Methodology (Stitch prompt series)

Screens are generated using Google Stitch from a structured prompt series (tracked separately, not checked into this repo as it is a working prompting document rather than a technical spec). Two rules apply to any future prompt authoring against this design system, learned from the first generation pass:

1. **One screen per prompt.** Multi-screen prompts measurably reduce adherence to the mandatory-element lists in §4/§5.
2. **Mandatory elements listed as an imperative checklist, separated from mood/style language**, not folded into descriptive prose — prose-embedded instructions are the most common source of dropped requirements in LLM-based UI generation.

---

## 8. Open Items

| Item | Why it matters |
|---|---|
| WCAG contrast fix for `text/secondary` (§2.1) | Must be resolved before accessibility sign-off |
| No visual asset source of truth committed yet | Figma export from Stitch should be added as `docs/design/assets/` (or linked) once the corrected one-screen-per-prompt pass is complete |
| Toggle color-blindness fallback (§3) | On/off toggles must not rely on gold-vs-outline alone; text label required |

---

*This document specifies the visual layer only. Functional behavior, permissions, and API bindings for every screen listed here remain governed by SRS §47 (Mobile) and §49 (Dashboard) — this file must never contradict those sections; if a conflict is found, §47/§49 win and this file is corrected.*
