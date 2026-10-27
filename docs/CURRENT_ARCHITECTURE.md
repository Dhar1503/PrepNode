# PrepNode — Current Architecture (as of Phase 1C)

This document describes what actually exists in the running app today.
The older `docs/07_PrepNode-Database-Schema.md` and
`lib/PROJECT_STRUCTURE.md` describe an earlier, more ambitious plan (a
real MySQL backend, bcrypt password hashing, different folder names) that
was never built — this file supersedes them for anything about current
state. Those documents remain useful as historical design intent, not as
a description of what runs today.

## Stack

- **Flutter** (Dart), single codebase, Android built and tested; iOS/Web/
  Desktop scaffolded by default but never built or tested.
- **Riverpod** — state management and dependency injection throughout.
- **GoRouter** — navigation, `StatefulShellRoute` for the 5 bottom-nav tabs.
- **Drift (SQLite)** — the real, persisted local database. **This is the
  actual source of truth**, not a cache in front of a live backend.
- **Dio** — REST client, fully implemented (auth headers, token refresh,
  retry) with nowhere to connect to. See "No backend" below.
- **Clean Architecture** — Presentation → Domain → Data, three layers per
  feature, consistently applied across all 13 feature modules.
- **Repository Pattern** — every feature repository attempts a remote
  call, falls back to Drift on failure. This offline-first behavior is
  real and load-bearing.

## No backend

`api.prepnode.app` does not resolve — there is no server. Every Dio call
in the app fails with a connection error and falls back to local data.
This is the actual, intended state of this build, not a bug: it means
the app is genuinely usable offline, because the offline path is the
*only* path currently exercised.

## Local database (Drift/SQLite)

Schema v3 as of Phase 1A. 23 tables:

`Users, UserPreferences, RefreshTokens, Exams, Subjects, Topics,
ConceptRelationships, Questions, Resources, ResourceRatings, CutoffData,
UserQuestionAttempts, UserAnalytics, StudySessions, MockTests,
MockTestQuestions, MockTestAnswers, StudyPlans, UserTopicProgress,
ConfidenceCheckins, Achievements, Bookmarks, ContentSyncMetadata`

Schema v2 → v3 was the first real migration this project has had — every
prior schema change relied on a fresh install (no data preservation) since
no `MigrationStrategy.onUpgrade` existed before. Migrations are now
additive-only and preserve existing local data across app updates.

## Password security

Local-only djb2-style hash (`AuthLocalDataSource._hashSecret`), explicitly
not cryptographically secure, used only to gate the offline-fallback
login/register path. **Not bcrypt** (the old MySQL-era doc claims bcrypt
cost 12 — that was never implemented). If a real backend existed, it
would own real password hashing server-side; this local hash would remain
a device-only convenience gate, not the security boundary.

## Resource catalog — consolidated in Phase 1A

Before Phase 1A there were **three** independent resource data sources:
1. A thin, mostly-orphaned Drift `Resources` table (`SeedData.getResources()`,
   topicIds that matched no real Topic row).
2. A hardcoded static class (`ResourceRemoteDataSource`) with ~25 rich
   entries — the one actually shown in the UI.
3. (Implicitly) whatever a real backend might have served, had one existed.

As of Phase 1A: the Drift `Resources` table is the single source of
truth, seeded from `SeedData.getResourceCatalog()` (the migrated, richer
catalog). `ResourceRemoteDataSource` is now a genuine Dio-based remote
datasource matching the pattern every other feature already uses — it
will fail until a backend exists, exactly like every other remote call
in the app.

## Content volume (real counts, Phase 1B)

