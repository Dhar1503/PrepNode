# PrepGraph — Screen Spec 01: Splash Screen
### Built on Design System v1.0 · Screen S0.1 (Information Architecture v1.0)

---

## 1. Purpose

The Splash Screen has exactly two jobs, and nothing else:

1. **Establish brand identity in under 2 seconds** — the very first visual impression of "calm, credible, unhurried" that the entire brand voice depends on.
2. **Perform a silent session check** — determine whether a valid session exists and route accordingly, with zero visible loading chrome (no spinner, no progress bar) so the screen never feels like it's "working."

It is explicitly **not** a marketing screen, not an ad slot, and carries no interactive elements — no buttons, no skip option (2 seconds does not warrant one). Per the Information Architecture, it routes to either the Onboarding Carousel (new user) or straight to Home (valid session).

---

## 2. Layout

Single-zone, vertically centered composition on a full-bleed background — no app bar, no bottom navigation, no status-bar treatment beyond default OS chrome (transparent, icons set to dark-on-light per Light Theme).

```
┌───────────────────────────────┐
│                               │
│                               │
│                               │
│                               │
│                               │
│            [●─●─●]           │  ← Logo mark, 64dp, centered
│                               │     at ~38% of screen height
│                               │
│          PrepGraph            │  ← Wordmark, 12px below mark
│                               │
│      Prepare with Purpose     │  ← Tagline, 8px below wordmark
│                               │
│                               │
│                               │
│                               │
│                               │
│                               │
└───────────────────────────────┘
```

