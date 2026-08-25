import '../database/database.dart';
import '../dtos/content_dto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Seed data for the local database
/// Provides initial data for exams, subjects, topics, and questions
/// Based on docs/07_PrepGraph-Database-Schema.md and docs/06_PrepGraph_API_Documentation.md
class SeedData {
  static final _uuid = Uuid();

  /// Get seed exams
  static List<ExamDto> getExams() {
    return [
      ExamDto(
        examId: 'tnpsc-group2',
        examName: 'TNPSC Group 2',
        description: 'Tamil Nadu Public Service Commission Group 2 Examination',
        conductingBody: 'TNPSC',
        comingSoon: false,
        createdAt: DateTime.now(),
      ),
      ExamDto(
        examId: 'tnpsc-group4',
        examName: 'TNPSC Group 4',
        description: 'Tamil Nadu Public Service Commission Group 4 Examination',
        conductingBody: 'TNPSC',
        comingSoon: false,
        createdAt: DateTime.now(),
      ),
      ExamDto(
        examId: 'tnpsc-group1',
        examName: 'TNPSC Group 1',
        description: 'Tamil Nadu Public Service Commission Group 1 Examination',
        conductingBody: 'TNPSC',
        comingSoon: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Get seed subjects for TNPSC Group 2
  static List<SubjectDto> getSubjects() {
    return [
      SubjectDto(
        subjectId: 'subject-general-tamil',
        examId: 'tnpsc-group2',
        subjectName: 'General Tamil',
        importanceWeight: 0.25,
      ),
      SubjectDto(
        subjectId: 'subject-general-english',
        examId: 'tnpsc-group2',
        subjectName: 'General English',
        importanceWeight: 0.20,
      ),
      SubjectDto(
        subjectId: 'subject-general-studies',
        examId: 'tnpsc-group2',
        subjectName: 'General Studies',
        importanceWeight: 0.35,
      ),
      SubjectDto(
        subjectId: 'subject-aptitude',
        examId: 'tnpsc-group2',
        subjectName: 'Aptitude & Mental Ability',
        importanceWeight: 0.20,
      ),
    ];
  }

  /// Get seed topics for General Studies
  static List<TopicDto> getTopics() {
    return [
      // Indian Polity
      TopicDto(
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        parentTopicId: null,
        topicName: 'Indian Constitution',
        difficulty: 'medium',
        importanceScore: 0.95,
      ),
      TopicDto(
        topicId: 'topic-fundamental-rights',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-constitution',
        topicName: 'Fundamental Rights',
        difficulty: 'medium',
        importanceScore: 0.90,
      ),
      TopicDto(
        topicId: 'topic-directive-principles',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-constitution',
        topicName: 'Directive Principles',
        difficulty: 'medium',
        importanceScore: 0.85,
      ),
      // Indian Economy
      TopicDto(
        topicId: 'topic-indian-economy',
        subjectId: 'subject-general-studies',
        parentTopicId: null,
        topicName: 'Indian Economy',
        difficulty: 'medium',
        importanceScore: 0.90,
      ),
      TopicDto(
        topicId: 'topic-planning',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-economy',
        topicName: 'Five Year Plans',
        difficulty: 'easy',
        importanceScore: 0.75,
      ),
      // Tamil Nadu History
      TopicDto(
        topicId: 'topic-tn-history',
        subjectId: 'subject-general-studies',
        parentTopicId: null,
        topicName: 'Tamil Nadu History',
        difficulty: 'medium',
        importanceScore: 0.95,
      ),
      TopicDto(
        topicId: 'topic-ancient-tamil',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-tn-history',
        topicName: 'Ancient Tamil Kingdoms',
        difficulty: 'medium',
        importanceScore: 0.85,
      ),
      // Geography
      TopicDto(
        topicId: 'topic-geography',
        subjectId: 'subject-general-studies',
        parentTopicId: null,
        topicName: 'Geography',
        difficulty: 'easy',
        importanceScore: 0.80,
      ),
      TopicDto(
        topicId: 'topic-tn-geography',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-geography',
        topicName: 'Tamil Nadu Geography',
        difficulty: 'easy',
        importanceScore: 0.85,
      ),
      // Added Phase 1B: subject-general-tamil, subject-general-english and
      // subject-aptitude previously had zero topics — real syllabus
      // sections with nothing under them, which is exactly why the
      // Knowledge Graph appeared empty when browsing those subjects
      // (e.g. "General Tamil"). These three are genuine TNPSC exam
      // sections (verified: Prelims = 100 Language + 75 General Studies +
      // 25 Aptitude & Mental Ability questions), not invented topics —
      // this is deliberately minimal structure (one topic per subject),
      // not a claim of full syllabus coverage.
      TopicDto(
        topicId: 'topic-tamil-grammar-literature',
        subjectId: 'subject-general-tamil',
        parentTopicId: null,
        topicName: 'Tamil Grammar & Literature',
        difficulty: 'medium',
        importanceScore: 0.80,
      ),
      TopicDto(
        topicId: 'topic-english-grammar-usage',
        subjectId: 'subject-general-english',
        parentTopicId: null,
        topicName: 'English Grammar & Usage',
        difficulty: 'medium',
        importanceScore: 0.75,
      ),
      TopicDto(
        topicId: 'topic-aptitude-reasoning',
        subjectId: 'subject-aptitude',
        parentTopicId: null,
        topicName: 'Aptitude & Mental Ability',
        difficulty: 'medium',
        importanceScore: 0.80,
      ),
      TopicDto(
        topicId: 'topic-general-science',
        subjectId: 'subject-general-studies',
        parentTopicId: null,
        topicName: 'General Science',
        difficulty: 'medium',
        importanceScore: 0.75,
      ),
      TopicDto(
        topicId: 'topic-current-affairs',
        subjectId: 'subject-general-studies',
        parentTopicId: null,
        topicName: 'Current Affairs',
        difficulty: 'easy',
        importanceScore: 0.70,
      ),
      // Indian History is a real TNPSC General Studies syllabus unit that was
      // missing from this list — the only history topics were Tamil Nadu
      // scoped (topic-tn-history, topic-ancient-tamil), leaving national
      // history material with nowhere correct to sit.
      TopicDto(
        topicId: 'topic-indian-history',
        subjectId: 'subject-general-studies',
        parentTopicId: null,
        topicName: 'Indian History',
        difficulty: 'medium',
        importanceScore: 0.90,
      ),
    ];
  }

  /// Get seed concept relationships
  static List<ConceptRelationshipDto> getConceptRelationships() {
    return [
      ConceptRelationshipDto(
        relationId: _uuid.v4(),
        sourceTopicId: 'topic-fundamental-rights',
        targetTopicId: 'topic-directive-principles',
        relationshipType: 'complementary',
      ),
      ConceptRelationshipDto(
        relationId: _uuid.v4(),
        sourceTopicId: 'topic-indian-constitution',
        targetTopicId: 'topic-fundamental-rights',
        relationshipType: 'prerequisite',
      ),
      ConceptRelationshipDto(
        relationId: _uuid.v4(),
        sourceTopicId: 'topic-indian-economy',
        targetTopicId: 'topic-planning',
        relationshipType: 'contains',
      ),
    ];
  }

  /// Get seed questions
  /// 5 questions, all `verificationStatus: 'unverified'`. The content is
  /// factually accurate (checked: Article 14 = Right to Equality, Articles
  /// 19-22 = Right to Freedom, Part IV = Directive Principles, Second Five
  /// Year Plan = Mixed Economy — all correct general knowledge), but none
  /// of these are confirmed to have actually appeared in a real TNPSC
  /// paper — the `year` values are plausible, not sourced. This is
  /// illustrative seed content demonstrating the schema, not a PYQ bank.
  /// A genuine PYQ bank requires transcribing real papers from
  /// tnpsc.gov.in (see docs/CONTENT_INGESTION_STRATEGY.md) — not
  /// something a search-based pass can responsibly fabricate.
  ///
  /// Phase 1C attempted to source real, verifiable PYQs. Findings:
  /// tnpsc.gov.in/English/previous-questions.html is real and does list
  /// scanned original-paper PDFs for several exams (Group I, Group IV,
  /// VAO, etc.) but does NOT list Group 2/2A under that name; the site's
  /// answer-keys index (tnpsc.gov.in/English/answerkeys.html) likewise has
  /// no current Group 2/2A entries. One candidate PDF was fetched
  /// directly and did load (not a 404), but its content is a scanned
  /// image, not extractable text, and this environment has no PDF/OCR
  /// rendering available to transcribe it. Per the no-invention rule, zero
  /// questions were added or marked verified this phase — all 5 below are
  /// unchanged.
  static List<QuestionDto> getQuestions() {
    return [
      QuestionDto(
        questionId: 'q-001',
        examId: 'tnpsc-group2',
        subjectId: 'subject-general-studies',
        topicId: 'topic-fundamental-rights',
        year: 2023,
        questionText: 'Which Article of the Indian Constitution deals with Right to Equality?',
        optionA: 'Article 14',
        optionB: 'Article 19',
        optionC: 'Article 21',
        optionD: 'Article 32',
        correctAnswer: 'A',
        explanation: 'Article 14 of the Indian Constitution guarantees Right to Equality. It states that the State shall not deny to any person equality before the law or the equal protection of the laws within the territory of India.',
        difficulty: 'easy',
        createdAt: DateTime.now(),
        verificationStatus: 'unverified',
      ),
      QuestionDto(
        questionId: 'q-002',
        examId: 'tnpsc-group2',
        subjectId: 'subject-general-studies',
        topicId: 'topic-fundamental-rights',
        year: 2022,
        questionText: 'The Right to Freedom is covered under which Articles?',
        optionA: 'Articles 19-22',
        optionB: 'Articles 14-18',
        optionC: 'Articles 23-24',
        optionD: 'Articles 25-28',
        correctAnswer: 'A',
        explanation: 'Articles 19 to 22 of the Indian Constitution deal with the Right to Freedom. Article 19 guarantees six fundamental freedoms, while Articles 20, 21, and 22 provide protection in respect of conviction for offences, protection of life and personal liberty, and protection against arrest and detention.',
        difficulty: 'medium',
        createdAt: DateTime.now(),
        verificationStatus: 'unverified',
      ),
      QuestionDto(
        questionId: 'q-003',
        examId: 'tnpsc-group2',
        subjectId: 'subject-general-studies',
        topicId: 'topic-directive-principles',
        year: 2023,
        questionText: 'Directive Principles of State Policy are contained in which Part of the Constitution?',
        optionA: 'Part III',
        optionB: 'Part IV',
        optionC: 'Part V',
        optionD: 'Part VI',
        correctAnswer: 'B',
        explanation: 'Directive Principles of State Policy are contained in Part IV (Articles 36-51) of the Indian Constitution. They are non-justiciable in nature but are fundamental in the governance of the country.',
        difficulty: 'easy',
        createdAt: DateTime.now(),
        verificationStatus: 'unverified',
      ),
      QuestionDto(
        questionId: 'q-004',
        examId: 'tnpsc-group2',
        subjectId: 'subject-general-studies',
        topicId: 'topic-tn-history',
        year: 2022,
        questionText: 'Which dynasty ruled the ancient Tamil kingdom of Cheras?',
        optionA: 'Pandyas',
        optionB: 'Cheras',
        optionC: 'Cholas',
        optionD: 'Pallavas',
        correctAnswer: 'B',
        explanation: 'The Chera dynasty ruled the ancient Tamil kingdom of Cheras, which was located in present-day Kerala and parts of Tamil Nadu. They were one of the three ancient Tamil kingdoms along with Cholas and Pandyas.',
        difficulty: 'easy',
        createdAt: DateTime.now(),
        verificationStatus: 'unverified',
      ),
      QuestionDto(
        questionId: 'q-005',
        examId: 'tnpsc-group2',
        subjectId: 'subject-general-studies',
        topicId: 'topic-indian-economy',
        year: 2023,
        questionText: 'Which Five Year Plan introduced the concept of Mixed Economy?',
        optionA: 'First Five Year Plan',
        optionB: 'Second Five Year Plan',
        optionC: 'Third Five Year Plan',
        optionD: 'Fourth Five Year Plan',
        correctAnswer: 'B',
        explanation: 'The Second Five Year Plan (1956-61) introduced the concept of Mixed Economy in India. It was based on the Mahalanobis model and emphasized heavy industries and public sector development.',
        difficulty: 'medium',
        createdAt: DateTime.now(),
        verificationStatus: 'unverified',
      ),
    ];
  }

  /// Superseded by [getResourceCatalog] (Phase 1A/1B) — kept only so
  /// nothing silently disappears from version history. Not called by the
  /// seeder anymore, but not because of a topicId mismatch as originally
  /// noted here — correction: these topicIds ('topic-fundamental-rights'
  /// etc.) DO match real [getTopics] rows. The actual reason it was
  /// replaced is the thinner schema (no description/author/tags/etc.),
  /// which [ResourceCatalogDto] exists to hold. (Phase 1A's
  /// getResourceCatalog() initially used a *different*, fictional
  /// 'topic-1-1'-style scheme by mistake, inherited from the old
  /// ResourceRemoteDataSource — that was corrected in Phase 1B to use
  /// these same real topic slugs.)
  @Deprecated('Use getResourceCatalog() instead — see doc comment')
  static List<ResourceDto> getResources() {
    return [
      ResourceDto(
        resourceId: 'res-001',
        topicId: 'topic-fundamental-rights',
        title: 'NCERT - Indian Polity for Class XI',
        type: 'pdf',
        link: 'https://example.com/polity-ncert',
        averageRating: 4.5,
        ratingCount: 120,
      ),
      ResourceDto(
        resourceId: 'res-002',
        topicId: 'topic-fundamental-rights',
        title: 'M. Laxmikanth - Indian Polity',
        type: 'book',
        link: 'https://example.com/polity-laxmikanth',
        averageRating: 4.8,
        ratingCount: 350,
      ),
      ResourceDto(
        resourceId: 'res-003',
        topicId: 'topic-tn-history',
        title: 'Tamil Nadu State Board History Textbook',
        type: 'pdf',
        link: 'https://example.com/tn-history',
        averageRating: 4.3,
        ratingCount: 85,
      ),
      ResourceDto(
        resourceId: 'res-004',
        topicId: 'topic-indian-economy',
        title: 'Ramesh Singh - Indian Economy',
        type: 'book',
        link: 'https://example.com/economy-ramesh',
        averageRating: 4.6,
        ratingCount: 200,
      ),
    ];
  }

  /// Resource catalog — Phase 1A consolidation, topic/subject IDs
  /// corrected in Phase 1B. This is the single real source of truth for
  /// the Resources module (see database.dart's schema v3 migration for
  /// why two independent catalogs existed before this). Every entry's
  /// topicId/subjectId matches a real row from [getTopics]/[getSubjects]
  /// — Phase 1A shipped this pointing at a fictional 'topic-1-1'/
  /// 'subject-1' scheme inherited from the old ResourceRemoteDataSource,
  /// which orphaned every resource exactly the way the old getResources()
  /// seed did; Phase 1B remapped everything to the real topic/subject
  /// slugs and added 3 real topics (General Science, Aptitude & Mental
  /// Ability, Current Affairs) since those syllabus areas had zero
  /// topics to attach resources to. Verified entries as of Phase 1C
  /// (2026-08-17): res-4, res-5, res-21, res-22 (YouTube, live-search
  /// checked 2026-08-04), res-12, res-13 (official/govt websites, checked
  /// 2026-08-04), res-6 (official TNPSC syllabus PDF, link confirmed to
  /// actually resolve on 2026-08-17 after the original guessed URL was
  /// found to be a fabricated 404 — see res-6's own comment). The
  /// remaining 15 entries still carry literal example.com placeholder
  /// links — real free/official equivalents were not found for them in
  /// Phase 1C (see docs/CURRENT_ARCHITECTURE.md's Phase 1C section); they
  /// are kept, not deleted, but must never be treated as real by the UI —
  /// that's what `verificationStatus` on each row is for: it's queryable,
  /// not just a comment.
  static List<ResourceCatalogDto> getResourceCatalog() {
    final verifiedNow = DateTime(2026, 8, 4);
    return [
      ResourceCatalogDto(
        resourceId: 'res-1',
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        title: 'Indian Polity - Complete Notes',
        description: 'Comprehensive notes on Indian Constitution, Fundamental Rights, Directive Principles, and Union-State relations. Covers all TNPSC Group 2 and Group 4 syllabus topics.',
        type: 'pdf',
        link: 'https://example.com/polity-notes.pdf',
        sourceUrl: 'https://example.com/polity-notes.pdf',
        thumbnailUrl: 'https://example.com/polity-thumb.jpg',
        author: 'TNPSC Academy',
        pageCount: 120,
        difficulty: 'intermediate',
        averageRating: 4.5,
        viewCount: 12500,
        publishedDate: DateTime(2024, 1, 15),
        tags: const ['polity', 'constitution', 'fundamental rights'],
        isOfficial: false,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-2',
        topicId: 'topic-indian-economy',
        subjectId: 'subject-general-studies',
        title: 'Indian Economy - Quick Revision',
        description: 'Quick revision notes for Indian Economy covering GDP, inflation, banking, and fiscal policy. Perfect for last-minute preparation.',
        type: 'pdf',
        link: 'https://example.com/economy-notes.pdf',
        sourceUrl: 'https://example.com/economy-notes.pdf',
        thumbnailUrl: 'https://example.com/economy-thumb.jpg',
        author: 'Success Academy',
        pageCount: 85,
        difficulty: 'beginner',
        averageRating: 4.2,
        viewCount: 8900,
        publishedDate: DateTime(2024, 2, 20),
        tags: const ['economy', 'gdp', 'banking'],
        isOfficial: false,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-3',
        topicId: 'topic-tn-history',
        subjectId: 'subject-general-studies',
        title: 'Tamil Nadu History - Part 1',
        description: 'Ancient Tamil Nadu history covering Sangam period, Pallavas, Cholas, and Pandya dynasties. Based on NCERT and state board textbooks.',
        type: 'pdf',
        link: 'https://example.com/tn-history-1.pdf',
        sourceUrl: 'https://example.com/tn-history-1.pdf',
        thumbnailUrl: 'https://example.com/tn-history-thumb.jpg',
        author: 'State Board',
        pageCount: 95,
        difficulty: 'intermediate',
        averageRating: 4.7,
        viewCount: 15200,
        publishedDate: DateTime(2024, 3, 10),
        tags: const ['history', 'tamil nadu', 'sangam'],
        isOfficial: true,
        isDownloadable: true,
      ),
      // Real, individually-verified YouTube links (live search, 2026-08-04).
      ResourceCatalogDto(
        resourceId: 'res-4',
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        title: 'TNPSC Indian Polity Book — Tamil Medium',
        description: 'Tamil-medium video lecture covering Indian Polity for TNPSC Group 1/2/2A preparation.',
        type: 'youtube',
        link: 'https://www.youtube.com/watch?v=VklpPj26wG4',
        sourceUrl: 'https://www.youtube.com/watch?v=VklpPj26wG4',
        thumbnailUrl: 'https://img.youtube.com/vi/VklpPj26wG4/hqdefault.jpg',
        author: 'TNPSC prep channel (Tamil medium)',
        difficulty: 'intermediate',
        publishedDate: DateTime(2024, 1, 5),
        tags: const ['polity', 'constitution', 'video', 'tamil'],
        language: 'tamil',
        verifiedAt: verifiedNow,
        verificationStatus: 'verified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-5',
        topicId: 'topic-geography',
        subjectId: 'subject-general-studies',
        title: 'TNPSC Group 2/2A Mains — Geography',
        description: 'Geography lecture targeted at TNPSC Group 2/2A Mains preparation.',
        type: 'youtube',
        link: 'https://www.youtube.com/watch?v=_SABquvYjlg',
        sourceUrl: 'https://www.youtube.com/watch?v=_SABquvYjlg',
        thumbnailUrl: 'https://img.youtube.com/vi/_SABquvYjlg/hqdefault.jpg',
        author: 'TNPSC prep channel',
        difficulty: 'beginner',
        publishedDate: DateTime(2024, 2, 15),
        tags: const ['geography', 'maps', 'physical features'],
        language: 'english',
        verifiedAt: verifiedNow,
        verificationStatus: 'verified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-21',
        topicId: 'topic-tn-history',
        subjectId: 'subject-general-studies',
        title: 'TNPSC History Classes — Tamil (Playlist)',
        description: 'Full playlist of Tamil-medium history classes for TNPSC preparation.',
        type: 'youtube',
        link: 'https://www.youtube.com/playlist?list=PLdKp4Fj-CcfoC4t_K1Qh9yyVMM97YTZVT',
        sourceUrl: 'https://www.youtube.com/playlist?list=PLdKp4Fj-CcfoC4t_K1Qh9yyVMM97YTZVT',
        author: 'TNPSC prep channel (Tamil medium)',
        difficulty: 'beginner',
        publishedDate: DateTime(2024, 1, 1),
        tags: const ['history', 'video', 'tamil', 'playlist'],
        language: 'tamil',
        verifiedAt: verifiedNow,
        verificationStatus: 'verified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-22',
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        title: 'TNPSC GK Times — Full Channel (Tamil + English)',
        description: 'Channel covering Polity, History, Geography, Economy and current affairs shortcuts for TNPSC — browse the channel for the specific topic you need.',
        type: 'youtube',
        link: 'https://www.youtube.com/channel/UCliCXg93GpzBtECq_wxtmdg',
        sourceUrl: 'https://www.youtube.com/channel/UCliCXg93GpzBtECq_wxtmdg',
        author: 'TNPSC GK Times',
        difficulty: 'beginner',
        publishedDate: DateTime(2024, 1, 1),
        tags: const ['channel', 'general studies', 'tamil', 'english'],
        language: 'both',
        verifiedAt: verifiedNow,
        verificationStatus: 'verified',
      ),
      // Phase 1C: the original link ('.../group2-syllabus.pdf') was a
      // guessed, non-existent URL — confirmed 404 on direct fetch
      // (2026-08-17), despite sitting on the real tnpsc.gov.in domain. The
      // URL below was found via the official syllabus index
      // (tnpsc.gov.in/English/syllabus.html, code 495: "Combined Civil
      // Services (Preliminary) Examination — Group-II and IIA Services")
      // and confirmed to actually resolve (200, real PDF returned) on the
      // same date. Its exact content wasn't transcribed (no PDF text
      // extraction available in this environment), but the URL, domain,
      // and syllabus code independently match what multiple sources report
      // for this exam — sufficient to verify the *resource itself* (a
      // link), which is a lower bar than verifying transcribed content.
      ResourceCatalogDto(
        resourceId: 'res-6',
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        title: 'TNPSC Group 2/2A Prelims Syllabus (Official)',
        description: 'Official TNPSC syllabus (code 495) for the Combined Civil Services (Preliminary) Examination — Group-II and IIA Services.',
        type: 'governmentMaterial',
        link: 'https://tnpsc.gov.in/static_pdf/syllabus/495_Group II and IIA prelims.pdf',
        sourceUrl: 'https://tnpsc.gov.in/static_pdf/syllabus/495_Group II and IIA prelims.pdf',
        author: 'TNPSC',
        difficulty: 'beginner',
        publishedDate: DateTime(2023, 11, 1),
        tags: const ['syllabus', 'official', 'group 2'],
        isOfficial: true,
        isDownloadable: true,
        verifiedAt: DateTime(2026, 8, 17),
        verificationStatus: 'verified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-7',
        topicId: 'topic-current-affairs',
        subjectId: 'subject-general-studies',
        title: 'Tamil Nadu Government Schemes PDF',
        description: 'Complete compilation of Tamil Nadu government schemes for TNPSC preparation. Updated with latest schemes.',
        type: 'governmentMaterial',
        link: 'https://example.com/tn-schemes.pdf',
        sourceUrl: 'https://example.com/tn-schemes.pdf',
        thumbnailUrl: 'https://example.com/tn-schemes.jpg',
        author: 'Government of Tamil Nadu',
        pageCount: 200,
        difficulty: 'intermediate',
        averageRating: 4.9,
        viewCount: 28000,
        publishedDate: DateTime(2024, 3, 1),
        tags: const ['schemes', 'tamil nadu', 'government'],
        isOfficial: true,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-8',
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        title: 'TNPSC Group 2 Previous Papers (2018-2023)',
        description: 'Collection of TNPSC Group 2 previous year question papers from 2018 to 2023 with answer keys.',
        type: 'previousPapers',
        link: 'https://example.com/group2-papers.pdf',
        sourceUrl: 'https://example.com/group2-papers.pdf',
        thumbnailUrl: 'https://example.com/papers-thumb.jpg',
        author: 'TNPSC',
        pageCount: 350,
        difficulty: 'advanced',
        averageRating: 4.8,
        viewCount: 42000,
        publishedDate: DateTime(2024, 1, 20),
        tags: const ['previous papers', 'group 2', 'answer key'],
        isOfficial: true,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-9',
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        title: 'TNPSC Group 4 Previous Papers (2019-2023)',
        description: 'Complete set of TNPSC Group 4 previous year question papers with detailed solutions.',
        type: 'previousPapers',
        link: 'https://example.com/group4-papers.pdf',
        sourceUrl: 'https://example.com/group4-papers.pdf',
        thumbnailUrl: 'https://example.com/group4-papers.jpg',
        author: 'TNPSC',
        pageCount: 280,
        difficulty: 'intermediate',
        averageRating: 4.7,
        viewCount: 38000,
        publishedDate: DateTime(2024, 2, 10),
        tags: const ['previous papers', 'group 4', 'solutions'],
        isOfficial: true,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-10',
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        title: 'Indian Polity by M. Laxmikanth',
        description: 'The most recommended book for Indian Polity for competitive exams. Covers all aspects of Indian Constitution.',
        type: 'book',
        link: 'https://example.com/laxmikanth-polity',
        sourceUrl: 'https://example.com/laxmikanth-polity',
        thumbnailUrl: 'https://example.com/laxmikanth-cover.jpg',
        author: 'M. Laxmikanth',
        pageCount: 650,
        difficulty: 'advanced',
        averageRating: 4.9,
        viewCount: 75000,
        publishedDate: DateTime(2023, 6, 1),
        tags: const ['polity', 'constitution', 'book'],
        isOfficial: false,
        isDownloadable: false,
      ),
      ResourceCatalogDto(
        resourceId: 'res-11',
        topicId: 'topic-tn-history',
        subjectId: 'subject-general-studies',
        title: 'Tamil Nadu History - State Board Textbook',
        description: 'Official Tamil Nadu State Board history textbook for Class 11 and 12. Essential for TNPSC preparation.',
        type: 'book',
        link: 'https://example.com/tn-history-textbook',
        sourceUrl: 'https://example.com/tn-history-textbook',
        thumbnailUrl: 'https://example.com/tn-textbook-cover.jpg',
        author: 'Tamil Nadu Textbook Corporation',
        pageCount: 450,
        difficulty: 'intermediate',
        averageRating: 4.8,
        viewCount: 55000,
        publishedDate: DateTime(2023, 5, 1),
        tags: const ['history', 'tamil nadu', 'textbook'],
        isOfficial: true,
        isDownloadable: false,
      ),
      ResourceCatalogDto(
        resourceId: 'res-12',
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        title: 'TNPSC Official Website',
        description: 'Official TNPSC website for notifications, syllabus, results, and exam updates.',
        type: 'website',
        link: 'https://tnpsc.gov.in',
        sourceUrl: 'https://tnpsc.gov.in',
        thumbnailUrl: 'https://example.com/tnpsc-web.jpg',
        author: 'TNPSC',
        difficulty: 'beginner',
        averageRating: 5.0,
        viewCount: 100000,
        publishedDate: DateTime(2020, 1, 1),
        tags: const ['official', 'notifications', 'updates'],
        isOfficial: true,
        isDownloadable: false,
        verifiedAt: verifiedNow,
        verificationStatus: 'verified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-13',
        topicId: 'topic-current-affairs',
        subjectId: 'subject-general-studies',
        title: 'PIB Tamil Nadu',
        description: 'Press Information Bureau Tamil Nadu for latest government news and updates relevant for current affairs.',
        type: 'website',
        link: 'https://pib.gov.in/region/tamil-nadu',
        sourceUrl: 'https://pib.gov.in/region/tamil-nadu',
        thumbnailUrl: 'https://example.com/pib-web.jpg',
        author: 'PIB',
        difficulty: 'intermediate',
        averageRating: 4.6,
        viewCount: 25000,
        publishedDate: DateTime(2020, 1, 1),
        tags: const ['current affairs', 'government', 'news'],
        isOfficial: true,
        isDownloadable: false,
        verifiedAt: verifiedNow,
        verificationStatus: 'verified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-14',
        topicId: 'topic-general-science',
        subjectId: 'subject-general-studies',
        title: 'General Science - Physics Notes',
        description: 'Physics notes covering mechanics, heat, light, sound, and electricity. Based on TNPSC syllabus.',
        type: 'pdf',
        link: 'https://example.com/physics-notes.pdf',
        sourceUrl: 'https://example.com/physics-notes.pdf',
        thumbnailUrl: 'https://example.com/physics-thumb.jpg',
        author: 'Science Academy',
        pageCount: 110,
        difficulty: 'intermediate',
        averageRating: 4.4,
        viewCount: 9800,
        publishedDate: DateTime(2024, 2, 5),
        tags: const ['science', 'physics', 'mechanics'],
        isOfficial: false,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-15',
        topicId: 'topic-general-science',
        subjectId: 'subject-general-studies',
        title: 'General Science - Chemistry Notes',
        description: 'Chemistry notes covering periodic table, chemical reactions, acids and bases, and organic chemistry basics.',
        type: 'pdf',
        link: 'https://example.com/chemistry-notes.pdf',
        sourceUrl: 'https://example.com/chemistry-notes.pdf',
        thumbnailUrl: 'https://example.com/chemistry-thumb.jpg',
        author: 'Science Academy',
        pageCount: 95,
        difficulty: 'intermediate',
        averageRating: 4.3,
        viewCount: 8700,
        publishedDate: DateTime(2024, 2, 8),
        tags: const ['science', 'chemistry', 'periodic table'],
        isOfficial: false,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-16',
        topicId: 'topic-current-affairs',
        subjectId: 'subject-general-studies',
        title: 'Current Affairs - January 2024',
        description: 'Monthly current affairs compilation for January 2024 covering national, international, and Tamil Nadu news.',
        type: 'pdf',
        link: 'https://example.com/ca-jan-2024.pdf',
        sourceUrl: 'https://example.com/ca-jan-2024.pdf',
        thumbnailUrl: 'https://example.com/ca-thumb.jpg',
        author: 'Current Affairs Hub',
        pageCount: 75,
        difficulty: 'beginner',
        averageRating: 4.5,
        viewCount: 18500,
        publishedDate: DateTime(2024, 2, 1),
        tags: const ['current affairs', 'monthly', '2024'],
        isOfficial: false,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-17',
        topicId: 'topic-aptitude-reasoning',
        subjectId: 'subject-aptitude',
        title: 'Reasoning Ability - Complete Guide',
        description: 'Complete guide for reasoning ability covering verbal and non-verbal reasoning with solved examples.',
        type: 'pdf',
        link: 'https://example.com/reasoning-guide.pdf',
        sourceUrl: 'https://example.com/reasoning-guide.pdf',
        thumbnailUrl: 'https://example.com/reasoning-thumb.jpg',
        author: 'Reasoning Master',
        pageCount: 180,
        difficulty: 'intermediate',
        averageRating: 4.6,
        viewCount: 14500,
        publishedDate: DateTime(2024, 1, 25),
        tags: const ['reasoning', 'verbal', 'non-verbal'],
        isOfficial: false,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-18',
        topicId: 'topic-aptitude-reasoning',
        subjectId: 'subject-aptitude',
        title: 'Quantitative Aptitude - Shortcuts & Tricks',
        description: 'Quantitative aptitude shortcuts and tricks for faster problem solving. Covers all TNPSC topics.',
        type: 'pdf',
        link: 'https://example.com/aptitude-tricks.pdf',
        sourceUrl: 'https://example.com/aptitude-tricks.pdf',
        thumbnailUrl: 'https://example.com/aptitude-thumb.jpg',
        author: 'Math Wizard',
        pageCount: 150,
        difficulty: 'advanced',
        averageRating: 4.7,
        viewCount: 16800,
        publishedDate: DateTime(2024, 2, 12),
        tags: const ['aptitude', 'math', 'shortcuts'],
        isOfficial: false,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-19',
        topicId: 'topic-tn-geography',
        subjectId: 'subject-general-studies',
        title: 'Geography of Tamil Nadu',
        description: 'Detailed notes on Tamil Nadu geography covering physical features, rivers, districts, and climate.',
        type: 'pdf',
        link: 'https://example.com/tn-geography.pdf',
        sourceUrl: 'https://example.com/tn-geography.pdf',
        thumbnailUrl: 'https://example.com/tn-geo-thumb.jpg',
        author: 'Geo Master',
        pageCount: 88,
        difficulty: 'intermediate',
        averageRating: 4.5,
        viewCount: 11200,
        publishedDate: DateTime(2024, 3, 5),
        tags: const ['geography', 'tamil nadu', 'districts'],
        isOfficial: false,
        isDownloadable: true,
      ),
      ResourceCatalogDto(
        resourceId: 'res-20',
        topicId: 'topic-geography',
        subjectId: 'subject-general-studies',
        title: 'Indian Geography - Complete Notes',
        description: 'Complete Indian geography notes covering physical features, climate, rivers, mountains, and states.',
        type: 'pdf',
        link: 'https://example.com/india-geography.pdf',
        sourceUrl: 'https://example.com/india-geography.pdf',
        thumbnailUrl: 'https://example.com/india-geo-thumb.jpg',
        author: 'Geo Master',
        pageCount: 135,
        difficulty: 'intermediate',
        averageRating: 4.6,
        viewCount: 13500,
        publishedDate: DateTime(2024, 2, 28),
        tags: const ['geography', 'india', 'physical features'],
        isOfficial: false,
        isDownloadable: true,
      ),

      // ---- Tamil-medium TNPSC coaching lectures, supplied by the user ----
      // Real third-party coaching channels, not TNPSC official, so every one
      // carries isOfficial: false. URLs are stored clean (no ?si= tracking
      // params, youtu.be normalised to youtube.com/watch?v=) so the YouTube
      // app intent resolves reliably.
      //
      // verificationStatus stays 'unverified' until each link has actually
      // been opened on a device — only the playlist below was confirmed by
      // fetch. Note some cover Group 1 / Group 4 rather than this build's
      // Group 2: that's stated in the title AND description rather than
      // silently presented as Group 2 material.
      ResourceCatalogDto(
        resourceId: 'res-23',
        topicId: 'topic-indian-economy',
        subjectId: 'subject-general-studies',
        title: 'Economics — TNPSC (Tamil)',
        description: 'Tamil-medium Economics session for TNPSC preparation.',
        type: 'youtube',
        link: 'https://www.youtube.com/live/nwLZ914O6FI',
        sourceUrl: 'https://www.youtube.com/live/nwLZ914O6FI',
        author: 'TNPSC coaching channel (Tamil medium)',
        difficulty: 'intermediate',
        tags: const ['economy', 'video', 'tamil'],
        language: 'tamil',
        isOfficial: false,
      ),
      ResourceCatalogDto(
        resourceId: 'res-24',
        topicId: 'topic-aptitude-reasoning',
        subjectId: 'subject-aptitude',
        title: 'Maths / Aptitude — TNPSC (Tamil)',
        description: 'Tamil-medium aptitude and mental ability session for TNPSC.',
        type: 'youtube',
        link: 'https://www.youtube.com/live/Rj8F1dWzVkg',
        sourceUrl: 'https://www.youtube.com/live/Rj8F1dWzVkg',
        author: 'TNPSC coaching channel (Tamil medium)',
        difficulty: 'intermediate',
        tags: const ['aptitude', 'maths', 'video', 'tamil'],
        language: 'tamil',
        isOfficial: false,
      ),
      ResourceCatalogDto(
        resourceId: 'res-25',
        topicId: 'topic-indian-economy',
        subjectId: 'subject-general-studies',
        title: 'Indian Economy — TNPSC Group 1 (Tamil)',
        description:
            'Group 1 level material. The syllabus overlaps Group 2 General Studies, but it is pitched at Group 1 depth.',
        type: 'youtube',
        link: 'https://www.youtube.com/watch?v=rzNSnTQOrlE',
        sourceUrl: 'https://www.youtube.com/watch?v=rzNSnTQOrlE',
        author: 'TNPSC coaching channel (Tamil medium)',
        difficulty: 'advanced',
        tags: const ['economy', 'group 1', 'video', 'tamil'],
        language: 'tamil',
        isOfficial: false,
      ),
      ResourceCatalogDto(
        resourceId: 'res-26',
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        title: 'Indian Polity — TNPSC Group 1 (Tamil)',
        description:
            'Group 1 level material. The polity syllabus overlaps Group 2 General Studies, but it is pitched at Group 1 depth.',
        type: 'youtube',
        link: 'https://www.youtube.com/watch?v=22TT840pMf4',
        sourceUrl: 'https://www.youtube.com/watch?v=22TT840pMf4',
        author: 'TNPSC coaching channel (Tamil medium)',
        difficulty: 'advanced',
        tags: const ['polity', 'constitution', 'group 1', 'video', 'tamil'],
        language: 'tamil',
        isOfficial: false,
      ),
      ResourceCatalogDto(
        resourceId: 'res-27',
        topicId: 'topic-geography',
        subjectId: 'subject-general-studies',
        title: 'Geography — TNPSC Prelims (Tamil)',
        description: 'Tamil-medium Geography session for TNPSC Prelims preparation.',
        type: 'youtube',
        link: 'https://www.youtube.com/watch?v=sYCDWyzxU2Q',
        sourceUrl: 'https://www.youtube.com/watch?v=sYCDWyzxU2Q',
        author: 'TNPSC coaching channel (Tamil medium)',
        difficulty: 'intermediate',
        tags: const ['geography', 'prelims', 'video', 'tamil'],
        language: 'tamil',
        isOfficial: false,
      ),
      ResourceCatalogDto(
        resourceId: 'res-28',
        topicId: 'topic-english-grammar-usage',
        subjectId: 'subject-general-english',
        title: 'General English — TNPSC Group 4 (Tamil)',
        description:
            'Group 4 level material. General English fundamentals still apply to Group 2, but it is pitched at Group 4 depth.',
        type: 'youtube',
        link: 'https://www.youtube.com/watch?v=80D9jD1w8YA',
        sourceUrl: 'https://www.youtube.com/watch?v=80D9jD1w8YA',
        author: 'TNPSC coaching channel (Tamil medium)',
        difficulty: 'beginner',
        tags: const ['english', 'grammar', 'group 4', 'video', 'tamil'],
        language: 'tamil',
        isOfficial: false,
      ),
      // The one link in this batch whose title was confirmed by fetching the
      // page ("History & Culture of India | TNPSC Group 1 Prelims", AIM TN,
      // 22 videos), so it is marked verified where the others are not.
      // Filed under the newly added topic-indian-history rather than
      // topic-tn-history: the playlist is national in scope, and filing it
      // under Tamil Nadu History would misrepresent what it teaches.
      ResourceCatalogDto(
        resourceId: 'res-29',
        topicId: 'topic-indian-history',
        subjectId: 'subject-general-studies',
        title: 'History & Culture of India — TNPSC Prelims (AIM TN, 22 videos)',
        description:
            '22-video Tamil-medium playlist covering Indian history and culture. Recorded for Group 1 Prelims; the history syllabus overlaps Group 2 General Studies.',
        type: 'youtube',
        link: 'https://www.youtube.com/playlist?list=PLbzZaesUcQfuBkViGwqToU-LT-72Eh5PE',
        sourceUrl: 'https://www.youtube.com/playlist?list=PLbzZaesUcQfuBkViGwqToU-LT-72Eh5PE',
        author: 'AIM TN',
        difficulty: 'intermediate',
        tags: const ['history', 'culture', 'playlist', 'video', 'tamil'],
        language: 'tamil',
        verifiedAt: DateTime(2026, 8, 20),
        verificationStatus: 'verified',
        isOfficial: false,
      ),
    ];
  }

  /// Get seed cutoff data
  ///
  /// Five years (2019-2023) across all seven TNPSC reservation categories
  /// (OC, BC, BCM, MBC/DNC, SC, SCA, ST) — the category filter chips and
  /// year filter on the Historical Cutoffs / Cutoff Intelligence screens
  /// are derived directly from whichever years/categories exist here, so
  /// this is the actual source of the trend charts, not a display concern.
  /// The year-over-year movement (rising 2019-2022, dipping in 2023) is a
  /// deliberately non-monotonic, realistic pattern rather than a straight
  /// line, since real cutoffs move with paper difficulty and applicant
  /// pool size each year.
  ///
  /// NOT VERIFIED against an official TNPSC source — every row defaults to
  /// `verificationStatus: 'unverified'` (see [CutoffDatumDto]). Phase 1B
  /// made two genuine attempts to source real figures: a general web
  /// search returned only vague ranges ("140-150 expected"), and a more
  /// specific fetch found a structured third-party table whose 2019 OC
  /// figure (161) directly conflicts with this seed's 2019 OC figure
  /// (175). Neither source is tnpsc.gov.in itself, so neither was used to
  /// overwrite the other — that would just trade one unverified number
  /// for a different unverified number. This data is kept (not deleted)
  /// because Cutoff Intelligence's trend/volatility computations are real
  /// and demonstrable over *some* dataset, and removing it would break a
  /// working, demoed feature — but it must never be described as official
  /// or verified. Getting real figures requires the actual TNPSC result/
  /// notification PDF, not a search-based reconstruction.
  ///
  /// Phase 1C made a further attempt: tnpsc.gov.in's own site navigation
  /// was probed directly (results/cutoff index pages) rather than relying
  /// on search snippets. No stable, guessable results/cutoff archive page
  /// was found — every reachable URL either 404'd or led back to
  /// third-party aggregator coverage of results, never a primary TNPSC
  /// cutoff document. This reconfirms Phase 1B's finding rather than
  /// changing it. All 35 rows below are unchanged and remain unverified.
  static List<CutoffDatumDto> getCutoffData() {
    return [
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2019-oc',
        examId: 'tnpsc-group2',
        year: 2019,
        category: 'OC',
        cutoffMark: 175.0,
        vacancyCount: 55,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2019-bc',
        examId: 'tnpsc-group2',
        year: 2019,
        category: 'BC',
        cutoffMark: 168.0,
        vacancyCount: 32,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2019-bcm',
        examId: 'tnpsc-group2',
        year: 2019,
        category: 'BCM',
        cutoffMark: 165.0,
        vacancyCount: 14,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2019-mbc',
        examId: 'tnpsc-group2',
        year: 2019,
        category: 'MBC',
        cutoffMark: 163.0,
        vacancyCount: 27,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2019-sc',
        examId: 'tnpsc-group2',
        year: 2019,
        category: 'SC',
        cutoffMark: 155.0,
        vacancyCount: 22,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2019-sca',
        examId: 'tnpsc-group2',
        year: 2019,
        category: 'SCA',
        cutoffMark: 148.0,
        vacancyCount: 9,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2019-st',
        examId: 'tnpsc-group2',
        year: 2019,
        category: 'ST',
        cutoffMark: 142.0,
        vacancyCount: 11,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2020-oc',
        examId: 'tnpsc-group2',
        year: 2020,
        category: 'OC',
        cutoffMark: 179.0,
        vacancyCount: 48,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2020-bc',
        examId: 'tnpsc-group2',
        year: 2020,
        category: 'BC',
        cutoffMark: 172.0,
        vacancyCount: 29,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2020-bcm',
        examId: 'tnpsc-group2',
        year: 2020,
        category: 'BCM',
        cutoffMark: 169.0,
        vacancyCount: 11,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2020-mbc',
        examId: 'tnpsc-group2',
        year: 2020,
        category: 'MBC',
        cutoffMark: 167.0,
        vacancyCount: 24,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2020-sc',
        examId: 'tnpsc-group2',
        year: 2020,
        category: 'SC',
        cutoffMark: 158.0,
        vacancyCount: 19,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2020-sca',
        examId: 'tnpsc-group2',
        year: 2020,
        category: 'SCA',
        cutoffMark: 151.0,
        vacancyCount: 8,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2020-st',
        examId: 'tnpsc-group2',
        year: 2020,
        category: 'ST',
        cutoffMark: 145.0,
        vacancyCount: 10,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2021-oc',
        examId: 'tnpsc-group2',
        year: 2021,
        category: 'OC',
        cutoffMark: 183.0,
        vacancyCount: 52,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2021-bc',
        examId: 'tnpsc-group2',
        year: 2021,
        category: 'BC',
        cutoffMark: 176.0,
        vacancyCount: 31,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2021-bcm',
        examId: 'tnpsc-group2',
        year: 2021,
        category: 'BCM',
        cutoffMark: 173.0,
        vacancyCount: 13,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2021-mbc',
        examId: 'tnpsc-group2',
        year: 2021,
        category: 'MBC',
        cutoffMark: 171.0,
        vacancyCount: 26,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2021-sc',
        examId: 'tnpsc-group2',
        year: 2021,
        category: 'SC',
        cutoffMark: 162.0,
        vacancyCount: 21,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2021-sca',
        examId: 'tnpsc-group2',
        year: 2021,
        category: 'SCA',
        cutoffMark: 155.0,
        vacancyCount: 9,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2021-st',
        examId: 'tnpsc-group2',
        year: 2021,
        category: 'ST',
        cutoffMark: 149.0,
        vacancyCount: 11,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2023-oc',
        examId: 'tnpsc-group2',
        year: 2023,
        category: 'OC',
        cutoffMark: 185.0,
        vacancyCount: 50,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2023-bc',
        examId: 'tnpsc-group2',
        year: 2023,
        category: 'BC',
        cutoffMark: 178.0,
        vacancyCount: 30,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2023-bcm',
        examId: 'tnpsc-group2',
        year: 2023,
        category: 'BCM',
        cutoffMark: 176.0,
        vacancyCount: 12,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2023-mbc',
        examId: 'tnpsc-group2',
        year: 2023,
        category: 'MBC',
        cutoffMark: 175.0,
        vacancyCount: 25,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2023-sc',
        examId: 'tnpsc-group2',
        year: 2023,
        category: 'SC',
        cutoffMark: 165.0,
        vacancyCount: 20,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2023-sca',
        examId: 'tnpsc-group2',
        year: 2023,
        category: 'SCA',
        cutoffMark: 160.0,
        vacancyCount: 8,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2023-st',
        examId: 'tnpsc-group2',
        year: 2023,
        category: 'ST',
        cutoffMark: 155.0,
        vacancyCount: 10,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2022-oc',
        examId: 'tnpsc-group2',
        year: 2022,
        category: 'OC',
        cutoffMark: 190.0,
        vacancyCount: 45,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2022-bc',
        examId: 'tnpsc-group2',
        year: 2022,
        category: 'BC',
        cutoffMark: 182.0,
        vacancyCount: 28,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2022-bcm',
        examId: 'tnpsc-group2',
        year: 2022,
        category: 'BCM',
        cutoffMark: 180.0,
        vacancyCount: 10,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2022-mbc',
        examId: 'tnpsc-group2',
        year: 2022,
        category: 'MBC',
        cutoffMark: 179.0,
        vacancyCount: 22,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2022-sc',
        examId: 'tnpsc-group2',
        year: 2022,
        category: 'SC',
        cutoffMark: 170.0,
        vacancyCount: 18,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2022-sca',
        examId: 'tnpsc-group2',
        year: 2022,
        category: 'SCA',
        cutoffMark: 164.0,
        vacancyCount: 7,
      ),
      CutoffDatumDto(
        cutoffId: 'cutoff-tnpsc2-2022-st',
        examId: 'tnpsc-group2',
        year: 2022,
        category: 'ST',
        cutoffMark: 158.0,
        vacancyCount: 9,
      ),
    ];
  }

  /// Seed all data to database
  static Future<void> seedDatabase(PrepGraphDatabase database) async {
    await database.transaction(() async {
      // Seed Exams
      for (final exam in getExams()) {
        try {
          await database.into(database.exams).insert(
            ExamsCompanion(
              examId: Value(exam.examId),
              examName: Value(exam.examName),
              description: Value(exam.description),
              conductingBody: Value(exam.conductingBody),
              comingSoon: Value(exam.comingSoon),
              createdAt: Value(exam.createdAt),
            ),
          );
        } catch (_) {
          // Ignore if already exists
        }
      }

      // Seed Subjects
      for (final subject in getSubjects()) {
        try {
          await database.into(database.subjects).insert(
            SubjectsCompanion(
              subjectId: Value(subject.subjectId),
              examId: Value(subject.examId),
              subjectName: Value(subject.subjectName),
              importanceWeight: Value(subject.importanceWeight),
            ),
          );
        } catch (_) {
          // Ignore if already exists
        }
      }

      // Seed Topics
      for (final topic in getTopics()) {
        try {
          await database.into(database.topics).insert(
            TopicsCompanion(
              topicId: Value(topic.topicId),
              subjectId: Value(topic.subjectId),
              topicName: Value(topic.topicName),
              difficulty: Value(topic.difficulty),
              importanceScore: Value(topic.importanceScore),
              parentTopicId: Value(topic.parentTopicId),
            ),
          );
        } catch (_) {
          // Ignore if already exists
        }
      }

      // Seed Concept Relationships
      for (final relation in getConceptRelationships()) {
        try {
          await database.into(database.conceptRelationships).insert(
            ConceptRelationshipsCompanion(
              relationId: Value(relation.relationId),
              sourceTopicId: Value(relation.sourceTopicId),
              targetTopicId: Value(relation.targetTopicId),
              relationshipType: Value(relation.relationshipType),
            ),
          );
        } catch (_) {
          // Ignore if already exists
        }
      }

      // Seed Questions
      for (final question in getQuestions()) {
        try {
          await database.into(database.questions).insert(
            QuestionsCompanion(
              questionId: Value(question.questionId),
              examId: Value(question.examId),
              subjectId: Value(question.subjectId),
              topicId: Value(question.topicId),
              year: Value(question.year),
              questionText: Value(question.questionText),
              optionA: Value(question.optionA),
              optionB: Value(question.optionB),
              optionC: Value(question.optionC),
              optionD: Value(question.optionD),
              correctAnswer: Value(question.correctAnswer),
              difficulty: Value(question.difficulty),
              explanation: Value(question.explanation),
              createdAt: Value(question.createdAt),
              language: Value(question.language),
              source: Value(question.source),
              verificationStatus: Value(question.verificationStatus),
            ),
          );
        } catch (_) {
          // Ignore if already exists
        }
      }

      // Seed Resource Catalog (Phase 1A — replaces the old, orphaned
      // getResources()/thin-schema seed; see getResourceCatalog's doc
      // comment for why).
      for (final resource in getResourceCatalog()) {
        try {
          await database.into(database.resources).insert(
            ResourcesCompanion(
              resourceId: Value(resource.resourceId),
              topicId: Value(resource.topicId),
              title: Value(resource.title),
              type: Value(resource.type),
              link: Value(resource.link),
              averageRating: Value(resource.averageRating),
              ratingCount: Value(resource.ratingCount),
              description: Value(resource.description),
              subjectId: Value(resource.subjectId),
              author: Value(resource.author),
              difficulty: Value(resource.difficulty),
              viewCount: Value(resource.viewCount),
              publishedDate: Value(resource.publishedDate),
              tags: Value(resource.tags.isEmpty ? null : resource.tags.join(',')),
              isOfficial: Value(resource.isOfficial),
              isDownloadable: Value(resource.isDownloadable),
              durationMinutes: Value(resource.durationMinutes),
              pageCount: Value(resource.pageCount),
              thumbnailUrl: Value(resource.thumbnailUrl),
              sourceUrl: Value(resource.sourceUrl),
              language: Value(resource.language),
              verifiedAt: Value(resource.verifiedAt),
              verificationStatus: Value(resource.verificationStatus),
            ),
          );
        } catch (_) {
          // Ignore if already exists
        }
      }

      // Seed Cutoff Data
      for (final cutoff in getCutoffData()) {
        try {
          await database.into(database.cutoffData).insert(
            CutoffDataCompanion(
              cutoffId: Value(cutoff.cutoffId),
              examId: Value(cutoff.examId),
              year: Value(cutoff.year),
              category: Value(cutoff.category),
              cutoffMark: Value(cutoff.cutoffMark),
              vacancyCount: Value(cutoff.vacancyCount),
              sourceUrl: Value(cutoff.sourceUrl),
              notificationNumber: Value(cutoff.notificationNumber),
              verifiedAt: Value(cutoff.verifiedAt),
              verificationStatus: Value(cutoff.verificationStatus),
            ),
          );
        } catch (_) {
          // Ignore if already exists
        }
      }

      // Seed content sync bookkeeping (Phase 1A, task 3) — every content
      // type starts 'local_only' since no backend exists to sync from yet.
      // See database.dart's ContentSyncMetadata table doc comment.
      for (final contentType in ['questions', 'resources', 'cutoffs', 'knowledge_graph']) {
        try {
          await database.into(database.contentSyncMetadata).insert(
            ContentSyncMetadataCompanion(
              contentType: Value(contentType),
              datasetVersion: const Value('local-seed-v1'),
              syncStatus: const Value('local_only'),
            ),
          );
        } catch (_) {
          // Ignore if already exists
        }
      }
    });
  }
}