| Content | Count | Note |
|---|---|---|
| Subjects | 4 | `subject-general-tamil`, `subject-general-english`, `subject-general-studies`, `subject-aptitude` |
| Topics | 14 | 9 original (all under General Studies) + 5 added Phase 1B so Tamil/English/Aptitude/Science/Current Affairs have at least one topic each |
| Concept relationships (KG edges) | 7 | Unchanged — no new relationships added without a specific justified prerequisite claim |
| Questions (PYQ-style) | 5 | All unverified. Far below a usable practice bank. See "PYQ/cutoff sourcing" below |
| Cutoff rows | 35 | 5 years × 7 categories. All unverified — see below |
| Resources | 22 | 7 verified (4 YouTube + 2 official websites + 1 official syllabus PDF, fixed Phase 1C), 15 placeholder (`example.com`, unchanged). All topicId/subjectId references corrected in Phase 1B |

## Exam marks scale — corrected in Phase 1B

TNPSC Group 2 Prelims is **200 questions for 300 marks** (100 Language +
75 General Studies + 25 Aptitude & Mental Ability; qualifying mark
90/300) — verified against multiple independent sources. The app
previously assumed a 200-mark scale throughout (`cutoff_repository_impl.dart`'s
readiness projection, `category_comparison_screen.dart`'s progress bar,
and the Readiness screen's own "How this is calculated" text) — all
corrected. This also means anything said about a "200-mark paper" earlier
in this project's viva-prep material was wrong and should be corrected
before being repeated to anyone.

## PYQ/cutoff sourcing — attempted and honestly incomplete

Phase 1B attempted to source real PYQ questions and exact cutoff figures
via web search. Both attempts hit the same wall: search surfaces
third-party aggregator summaries (prepp.in, careerpower.in, testbook,
etc.), never the primary tnpsc.gov.in document itself in a form that can
be read with transcription-grade fidelity. One aggregator's 2019 cutoff
table (OC 161) directly conflicts with this app's existing seed data (OC
175) — neither has been confirmed against an official source, so neither
was used to silently overwrite the other. **No PYQ content or cutoff
figures were added or changed in Phase 1B** as a result — the existing 6
seed questions and 35 seed cutoff rows remain exactly what they were:
realistic placeholder content, honestly marked `verificationStatus:
'unverified'` where that field exists. Getting real, verified content
here requires either the user supplying actual official PDFs, or
dedicated manual transcription time — not a shortcut through search.

## Resource catalog topic/subject mapping — fixed in Phase 1B

Phase 1A's resource catalog consolidation shipped with topicId/subjectId
values (`topic-1-1`, `subject-1`, etc.) that didn't match any real seeded
row — the exact same orphaned-foreign-key mistake that consolidation was
meant to fix, just reintroduced under a different naming scheme. This
also explains why the Knowledge Graph appeared empty when browsing
General Tamil/English/Aptitude: those subjects had zero topics seeded at
all. Both are now fixed — every resource maps to a real topic, and every
subject has at least one topic.

## AI Assistant

Rule-based intent matching over the student's real local data (mastery,
PYQ stats, cutoff gap, capacity profile, etc.) — **not** a language model.
No general subject-matter knowledge exists in the app; it can report on a
student's own activity, not explain a concept it was never given content
for. An LLM integration, if added later, is intentionally kept separate
from this core rule-based engine per explicit product direction.

## Folder structure

The real feature folder names are: `auth, dashboard, knowledge_graph,
planner, pyq, mock_test, cutoff, insights, resources, ai_assistant,
strategy, settings, notifications`. `lib/PROJECT_STRUCTURE.md` names
different folders (`learn`, `pyqs`, `mock_tests`, `profile`) from an
earlier plan — treat that file as historical, not current.

## Phase 1C — real content verification and replacement (2026-08-17)

Goal: replace fictional/unverified content with genuinely sourced TNPSC
material wherever a real source could actually be established, without
touching architecture, schema shape, or the verification model built in
Phase 1A/1B. No new web/API dependency was added; no YouTube Data API was
added; the two schema migrations already in place (v3, v4) were not
touched — this phase made **zero schema changes**.

