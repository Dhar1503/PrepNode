# PrepGraph Design System v1.0
### "Prepare with Purpose"
**Material Design 3 · Flutter · Google Play Store Grade**

---

## 0. Design Rationale (Read First)

Before any tokens: competitive exam prep in India carries enormous emotional weight — fear of failure, comparison with siblings/peers, rank anxiety. Every generic "productivity app" palette (cold SaaS blue, gamified neon, or motivational-poster orange) works against PrepGraph's ethics. So the system is built on one idea:

> **A library, not a leaderboard.**

The palette reads like a well-designed academic institution — ink, paper, and a single warm accent reserved for *effort and progress*, never for rank. Nothing in this system is red-coded as "failure." Nothing visualizes another student. Every state — empty, loading, error — is written as a mentor would speak, not a scoreboard.

---

## 1. Brand Identity

**Name:** PrepGraph
**Tagline:** Prepare with Purpose
**Personality:** Calm mentor, not a coach shouting motivation. Think "a quiet senior IAS officer explaining a concept over chai" — warm, precise, unhurried.

**Brand Pillars → Design Translation**

| Value | Visual/Interaction Translation |
|---|---|
| Learning over memorization | Concepts shown as connected graphs, not flashcard counters |
| Progress over perfection | Progress bars never show "% wrong," only "% covered / mastered" |
| Purpose over pressure | No countdown timers styled in red; no streak-loss guilt UI |
| Support over comparison | No leaderboards, no percentile displays, no "others scored higher" |
| Fairness for every learner | Equal visual weight to every exam track; no "premium badge" shaming |
| Transparency in recommendations | Every AI suggestion has a visible "Why this?" affordance |

**Logo mark concept:** A single node branching into three calm arcs (representing a knowledge graph) — never an upward "growth arrow" (implies race/competition). Rendered in Ink Indigo on Paper White.

**Brand adjectives (for every copy/UI decision):** *Calm · Clear · Credible · Encouraging · Unhurried.*
**Anti-adjectives (never):** flashy, urgent, competitive, gamified-loud, childish.

---

## 2. Color Palette

Avoiding both the "warm-cream+terracotta" and "near-black+neon" AI-default palettes. PrepGraph's palette is grounded in Indian academic tradition: **ink, paper, and marigold** — the colors of handwritten notes, library halls, and exam-hall optimism (marigold is used in India for beginnings/exams/blessings, not celebration-after-winning).

### 2.1 Core Brand Colors

| Token | Hex | Usage |
|---|---|---|
| `pg.ink.900` (Primary) | `#1B2A4A` | Deep Ink Indigo — primary actions, headers, active states |
| `pg.ink.500` | `#3A538C` | Mid-tone primary, links, selected chips |
| `pg.marigold.500` (Secondary) | `#E5A73B` | Warm Marigold — progress fills, streaks, encouragement accents |
| `pg.sage.500` (Tertiary) | `#5C8A72` | Sage Green — mastery/completion signals, calm confirmations |
| `pg.paper.50` | `#FBFAF6` | Paper White — base background (warm, not clinical white) |
| `pg.graphite.700` | `#2E2E33` | Body text on light backgrounds |

### 2.2 Material 3 Color Roles — Light Scheme

| M3 Role | Hex | Notes |
|---|---|---|
| `primary` | `#1B2A4A` | |
| `onPrimary` | `#FFFFFF` | |
| `primaryContainer` | `#DCE3F5` | |
| `onPrimaryContainer` | `#0E1830` | |
| `secondary` | `#B4791F` | Deepened marigold for AA text contrast |
| `onSecondary` | `#FFFFFF` | |
| `secondaryContainer` | `#FCE9C7` | |
| `onSecondaryContainer` | `#4A3308` | |
| `tertiary` | `#3E6B54` | Deepened sage for text use |
| `onTertiary` | `#FFFFFF` | |
| `tertiaryContainer` | `#D7ECE0` | |
| `onTertiaryContainer` | `#0E2A1C` | |
| `error` | `#8C4A3D` | **Muted terracotta-brown, never pure red** — errors read as "attention," not "danger/failure" |
| `onError` | `#FFFFFF` | |
| `errorContainer` | `#F4DCD5` | |
| `onErrorContainer` | `#3B1A12` | |
| `background` | `#FBFAF6` | |
| `onBackground` | `#2E2E33` | |
| `surface` | `#FFFFFF` | |
| `onSurface` | `#2E2E33` | |
| `surfaceVariant` | `#EAE7DD` | |
| `onSurfaceVariant` | `#4A4842` | |
| `outline` | `#8D8B84` | |
| `outlineVariant` | `#DCD9CE` | |

