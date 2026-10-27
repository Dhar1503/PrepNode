import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/resources/domain/entities/bookmark.dart';
import 'package:prepnode/features/resources/domain/entities/download_status.dart';
import 'package:prepnode/features/resources/domain/entities/recommended_resource.dart';
import 'package:prepnode/features/resources/domain/entities/resource_category.dart';
import 'package:prepnode/features/resources/domain/entities/resource_collection.dart';
import 'package:prepnode/features/resources/domain/entities/study_resource.dart';

/// Resource Repository Interface
/// Defines operations for managing study resources
abstract class ResourceRepository {
  /// Get all available resource categories
  Future<Either<Failure, List<ResourceCategory>>> getResourceCategories();

  /// Get resources filtered by subject
  Future<Either<Failure, List<StudyResource>>> getResourcesBySubject(
    String subjectId, {
    String? topicId,
    String? type,
    String? difficulty,
  });

  /// Search resources by query
  Future<Either<Failure, List<StudyResource>>> searchResources(
    String query, {
    String? subjectId,
    String? type,
  });

  /// Get resource details by ID
  Future<Either<Failure, StudyResource>> getResourceById(String resourceId);

  /// Get recommended resources for a user
  Future<Either<Failure, List<RecommendedResource>>> getRecommendedResources(
    String userId,
  );

  /// Get curated resource collections
  Future<Either<Failure, List<ResourceCollection>>> getResourceCollections();

  /// Get resources in a collection
  Future<Either<Failure, List<StudyResource>>> getResourcesInCollection(
    String collectionId,
  );

  /// Get user's bookmarked resources
  Future<Either<Failure, List<Bookmark>>> getBookmarks(String userId);

  /// Add a bookmark
  Future<Either<Failure, Bookmark>> addBookmark(
    String userId,
    String resourceId, {
    String? notes,
  });

  /// Remove a bookmark
  Future<Either<Failure, void>> removeBookmark(String bookmarkId);

  /// Get download status for a resource
  Future<Either<Failure, DownloadStatus?>> getDownloadStatus(
    String userId,
    String resourceId,
  );

  /// Get all downloaded resources
  Future<Either<Failure, List<DownloadStatus>>> getDownloadedResources(
    String userId,
  );

  /// Update download status
  Future<Either<Failure, DownloadStatus>> updateDownloadStatus(
    String userId,
    String resourceId,
    DownloadState state,
    double progress,
  );

  /// Delete a single downloaded resource
  Future<Either<Failure, void>> deleteDownload(String userId, String resourceId);

  /// Clear all downloaded resources for a user
  Future<Either<Failure, void>> clearDownloads(String userId);

  /// Mark resource as viewed
  Future<Either<Failure, void>> markAsViewed(
    String userId,
    String resourceId,
  );

  /// Get recently viewed resources
  Future<Either<Failure, List<StudyResource>>> getRecentlyViewed(
    String userId,
  );

  /// Get related resources for a topic
  Future<Either<Failure, List<StudyResource>>> getRelatedResources(
    String topicId,
  );
}
