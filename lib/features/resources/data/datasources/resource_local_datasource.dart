/// Resource Local Data Source
/// Handles local persistence for bookmarks, downloads and recently-viewed
/// resources. Bookmarks reuse the existing `bookmarks` table (entityType
/// 'resource'); downloads and recently-viewed use two small tables created
/// alongside the other cache tables in DatabaseService, since neither has a
/// documented schema table of its own.
library;

import 'package:drift/drift.dart';
import 'package:prepnode/core/data/database/database.dart' hide Bookmark;
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/features/resources/domain/entities/bookmark.dart';
import 'package:prepnode/features/resources/domain/entities/download_status.dart';
import 'package:prepnode/features/resources/domain/entities/resource_category.dart';
import 'package:prepnode/features/resources/domain/entities/study_resource.dart';

class ResourceLocalDataSource {
  final DatabaseService _databaseService;

  ResourceLocalDataSource({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  // ==================== RESOURCE CATALOG (Phase 1A) ====================
  // Drift's `resources` table is now the single real source of truth for
  // the catalog (see database.dart's schema-v3 migration) — these methods
  // replace what used to live only in the hardcoded ResourceRemoteDataSource.

  StudyResource _mapResourceRow(Resource row) {
    return StudyResource(
      id: row.resourceId,
      title: row.title,
      description: row.description ?? '',
      type: _mapResourceType(row.type),
      url: row.link,
      thumbnailUrl: row.thumbnailUrl,
      subjectId: row.subjectId,
      topicId: row.topicId,
      author: row.author ?? '',
      durationMinutes: row.durationMinutes,
      pageCount: row.pageCount,
      difficulty: row.difficulty ?? 'beginner',
      rating: row.averageRating,
      viewCount: row.viewCount,
      publishedDate: row.publishedDate ?? DateTime.now(),
      tags: row.tags == null || row.tags!.isEmpty ? const [] : row.tags!.split(','),
      isOfficial: row.isOfficial,
      isDownloadable: row.isDownloadable,
      sourceUrl: row.sourceUrl,
      language: _mapLanguage(row.language),
      verifiedAt: row.verifiedAt,
      verificationStatus:
          row.verificationStatus == 'verified' ? VerificationStatus.verified : VerificationStatus.unverified,
    );
  }

  ResourceType _mapResourceType(String type) {
    return ResourceType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => ResourceType.pdf,
    );
  }

  ResourceLanguage _mapLanguage(String language) {
    switch (language) {
      case 'tamil':
        return ResourceLanguage.tamil;
      case 'both':
        return ResourceLanguage.both;
      default:
        return ResourceLanguage.english;
    }
  }

  /// Placeholder seed rows (example.com, or no link at all) are never
  /// surfaced to the UI: a card the user can't actually open is worse than
  /// no card. The rows stay in the database — they're still real catalog
  /// entries awaiting a verified URL (see SeedData.getResourceCatalog) —
  /// this only controls what gets shown.
  static bool _hasRealLink(Resource row) {
    final link = row.link.trim();
    return link.isNotEmpty && !link.contains('example.com');
  }

  List<StudyResource> _mapVisible(List<Resource> rows) {
    return rows.where(_hasRealLink).map(_mapResourceRow).toList();
  }

  Future<List<StudyResource>> getAllResources() async {
    final db = _databaseService.database;
    final rows = await db.select(db.resources).get();
    return _mapVisible(rows);
  }

  /// [subjectId] normally identifies a real subject, but the Resources home
  /// screen also routes here with a *category* id from
  /// [getResourceCategories] (e.g. 'cat-youtube'). Those never matched the
  /// subject_id column, so every category tap landed on "No resources
  /// found" — including the Video Lectures category. A category id selects
  /// by resource type instead, which is what the user actually asked for
  /// by tapping that card.
  Future<List<StudyResource>> getResourcesBySubject(
    String subjectId, {
    String? topicId,
    String? type,
    String? difficulty,
  }) async {
    final db = _databaseService.database;
    final categoryType = _typeFromCategoryId(subjectId);
    final query = db.select(db.resources);
    if (categoryType != null) {
      query.where((tbl) => tbl.type.equals(categoryType));
    } else {
      query.where((tbl) => tbl.subjectId.equals(subjectId));
    }
    if (topicId != null) query.where((tbl) => tbl.topicId.equals(topicId));
    if (type != null) query.where((tbl) => tbl.type.equals(type));
    if (difficulty != null) query.where((tbl) => tbl.difficulty.equals(difficulty));
    final rows = await query.get();
    return _mapVisible(rows);
  }

  /// 'cat-youtube' -> 'youtube'. Returns null when the id isn't a category
  /// id produced by [getResourceCategories].
  String? _typeFromCategoryId(String id) {
    if (!id.startsWith('cat-')) return null;
    final name = id.substring('cat-'.length);
    final match = ResourceType.values.where((t) => t.name == name);
    return match.isEmpty ? null : match.first.name;
  }

  Future<List<StudyResource>> searchResources(
    String query, {
    String? subjectId,
    String? type,
  }) async {
    final all = await getAllResources();
    final lowerQuery = query.toLowerCase();
    return all.where((r) {
      final matchesQuery = r.title.toLowerCase().contains(lowerQuery) ||
          r.description.toLowerCase().contains(lowerQuery) ||
          r.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      final matchesSubject = subjectId == null || r.subjectId == subjectId;
      final matchesType = type == null || r.type.name == type;
      return matchesQuery && matchesSubject && matchesType;
    }).toList();
  }

  Future<StudyResource?> getResourceById(String resourceId) async {
    final db = _databaseService.database;
    final row = await (db.select(db.resources)..where((tbl) => tbl.resourceId.equals(resourceId)))
        .getSingleOrNull();
    return row == null ? null : _mapResourceRow(row);
  }

  Future<List<StudyResource>> getResourcesByIds(List<String> resourceIds) async {
    if (resourceIds.isEmpty) return const [];
    final db = _databaseService.database;
    final rows = await (db.select(db.resources)..where((tbl) => tbl.resourceId.isIn(resourceIds))).get();
    return _mapVisible(rows);
  }

  Future<List<StudyResource>> getRelatedResources(String topicId) async {
    final db = _databaseService.database;
    final rows = await (db.select(db.resources)..where((tbl) => tbl.topicId.equals(topicId))).get();
    return _mapVisible(rows).take(5).toList();
  }

  /// Categories are computed from the real catalog (grouped by type), not
  /// a separately hardcoded list with invented counts.
  Future<List<ResourceCategory>> getResourceCategories() async {
    final all = await getAllResources();
    final counts = <ResourceType, int>{};
    for (final r in all) {
      counts[r.type] = (counts[r.type] ?? 0) + 1;
    }
    return counts.entries
        .map((e) => ResourceCategory(
              id: 'cat-${e.key.name}',
              name: _categoryLabel(e.key),
              icon: _categoryIcon(e.key),
              resourceCount: e.value,
            ))
        .toList();
  }

  String _categoryLabel(ResourceType type) {
    switch (type) {
      case ResourceType.pdf:
        return 'PDF Notes';
      case ResourceType.book:
        return 'Books';
      case ResourceType.notes:
        return 'Notes';
      case ResourceType.youtube:
        return 'Video Lectures';
      case ResourceType.website:
        return 'Websites';
      case ResourceType.governmentMaterial:
        return 'Government Material';
      case ResourceType.previousPapers:
        return 'Previous Papers';
    }
  }

  String _categoryIcon(ResourceType type) {
    switch (type) {
      case ResourceType.pdf:
        return 'description';
      case ResourceType.book:
        return 'menu_book';
      case ResourceType.notes:
        return 'note';
      case ResourceType.youtube:
        return 'play_circle';
      case ResourceType.website:
        return 'language';
      case ResourceType.governmentMaterial:
        return 'account_balance';
      case ResourceType.previousPapers:
        return 'history';
    }
  }

  // ==================== BOOKMARKS ====================

  Future<List<Bookmark>> getBookmarks(String userId) async {
    final db = _databaseService.database;
    final rows = await (db.select(db.bookmarks)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.entityType.equals('resource')))
        .get();

    return rows
        .map((row) => Bookmark(
              id: row.bookmarkId,
              userId: row.userId,
              resourceId: row.entityId,
              bookmarkedAt: row.createdAt,
            ))
        .toList();
  }