### 2.3 Material 3 Color Roles — Dark Scheme

| M3 Role | Hex | Notes |
|---|---|---|
| `primary` | `#AEC1EC` | |
| `onPrimary` | `#12213F` | |
| `primaryContainer` | `#293B60` | |
| `onPrimaryContainer` | `#DCE3F5` | |
| `secondary` | `#F0C578` | |
| `onSecondary` | `#402B04` | |
| `secondaryContainer` | `#5C4009` | |
| `onSecondaryContainer` | `#FCE9C7` | |
| `tertiary` | `#9FCBB0` | |
| `onTertiary` | `#0E2A1C` | |
| `tertiaryContainer` | `#27503C` | |
| `onTertiaryContainer` | `#D7ECE0` | |
| `error` | `#E3A897` | |
| `onError` | `#4A241A` | |
| `errorContainer` | `#663527` | |
| `onErrorContainer` | `#F4DCD5` | |
| `background` | `#15161A` | Warm near-black, not pure black |
| `onBackground` | `#E7E5DF` | |
| `surface` | `#1D1E23` | |
| `onSurface` | `#E7E5DF` | |
| `surfaceVariant` | `#333139` | |
| `onSurfaceVariant` | `#C6C3BA` | |
| `outline` | `#8D8B84` | |

**Never used:** pure `#FF0000` red, saturated neon green, greyscale-only "locked" states that look punitive. Streak/rank colors (gold/silver/bronze medal metaphors) are explicitly banned — they imply comparison.

---

## 3. Typography

**Typeface pairing:**
- **Display / Headings:** *Fraunces* (a warm, humanist serif with slight editorial character) — used sparingly, for hero moments (welcome screens, milestone celebrations, onboarding). Gives PrepGraph a "considered publication" feel instead of generic SaaS sans-only design.
- **UI / Body:** *Inter* — for all functional UI text, forms, navigation, data. Excellent legibility at small sizes, ships well in Flutter via `google_fonts`.
- **Numerals / Data:** *Inter Tight* (tabular figures) for scores, timers, percentages — ensures columns of numbers align.

### 3.1 Type Scale (maps to Flutter `TextTheme`)

| Style | Font | Size / Line Height | Weight | Use |
|---|---|---|---|---|
| `displayLarge` | Fraunces | 57 / 64 | 500 | Splash, milestone screens only |
| `displayMedium` | Fraunces | 45 / 52 | 500 | Onboarding hero text |
| `headlineLarge` | Fraunces | 32 / 40 | 500 | Section/page titles |
| `headlineMedium` | Inter | 28 / 36 | 600 | Card group headers |
| `headlineSmall` | Inter | 24 / 32 | 600 | Sub-section headers |
| `titleLarge` | Inter | 22 / 28 | 600 | App bar titles |
| `titleMedium` | Inter | 16 / 24 | 600 | Card titles |
| `titleSmall` | Inter | 14 / 20 | 600 | List item titles |
| `bodyLarge` | Inter | 16 / 24 | 400 | Primary reading text |
| `bodyMedium` | Inter | 14 / 20 | 400 | Secondary text, descriptions |
| `bodySmall` | Inter | 12 / 16 | 400 | Captions, timestamps |
| `labelLarge` | Inter | 14 / 20 | 600 | Buttons |
| `labelMedium` | Inter | 12 / 16 | 600 | Chips, tags |
| `labelSmall` | Inter | 11 / 16 | 600 | Overlines, badges |
| `numeralData` | Inter Tight | 20–40 / 1.2 | 600 (tabular) | Scores, %, timers, charts |

**Rules:** Never set Fraunces below 22px (it loses character at small sizes). Body copy line length capped at ~68 characters for reading comfort. Sentence case everywhere — no ALL CAPS except `labelSmall` overlines at ≤11px with +0.5 letter-spacing.

