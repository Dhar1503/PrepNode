# PrepGraph — REST API Documentation v1.0
### Node.js + Express.js + MySQL
**Base URL:** `https://api.prepgraph.app/api/v1`
Consistent with the Technical Architecture document's layered backend (Routes → Controller → Service → Repository → MySQL).

---

## 0. API Architecture

### 0.1 Versioning
All routes are prefixed `/api/v1`. Breaking changes ship as `/api/v2` alongside the old version until clients migrate — never a breaking change to a live `v1` path.

### 0.2 Authentication
Every endpoint except those under `/auth/*` (and `GET /exams`, treated as public catalog data) requires:
```
Authorization: Bearer <accessToken>
```
Access tokens are short-lived JWTs (15 min); see §2 for the refresh flow.

### 0.3 Standard Response Envelope
Every response, success or failure, uses one of these two shapes — this is what lets the Flutter Data layer parse all 14 API groups with one generic wrapper.

**Success:**
```json
{
  "success": true,
  "data": { },
  "message": "Human-readable confirmation",
  "meta": { "timestamp": "2026-07-16T10:00:00Z" }
}
```

**Error:**
```json
{
  "success": false,
  "error": { "code": "VALIDATION_ERROR", "message": "email is required" },
  "meta": { "timestamp": "2026-07-16T10:00:00Z" }
}
```

### 0.4 Common Error Responses
Referenced from every endpoint below as "Common Errors" rather than repeated in full each time.

| HTTP Status | `error.code` | Meaning |
|---|---|---|
| 400 | `VALIDATION_ERROR` | Request body/query failed schema validation |
| 401 | `AUTH_MISSING_TOKEN` | No `Authorization` header present |
| 401 | `AUTH_INVALID_TOKEN` | Token malformed, expired, or signature invalid |
| 403 | `AUTH_FORBIDDEN` | Valid token, but the user lacks permission for this resource |
| 404 | `RESOURCE_NOT_FOUND` | Path parameter references a non-existent record |
| 409 | `CONFLICT` | Request conflicts with existing state (e.g. duplicate email) |
| 429 | `RATE_LIMITED` | Too many requests from this client/IP |
| 500 | `INTERNAL_ERROR` | Unhandled server error — logged server-side, generic message returned to client |

### 0.5 Pagination
List endpoints returning potentially large collections accept `?page=1&limit=20` (defaults shown) and return:
```json
"meta": {
  "timestamp": "...",
  "pagination": { "page": 1, "limit": 20, "totalItems": 134, "totalPages": 7 }
}
```

### 0.6 Rate Limiting
Global: 100 requests/minute per IP. `/auth/login` and `/auth/register` specifically: 5 requests/minute per IP, per Technical Architecture §12.

---

## 1. Authentication APIs

### 1.1 Register
`POST /auth/register`

