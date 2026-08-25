# PrepGraph — Screen Spec 02: Onboarding Carousel
### Built on Design System v1.0 · Screen S0.2 (Information Architecture v1.0)

---

## 0. Shared Carousel Mechanics

The mockup above shows the chrome that stays identical across all four pages — only the illustration, headline, and supporting text change. Documenting this once here avoids repeating it four times below.

- **Structure:** `Skip` (top-right, always available) → Illustration zone (fixed height, ~220dp) → Headline + Supporting text (fixed vertical position) → Page indicator (4 dots) → Primary button (`Next` on pages 1–3, `Get started` on page 4).
- **Why every page keeps identical geometry:** if the illustration, text block, and button all sat at different vertical positions per page, swiping would feel like flipping between unrelated screens rather than one continuous idea unfolding. Fixed geometry is what makes the carousel read as *one thought*, told in four parts.
- **Page indicator:** active dot is a 20×6dp pill in `pg.ink.900`; inactive dots are 6×6dp circles in `pg.outlineVariant` (`#DCD9CE`) — never a numbered "1 of 4," which would frame onboarding as a chore to get through rather than a short story.
- **Skip:** always present, always the same weight (`bodyMedium`, `pg.graphite.700` at reduced emphasis) — never hidden or de-prioritized, per the earlier UX-journey finding that impatient, time-pressed users (like the Dharani persona) must never be made to sit through unwanted content.
- **Swipe + button both work** — a user can swipe directly or tap Next; both update the indicator identically.

---

## 1. Screen 1 — Welcome

**Job:** Replace first-launch uncertainty with a simple, believable promise — *this app understands the problem*, before asking for anything.

