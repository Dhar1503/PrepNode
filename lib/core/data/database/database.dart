import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

/// PrepNode Local Database
/// Based on docs/07_PrepNode-Database-Schema.md
/// Engine: SQLite (via Drift)
/// Charset: utf8mb4 (handled by SQLite)
@DriftDatabase(tables: [
  Users,
  UserPreferences,
  RefreshTokens,
  Exams,
  Subjects,
  Topics,
  ConceptRelationships,
  Questions,
  Resources,
  ResourceRatings,
  CutoffData,
  UserQuestionAttempts,
  UserAnalytics,
  StudySessions,
  MockTests,
  MockTestQuestions,
  MockTestAnswers,
  StudyPlans,
  UserTopicProgress,
  ConfidenceCheckins,
  Achievements,
  Bookmarks,
  ContentSyncMetadata,
  // Adaptive learning platform (schema v7)
  RoadmapPreferences,
  RoadmapDays,
  RoadmapTasks,
  Streaks,
  XpHistory,
  Badges,
  DailyChallenges,
  WeeklyMissions,
])
class PrepNodeDatabase extends _$PrepNodeDatabase {
  PrepNodeDatabase(super.e);

  @override
  int get schemaVersion => 7;

  /// Schema v2 -> v3: additive-only (Phase 1A — real content foundation).
  /// No table is dropped or recreated, so every existing local row survives
  /// an app update instead of requiring a fresh install, which is what
  /// every prior schema bump in this project has silently relied on (there
  /// was no migration handler at all before this).
  /// Schema v3 -> v4 (Phase 1B): CutoffData.verificationStatus — v3 added
  /// sourceUrl/notificationNumber/verifiedAt to CutoffData but missed the
  /// actual verified/unverified flag every other content table carries.
  /// Schema v4 -> v5: MockTests.domainTestId — MockTests.examId is declared
  /// with a real FK to Exams, but MockTestLocalDataSource was writing the
  /// domain test id (e.g. 'local-full-tnpsc-group2') into it instead of a
  /// real exam id, and there was nowhere else to keep the domain test id.
  /// This column gives the domain test id its own place so `examId` can
  /// finally hold what it was always declared to hold.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 3) {
            // Resources: bring the table up to the full StudyResource shape
            // (previously only a thin subset lived here) plus new
            // provenance/verification metadata.
            await m.addColumn(resources, resources.description);
            await m.addColumn(resources, resources.subjectId);
            await m.addColumn(resources, resources.author);
            await m.addColumn(resources, resources.difficulty);
            await m.addColumn(resources, resources.viewCount);
            await m.addColumn(resources, resources.publishedDate);
            await m.addColumn(resources, resources.tags);
            await m.addColumn(resources, resources.isOfficial);
            await m.addColumn(resources, resources.isDownloadable);
            await m.addColumn(resources, resources.durationMinutes);
            await m.addColumn(resources, resources.pageCount);
            await m.addColumn(resources, resources.thumbnailUrl);
            await m.addColumn(resources, resources.sourceUrl);
            await m.addColumn(resources, resources.language);
            await m.addColumn(resources, resources.verifiedAt);
            await m.addColumn(resources, resources.verificationStatus);

            // CutoffData: provenance so every number is traceable back to
            // the notification/document it came from.
            await m.addColumn(cutoffData, cutoffData.sourceUrl);
            await m.addColumn(cutoffData, cutoffData.notificationNumber);
            await m.addColumn(cutoffData, cutoffData.verifiedAt);

            // Questions: language + provenance + verification, so a real
            // PYQ bank can be told apart from anything unverified.
            await m.addColumn(questions, questions.language);
            await m.addColumn(questions, questions.source);
            await m.addColumn(questions, questions.verificationStatus);

