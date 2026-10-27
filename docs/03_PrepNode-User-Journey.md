# PrepNode — Complete User Journey Map v1.0
### From First Launch to Active Learner
**Research lens:** Jobs-to-be-done + emotional-arc mapping, cross-referenced to screens defined in the Information Architecture (v1.0) and voice/motion rules in the Design System (v1.0).

---

## 0. Methodology & Persona

Each stage below documents: **User Goal → Actions/Interactions → System Response → Screens Touched → Emotional State → UX Risk → Mitigation (per PrepNode ethics)**.

**Primary research persona:**
> **Dharani, 24** — preparing for TNPSC Group 2 alongside a part-time job. Has tried 2 other exam apps before, both abandoned within 3 weeks. Anxious about "wasting time on the wrong topics." Studies mostly at night, sometimes on a bus during commute. Has failed once before and is wary of anything that feels like it's "keeping score" on her.

Dharani is the lens for every emotional-state annotation below — she represents the exact user PrepNode's ethical-AI principles were written to protect.

---

## 1. STAGE 0 — Discovery & First Launch

**User goal:** "Is this worth my time? Is this different from the last app I deleted?"

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Downloads app from Play Store (via search "TNPSC preparation app" or word-of-mouth) | App installs; icon uses knowledge-graph mark (calm, non-generic) | Play Store listing | Neutral, mildly skeptical | Risk: store screenshots look like every other "gamified" exam app → Mitigation: screenshots emphasize calm UI, "Prepare with Purpose" tagline, no leaderboard/badge imagery in marketing assets |
| 2 | Opens app for first time | Splash screen renders (logo fade + scale, 2s), session check runs in background | S0.1 Splash | Curious, low investment | Cold start must be <2s or perceived reliability drops before first impression forms |
| 3 | Splash resolves — no session found | Auto-routes to Onboarding Carousel | S0.1 → S0.2 | Waiting, low friction expected | — |

**Moment that matters:** the first 2 seconds decide whether Dharani gives the app a real chance or bounces back to the Play Store — this is why splash has zero network dependency and pure local logic.

---

## 2. STAGE 1 — Onboarding (Value Communication, Pre-Commitment)

**User goal:** "Show me you understand my problem before you ask anything of me."

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Swipes through Page 1: "Welcome to PrepNode" | Illustration + value statement, page indicator appears | S0.2 (p1) | Cautiously interested | — |
| 2 | Swipes Page 2: "Understand Your Preparation" | Explains tracking/strengths framing | S0.2 (p2) | Slightly more trusting — this differs from prior apps' "study harder" messaging | Risk: sounds like generic "track your progress" copy → Mitigation: language is specific ("identify strengths," not "beat your rank") |
| 3 | Swipes Page 3: "Practice with Purpose" | PYQ/mock/insight framing | S0.2 (p3) | Building confidence in feature depth | — |
| 4 | Swipes Page 4: "Prepare with Confidence" | Closing emotional note, no pressure language | S0.2 (p4) | Emotionally primed, low anxiety | — |
| 5 | Taps "Skip" (impatient users) OR finishes carousel | Either path lands at same destination | → S0.3 | Either "let's get to it" or "I'm convinced" | Skip must always be available — forcing the full carousel on an impatient user (like Dharani, mid-commute) creates first-run resentment |

**Moment that matters:** Dharani has been burned by apps that front-load "motivational hype." Onboarding intentionally under-promises and lets the product itself over-deliver later.

---

## 3. STAGE 2 — Registration (Identity Commitment)

**User goal:** "I've decided to try this — don't make it hard, and don't make me feel judged yet."

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Taps "Register" (or "Continue with Google" for lower-friction path) | Form renders: name, email, password, confirm password | S0.4 | Slight friction tolerance — this is the "cost" of entry | Risk: long forms cause drop-off → Mitigation: Google Sign-In offered as equal-weight primary option, not buried |
| 2 | Fills form, taps "Create Account" | Client validation (password match, email format) inline, no full-page reload errors | S0.4 | Mild tension (typical for any signup) | Field-level errors per Design System §28 — calm, specific, no red alarm styling |
| 3 | Submits | Remote: `/auth/register`; on success, session token stored | S0.4 → S1.1 | Relief + anticipation | — |
| 4 | (Edge case) Email already registered | Inline error: "This email is already registered. Log in instead?" — actionable, not blaming | S0.4 | Mild annoyance, quickly resolved | Error copy offers the fix, not just the problem (per §28 rules) |

