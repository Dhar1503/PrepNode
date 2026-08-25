import '../database/database.dart';
import '../dtos/engagement_dto.dart';
import '../failures.dart';
import '../result.dart';
import 'local_datasource.dart';
import 'package:drift/drift.dart';

/// Local data source for Engagement-related operations
/// Handles Achievements, Bookmarks
class EngagementLocalDataSource extends BaseLocalDataSource {
  EngagementLocalDataSource(super.database);

  // ==================== ACHIEVEMENTS ====================

  /// Get achievements for a user
  Future<Result<List<AchievementDto>>> getAchievements(
    String userId, {
    bool? seen,
  }) async {
    try {
      final query = database.select(database.achievements)
        ..where((tbl) => tbl.userId.equals(userId));

      if (seen != null) {
        query.where((tbl) => tbl.seen.equals(seen));
      }

      query.orderBy([(tbl) => OrderingTerm.desc(tbl.unlockedAt)]);

      final results = await query.get();

      final dtos = results.map((a) => AchievementDto(
        achievementId: a.achievementId,
        userId: a.userId,
        achievementType: a.achievementType,
        title: a.title,
        description: a.description,
        relatedTopicId: a.relatedTopicId,
        unlockedAt: a.unlockedAt,
        seen: a.seen,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Get achievement by ID
  Future<Result<AchievementDto>> getAchievementById(String achievementId) async {
    try {
      final result = await (database.select(database.achievements)
            ..where((tbl) => tbl.achievementId.equals(achievementId))
            ..limit(1))
          .getSingleOrNull();

      if (result == null) {
        return Result.failure(DatabaseFailure.notFound(entity: 'Achievement'));
      }

      final dto = AchievementDto(
        achievementId: result.achievementId,
        userId: result.userId,
        achievementType: result.achievementType,
        title: result.title,
        description: result.description,
        relatedTopicId: result.relatedTopicId,
        unlockedAt: result.unlockedAt,
        seen: result.seen,
      );

      return Result.success(dto);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Create achievement
  Future<Result<AchievementDto>> createAchievement(AchievementDto achievement) async {
    try {
      await database.into(database.achievements).insert(
        AchievementsCompanion.insert(
          achievementId: achievement.achievementId,
          userId: achievement.userId,
          achievementType: achievement.achievementType,
          title: achievement.title,
          description: achievement.description,
          relatedTopicId: Value(achievement.relatedTopicId),
          seen: Value(achievement.seen),
        ),
      );

      return Result.success(achievement);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Update achievement seen status
  Future<Result<void>> markAchievementAsSeen(String achievementId) async {
    try {
      await (database.update(database.achievements)
          ..where((tbl) => tbl.achievementId.equals(achievementId)))
          .write(
            AchievementsCompanion(
              seen: const Value(true),
            ),
          );

      return Result.success(null);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== BOOKMARKS ====================

  /// Get bookmarks for a user
  Future<Result<List<BookmarkDto>>> getBookmarks(
    String userId, {
    String? entityType,
  }) async {
    try {
      final query = database.select(database.bookmarks)
        ..where((tbl) => tbl.userId.equals(userId));

      if (entityType != null) {
        query.where((tbl) => tbl.entityType.equals(entityType));
      }

      query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

      final results = await query.get();

      final dtos = results.map((b) => BookmarkDto(
        bookmarkId: b.bookmarkId,
        userId: b.userId,
        entityType: b.entityType,
        entityId: b.entityId,
        createdAt: b.createdAt,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Check if entity is bookmarked
  Future<Result<bool>> isBookmarked(
    String userId,
    String entityType,
    String entityId,
  ) async {
    try {
      final result = await (database.select(database.bookmarks)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.entityType.equals(entityType))
            ..where((tbl) => tbl.entityId.equals(entityId))
            ..limit(1))
          .getSingleOrNull();

      return Result.success(result != null);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Create bookmark
  Future<Result<BookmarkDto>> createBookmark(BookmarkDto bookmark) async {
    try {
      await database.into(database.bookmarks).insert(
        BookmarksCompanion.insert(
          bookmarkId: bookmark.bookmarkId,
          userId: bookmark.userId,
          entityType: bookmark.entityType,
          entityId: bookmark.entityId,
        ),
      );

      return Result.success(bookmark);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Delete bookmark
  Future<Result<void>> deleteBookmark(String bookmarkId) async {
    try {
      await (database.delete(database.bookmarks)
            ..where((tbl) => tbl.bookmarkId.equals(bookmarkId)))
          .go();

      return Result.success(null);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Delete bookmark by entity
  Future<Result<void>> deleteBookmarkByEntity(
    String userId,
    String entityType,
    String entityId,
  ) async {
    try {
      await (database.delete(database.bookmarks)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.entityType.equals(entityType))
            ..where((tbl) => tbl.entityId.equals(entityId)))
          .go();

      return Result.success(null);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await database.delete(database.achievements).go();
      await database.delete(database.bookmarks).go();
    } catch (e) {
      throw handleDatabaseError(e);
    }
  }
}
