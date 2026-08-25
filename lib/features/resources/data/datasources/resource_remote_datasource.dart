/// Resource Remote Data Source — Phase 1A rewrite.
///
/// This used to be a hardcoded static catalog masquerading as a remote
/// call (wrapped in Future.delayed to look like network latency). That
/// was the second of two independent "sources of truth" for resources —
/// see database.dart's schema-v3 migration for the full reconciliation.
///
/// This is now a genuine Dio-based REST client, matching every other
/// feature's remote datasource (see CutoffRemoteDataSource for the same
/// pattern). It will fail with a connection error until a real backend
/// exists at ApiConstants.baseUrl — that failure is expected and is what
/// makes ResourceRepositoryImpl's fallback to the Drift-backed local
/// catalog (seeded from SeedData.getResourceCatalog()) the actual path
/// exercised today.
library;

import 'package:prepgraph/core/network/api_client.dart';
import 'package:prepgraph/core/network/api_constants.dart';
import 'package:prepgraph/core/network/models/api_response.dart';
import 'package:prepgraph/features/resources/domain/entities/bookmark.dart';
import 'package:prepgraph/features/resources/domain/entities/recommended_resource.dart';
import 'package:prepgraph/features/resources/domain/entities/resource_category.dart';
import 'package:prepgraph/features/resources/domain/entities/resource_collection.dart';
import 'package:prepgraph/features/resources/domain/entities/study_resource.dart';

class ResourceRemoteDataSource {
  final ApiClient _apiClient;

  ResourceRemoteDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  StudyResource _parseResource(Map<String, dynamic> data) {
    return StudyResource(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      type: ResourceType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ResourceType.pdf,
      ),
      url: data['url'] as String,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      subjectId: data['subjectId'] as String?,
      topicId: data['topicId'] as String?,
      author: data['author'] as String? ?? '',
      durationMinutes: data['durationMinutes'] as int? ?? 0,
      pageCount: data['pageCount'] as int? ?? 0,
      difficulty: data['difficulty'] as String? ?? 'beginner',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      viewCount: data['viewCount'] as int? ?? 0,
      publishedDate: data['publishedDate'] != null
          ? DateTime.parse(data['publishedDate'] as String)
          : DateTime.now(),
      tags: (data['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ?? const [],
      isOfficial: data['isOfficial'] as bool? ?? false,
      isDownloadable: data['isDownloadable'] as bool? ?? false,
      sourceUrl: data['sourceUrl'] as String?,
      verificationStatus:
          data['verificationStatus'] == 'verified' ? VerificationStatus.verified : VerificationStatus.unverified,
    );
  }

  Future<List<ResourceCategory>> getResourceCategories() async {
    final response = await _apiClient.get<ApiResponse<List<dynamic>>>(
      '${ApiConstants.resources}/categories',
    );
    final data = response.data!;
    return data.map((c) {
      final map = c as Map<String, dynamic>;
      return ResourceCategory(
        id: map['id'] as String,
        name: map['name'] as String,
        icon: map['icon'] as String,
        resourceCount: map['resourceCount'] as int,
        subjectId: map['subjectId'] as String?,
      );
    }).toList();
  }

  Future<List<StudyResource>> getResourcesBySubject(
    String subjectId, {
    String? topicId,
    String? type,
    String? difficulty,
  }) async {
    final response = await _apiClient.get<ApiResponse<List<dynamic>>>(
      ApiConstants.resources,
      queryParameters: {
        'subjectId': subjectId,
        if (topicId != null) 'topicId': topicId,
        if (type != null) 'type': type,
        if (difficulty != null) 'difficulty': difficulty,
      },
    );
    return response.data!.map((r) => _parseResource(r as Map<String, dynamic>)).toList();
  }

  Future<List<StudyResource>> searchResources(
    String query, {
    String? subjectId,
    String? type,
  }) async {
    final response = await _apiClient.get<ApiResponse<List<dynamic>>>(
      '${ApiConstants.resources}/search',
      queryParameters: {
        'q': query,
        if (subjectId != null) 'subjectId': subjectId,
        if (type != null) 'type': type,
      },
    );
    return response.data!.map((r) => _parseResource(r as Map<String, dynamic>)).toList();
  }

  Future<StudyResource> getResourceById(String resourceId) async {
    final response = await _apiClient.get<ApiResponse<Map<String, dynamic>>>(
      '${ApiConstants.resources}/$resourceId',
    );
    return _parseResource(response.data!);
  }

  Future<List<RecommendedResource>> getRecommendedResources(String userId) async {
    final response = await _apiClient.get<ApiResponse<List<dynamic>>>(
      '${ApiConstants.usersRecommendedResources}',
      queryParameters: {'userId': userId},
    );
    return response.data!.map((r) {
      final map = r as Map<String, dynamic>;
      return RecommendedResource(
        id: map['id'] as String,
        userId: userId,
        resource: _parseResource(map['resource'] as Map<String, dynamic>),
        reason: map['reason'] as String,
        relevanceScore: (map['relevanceScore'] as num).toDouble(),
        recommendedAt: DateTime.parse(map['recommendedAt'] as String),
        sourceTopicId: map['sourceTopicId'] as String?,
        sourceModule: map['sourceModule'] as String?,
      );
    }).toList();
  }

  Future<List<ResourceCollection>> getResourceCollections() async {
    final response = await _apiClient.get<ApiResponse<List<dynamic>>>(
      '${ApiConstants.resources}/collections',
    );
    return response.data!.map((c) {
      final map = c as Map<String, dynamic>;
      return ResourceCollection(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        coverImage: map['coverImage'] as String,
        resourceIds: (map['resourceIds'] as List<dynamic>).map((r) => r as String).toList(),
        curator: map['curator'] as String,
        totalResources: map['totalResources'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
        isOfficial: map['isOfficial'] as bool? ?? false,
      );
    }).toList();
  }

  Future<List<StudyResource>> getResourcesInCollection(String collectionId) async {
    final response = await _apiClient.get<ApiResponse<List<dynamic>>>(
      '${ApiConstants.resources}/collections/$collectionId',
    );
    return response.data!.map((r) => _parseResource(r as Map<String, dynamic>)).toList();
  }

  Future<List<Bookmark>> getBookmarks(String userId) async {
    final response = await _apiClient.get<ApiResponse<List<dynamic>>>(
      ApiConstants.usersBookmarks,
      queryParameters: {'userId': userId},
    );
    return response.data!.map((b) {
      final map = b as Map<String, dynamic>;
      return Bookmark(
        id: map['id'] as String,
        userId: userId,
        resourceId: map['resourceId'] as String,
        bookmarkedAt: DateTime.parse(map['bookmarkedAt'] as String),
        notes: map['notes'] as String?,
      );
    }).toList();
  }

  Future<List<StudyResource>> getRecentlyViewed(String userId) async {
    final response = await _apiClient.get<ApiResponse<List<dynamic>>>(
      '${ApiConstants.resources}/recently-viewed',
      queryParameters: {'userId': userId},
    );
    return response.data!.map((r) => _parseResource(r as Map<String, dynamic>)).toList();
  }

  Future<List<StudyResource>> getRelatedResources(String topicId) async {
    final response = await _apiClient.get<ApiResponse<List<dynamic>>>(
      '${ApiConstants.resources}/related/$topicId',
    );
    return response.data!.map((r) => _parseResource(r as Map<String, dynamic>)).toList();
  }
}