---

## 4. Spacing System

Base unit: **4px**, scaled in an 4/8pt hybrid (Apple-level breathing room + Material rigor).

| Token | Value | Usage |
|---|---|---|
| `space.4xs` | 2px | Icon-to-label micro gaps |
| `space.3xs` | 4px | Chip internal padding |
| `space.2xs` | 8px | Compact element gaps |
| `space.xs` | 12px | Related-item spacing |
| `space.sm` | 16px | Standard content padding (default screen margin) |
| `space.md` | 24px | Section spacing within a card |
| `space.lg` | 32px | Between distinct card groups |
| `space.xl` | 48px | Between major page sections |
| `space.2xl` | 64px | Hero/onboarding vertical rhythm |
| `space.3xl` | 96px | Splash/empty-state vertical centering |

**Screen margins:** 16px mobile default, 24px on tablets ≥600dp.
**Touch targets:** minimum 48×48dp (Material 3 / accessibility floor), with 8px minimum gap between adjacent tappable targets.

---

## 5. Grid System

- **Base grid:** 4dp baseline grid underlying all layout.
- **Columns:** 4-column grid on phones (compact, <600dp), 8-column on foldable/tablet (medium, 600–840dp), 12-column on large tablet/desktop (expanded, >840dp) — per Material 3 window size classes.
- **Gutters:** 16px (compact), 24px (medium), 24px (expanded).
- **Content max-width:** 720px on expanded layouts — text and cards never stretch edge-to-edge on tablets, preserving reading comfort.
- **Card grid:** Dashboard cards snap to a 2-column grid on compact, 3-column on medium+, using a consistent 16px gutter.

---

## 6. Elevation

Material 3 tonal elevation (color-based, not just shadow-based) — surfaces get subtly warmer/lighter as they rise, avoiding heavy drop-shadows that feel "app-store generic."

