# PrepGraph — Information Architecture & Navigation Blueprint v1.0
### "Prepare with Purpose"

This document defines every screen required for a production-grade release, grouped into modules, with navigation hierarchy, purpose, required data, and destination mapping. No UI is designed here — this is the structural skeleton the design system (v1.0) will be applied to.

---

## 1. Navigation Model Overview

PrepGraph uses a **hybrid navigation model**:

- **Bottom Navigation Bar (persistent, 5 tabs)** for top-level modules — always visible except during focused sessions (Mock Test, Practice Session, Onboarding).
- **Push navigation (stack)** for drill-down within a module (e.g., Home → Topic → Question).
- **Modal bottom sheets** for contextual, non-destination actions (filters, "why this recommendation," quick edit).
- **Full-screen modals (no bottom nav)** for focused, distraction-free tasks: Mock Test session, Active Practice session, Onboarding, Auth.

```
                        ┌─────────────────────────┐
                        │      APP ENTRY POINT      │
                        └────────────┬─────────────┘
                                     │
                 ┌───────────────────┴───────────────────┐
                 │                                         │
          First-time user                            Returning user
                 │                                         │
                 ▼                                         ▼
        0. ONBOARDING & AUTH                      Session valid? ──No──▶ 0. AUTH
                 │                                         │
                 ▼                                         │ Yes
        1. PROFILE SETUP (exam, goal)                      │
                 │                                         │
                 └───────────────────┬─────────────────────┘
                                     ▼
                     ┌───────────────────────────────┐
                     │   PERSISTENT BOTTOM NAVIGATION  │
                     │  Home · Learn · Practice ·      │
                     │  Insights · Profile             │
                     └───────────────────────────────┘
```

---

## 2. Module Map

| # | Module | Core Job | Contains |
|---|---|---|---|
| M0 | **Onboarding & Auth** | First-run intro + identity | Splash, Onboarding carousel, Login, Register, Forgot Password |
| M1 | **Profile Setup** | Capture goals to personalize everything downstream | Exam selection, target date, study hours, level |
| M2 | **Home** | Daily anchor screen — "what should I do right now" | Dashboard, Notifications, Today's Plan preview |
| M3 | **Learn (Knowledge Graph)** | Conceptual map of the syllabus | Subject list, Graph view, Topic detail, Prerequisite view |
| M4 | **Planner** | Personalized scheduling engine | Today's Plan, Weekly Plan, Task detail, Reschedule |
| M5 | **Practice (PYQ Center)** | Previous-year question practice | Exam/Subject/Topic browser, Question session, Result & Explanation |
| M6 | **Mock Test** | Timed simulated exams | Test setup, Live test, Submission, Result & Review |
| M7 | **Cutoff Intelligence** | Historical exam data as reference | Exam selector, Trend charts, Vacancy view |
| M8 | **Insights (Analytics)** | Personal progress visualization | Strength Map, Time Invested, Confidence Trend, Score |
| M9 | **Resources** | Curated learning material | Resource list, Resource detail/player |
| M10 | **Profile & Settings** | Identity, preferences, app config | Profile, Achievements, Settings, About, Help |
| M11 | **Notifications** | Non-intrusive nudges | Notification Center |
| M12 | **AI Assistant (Doubt Solver)** | Conversational concept help (Gemini-backed) | Chat interface, Saved explanations |

---

## 3. Full Screen Inventory

### MODULE 0 — Onboarding & Auth
*No bottom navigation visible. Linear, escapable only via Skip/Login.*

| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S0.1 Splash** | Brand introduction, session check while app initializes | Local: cached session token | → S0.3 (new user) or → M2 Home (valid session) |
| **S0.2 Onboarding Carousel** (4 pages) | Explain value prop before asking for commitment (account creation) | Static content only | → S0.3 Login/Register choice |
| **S0.3 Login** | Authenticate returning user | Input: email/password; Remote: auth API | → M2 Home (success) · → S0.5 Forgot Password · → S0.4 Register |
| **S0.4 Register** | Create new account | Input: name, email, password; Remote: auth API | → M1.1 Profile Setup (on success) |
| **S0.5 Forgot Password** | Account recovery | Input: email; Remote: reset-link API | → S0.3 Login (after reset confirmation) |