            // New table: per-content-type sync bookkeeping (Phase 1A task
            // 3). No backend exists yet, so every row starts as
            // 'local_only' — this is not simulated real-time sync, it's
            // the honest bookkeeping structure a future sync would update.
            await m.createTable(contentSyncMetadata);
          }
          if (from < 4) {
            await m.addColumn(cutoffData, cutoffData.verificationStatus);
          }
          if (from < 5) {
            await m.addColumn(mockTests, mockTests.domainTestId);
          }
          if (from < 6) {
            await _migrateToUniqueEmails();
            await _createIndexes();
          }
          if (from < 7) {
            // v6 -> v7: the adaptive learning platform. Purely additive —
            // eight new tables, no existing table touched — so every
            // account, attempt and plan on an upgrading device survives.
            await m.createTable(roadmapPreferences);
            await m.createTable(roadmapDays);
            await m.createTable(roadmapTasks);
            await m.createTable(streaks);
            await m.createTable(xpHistory);
            await m.createTable(badges);
            await m.createTable(dailyChallenges);
            await m.createTable(weeklyMissions);
            await _createIndexes();
          }
        },
      );

  /// v5 -> v6: make the account store actually enforce one account per
  /// email, and normalize what is already there.
  ///
  /// `users.email` was declared with no unique constraint and was written
  /// verbatim, so a device could hold both "Aspirant@Gmail.com" and
  /// "aspirant@gmail.com" as separate accounts — and the login lookup, which
  /// used `getSingleOrNull()`, threw on any duplicate instead of logging the
  /// user in. This lowercases every stored email, collapses duplicates onto
  /// the earliest-created row, and only then adds the unique index, because
  /// SQLite refuses to build a unique index over existing duplicate values.
  Future<void> _migrateToUniqueEmails() async {
    await customStatement('UPDATE users SET email = lower(trim(email))');
    await customStatement('''
      DELETE FROM users
      WHERE rowid NOT IN (
        SELECT min(rowid) FROM users GROUP BY email
      )
    ''');
  }

  /// Indexes for the columns this app actually filters and joins on.
  /// Created with IF NOT EXISTS so this is safe to run on both a fresh
  /// database (onCreate) and an upgraded one (onUpgrade).
  Future<void> _createIndexes() async {
    const statements = [
      // Account store: the constraint that makes duplicate registration
      // impossible rather than merely discouraged by an app-level check.
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users (email)',
      // Syllabus hierarchy — walked on every Knowledge Graph build.
      'CREATE INDEX IF NOT EXISTS idx_subjects_exam ON subjects (exam_id)',
      'CREATE INDEX IF NOT EXISTS idx_topics_subject ON topics (subject_id)',
      'CREATE INDEX IF NOT EXISTS idx_topics_parent ON topics (parent_topic_id)',
      // Question bank — filtered by exam/subject/topic on every PYQ screen.
      'CREATE INDEX IF NOT EXISTS idx_questions_exam ON questions (exam_id)',
      'CREATE INDEX IF NOT EXISTS idx_questions_subject ON questions (subject_id)',
      'CREATE INDEX IF NOT EXISTS idx_questions_topic ON questions (topic_id)',
      // Per-user progress — the hot path for mastery and the score.
      'CREATE INDEX IF NOT EXISTS idx_attempts_user ON user_question_attempts (user_id)',
      'CREATE INDEX IF NOT EXISTS idx_attempts_user_question ON user_question_attempts (user_id, question_id)',
      'CREATE INDEX IF NOT EXISTS idx_progress_user ON user_topic_progress (user_id)',
      'CREATE INDEX IF NOT EXISTS idx_progress_user_topic ON user_topic_progress (user_id, topic_id)',
      'CREATE INDEX IF NOT EXISTS idx_mock_tests_user ON mock_tests (user_id)',
      'CREATE INDEX IF NOT EXISTS idx_mock_answers_test ON mock_test_answers (test_id)',
      'CREATE INDEX IF NOT EXISTS idx_study_plans_user ON study_plans (user_id)',
      'CREATE INDEX IF NOT EXISTS idx_bookmarks_user ON bookmarks (user_id)',
      'CREATE INDEX IF NOT EXISTS idx_resources_subject ON resources (subject_id)',
      'CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON refresh_tokens (user_id)',
      // Adaptive learning platform (v7) — every one of these is read on
      // each dashboard build, so none of them should ever table-scan.
      'CREATE INDEX IF NOT EXISTS idx_roadmap_days_user ON roadmap_days (user_id, day_number)',
      'CREATE INDEX IF NOT EXISTS idx_roadmap_days_user_date ON roadmap_days (user_id, date)',
      'CREATE INDEX IF NOT EXISTS idx_roadmap_tasks_day ON roadmap_tasks (day_id)',
      'CREATE INDEX IF NOT EXISTS idx_roadmap_tasks_user ON roadmap_tasks (user_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_xp_history_user ON xp_history (user_id, earned_at)',
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_xp_history_dedupe ON xp_history (user_id, dedupe_key)',
      'CREATE INDEX IF NOT EXISTS idx_badges_user ON badges (user_id)',
      'CREATE INDEX IF NOT EXISTS idx_daily_challenges_user ON daily_challenges (user_id, date)',
      'CREATE INDEX IF NOT EXISTS idx_weekly_missions_user ON weekly_missions (user_id, week_start)',
    ];
    for (final statement in statements) {
      try {
        await customStatement(statement);
      } catch (_) {
        // A column named in an index may not exist on a database that
        // predates it; the rest of the indexes are still worth creating.
      }
    }
  }

  /// Create database from file
  static Future<PrepNodeDatabase> create() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbDir.path, 'prepnode.db');
    final file = File(dbPath);
    
    return PrepNodeDatabase(NativeDatabase.createInBackground(file));
  }

  /// Create in-memory database for testing
  static Future<PrepNodeDatabase> createInMemory() async {
    return PrepNodeDatabase(NativeDatabase.memory());
  }
}