| Level | Elevation | Usage |
|---|---|---|
| `el.0` | 0dp | Base background, flat content |
| `el.1` | 1dp | Resting cards, list rows |
| `el.2` | 3dp | Raised cards (active practice card, today's plan) |
| `el.3` | 6dp | App bar on scroll, bottom sheets at rest |
| `el.4` | 8dp | FAB, dialogs |
| `el.5` | 12dp | Modal bottom sheets (expanded), navigation drawer |

Each level pairs a **tonal surface tint** (surface mixed with primary at 5–14% depending on level) with a **matching shadow token** below — never shadow alone.

---

## 7. Shadows

Soft, diffused, warm-tinted shadows (never pure black) — consistent with "paper" material metaphor.

| Token | Value | Pairs with |
|---|---|---|
| `shadow.xs` | `0 1px 2px rgba(27,42,74,0.06)` | `el.1` |
| `shadow.sm` | `0 2px 6px rgba(27,42,74,0.08)` | `el.2` |
| `shadow.md` | `0 4px 12px rgba(27,42,74,0.10)` | `el.3` |
| `shadow.lg` | `0 8px 24px rgba(27,42,74,0.12)` | `el.4` |
| `shadow.xl` | `0 16px 40px rgba(27,42,74,0.16)` | `el.5` |

Shadow color derives from `pg.ink.900` at low opacity — ties shadows back to brand ink rather than generic grey/black.

---

## 8. Corner Radius

A single consistent radius language signals "calm," avoiding the mixed-radius look of template UI kits.

| Token | Value | Usage |
|---|---|---|
| `radius.xs` | 8px | Chips, tags, small badges |
| `radius.sm` | 12px | Buttons, text fields, list rows |
| `radius.md` | 16px | Standard cards |
| `radius.lg` | 24px | Feature cards, hero cards, bottom sheets (top corners) |
| `radius.xl` | 28px | Dialogs |
| `radius.full` | 999px | Pills, FAB, avatar, progress rings |

---

## 9. Buttons

| Variant | Style | Usage |
|---|---|---|
| **Filled** | `pg.ink.900` bg, white text, `radius.sm`, `el.1` on rest | Primary action per screen (max 1 visible at a time) |
| **Tonal** | `secondaryContainer`/`tertiaryContainer` bg | Secondary actions (e.g., "Save for later") |
| **Outlined** | 1px `outline`, transparent bg | Tertiary actions |
| **Text** | No container, `pg.ink.500` text | Low-emphasis actions, dialog dismiss |
| **FAB** | `radius.full`, `pg.marigold.500` bg, `el.4` | Single global action: "Continue studying" / "Resume" |

**Sizing:** height 48dp (default), 56dp (large/FAB-adjacent CTA on home). Horizontal padding 24px. Label: `labelLarge`.
**States:** rest → hover (desktop/tablet, +4% tonal overlay) → pressed (+8% overlay, scale 0.98) → disabled (38% opacity, no shadow). No red "danger" button style anywhere — destructive actions (e.g., delete a plan) use an Outlined button with `error` color text, never a solid red block.

---

## 10. Cards

**Base card:** `surface` background, `radius.md`, `el.1`, 16–20px internal padding, 1px `outlineVariant` hairline optional in light theme for extra definition on white-on-white contexts.

**Card types:**
- **Concept Card** — topic + mastery indicator (never a numeric rank), tap to expand into graph view.
- **Today's Plan Card** — `el.2`, marigold-tinted progress fill, always shows *what's next*, never *what's overdue* in alarming red.
- **Insight Card** (AI recommendation) — has a visible "Why this?" text-button in the footer (transparency principle) that expands an explanation inline.
- **Milestone Card** — uses Fraunces headline + sage accent, appears only on personal achievement (never comparative).

Cards never stack a shadow AND a border AND a colored background together — one elevation cue per card, kept minimal.

---

## 11. Navigation

**Structure:** 4–5 top-level destinations via Bottom Navigation Bar; secondary/contextual navigation via top App Bar actions and in-card drill-down (push, not modal, for depth >1).

**Primary destinations:** Home · Learn (Graph) · Practice · Insights · Profile.

**Navigation Drawer:** used only on tablet/expanded layout as a permanent rail (Material 3 Navigation Rail) — replaces bottom bar above 600dp width.

**Transitions:** shared-axis (horizontal) between sibling top-level tabs; shared-axis (forward, vertical-ish/scale) when drilling into detail — standard Material 3 motion patterns, 300ms, emphasized easing.

---

## 12. Bottom Navigation

- Height: 80dp (with label), Material 3 `NavigationBar` component.
- Background: `surface` at `el.2` tonal elevation, floating indicator pill (`radius.full`) in `secondaryContainer` behind the active icon.
- Icons: outlined style at rest, filled style when active (standard M3 icon-swap pattern) — filled icon rendered in `pg.ink.900`.
- Labels: always visible (`labelMedium`), never icon-only — reduces cognitive load for exam aspirants who may be revisiting under stress.
- No badge dots in alarming red; unread/new-content badges use a small `secondary` (marigold) dot, capped at a dot — never a number counter that could feel like mounting pressure.

---

## 13. App Bar

- **Default:** `CenterAlignedAppBar` or Large Top App Bar (M3) on primary screens — large title (`headlineSmall`, Fraunces on Home only) collapses to `titleLarge` Inter on scroll.
- Background: transparent → `surface` tonal fill at `el.3` on scroll (standard M3 scroll-elevation behavior).
- Leading: back arrow (24dp, `onSurface`) on drill-down screens only; no hamburger except on tablet rail contexts.
- Trailing actions: max 2 icons + optional profile avatar (32dp, `radius.full`). Notification bell uses outline icon, no red dot — uses marigold dot instead.

---

## 14. Search Bars

- Material 3 `SearchBar` component: `radius.full`, height 56dp, `surfaceVariant` fill, `el.1`.
- Leading search icon (`onSurfaceVariant`), trailing filter icon when applicable.
- Placeholder copy is task-specific and warm: *"Search topics, e.g. Indian Polity"* — never a bare "Search…".
- Expands to full-screen search overlay with recent searches and suggested topics (never "trending among other students" — avoids comparison).

---

## 15. Progress Components

Progress is always framed as **coverage and mastery**, never rank.

- **Linear progress bar:** `radius.full`, track in `surfaceVariant`, fill in `pg.marigold.500` (or `pg.sage.500` once a topic reaches "mastered" threshold — a deliberate color shift that rewards depth over speed).
- **Circular mastery ring:** used on Concept Cards; 3-stop scale — Not Started (`outlineVariant` ring), In Progress (`marigold` arc), Mastered (`sage` full ring + soft checkmark, no confetti/badge iconography that implies competition).
- **Study streak indicator:** shown as a *personal calendar heatmap* (like a garden growing), not a "streak counter" with fire emoji pressure. Missing a day never resets to zero or shows a "broken streak" warning — it simply shows a lighter dot, framed as "a day of rest."
- **Syllabus coverage bar:** horizontal, segmented by subject, always shows "X% of syllabus explored" — copy explicitly avoids "completed" (implies pass/fail finality) in favor of "explored / revised / mastered."

---

## 16. Analytics Components

Personal-only analytics — no cohort, percentile, or peer-comparison visualizations anywhere in the app.

- **Strength Map:** radial/graph visualization of topics colored by personal mastery (sage=strong, marigold=building, ink-outline=not yet started). Replaces traditional "weak areas in red" heat-maps.
- **Time Invested Summary:** shown as hours of focused study this week vs. personal average — never vs. other users.
- **Confidence Trend:** a gentle line chart of self-reported confidence per topic over time (self-assessed, not score-based) — reinforces "progress over perfection."
- **Recommendation Transparency Panel:** every AI-analytics card carries a small `(i)` affordance opening a plain-language explanation: *"We suggest this because you marked Polity as low-confidence 3 days ago."*

---

## 17. Charts

- **Library:** `fl_chart` (Flutter-native, fully themeable) recommended over WebView-based charting for performance and theme consistency.
- **Chart palette:** max 3 data colors on any single chart — `pg.ink.500`, `pg.marigold.500`, `pg.sage.500` — plus neutral greys for gridlines (`outlineVariant`). No red/green "good/bad" binary coding.
- **Types used:** horizontal bar (subject-wise time), radial/donut (mastery distribution), line (confidence trend over time), heatmap calendar (consistency, not streak-shaming).
- **Axes & gridlines:** hairline `outlineVariant`, no harsh black gridlines. Labels in `bodySmall`, numerals in `numeralData` style with tabular figures.
- **Never used:** leaderboard bar charts, rank-order sorted charts that expose "you are below average," pie charts with more than 4 segments (readability).

---

## 18. Dialogs

- `radius.xl` (28px), `el.4`, `surface` background, max-width 320–360dp on phones (M3 basic dialog sizing).
- Title: `headlineSmall` Inter, body: `bodyMedium`.
- Max 2 actions (Text buttons, right-aligned): primary action always phrased as a specific verb ("Reschedule," "Got it") — never bare "OK/Cancel" when a clearer verb exists.
- Destructive confirmation dialogs use calm, factual copy (e.g., "This will remove your saved plan for Polity. This can't be undone.") — no guilt language ("Are you sure you want to give up?").

---

## 19. Bottom Sheets

- Modal bottom sheet: `radius.lg` top corners only, drag handle (32×4dp, `outlineVariant`, centered, 8px top margin), `el.5`.
- Used for: filter/sort controls, quick topic actions, "Why this recommendation?" expansions, plan editing.
- Non-modal (persistent) bottom sheet used sparingly for in-context tools during active practice sessions (e.g., a calculator or formula sheet) that shouldn't block the main content.
- Scrim: `pg.ink.900` at 40% opacity (warm-tinted scrim rather than pure black) in light theme; 60% in dark theme.

---

## 20. Snackbars

- Single-line default (`bodyMedium`, `inverseSurface` background — per M3 spec, so it stands apart from page content), `radius.sm`, `el.3`, floating 16px from bottom edge (above bottom nav / FAB).
- Optional single text action (e.g., "Undo"), right-aligned, `secondary` color.
- Tone: factual and warm — *"Plan updated for tomorrow."* / *"Note saved."* Never exclamation-heavy ("Great job!!") which can feel patronizing at scale; save genuine warmth for Success States (§29) and milestone moments, not routine confirmations.

---

## 21. Icons

- **Icon set:** Material Symbols (Rounded variant) — rounded terminals match the app's calm, soft-radius language better than Sharp/Outlined-only defaults.
- **Weight:** 400 default, 500 for active/selected nav states.
- **Sizing:** 24dp standard, 20dp inline-with-text, 32dp feature/empty-state illustration icons.
- **Color:** icons inherit `onSurfaceVariant` at rest, `primary` or `secondary` when active/selected — never independently colored per icon (avoids a "clip-art" look).
- **Custom icon needs** (graph/knowledge-map, mastery ring, confidence-meter): custom-drawn in the same 24dp grid, rounded stroke terminals, 2dp stroke weight to match Material Symbols Rounded visually.

---

## 22. Animations

Motion is used to convey calm continuity, never urgency.

- **Duration scale:** `short1` 100ms (icon toggles) · `short4` 200ms (chip/button state) · `medium2` 300ms (page transitions) · `long2` 500ms (progress ring fill, milestone reveal).
- **Easing:** Material 3 Emphasized easing curve (`cubic-bezier(0.2, 0.0, 0, 1.0)`) for navigation; Standard easing for micro-interactions.
- **Signature motion moment:** when a topic reaches "Mastered," the mastery ring completes with a slow (500ms) sage-colored sweep and a single soft particle-free glow pulse — deliberately quiet, no confetti, no sound-heavy celebration, respecting users who study in shared/quiet spaces.
- **Reduced motion:** all transitions have a cross-fade fallback (150ms opacity-only) when the OS-level "reduce motion" accessibility setting is on.
- **Loading motion:** skeleton shimmer (see §27) rather than spinners wherever content shape is predictable; spinners reserved for indeterminate actions <2s.

---

## 23. Light Theme (Summary)

- Background `#FBFAF6`, Surface `#FFFFFF`, Primary `#1B2A4A`, Secondary `#B4791F`, Tertiary `#3E6B54`, Error `#8C4A3D`.
- Feels like: a well-lit reading room. High legibility, warm paper undertone (not clinical white), ink-dark primary for authority and calm.
- Default theme for all new installs (competitive-exam study often happens in daylight/library settings).

## 24. Dark Theme (Summary)

- Background `#15161A`, Surface `#1D1E23`, Primary `#AEC1EC`, Secondary `#F0C578`, Tertiary `#9FCBB0`, Error `#E3A897`.
- Feels like: late-night study lamp — warm near-black (not pure OLED black, which can feel harsh/cold), softened accent tones to reduce eye strain during late revision sessions.
- Auto-switches with system setting by default; manual override available in Profile settings.

---

## 25. Accessibility

- **Contrast:** all text/background pairs meet WCAG 2.1 AA (4.5:1 body, 3:1 large text) — verified per token pairing above, not just per-component spot checks.
- **Touch targets:** 48×48dp minimum, 8dp minimum spacing.
- **Text scaling:** full support for OS-level font scaling up to 200% without truncation — layouts use `Flexible`/`Wrap`, not fixed-height text containers.
- **Color independence:** mastery/progress states are never conveyed by color alone — always paired with an icon or label (e.g., outline ring vs. filled ring vs. checkmark, not just color hue change) for color-blind users.
- **Screen reader:** all icons have semantic labels; charts include a text-equivalent summary ("You've explored 68% of the Polity syllabus") accessible via `Semantics` widgets.
- **Reduced motion & haptics:** respects system-level reduce-motion; haptic feedback is light (`HapticFeedback.selectionClick`) and can be fully disabled in settings.
- **Language/reading level:** UI copy defaults to clear, sentence-case, plain language (roughly grade 8 reading level) given the app's use by aspirants for whom English may be a second language.

---

## 26. Empty States

Empty states are framed as **invitations**, never as absence/failure.

- Illustration: simple, single-line-weight custom line art (ink-colored stroke, marigold single accent dot) — no generic stock "empty box" icon.
- Copy pattern: [What's here normally] + [one clear action]. E.g., *"Your strength map will appear here once you complete your first topic. Ready to start?"* → Filled button: "Explore your first topic."
- Never uses guilt/shame framing ("You haven't studied anything yet").

---

## 27. Loading States

- **Skeleton screens** (shimmer, `surfaceVariant` base with a soft 1200ms shimmer sweep) for predictable content: cards, lists, profile.
- **Indeterminate circular spinner** (`primary` color, 24–40dp) only for actions under ~2 seconds (button-embedded loading, e.g., "Saving...").
- **AI "thinking" state** (for personalized recommendations): a custom 3-dot pulse in marigold, paired with reassuring microcopy — *"Personalizing your plan..."* — never a bare spinner with no context, since AI-wait states are a key trust moment.

---

## 28. Error States

Errors are treated as information, in a calm, factual voice — never alarming.

- Color: `error` role (`#8C4A3D` light / `#E3A897` dark) — a muted terracotta-brown, deliberately never saturated red, so an error never visually reads as "you failed."
- Inline field errors: small icon + `bodySmall` message directly below the field, e.g., *"Enter a valid phone number."*
- Full-screen errors (network/server): friendly line illustration + copy explaining what happened and the one recoverable action — *"We couldn't load your plan. Check your connection and try again."* + Filled "Try again" button.
- No error ever references performance/scores (e.g., never "Your score failed to load" phrased in a way that could read as a value judgment) — reworded to neutral system language ("This data couldn't load right now").

---

## 29. Success States

Success is quiet, personal, and specific — never a generic "Congratulations!" burst.

- Uses `tertiary` (sage) color family + a single soft checkmark motion (see §22 signature motion).
- Copy is specific to the action and forward-looking: *"Nice — you've revised Modern History twice this week."* rather than generic praise, tying feedback back to the effort (supports "progress over perfection").
- Milestone success (e.g., finishing a full subject) may use a Fraunces headline moment on a dedicated full-screen card, still calm — no fireworks/confetti animation, consistent with "no fear-based/hype-based UX" ethic extended positively (avoid manufactured hype too).

---

## 30. Tone of Voice

**Voice:** A calm, competent mentor — like a favorite teacher who has seen a thousand students pass this exam and genuinely believes you will too, without ever needing to raise their voice.

**Principles:**
1. **Plain verbs, active voice.** "Save your plan," not "Your plan can be saved."
2. **Specific, not generic praise.** Reference the actual behavior/topic, not empty enthusiasm.
3. **No fear words.** Avoid "failing," "behind," "weak," "losing streak," "falling behind others." Prefer "still exploring," "building confidence," "next up."
4. **No comparison words.** Avoid "top," "rank," "beat," "compete," "better than." PrepGraph never mentions other users in copy.
5. **Explain, don't command.** AI suggestions are framed as offers with reasoning ("Based on your last session, here's what might help") not directives ("You must do this now").
6. **Errors and empty states speak in system voice, not personal voice** — factual, never apologetic-to-excess, never self-deprecating ("Oops, our bad!" is avoided in favor of "This didn't load. Let's try again.").
7. **Sentence case everywhere**, including buttons and titles — reinforces the calm, non-shouty register (no ALL CAPS CTAs).

**Sample copy bank:**
| Context | ✅ PrepGraph voice | ❌ Avoid |
|---|---|---|
| Streak break | "You took a rest day. Ready to continue Polity?" | "Streak lost! Don't give up!" |
| Low practice score | "You're still building confidence here. Let's revisit the basics together." | "You scored low. Improve now!" |
| Recommendation | "Based on your recent notes, we think Geography might help next." | "You NEED to study Geography!" |
| Milestone | "You've now explored every topic in Indian Polity." | "You WON Indian Polity! 🏆" |

---

## Summary: Design Tokens at a Glance

```
Color      → Ink #1B2A4A · Marigold #E5A73B · Sage #5C8A72 · Paper #FBFAF6
Type       → Fraunces (display, sparing) + Inter (UI) + Inter Tight (data)
Spacing    → 4px base, 16/24/32/48px rhythm
Radius     → 8 / 12 / 16 / 24 / 28 / full
Elevation  → Tonal (M3), 0–5, warm-tinted shadows only
Motion     → 100–500ms, Emphasized easing, no confetti, reduce-motion respected
Voice      → Calm mentor · specific praise · zero comparison · zero fear
```

This document is the single source of truth for all PrepGraph screen design. No screen should introduce a color, radius, shadow, or copy pattern not defined here without a documented exception.
