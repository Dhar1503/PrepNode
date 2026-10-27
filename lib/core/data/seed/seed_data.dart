import '../database/database.dart';
import '../dtos/content_dto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'question_bank.dart';

/// Seed data for the local database
/// Provides initial data for exams, subjects, topics, and questions
/// Based on docs/07_PrepNode-Database-Schema.md and docs/06_PrepNode_API_Documentation.md
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

      // ============ SUBTOPICS ============
      // Every unit above previously stopped at one level, so three of the
      // four subjects had a single childless topic. The knowledge graph is
      // built from this hierarchy, so a flat list drew a flat graph. These
      // are the standard TNPSC Group 2 syllabus subdivisions.

      // Indian History -> chronological periods
      TopicDto(
        topicId: 'topic-ancient-india',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-history',
        topicName: 'Ancient India',
        difficulty: 'medium',
        importanceScore: 0.80,
      ),
      TopicDto(
        topicId: 'topic-medieval-india',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-history',
        topicName: 'Medieval India',
        difficulty: 'medium',
        importanceScore: 0.75,
      ),
      TopicDto(
        topicId: 'topic-modern-india',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-history',
        topicName: 'Modern India & Freedom Struggle',
        difficulty: 'hard',
        importanceScore: 0.92,
      ),

      // Indian Constitution -> organs of the state
      TopicDto(
        topicId: 'topic-parliament',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-constitution',
        topicName: 'Union Legislature (Parliament)',
        difficulty: 'medium',
        importanceScore: 0.88,
      ),
      TopicDto(
        topicId: 'topic-judiciary',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-constitution',
        topicName: 'Judiciary',
        difficulty: 'medium',
        importanceScore: 0.82,
      ),
      TopicDto(
        topicId: 'topic-union-state-executive',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-constitution',
        topicName: 'Union & State Executive',
        difficulty: 'medium',
        importanceScore: 0.80,
      ),

      // Tamil Nadu History -> periods
      TopicDto(
        topicId: 'topic-medieval-tn',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-tn-history',
        topicName: 'Medieval Tamil Nadu',
        difficulty: 'medium',
        importanceScore: 0.78,
      ),
      TopicDto(
        topicId: 'topic-tn-freedom-movement',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-tn-history',
        topicName: 'Freedom Movement in Tamil Nadu',
        difficulty: 'medium',
        importanceScore: 0.85,
      ),
      TopicDto(
        topicId: 'topic-social-reformers-tn',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-tn-history',
        topicName: 'Social Reformers of Tamil Nadu',
        difficulty: 'medium',
        importanceScore: 0.83,
      ),

      // Geography
      TopicDto(
        topicId: 'topic-physical-geography',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-geography',
        topicName: 'Physical Geography',
        difficulty: 'medium',
        importanceScore: 0.75,
      ),
      TopicDto(
        topicId: 'topic-indian-geography',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-geography',
        topicName: 'Geography of India',
        difficulty: 'medium',
        importanceScore: 0.80,
      ),

      // Indian Economy
      TopicDto(
        topicId: 'topic-banking-finance',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-economy',
        topicName: 'Banking & Public Finance',
        difficulty: 'hard',
        importanceScore: 0.78,
      ),
      TopicDto(
        topicId: 'topic-agriculture-economy',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-indian-economy',
        topicName: 'Agriculture & Rural Economy',
        difficulty: 'medium',
        importanceScore: 0.72,
      ),

      // General Science -> the three science streams
      TopicDto(
        topicId: 'topic-physics',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-general-science',
        topicName: 'Physics',
        difficulty: 'medium',
        importanceScore: 0.75,
      ),
      TopicDto(
        topicId: 'topic-chemistry',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-general-science',
        topicName: 'Chemistry',
        difficulty: 'medium',
        importanceScore: 0.73,
      ),
      TopicDto(
        topicId: 'topic-biology',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-general-science',
        topicName: 'Botany & Zoology',
        difficulty: 'medium',
        importanceScore: 0.77,
      ),

      // Current Affairs
      TopicDto(
        topicId: 'topic-national-affairs',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-current-affairs',
        topicName: 'National & International Affairs',
        difficulty: 'medium',
        importanceScore: 0.80,
      ),
      TopicDto(
        topicId: 'topic-tn-affairs',
        subjectId: 'subject-general-studies',
        parentTopicId: 'topic-current-affairs',
        topicName: 'Tamil Nadu Affairs & Schemes',
        difficulty: 'medium',
        importanceScore: 0.82,
      ),

      // Aptitude & Mental Ability — Paper II's quantitative section
      TopicDto(
        topicId: 'topic-number-system',
        subjectId: 'subject-aptitude',
        parentTopicId: 'topic-aptitude-reasoning',
        topicName: 'Number System',
        difficulty: 'easy',
        importanceScore: 0.85,
      ),
      TopicDto(
        topicId: 'topic-algebra',
        subjectId: 'subject-aptitude',
        parentTopicId: 'topic-aptitude-reasoning',
        topicName: 'Algebra',
        difficulty: 'medium',
        importanceScore: 0.78,
      ),
      TopicDto(
        topicId: 'topic-geometry',
        subjectId: 'subject-aptitude',
        parentTopicId: 'topic-aptitude-reasoning',
        topicName: 'Geometry & Mensuration',
        difficulty: 'medium',
        importanceScore: 0.74,
      ),
      TopicDto(
        topicId: 'topic-data-interpretation',
        subjectId: 'subject-aptitude',
        parentTopicId: 'topic-aptitude-reasoning',
        topicName: 'Data Interpretation',
        difficulty: 'medium',
        importanceScore: 0.76,
      ),
      TopicDto(
        topicId: 'topic-logical-reasoning',
        subjectId: 'subject-aptitude',
        parentTopicId: 'topic-aptitude-reasoning',
        topicName: 'Logical Reasoning',
        difficulty: 'medium',
        importanceScore: 0.80,
      ),

      // General Tamil
      TopicDto(
        topicId: 'topic-tamil-grammar',
        subjectId: 'subject-general-tamil',
        parentTopicId: 'topic-tamil-grammar-literature',
        topicName: 'Tamil Grammar (Ilakkanam)',
        difficulty: 'medium',
        importanceScore: 0.85,
      ),
      TopicDto(
        topicId: 'topic-sangam-literature',
        subjectId: 'subject-general-tamil',
        parentTopicId: 'topic-tamil-grammar-literature',
        topicName: 'Sangam Literature',
        difficulty: 'medium',
        importanceScore: 0.88,
      ),
      TopicDto(
        topicId: 'topic-tamil-authors',
        subjectId: 'subject-general-tamil',
        parentTopicId: 'topic-tamil-grammar-literature',
        topicName: 'Authors & Their Works',
        difficulty: 'medium',
        importanceScore: 0.80,
      ),

      // General English
      TopicDto(
        topicId: 'topic-english-grammar',
        subjectId: 'subject-general-english',
        parentTopicId: 'topic-english-grammar-usage',
        topicName: 'Grammar & Sentence Structure',
        difficulty: 'medium',
        importanceScore: 0.82,
      ),
      TopicDto(
        topicId: 'topic-english-vocabulary',
        subjectId: 'subject-general-english',
        parentTopicId: 'topic-english-grammar-usage',
        topicName: 'Vocabulary & Comprehension',
        difficulty: 'easy',
        importanceScore: 0.78,
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

      // Practice bank. Kept in its own file so this one stays readable, and
      // so the provenance rules for practice questions live next to the
      // questions themselves rather than in a comment here.
      ...QuestionBank.all(),
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
  /// checked 2026-08-04), res-6 (official TNPSC syllabus PDF, link
  /// confirmed to actually resolve on 2026-08-17 after the original
  /// guessed URL was found to be a fabricated 404 — see res-6's own
  /// comment), plus res-23..res-29 (Tamil-medium YouTube lecture series).
  ///
  /// The 17 entries that still carried literal example.com placeholder
  /// links were DELETED in this pass rather than kept behind a
  /// `verificationStatus` flag. Marking a dead link "unverified" still
  /// puts a row on the Resources screen that 404s when tapped; the flag
  /// was doing less work than intended. Every row that remains has a link
  /// that resolves, which `test/core/data/seed_integrity_test.dart` now
  /// enforces on every run.
  static List<ResourceCatalogDto> getResourceCatalog() {
    final verifiedNow = DateTime(2026, 8, 4);
    return [
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

      // ---- Official and institutional primary sources ----
      // Root/section URLs rather than deep file paths on purpose: a deep
      // PDF link rots when a department reorganises its site, and this
      // catalog has already been cleaned once of links that 404'd. A
      // department landing page is the most durable thing to point at.
      //
      // Every one is 'unverified' because none has been opened and
      // confirmed from this machine. That is what the badge is for - do
      // not promote any of these to 'verified' without actually tapping
      // it.
      ResourceCatalogDto(
        resourceId: 'res-30',
        topicId: 'topic-tn-history',
        subjectId: 'subject-general-studies',
        title: 'Tamil Nadu State Board Textbooks (Official)',
        description: 'Free PDFs of every Tamil Nadu State Board textbook from Class 6 to 12. These are the primary source most TNPSC questions are drawn from.',
        type: 'governmentMaterial',
        link: 'https://www.textbooksonline.tn.nic.in/',
        sourceUrl: 'https://www.textbooksonline.tn.nic.in/',
        author: 'Tamil Nadu Textbook Corporation',
        difficulty: 'beginner',
        tags: const ['textbook', 'official', 'state board'],
        isOfficial: true,
        isDownloadable: true,
        verificationStatus: 'unverified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-31',
        topicId: 'topic-indian-history',
        subjectId: 'subject-general-studies',
        title: 'NCERT Textbooks (Official)',
        description: 'Official NCERT textbook downloads. NCERT history, geography and polity volumes are standard preparation material for the General Studies paper.',
        type: 'governmentMaterial',
        link: 'https://ncert.nic.in/textbook.php',
        sourceUrl: 'https://ncert.nic.in/textbook.php',
        author: 'NCERT',
        difficulty: 'beginner',
        tags: const ['textbook', 'official', 'ncert'],
        isOfficial: true,
        isDownloadable: true,
        verificationStatus: 'unverified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-32',
        topicId: 'topic-indian-constitution',
        subjectId: 'subject-general-studies',
        title: 'The Constitution of India (Full Text)',
        description: 'The complete Constitution published by the Legislative Department, the authoritative text for Article numbers, Schedules and Amendments.',
        type: 'governmentMaterial',
        link: 'https://legislative.gov.in/constitution-of-india/',
        sourceUrl: 'https://legislative.gov.in/constitution-of-india/',
        author: 'Legislative Department, Government of India',
        difficulty: 'intermediate',
        tags: const ['constitution', 'official', 'polity'],
        isOfficial: true,
        isDownloadable: true,
        verificationStatus: 'unverified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-33',
        topicId: 'topic-banking-finance',
        subjectId: 'subject-general-studies',
        title: 'Reserve Bank of India (Official)',
        description: 'RBI publications, current policy rates and the annual report, the primary source for banking and monetary policy questions.',
        type: 'website',
        link: 'https://www.rbi.org.in/',
        sourceUrl: 'https://www.rbi.org.in/',
        author: 'Reserve Bank of India',
        difficulty: 'intermediate',
        tags: const ['economy', 'banking', 'official'],
        isOfficial: true,
        isDownloadable: false,
        verificationStatus: 'unverified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-34',
        topicId: 'topic-national-affairs',
        subjectId: 'subject-general-studies',
        title: 'Press Information Bureau (Official)',
        description: 'Government press releases as they are issued. Reading PIB directly avoids the errors that creep into second-hand current affairs compilations.',
        type: 'website',
        link: 'https://pib.gov.in/',
        sourceUrl: 'https://pib.gov.in/',
        author: 'Press Information Bureau',
        difficulty: 'intermediate',
        tags: const ['current affairs', 'official'],
        isOfficial: true,
        isDownloadable: false,
        verificationStatus: 'unverified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-35',
        topicId: 'topic-indian-geography',
        subjectId: 'subject-general-studies',
        title: 'Census of India (Official)',
        description: 'Official population, literacy and density figures. Use this rather than remembered numbers, because census questions turn on exact values.',
        type: 'governmentMaterial',
        link: 'https://censusindia.gov.in/',
        sourceUrl: 'https://censusindia.gov.in/',
        author: 'Office of the Registrar General of India',
        difficulty: 'intermediate',
        tags: const ['geography', 'statistics', 'official'],
        isOfficial: true,
        isDownloadable: true,
        verificationStatus: 'unverified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-36',
        topicId: 'topic-sangam-literature',
        subjectId: 'subject-general-tamil',
        title: 'Tamil Virtual Academy',
        description: 'Digitised Tamil literary texts and study material maintained by the Government of Tamil Nadu, covering Sangam works and grammar.',
        type: 'website',
        link: 'https://www.tamilvu.org/',
        sourceUrl: 'https://www.tamilvu.org/',
        author: 'Tamil Virtual Academy',
        difficulty: 'intermediate',
        tags: const ['tamil', 'literature', 'official'],
        isOfficial: true,
        isDownloadable: false,
        verificationStatus: 'unverified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-37',
        topicId: 'topic-tn-affairs',
        subjectId: 'subject-general-studies',
        title: 'TNPSC Official Portal',
        description: 'Notifications, syllabi, answer keys and results published by the Commission itself, the only authoritative source for exam announcements.',
        type: 'governmentMaterial',
        link: 'https://www.tnpsc.gov.in/',
        sourceUrl: 'https://www.tnpsc.gov.in/',
        author: 'TNPSC',
        difficulty: 'beginner',
        tags: const ['official', 'notification', 'syllabus'],
        isOfficial: true,
        isDownloadable: false,
        verificationStatus: 'unverified',
      ),
      ResourceCatalogDto(
        resourceId: 'res-38',
        topicId: 'topic-parliament',
        subjectId: 'subject-general-studies',
        title: 'India Code - Central Acts',
        description: 'The official repository of Central Acts, useful for checking the text and year of any legislation named in a question.',
        type: 'governmentMaterial',
        link: 'https://www.indiacode.nic.in/',
        sourceUrl: 'https://www.indiacode.nic.in/',
        author: 'Ministry of Law and Justice',
        difficulty: 'advanced',
        tags: const ['polity', 'legislation', 'official'],
        isOfficial: true,
        isDownloadable: true,
        verificationStatus: 'unverified',
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
  static Future<void> seedDatabase(PrepNodeDatabase database) async {
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
