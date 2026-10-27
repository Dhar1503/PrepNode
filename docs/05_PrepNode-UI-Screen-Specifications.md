# PrepNode — Complete UI Screen Specifications v1.0
### Developer Handoff Document · Built on Design System v1.0 + Information Architecture v1.0

This document gives every screen a complete, implementable spec. Screen IDs in parentheses reference the Information Architecture document (e.g. `S2.1`). API paths reference the Technical Architecture document's endpoint conventions (`/auth/register`, `/planner/:userid`, etc.) — any endpoint not previously defined is specified here for the first time and should be added to the backend route list.

---

## 1. Splash Screen (`S0.1`)

**Screen purpose:** Brand introduction + silent session check before routing.
**User goal:** "Is the app opening correctly?" (largely unconscious — this screen should not require the user to *want* anything from it).

**Layout structure:** Single vertically-centered lockup — logo mark (64dp) → wordmark (Fraunces 24px) → tagline (Inter 13px), optical center at 38% screen height. Full detail in Screen Spec 01.
**Components used:** `OnboardingIllustration`-style custom-painted logo mark, branded `Text` widgets, no interactive components.
**User interactions:** None — zero interactive elements by design.
**Navigation flow:** Auto-routes after session check + minimum 900ms hold → `/onboarding` (no session/new user) or `/home` (valid session) or `/auth/login` (expired session).
**Required data:** Local secure-storage session token only; no remote call.
**API requirements:** None. (Optional: a lightweight `GET /health` ping if a "server unreachable" pre-check is desired, but not required for routing logic.)
**Empty state:** N/A (nothing to be empty).
**Loading state:** The screen itself *is* the loading state — no spinner overlay, per Screen Spec 01 §11 (no visible loading chrome).
**Error state:** If secure storage read fails unexpectedly, silently treat as "no session" and route to onboarding rather than surfacing an error on this screen — a splash-screen error dialog would be jarring on first launch.
**Accessibility:** Single semantic announcement ("PrepNode, Prepare with Purpose, loading"); focus passes to destination screen's heading on route completion; respects reduced-motion (fade-only fallback).

---

## 2. Onboarding (`S0.2`)

**Screen purpose:** Communicate product value across 4 pages before requesting account creation.
**User goal:** "Understand what this app actually does for me, quickly, or skip straight past it."

**Layout structure:** Shared `PageView` chrome — Skip (top-right) → illustration zone (fixed 220dp) → headline + supporting text (fixed position) → page indicator (4 dots) → primary button. Full detail in Screen Spec 02.
**Components used:** `OnboardingSkipButton`, `OnboardingPageIndicator`, `OnboardingPrimaryButton`, `OnboardingPageViewItem`, `OnboardingIllustration`.
**User interactions:** Swipe left/right between pages; tap `Next`/`Get started`; tap `Skip` (any page).
**Navigation flow:** Page 4 "Get started" or any page's "Skip" → `/auth/login` (or a Login/Register choice screen if implemented as a separate intermediary).
**Required data:** Static content only (`kOnboardingPages` constant list) — no remote calls.
**API requirements:** None.
**Empty state:** N/A.
**Loading state:** N/A — content is bundled, not fetched.
**Error state:** N/A.
**Accessibility:** Each page announces headline + supporting text + "Page X of 4" as one sentence; illustrations marked decorative; Skip/Next meet 48dp touch targets; reduced-motion collapses all entrance animation to a single 150ms cross-fade.

---

## 3. Login (`S0.3`)

**Screen purpose:** Authenticate a returning user.
**User goal:** "Get back into my account with minimum friction."

