import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepnode/core/data/database/database.dart';
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/core/data/seed/seed_data.dart';
import 'package:prepnode/features/mock_test/data/datasources/mock_test_local_datasource.dart';
import 'package:prepnode/features/mock_test/domain/entities/mock_test.dart';

class TestDatabaseService implements DatabaseService {
  final PrepNodeDatabase _db;

  TestDatabaseService(this._db);

  @override
  PrepNodeDatabase get database => _db;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The mock test catalog is generated from the question bank rather than
/// stored, so growing the bank is what makes the tests bigger. These assert
/// that the catalog the user actually sees is worth taking.
void main() {
  late PrepNodeDatabase db;
  late MockTestLocalDataSource source;

  setUpAll(() async {
    db = PrepNodeDatabase(NativeDatabase.memory());
    await SeedData.seedDatabase(db);
    source = MockTestLocalDataSource(databaseService: TestDatabaseService(db));
  });

  tearDownAll(() async => db.close());

  test('the catalog offers a full mock, subject tests and topic tests',
      () async {
    final tests = await source.getAvailableTestsLocal(examId: 'tnpsc-group2');

    final byType = <MockTestType, int>{};
    for (final t in tests) {
      byType[t.type] = (byType[t.type] ?? 0) + 1;
    }

    expect(byType[MockTestType.full], 1, reason: 'exactly one full mock');
    expect(byType[MockTestType.subject], 4,
        reason: 'one subject test per TNPSC subject');
    expect(byType[MockTestType.topic] ?? 0, greaterThanOrEqualTo(25),
        reason: 'a topic test for each topic that has questions');
  });

  test('the full mock is a substantial paper', () async {
    final full = await source.getTestConfigLocal('local-full-tnpsc-group2');

    expect(full, isNotNull);
    expect(full!.totalQuestions, greaterThanOrEqualTo(100),
        reason: 'the full mock draws on the whole bank');
    expect(full.durationMinutes, greaterThan(0));
  });

  test('every subject test has enough questions to be meaningful', () async {
    final tests = await source.getAvailableTestsLocal(
      examId: 'tnpsc-group2',
      type: MockTestType.subject,
    );

    expect(tests, isNotEmpty);
    for (final test in tests) {
      expect(test.totalQuestions, greaterThanOrEqualTo(5),
          reason: '${test.title} has only ${test.totalQuestions} questions');
    }
  });

  test('no topic test is trivially short', () async {
    final tests = await source.getAvailableTestsLocal(
      examId: 'tnpsc-group2',
      type: MockTestType.topic,
    );

    expect(tests, isNotEmpty);
    for (final test in tests) {
      expect(test.totalQuestions, greaterThanOrEqualTo(3),
          reason: '${test.title} has only ${test.totalQuestions} questions');
    }
  });

  test('every listed test can actually be started', () async {
    final tests = await source.getAvailableTestsLocal(examId: 'tnpsc-group2');

    for (final test in tests) {
      final config = await source.getTestConfigLocal(test.id);
      expect(config, isNotNull,
          reason: '${test.id} is listed but cannot be resolved');
    }
  });
}