**What was actually found and verified:**
- The official TNPSC syllabus index (`tnpsc.gov.in/English/syllabus.html`)
  is real and lists syllabus code 495, "Combined Civil Services
  (Preliminary) Examination — Group-II and IIA Services", linking to
  `tnpsc.gov.in/static_pdf/syllabus/495_Group II and IIA prelims.pdf`.
  That URL was fetched directly and confirmed to resolve (a real PDF is
  returned, not a 404). `res-6` previously pointed at a *guessed* URL
  (`tnpsc.gov.in/group2-syllabus.pdf`) that was confirmed 404 on direct
  fetch — a fabricated link on a real domain, which is exactly the kind
  of thing this phase exists to catch. `res-6` now points at the real
  URL and is marked `verificationStatus: 'verified'`.
- This is resource-level verification (the link resolves and its
  identity is corroborated by an independent naming convention/code, not
  by transcribing its contents) — a lower bar than verifying PYQ text or
  cutoff numbers, and it is not claimed to be more than that.

**What was searched for and genuinely not found:**
- **PYQs**: `tnpsc.gov.in/English/previous-questions.html` is real and
  lists scanned original papers for Group I, Group IV, VAO, and several
  specialist posts — but not Group 2/2A under any name tried. The site's
  answer-key index likewise has no current Group 2/2A entries reachable
  by direct navigation. One candidate PDF (from a differently-named
  "Combined Sub-ordinate Service Examination" entry) was fetched and did
  load, but it is a scanned image with no extractable text, and this
  environment has no PDF/OCR rendering available (`pdftoppm`/poppler not
  installed) to transcribe it even if it were confirmed to be the right
  exam. Zero PYQs were added or marked verified.
- **Cutoffs**: no stable, navigable results/cutoff archive page was found
  on tnpsc.gov.in itself (multiple guessed URLs 404'd); search results
  only ever surface third-party aggregator coverage, never a primary
  document. This reconfirms Phase 1B's finding. Zero cutoff rows were
  added, changed, or marked verified — all 35 remain exactly as before.
- **Other resource placeholders**: the remaining 15 `example.com` links
  (generic notes/book/aptitude PDFs) were deliberately left as
  placeholders rather than pointed at some other real-but-unrelated site
  just to remove `example.com` — several (e.g. a specific book title)
  have no legitimate free/official equivalent to link to at all.

**UI safety fix (Priority 5, rule 15):** two places could previously let
unverified content read as authoritative:
1. `resource_detail_screen.dart` showed a single green "Official
   Material" checkmark badge driven only by `isOfficial` — a flag that
   describes a resource's *claimed* origin, not whether PrepNode
   verified its link. Several `isOfficial: true` resources (e.g. `res-7`,
   `res-8`, `res-9`, `res-11`) still carry `example.com` placeholder
   links, so this badge could show a verified-looking checkmark next to
   a fake URL. Replaced with two independent badges: a neutral "Claimed
   Official Source" label (no checkmark) plus a `verificationStatus`-
   driven badge that separately reads Verified / Unverified source /
   Placeholder link — not real, do not use (the last one detected via
   the `example.com` link check, not a new schema field).
2. `question_card.dart` (PYQ practice screen) had no verification
   indicator at all — a seed/illustrative question looked identical to a
   confirmed real PYQ. Added a small "Verified PYQ" / "Unverified" badge
   next to the existing difficulty/year badges, driven by the question's
   existing `verificationStatus` field.
3. The Cutoff Intelligence disclaimer banner previously read "Historical
   trends are shown for reference only. Actual cutoffs may vary." —
   true but not honest about the deeper issue (the figures aren't
   confirmed against any official document at all). Reworded to "These
   cutoff figures are illustrative and not yet confirmed against an
   official TNPSC notification. Do not treat them as official."

No other UI, layout, or visual design was touched.

**Provenance field for Questions — considered, not added.** The task
brief anticipated adding a `sourceUrl`-equivalent field to `Questions` if
real PYQs were found and the existing `source` free-text field proved
insufficient. Since zero real PYQs were sourced this phase, adding that
field now would mean a schema migration with no real data to justify it
— exactly the "looks complete" trap this phase is supposed to avoid. Left
for whichever phase actually transcribes real PYQ content.