**Moment that matters:** registration is the first place PrepNode could feel like "just another form" — keeping it under 30 seconds (Google Sign-In path) directly protects retention for time-pressed users like Dharani.

---

## 4. STAGE 3 — Exam Selection & Profile Setup (Personalization Contract)

**User goal:** "Now prove you're actually going to personalize this for *me*, not give me a generic syllabus dump."

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Selects exam: TNPSC Group 2 | List renders from `/exams`; selection highlighted, not "locked in" yet (can change later in Settings) | S1.1 | Focused, decision-making mode | Reassurance microcopy: "You can change this anytime" reduces decision anxiety |
| 2 | Sets target exam date via date picker | Calendar UI, no penalty framing for "short" timelines | S1.2 | Slight anxiety if date is close — must NOT be amplified by UI (no red countdown here) | Copy: "We'll help you make the most of the time you have," regardless of how little time is selected |
| 3 | Sets daily study hours (slider: 1–8+ hrs) | Slider updates live preview text ("~3 hrs/day — a solid, sustainable pace") | S1.3 | Reflective — Dharani sets realistic 2hrs given her job | Never labels low hours as "insufficient" — validates whatever is chosen |
| 4 | Selects preparation level: Beginner | Single-select cards, equal visual weight (no "you're behind" styling on Beginner) | S1.4 | Slightly vulnerable moment — admitting she's a beginner | Critical ethical checkpoint: copy explicitly reframes this as "helps us personalize, not a judgment of ability" |
| 5 | Taps "Finish Setup" | Remote: profile saved; triggers `/planner/generate` (first plan computed) | S1.5 | Anticipation — "what will it recommend?" | Loading state uses AI "thinking" pattern (§27) with reassuring copy: "Personalizing your first plan..." |
| 6 | Setup Complete screen shown | Brief, warm confirmation; auto-advances or single tap to continue | S1.5 → S2.1 | Hopeful, engaged | This is the pivotal trust moment — first plan must feel *specific* to her inputs, not generic |

**Moment that matters:** if the very first generated plan feels generic ("Study Chapter 1"), Dharani's trust collapses immediately. The plan must visibly reference her stated exam, hours, and level in its first reasoning line.

---

## 5. STAGE 4 — First Dashboard Experience (First Impression of Daily Value)

**User goal:** "Was setting all that up worth it? What do I actually get?"

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Lands on Home Dashboard for the first time | Greeting ("Good evening, Dharani"), Today's Purpose card, Today's Plan preview (1–2 tasks, generated from her inputs), empty Progress card (0%, framed as a start, not a deficit) | S2.1 | Evaluating — this is the make-or-break screen | Empty progress state uses §26 "invitation" framing, never "0% — you have a long way to go" |
| 2 | Taps first recommended task | Task detail opens with visible reasoning ("Recommended because Indian Polity is frequently tested and matches your Beginner starting point") | S2.1 → S4.3 | Reassured — sees the "why," builds trust in the AI | This is the Explainable AI principle in its first live use — must not be skipped even in v1 |
| 3 | Explores Quick Actions row (PYQ, Mock Test, Cutoff, Graph) | Cards navigate to respective module homes | S2.1 → S5.1 / S6.1 / S7.1 / S3.1 | Curious exploration, low commitment | First-run users often "window shop" all tabs before committing to one — this is expected and healthy |
| 4 | Returns to Home via bottom nav | Dashboard state persists/refreshes | S2.1 | Comfortable, orienting complete | — |

**Moment that matters:** this session establishes the *mental model* — "this app tells me what to do and why, without pressuring me." Everything after this either confirms or breaks that model.

---

## 6. STAGE 5 — Daily Study Loop (Habit Formation Begins)

