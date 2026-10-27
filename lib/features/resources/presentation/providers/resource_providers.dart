import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepnode/core/data/providers/data_providers.dart';
import 'package:prepnode/core/network/providers/network_providers.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/resources/data/datasources/resource_local_datasource.dart';
import 'package:prepnode/features/resources/data/datasources/resource_remote_datasource.dart';
import 'package:prepnode/features/resources/data/repositories/resource_repository_impl.dart';
import 'package:prepnode/features/resources/domain/entities/bookmark.dart';
import 'package:prepnode/features/resources/domain/entities/download_status.dart';
import 'package:prepnode/features/resources/domain/entities/recommended_resource.dart';
import 'package:prepnode/features/resources/domain/entities/resource_category.dart';
import 'package:prepnode/features/resources/domain/entities/resource_collection.dart';
import 'package:prepnode/features/resources/domain/entities/study_resource.dart';
import 'package:prepnode/features/resources/domain/repositories/resource_repository.dart';

// Remote Data Source Provider (resource catalog content) — Phase 1A: now a
// real Dio-based client, matching every other feature's remote datasource.
final resourceRemoteDataSourceProvider =
    Provider<ResourceRemoteDataSource>((ref) {
  return ResourceRemoteDataSource(apiClient: ref.watch(apiClientProvider));
});

// Local Data Source Provider (bookmarks/downloads/recently-viewed)
final resourceLocalDataSourceProvider = Provider<ResourceLocalDataSource>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return ResourceLocalDataSource(databaseService: databaseService);
});

// Repository Provider
final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  final remoteDataSource = ref.watch(resourceRemoteDataSourceProvider);
  final localDataSource = ref.watch(resourceLocalDataSourceProvider);
  return ResourceRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Current user id, read from the real auth session rather than a mock
/// constant. Resource-personalization providers below depend on this.
final _currentUserIdProvider = Provider<String>((ref) {
  return ref.watch(authProvider).userId ?? '';
});

// Resource Categories Provider
final resourceCategoriesProvider =
    FutureProvider<List<ResourceCategory>>((ref) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final result = await repository.getResourceCategories();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});

// Resources by Subject Provider
//
// Keyed on subjectId alone (a String, which has real value equality) rather
// than a Map literal — a fresh Map is never == to the previous one, so
// Riverpod treated every rebuild as a brand-new family parameter and never
// reused the cached future, which is what made this screen appear to load
// forever. Type/difficulty filtering happens client-side in
// SubjectResourcesScreen instead, the same pattern MockTestHomeScreen
// already uses for its own type filter.
final resourcesBySubjectProvider =
    FutureProvider.family<List<StudyResource>, String>((ref, subjectId) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final result = await repository.getResourcesBySubject(subjectId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (resources) => resources,
  );
});

// Search Resources Provider
final searchResourcesProvider =
    FutureProvider.family<List<StudyResource>, SearchParams>((ref, params) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final result = await repository.searchResources(
    params.query,
    subjectId: params.subjectId,
    type: params.type,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (resources) => resources,
  );
});

// Resource by ID Provider
final resourceByIdProvider =
    FutureProvider.family<StudyResource, String>((ref, resourceId) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final result = await repository.getResourceById(resourceId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (resource) => resource,
  );
});

// Recommended Resources Provider
final recommendedResourcesProvider =
    FutureProvider<List<RecommendedResource>>((ref) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final userId = ref.watch(_currentUserIdProvider);
  final result = await repository.getRecommendedResources(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (recommendations) => recommendations,
  );
});

// Resource Collections Provider
final resourceCollectionsProvider =
    FutureProvider<List<ResourceCollection>>((ref) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final result = await repository.getResourceCollections();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (collections) => collections,
  );
});

// Resources in Collection Provider
final resourcesInCollectionProvider =
    FutureProvider.family<List<StudyResource>, String>((ref, collectionId) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final result = await repository.getResourcesInCollection(collectionId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (resources) => resources,
  );
});

// Bookmarks Provider
final bookmarksProvider = FutureProvider<List<Bookmark>>((ref) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final userId = ref.watch(_currentUserIdProvider);
  final result = await repository.getBookmarks(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (bookmarks) => bookmarks,
  );
});

// Download Status Provider
final downloadStatusProvider =
    FutureProvider.family<DownloadStatus?, String>((ref, resourceId) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final userId = ref.watch(_currentUserIdProvider);
  final result = await repository.getDownloadStatus(userId, resourceId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (status) => status,
  );
});

// Downloaded Resources Provider
final downloadedResourcesProvider =
    FutureProvider<List<DownloadStatus>>((ref) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final userId = ref.watch(_currentUserIdProvider);
  final result = await repository.getDownloadedResources(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (downloads) => downloads,
  );
});

// Recently Viewed Provider
final recentlyViewedProvider = FutureProvider<List<StudyResource>>((ref) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final userId = ref.watch(_currentUserIdProvider);
  final result = await repository.getRecentlyViewed(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (resources) => resources,
  );
});

// Related Resources Provider
final relatedResourcesProvider =
    FutureProvider.family<List<StudyResource>, String>((ref, topicId) async {
  final repository = ref.watch(resourceRepositoryProvider);
  final result = await repository.getRelatedResources(topicId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (resources) => resources,
  );
});

// Search Parameters Class
class SearchParams {
  final String query;
  final String? subjectId;
  final String? type;

  const SearchParams({
    required this.query,
    this.subjectId,
    this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          subjectId == other.subjectId &&
          type == other.type;

  @override
  int get hashCode => query.hashCode ^ subjectId.hashCode ^ type.hashCode;
}
