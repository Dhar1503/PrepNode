// Unit tests for ResourceRepositoryImpl — chosen for the top-3 pass because
// this exact class has a proven history of a real bug in this project
// (topic/subject IDs that didn't match any real seeded row, self-audited
// and fixed in Phase 1B) and contains non-trivial assembly logic on top of
// the remote-then-local fallback pattern every repository in this app uses
// (curated recommendations, static collections, recency ordering). No
// database or network is exercised — both datasources are mocked.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prepnode/features/resources/data/datasources/resource_local_datasource.dart';
import 'package:prepnode/features/resources/data/datasources/resource_remote_datasource.dart';
import 'package:prepnode/features/resources/data/repositories/resource_repository_impl.dart';
import 'package:prepnode/features/resources/domain/entities/study_resource.dart';
import 'package:prepnode/features/resources/domain/repositories/resource_repository.dart';

class MockResourceRemoteDataSource extends Mock implements ResourceRemoteDataSource {}

class MockResourceLocalDataSource extends Mock implements ResourceLocalDataSource {}

StudyResource _resource(String id, {String topicId = 'topic-x'}) {
  return StudyResource(
    id: id,
    title: 'Resource $id',
    description: 'desc',
    type: ResourceType.pdf,
    url: 'https://example.com/$id.pdf',
    subjectId: 'subject-general-studies',
    topicId: topicId,
    author: 'Author',
    durationMinutes: 0,
    pageCount: 10,
    difficulty: 'beginner',
    rating: 4.0,
    viewCount: 0,
    publishedDate: DateTime(2024, 1, 1),
    tags: const [],
    isOfficial: false,
    isDownloadable: true,
  );
}

void main() {
  late MockResourceRemoteDataSource remoteDataSource;
  late MockResourceLocalDataSource localDataSource;
  late ResourceRepository repository;

  setUp(() {
    remoteDataSource = MockResourceRemoteDataSource();
    localDataSource = MockResourceLocalDataSource();
    repository = ResourceRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  });

  group('remote-then-local fallback', () {
    test('getResourcesBySubject returns remote data without touching local '
        'when the remote call succeeds', () async {
      final remoteResult = [_resource('res-remote')];
      when(() => remoteDataSource.getResourcesBySubject(
            any(),
            topicId: any(named: 'topicId'),
            type: any(named: 'type'),
            difficulty: any(named: 'difficulty'),
          )).thenAnswer((_) async => remoteResult);

      final result = await repository.getResourcesBySubject('subject-general-studies');

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []).map((r) => r.id), remoteResult.map((r) => r.id));
      verifyNever(() => localDataSource.getResourcesBySubject(
            any(),
            topicId: any(named: 'topicId'),
            type: any(named: 'type'),
            difficulty: any(named: 'difficulty'),
          ));
    });

    test('getResourcesBySubject falls back to local data when the remote '
        'call throws (the real state of this app — no backend exists)', () async {
      when(() => remoteDataSource.getResourcesBySubject(
            any(),
            topicId: any(named: 'topicId'),
            type: any(named: 'type'),
            difficulty: any(named: 'difficulty'),
          )).thenThrow(Exception('no backend'));
      final localResult = [_resource('res-local')];
      when(() => localDataSource.getResourcesBySubject(
            any(),
            topicId: any(named: 'topicId'),
            type: any(named: 'type'),
            difficulty: any(named: 'difficulty'),
          )).thenAnswer((_) async => localResult);

      final result = await repository.getResourcesBySubject('subject-general-studies');

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []).map((r) => r.id), localResult.map((r) => r.id));
    });

    test('getResourcesBySubject returns a Left failure when both remote and '
        'local fail', () async {
      when(() => remoteDataSource.getResourcesBySubject(
            any(),
            topicId: any(named: 'topicId'),
            type: any(named: 'type'),
            difficulty: any(named: 'difficulty'),
          )).thenThrow(Exception('no backend'));
      when(() => localDataSource.getResourcesBySubject(
            any(),
            topicId: any(named: 'topicId'),
            type: any(named: 'type'),
            difficulty: any(named: 'difficulty'),
          )).thenThrow(Exception('db error'));

      final result = await repository.getResourcesBySubject('subject-general-studies');

      expect(result.isLeft(), isTrue);
    });
  });

  group('getRecommendedResources — curated fallback assembly', () {
    test('attaches reason/relevanceScore/sourceModule to each resource '
        'looked up from the local catalog, in the curated definition order, '
        'and silently skips a curated id the catalog no longer has', () async {
      when(() => remoteDataSource.getRecommendedResources(any())).thenThrow(Exception('no backend'));
      // The curated list references the verified resources res-4, res-21,
      // res-6 — simulate res-21 being unavailable from the catalog (the
      // local datasource hides any row without a real link).
      when(() => localDataSource.getResourcesByIds(any())).thenAnswer(
        (_) async => [_resource('res-4'), _resource('res-6')],
      );

      final result = await repository.getRecommendedResources('user-1');

      expect(result.isRight(), isTrue);
      final recs = result.getOrElse(() => throw StateError('expected Right'));
      expect(recs.map((r) => r.resource.id).toList(), ['res-4', 'res-6']);
      expect(recs.every((r) => r.reason.isNotEmpty), isTrue);
      expect(recs.every((r) => r.relevanceScore > 0), isTrue);
    });
  });

  group('getResourceCollections — static curated fallback', () {
    test('maps the built-in collection definitions when remote fails', () async {
      when(() => remoteDataSource.getResourceCollections()).thenThrow(Exception('no backend'));

      final result = await repository.getResourceCollections();

      expect(result.isRight(), isTrue);
      final collections = result.getOrElse(() => throw StateError('expected Right'));
      expect(collections.length, 3);
      expect(collections.map((c) => c.id), containsAll(['coll-1', 'coll-2', 'coll-3']));
      final official = collections.firstWhere((c) => c.id == 'coll-3');
      expect(official.isOfficial, isTrue);
      expect(official.totalResources, official.resourceIds.length);
    });
  });

  group('getResourcesInCollection', () {
    test('looks up the real resources for a known curated collection id when '
        'remote fails', () async {
      when(() => remoteDataSource.getResourcesInCollection(any())).thenThrow(Exception('no backend'));
      final localResult = [_resource('res-1'), _resource('res-2')];
      when(() => localDataSource.getResourcesByIds(any())).thenAnswer((_) async => localResult);

      final result = await repository.getResourcesInCollection('coll-1');

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []).map((r) => r.id), localResult.map((r) => r.id));
    });

    test('returns a Left failure for an unknown collection id instead of '
        'throwing', () async {
      when(() => remoteDataSource.getResourcesInCollection(any())).thenThrow(Exception('no backend'));

      final result = await repository.getResourcesInCollection('coll-does-not-exist');

      expect(result.isLeft(), isTrue);
    });
  });

  group('getRecentlyViewed — recency order preservation', () {
    test('returns resources in the same order as the recently-viewed id '
        'list, even though the catalog lookup does not guarantee order', () async {
      when(() => localDataSource.getRecentlyViewedResourceIds(any())).thenAnswer(
        (_) async => ['res-3', 'res-1', 'res-2'],
      );
      // Catalog lookup deliberately returns them in a different order.
      when(() => localDataSource.getResourcesByIds(any())).thenAnswer(
        (_) async => [_resource('res-1'), _resource('res-2'), _resource('res-3')],
      );

      final result = await repository.getRecentlyViewed('user-1');

      final ordered = result.getOrElse(() => throw StateError('expected Right'));
      expect(ordered.map((r) => r.id).toList(), ['res-3', 'res-1', 'res-2']);
    });
  });
}
