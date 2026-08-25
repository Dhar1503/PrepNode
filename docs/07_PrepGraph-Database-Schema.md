# PrepGraph — MySQL Database Schema Documentation v1.0
### Database: `prepgraph_db` · Engine: InnoDB · Charset: `utf8mb4`

The diagram above shows the core entity relationships. This document is the full schema — all 20 tables, every column, every key, and the indexing and normalization rationale behind each.

---

## 1. Database Architecture

**Engine:** InnoDB exclusively — required for foreign-key enforcement and transaction support (Technical Architecture §10's transactional Mock Test submission depends on this).
**Charset/Collation:** `utf8mb4` / `utf8mb4_unicode_ci` on every table — supports Tamil/regional-language question text (TNPSC content) and any future emoji-adjacent UI content without silent truncation.
**Primary key strategy:** `CHAR(36)` UUIDs (v4) on every table, not auto-increment integers. Chosen deliberately over the more "efficient" integer PK:
- Matches the REST API's opaque-ID authorization model (Technical Architecture §11/§12 — no sequential ID enumeration attack surface).
- Safe to generate client-side for idempotent writes (e.g. `attempt_id` in `user_question_attempts`, per Technical Architecture §13's offline-outbox pattern) without a round-trip to the database first.
- The minor storage/index-size cost (16 bytes vs 4–8) is negligible at this application's scale and is a standard, well-understood trade-off.
**Timestamps:** every table carries `created_at DATETIME DEFAULT CURRENT_TIMESTAMP` and, where rows are mutable, `updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`.
**Soft deletes:** applied only to `users` (`deleted_at DATETIME NULL`) to preserve referential integrity for historical attempts/progress after account deletion requests, per privacy regulations that often require a grace period before hard deletion. All other tables use hard deletes with `ON DELETE CASCADE` where a child record has no meaning without its parent (e.g. `mock_test_answers` without `mock_tests`).
**Normalization target:** Third Normal Form (3NF) throughout, with two deliberate, documented exceptions noted inline in §3–8 where a small denormalization avoids an expensive join on a high-frequency query path.

---

## 2. Entity Relationship Diagram

*(A simplified core-entity view is rendered above. Full relationships below.)*

```
erDiagram
  USERS ||--o| USER_PREFERENCES : has
  USERS ||--o{ REFRESH_TOKENS : owns
  USERS ||--o{ USER_QUESTION_ATTEMPTS : makes
  USERS ||--o{ STUDY_PLANS : has
  USERS ||--o{ USER_TOPIC_PROGRESS : tracks
  USERS ||--o{ CONFIDENCE_CHECKINS : submits
  USERS ||--o{ MOCK_TESTS : takes
  USERS ||--o{ RESOURCE_RATINGS : rates
  USERS ||--o{ BOOKMARKS : creates
  USERS ||--o{ ACHIEVEMENTS : unlocks

  EXAMS ||--o{ SUBJECTS : contains
  EXAMS ||--o{ CUTOFF_DATA : has
  EXAMS ||--o{ MOCK_TESTS : scoped_to

  SUBJECTS ||--o{ TOPICS : contains

  TOPICS ||--o{ TOPICS : parent_of
  TOPICS ||--o{ QUESTIONS : has
  TOPICS ||--o{ USER_TOPIC_PROGRESS : measured_by
  TOPICS ||--o{ CONFIDENCE_CHECKINS : about
  TOPICS ||--o{ RESOURCES : recommends
  TOPICS ||--o{ CONCEPT_RELATIONSHIPS : source_of
  TOPICS ||--o{ STUDY_PLANS : scheduled_for

  QUESTIONS ||--o{ USER_QUESTION_ATTEMPTS : attempted_via
  QUESTIONS ||--o{ MOCK_TEST_QUESTIONS : included_in
  QUESTIONS ||--o{ BOOKMARKS : bookmarked_as

  MOCK_TESTS ||--o{ MOCK_TEST_QUESTIONS : includes
  MOCK_TESTS ||--o{ MOCK_TEST_ANSWERS : records

  RESOURCES ||--o{ RESOURCE_RATINGS : receives
  RESOURCES ||--o{ BOOKMARKS : bookmarked_as
```

---

## 3. User Domain Tables

### 3.1 `users`
| Column | Type | Constraints |
|---|---|---|
| `user_id` | `CHAR(36)` | PK |
| `name` | `VARCHAR(80)` | NOT NULL |
| `email` | `VARCHAR(255)` | NOT NULL, UNIQUE |
| `password_hash` | `VARCHAR(255)` | NOT NULL (bcrypt, cost 12) |
| `phone` | `VARCHAR(20)` | NULL |
| `avatar_url` | `VARCHAR(500)` | NULL |
| `exam_id` | `CHAR(36)` | FK → `exams.exam_id`, NULL |
| `target_date` | `DATE` | NULL |
| `daily_study_hours` | `TINYINT UNSIGNED` | NULL, CHECK (1–16) |
| `preparation_level` | `ENUM('beginner','intermediate','advanced')` | NULL |
| `profile_complete` | `BOOLEAN` | NOT NULL, DEFAULT FALSE |
| `created_at` | `DATETIME` | DEFAULT CURRENT_TIMESTAMP |
| `last_login` | `DATETIME` | NULL |
| `deleted_at` | `DATETIME` | NULL (soft-delete marker) |

**Note on normalization:** `exam_id`/`target_date`/`daily_study_hours`/`preparation_level` could be split into a separate `user_profile` table (which the original project brief calls `user_preferences`). They're kept on `users` here because they're 1:1, always fetched together with the user record (every authenticated request needs them), and splitting them would force a join on nearly every request — a deliberate, documented denormalization exception per §1.

### 3.2 `user_preferences`
Distinct from the profile fields above — this table holds *app configuration*, not *exam personalization*, and is fetched far less often (only on the Settings screen), justifying its separation.
| Column | Type | Constraints |
|---|---|---|
| `preference_id` | `CHAR(36)` | PK |
| `user_id` | `CHAR(36)` | FK → `users.user_id`, UNIQUE, ON DELETE CASCADE |
| `theme_mode` | `ENUM('light','dark','system')` | DEFAULT `'system'` |
| `daily_reminder_enabled` | `BOOLEAN` | DEFAULT TRUE |
| `revision_alerts_enabled` | `BOOLEAN` | DEFAULT TRUE |
| `milestone_updates_enabled` | `BOOLEAN` | DEFAULT TRUE |

### 3.3 `refresh_tokens`
Supports Technical Architecture §11's revocable-session auth design — one row per active device/session.
| Column | Type | Constraints |
|---|---|---|
| `token_id` | `CHAR(36)` | PK |
| `user_id` | `CHAR(36)` | FK → `users.user_id`, ON DELETE CASCADE |
| `token_hash` | `VARCHAR(255)` | NOT NULL (refresh token stored hashed, never plaintext) |
| `device_label` | `VARCHAR(100)` | NULL (e.g. "Pixel 8 – Android") |
| `expires_at` | `DATETIME` | NOT NULL |
| `revoked_at` | `DATETIME` | NULL |
| `created_at` | `DATETIME` | DEFAULT CURRENT_TIMESTAMP |

---

## 4. Exam Hierarchy Tables

### 4.1 `exams`
| Column | Type | Constraints |
|---|---|---|
| `exam_id` | `CHAR(36)` | PK |
| `exam_name` | `VARCHAR(150)` | NOT NULL |
| `description` | `TEXT` | NULL |
| `conducting_body` | `VARCHAR(150)` | NULL |
| `coming_soon` | `BOOLEAN` | DEFAULT FALSE |
| `created_at` | `DATETIME` | DEFAULT CURRENT_TIMESTAMP |

### 4.2 `subjects`
| Column | Type | Constraints |
|---|---|---|
| `subject_id` | `CHAR(36)` | PK |
| `exam_id` | `CHAR(36)` | FK → `exams.exam_id`, ON DELETE CASCADE |
| `subject_name` | `VARCHAR(150)` | NOT NULL |
| `importance_weight` | `DECIMAL(3,2)` | DEFAULT 0.50, CHECK (0.00–1.00) |

### 4.3 `topics`
| Column | Type | Constraints |
|---|---|---|
| `topic_id` | `CHAR(36)` | PK |
| `subject_id` | `CHAR(36)` | FK → `subjects.subject_id`, ON DELETE CASCADE |
| `parent_topic_id` | `CHAR(36)` | FK → `topics.topic_id` (self-referencing), NULL for top-level |
| `topic_name` | `VARCHAR(200)` | NOT NULL |
| `difficulty` | `ENUM('easy','medium','hard')` | DEFAULT `'medium'` |
| `importance_score` | `DECIMAL(3,2)` | DEFAULT 0.50, CHECK (0.00–1.00) |

**Self-referencing FK** (`parent_topic_id`) is what encodes the syllabus hierarchy (History → Ancient History → Chola Dynasty) without a separate closure table — appropriate at this depth (max 3–4 levels observed in the original syllabus design); a closure table would be over-engineering for this depth of nesting.

### 4.4 `concept_relationships`
Backs the Knowledge Graph module (Information Architecture Module M3 / API §5.3).
| Column | Type | Constraints |
|---|---|---|
| `relation_id` | `CHAR(36)` | PK |
| `source_topic_id` | `CHAR(36)` | FK → `topics.topic_id`, ON DELETE CASCADE |
| `target_topic_id` | `CHAR(36)` | FK → `topics.topic_id`, ON DELETE CASCADE |
| `relationship_type` | `ENUM('prerequisite','related','frequently_asked','revision_needed')` | NOT NULL |

**Note:** this is a many-to-many self-relationship on `topics`, deliberately modeled as its own table rather than crammed into `topics.parent_topic_id` — prerequisites are not the same relationship as syllabus hierarchy (a topic can have a prerequisite from a *different* subject entirely, e.g. basic arithmetic as a prerequisite for a Reasoning topic).

---

## 5. Content Tables

### 5.1 `questions` (PYQs)
| Column | Type | Constraints |
|---|---|---|
| `question_id` | `CHAR(36)` | PK |
| `exam_id` | `CHAR(36)` | FK → `exams.exam_id`, ON DELETE CASCADE |
| `subject_id` | `CHAR(36)` | FK → `subjects.subject_id`, ON DELETE CASCADE |
| `topic_id` | `CHAR(36)` | FK → `topics.topic_id`, ON DELETE CASCADE |
| `year` | `SMALLINT UNSIGNED` | NOT NULL |
| `question_text` | `TEXT` | NOT NULL |
| `option_a` / `option_b` / `option_c` / `option_d` | `VARCHAR(500)` | NOT NULL each |
| `correct_answer` | `ENUM('a','b','c','d')` | NOT NULL |
| `explanation` | `TEXT` | NULL |
| `difficulty` | `ENUM('easy','medium','hard')` | DEFAULT `'medium'` |
| `created_at` | `DATETIME` | DEFAULT CURRENT_TIMESTAMP |

**Note on denormalization:** `exam_id` and `subject_id` are technically derivable via `topic_id → subjects.exam_id`, but are stored redundantly here (a documented 3NF exception) because the PYQ browse API (§6.1 of the REST API doc) filters directly by `exam_id`/`subject_id`/`topic_id` together on the single highest-traffic read path in the app — avoiding a two-hop join on every PYQ list request.

### 5.2 `resources`
| Column | Type | Constraints |
|---|---|---|
| `resource_id` | `CHAR(36)` | PK |
| `topic_id` | `CHAR(36)` | FK → `topics.topic_id`, ON DELETE CASCADE |
| `title` | `VARCHAR(200)` | NOT NULL |
| `type` | `ENUM('video','book','notes','article')` | NOT NULL |
| `link` | `VARCHAR(500)` | NOT NULL |
| `average_rating` | `DECIMAL(2,1)` | DEFAULT 0.0 (denormalized aggregate, kept in sync by application logic on each new rating — avoids a `COUNT/AVG` aggregate query on every resource-list render) |
| `rating_count` | `INT UNSIGNED` | DEFAULT 0 |

### 5.3 `resource_ratings`
| Column | Type | Constraints |
|---|---|---|
| `rating_id` | `CHAR(36)` | PK |
| `resource_id` | `CHAR(36)` | FK → `resources.resource_id`, ON DELETE CASCADE |
| `user_id` | `CHAR(36)` | FK → `users.user_id`, ON DELETE CASCADE |
| `rating` | `TINYINT UNSIGNED` | NOT NULL, CHECK (1–5) |
| `created_at` | `DATETIME` | DEFAULT CURRENT_TIMESTAMP |

`UNIQUE (resource_id, user_id)` — one rating per user per resource; a repeat rating is an `UPDATE`, not a new row.

### 5.4 `cutoff_data`
| Column | Type | Constraints |
|---|---|---|
| `cutoff_id` | `CHAR(36)` | PK |
| `exam_id` | `CHAR(36)` | FK → `exams.exam_id`, ON DELETE CASCADE |
| `year` | `SMALLINT UNSIGNED` | NOT NULL |
| `category` | `VARCHAR(50)` | NOT NULL (stored as official historical reference only — per Technical Architecture §12, this column is never joined against a user's own profile in any application query) |
| `cutoff_mark` | `DECIMAL(6,2)` | NOT NULL |
| `vacancy_count` | `INT UNSIGNED` | NULL |

---

## 6. Practice & Assessment Tables

### 6.1 `user_question_attempts`
| Column | Type | Constraints |
|---|---|---|
| `attempt_id` | `CHAR(36)` | PK (client-generated, per Technical Architecture §13 idempotency) |
| `user_id` | `CHAR(36)` | FK → `users.user_id`, ON DELETE CASCADE |
| `question_id` | `CHAR(36)` | FK → `questions.question_id`, ON DELETE CASCADE |
| `selected_answer` | `ENUM('a','b','c','d')` | NOT NULL |
| `is_correct` | `BOOLEAN` | NOT NULL (computed server-side at write time, stored for fast analytics aggregation rather than re-derived on every read) |
| `time_taken_seconds` | `SMALLINT UNSIGNED` | NULL |
| `attempt_date` | `DATETIME` | DEFAULT CURRENT_TIMESTAMP |

### 6.2 `mock_tests`
| Column | Type | Constraints |
|---|---|---|
| `test_id` | `CHAR(36)` | PK |
| `user_id` | `CHAR(36)` | FK → `users.user_id`, ON DELETE CASCADE |
| `exam_id` | `CHAR(36)` | FK → `exams.exam_id`, ON DELETE CASCADE |
| `type` | `ENUM('topic','subject','full')` | NOT NULL |
| `subject_id` | `CHAR(36)` | FK → `subjects.subject_id`, NULL (set only for `type='subject'`) |
| `topic_id` | `CHAR(36)` | FK → `topics.topic_id`, NULL (set only for `type='topic'`) |
| `duration_minutes` | `SMALLINT UNSIGNED` | NOT NULL |
| `status` | `ENUM('in_progress','submitted','expired')` | DEFAULT `'in_progress'` |
| `score` | `DECIMAL(5,2)` | NULL (populated on submission) |
| `started_at` | `DATETIME` | DEFAULT CURRENT_TIMESTAMP |
| `submitted_at` | `DATETIME` | NULL |

### 6.3 `mock_test_questions`
Join table — which questions were selected into a given test instance (question sets are snapshotted at test-start, per REST API §7.2, so a later PYQ edit never retroactively changes an already-taken test).
| Column | Type | Constraints |
|---|---|---|
| `test_id` | `CHAR(36)` | FK → `mock_tests.test_id`, ON DELETE CASCADE, part of composite PK |
| `question_id` | `CHAR(36)` | FK → `questions.question_id`, ON DELETE CASCADE, part of composite PK |
| `question_order` | `TINYINT UNSIGNED` | NOT NULL |

`PRIMARY KEY (test_id, question_id)`.

### 6.4 `mock_test_answers`
| Column | Type | Constraints |
|---|---|---|
| `test_id` | `CHAR(36)` | FK → `mock_tests.test_id`, ON DELETE CASCADE, part of composite PK |
| `question_id` | `CHAR(36)` | FK → `questions.question_id`, ON DELETE CASCADE, part of composite PK |
| `selected_answer` | `ENUM('a','b','c','d')` | NULL (NULL = left unanswered) |
| `is_correct` | `BOOLEAN` | NULL (computed at submission time) |

`PRIMARY KEY (test_id, question_id)`.

---

## 7. Planning & Progress Tables

### 7.1 `study_plans`
| Column | Type | Constraints |
|---|---|---|
| `plan_id` | `CHAR(36)` | PK |
| `user_id` | `CHAR(36)` | FK → `users.user_id`, ON DELETE CASCADE |
| `topic_id` | `CHAR(36)` | FK → `topics.topic_id`, ON DELETE CASCADE |
| `date` | `DATE` | NOT NULL |
| `title` | `VARCHAR(200)` | NOT NULL |
| `duration_minutes` | `SMALLINT UNSIGNED` | NOT NULL |
| `type` | `ENUM('learn','pyq','revision')` | NOT NULL |
| `priority` | `ENUM('low','medium','high')` | DEFAULT `'medium'` |
| `reason` | `VARCHAR(300)` | NULL (the Explainable-AI text shown in `TaskCard`, e.g. "High PYQ frequency + revision needed") |
| `status` | `ENUM('pending','completed','skipped')` | DEFAULT `'pending'` |

### 7.2 `user_topic_progress`
| Column | Type | Constraints |
|---|---|---|
| `progress_id` | `CHAR(36)` | PK |
| `user_id` | `CHAR(36)` | FK → `users.user_id`, ON DELETE CASCADE |
| `topic_id` | `CHAR(36)` | FK → `topics.topic_id`, ON DELETE CASCADE |
| `mastery_percentage` | `DECIMAL(5,2)` | DEFAULT 0.00, CHECK (0–100) |
| `accuracy` | `DECIMAL(5,2)` | NULL, CHECK (0–100) |
| `last_revision_date` | `DATE` | NULL |

`UNIQUE (user_id, topic_id)` — exactly one progress row per user per topic, updated (not inserted) on every relevant activity.

### 7.3 `confidence_checkins`
Backs the Insights module's self-reported Confidence Trend (REST API §9.4–9.5).
| Column | Type | Constraints |
|---|---|---|
| `checkin_id` | `CHAR(36)` | PK |
| `user_id` | `CHAR(36)` | FK → `users.user_id`, ON DELETE CASCADE |
| `topic_id` | `CHAR(36)` | FK → `topics.topic_id`, ON DELETE CASCADE |
| `confidence_level` | `TINYINT UNSIGNED` | NOT NULL, CHECK (1–5) |
| `week_of` | `DATE` | NOT NULL (normalized to the Monday of the check-in's week, for clean weekly aggregation) |

---

## 8. Engagement Tables

### 8.1 `achievements`
| Column | Type | Constraints |
|---|---|---|
| `achievement_id` | `CHAR(36)` | PK |
| `user_id` | `CHAR(36)` | FK → `users.user_id`, ON DELETE CASCADE |
| `achievement_type` | `VARCHAR(50)` | NOT NULL (e.g. `subject_explored`, `revision_streak`) |
| `title` | `VARCHAR(150)` | NOT NULL |
| `description` | `VARCHAR(300)` | NOT NULL |
| `related_topic_id` | `CHAR(36)` | FK → `topics.topic_id`, NULL |
| `unlocked_at` | `DATETIME` | DEFAULT CURRENT_TIMESTAMP |
| `seen` | `BOOLEAN` | DEFAULT FALSE |

Deliberately **personal-only** — there is no `rank`, `percentile`, or `leaderboard_position` column anywhere in this schema, enforcing the Design System's "never comparative" achievement rule at the data-model level, not just the UI level.

### 8.2 `bookmarks`
Generalized across entity types, matching REST API §12's unified bookmark endpoint design.
| Column | Type | Constraints |
|---|---|---|
| `bookmark_id` | `CHAR(36)` | PK |
| `user_id` | `CHAR(36)` | FK → `users.user_id`, ON DELETE CASCADE |
| `entity_type` | `ENUM('question','resource')` | NOT NULL |
| `entity_id` | `CHAR(36)` | NOT NULL (polymorphic reference — no FK constraint possible across two tables, validated at the application layer instead) |
| `created_at` | `DATETIME` | DEFAULT CURRENT_TIMESTAMP |

`UNIQUE (user_id, entity_type, entity_id)` — prevents duplicate bookmarks, and is exactly the constraint the API's `409 ALREADY_BOOKMARKED` error (REST API §12.1) maps onto.

**Note on the polymorphic design:** `entity_id` intentionally has no database-level FK, since MySQL cannot enforce a foreign key against "one of two possible tables." This is a deliberate, documented trade-off (referential integrity for bookmarked entities is enforced by the `bookmark.service.js` application layer, which validates existence before insert) — the alternative (two separate tables, `question_bookmarks` and `resource_bookmarks`) would satisfy strict 3NF/FK purity but was rejected here because it would require the API layer to duplicate near-identical logic twice rather than once, a worse trade-off at this schema's scale.

---

## 9. Indexing Strategy

Indexes are chosen directly from the query patterns in the REST API documentation, not added generically.

| Table | Index | Supports |
|---|---|---|
| `users` | `UNIQUE (email)` | Login lookup, registration uniqueness check |
| `questions` | `INDEX (exam_id, subject_id, topic_id, year)` | PYQ browse endpoint's primary filter path (REST API §6.1) |
| `user_question_attempts` | `INDEX (user_id, question_id)` | Attempt-history lookups and analytics aggregation (REST API §6.4, §9) |
| `user_question_attempts` | `INDEX (user_id, attempt_date)` | Streak/heatmap queries (last-30-days activity, Home dashboard) |
| `study_plans` | `INDEX (user_id, date)` | Today's/week's plan queries — the single highest-frequency read in the app (hit on every Home screen load) |
| `user_topic_progress` | `UNIQUE (user_id, topic_id)` | Doubles as both the uniqueness constraint and the lookup index for Strength Map queries |
| `mock_tests` | `INDEX (user_id, status)` | "Do you have an in-progress test?" check on Mock Test start (REST API §7.2's `TEST_ALREADY_IN_PROGRESS` check) |
| `cutoff_data` | `INDEX (exam_id, year)` | Cutoff trend chart queries |
| `resources` | `INDEX (topic_id, type)` | Resource list filter (REST API §11.1) |
| `bookmarks` | `INDEX (user_id, entity_type)` | Bookmark list queries (REST API §12.3) |
| `achievements` | `INDEX (user_id, unlocked_at DESC)` | Achievement list, most-recent-first |
| `refresh_tokens` | `INDEX (user_id, revoked_at)` | Session-validity checks on token refresh |
| `concept_relationships` | `INDEX (source_topic_id)`, `INDEX (target_topic_id)` | Knowledge Graph traversal in both directions (REST API §5.3) |

**Composite index column order rule applied throughout:** the most selective / most-frequently-filtered-alone column is placed first in each composite index (e.g. `user_id` before `date` in `study_plans`, since "give me this user's plan" is always the entry filter, with date narrowing afterward) — standard leftmost-prefix indexing practice.

---

## 10. Sample Data Examples

### `exams`
| exam_id | exam_name | conducting_body |
|---|---|---|
| `e1a2...` | TNPSC Group 2 | Tamil Nadu Public Service Commission |
| `e1b3...` | TNPSC Group 4 | Tamil Nadu Public Service Commission |

### `subjects`
| subject_id | exam_id | subject_name | importance_weight |
|---|---|---|---|
| `s1a1...` | `e1a2...` | Indian Polity | 0.90 |
| `s1a2...` | `e1a2...` | Indian History | 0.85 |

### `topics`
| topic_id | subject_id | parent_topic_id | topic_name | importance_score |
|---|---|---|---|---|
| `t1a1...` | `s1a1...` | NULL | Constitution | 0.95 |
| `t1a2...` | `s1a1...` | `t1a1...` | Fundamental Rights | 0.88 |

### `questions`
| question_id | topic_id | year | question_text (truncated) | correct_answer |
|---|---|---|---|---|
| `q1a1...` | `t1a2...` | 2024 | "Which Article of the Constitution deals with..." | `b` |

### `study_plans`
| plan_id | user_id | topic_id | date | title | reason | status |
|---|---|---|---|---|---|---|
| `p1a1...` | `u1a1...` | `t1a2...` | 2026-07-16 | Fundamental Rights | "High PYQ frequency + revision overdue by 10 days" | `pending` |

### `user_topic_progress`
| progress_id | user_id | topic_id | mastery_percentage | accuracy |
|---|---|---|---|---|
| `pr1a1...` | `u1a1...` | `t1a2...` | 62.00 | 58.00 |

### `achievements`
| achievement_id | user_id | achievement_type | title |
|---|---|---|---|
| `ach1a1...` | `u1a1...` | `subject_explored` | "Explored every topic in Indian Polity" |

---

## 11. Scalability & Normalization Summary

- **Normalization level:** 3NF throughout, with exactly three documented, deliberate denormalizations — `users` holding profile fields inline (§3.1), `questions` duplicating `exam_id`/`subject_id` (§5.1), and `resources.average_rating`/`rating_count` as maintained aggregates (§5.2) — each chosen because it eliminates a join or aggregate query on a proven high-frequency read path, and each is documented here specifically so a future engineer doesn't "fix" it back into stricter normal form without understanding the trade-off.
- **Horizontal scalability path:** every table's PK is a UUID rather than an auto-increment integer specifically so that, if the application ever needs to shard by `user_id` or migrate to a distributed SQL engine, no primary key collision or re-keying migration is required — this decision in §1 is this schema's single biggest lever for future scale, made once, upfront, rather than retrofitted later.
- **Read-heavy optimization:** the indexing strategy in §9 is deliberately biased toward the app's read-heavy access pattern (Home/Planner/PYQ-browse are hit constantly; writes like `POST /pyq/attempt` are comparatively infrequent per user) — this matches the real usage shape of a study app, where students read a plan far more often than they submit an answer.
- **Growth-ready content model:** adding a new exam (UPSC, SSC, Banking) requires zero schema changes — only new rows in `exams`/`subjects`/`topics`/`questions`, exactly the scalability requirement stated in the original project brief.

This schema, together with the Design System, Information Architecture, User Journey, Technical Architecture, UI Screen Specifications, and REST API Documentation already produced, completes PrepGraph's full pre-build documentation set end to end — product vision through to the literal `CREATE TABLE` statements this document implies.
