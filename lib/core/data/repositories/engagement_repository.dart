import '../datasources/engagement_local_datasource.dart';
import '../dtos/engagement_dto.dart';
import '../result.dart';
import 'base_repository.dart';
import 'package:uuid/uuid.dart';

/// Repository for Engagement-related operations
/// Handles Achievements, Bookmarks
class EngagementRepository extends BaseRepositoryImpl {
  final EngagementLocalDataSource _localDataSource;

  EngagementRepository(this._localDataSource);

  // ==================== ACHIEVEMENTS ====================

  /// Get achievements for a user
  Future<Result<List<Map<String, dynamic>>>> getAchievements(
    String userId, {
    bool? seen,
  }) async {
    try {
      final result = await _localDataSource.getAchievements(userId, seen: seen);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Get achievement by ID
  Future<Result<Map<String, dynamic>>> getAchievementById(String achievementId) async {
    try {
      final result = await _localDataSource.getAchievementById(achievementId);
      return result.fold(
        onSuccess: (dto) => Result.success(dto.toDomainMap()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Create achievement
  Future<Result<void>> createAchievement({
    required String userId,
    required String achievementType,
    required String title,
    required String description,
    String? relatedTopicId,
  }) async {
    try {
      final dto = AchievementDto(
        achievementId: const Uuid().v4(),
        userId: userId,
        achievementType: achievementType,
        title: title,
        description: description,
        relatedTopicId: relatedTopicId,
        unlockedAt: DateTime.now(),
        seen: false,
      );

      final result = await _localDataSource.createAchievement(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Update achievement seen status
  Future<Result<void>> markAchievementAsSeen(String achievementId) async {
    try {
      final result = await _localDataSource.markAchievementAsSeen(achievementId);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== BOOKMARKS ====================

  /// Get bookmarks for a user
  Future<Result<List<Map<String, dynamic>>>> getBookmarks(
    String userId, {
    String? entityType,
  }) async {
    try {
      final result = await _localDataSource.getBookmarks(userId, entityType: entityType);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Check if entity is bookmarked
  Future<Result<bool>> isBookmarked(
    String userId,
    String entityType,
    String entityId,
  ) async {
    try {
      return await _localDataSource.isBookmarked(userId, entityType, entityId);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Create bookmark
  Future<Result<void>> createBookmark({
    required String userId,
    required String entityType,
    required String entityId,
  }) async {
    try {
      final dto = BookmarkDto(
        bookmarkId: const Uuid().v4(),
        userId: userId,
        entityType: entityType,
        entityId: entityId,
        createdAt: DateTime.now(),
      );

      final result = await _localDataSource.createBookmark(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Delete bookmark
  Future<Result<void>> deleteBookmark(String bookmarkId) async {
    try {
      return await _localDataSource.deleteBookmark(bookmarkId);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Delete bookmark by entity
  Future<Result<void>> deleteBookmarkByEntity(
    String userId,
    String entityType,
    String entityId,
  ) async {
    try {
      return await _localDataSource.deleteBookmarkByEntity(userId, entityType, entityId);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Toggle bookmark
  Future<Result<bool>> toggleBookmark({
    required String userId,
    required String entityType,
    required String entityId,
  }) async {
    try {
      final isBookmarkedResult = await isBookmarked(userId, entityType, entityId);
      
      return isBookmarkedResult.fold(
        onSuccess: (isBookmarked) async {
          if (isBookmarked) {
            final deleteResult = await deleteBookmarkByEntity(userId, entityType, entityId);
            return deleteResult.fold(
              onSuccess: (_) => Result.success(false),
              onFailure: (failure) => Result.failure(failure),
            );
          } else {
            final createResult = await createBookmark(userId: userId, entityType: entityType, entityId: entityId);
            return createResult.fold(
              onSuccess: (_) => Result.success(true),
              onFailure: (failure) => Result.failure(failure),
            );
          }
        },
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  @override
  Future<Result<void>> clearCache() async {
    try {
      await _localDataSource.clearAll();
      return Result.success(null);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }
}