### MODULE 1 — Profile Setup
*Linear wizard, shown once post-registration. Editable later from M10.*

| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S1.1 Exam Selection** | Choose target exam (TNPSC G1/G2/G4, extensible) | Remote: `/exams` list | → S1.2 |
| **S1.2 Goal & Timeline** | Set target exam date | Input: date picker | → S1.3 |
| **S1.3 Study Availability** | Daily study hours, preferred time-of-day | Input: hours slider, time-of-day chips | → S1.4 |
| **S1.4 Preparation Level** | Self-declared starting point (Beginner/Intermediate/Advanced) — framed as personalization input, never shown again as a label | Input: single select | → S1.5 |
| **S1.5 Setup Complete** | Confirms plan is being generated, builds anticipation | Remote: triggers `/planner/generate` (first run) | → M2 Home |

### MODULE 2 — Home (Bottom Nav Tab 1)
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S2.1 Home Dashboard** | Daily anchor: greeting, today's purpose, progress snapshot, today's plan preview, quick actions | Remote: `/planner/:userid` (today), `/analytics/:userid` (progress summary), user streak/heatmap data | → M4.1 Today's Plan (full) · → M3 Learn · → M5 Practice · → M6 Mock Test · → M7 Cutoff · → M11 Notifications (bell icon) · → M10.1 Profile (avatar) |
| **S2.2 Search** (global) | Cross-module search: topics, subjects, resources | Input: query; Remote: search index | → M3.3 Topic Detail · → M9.2 Resource Detail |

### MODULE 3 — Learn / Knowledge Graph (Bottom Nav Tab 2)
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S3.1 Subject List** | Entry point to syllabus, organized by subject | Remote: `/exams/:id/subjects` | → S3.2 Topic List |
| **S3.2 Topic List** | Hierarchical syllabus browser within a subject | Remote: `subjects/:id/topics` (with mastery status per topic) | → S3.3 Topic Detail |
| **S3.3 Topic Detail** | Concept summary, mastery state, related PYQs, resources, prerequisite links | Remote: topic metadata, `concept_relationships` | → S3.4 Graph View (visualize) · → M5.3 Practice (topic-filtered) · → M9.1 Resource List (topic-filtered) · → M12.1 AI Assistant (ask about this topic) |
| **S3.4 Graph View (Interactive)** | Full visual knowledge graph — nodes/edges, tap-to-expand, prerequisite pathing | Remote: `concept_nodes`, `concept_relationships` for subject/topic scope | → S3.3 Topic Detail (on node tap) |

### MODULE 4 — Planner (accessed from Home; also a Bottom Nav alternative depending on IA decision — see §5)
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S4.1 Today's Plan** | Full daily task list with reasoning | Remote: `/planner/:userid` (today, with `reason` field per task) | → S4.3 Task Detail · → S4.2 Weekly View |
| **S4.2 Weekly Plan View** | Calendar-style forward view of upcoming tasks/revisions | Remote: `/planner/:userid?range=week` | → S4.1 (tap a day) |
| **S4.3 Task Detail** | Single task: what, why, how long, actions | Remote: task detail incl. `reason`, linked topic_id | → M3.3 Topic Detail (start) · → M5.3 Practice Session (if PYQ task) · Action: Complete / Skip / Reschedule (stays on screen, updates state) |
| **S4.4 Reschedule Sheet** (modal) | Move a task without guilt-framed copy | Input: new date/time | Closes back to S4.1/S4.3 |