**Layout structure:** Logo (small, top) → "Welcome back!" headline → Email field → Password field (with visibility toggle) → primary `Login` button → `Continue with Google` secondary button → `Forgot password?` text link → `Don't have an account? Register` text link at bottom. Generous vertical spacing (`space.lg` between field group and buttons) per Apple-level spacing principle.
**Components used:** `AppTextField` (reusable, with built-in error-state styling per Design System §28), `FilledButton` (primary), `OutlinedButton` or branded Google button (secondary), `TextButton` (forgot password / register link).
**User interactions:** Type email/password; tap visibility-toggle icon on password field; tap `Login`; tap `Continue with Google`; tap `Forgot password?`; tap `Register` link.
**Navigation flow:** Successful login → `/home` (or `/profile-setup` if the account has no completed profile). `Forgot password?` → Forgot Password screen (`S0.5`). `Register` link → `S0.4`.
**Required data:** Input: `email`, `password`. Remote: session token + user profile-completion flag on success.
**API requirements:** `POST /auth/login` → `{ email, password }` → `{ accessToken, refreshToken, user: { id, name, profileComplete } }`. `POST /auth/google` for the Google flow (exchanges a Google ID token for PrepNode's own JWT pair, per Technical Architecture §11).
**Empty states:** N/A (this is an input screen, not a data-list screen).
**Loading state:** `Login` button shows an embedded circular spinner (per Design System §27) and disables itself for the duration of the request; all fields disabled during submission to prevent double-submit.
**Error state:** Inline field-level errors for validation (empty email, malformed email) per Design System §28; a non-field banner/snackbar for auth failure ("Incorrect email or password") — never reveals which field was wrong, standard security practice against user enumeration.
**Accessibility:** Both fields have visible labels (not placeholder-only, so content isn't lost on focus); password visibility toggle has a semantic label ("Show password"/"Hide password"); error messages are announced via `Semantics.liveRegion` when they appear; `Login` button meets 48dp minimum height.

---

## 4. Registration (`S0.4`)

**Screen purpose:** Create a new account.
**User goal:** "Sign up quickly and get to the part where the app actually helps me."

**Layout structure:** Same header treatment as Login → Name field → Email field → Password field → Confirm Password field → primary `Create Account` button → `Continue with Google` → `Already have an account? Log in` link.
**Components used:** Same `AppTextField` family as Login, with real-time password-match validation on the Confirm field.
**User interactions:** Type all fields; live validation feedback as user types (debounced, not on every keystroke, to avoid flickering errors); tap `Create Account`.
**Navigation flow:** Successful registration → `/profile-setup` (`S1.1`), always — a new account never has a completed profile. `Log in` link → `S0.3`.
**Required data:** Input: `name`, `email`, `password`, `confirmPassword` (client-side only, never sent to server). Remote: new `userId` + session token.
**API requirements:** `POST /auth/register` → `{ name, email, password }` → `{ accessToken, refreshToken, user: { id, name } }`. Server returns `409 Conflict` with `error.code: "EMAIL_EXISTS"` if the email is already registered.
**Empty states:** N/A.
**Loading state:** Same pattern as Login — button-embedded spinner, fields disabled.
**Error state:** Inline errors: empty fields, invalid email format, password under 8 characters, passwords not matching, and the specific "This email is already registered. Log in instead?" case (per User Journey Stage 2) with a tappable inline link straight to Login, prefilled with the entered email.
**Accessibility:** Same as Login; additionally, password strength/requirement hints are always visible (not only on error) so screen-reader users aren't surprised by a validation failure with no prior context.

---

## 5. Exam Selection & Profile Setup (`S1.1`–`S1.5`)

**Screen purpose:** Capture exam, timeline, availability, and starting level to seed all downstream personalization.
**User goal:** "Tell the app enough about me that its recommendations feel relevant, without a long form."

**Layout structure:** A 5-step linear wizard, one decision per screen, with a top progress indicator (5 segments, not a percentage) and a persistent `Continue` button at the bottom. Step 1 (Exam Selection): a vertically scrollable list of exam cards (TNPSC Group 1/2/4, others greyed as "coming soon"). Step 2 (Goal & Timeline): a date-picker card. Step 3 (Study Availability): a labeled slider (1–8+ hrs) with live preview text. Step 4 (Preparation Level): three equal-weight selectable cards (Beginner/Intermediate/Advanced) — explicitly not stacked in a way that implies hierarchy/ranking. Step 5 (Setup Complete): a brief confirmation screen with the AI "thinking" loading pattern while the first plan generates.
**Components used:** `ExamSelectionCard`, `AppDatePicker`, `AppSlider` with live label, `SelectableLevelCard` (equal visual weight, no crown/star iconography on "Advanced"), `WizardProgressIndicator`, `AiThinkingIndicator` (marigold 3-dot pulse per Design System §27).
**User interactions:** Tap an exam card; pick a date; drag a slider; tap a level card; tap `Continue` on each step; implicit auto-advance from Step 5 once plan generation completes.
**Navigation flow:** Step 1→2→3→4→5 linear, no skipping (each step's choice affects the next screen's defaults). Step 5 auto-navigates to `/home` once `POST /planner/generate` resolves.
**Required data:** Input across steps: `examId`, `targetDate`, `dailyStudyHours`, `preparationLevel`. Remote: `GET /exams` (Step 1 list), then a single combined write on Step 5.
**API requirements:** `GET /exams` → list of `{ id, name, description }`. `POST /users/:userId/profile` → `{ examId, targetDate, dailyStudyHours, preparationLevel }` → `200 OK`. `POST /planner/generate` → `{ userId }` → triggers first Adaptive Planner run, returns the first day's plan (used to prefetch Home's initial state).
**Empty states:** If `GET /exams` returns no data (unlikely, but defensively handled): a calm message — "We're still adding exams. TNPSC is ready to go" — with TNPSC hardcoded as a fallback rather than a blank list.
**Loading state:** Step 1's exam list uses skeleton cards while `GET /exams` resolves. Step 5 uses the `AiThinkingIndicator` with copy "Personalizing your first plan..." per Screen Spec conventions — never a bare spinner here, since this is a key trust moment (User Journey Stage 3).
**Error state:** Network failure on `GET /exams` → full-screen error component with `Try again`. Failure on the final `POST /users/:userId/profile` → inline banner on Step 5 ("This didn't save. Let's try again.") with retry, not a silent redirect to Home with an incomplete profile.
**Accessibility:** Each step's single decision is the only focused interactive element, minimizing cognitive load; the level-selection step's copy explicitly available to screen readers as "helps us personalize, not a judgment of ability," matching the visual reassurance microcopy so screen-reader users get the same ethical framing.

---

## 6. Dashboard / Home (`S2.1`)

**Screen purpose:** The daily anchor screen — surfaces what to do today and quick access to every other module.
**User goal:** "In under 5 seconds, tell me what I should do right now."

**Layout structure:** Scrollable `CustomScrollView` with: (1) Greeting + date row, (2) Today's Purpose Card (rotating supportive line), (3) Today's Plan Card (`el.2` elevation, 1–3 tasks with reasoning preview), (4) Progress snapshot (syllabus coverage + streak heatmap side by side or stacked on narrow screens), (5) Quick Actions grid (2×3 or 3×2 depending on screen width — Learn, Practice, Mock Test, Cutoff, Insights, AI Assistant), (6) Recent Activity list (last 2–3 completed items).
**Components used:** `GreetingHeader`, `PurposeCard`, `TodaysPlanCard`, `SyllabusCoverageBar`, `StreakHeatmap`, `QuickActionCard` (reusable, icon + label), `RecentActivityTile`.
**User interactions:** Pull-to-refresh (re-fetches plan + progress); tap Today's Plan Card → task detail; tap any Quick Action → respective module; tap notification bell (app bar) → Notification Center; tap avatar (app bar) → Profile.
**Navigation flow:** → `S4.3` (task detail), → `S5.1`/`S6.1`/`S7.1`/`S3.1`/`S8.1`/`S12.1` (quick actions), → `S11.1` (bell), → `S10.1` (avatar).
**Required data:** User's first name/greeting time-of-day logic (client-computed), today's plan (with `reason` field per task), syllabus coverage %, streak heatmap data (last ~30 days), quick-action badge state (e.g. unread notification dot).
**API requirements:** `GET /planner/:userId?date=today` → `{ tasks: [{ id, topicName, durationMinutes, reason, status }] }`. `GET /analytics/:userId/summary` → `{ syllabusCoveragePercent, streak: [{ date, studied: bool }] }`.
**Empty states:** First-ever visit (no completed topics yet): Progress card shows an "invitation" framing per Design System §26 ("Your progress map will build up as you go — ready to start?") rather than a bare 0%. If the planner has no tasks for today (e.g. all caught up): a calm "You're all caught up for today — great consistency" message with a `Practice something extra` optional CTA, never an empty white space.
**Loading state:** Skeleton screens for the Today's Plan Card and Progress section (shimmer per Design System §27) while both API calls resolve in parallel; Quick Actions grid renders immediately since it's static content, not fetched.
**Error state:** If the planner fetch fails but analytics succeeds (or vice versa), each card fails independently with its own small inline retry — the whole Home screen never shows one giant full-screen error for a partial data failure.
**Accessibility:** Heading hierarchy (`headlineSmall` greeting as the page's semantic h1-equivalent); Streak heatmap has a text-equivalent summary via `Semantics` ("12 of the last 30 days studied"); Quick Action grid items are all ≥48dp targets with clear labels (never icon-only).

---

## 7. AI Study Planner (`S4.1`–`S4.4`)

**Screen purpose:** Full daily/weekly personalized schedule with explainable reasoning per task.
**User goal:** "See my whole plan, understand *why* each task is there, and adjust it if my day changes."

**Layout structure:** Segmented control at top (`Today` / `This Week`). Today view: vertical list of `TaskCard`s, each expandable to reveal the "Why this?" reasoning. Week view: a 7-column calendar strip with tap-to-jump-to-day.
**Components used:** `SegmentedControl`, `TaskCard` (with embedded `ReasonChip` and Complete/Skip/Reschedule action row), `WeekStrip`, `RescheduleBottomSheet`.
**User interactions:** Switch Today/Week segment; tap a task to expand reasoning; tap `Complete` (marks done, quiet checkmark animation per Design System §22); tap `Skip` (no guilt copy — moves to "skipped" state, still visible, not deleted); tap `Reschedule` → opens bottom sheet with date/time picker.
**Navigation flow:** Tapping a task's main body (not the action buttons) → `S3.3` Topic Detail (if a Learn task) or → `S5.5` Practice Session (if a PYQ task). Reschedule sheet closes back to the same screen with updated state.
**Required data:** Full task objects: `{ id, topicId, title, durationMinutes, reason, type: 'learn'|'pyq'|'revision', status }`.
**API requirements:** `GET /planner/:userId?range=today|week`. `PATCH /planner/task/:taskId` → `{ status: 'completed'|'skipped' }`. `POST /planner/task/:taskId/reschedule` → `{ newDate }`.
**Empty states:** No tasks today (all done or rest day) → supportive "You're all caught up" state (shared component with Home's empty state, §6). Week view with a fully unplanned future day → "Your plan updates each morning based on your progress" rather than a blank grid cell.
**Loading state:** Skeleton `TaskCard`s (3 placeholder rows) while fetching; segmented-control switch shows a brief shimmer only on the changed segment, not a full-screen reload.
**Error state:** Failed fetch → full-screen error component ("We couldn't load your plan. Check your connection and try again."); a failed `Complete`/`Skip` action reverts the optimistic UI update and shows a small snackbar ("Couldn't update this task — try again") rather than silently failing.
**Accessibility:** Each `TaskCard`'s reasoning is available to screen readers as part of the card's combined semantic label, not requiring a separate expand-tap to be discoverable by assistive tech; Complete/Skip/Reschedule are distinct, clearly labeled actions (never icon-only).

---

## 8. PYQ Module — Browse (`S5.1`–`S5.3`)

**Screen purpose:** Let a student navigate Exam → Subject → Topic → Year to find previous-year questions.
**User goal:** "Find PYQs for the specific topic I just studied, or continue where I left off."

**Layout structure:** Practice Home (`S5.1`): a "Continue practicing [Topic]" resume card (if a session exists) above a browsable exam/subject grid. Subject/Topic Browser (`S5.2`): drill-down list with PYQ-count badges and a small repetition-frequency heatmap strip per topic. Topic PYQ List (`S5.3`): a list of individual questions with solved (✓)/unsolved and bookmark (★) indicators, plus a "Practice all" button to enter batch mode.
**Components used:** `ResumeSessionCard`, `SubjectListTile`, `TopicListTile` (with `FrequencyHeatmapChip`), `QuestionListTile` (with status icons), `PracticeAllButton`.
**User interactions:** Tap Resume card → jumps back into an in-progress session; drill through Exam→Subject→Topic; tap an individual question → single Question Detail (`S5.4`); tap "Practice all" → batch Practice Session (`S5.5`); tap bookmark star to toggle.
**Navigation flow:** `S5.1` → `S5.2` → `S5.3` → `S5.4` (single) or `S5.5` (batch, full-screen).
**Required data:** Exam/subject/topic hierarchy with per-node PYQ counts; per-question solved/bookmarked status (per current user).
**API requirements:** `GET /exams/:id/subjects`, `GET /subjects/:id/topics`, `GET /pyq/:exam/:subject/:topic` → `{ questions: [{ id, year, solved, bookmarked, difficulty }] }`. `POST /pyq/:questionId/bookmark` (toggle).
**Empty states:** A topic with zero PYQs recorded yet (data still being added) → "PYQs for this topic are being added — check back soon" rather than a bare empty list; a first-time Practice Home with no resume history → the resume card simply doesn't render (not shown as an empty placeholder, since its absence is self-explanatory).
**Loading state:** Skeleton list tiles at each drill-down level; the frequency heatmap chip shows a neutral placeholder bar during load rather than popping in abruptly.
**Error state:** Standard full-screen error component with retry at any drill-down level; a failed bookmark toggle reverts optimistically and shows a small inline icon-shake (not a full snackbar, to keep this lightweight interaction lightweight).
**Accessibility:** Frequency heatmap chips have a text equivalent ("Appeared in 8 of the last 10 years"); solved/bookmark icon states have semantic labels, not color-only distinction (per Design System §25 color-independence rule).

---

## 9. PYQ Practice Screen (`S5.4`–`S5.6`)

**Screen purpose:** The actual question-answering experience, single or batch mode.
**User goal:** "Test whether I actually understood this topic, and learn from my mistakes without feeling judged."

**Layout structure:** Full-screen, nav-free focus mode. Top: linear progress bar (question X of Y) + an exit "X" (with confirmation if mid-batch). Center: question text, options as large tappable cards. Bottom: `Submit` button, replaced by `Next` once answered. After answering: inline expansion showing correct answer, explanation, and a "Related concept" link — no red/green flash, muted `error`-role color for incorrect per Design System §7 for incorrect answers.
**Components used:** `PracticeProgressBar`, `QuestionCard`, `OptionTile` (four states: default, selected, correct, incorrect), `ExplanationPanel`, `SessionSummaryCard` (final screen).
**User interactions:** Tap an option to select; tap `Submit`; read explanation; tap `Related concept` (optional detour); tap `Next`; on the final question, tap `Finish` → Session Summary (`S5.6`); tap `Add to revision plan` on any flagged topic from the summary.
**Navigation flow:** `S5.4`/`S5.5` → (optional detour) `S3.3` Topic Detail → back to session or exit → `S5.6` → back to `S5.1`, or → `S4.1` if a revision task was added.
**Required data:** Question batch `{ id, text, options[4], correctAnswer, explanation, relatedTopicId }`; session-level running accuracy and per-question time.
**API requirements:** `GET /pyq/:exam/:subject/:topic` (batch fetch, same as browse). `POST /pyq/attempt` → `{ questionId, selectedAnswer, timeTakenSeconds, attemptId (client UUID for idempotency per Technical Architecture §13) }`. `GET /analytics/session-summary` (or computed client-side from the batch's local results — either is valid; client-side computation reduces one round-trip and is recommended for a batch already fully loaded).
**Empty states:** N/A within an active session (a session is only ever entered with a non-empty question batch — the browse screen already prevents entering an empty batch).
**Loading state:** Initial batch fetch shows a brief `AiThinkingIndicator`-style loader (`Preparing your practice set...`) before the session UI mounts; no skeleton needed mid-session since each question is already loaded in memory.
**Error state:** If `POST /pyq/attempt` fails (offline/network drop), the attempt is queued in the local outbox (per Technical Architecture §13 offline strategy) and the UI proceeds optimistically — the student is never blocked mid-practice by a transient network failure.
**Accessibility:** Options are large touch targets (≥48dp height) with clear focus order; the post-answer explanation is announced via a live region so screen-reader users aren't required to visually notice the new content; exit confirmation dialog follows Design System §18 dialog rules (specific action verb, not bare "OK/Cancel").

---

## 10. Cutoff Intelligence (`S7.1`–`S7.2`)

**Screen purpose:** Present historical exam cutoff data as reference information.
**User goal:** "Understand what score has historically been competitive, to set a realistic personal goal — without feeling compared."

**Layout structure:** Exam selector (dropdown or segmented chips) at top → a persistently visible disclaimer banner ("Historical trends are shown for reference only") directly above the chart, never buried in fine print → Year-vs-Cutoff line chart → Vacancy trend bar chart below it → optional Difficulty trend indicator.
**Components used:** `ExamSelectorChips`, `DisclaimerBanner`, `LineChart` (fl_chart), `BarChart` (fl_chart).
**User interactions:** Switch exam/year-range selector; pinch/scroll to explore chart detail (if implemented); no drill-down destination — this module is intentionally a terminal, reference-only screen.
**Navigation flow:** Entry-only from Home Quick Action or Insights nested entry; no forward navigation (per Information Architecture §3, this is a terminal screen within its module).
**Required data:** `{ year, category, cutoffMark, vacancyCount }[]` aggregated by exam.
**API requirements:** `GET /cutoff/:examId` → array of yearly cutoff records.
**Empty states:** An exam with no historical data yet (e.g. a newly added exam track) → "Historical data for this exam isn't available yet" rather than an empty chart canvas.
**Loading state:** Chart-shaped skeleton (a grey placeholder mimicking axis lines) while data loads, rather than a generic spinner, so the layout doesn't jump once real data arrives.
**Error state:** Standard full-screen error component with retry.
**Accessibility:** Charts include a `Semantics`-exposed text summary ("Cutoff for General category ranged from X to Y between 2020 and 2024") since chart data is otherwise inaccessible to screen readers; the disclaimer banner text is included in the screen's semantic reading order before the chart, not after, so it's encountered first.

---

## 11. Mock Tests (`S6.1`–`S6.5`)

**Screen purpose:** Timed, simulated exam conditions with scoring.
**User goal:** "Find out if I can perform under real conditions" — and, per the User Journey's Stage 7 analysis, this carries the highest emotional stakes of any screen in the app.

**Layout structure:** Setup (`S6.1`): three large selectable cards (Topic Test / Subject Test / Full Mock) each showing estimated duration and question count, plus a rules summary. Live Test (`S6.2`): full-screen, no bottom nav — top shows a neutral (never red) timer and "Question X of Y," center shows the question, bottom shows Previous/Next + a question-navigator grid (accessible via a expandable drawer) for jumping between questions. Submission Confirmation (`S6.3`): a calm modal dialog. Result (`S6.4`): large score display, section-wise breakdown bars — explicitly no percentile/rank anywhere on this screen. Detailed Review (`S6.5`): question-by-question list with explanations, same visual language as PYQ's `ExplanationPanel`.
**Components used:** `TestTypeCard`, `NeutralTimer`, `QuestionNavigatorGrid`, `SubmitConfirmationDialog`, `ScoreBreakdownCard`, `ReviewQuestionTile`.
**User interactions:** Select test type → `Start`; answer/navigate questions during the test; tap `Submit` → confirm in dialog; after results, tap into Detailed Review; tap a flagged weak topic → routes to Topic Detail or Planner.
**Navigation flow:** `S6.1` → `S6.2` → `S6.3` (modal) → `S6.4` → `S6.5` → `S3.3`/`S4.1` (from a weak-topic tap in review).
**Required data:** Test configuration (question count, duration, sections); the question set itself; computed score/section breakdown on submission.
**API requirements:** `GET /mock-test/config?type=topic|subject|full&examId=...`. `POST /mock-test/start` → `{ testId, questions[] }`. `POST /mock-test/:testId/submit` → `{ answers[] }` → `{ score, accuracy, sectionBreakdown[], weakTopics[] }` (server-computed, never client-computed, since this is the one flow explicitly not offline-capable per Technical Architecture §13).
**Empty states:** N/A for setup (test types are always available); N/A for results (a submitted test always produces a result).
**Loading state:** `Start` button shows embedded spinner while `POST /mock-test/start` fetches the question set; Submission Confirmation → Result transition shows a brief "Calculating your result..." state (not instant, even if the computation is fast — an abrupt score reveal can feel jarring after a high-stakes submit; a brief, deliberate pause reads as "your answers are being carefully considered").
**Error state:** If `POST /mock-test/start` fails, a full-screen error before the timer starts (never mid-test); if `submit` fails due to connectivity, the app retries automatically with the answers already captured locally, and shows "Submitting your answers..." rather than losing the completed test — this is the one write in the whole app where the offline-outbox pattern's reliability matters most.
**Accessibility:** Timer is announced periodically (not continuously, to avoid overwhelming screen-reader users) via a polite live region; the Question Navigator grid has clear per-question state (answered/unanswered/flagged) conveyed through both icon and color; the Result screen's score is the first thing announced on screen entry, with section breakdown following in reading order — never a rank or comparison figure anywhere in the semantic tree, matching the visual rule exactly.

---

## 12. Knowledge Graph (`S3.1`–`S3.4`)

**Screen purpose:** Visualize topic relationships and prerequisites; the product's core differentiator.
**User goal:** "Understand what I need to know before this topic, and what depends on it."

**Layout structure:** Subject List (`S3.1`) → Topic List (`S3.2`, hierarchical, with mastery-state icons per topic) → Topic Detail (`S3.3`, concept summary + mastery ring + prerequisite chips + "View in graph" button) → Graph View (`S3.4`, full interactive canvas — nodes sized/colored by mastery state, pinch-to-zoom, tap-to-expand-and-recenter).
**Components used:** `SubjectListTile`, `TopicListTile` (with `MasteryRing` mini-indicator), `TopicDetailHeader`, `PrerequisiteChip`, `InteractiveGraphCanvas` (custom-painted or a `GraphView`-style package wrapping `CustomPaint` + gesture detectors).
**User interactions:** Drill Subject→Topic→Detail; tap "View in graph" → full graph; within graph: pinch-zoom, pan, tap a node to recenter and open that node's Topic Detail.
**Navigation flow:** `S3.1` → `S3.2` → `S3.3` → `S3.4` (and `S3.4` node-tap → back to `S3.3` for the tapped node). Topic Detail also links out to `S5.3` (topic-filtered PYQs) and `S9.1` (topic-filtered resources).
**Required data:** `concept_nodes` and `concept_relationships` scoped to the current subject; per-topic mastery percentage (from `user_topic_progress`).
**API requirements:** `GET /exams/:id/subjects`, `GET /subjects/:id/topics` (with mastery annotations merged server-side per user), `GET /topics/:id/graph` → `{ nodes[], edges[] }` scoped to a reasonable radius around the requested topic (never the entire syllabus graph at once, for both performance and readability).
**Empty states:** A topic with no defined prerequisite relationships yet (data still being modeled) → Topic Detail simply omits the Prerequisites section rather than showing an empty "Prerequisites: none" block that might read as a data gap.
**Loading state:** Skeleton list tiles for Subject/Topic lists; the Graph View shows a brief centered loading indicator while node/edge data streams in, then animates nodes into position (a gentle settle, not an abrupt pop).
**Error state:** Standard full-screen error with retry at any level; if the Graph View specifically fails to load (a more complex request than a flat list), its error state offers a "View as list instead" fallback link, so a graph-rendering failure never fully blocks access to the underlying topic information.
**Accessibility:** The Graph View is the one screen in the app where a meaningful accessible alternative is essential — every node's information (name, mastery state, prerequisite relationships) must also be reachable through the flat Topic List/Detail screens, so a screen-reader user is never dependent on the visual graph interaction to get the same information; mastery states use icon + color together (never color alone).

---

## 13. Analytics Dashboard / Insights (`S8.1`–`S8.5`)

**Screen purpose:** Personal-only reflection on progress — never comparative.
**User goal:** "Step back weekly and see if this is working for me."

**Layout structure:** Overview (`S8.1`): PrepNode Score hero number + short explanation link, Strength Map preview (tappable into full view), headline stats row (time invested this week, topics mastered this month). Strength Map (`S8.2`): full radial/graph mastery visualization. Time Invested (`S8.3`): bar chart by subject/day. Confidence Trend (`S8.4`): line chart of self-reported confidence over weeks. Score Detail (`S8.5`): a plain-language breakdown of the five weighted components.
**Components used:** `ScoreHeroCard`, `StrengthMapPreview` / `StrengthMapFull` (radial chart), `TimeInvestedBarChart`, `ConfidenceLineChart`, `ScoreComponentBreakdownList`.
**User interactions:** Tap into any sub-detail screen from the Overview; tap a node in the Strength Map → routes to that Topic Detail; tap the Score to open its breakdown.
**Navigation flow:** `S8.1` → `S8.2`/`S8.3`/`S8.4`/`S8.5`; `S8.2` → `S3.3` (topic tap).
**Required data:** `{ prepNodeScore, scoreComponents: { topicCompletion, pyqPerformance, mockAccuracy, consistency, revisionDiscipline } }`, per-topic mastery array, time-invested logs, confidence check-in history.
**API requirements:** `GET /analytics/:userId` → the full aggregated payload above (a single call for the Overview screen; sub-detail screens may lazy-fetch more granular time ranges via `GET /analytics/:userId/time-invested?range=...` etc. if payload size warrants splitting).
**Empty states:** A brand-new account with insufficient data → Overview shows an "invitation" framing exactly like Home's empty state (§6, §26 of Design System) rather than a zeroed-out dashboard that reads as failure.
**Loading state:** Skeleton hero-number placeholder + skeleton chart shapes, matching the Cutoff module's chart-skeleton pattern (§10) for visual consistency across every chart-bearing screen in the app.
**Error state:** Standard full-screen error with retry; because this screen is read-only (no destructive or time-sensitive actions), a stale cached view (if available) may be shown with a small "last updated X ago, tap to refresh" note rather than blocking entirely — an acceptable relaxation of the standard error pattern specifically because Insights data is inherently non-urgent (per its "weekly reflection" cadence in the User Journey).
**Accessibility:** Every chart has a plain-language `Semantics` summary; the PrepNode Score's five-component breakdown is presented as a real, readable list (not just visual bar-widths) so the Explainable-AI principle holds for screen-reader users exactly as well as sighted ones.

---

## 14. Profile (`S10.1`–`S10.3`)

**Screen purpose:** Identity summary, exam goal display, personal achievements.
**User goal:** "See my identity and progress represented back to me, and get to Settings if I need to change something."

**Layout structure:** Profile Home (`S10.1`): avatar + name + exam goal summary card → Achievements preview row (horizontally scrollable) → menu list (Edit Profile, Achievements [full], Settings). Edit Profile (`S10.2`): a form mirroring the Profile Setup wizard's fields, but as a single editable screen rather than a multi-step wizard. Achievements (`S10.3`): a grid of personal milestone cards — explicitly never comparative badges (per Design System §29).
**Components used:** `ProfileHeaderCard`, `AchievementCard` (personal-only framing), `SettingsMenuTile`.
**User interactions:** Tap avatar to change photo; tap any menu tile; tap into full Achievements grid; edit and save profile fields.
**Navigation flow:** `S10.1` → `S10.2` / `S10.3` / `S10.4` (Settings).
**Required data:** `{ name, avatarUrl, examGoal, targetDate, achievements[] }`.
**API requirements:** `GET /users/:userId/profile`. `PATCH /users/:userId/profile` → updated fields. `POST /users/:userId/avatar` (multipart upload) if photo upload is supported.
**Empty states:** No achievements yet → a calm, forward-looking placeholder ("Your first milestone will appear here as you make progress") rather than an empty grid.
**Loading state:** Skeleton header card + skeleton achievement tiles while `GET /users/:userId/profile` resolves.
**Error state:** Standard full-screen error with retry on initial load; a failed profile-edit save shows an inline banner on the edit screen itself (not a silent failure that discards the user's typed changes) and preserves the entered form values for retry.
**Accessibility:** Achievement cards' text is specific and screen-reader friendly ("Explored every topic in Indian Polity, completed March 3rd") rather than relying on a visual badge icon alone to convey meaning.

---

## 15. Settings (`S10.4`–`S10.9`)

**Screen purpose:** App-level configuration: notifications, appearance, privacy, help.
**User goal:** "Adjust the app to fit my actual life and routine."

**Layout structure:** A single grouped list (Material 3 `ListTile` groups with section headers): Notifications, Appearance, Privacy & Data, About PrepNode, Help & Support, and a `Log out` action at the bottom, visually separated (not styled as a destructive-red button — a calm `OutlinedButton` with standard text color, since logging out is a neutral action, not a warning-worthy one per the ethical stance on non-guilt-based exit).
**Components used:** `SettingsSectionHeader`, `SettingsToggleTile` (notifications, appearance), `SettingsNavigationTile` (privacy/about/help, chevron-right), `LogoutButton`, `LogoutConfirmationDialog`.
**User interactions:** Toggle notification categories on/off; select theme (Light/Dark/System) via a segmented control or radio list; tap into Privacy & Data, About, or Help screens; tap `Log out` → confirm in dialog.
**Navigation flow:** `S10.4` → `S10.5`/`S10.6`/`S10.7`/`S10.8`/`S10.9` (each a simple pushed detail screen); `Log out` confirmed → clears session → `/auth/login`.
**Required data:** Current notification preferences, current theme mode, static content for About/Help.
**API requirements:** `GET /users/:userId/preferences` → `{ notifications: {...}, themeMode }`. `PATCH /users/:userId/preferences`. `POST /auth/logout` → invalidates the current refresh token server-side (per Technical Architecture §11's revocable-session design) before the client clears local storage.
**Empty states:** N/A — Settings is a static configuration surface, not a data-list screen.
**Loading state:** Toggle switches show a brief disabled/dimmed state while a preference-change request is in flight, re-enabling once confirmed (optimistic UI with rollback on failure).
**Error state:** A failed preference update reverts the toggle to its prior state and shows a small snackbar ("Couldn't update this setting"); a failed logout call still proceeds with local session clearing after a short timeout, so a network hiccup can never trap a user who wants to log out.
**Accessibility:** All toggles have clear on/off semantic state exposed (not color-only); theme selection announces the currently active option; the logout confirmation dialog uses the Design System §18 pattern (specific verb, reassurance about data persistence: "Your progress is saved and will be here when you return") which is itself an accessibility-adjacent anxiety-reduction measure as much as a visual-design one.

---

## Cross-Screen Developer Notes

- **Every screen listed above consumes theme values exclusively through `Theme.of(context).colorScheme`/`textTheme`** — no screen spec above introduces a new hardcoded color or font; this is a hard constraint carried over from the Design System and enforced in code review.
- **Every "Loading state" described above should be implemented via each feature's `AsyncNotifier`'s built-in `AsyncValue.when(data:, error:, loading:)`** (per Technical Architecture §6) rather than ad hoc boolean flags — this keeps loading/error/data handling structurally identical across all 15 screens.
- **Every API endpoint listed above should return the standard response envelope** defined in Technical Architecture §9, so the Data layer's JSON-to-Failure mapping logic is written once and reused by all 15 screens' repositories.
- **Offline-outbox eligibility**, per Technical Architecture §13, applies to: PYQ attempt submission, task Complete/Skip, and preference updates. It explicitly does **not** apply to Mock Test start/submit (server-authoritative, network-required by design) or Registration/Login (identity operations should never appear to succeed locally before server confirmation).

This document, combined with the Design System, Information Architecture, User Journey, and Technical Architecture documents already produced, is the complete pre-build package for PrepNode: ready for a development team to begin implementation screen by screen.
