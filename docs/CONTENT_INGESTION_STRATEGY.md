# PrepGraph — Content Ingestion Strategy

Phase 1A, Task 5. Defines *how* real content enters the app's data layer —
not the content itself. No scraping, no fabricated URLs, no generated
questions; every record must answer "where did this come from?"

## Principle

Every content type below follows the same shape: **source → manual
verification → DTO → seed/import function → Drift table**. There is no
automated pipeline yet, by design — a human confirms each record before
it reaches a student, because wrong exam content is worse than missing
content.

## Source strategy by content type

| Content | Source(s) | Access method | Legal status | Update frequency |
|---|---|---|---|---|
| PYQs | tnpsc.gov.in official question papers/answer keys | Manual transcription from official PDF | Safe — official published exam content | Per exam cycle |
| Cutoff marks | tnpsc.gov.in result/notification PDFs | Manual entry, tagged with notification number | Safe — official published data | Per result announcement |
| Syllabus | tnpsc.gov.in notification PDFs | Manual entry | Safe — official published data | Per notification (infrequent) |
| Study materials (PDFs) | NCERT (ncert.nic.in), TN State Board (freely hosted), official TNPSC docs | Direct link to the official host, not re-hosted | Safe if linked, not mirrored | Rare |
| Study materials (books) | Commercial titles (e.g. Laxmikanth) | Link to purchase/library page only | Must not host/claim a free copy | N/A |
| YouTube lectures | Established TNPSC prep channels, individually verified | Manual search + verify link resolves + verify topic relevance | Safe to link; do not embed/download | As new verified links are found |

## Per-record metadata contract

Every ingested record must carry enough to answer "where did this come
from?" without opening a separate document:

- **Resources**: `sourceUrl`, `verifiedAt`, `verificationStatus`, `language` (added schema v3)
- **Cutoffs**: `sourceUrl`, `notificationNumber`, `verifiedAt` (added schema v3)
- **Questions**: `source` (free text — e.g. "TNPSC Group 2 2023 Prelims, official paper"), `verificationStatus`, `language` (added schema v3)

A record with `verificationStatus: 'unverified'` is real seed/placeholder
content, not yet confirmed against a primary source — the field exists so
the app (and this team) can always tell the two apart, including in a
future admin/ingestion UI.

## What ingestion is NOT, right now

- Not a scraper. Nothing crawls tnpsc.gov.in or any third-party site
  automatically.
- Not a YouTube Data API integration — no API key exists yet (explicit
  decision). Verified links come from manual search, one at a time.
- Not a backend. Ingestion today means: a developer adds a DTO entry to
  `seed_data.dart` (or the equivalent resource catalog function), sourced
  and verified by hand, and it ships with the next app build. `Phase 2`'s
  backend would let this happen without an app release, but the
  verification step stays human either way.

## Volume reality check

A usable PYQ bank needs hundreds to low-thousands of verified questions.
A meaningful resource catalog needs broad subject coverage, not a handful
of examples. This is a content-curation project measured in person-hours
of sourcing and verification, not an engineering sprint — the
architecture in this Phase 1A work is what makes that curation *safe to
add incrementally* (versioned, traceable, additive schema), not a
shortcut around doing it.
