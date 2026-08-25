import '../result.dart';

/// Base interface for all repositories
/// Provides common functionality for data operations
abstract class BaseRepository {
  /// Clear all cached data
  Future<Result<void>> clearCache();

  /// Check if repository is ready
  bool get isReady;
}

/// Base implementation of BaseRepository
/// Provides common functionality for repository implementations
abstract class BaseRepositoryImpl implements BaseRepository {
  @override
  bool get isReady => true;

  @override
  Future<Result<void>> clearCache() async {
    // Override in subclasses to clear specific caches
    return Result.success(null);
  }

  /// Handle errors and convert to Failure
  Object handleError(Object error) {
    return error;
  }
}