### MODULE 5 — Practice / PYQ Center (Bottom Nav Tab 3, shared entry with Mock Test via segmented control or sub-tabs)
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S5.1 Practice Home** | Entry point: browse by exam/subject/topic, or "Continue where you left off" | Remote: `/exams`, recent-session cache | → S5.2 Subject/Topic Browser · → S5.5 Practice Session (continue) |
| **S5.2 Subject/Topic Browser** | Drill into exam → subject → topic → year, shows PYQ counts and repetition heatmap | Remote: `/pyq/:exam/:subject/:topic` (metadata only, counts) | → S5.3 Topic PYQ List |
| **S5.3 Topic PYQ List** | List of individual questions for a topic, with solved/bookmarked status | Remote: `/pyq/:exam/:subject/:topic` (question list) | → S5.4 Question Detail (single) · → S5.5 Practice Session (batch/all) |
| **S5.4 Question Detail (single view)** | One question, answer, explanation, related concept link | Remote: question object; Write: `/pyq/attempt` on submit | → S3.3 Topic Detail (related concept) · Back to S5.3 |
| **S5.5 Practice Session (batch, full-screen focus mode)** | Sequential question-answering flow, no bottom nav (reduces distraction) | Remote: question batch; Write: attempts stream to `/pyq/attempt` | → S5.6 Session Summary |
| **S5.6 Session Summary** | Post-session recap: accuracy, time, topics to revisit — framed supportively | Local: session results | → S5.1 Practice Home · → S4.1 Today's Plan (if revision suggested) |

### MODULE 6 — Mock Test (accessed via Practice Home segmented control, or Home quick action)
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S6.1 Mock Test Setup** | Choose Topic Test / Subject Test / Full Mock, view rules | Remote: available test configs | → S6.2 (start) |
| **S6.2 Live Test (full-screen, timer, no bottom nav)** | Timed question flow with progress indicator | Remote: test question set; Local: timer state, answer draft | → S6.3 on submit/time-up |
| **S6.3 Submission Confirmation** (modal) | Confirms before final submit (irreversible action, calm confirmation dialog) | — | → S6.4 Result |
| **S6.4 Result & Score Breakdown** | Score, accuracy, section-wise breakdown — no rank/percentile | Remote: computed result; Write: stored to `user_topic_progress` | → S6.5 Detailed Review · → M8.1 Insights |
| **S6.5 Detailed Review** | Question-by-question review with explanations | Remote: full attempt log with correct answers | → S3.3 Topic Detail (weak topic) |

### MODULE 7 — Cutoff Intelligence (accessed from Home quick action; nested under Insights or standalone — see §5)
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S7.1 Exam Selector** | Choose exam/year scope for trend data | Remote: `/exams`, `/cutoff/:exam` | → S7.2 Trend View |
| **S7.2 Trend View** | Year-vs-cutoff chart, vacancy trend, difficulty trend, with reference-only disclaimer | Remote: `cutoff_data` aggregated by year/category | — (terminal screen within module; no drill-down needed) |

### MODULE 8 — Insights / Analytics (Bottom Nav Tab 4)
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S8.1 Insights Overview** | PrepGraph Score, strength map, headline personal stats | Remote: `/analytics/:userid` (aggregated) | → S8.2 Strength Map (full) · → S8.3 Time Invested · → S8.4 Confidence Trend · → S8.5 Score Detail |
| **S8.2 Strength Map (full view)** | Radial/graph visualization of mastery across all subjects | Remote: `user_topic_progress` per topic | → S3.3 Topic Detail (tap a node) |
| **S8.3 Time Invested Detail** | Study time breakdown by subject/day/week | Remote: session logs aggregated | — |
| **S8.4 Confidence Trend Detail** | Self-reported confidence over time, per topic | Remote: confidence check-in history | → S3.3 Topic Detail |
| **S8.5 PrepGraph Score Detail** | Explains the composite score formula in plain language (transparency) | Remote: score components breakdown | — |

