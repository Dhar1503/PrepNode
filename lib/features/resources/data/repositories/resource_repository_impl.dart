import 'package:dartz/dartz.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/resources/data/datasources/resource_local_datasource.dart';
import 'package:prepgraph/features/resources/data/datasources/resource_remote_datasource.dart';
import 'package:prepgraph/features/resources/domain/entities/bookmark.dart';
import 'package:prepgraph/features/resources/domain/entities/download_status.dart';
import 'package:prepgraph/features/resources/domain/entities/recommended_resource.dart';
import 'package:prepgraph/features/resources/domain/entities/resource_category.dart';
import 'package:prepgraph/features/resources/domain/entities/resource_collection.dart';
import 'package:prepgraph/features/resources/domain/entities/study_resource.dart';
import 'package:prepgraph/features/resources/domain/repositories/resource_repository.dart';

/// Resource Repository Implementation — Phase 1A.
///
/// Catalog browsing (categories, subject listings, search, related
/// resources) now follows the same remote-then-local pattern every other
/// repository in this app uses: try [remoteDataSource] (real Dio, fails
/// with no backend deployed), fall back to [localDataSource], which reads
/// the Drift `resources` table — the single real source of truth for the
/// catalog as of the schema-v3 consolidation (see database.dart).
///
/// User-specific state — bookmarks, downloads, recently-viewed — was
/// already real and local-only; unchanged here.
class ResourceRepositoryImpl implements ResourceRepository {
  final ResourceRemoteDataSource remoteDataSource;
  final ResourceLocalDataSource localDataSource;

  ResourceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // A handful of curated groupings over real, local resourceIds — this is
  // editorial curation (which resources belong together), not raw content,
  // so it doesn't need its own Drift table the way the catalog itself did.
  static const _collections = [
    ResourceCollectionDef(
      id: 'coll-1',
      title: 'TNPSC Group 2 Complete Package',
      description: 'Complete study material package for TNPSC Group 2 preparation including all subjects.',
      resourceIds: ['res-1', 'res-2', 'res-8', 'res-10', 'res-17', 'res-18'],
      curator: 'TNPSC Academy',
      isOfficial: false,
    ),
    ResourceCollectionDef(
      id: 'coll-2',
      title: 'TNPSC Group 4 Starter Kit',
      description: 'Essential resources for TNPSC Group 4 beginners. Covers all important topics.',
      resourceIds: ['res-1', 'res-3', 'res-9', 'res-11', 'res-14'],
      curator: 'Success Academy',
      isOfficial: false,
    ),
    ResourceCollectionDef(
      id: 'coll-3',
      title: 'Official TNPSC Materials',
      description: 'Collection of official TNPSC documents and government materials.',
      resourceIds: ['res-6', 'res-7', 'res-8', 'res-9', 'res-11', 'res-12'],
      curator: 'TNPSC',
      isOfficial: true,
    ),
  ];

  // Curated "recommended" resourceIds + why — a lightweight substitute for
  // real personalized ranking (which would need attempt-history-driven
  // logic akin to the Strategy Engine's, out of scope for this schema
  // pass). Looked up from the real catalog rather than duplicating
  // StudyResource data inline, unlike the old implementation.
  // Points at verified resources only. The previous picks (res-1, res-3,
  // res-10) were all example.com placeholder rows, which the local
  // datasource now hides — so this list rendered empty on the home screen.
  static const _recommendedDefs = [
    ('res-4', 'Polity is the highest-frequency PYQ area — start here', 0.92, 'pyq'),
    ('res-21', 'Tamil-medium history lectures for your weakest topics', 0.88, 'planner'),
    ('res-6', 'The official syllabus — check your coverage against it', 0.85, 'cutoff'),
  ];

