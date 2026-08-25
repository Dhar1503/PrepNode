import '../dtos/engagement_dto.dart';

/// Mapping extensions for Engagement entities (Achievements, Bookmarks)

extension AchievementDtoMapping on AchievementDto {
  /// Convert AchievementDto to Domain entity
  Map<String, dynamic> toDomainMap() {
    return {
      'achievementId': achievementId,
      'userId': userId,
      'achievementType': achievementType,
      'title': title,
      'description': description,
      'relatedTopicId': relatedTopicId,
      'unlockedAt': unlockedAt,
      'seen': seen,
    };
  }
}

extension BookmarkDtoMapping on BookmarkDto {
  /// Convert BookmarkDto to Domain entity
  Map<String, dynamic> toDomainMap() {
    return {
      'bookmarkId': bookmarkId,
      'userId': userId,
      'entityType': entityType,
      'entityId': entityId,
      'createdAt': createdAt,
    };
  }
}