### MODULE 9 — Resources
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S9.1 Resource List** | Curated books/videos/notes, filterable by topic/type | Remote: `/resources` filtered by topic_id | → S9.2 Resource Detail |
| **S9.2 Resource Detail / Player** | View/play/read a resource, rate usefulness | Remote: resource content or embed link | Back to S9.1 or originating Topic Detail |

### MODULE 10 — Profile & Settings (Bottom Nav Tab 5)
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S10.1 Profile Home** | Identity summary, exam goal, achievements, entry to settings | Remote: user profile, achievement list | → S10.2 Edit Profile · → S10.3 Achievements · → S10.4 Settings |
| **S10.2 Edit Profile** | Update name, photo, exam/date/hours (re-enters M1 fields) | Input: profile fields; Remote: update user API | Back to S10.1 |
| **S10.3 Achievements** | Personal milestones (never comparative badges) | Remote: milestone log | Back to S10.1 |
| **S10.4 Settings** | App-level configuration | — | → S10.5 Notification Preferences · → S10.6 Appearance (theme) · → S10.7 Privacy & Data · → S10.8 About PrepGraph · → S10.9 Help & Support |
| **S10.5 Notification Preferences** | Control reminder frequency/type | Input: toggle list | Back to S10.4 |
| **S10.6 Appearance** | Light/Dark/System theme toggle | Input: selection | Back to S10.4 |
| **S10.7 Privacy & Data** | Data usage explanation, account deletion, export | Remote: account data export API | Back to S10.4 |
| **S10.8 About PrepGraph** | Version, philosophy statement, ethical AI principles (surfaces brand values in-product) | Static content | Back to S10.4 |
| **S10.9 Help & Support** | FAQ, contact, feedback form | Static + Input: feedback form | Back to S10.4 |

### MODULE 11 — Notifications
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S11.1 Notification Center** | Chronological list: plan reminders, milestone acknowledgments, resource suggestions — never "you're falling behind" alerts | Remote: notification feed | → deep-links into S4.3 Task Detail / S3.3 Topic Detail / S10.3 Achievements depending on notification type |

### MODULE 12 — AI Assistant / Doubt Solver
| Screen | Purpose | Data Needed | Navigates To |
|---|---|---|---|
| **S12.1 Assistant Chat** | Conversational doubt-solving (Gemini-backed), concept explanations, note generation | Input: chat text; Remote: Gemini API with topic context | → S12.2 Saved Explanations (save current answer) |
| **S12.2 Saved Explanations** | Bookmarked AI explanations for revision | Local/Remote: saved notes list | Back to S12.1 · → S3.3 Topic Detail |

---

## 4. Navigation Hierarchy (Full Tree)