All three elements (mark, wordmark, tagline) form a single vertically-stacked group, centered as one block both horizontally and vertically-biased slightly above true center (38–42% of screen height for the logo's optical center) — true dead-center reads as static; a slight upward bias reads as more considered, matching Apple/Google splash conventions.

No footer content, no version number in production builds (version number shown in the mockup above is for internal QA/staging builds only, removed for Play Store release).

---

## 3. Spacing

Using the Design System's 4px base scale:

| Element relationship | Token | Value |
|---|---|---|
| Logo mark size | — | 64×64dp |
| Logo mark → Wordmark gap | `space.sm` | 16px (visually reads as 12–16px due to mark's internal padding) |
| Wordmark → Tagline gap | `space.2xs` | 8px |
| Logo group vertical position | — | optical center at 38% of screen height (not 50% — see Layout rationale) |
| Screen margins | `space.sm` | 16px (unused here since content is centered, but reserved for any future safe-area needs) |

The tight 8–16px rhythm between mark/wordmark/tagline is intentional: these three elements should read as **one composed lockup**, not three independent elements loosely placed on a page.

---

## 4. Color Usage

Per Design System §2 (Light Theme default — splash always renders in Light Theme regardless of the user's saved dark-mode preference, since preference hasn't been read from storage yet at this point in cold start):

| Element | Token | Hex |
|---|---|---|
| Background | `pg.paper.50` | `#FBFAF6` |
| Logo mark — primary node | `pg.ink.900` | `#1B2A4A` |
| Logo mark — secondary arc | `pg.sage.500` | `#5C8A72` |
| Logo mark — tertiary arc | `pg.marigold.500` | `#E5A73B` |
| Wordmark text | `pg.ink.900` | `#1B2A4A` |
| Tagline text | `pg.graphite.700` at 70% (a muted variant, not a new token) | `#2E2E33` @ 70% |

No gradients, no shadow beneath the logo mark — flat color only, consistent with the system's "no decorative effects" rule. This is the one screen in the app where color must feel absolutely certain and unhurried — no tonal elevation tricks, no surface tinting.

---

## 5. Typography

| Element | Typeface | Size | Weight | Notes |
|---|---|---|---|---|
| Wordmark "PrepGraph" | Fraunces | 24px | 500 | The one place Fraunces appears below its normal 22px floor is not violated — 24px is compliant. Letter-spacing +0.3px for a slightly more composed, less cramped serif set |
| Tagline "Prepare with Purpose" | Inter | 13px | 400 | Letter-spacing +0.5px, sentence case (not caps) — a deliberate softening; caps would feel like a stamp/seal rather than a spoken line |

Rationale for using Fraunces here rather than Inter: this is the one true "hero" typographic moment (per Design System §3, Fraunces is reserved for splash, milestones, and onboarding hero text) — it sets the emotional register before a single line of functional UI copy appears.

---

## 6. Logo Placement

- **Mark:** 64×64dp, centered horizontally, vertical position such that the mark's visual center sits at 38% of total screen height (accounting for notch/status-bar safe area — measured from the safe content area, not the physical screen edge).
- **Construction:** three circular nodes (6dp radius each) connected by two straight edges — literally the brand's "single node branching into three calm arcs" concept from Brand Identity §1. This is not a filled icon or app-icon crop; it is drawn fresh at splash scale for crispness.
- **Clear space:** minimum 24dp of empty space on all sides of the mark before any other element begins (satisfied naturally here since it's the only visual element besides text).
- **Never animated to imply loading** (no spinning, no pulsing node) — the mark is static; only opacity/scale entrance motion is applied (see §9).

---

## 7. Tagline Placement

- Positioned 8px directly below the wordmark's baseline, horizontally centered, same optical center line as the mark and wordmark above it.
- Always paired with the wordmark — the tagline never appears without "PrepGraph" above it in any context (splash, onboarding, about screen) to avoid it reading as a detached slogan.
- Single line, no wrapping — "Prepare with Purpose" fits comfortably at 13px within any supported phone width (as narrow as 320dp logical width); no responsive truncation logic needed.

---

## 8. Animation (Entrance Sequence)

Total entrance duration: **900ms**, well within the 2-second splash budget, leaving ~1100ms of calm "settled" hold time before routing.

| Time | Element | Motion | Easing |
|---|---|---|---|
| 0–400ms | Logo mark | Fade in (opacity 0→1) + scale (0.92→1.0) | Standard easing (Material 3 `cubic-bezier(0.2,0,0,1)`) |
| 250–550ms | Wordmark | Fade in (opacity 0→1), no scale — text should never "pop," only settle | Standard easing |
| 400–650ms | Tagline | Fade in (opacity 0→1), slight delay after wordmark for a gentle cascading reveal | Standard easing |
| 650–900ms | Full lockup | Hold, fully static — no idle animation, no breathing/pulsing effects | — |

This staggered fade (mark → wordmark → tagline, each overlapping the previous by ~150ms) creates a single unified "arrival" feeling rather than three separate pops — consistent with the "quiet mentor" brand personality; nothing on this screen should demand attention through motion.

**Reduced motion:** if the OS-level reduce-motion setting is on, all three elements appear simultaneously via a single 150ms opacity cross-fade with no scale — per Design System §22.

---

## 9. Transition Animation (Splash → Next Screen)

- **Type:** shared-axis fade-through (Material 3 standard pattern for unrelated content — splash and onboarding/home are not spatially related, so a directional slide would be the wrong signal).
- **Duration:** 300ms (`medium2` token).
- **Sequence:** splash content fades out (opacity 1→0, 150ms) fully before the destination screen fades in (opacity 0→1, 150ms) — a true cross-fade through a brief transparent/background-only middle frame, not an overlapping dissolve, to avoid a muddy double-exposure look between two differently-composed screens.
- **Never a slide, zoom, or push transition here** — those imply spatial continuity between splash and the destination, which doesn't exist conceptually.

---

## 10. Accessibility

- **Screen reader:** the entire splash screen is announced as a single semantic label — "PrepGraph, Prepare with Purpose, loading" — rather than three separate elements being read individually with unpredictable pauses. Once routing completes, focus moves directly to the destination screen's primary heading; the splash never receives or holds focus.
- **Reduced motion:** per §8 — fade-only fallback, no scale transform.
- **Timing:** total screen duration (entrance + hold + transition) never exceeds ~2.5s in the worst case (slow network for session check) — WCAG guidance on avoiding unnecessary timing constraints is satisfied since no user action is required or possible on this screen; there's nothing to "miss."
- **Contrast:** Ink (#1B2A4A) wordmark on Paper (#FBFAF6) background measures well above the 4.5:1 AA text threshold; tagline at 70% graphite opacity is verified to still clear 4.5:1 against paper.
- **No flashing content:** the fade sequence contains no rapid opacity oscillation (nothing exceeds the 3-flashes-per-second photosensitivity threshold by an enormous margin — this is a single slow fade).

---

## 11. Micro-interactions

The Splash Screen is intentionally **non-interactive** — this is a deliberate micro-interaction *absence*, not an oversight:

- **No tap-to-skip gesture.** At under 2 seconds, a skip affordance would add more cognitive load (deciding whether to tap) than it would ever save in time.
- **No haptic feedback** on entrance — haptics are reserved for user-initiated actions elsewhere in the app; a haptic buzz on app open would feel presumptuous on first launch.
- **No sound.** Silent by default and never overridden, regardless of system media-volume state — respects contexts like buses, libraries, and shared study spaces central to the target persona.
- **The only "interaction"** is implicit: if the session check resolves in under ~400ms (fast local cache hit), the entrance animation is still allowed to complete its full 900ms before transitioning — the destination is never allowed to snap in early and cut the brand moment short, even when technically able to.

---

## 12. Flutter-Friendly Layout Description

*(Structural description only — no code, per instructions.)*

- **Root:** a `Scaffold` with `backgroundColor` bound to `pg.paper.50`, and `SystemUiOverlayStyle` set for dark status-bar icons (light background).
- **Body:** a `Center` widget containing a `Column` (`mainAxisSize: MainAxisSize.min`), vertically offset upward from true center using an `Align` + `FractionalOffset` (or a `Column` wrapped in a sized `Container` with asymmetric top/bottom `Spacer` flex values — top `Spacer(flex: 38)`, bottom `Spacer(flex: 62)` — to achieve the 38%-height optical center described in §2/§6).
- **Column children, top to bottom:**
  1. Logo mark — a custom `CustomPainter` or a pre-rendered SVG (via `flutter_svg`) sized 64×64dp.
  2. `SizedBox(height: 16)` spacer.
  3. Wordmark — a `Text` widget using the Fraunces `TextTheme.headlineSmall`-equivalent style token, color `pg.ink.900`.
  4. `SizedBox(height: 8)` spacer.
  5. Tagline — a `Text` widget using a custom `TextStyle` (Inter, 13px, `pg.graphite.700` at 70% opacity via `.withOpacity(0.7)`), letter-spacing 0.5.
- **Animation layer:** each of the three children wrapped individually in `FadeTransition` (and the logo additionally in a `ScaleTransition`), all driven by a single shared `AnimationController` with staggered `Interval`-based `CurvedAnimation`s per the timing table in §8, so the whole sequence is orchestrated from one controller rather than three independent timers.
- **Routing logic:** lives outside the visual tree, in a `FutureBuilder`/async check in `initState` (session-token lookup via local secure storage) that, once resolved AND the minimum animation hold time has elapsed (whichever is longer, per §9's "never cut short" rule), triggers `Navigator.pushReplacement` with a custom `PageRouteBuilder` implementing the 300ms fade-through transition described in §9 — never the default Material page-route slide.
- **No `Scaffold` app bar, no bottom navigation shell** — this screen sits entirely outside the main app shell's `NavigationBar`-wrapped route tree, consistent with the Information Architecture's "no bottom nav during Onboarding & Auth" rule.

---

This spec is ready for direct handoff to Windsurf/Flutter implementation as a single, well-scoped task, consistent with Part 2's "small, clear tasks" coding-workflow rule: *"Create Flutter code for the Splash screen exactly per PrepGraph-Screen-Spec-01."*
