import '../database/database.dart';
import '../failures.dart';

/// Base interface for local data sources
/// All local data sources should extend this interface
abstract class LocalDataSource {
  /// Get the database instance
  PrepNodeDatabase get database;

  /// Initialize the data source
  Future<void> initialize();

  /// Clear all cached data
  Future<void> clearAll();

  /// Check if data source is ready
  bool get isReady;
}

/// Base implementation of LocalDataSource
/// Provides common functionality for all local data sources
abstract class BaseLocalDataSource implements LocalDataSource {
  final PrepNodeDatabase _database;

  BaseLocalDataSource(this._database);

  @override
  PrepNodeDatabase get database => _database;

  @override
  Future<void> initialize() async {
    // Database is already initialized when passed in
    // This can be overridden for specific initialization logic
  }

  @override
  Future<void> clearAll() async {
    // Override in subclasses to clear specific tables
  }

  @override
  bool get isReady => true;

  /// Handle database errors and convert to Failure
  Failure handleDatabaseError(Object error) {
    return DatabaseFailure.queryFailed(
      originalError: error,
    );
  }
}