### Illustration idea
A single open notebook, drawn in thin ink-colored line art (no fill, 2dp stroke, matching the Design System's icon stroke weight), with one small marigold dot marking a spot on the page — like a bookmark or a single highlighted line. No student figure, no laptop, no generic "graduation cap" cliché — the notebook is PrepGraph's own visual vocabulary (handwritten notes, quiet study) rather than borrowed exam-app iconography.

### Headline
**"Welcome to PrepGraph."**

Deliberately plain — a greeting, not a pitch. No adjectives doing marketing work ("revolutionary," "smarter").

### Supporting text
"A companion for your exam preparation — built around your syllabus, your pace, and your goals."

Three concrete nouns (syllabus, pace, goals) instead of abstract promises ("success," "results") — grounds the claim in something checkable.

### Layout
Standard carousel geometry (§0). Illustration occupies the full fixed zone, centered, sized to roughly 60% of the zone's width so it doesn't feel cramped against the dashed-boundary area shown in the mockup.

### Animation
On page load (whether arriving from Splash or swiping back to page 1): illustration fades + rises 8dp (200ms), headline fades in 100ms after, supporting text a further 80ms after — the same gentle cascade principle used on the Splash Screen, so the brand's "arrival" motion language stays consistent from the very first screen to this one.

### Navigation
- Swipe left or tap `Next` → Screen 2 (Prepare with Purpose).
- Tap `Skip` → routes directly to Login/Register choice (S0.3/S0.4), bypassing pages 2–4 entirely.
- No back-swipe target (this is page 1; swiping right does nothing, no rubber-band bounce needed beyond the OS default).

### Accessibility
- Screen reader announces: "Welcome to PrepGraph. A companion for your exam preparation, built around your syllabus, your pace, and your goals. Page 1 of 4."
- Illustration is marked `decorative` / given an empty semantic label (it adds no information not already in the text) so screen-reader users aren't forced to sit through a description of line art.
- `Skip` and `Next` both meet the 48×48dp touch target minimum with 8dp clearance from screen edges.

---

## 2. Screen 2 — Prepare with Purpose

**Job:** Introduce the *planning* half of the product (Planner, PYQ awareness) without yet using the word "AI" — earn the concept before naming the mechanism.

### Illustration idea
A simple calendar grid (7×1 row, one week), where most day-cells are plain outlines and exactly one cell is filled with a soft marigold tint and a small checkmark — representing "today's one clear task," not a wall of demands. This deliberately mirrors the Design System's streak-heatmap visual language (§15) so the onboarding illustration and the real in-app component the user will later see are visually the same idea, not two unrelated pieces of art.

### Headline
**"Prepare with Purpose."**

The brand tagline itself, used here as this screen's headline — its one appearance as a headline in the whole app, tying the carousel directly back to the brand identity rather than treating the tagline as a throwaway logo subtitle.

### Supporting text
"Each day, we highlight what matters most — based on your syllabus, previous years' patterns, and where you're starting from."

Names the actual inputs (syllabus, previous years' patterns, starting point) rather than a vague "personalized for you" — consistent with the Explainable AI principle showing up even at the onboarding stage, before the user has met a single real recommendation.

### Layout
Identical geometry to Screen 1. The calendar illustration is wider than tall, so it's centered with slightly more horizontal padding (24dp instead of the default 16dp) to avoid it looking stretched edge-to-edge.

### Animation
Standard cascade entrance (as Screen 1). Additional micro-detail: the single filled calendar cell's checkmark draws in with a short 300ms stroke-path animation (SVG `strokeDashoffset` from full to 0) timed to land right as the headline finishes fading in — a small, quiet "aha" beat rather than a static illustration.

### Navigation
- Swipe left / tap `Next` → Screen 3 (Learn with Clarity).
- Swipe right → back to Screen 1.
- `Skip` → same behavior as Screen 1 (jumps straight to Login/Register).

### Accessibility
- Announcement: "Prepare with purpose. Each day, we highlight what matters most, based on your syllabus, previous years' patterns, and where you're starting from. Page 2 of 4."
- The stroke-draw checkmark animation respects reduced-motion settings — under that setting, the checkmark simply appears at full opacity with no path animation.

---

## 3. Screen 3 — Learn with Clarity

**Job:** Introduce the Knowledge Graph concept — PrepGraph's core differentiator — in a way that's felt, not explained with jargon like "knowledge graph."

### Illustration idea
Three small circles connected by two thin lines — a direct, smaller-scale echo of the splash logo mark itself (per Brand Identity's "single node branching into three calm arcs"), but here labeled loosely with faint, non-literal shapes suggesting "a topic leads to another topic" rather than actual syllabus text (avoiding the risk of the illustration looking outdated if syllabus content changes). One line between two of the nodes is drawn slightly bolder — implying "some connections matter more than others" without needing a caption to explain it.

### Headline
**"Learn with Clarity."**

### Supporting text
"Topics aren't studied in isolation — see how they connect, so you always know what to revisit before moving on."

Explains the *reason* the graph exists (sequencing/prerequisite clarity) rather than describing the feature mechanically ("interactive knowledge graph visualization").

### Layout
Same fixed geometry. Because this illustration is more abstract than Screens 1–2, it's given slightly more optical weight — same zone height, but the three-node graphic is centered with generous surrounding negative space so it doesn't feel like it's trying to convey more detail than three dots and two lines actually can.

### Animation
Standard cascade entrance. The bolder connecting line performs a very subtle 400ms width transition (from matching-weight to emphasized-weight) after the illustration settles — the only page in the carousel where an element continues to change slightly after arrival, since "which connection matters more" is literally the idea being taught, and a static image can't carry that distinction as well as one quiet transition can.

### Navigation
- Swipe left / tap `Next` → Screen 4 (Grow with Confidence).
- Swipe right → back to Screen 2.
- `Skip` → same as above.

### Accessibility
- Announcement: "Learn with clarity. Topics aren't studied in isolation. See how they connect, so you always know what to revisit before moving on. Page 3 of 4."
- The line-weight transition is purely decorative reinforcement of text already conveyed verbally — no accessibility dependency on it; disabled entirely under reduced-motion.

---

## 4. Screen 4 — Grow with Confidence

**Job:** Close the carousel on an emotional note — progress and self-trust — while transitioning the user toward the one real decision this flow has been building to: creating an account.

### Illustration idea
A single, softly rising line (like a calm, gentle upward path — not a sharp "growth arrow" or bar chart, both of which the Design System explicitly avoids as competitive/race imagery). Three small sage-green dots sit along the line at increasing height, each slightly larger than the last — suggesting accumulated, personal progress over time, with no axis labels, no numbers, and certainly no percentile or comparison marks.

### Headline
**"Grow with Confidence."**

### Supporting text
"Progress here is measured against your own starting point — never against anyone else's."

This is the one line in the entire onboarding flow that states PrepGraph's ethical stance directly and plainly, rather than only implying it — earned placement, since by page 4 the user has already seen three screens of supporting evidence and is ready to hear the underlying principle named outright.

### Layout
Same fixed geometry as prior three pages, with one addition: the primary button reads **"Get started"** instead of "Next" — the only page where button label changes, signaling this is the transition point without needing extra copy to explain it.

### Animation
Standard cascade entrance, plus: the three sage dots along the rising line appear in sequence (left to right, 150ms apart, each with a small scale-up-from-0.8 pop) rather than all fading in simultaneously — a small sense of "building up" that visually rhymes with the headline's meaning, timed to finish just as "Get started" fades in.

### Navigation
- Swipe left → no further page (this is the last page; swipe does nothing beyond default OS edge behavior).
- Tap **"Get started"** → routes to Login/Register choice (S0.3/S0.4) — same destination as `Skip` on every other page, meaning all paths through onboarding converge on one consistent next step regardless of how much of the carousel a user actually watched.
- Swipe right → back to Screen 3.
- `Skip` → still present and functionally identical to "Get started" here, kept only for UI consistency across all four pages rather than because it serves a different purpose on this specific page.

### Accessibility
- Announcement: "Grow with confidence. Progress here is measured against your own starting point, never against anyone else's. Page 4 of 4. Get started button available."
- The sequenced dot animation is decorative; disabled under reduced motion, replaced by all three dots appearing at once at full opacity.
- Focus moves to the "Get started" button automatically once this page becomes active (for keyboard/switch-access users), since it's now the primary expected action.

---

## 5. Cross-Screen Consistency Notes

- **No screen uses superlatives** ("best," "smartest," "#1") or urgency language ("don't miss out," "join now") anywhere in headline or supporting text — every line was written to survive being read back literally as a factual claim.
- **Each headline is exactly the module name it introduces** (Welcome / Prepare with Purpose / Learn with Clarity / Grow with Confidence) — this is deliberate repetition, not a missed opportunity for cleverer copy: by the time a user reaches the real Planner, Learn, and Insights tabs later, the naming will already feel familiar rather than newly introduced.
- **Illustration palette is limited to two accent colors total across all four screens** (marigold in Screens 1–2, sage in Screens 3–4) plus ink line-work throughout — keeps the whole carousel feeling like one coherent visual set rather than four separately-designed graphics.
- **No screen mentions "AI"** — Screen 2 describes the planning behavior, Screen 3 describes the graph behavior, without naming the underlying mechanism. This mirrors the product's own Explainable-AI stance: earn trust in what the system does before naming what powers it.

---

## 6. Flutter-Friendly Layout Description

*(Structural description only — no code.)*

- **Container:** a `PageView` (or `PageView.builder` over a 4-item list of page-content models) wrapped in the same `Scaffold` background (`pg.paper.50`) used on Splash — no app bar.
- **Persistent overlay elements** (Skip button, page indicator, primary button) sit in a `Stack` above the `PageView`, not inside each page — this guarantees their fixed screen position stays pixel-identical across swipes, rather than being re-laid-out per page (which risks a visible "jump" if any page's content height differs even slightly).
- **Skip:** a `TextButton` positioned top-right via `Positioned` / `SafeArea` padding, bound to a single navigation callback shared across all four pages.
- **Page indicator:** a small custom `Row` of `AnimatedContainer` widgets (each animating `width` between 6dp and 20dp, and `color` between active/inactive tokens, over ~200ms) driven by the `PageController`'s current page value via a listener, not by four independently-built dot widgets.
- **Each page's content:** a `Column` inside the `PageView` item — illustration widget (fixed-height `SizedBox` wrapping an SVG via `flutter_svg`), then headline `Text` (Fraunces `headlineMedium`-equivalent), then supporting text `Text` (Inter `bodyMedium`), matching the vertical rhythm described in §0.
- **Primary button:** a single `AnimatedSwitcher` or conditional label swap (`Next` vs `Get started`) on one persistent `FilledButton` instance — not four separate buttons — driven by whether `PageController.page == 3`.
- **Entrance animation per page:** each page's `Column` children individually wrapped in `FadeTransition` (+ `SlideTransition` for the 8dp rise), restarted via `AnimationController.forward(from: 0)` triggered on `PageView.onPageChanged`, so the cascade in §0/§1 replays correctly both on forward swipes and on swiping back.
- **Routing:** `Skip` and the final `Get started` button both call the same navigation method (`context.go('/auth')` or equivalent), reinforcing the "all paths converge" rule from §4.

---

This spec is ready for handoff as a single scoped Windsurf task: *"Create Flutter code for the Onboarding carousel exactly per PrepGraph-Screen-Spec-02, four pages, shared PageView chrome."*