  @override
  Future<Either<Failure, List<ResourceCategory>>> getResourceCategories() async {
    try {
      final categories = await remoteDataSource.getResourceCategories();
      return Right(categories);
    } catch (_) {
      try {
        final categories = await localDataSource.getResourceCategories();
        return Right(categories);
      } catch (e) {
        return Left(ServerFailure('Failed to load resource categories'));
      }
    }
  }

  @override
  Future<Either<Failure, List<StudyResource>>> getResourcesBySubject(
    String subjectId, {
    String? topicId,
    String? type,
    String? difficulty,
  }) async {
    try {
      final resources = await remoteDataSource.getResourcesBySubject(
        subjectId,
        topicId: topicId,
        type: type,
        difficulty: difficulty,
      );
      return Right(resources);
    } catch (_) {
      try {
        final resources = await localDataSource.getResourcesBySubject(
          subjectId,
          topicId: topicId,
          type: type,
          difficulty: difficulty,
        );
        return Right(resources);
      } catch (e) {
        return Left(ServerFailure('Failed to load resources'));
      }
    }
  }

  @override
  Future<Either<Failure, List<StudyResource>>> searchResources(
    String query, {
    String? subjectId,
    String? type,
  }) async {
    try {
      final resources = await remoteDataSource.searchResources(
        query,
        subjectId: subjectId,
        type: type,
      );
      return Right(resources);
    } catch (_) {
      try {
        final resources = await localDataSource.searchResources(
          query,
          subjectId: subjectId,
          type: type,
        );
        return Right(resources);
      } catch (e) {
        return Left(ServerFailure('Failed to search resources'));
      }
    }
  }

  @override
  Future<Either<Failure, StudyResource>> getResourceById(
    String resourceId,
  ) async {
    try {
      final resource = await remoteDataSource.getResourceById(resourceId);
      return Right(resource);
    } catch (_) {
      try {
        final resource = await localDataSource.getResourceById(resourceId);
        if (resource == null) {
          return Left(ServerFailure('Resource not found'));
        }
        return Right(resource);
      } catch (e) {
        return Left(ServerFailure('Failed to load resource details'));
      }
    }
  }

  @override
  Future<Either<Failure, List<RecommendedResource>>>
      getRecommendedResources(String userId) async {
    try {
      final recommendations = await remoteDataSource.getRecommendedResources(userId);
      return Right(recommendations);
    } catch (_) {
      try {
        final resourceIds = _recommendedDefs.map((d) => d.$1).toList();
        final resources = await localDataSource.getResourcesByIds(resourceIds);
        final byId = {for (final r in resources) r.id: r};
        final recommendations = <RecommendedResource>[];
        for (final def in _recommendedDefs) {
          final resource = byId[def.$1];
          if (resource == null) continue;
          recommendations.add(RecommendedResource(
            id: 'rec-${def.$1}',
            userId: userId,
            resource: resource,
            reason: def.$2,
            relevanceScore: def.$3,
            recommendedAt: DateTime.now(),
            sourceTopicId: resource.topicId,
            sourceModule: def.$4,
          ));
        }
        return Right(recommendations);
      } catch (e) {
        return Left(ServerFailure('Failed to load recommended resources'));
      }
    }
  }

  @override
  Future<Either<Failure, List<ResourceCollection>>> getResourceCollections() async {
    try {
      final collections = await remoteDataSource.getResourceCollections();
      return Right(collections);
    } catch (_) {
      final collections = _collections
          .map((c) => ResourceCollection(
                id: c.id,
                title: c.title,
                description: c.description,
                coverImage: '',
                resourceIds: c.resourceIds,
                curator: c.curator,
                totalResources: c.resourceIds.length,
                createdAt: DateTime(2024, 1, 1),
                isOfficial: c.isOfficial,
              ))
          .toList();
      return Right(collections);
    }
  }