// ==================== USER DOMAIN TABLES ====================

@DataClassName('User')
class Users extends Table {
  @override
  String get tableName => 'users';

  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get passwordHash => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get examId => text().nullable().references(Exams, #examId)();
  DateTimeColumn get targetDate => dateTime().nullable()();
  IntColumn get dailyStudyHours => integer().nullable()();
  TextColumn get preparationLevel => text().nullable()();
  BoolColumn get profileComplete => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastLogin => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

@DataClassName('UserPreference')
class UserPreferences extends Table {
  @override
  String get tableName => 'user_preferences';

  TextColumn get preferenceId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get dailyReminderEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get revisionAlertsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get milestoneUpdatesEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get plannerRemindersEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get mockTestRemindersEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get studyStreakRemindersEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get resourceRecommendationsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get aiRecommendationsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get cutoffAlertsEnabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {preferenceId};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {userId},
  ];
}

@DataClassName('RefreshToken')
class RefreshTokens extends Table {
  @override
  String get tableName => 'refresh_tokens';

  TextColumn get tokenId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get tokenHash => text()();
  TextColumn get deviceLabel => text().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get revokedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {tokenId};
}

// ==================== EXAM HIERARCHY TABLES ====================

@DataClassName('Exam')
class Exams extends Table {
  @override
  String get tableName => 'exams';

  TextColumn get examId => text()();
  TextColumn get examName => text()();
  TextColumn get description => text().nullable()();
  TextColumn get conductingBody => text().nullable()();
  BoolColumn get comingSoon => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {examId};
}

@DataClassName('Subject')
class Subjects extends Table {
  @override
  String get tableName => 'subjects';

  TextColumn get subjectId => text()();
  TextColumn get examId => text().references(Exams, #examId)();
  TextColumn get subjectName => text()();
  RealColumn get importanceWeight => real().withDefault(const Constant(0.50))();

  @override
  Set<Column> get primaryKey => {subjectId};
}

@DataClassName('Topic')
class Topics extends Table {
  @override
  String get tableName => 'topics';