**User goal:** "Make this a 10-minute part of my routine, not a chore."

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Receives gentle reminder notification (e.g., evening, matching her stated study-hours preference) | Notification copy: "Ready for today's Polity session? About 25 minutes." — time-boxed, low-pressure | Push → S11.1 or deep-link | Low-friction re-entry cue | Never sent as "You haven't studied today!" — always framed forward, never guilt-based (per Tone of Voice §30) |
| 2 | Taps notification → opens directly to Today's Plan | Deep link bypasses Home, goes straight to task | S4.1 or S4.3 | Efficient — respects her limited time | Reduces steps-to-value for repeat users; first-run users get the full Home tour, repeat users get shortcuts |
| 3 | Taps "Start" on a Topic task | Routes into Topic Detail, or directly into a short concept read | S4.3 → S3.3 | Engaged, learning mode | — |
| 4 | Finishes reading, marks task complete | Task card animates to "done" state (sage checkmark, quiet motion per §22) — no fanfare | S4.3 | Small, quiet satisfaction | Deliberately restrained — big celebratory motion for routine tasks would feel patronizing over time |
| 5 | Sees streak/consistency indicator update on Home | Calendar-heatmap dot fills in, no numeric "streak count" pressure | S2.1 | Mild positive reinforcement | Per §15 — heatmap framing avoids the anxiety of "don't break the chain" streak mechanics |
| 6 | Closes app | Session state saved; no exit-intent guilt prompt ("Are you sure you want to leave?") | — | Neutral — respects her autonomy to leave | Ethical stance: PrepNode never uses exit-friction dark patterns |

**Moment that matters:** the daily loop must feel *shorter and calmer* than her old app's loop. This is the retention hinge — habit forms here or the app quietly stops being opened within 2 weeks (the exact failure mode of her previous two apps).

---

## 7. STAGE 6 — PYQ Practice (Skill Application)

**User goal:** "Let me actually test whether I understood that topic."

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Navigates to Practice tab, or arrives via "Practice this topic" link from Topic Detail | Practice Home shows recent/continue options | S5.1 | Motivated, slightly nervous (testing = vulnerability) | — |
| 2 | Browses Exam → Subject → Topic → sees PYQ count/heatmap | Topic PYQ List renders with solved/bookmark states | S5.2 → S5.3 | Focused | Heatmap shows *frequency*, never "difficulty ranking against other students" |
| 3 | Starts a batch Practice Session | Full-screen focus mode, no bottom nav | S5.5 | Concentrated, in "flow" | Removing nav here is deliberate — matches Design System's focus-mode principle |
| 4 | Answers each question, sees immediate correct/incorrect + explanation | Explanation + related-concept link shown inline, not just a red/green flash | S5.5 | Mix of small wins and small misses — must stay emotionally neutral | Incorrect answers use `error` (muted terracotta), never red flash or negative sound effect |
| 5 | Finishes session → Session Summary | Accuracy, time, and 1–2 topics to revisit shown; framed as "areas to revisit," never "areas you failed" | S5.6 | Reflective, slightly vulnerable but supported | Critical wording checkpoint — this screen is an easy place for judgmental language to creep in during dev; must be reviewed against §30 tone bank |
| 6 | Taps "Add to revision plan" for a flagged topic | Task auto-inserted into Planner | S5.6 → S4.1 | Proactive, in control | Closes the loop between practice and planning — reinforces the "system explains and adapts" trust model |

---

## 8. STAGE 7 — Mock Tests (Simulated Real Stakes)

**User goal:** "I need to know if I can perform under real exam conditions — but I'm scared of a bad number."

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Opens Mock Test via segmented control on Practice tab | Setup screen: Topic / Subject / Full Mock, with rules and estimated duration | S6.1 | Building resolve — this is a bigger emotional commitment than PYQ practice | — |
| 2 | Starts test | Full-screen timed flow, progress indicator (question X of Y), no bottom nav | S6.2 | Concentration, adrenaline | Timer uses neutral ink/graphite styling, not a red countdown that spikes anxiety |
| 3 | Reaches final question, taps Submit | Confirmation dialog appears (irreversible action) | S6.3 | Slight hesitation — normal pre-submission nerves | Calm confirmation copy: "Ready to submit? You can review your answers first." — offers an out, doesn't rush |
| 4 | Confirms submission | Result computed | S6.4 | Anxious anticipation (this is the highest-stakes emotional peak in the entire journey) | This is the single most important screen in the whole app to get right ethically |
| 5 | Views Result & Score Breakdown | Score, accuracy, section breakdown — explicitly **no percentile, no rank, no "others scored higher"** | S6.4 | Relief or disappointment, but *not* shame — because there is nothing to compare against | This is the direct, concrete expression of "Support over comparison" as an actual screen, not just a value statement |
| 6 | Opens Detailed Review | Question-by-question explanations | S6.5 | Learning-oriented, curiosity replacing anxiety | Even a low score routes to constructive next steps, never a static "you failed" state |
| 7 | Taps into a weak topic from review | Routes to Topic Detail, and optionally into Planner | S6.5 → S3.3 → S4.1 | Determined — bad result converted into a concrete next action | This is the emotional recovery step that prevents mock-test anxiety from becoming app abandonment |