**Request body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `name` | string | yes | 2–80 chars |
| `email` | string | yes | valid email, unique |
| `password` | string | yes | min 8 chars |

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "accessToken": "...",
    "refreshToken": "...",
    "user": { "id": "uuid", "name": "Dharani", "email": "...", "profileComplete": false }
  },
  "message": "Account created successfully"
}
```

**Error responses:** Common Errors, plus:
| Status | Code | Meaning |
|---|---|---|
| 409 | `EMAIL_EXISTS` | Email already registered |

---

### 1.2 Login
`POST /auth/login`

**Request body:** `{ "email": string, "password": string }`

**Response `200`:** Same shape as Register's `data`, with `profileComplete` reflecting the account's actual state.

**Error responses:** Common Errors, plus:
| Status | Code | Meaning |
|---|---|---|
| 401 | `AUTH_INVALID_CREDENTIALS` | Email/password combination incorrect (deliberately not specific about which field, per Technical Architecture §11 anti-enumeration practice) |

---

### 1.3 Google Sign-In
`POST /auth/google`

**Request body:** `{ "idToken": string }` (Google-issued ID token from the client SDK)

**Response `200`:** Same shape as Login — the server verifies the Google token independently before issuing PrepGraph's own JWT pair (never trusts a client-asserted identity, per Technical Architecture §11).

**Error responses:** Common Errors, plus:
| Status | Code | Meaning |
|---|---|---|
| 401 | `AUTH_GOOGLE_TOKEN_INVALID` | Google token failed independent verification |

---

### 1.4 Refresh Token
`POST /auth/refresh`

**Request body:** `{ "refreshToken": string }`

**Response `200`:** `{ "accessToken": "...", "refreshToken": "..." }` (refresh tokens are rotated on use — the old one is invalidated).

**Error responses:** Common Errors, plus:
| Status | Code | Meaning |
|---|---|---|
| 401 | `AUTH_REFRESH_EXPIRED_OR_REVOKED` | Refresh token no longer valid — client must route to Login |

---

### 1.5 Forgot Password
`POST /auth/forgot-password`

**Request body:** `{ "email": string }`

**Response `200`:** `{ "success": true, "message": "If an account exists for this email, a reset link has been sent." }` — deliberately identical response whether or not the email exists, to avoid leaking account existence.

---

### 1.6 Reset Password
`POST /auth/reset-password`

**Request body:** `{ "resetToken": string, "newPassword": string }`

**Response `200`:** `{ "success": true, "message": "Password updated. Please log in again." }`

**Error responses:** Common Errors, plus:
| Status | Code | Meaning |
|---|---|---|
| 400 | `RESET_TOKEN_EXPIRED` | Reset link expired (typically 1 hour TTL) |

---

### 1.7 Logout
`POST /auth/logout`
**Auth required.** **Request body:** `{ "refreshToken": string }` (revokes this specific device/session server-side).
**Response `200`:** `{ "success": true, "message": "Logged out" }`

---

## 2. User APIs

### 2.1 Get Profile
`GET /users/:userId/profile`
**Response `200` `data`:** `{ id, name, email, avatarUrl, examId, targetDate, dailyStudyHours, preparationLevel, createdAt }`
**Error responses:** Common Errors (403 if `:userId` ≠ authenticated user's own id — users may only read their own profile).

### 2.2 Update Profile
`PATCH /users/:userId/profile`
**Request body (all optional, partial update):** `{ name?, examId?, targetDate?, dailyStudyHours?, preparationLevel? }`
**Response `200`:** the updated profile object, same shape as 2.1.
**Error responses:** Common Errors, plus `VALIDATION_ERROR` if `dailyStudyHours` outside 1–16 or `targetDate` in the past.

### 2.3 Upload Avatar
`POST /users/:userId/avatar` (multipart/form-data, field name `avatar`, max 5MB, jpeg/png)
**Response `200`:** `{ "avatarUrl": "https://cdn.prepgraph.app/avatars/..." }`
**Error responses:** Common Errors, plus:
| Status | Code | Meaning |
|---|---|---|
| 400 | `FILE_TOO_LARGE` | Exceeds 5MB |
| 415 | `UNSUPPORTED_FILE_TYPE` | Not jpeg/png |

### 2.4 Get Preferences
`GET /users/:userId/preferences`
**Response `200` `data`:** `{ themeMode: "light"|"dark"|"system", notifications: { dailyReminder: bool, revisionAlerts: bool, milestoneUpdates: bool } }`

### 2.5 Update Preferences
`PATCH /users/:userId/preferences`
**Request body:** partial of the shape in 2.4.
**Response `200`:** the updated preferences object.

### 2.6 Delete Account
`DELETE /users/:userId`
**Request body:** `{ "confirmationPassword": string }` (re-authentication required for this destructive action)
**Response `200`:** `{ "success": true, "message": "Account deleted" }`
**Error responses:** Common Errors, plus `401 AUTH_INVALID_CREDENTIALS` if the confirmation password is wrong.

---

## 3. Exam APIs

### 3.1 List Exams
`GET /exams` — **public, no auth required** (catalog data).
**Query params:** none required.
**Response `200` `data`:** `[{ id, name, description, conductingBody, comingSoon: bool }]`

### 3.2 Get Exam Detail
`GET /exams/:examId`
**Response `200` `data`:** `{ id, name, description, conductingBody, subjectCount, totalPyqCount }`
**Error responses:** Common Errors (`404 RESOURCE_NOT_FOUND` for an invalid `:examId`).

---

## 4. Subject APIs

### 4.1 List Subjects for an Exam
`GET /exams/:examId/subjects`
**Response `200` `data`:** `[{ id, examId, subjectName, importanceWeight, topicCount }]`

### 4.2 Get Subject Detail
`GET /subjects/:subjectId`
**Response `200` `data`:** `{ id, examId, subjectName, importanceWeight, description }`
**Error responses:** Common Errors.

---

## 5. Topic APIs

### 5.1 List Topics for a Subject
`GET /subjects/:subjectId/topics`
**Query params:** `?includeMastery=true` — when `true` and the caller is authenticated, merges the current user's `mastery_percentage` per topic from `user_topic_progress` (per Technical Architecture §10's repository-layer join pattern).
**Response `200` `data`:** `[{ id, subjectId, topicName, parentTopicId, difficulty, importanceScore, masteryPercentage? }]` (hierarchical — `parentTopicId: null` for top-level topics).

### 5.2 Get Topic Detail
`GET /topics/:topicId`
**Response `200` `data`:** `{ id, topicName, subjectId, difficulty, importanceScore, masteryPercentage, prerequisiteTopics: [{ id, name }], relatedResourceCount, pyqCount }`
**Error responses:** Common Errors.

### 5.3 Get Topic Graph (Knowledge Graph)
`GET /topics/:topicId/graph`
**Query params:** `?radius=1` (how many relationship hops to include around the requested topic — defaults to 1, capped at 2, per Technical Architecture §12's "never the entire syllabus graph at once" rule).
**Response `200` `data`:** `{ nodes: [{ id, name, masteryState }], edges: [{ sourceNodeId, targetNodeId, relationshipType }] }`
`relationshipType` ∈ `prerequisite | related | frequently_asked | revision_needed`.

---

## 6. PYQ APIs

### 6.1 List Questions
`GET /pyq/:examId/:subjectId/:topicId`
**Query params:** `?year=2024` (optional filter), `?page=1&limit=20`.
**Response `200` `data`:** `[{ id, year, questionText, options: [a,b,c,d], difficulty, solved: bool, bookmarked: bool }]` — `solved`/`bookmarked` are per-authenticated-user flags joined in at the repository layer.

### 6.2 Get Question Detail
`GET /pyq/question/:questionId`
**Response `200` `data`:** `{ id, questionText, options, correctAnswer, explanation, difficulty, relatedTopicId, year }`

### 6.3 Submit Attempt
`POST /pyq/attempt`

**Request body:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `attemptId` | string (UUID) | yes | client-generated, for idempotency (Technical Architecture §13) |
| `questionId` | string | yes | |
| `selectedAnswer` | string | yes | one of `a\|b\|c\|d` |
| `timeTakenSeconds` | integer | yes | |

**Response `200` `data`:** `{ isCorrect: bool, correctAnswer, explanation }`
Server-side: `INSERT ... ON DUPLICATE KEY UPDATE` keyed on `attemptId`, so a retried offline-sync request never double-counts (Technical Architecture §13).

**Error responses:** Common Errors, plus `404 RESOURCE_NOT_FOUND` if `questionId` doesn't exist.

### 6.4 Get Attempt History
`GET /pyq/attempts/:userId`
**Query params:** `?topicId=` (optional filter), `?page=1&limit=20`.
**Response `200` `data`:** `[{ questionId, selectedAnswer, isCorrect, attemptDate, timeTakenSeconds }]`

---

## 7. Mock Test APIs

### 7.1 Get Test Configuration Options
`GET /mock-test/config`
**Query params:** `?examId=`
**Response `200` `data`:** `[{ type: "topic"|"subject"|"full", estimatedDurationMinutes, questionCount }]`

### 7.2 Start a Test
`POST /mock-test/start`
**Request body:** `{ examId, type: "topic"|"subject"|"full", subjectId?, topicId? }` (`subjectId`/`topicId` required only for their respective `type`).
**Response `201` `data`:** `{ testId, durationMinutes, questions: [{ id, questionText, options }] }` — note: `correctAnswer` is deliberately withheld until submission.
**Error responses:** Common Errors, plus `409 CONFLICT` (`code: "TEST_ALREADY_IN_PROGRESS"`) if the user has an unsubmitted test session already open.

### 7.3 Submit a Test
`POST /mock-test/:testId/submit`
**Request body:** `{ answers: [{ questionId, selectedAnswer }] }`
**Response `200` `data`:** `{ score, totalQuestions, accuracy, sectionBreakdown: [{ subjectName, correct, total }], weakTopics: [{ topicId, topicName }] }`
Computed server-side only — never client-side — per Technical Architecture §13's stance that Mock Test scoring is not offline-capable.
**Error responses:** Common Errors, plus:
| Status | Code | Meaning |
|---|---|---|
| 400 | `TEST_ALREADY_SUBMITTED` | This `testId` has already been finalized |
| 400 | `TEST_EXPIRED` | Submission arrived after the allotted duration + grace period |

### 7.4 Get Test Result
`GET /mock-test/:testId/result`
**Response `200` `data`:** same shape as 7.3's response — retrievable after the fact (e.g. reopening from Notification/History).

### 7.5 Get Detailed Review
`GET /mock-test/:testId/review`
**Response `200` `data`:** `[{ questionId, questionText, options, selectedAnswer, correctAnswer, explanation, relatedTopicId }]`

---

## 8. Study Planner APIs

### 8.1 Get Plan
`GET /planner/:userId`
**Query params:** `?range=today|week` (default `today`).
**Response `200` `data`:** `[{ id, topicId, title, durationMinutes, reason, type: "learn"|"pyq"|"revision", status: "pending"|"completed"|"skipped", date }]`

### 8.2 Generate Plan
`POST /planner/generate`
**Request body:** `{ userId }` — triggers the Adaptive Study Planner algorithm (Technical Architecture §8's `planner.service.js`, implementing the weighted Priority Score formula).
**Response `200` `data`:** the newly generated day's task list (same shape as 8.1).

### 8.3 Update Task Status
`PATCH /planner/task/:taskId`
**Request body:** `{ status: "completed"|"skipped" }`
**Response `200` `data`:** the updated task object.
**Error responses:** Common Errors, plus `404 RESOURCE_NOT_FOUND` if `taskId` doesn't belong to the caller.

### 8.4 Reschedule Task
`POST /planner/task/:taskId/reschedule`
**Request body:** `{ newDate: "YYYY-MM-DD" }`
**Response `200` `data`:** the updated task object with its new `date`.

---

## 9. Progress Analytics APIs

### 9.1 Get Analytics Summary
`GET /analytics/:userId`
**Response `200` `data`:**
```json
{
  "prepGraphScore": 782,
  "scoreComponents": {
    "topicCompletion": 0.68, "pyqPerformance": 0.71,
    "mockAccuracy": 0.64, "consistency": 0.80, "revisionDiscipline": 0.55
  },
  "syllabusCoveragePercent": 62,
  "streak": [{ "date": "2026-07-15", "studied": true }]
}
```

### 9.2 Get Strength Map
`GET /analytics/:userId/strength-map`
**Response `200` `data`:** `[{ topicId, topicName, subjectName, masteryPercentage }]`

### 9.3 Get Time Invested Detail
`GET /analytics/:userId/time-invested`
**Query params:** `?range=week|month`
**Response `200` `data`:** `[{ subjectName, minutesStudied, date }]`

### 9.4 Get Confidence Trend
`GET /analytics/:userId/confidence-trend`
**Response `200` `data`:** `[{ topicId, topicName, weekOf, selfReportedConfidence }]` (1–5 scale, user-submitted via a lightweight periodic check-in prompt, not inferred).

### 9.5 Submit Confidence Check-in
`POST /analytics/:userId/confidence-checkin`
**Request body:** `{ topicId, confidenceLevel: 1-5 }`
**Response `201`:** `{ "success": true, "message": "Recorded" }`

---

## 10. Cutoff APIs

### 10.1 Get Cutoff Data
`GET /cutoff/:examId`
**Query params:** `?category=` (optional; per Technical Architecture §12, category data is stored and returned only as historical reference and is never cross-joined with the requesting user's own profile).
**Response `200` `data`:** `[{ year, category, cutoffMark, vacancyCount }]`

### 10.2 Get Cutoff Trend Summary
`GET /cutoff/:examId/trend`
**Response `200` `data`:** `{ years: [2020,2021,2022,2023,2024], cutoffSeries: [...], vacancySeries: [...], difficultyTrend: [...] }` — pre-aggregated shape ready for direct charting client-side.

---

## 11. Resource Recommendation APIs

### 11.1 List Resources for a Topic
`GET /topics/:topicId/resources`
**Query params:** `?type=video|book|notes|article` (optional filter).
**Response `200` `data`:** `[{ id, title, type, link, rating, ratingCount }]`

### 11.2 Get Resource Detail
`GET /resources/:resourceId`
**Response `200` `data`:** `{ id, title, type, link, rating, topicId, description }`

### 11.3 Rate a Resource
`POST /resources/:resourceId/rate`
**Request body:** `{ rating: 1-5 }`
**Response `200` `data`:** `{ newAverageRating, ratingCount }`

### 11.4 Get Recommended Resources (personalized)
`GET /users/:userId/recommended-resources`
Implements Algorithm 4 (Personalized Resource Recommendation) from the original design: recommends beginner content below 50% topic accuracy, practice questions between 50–80%, advanced PYQs above 80%.
**Response `200` `data`:** `[{ resourceId, title, type, reasonTag: "foundational"|"practice"|"advanced" }]`

---

## 12. Bookmark APIs

Generalized across bookmarkable entity types (`question`, `resource`) rather than one endpoint set per type, keeping the API surface small.

### 12.1 Add Bookmark
`POST /bookmarks`
**Request body:** `{ entityType: "question"|"resource", entityId: string }`
**Response `201` `data`:** `{ bookmarkId, entityType, entityId, createdAt }`
**Error responses:** Common Errors, plus `409 CONFLICT` (`code: "ALREADY_BOOKMARKED"`).

### 12.2 Remove Bookmark
`DELETE /bookmarks/:bookmarkId`
**Response `200`:** `{ "success": true, "message": "Bookmark removed" }`

### 12.3 List Bookmarks
`GET /users/:userId/bookmarks`
**Query params:** `?entityType=question|resource`, `?page=1&limit=20`.
**Response `200` `data`:** `[{ bookmarkId, entityType, entityId, entitySummary: { ... }, createdAt }]` — `entitySummary` is a lightweight denormalized preview (question text snippet or resource title) so the client doesn't need a second round-trip per bookmarked item.

---

## 13. Achievement APIs

Achievements are always personal-only milestones (per Design System §29 — never comparative badges), backed by an `achievements` table: `{ achievement_id, user_id, achievement_type, title, description, unlocked_at }`.

### 13.1 List User Achievements
`GET /users/:userId/achievements`
**Response `200` `data`:** `[{ id, achievementType, title, description, unlockedAt, seen: bool }]`

### 13.2 Get Achievement Detail
`GET /achievements/:achievementId`
**Response `200` `data`:** `{ id, achievementType, title, description, unlockedAt, relatedTopicId? }`

### 13.3 Mark Achievement as Seen
`PATCH /achievements/:achievementId/seen`
Called once the client has displayed the milestone card, so it doesn't re-trigger a celebratory state on next app open.
**Response `200`:** `{ "success": true }`

---

## 14. Cross-Cutting Notes for Implementers

- **All `:userId` path parameters are authorization-checked against the authenticated token's `userId`** in `authMiddleware` before reaching the controller — a user can never read or write another user's resources by guessing an ID, even though IDs are opaque UUIDs rather than sequential integers (defense in depth).
- **All list endpoints follow the pagination contract in §0.5** unless explicitly noted otherwise (e.g. `GET /exams` returns its full small catalog unpaginated, since exam count is small and bounded).
- **All write endpoints that map to Technical Architecture §13's offline-outbox strategy** (`POST /pyq/attempt`, `PATCH /planner/task/:taskId`, `PATCH /users/:userId/preferences`) accept a client-generated idempotency key (`attemptId` or an equivalent) so retried offline-queued requests are always safe to replay.
- **Every endpoint's underlying repository query uses prepared statements exclusively** (Technical Architecture §10/§12) — no endpoint in this document should ever be implemented with string-concatenated SQL.
- **This document is the contract Postman/OpenAPI (Swagger) collections should be generated from** — recommended next step for implementation is authoring an `openapi.yaml` mirroring these 14 sections exactly, so the same source of truth drives both human documentation and auto-generated client/server stubs.

This API specification, together with the Design System, Information Architecture, User Journey, Technical Architecture, and UI Screen Specifications already produced, completes PrepGraph's full pre-build documentation set — frontend and backend are now both fully specified against the same shared vocabulary of screens, data, and endpoints.