  TextColumn get topicId => text()();
  TextColumn get subjectId => text().references(Subjects, #subjectId)();
  TextColumn get parentTopicId => text().nullable().references(Topics, #topicId)();
  TextColumn get topicName => text()();
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();
  RealColumn get importanceScore => real().withDefault(const Constant(0.50))();

  @override
  Set<Column> get primaryKey => {topicId};
}

@DataClassName('ConceptRelationship')
class ConceptRelationships extends Table {
  @override
  String get tableName => 'concept_relationships';

  TextColumn get relationId => text()();
  TextColumn get sourceTopicId => text().references(Topics, #topicId)();
  TextColumn get targetTopicId => text().references(Topics, #topicId)();
  TextColumn get relationshipType => text()();

  @override
  Set<Column> get primaryKey => {relationId};
}

// ==================== CONTENT TABLES ====================

@DataClassName('Question')
class Questions extends Table {
  @override
  String get tableName => 'questions';

  TextColumn get questionId => text()();
  TextColumn get examId => text().references(Exams, #examId)();
  TextColumn get subjectId => text().references(Subjects, #subjectId)();
  TextColumn get topicId => text().references(Topics, #topicId)();
  IntColumn get year => integer()();
  TextColumn get questionText => text()();
  TextColumn get optionA => text()();
  TextColumn get optionB => text()();
  TextColumn get optionC => text()();
  TextColumn get optionD => text()();
  TextColumn get correctAnswer => text()();
  TextColumn get explanation => text().nullable()();
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // ---- Added in schema v3 (Phase 1A): language + provenance, so a real
  // verified PYQ is distinguishable from seed/placeholder content as the
  // bank grows. ----
  TextColumn get language => text().withDefault(const Constant('english'))(); // 'english' | 'tamil' | 'both'
  TextColumn get source => text().nullable()(); // e.g. "TNPSC Group 2 2023 Prelims — official paper"
  TextColumn get verificationStatus => text().withDefault(const Constant('unverified'))(); // 'verified' | 'unverified'

  @override
  Set<Column> get primaryKey => {questionId};
}

@DataClassName('Resource')
class Resources extends Table {
  @override
  String get tableName => 'resources';

  TextColumn get resourceId => text()();
  TextColumn get topicId => text().references(Topics, #topicId)();
  TextColumn get title => text()();
  TextColumn get type => text()();
  TextColumn get link => text()();
  RealColumn get averageRating => real().withDefault(const Constant(0.0))();
  IntColumn get ratingCount => integer().withDefault(const Constant(0))();

  // ---- Added in schema v3 (Phase 1A): brings this table up to the full
  // catalog shape previously only held in the hardcoded
  // ResourceRemoteDataSource list, so Drift becomes the single real source
  // of truth for the resource catalog instead of two independent ones. ----
  TextColumn get description => text().nullable()();
  TextColumn get subjectId => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get difficulty => text().nullable()();
  IntColumn get viewCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get publishedDate => dateTime().nullable()();
  // Comma-separated — this table has no separate tags table, and the tag
  // lists here are short (2-4 words), so a join table would be overhead
  // without a real benefit yet.
  TextColumn get tags => text().nullable()();
  BoolColumn get isOfficial => boolean().withDefault(const Constant(false))();
  BoolColumn get isDownloadable => boolean().withDefault(const Constant(false))();
  IntColumn get durationMinutes => integer().withDefault(const Constant(0))();
  IntColumn get pageCount => integer().withDefault(const Constant(0))();
  TextColumn get thumbnailUrl => text().nullable()();
  // Distinct from `link` on purpose: `link` is where the resource itself
  // lives; `sourceUrl` is where it was found/verified from. For most
  // entries today the two are the same value, since verification was
  // "does this exact link work" — they'd diverge if a resource were ever
  // mirrored/cached at a different location than where it was sourced.
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get language => text().withDefault(const Constant('english'))(); // 'english' | 'tamil' | 'both'
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  TextColumn get verificationStatus => text().withDefault(const Constant('unverified'))(); // 'verified' | 'unverified'

  @override
  Set<Column> get primaryKey => {resourceId};
}

@DataClassName('ResourceRating')
class ResourceRatings extends Table {
  @override
  String get tableName => 'resource_ratings';

  TextColumn get ratingId => text()();
  TextColumn get resourceId => text().references(Resources, #resourceId)();
  TextColumn get userId => text().references(Users, #userId)();
  IntColumn get rating => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {ratingId};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {resourceId, userId},
  ];
}

@DataClassName('CutoffDatum')
class CutoffData extends Table {
  @override
  String get tableName => 'cutoff_data';

  TextColumn get cutoffId => text()();
  TextColumn get examId => text().references(Exams, #examId)();
  IntColumn get year => integer()();
  TextColumn get category => text()();
  RealColumn get cutoffMark => real()();
  IntColumn get vacancyCount => integer().nullable()();

  // ---- Added in schema v3 (Phase 1A): provenance, so every cutoff number
  // is traceable to the real document it came from. ----
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get notificationNumber => text().nullable()();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  // Added schema v4 (Phase 1B) — v3 added the provenance fields above but
  // missed this one, the actual verified/unverified flag every other
  // content table (Resources, Questions) already carries.
  TextColumn get verificationStatus => text().withDefault(const Constant('unverified'))();

  @override
  Set<Column> get primaryKey => {cutoffId};
}

// ==================== PRACTICE & ASSESSMENT TABLES ====================

@DataClassName('UserQuestionAttempt')
class UserQuestionAttempts extends Table {
  @override
  String get tableName => 'user_question_attempts';

  TextColumn get attemptId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get questionId => text().references(Questions, #questionId)();
  TextColumn get selectedAnswer => text()();
  BoolColumn get isCorrect => boolean()();
  IntColumn get timeTakenSeconds => integer().nullable()();
  DateTimeColumn get attemptDate => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {attemptId};
}

@DataClassName('MockTest')
class MockTests extends Table {
  @override
  String get tableName => 'mock_tests';

  TextColumn get testId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get examId => text().references(Exams, #examId)();
  TextColumn get type => text()();
  TextColumn get subjectId => text().nullable().references(Subjects, #subjectId)();
  TextColumn get topicId => text().nullable().references(Topics, #topicId)();
  IntColumn get durationMinutes => integer()();
  TextColumn get status => text().withDefault(const Constant('in_progress'))();
  RealColumn get score => real().nullable()();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get submittedAt => dateTime().nullable()();
  // Added schema v5 — the domain test id (e.g. 'local-full-tnpsc-group2',
  // identifying which catalog entry was attempted), distinct from both
  // `testId` (this row's PK, actually the attempt id) and `examId` (the
  // real exam, FK'd to Exams above). Nullable so existing rows from before
  // this migration don't need backfilling.
  TextColumn get domainTestId => text().nullable()();

  @override
  Set<Column> get primaryKey => {testId};
}

@DataClassName('MockTestQuestion')
class MockTestQuestions extends Table {
  @override
  String get tableName => 'mock_test_questions';

  TextColumn get testId => text().references(MockTests, #testId)();
  TextColumn get questionId => text().references(Questions, #questionId)();
  IntColumn get questionOrder => integer()();

  @override
  Set<Column> get primaryKey => {testId, questionId};
}

@DataClassName('MockTestAnswer')
class MockTestAnswers extends Table {
  @override
  String get tableName => 'mock_test_answers';

  TextColumn get testId => text().references(MockTests, #testId)();
  TextColumn get questionId => text().references(Questions, #questionId)();
  TextColumn get selectedAnswer => text().nullable()();
  BoolColumn get isCorrect => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {testId, questionId};
}

// ==================== PLANNING & PROGRESS TABLES ====================

@DataClassName('StudyPlan')
class StudyPlans extends Table {
  @override
  String get tableName => 'study_plans';

  TextColumn get planId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get topicId => text().references(Topics, #topicId)();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text()();
  IntColumn get durationMinutes => integer()();
  TextColumn get type => text()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get reason => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {planId};
}

@DataClassName('UserTopicProgressData')
class UserTopicProgress extends Table {
  @override
  String get tableName => 'user_topic_progress';

  TextColumn get progressId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get topicId => text().references(Topics, #topicId)();
  RealColumn get masteryPercentage => real().withDefault(const Constant(0.0))();
  RealColumn get accuracy => real().nullable()();
  IntColumn get questionsAttempted => integer().withDefault(const Constant(0))();
  IntColumn get questionsCorrect => integer().withDefault(const Constant(0))();
  IntColumn get studyMinutes => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastRevisionDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {progressId};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {userId, topicId},
  ];
}

@DataClassName('UserAnalyticsData')
class UserAnalytics extends Table {
  @override
  String get tableName => 'user_analytics';

  TextColumn get userId => text().references(Users, #userId)();
  RealColumn get prepNodeScore => real().withDefault(const Constant(0.0))();
  RealColumn get topicCompletion => real().withDefault(const Constant(0.0))();
  RealColumn get pyqPerformance => real().withDefault(const Constant(0.0))();
  RealColumn get mockAccuracy => real().withDefault(const Constant(0.0))();
  RealColumn get consistency => real().withDefault(const Constant(0.0))();
  RealColumn get revisionDiscipline => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}

@DataClassName('StudySessionData')
class StudySessions extends Table {
  @override
  String get tableName => 'study_sessions';

  TextColumn get sessionId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get topicId => text().references(Topics, #topicId)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get actualDurationMinutes => integer()();
  TextColumn get quality => text().withDefault(const Constant('good'))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {sessionId};
}

@DataClassName('ConfidenceCheckin')
class ConfidenceCheckins extends Table {
  @override
  String get tableName => 'confidence_checkins';

  TextColumn get checkinId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get topicId => text().references(Topics, #topicId)();
  IntColumn get confidenceLevel => integer()();
  DateTimeColumn get weekOf => dateTime()();

  @override
  Set<Column> get primaryKey => {checkinId};
}

// ==================== ENGAGEMENT TABLES ====================

@DataClassName('Achievement')
class Achievements extends Table {
  @override
  String get tableName => 'achievements';

  TextColumn get achievementId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get achievementType => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get relatedTopicId => text().nullable().references(Topics, #topicId)();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get seen => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {achievementId};
}

@DataClassName('Bookmark')
class Bookmarks extends Table {
  @override
  String get tableName => 'bookmarks';

  TextColumn get bookmarkId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {bookmarkId};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {userId, entityType, entityId},
  ];
}

// ==================== CONTENT SYNC (Phase 1A, task 3) ====================
// Per-content-type bookkeeping for a *future* remote sync — not a live sync
// itself. No backend exists yet, so every row is seeded as 'local_only' and
// stays that way until Phase 2 actually introduces something to sync from.
// This exists so that when a backend does exist, "is this content stale /
// has it ever been synced" is a real question the app can answer instead of
// bolting on tracking after the fact.
@DataClassName('ContentSyncRecord')
class ContentSyncMetadata extends Table {
  @override
  String get tableName => 'content_sync_metadata';

  // 'questions' | 'resources' | 'cutoffs' | 'knowledge_graph'
  TextColumn get contentType => text()();
  TextColumn get datasetVersion => text().withDefault(const Constant('local-seed-v1'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  // 'local_only' | 'synced' | 'stale' | 'syncing' | 'error'
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();

  @override
  Set<Column> get primaryKey => {contentType};
}

@DataClassName('Notification')
class Notifications extends Table {
  @override
  String get tableName => 'notifications';

  TextColumn get notificationId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get entityType => text().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {notificationId};
}

// ==================== ADAPTIVE LEARNING PLATFORM TABLES (v7) ====================
// These back the roadmap, streak, XP and motivation features. They are
// deliberately per-user (every table carries userId) so that logging out and
// back in, or a second account on the same device, never inherits someone
// else's progress.

/// The answers from the roadmap wizard. One row per user — re-running the
/// wizard overwrites it rather than accumulating, because the roadmap is
/// always generated from the *current* preferences.
@DataClassName('RoadmapPreference')
class RoadmapPreferences extends Table {
  @override
  String get tableName => 'roadmap_preferences';

  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get examId => text()();
  /// beginner | intermediate | advanced
  TextColumn get level => text()();
  IntColumn get hoursPerDay => integer()();
  /// morning | afternoon | night
  TextColumn get preferredTime => text()();
  IntColumn get targetMonth => integer()();
  IntColumn get targetYear => integer()();
  /// working | fulltime
  TextColumn get studentType => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}

/// One row per day of the generated roadmap (30 days at a time).
@DataClassName('RoadmapDay')
class RoadmapDays extends Table {
  @override
  String get tableName => 'roadmap_days';

  TextColumn get dayId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  IntColumn get dayNumber => integer()();
  IntColumn get weekNumber => integer()();
  DateTimeColumn get date => dateTime()();
  /// The week's theme, e.g. "Foundations" — shown on the timeline card.
  TextColumn get focusLabel => text()();
  /// locked | current | completed | weak | missed
  TextColumn get status => text().withDefault(const Constant('locked'))();
  DateTimeColumn get generatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {dayId};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {userId, dayNumber},
  ];
}

/// The individual items inside a roadmap day.
@DataClassName('RoadmapTask')
class RoadmapTasks extends Table {
  @override
  String get tableName => 'roadmap_tasks';

  TextColumn get taskId => text()();
  TextColumn get dayId => text().references(RoadmapDays, #dayId)();
  TextColumn get userId => text().references(Users, #userId)();
  TextColumn get topicId => text().nullable().references(Topics, #topicId)();
  TextColumn get title => text()();
  /// study | pyq | mock | revision | resource | assessment
  TextColumn get kind => text()();
  IntColumn get estimatedMinutes => integer()();
  /// pending | completed | skipped
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {taskId};
}

/// Streak state. One row per user; [lastStudyDate] is stored as a date-only
/// value at local midnight so "did they study today" is a plain equality
/// check rather than timezone-sensitive arithmetic.
@DataClassName('Streak')
class Streaks extends Table {
  @override
  String get tableName => 'streaks';

  TextColumn get userId => text().references(Users, #userId)();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastStudyDate => dateTime().nullable()();
  IntColumn get freezeCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Append-only XP ledger. Totals are summed rather than stored, so a bug in
/// one award can never silently corrupt a running total.
@DataClassName('XpEntry')
class XpHistory extends Table {
  @override
  String get tableName => 'xp_history';

  TextColumn get entryId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  /// planner | pyq | mock | streak | revision | resource
  TextColumn get source => text()();
  IntColumn get amount => integer()();
  TextColumn get note => text().nullable()();
  /// Set for awards that must only ever happen once (e.g. one streak bonus
  /// per calendar day). Unique per user, so a repeated award is rejected by
  /// the database rather than relying on the caller to remember.
  TextColumn get dedupeKey => text().nullable()();
  DateTimeColumn get earnedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {entryId};
}

/// Unlocked milestone badges.
@DataClassName('Badge')
class Badges extends Table {
  @override
  String get tableName => 'badges';

  TextColumn get badgeId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  /// e.g. streak_7, level_strategist
  TextColumn get code => text()();
  DateTimeColumn get earnedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {badgeId};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {userId, code},
  ];
}

/// One challenge per user per day.
@DataClassName('DailyChallenge')
class DailyChallenges extends Table {
  @override
  String get tableName => 'daily_challenges';

  TextColumn get challengeId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  DateTimeColumn get date => dateTime()();
  TextColumn get code => text()();
  TextColumn get title => text()();
  IntColumn get targetCount => integer()();
  IntColumn get progressCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {challengeId};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {userId, date},
  ];
}

/// One mission per user per week (weekStart is the local Monday).
@DataClassName('WeeklyMission')
class WeeklyMissions extends Table {
  @override
  String get tableName => 'weekly_missions';

  TextColumn get missionId => text()();
  TextColumn get userId => text().references(Users, #userId)();
  DateTimeColumn get weekStart => dateTime()();
  TextColumn get code => text()();
  TextColumn get title => text()();
  IntColumn get targetCount => integer()();
  IntColumn get progressCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {missionId};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {userId, weekStart},
  ];
}