**Moment that matters:** a poor mock score is the single highest-risk moment for a competitive-exam app to lose a user permanently (shame → avoidance → uninstall). PrepNode's entire ethical-AI framework exists largely *for this exact moment*.

---

## 9. STAGE 8 — Revision (Long-Term Retention Behavior)

**User goal:** "Don't let me forget what I already learned."

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Spaced-repetition engine auto-inserts a revision task (Day 3 after first learning a topic) | Task appears in Today's Plan labeled "Revision" | S4.1 | Mild surprise ("oh, it remembered") — a positive trust signal | System proactively manages this — Dharani never has to track it manually |
| 2 | Opens revision task | Shows condensed concept summary + 3–5 quick PYQs, not a full re-read | S4.3 → S3.3 (condensed) | Efficient, low-effort re-engagement | Revision tasks are intentionally shorter than first-learning tasks — respects her limited time |
| 3 | Marks revision complete | Interval extends (Day 3 → Day 7 → Day 15), per spaced-repetition logic | S4.3 | Quiet confidence building | Revision Scheduler formula (Part 3 doc) runs invisibly — user never sees "algorithm," only sensible timing |
| 4 | Misses a scheduled revision day (life happens — night shift, exam-day-adjacent fatigue) | No penalty; task simply reappears next day, interval unaffected or gently adjusted | S4.1 | Relief — no guilt trigger | Directly enacts "the app should never judge" — missed revision ≠ failure state anywhere in the UI |

---

## 10. STAGE 9 — Analytics / Insights Engagement (Reflection Ritual)

**User goal:** "Step back and see if this is actually working — for me, not against anyone else."

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Opens Insights tab (typically weekly, not daily) | Overview: PrepNode Score, Strength Map preview, headline stats | S8.1 | Reflective, evaluative | Weekly-cadence design assumption — Insights doesn't need daily-engagement hooks, unlike Home |
| 2 | Taps into Strength Map | Radial visualization: sage (strong) / marigold (building) / outline (not started) per topic | S8.2 | Orienting — "where do I actually stand" | Colors never map to pass/fail semantics — mastery is a spectrum, not binary |
| 3 | Taps into Confidence Trend | Line chart of self-reported confidence over weeks | S8.4 | Validating — sees her own growth line, not anyone else's | Entirely self-referential data only |
| 4 | Opens PrepNode Score Detail | Plain-language formula breakdown (Topic Completion, PYQ Performance, Mock Accuracy, Consistency, Revision Discipline) | S8.5 | Reassured by transparency — "it's not a mysterious number" | Directly implements the Explainable AI principle at the composite-score level |
| 5 | Views Cutoff Intelligence (nested entry) | Historical trend chart with disclaimer | S7.1 → S7.2 | Contextualizing, calm curiosity | Disclaimer text always visible above the chart, not buried in fine print |

---

## 11. STAGE 10 — Profile & Settings Management

**User goal:** "Let me adjust this app to fit my actual life, not the other way around."

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Opens Profile tab | Sees identity, exam goal, achievements | S10.1 | Neutral, administrative | — |
| 2 | Views Achievements | Personal milestones only (e.g., "Explored every topic in Polity") — never comparative badges | S10.3 | Quiet pride | Reinforces §29 Success States rules at the profile level |
| 3 | Adjusts daily study hours (job schedule changed) | Re-enters profile fields, saves | S10.2 | Practical, in control | Editing past commitments never shows a "you're changing your goal down" warning tone |
| 4 | Opens Notification Preferences, reduces reminder frequency | Toggle list, immediate effect | S10.5 | Autonomy-affirming | PrepNode never resists a user reducing engagement — no "are you sure? you'll miss out!" dark pattern |
| 5 | Switches to Dark Mode for late-night study | Theme applies instantly app-wide | S10.6 | Comfort-seeking, practical | Directly serves the persona's stated night-study habit |
| 6 | Visits "About PrepNode" out of curiosity | Reads philosophy/ethical-AI statement | S10.8 | Builds deeper trust/brand affinity | This screen quietly converts curious users into advocates — worth investing real content here |