  @override
  Future<Either<Failure, List<StudyResource>>> getResourcesInCollection(
    String collectionId,
  ) async {
    try {
      final resources = await remoteDataSource.getResourcesInCollection(collectionId);
      return Right(resources);
    } catch (_) {
      try {
        final def = _collections.firstWhere((c) => c.id == collectionId);
        final resources = await localDataSource.getResourcesByIds(def.resourceIds);
        return Right(resources);
      } catch (e) {
        return Left(ServerFailure('Failed to load collection resources'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Bookmark>>> getBookmarks(String userId) async {
    try {
      final bookmarks = await localDataSource.getBookmarks(userId);
      return Right(bookmarks);
    } catch (e) {
      return Left(ServerFailure('Failed to load bookmarks'));
    }
  }

  @override
  Future<Either<Failure, Bookmark>> addBookmark(
    String userId,
    String resourceId, {
    String? notes,
  }) async {
    try {
      final bookmark =
          await localDataSource.addBookmark(userId, resourceId, notes: notes);
      return Right(bookmark);
    } catch (e) {
      return Left(ServerFailure('Failed to add bookmark'));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark(String bookmarkId) async {
    try {
      await localDataSource.removeBookmark(bookmarkId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to remove bookmark'));
    }
  }

  @override
  Future<Either<Failure, DownloadStatus?>> getDownloadStatus(
    String userId,
    String resourceId,
  ) async {
    try {
      final status = await localDataSource.getDownloadStatus(userId, resourceId);
      return Right(status);
    } catch (e) {
      return Left(ServerFailure('Failed to get download status'));
    }
  }

  @override
  Future<Either<Failure, List<DownloadStatus>>> getDownloadedResources(
    String userId,
  ) async {
    try {
      final downloads = await localDataSource.getDownloadedResources(userId);
      return Right(downloads);
    } catch (e) {
      return Left(ServerFailure('Failed to load downloaded resources'));
    }
  }

  @override
  Future<Either<Failure, DownloadStatus>> updateDownloadStatus(
    String userId,
    String resourceId,
    DownloadState state,
    double progress,
  ) async {
    try {
      final status = await localDataSource.updateDownloadStatus(
        userId,
        resourceId,
        state,
        progress,
      );
      return Right(status);
    } catch (e) {
      return Left(ServerFailure('Failed to update download status'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDownload(String userId, String resourceId) async {
    try {
      await localDataSource.deleteDownload(userId, resourceId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete download'));
    }
  }

  @override
  Future<Either<Failure, void>> clearDownloads(String userId) async {
    try {
      await localDataSource.clearDownloads(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to clear downloads'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsViewed(
    String userId,
    String resourceId,
  ) async {
    try {
      await localDataSource.markAsViewed(userId, resourceId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to mark as viewed'));
    }
  }

  @override
  Future<Either<Failure, List<StudyResource>>> getRecentlyViewed(
    String userId,
  ) async {
    try {
      final ids = await localDataSource.getRecentlyViewedResourceIds(userId);
      final resources = await localDataSource.getResourcesByIds(ids);
      // Preserve recency order — getResourcesByIds doesn't guarantee it.
      final byId = {for (final r in resources) r.id: r};
      final ordered = ids.map((id) => byId[id]).whereType<StudyResource>().toList();
      return Right(ordered);
    } catch (e) {
      return Left(ServerFailure('Failed to load recently viewed'));
    }
  }

  @override
  Future<Either<Failure, List<StudyResource>>> getRelatedResources(
    String topicId,
  ) async {
    try {
      final resources = await remoteDataSource.getRelatedResources(topicId);
      return Right(resources);
    } catch (_) {
      try {
        final resources = await localDataSource.getRelatedResources(topicId);
        return Right(resources);
      } catch (e) {
        return Left(ServerFailure('Failed to load related resources'));
      }
    }
  }
}

class ResourceCollectionDef {
  final String id;
  final String title;
  final String description;
  final List<String> resourceIds;
  final String curator;
  final bool isOfficial;

  const ResourceCollectionDef({
    required this.id,
    required this.title,
    required this.description,
    required this.resourceIds,
    required this.curator,
    required this.isOfficial,
  });
}
