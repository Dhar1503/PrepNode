import 'database.dart';
import '../seed/seed_data.dart';
import '../failures.dart';
import '../result.dart';

/// Database Service for managing database lifecycle
/// Handles initialization, seeding, and migration
class DatabaseService {
  static DatabaseService? _instance;
  static PrepGraphDatabase? _database;

  DatabaseService._();

  /// Get singleton instance
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Get database instance
  PrepGraphDatabase get database {
    if (_database == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  /// Initialize database
  Future<Result<void>> initialize({bool seedData = true}) async {
    try {
      _database = await PrepGraphDatabase.create();
      await _ensureInsightsTables();

      if (seedData) {
        await SeedData.seedDatabase(_database!);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  /// Initialize in-memory database for testing
  Future<Result<void>> initializeInMemory({bool seedData = true}) async {
    try {
      _database = await PrepGraphDatabase.createInMemory();
      await _ensureInsightsTables();

      if (seedData) {
        await SeedData.seedDatabase(_database!);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  /// Close database
  Future<Result<void>> close() async {
    try {
      await _database?.close();
      _database = null;
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  /// Check if database is initialized
  bool get isInitialized => _database != null;

  /// Clear all data from database
  Future<Result<void>> clearAllData() async {
    try {
      if (_database == null) {
        return Result.failure(DatabaseFailure.notFound(entity: 'Database'));
      }

      await _database!.transaction(() async {
        await _database!.delete(database.users).go();
        await _database!.delete(database.userPreferences).go();
        await _database!.delete(database.refreshTokens).go();
        await _database!.delete(database.exams).go();
        await _database!.delete(database.subjects).go();
        await _database!.delete(database.topics).go();
        await _database!.delete(database.conceptRelationships).go();
        await _database!.delete(database.questions).go();
        await _database!.delete(database.resources).go();
        await _database!.delete(database.resourceRatings).go();
        await _database!.delete(database.cutoffData).go();
        await _database!.delete(database.userQuestionAttempts).go();
        await _database!.delete(database.mockTests).go();
        await _database!.delete(database.mockTestQuestions).go();
        await _database!.delete(database.mockTestAnswers).go();
        await _database!.delete(database.studyPlans).go();
        await _database!.delete(database.userTopicProgress).go();
        await _database!.delete(database.confidenceCheckins).go();
        await _database!.delete(database.achievements).go();
        await _database!.delete(database.bookmarks).go();
        await _database!.customStatement('DELETE FROM user_analytics');
        await _database!.customStatement('DELETE FROM study_sessions');
      });

      // Re-seed data after clearing
      await SeedData.seedDatabase(_database!);

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  /// Re-seed database with fresh data
  Future<Result<void>> reseed() async {
    try {
      if (_database == null) {
        return Result.failure(DatabaseFailure.notFound(entity: 'Database'));
      }

      await SeedData.seedDatabase(_database!);
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  Future<void> _ensureInsightsTables() async {
    if (_database == null) return;

    await _database!.customStatement('''
      CREATE TABLE IF NOT EXISTS user_analytics (
        user_id TEXT PRIMARY KEY REFERENCES users (user_id),
        prep_graph_score REAL NOT NULL DEFAULT 0,
        topic_completion REAL NOT NULL DEFAULT 0,
        pyq_performance REAL NOT NULL DEFAULT 0,
        mock_accuracy REAL NOT NULL DEFAULT 0,
        consistency REAL NOT NULL DEFAULT 0,
        revision_discipline REAL NOT NULL DEFAULT 0,
        last_updated INTEGER NOT NULL
      )
    ''');

    await _database!.customStatement('''
      CREATE TABLE IF NOT EXISTS study_sessions (
        session_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL REFERENCES users (user_id),
        topic_id TEXT NOT NULL REFERENCES topics (topic_id),
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        actual_duration_minutes INTEGER NOT NULL,
        quality TEXT NOT NULL DEFAULT 'good',
        notes TEXT
      )
    ''');

    // Keep the existing user_topic_progress table aligned with the richer
    // insight cache queries even when the generated Drift schema is stale.
    await _addColumnIfMissing(
      'user_topic_progress',
      'questions_attempted',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      'user_topic_progress',
      'questions_correct',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      'user_topic_progress',
      'study_minutes',
      'INTEGER NOT NULL DEFAULT 0',
    );

    // Resources module: downloaded and recently-viewed tracking has no
    // documented schema table, so it's added here the same way the
    // analytics/session cache tables above are.
    await _database!.customStatement('''
      CREATE TABLE IF NOT EXISTS downloaded_resources (
        user_id TEXT NOT NULL REFERENCES users (user_id),
        resource_id TEXT NOT NULL,
        state TEXT NOT NULL,
        progress REAL NOT NULL DEFAULT 0,
        local_path TEXT,
        file_size_bytes INTEGER,
        downloaded_at INTEGER,
        PRIMARY KEY (user_id, resource_id)
      )
    ''');

    await _database!.customStatement('''
      CREATE TABLE IF NOT EXISTS recently_viewed_resources (
        user_id TEXT NOT NULL REFERENCES users (user_id),
        resource_id TEXT NOT NULL,
        viewed_at INTEGER NOT NULL,
        PRIMARY KEY (user_id, resource_id)
      )
    ''');
  }

  Future<void> _addColumnIfMissing(
    String tableName,
    String columnName,
    String columnDefinition,
  ) async {
    try {
      await _database!.customStatement(
        'ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition',
      );
    } catch (_) {
      // Column already exists or the table is already on the latest shape.
    }
  }
}