  Future<Bookmark> addBookmark(
    String userId,
    String resourceId, {
    String? notes,
  }) async {
    final db = _databaseService.database;
    final bookmarkId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.into(db.bookmarks).insert(BookmarksCompanion.insert(
          bookmarkId: bookmarkId,
          userId: userId,
          entityType: 'resource',
          entityId: resourceId,
        ));

    // `notes` has no backing column on the bookmarks table; it's returned
    // as given so the caller can still display it for this session.
    return Bookmark(
      id: bookmarkId,
      userId: userId,
      resourceId: resourceId,
      bookmarkedAt: DateTime.now(),
      notes: notes,
    );
  }

  Future<void> removeBookmark(String bookmarkId) async {
    final db = _databaseService.database;
    await (db.delete(db.bookmarks)..where((tbl) => tbl.bookmarkId.equals(bookmarkId))).go();
  }

  Future<void> removeBookmarkByResource(String userId, String resourceId) async {
    final db = _databaseService.database;
    await (db.delete(db.bookmarks)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.entityType.equals('resource') &
              tbl.entityId.equals(resourceId)))
        .go();
  }

  // ==================== DOWNLOADS ====================

  Future<DownloadStatus?> getDownloadStatus(String userId, String resourceId) async {
    final db = _databaseService.database;
    final row = await db
        .customSelect(
          'SELECT * FROM downloaded_resources WHERE user_id = ? AND resource_id = ?',
          variables: [Variable.withString(userId), Variable.withString(resourceId)],
        )
        .getSingleOrNull();

    if (row == null) return null;
    return _mapDownloadRow(row);
  }

  Future<List<DownloadStatus>> getDownloadedResources(String userId) async {
    final db = _databaseService.database;
    final rows = await db
        .customSelect(
          "SELECT * FROM downloaded_resources WHERE user_id = ? AND state = 'completed'",
          variables: [Variable.withString(userId)],
        )
        .get();

    return rows.map(_mapDownloadRow).toList();
  }

  Future<DownloadStatus> updateDownloadStatus(
    String userId,
    String resourceId,
    DownloadState state,
    double progress,
  ) async {
    final db = _databaseService.database;
    final isCompleted = state == DownloadState.completed;
    final downloadedAt = isCompleted ? DateTime.now() : null;
    final localPath = isCompleted ? '/downloads/$resourceId' : null;

    await db.customStatement(
      '''
      INSERT INTO downloaded_resources (user_id, resource_id, state, progress, local_path, downloaded_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT(user_id, resource_id) DO UPDATE SET
        state = excluded.state,
        progress = excluded.progress,
        local_path = COALESCE(excluded.local_path, downloaded_resources.local_path),
        downloaded_at = COALESCE(excluded.downloaded_at, downloaded_resources.downloaded_at)
      ''',
      [
        userId,
        resourceId,
        state.name,
        progress,
        localPath,
        downloadedAt?.millisecondsSinceEpoch,
      ],
    );

    return (await getDownloadStatus(userId, resourceId))!;
  }

  Future<void> deleteDownload(String userId, String resourceId) async {
    final db = _databaseService.database;
    await db.customStatement(
      'DELETE FROM downloaded_resources WHERE user_id = ? AND resource_id = ?',
      [userId, resourceId],
    );
  }

  Future<void> clearDownloads(String userId) async {
    final db = _databaseService.database;
    await db.customStatement(
      'DELETE FROM downloaded_resources WHERE user_id = ?',
      [userId],
    );
  }

  DownloadStatus _mapDownloadRow(QueryRow row) {
    final userId = row.read<String>('user_id');
    final resourceId = row.read<String>('resource_id');
    final downloadedAtMs = row.readNullable<int>('downloaded_at');

    return DownloadStatus(
      id: '${userId}_$resourceId',
      userId: userId,
      resourceId: resourceId,
      state: _mapDownloadState(row.read<String>('state')),
      progress: row.read<double>('progress'),
      localPath: row.readNullable<String>('local_path'),
      downloadedAt:
          downloadedAtMs != null ? DateTime.fromMillisecondsSinceEpoch(downloadedAtMs) : null,
    );
  }

  DownloadState _mapDownloadState(String state) {
    return DownloadState.values.firstWhere(
      (s) => s.name == state,
      orElse: () => DownloadState.notDownloaded,
    );
  }

  // ==================== RECENTLY VIEWED ====================

  Future<void> markAsViewed(String userId, String resourceId) async {
    final db = _databaseService.database;
    await db.customStatement(
      '''
      INSERT INTO recently_viewed_resources (user_id, resource_id, viewed_at)
      VALUES (?, ?, ?)
      ON CONFLICT(user_id, resource_id) DO UPDATE SET viewed_at = excluded.viewed_at
      ''',
      [userId, resourceId, DateTime.now().millisecondsSinceEpoch],
    );
  }

  Future<List<String>> getRecentlyViewedResourceIds(String userId, {int limit = 10}) async {
    final db = _databaseService.database;
    final rows = await db
        .customSelect(
          'SELECT resource_id FROM recently_viewed_resources WHERE user_id = ? '
          'ORDER BY viewed_at DESC LIMIT ?',
          variables: [Variable.withString(userId), Variable.withInt(limit)],
        )
        .get();

    return rows.map((row) => row.read<String>('resource_id')).toList();
  }
}