---

## 12. STAGE 11 — Logout & Re-engagement

**User goal:** "I want to step away (device change, privacy, or just a break) without the app making that hard or personal."

| Step | Interaction | System Response | Screen | Emotional State | Risk / Mitigation |
|---|---|---|---|---|---|
| 1 | Navigates Settings → Logout | Simple confirmation dialog: "Log out of PrepNode?" — factual, no guilt copy ("Your progress is saved and will be here when you return") | S10.4 (modal) | Neutral to slightly reassured | Confirmation copy explicitly reassures data persistence — reduces anxiety about "losing everything" |
| 2 | Confirms | Session token cleared; routes to Login | S10.4 → S0.3 | Closure | — |
| 3 | (Weeks later) Reopens app after inactivity | Splash → session invalid → Login, NOT full onboarding again (recognizes returning user by stored email/device) | S0.1 → S0.3 | Slight friction expected, minimized | Re-onboarding a lapsed user from scratch is a major churn risk — Login screen can offer "Welcome back" personalization if email is cached |
| 4 | Logs back in | Dashboard restores exactly where progress left off, with a gentle re-orientation nudge rather than judgment | S0.3 → S2.1 | Relief — "nothing was lost, no one shamed me for being away" | Re-entry copy: "Good to see you again. Here's where you left off" — never "You've been away for 23 days" |

---

## 13. STAGE 12 — Becoming an "Active Learner" (Habit Consolidation)

**User goal (now implicit, not stated):** "This is just part of how I study now."

By this stage, Dharani's behavior pattern has stabilized into a recognizable loop:

```
   TRIGGER                ACTION                  SYSTEM RESPONSE            REINFORCEMENT
(evening reminder    →  opens Today's Plan   →   presents 1–3 explained  →  quiet completion
 or internal habit)                               tasks + revision                animation,
                                                                                heatmap fills,
                                                                              no numeric pressure
        ↓                                                                          ↓
   Weekly reflection   →   opens Insights     →   shows self-referential   →  reinforces sense
   (Sunday evening)                                progress only                of "it's working"
```

**Behavioral markers of an "Active Learner" state** (for product analytics to track, without ever surfacing them as user-facing pressure):
- Opens Today's Plan ≥4 days/week
- Completes ≥1 revision task/week (indicates trust in spaced repetition, not just first-pass learning)
- Voluntarily attempts ≥1 Mock Test every 2–3 weeks (indicates reduced test anxiety over time)
- Visits Insights weekly (indicates reflective, not just reactive, engagement)
- Adjusts Settings at least once (indicates the app is being *fitted* to her life, a strong retention signal)

**The emotional arc, end to end:**

```
Skeptical → Cautiously hopeful → Trusting (first personalized plan) → Comfortable (daily loop)
   → Vulnerable (first practice miss) → Reassured (non-judgmental feedback) → Anxious (first mock test)
   → Relieved (no comparison, constructive review) → Confident (visible personal growth in Insights)
   → Habitual (active learner) → Advocate (tells a friend, referencing the calm/no-pressure difference
     from every other exam app she's tried)
```

This arc — specifically the **vulnerable → reassured** and **anxious → relieved** transitions around Practice misses and Mock Test scores — is where PrepNode's ethical-AI design either earns lifetime trust or loses the user permanently. Every screen in Stages 6–8 should be built and QA'd against this journey map before any other part of the app.

---

## 14. Cross-Reference: Journey Stage → IA Screens

| Journey Stage | Primary Screens (from IA v1.0) |
|---|---|
| First Launch | S0.1 |
| Onboarding | S0.2 |
| Registration | S0.3, S0.4, S0.5 |
| Exam Selection & Setup | S1.1–S1.5 |
| Dashboard (first + ongoing) | S2.1, S2.2 |
| Daily Study | S4.1, S4.3, S4.4, S3.3 |
| PYQs | S5.1–S5.6 |
| Mock Tests | S6.1–S6.5 |
| Revision | S4.1, S4.3 (spaced-repetition variant) |
| Analytics | S8.1–S8.5, S7.1–S7.2 |
| Profile | S10.1–S10.3 |
| Settings | S10.4–S10.9 |
| Logout | S10.4 (modal), S0.3 |

This journey map should be treated as a living QA checklist: any new feature or copy change should be evaluated against the emotional-state column for the stage it lands in, not just its functional correctness.