```
App Root
│
├── M0 Onboarding & Auth (pre-login stack, no bottom nav)
│   ├── S0.1 Splash
│   ├── S0.2 Onboarding Carousel
│   ├── S0.3 Login
│   │   └── S0.5 Forgot Password
│   └── S0.4 Register
│
├── M1 Profile Setup (post-register wizard, no bottom nav)
│   ├── S1.1 Exam Selection
│   ├── S1.2 Goal & Timeline
│   ├── S1.3 Study Availability
│   ├── S1.4 Preparation Level
│   └── S1.5 Setup Complete
│
└── Main App Shell (Bottom Nav visible)
    │
    ├── TAB 1 — HOME (M2)
    │   ├── S2.1 Home Dashboard
    │   └── S2.2 Global Search
    │
    ├── TAB 2 — LEARN (M3)
    │   ├── S3.1 Subject List
    │   │   └── S3.2 Topic List
    │   │       └── S3.3 Topic Detail
    │   │           └── S3.4 Graph View
    │
    ├── TAB 3 — PRACTICE (M5 + M6 nested via segmented control)
    │   ├── S5.1 Practice Home
    │   │   └── S5.2 Subject/Topic Browser
    │   │       └── S5.3 Topic PYQ List
    │   │           ├── S5.4 Question Detail
    │   │           └── S5.5 Practice Session (full-screen)
    │   │               └── S5.6 Session Summary
    │   └── S6.1 Mock Test Setup
    │       └── S6.2 Live Test (full-screen)
    │           └── S6.3 Submission Confirmation (modal)
    │               └── S6.4 Result
    │                   └── S6.5 Detailed Review
    │
    ├── TAB 4 — INSIGHTS (M8, with M7 Cutoff nested as a card/entry point)
    │   ├── S8.1 Insights Overview
    │   │   ├── S8.2 Strength Map
    │   │   ├── S8.3 Time Invested
    │   │   ├── S8.4 Confidence Trend
    │   │   └── S8.5 Score Detail
    │   └── S7.1 Cutoff Exam Selector → S7.2 Trend View
    │
    └── TAB 5 — PROFILE (M10)
        ├── S10.1 Profile Home
        │   ├── S10.2 Edit Profile
        │   ├── S10.3 Achievements
        │   └── S10.4 Settings
        │       ├── S10.5 Notification Preferences
        │       ├── S10.6 Appearance
        │       ├── S10.7 Privacy & Data
        │       ├── S10.8 About PrepGraph
        │       └── S10.9 Help & Support

Cross-cutting (reachable from multiple tabs, not tab-owned):
├── M4 Planner → reached from S2.1 (Home) and Notifications; lives conceptually "in" Home
├── M9 Resources → reached from S3.3 (Topic Detail) and S5.4 (Question Detail)
├── M11 Notifications → reached via bell icon on any App Bar
└── M12 AI Assistant → reached via FAB or S3.3 "Ask about this topic"
```

---

## 5. Key IA Decisions & Rationale

**Decision 1 — Planner is not a 6th bottom-nav tab.**
Five tabs is the Material 3 recommended maximum before overcrowding. Planner is surfaced prominently *inside* Home (as the primary "Today's Plan" card) rather than owning a tab, because the Home screen's entire job is already "what should I study today" — a separate tab would fragment that single job across two destinations.

**Decision 2 — Practice and Mock Test share Tab 3 via a segmented control**, not two separate tabs. Both are "structured question-answering" activities; splitting them would force users to learn two mental models for a very similar action. A top segmented control ("Practice" / "Mock Test") keeps them one tap apart.

**Decision 3 — Cutoff Intelligence lives inside Insights**, not as its own tab. Cutoff data is reference information students check occasionally, not a daily-use surface — nesting it avoids diluting the 5-tab structure while keeping it discoverable from the same place students already go to reflect on progress.

**Decision 4 — Knowledge Graph (Learn) is a top-level tab**, not buried under Practice, because it is PrepGraph's core differentiator (per the product philosophy) and needs first-class, daily-visit status — not a feature students stumble into.

**Decision 5 — Full-screen, nav-free modes** are used deliberately for exactly three flows: Onboarding/Auth, Practice Session, and Mock Test. All three require sustained, distraction-free attention; removing the bottom nav during these flows is an intentional focus cue, not an oversight.

**Decision 6 — AI Assistant is a floating, cross-cutting entry point** (FAB or contextual button), not a tab, because doubt-solving is support *for* a topic in context, not a separate daily destination — it should be reachable from wherever a student is confused, without needing to leave that context.

---

## 6. Screen Count Summary

| Module | Screen Count |
|---|---|
| M0 Onboarding & Auth | 5 |
| M1 Profile Setup | 5 |
| M2 Home | 2 |
| M3 Learn | 4 |
| M4 Planner | 4 |
| M5 Practice/PYQ | 6 |
| M6 Mock Test | 5 |
| M7 Cutoff Intelligence | 2 |
| M8 Insights/Analytics | 5 |
| M9 Resources | 2 |
| M10 Profile & Settings | 9 |
| M11 Notifications | 1 |
| M12 AI Assistant | 2 |
| **Total** | **52 screens** |

This is the complete structural blueprint. Next step (on request) would be wireframe-level layout for each screen, module by module, starting with M2 Home as the anchor screen.
