// Unit tests for CutoffRepositoryImpl — the highest-risk repository in the
// app (real, complex readiness/recommendation math; already responsible for
// one confirmed production bug this project shipped: an assumed 200-mark
// exam scale instead of the real 300-mark TNPSC Group 2 scale, corrected in
// Phase 1B via ExamScale). These tests exist to catch a regression of that
// exact bug class, plus the category-cutoff fallback and gap-closing
// recommendation ranking logic, which are pure computation over mocked
// dependencies — no database or network involved.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/auth/domain/entities/user.dart';
import 'package:prepgraph/features/auth/domain/repositories/profile_repository.dart';
import 'package:prepgraph/features/cutoff/data/datasources/cutoff_local_datasource.dart';
import 'package:prepgraph/features/cutoff/data/repositories/cutoff_repository_impl.dart';
import 'package:prepgraph/features/cutoff/domain/entities/category_cutoff.dart';
import 'package:prepgraph/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepgraph/features/insights/domain/entities/learner_progress.dart';
import 'package:prepgraph/features/insights/domain/entities/mastery_analytics.dart';
import 'package:prepgraph/features/insights/domain/entities/mock_test_analytics.dart';
import 'package:prepgraph/features/insights/domain/repositories/insights_repository.dart';
import 'package:prepgraph/features/knowledge_graph/domain/entities/graph_node.dart';
import 'package:prepgraph/features/knowledge_graph/domain/repositories/knowledge_graph_repository.dart';
import 'package:prepgraph/features/pyq/domain/entities/topic_pyq_summary.dart';
import 'package:prepgraph/features/pyq/domain/repositories/pyq_repository.dart';

class MockCutoffLocalDataSource extends Mock implements CutoffLocalDataSource {}

class MockInsightsRepository extends Mock implements InsightsRepository {}

class MockPyqRepository extends Mock implements PyqRepository {}

class MockKnowledgeGraphRepository extends Mock implements KnowledgeGraphRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockCutoffLocalDataSource localDataSource;
  late MockInsightsRepository insightsRepository;
  late MockPyqRepository pyqRepository;
  late MockKnowledgeGraphRepository knowledgeGraphRepository;
  late MockProfileRepository profileRepository;
  late CutoffRepositoryImpl repository;

  const userId = 'user-1';
  const examId = 'tnpsc-group2';

  setUp(() {
    localDataSource = MockCutoffLocalDataSource();
    insightsRepository = MockInsightsRepository();
    pyqRepository = MockPyqRepository();
    knowledgeGraphRepository = MockKnowledgeGraphRepository();
    profileRepository = MockProfileRepository();
    repository = CutoffRepositoryImpl(
      localDataSource: localDataSource,
      insightsRepository: insightsRepository,
      pyqRepository: pyqRepository,
      knowledgeGraphRepository: knowledgeGraphRepository,
      profileRepository: profileRepository,
    );

    // Common stubs every getReadinessPrediction call needs; individual
    // tests override whichever ones matter to them.
    when(() => profileRepository.getProfile(userId: any(named: 'userId'))).thenAnswer(
      (_) async => Right(User(
        id: userId,
        name: 'Test User',
        email: 't@example.com',
        profileComplete: true,
        targetDate: DateTime.now().add(const Duration(days: 84)), // ~12 weeks
      )),
    );
    when(() => insightsRepository.getMockTestAnalytics(any())).thenAnswer(
      (_) async => Right(MockTestAnalytics(
        userId: userId,
        attempts: const [],
        subjectStats: const SubjectMockTestStats(
          subjectId: 'subject-general-studies',
          subjectName: 'General Studies',
          totalAttempts: 0,
          averageScore: 0,
          averageAccuracy: 0,
          bestScore: 0,
          worstScore: 0,
          trend: ScoreTrend.stable,
        ),
        lastUpdated: DateTime.now(),
      )),
    );
    when(() => insightsRepository.getMasteryAnalytics(any())).thenAnswer(
      (_) async => Right(MasteryAnalytics(
        userId: userId,
        topicMasteries: const [],
        lastUpdated: DateTime.now(),
      )),
    );
  });

  ExamCutoff examCutoffWith(List<CategoryCutoff> categoryCutoffs) {
    return ExamCutoff(
      examId: examId,
      examName: 'TNPSC Group 2',
      conductingBody: 'TNPSC',
      categoryCutoffs: categoryCutoffs,
      yearlyTrends: const [],
    );
  }

  group('getReadinessPrediction — exam mark-scale correctness', () {
    test(
      'projects PrepGraph Score onto the real 300-mark TNPSC Group 2 scale, '
      'not the old (incorrect) 200-mark assumption',
      () async {
        when(() => localDataSource.getExamCutoffLocal(examId)).thenAnswer(
          (_) async => examCutoffWith([
            const CategoryCutoff(category: 'OC', cutoffMark: 175.0, year: 2019),
            const CategoryCutoff(category: 'OC', cutoffMark: 185.0, year: 2023),
            const CategoryCutoff(category: 'BC', cutoffMark: 178.0, year: 2023),
          ]),
        );
        when(() => insightsRepository.getLearnerProgress(userId)).thenAnswer(
          (_) async => Right(LearnerProgress(
            userId: userId,
            prepGraphScore: 50.0,
            scoreComponents: const ScoreComponents(
              topicCompletion: 0.5,
              pyqPerformance: 0.5,
              mockAccuracy: 0.5,
              consistency: 0.5,
              revisionDiscipline: 0.5,
            ),
            lastUpdated: DateTime.now(),
          )),
        );

        final result = await repository.getReadinessPrediction(userId, examId, category: 'OC');

        expect(result.isRight(), isTrue);
        final prediction = result.getOrElse(() => throw StateError('expected Right'));
        // 50/100 * 300 = 150 — a regression to the old bug would yield 100
        // (50/100 * 200) instead.
        expect(prediction.currentScore, 150.0);
        // The exam's OFFICIAL qualifying mark (90/300), NOT a row from
        // cutoff_data. Those rows were never sourced from a TNPSC document,
        // and this prediction is shown on Home, the Planner and the Mock
        // Test result screen — so benchmarking against them put invented
        // targets in front of exam aspirants in four places.
        expect(prediction.targetCutoff, 90.0);
        expect(prediction.predictedScore, 150.0);
        // Already past the qualifying mark, so readiness clamps at 100%.
        expect(prediction.readinessPercentage, 100.0);
        expect(prediction.readinessLevel, 'excellent');
      },
    );

    test('uses the same official qualifying mark regardless of the reservation '
        'category, since the qualifying mark is not category-specific', () async {
      when(() => insightsRepository.getLearnerProgress(userId)).thenAnswer(
        (_) async => Right(LearnerProgress(
          userId: userId,
          prepGraphScore: 0.0,
          scoreComponents: const ScoreComponents(
            topicCompletion: 0,
            pyqPerformance: 0,
            mockAccuracy: 0,
            consistency: 0,
            revisionDiscipline: 0,
          ),
          lastUpdated: DateTime.now(),
        )),
      );

      final oc = await repository.getReadinessPrediction(userId, examId, category: 'OC');
      final st = await repository.getReadinessPrediction(userId, examId, category: 'ST');

      expect(
        oc.getOrElse(() => throw StateError('expected Right')).targetCutoff,
        90.0,
      );
      expect(
        st.getOrElse(() => throw StateError('expected Right')).targetCutoff,
        90.0,
      );
    });

    test('returns a not-found failure for an exam with no verified qualifying '
        'mark, rather than guessing a target', () async {
      when(() => insightsRepository.getLearnerProgress(any())).thenAnswer(
        (_) async => Right(LearnerProgress(
          userId: userId,
          prepGraphScore: 50.0,
          scoreComponents: const ScoreComponents(
            topicCompletion: 0.5,
            pyqPerformance: 0.5,
            mockAccuracy: 0.5,
            consistency: 0.5,
            revisionDiscipline: 0.5,
          ),
          lastUpdated: DateTime.now(),
        )),
      );

      // Only tnpsc-group2 has a verified qualifying mark in ExamScale.
      final result = await repository.getReadinessPrediction(userId, 'tnpsc-group4');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('getCutoffAnalysis — gap-closing recommendation ranking', () {
    test('ranks topics by frequency × (1 - mastery) descending and drops '
        'topics with zero PYQ frequency', () async {
      when(() => localDataSource.getExamCutoffLocal(examId)).thenAnswer(
        (_) async => examCutoffWith([
          const CategoryCutoff(category: 'OC', cutoffMark: 185.0, year: 2023),
        ]),
      );
      when(() => insightsRepository.getLearnerProgress(userId)).thenAnswer(
        (_) async => Right(LearnerProgress(
          userId: userId,
          prepGraphScore: 50.0,
          scoreComponents: const ScoreComponents(
            topicCompletion: 0.5,
            pyqPerformance: 0.5,
            mockAccuracy: 0.5,
            consistency: 0.5,
            revisionDiscipline: 0.5,
          ),
          lastUpdated: DateTime.now(),
        )),
      );
      when(() => knowledgeGraphRepository.getSubjects(examId: any(named: 'examId'))).thenAnswer(
        (_) async => const Right([
          GraphNode(
            id: 'subject-general-studies',
            name: 'General Studies',
            type: NodeType.subject,
            masteryState: MasteryState.inProgress,
            masteryPercentage: 0.5,
          ),
        ]),
      );
      when(() => insightsRepository.getMasteryAnalytics(userId)).thenAnswer(
        (_) async => Right(MasteryAnalytics(
          userId: userId,
          topicMasteries: [
            TopicMastery(
              topicId: 't1',
              topicName: 'Topic One',
              subjectId: 'subject-general-studies',
              subjectName: 'General Studies',
              masteryPercentage: 0.8, // high mastery -> low gap
              level: MasteryLevel.building,
              questionsAttempted: 4,
              questionsCorrect: 3,
              studyMinutes: 30,
              lastStudied: DateTime.now(),
            ),
            TopicMastery(
              topicId: 't2',
              topicName: 'Topic Two',
              subjectId: 'subject-general-studies',
              subjectName: 'General Studies',
              masteryPercentage: 0.1, // low mastery -> high gap
              level: MasteryLevel.inProgress,
              questionsAttempted: 1,
              questionsCorrect: 0,
              studyMinutes: 10,
              lastStudied: DateTime.now(),
            ),
          ],
          lastUpdated: DateTime.now(),
        )),
      );
      when(() => pyqRepository.getTopicSummaries(
            examId: any(named: 'examId'),
            subjectId: any(named: 'subjectId'),
            userId: any(named: 'userId'),
          )).thenAnswer(
        (_) async => const Right([
          TopicPyqSummary(
            topicId: 't1',
            topicName: 'Topic One',
            totalQuestions: 5,
            solvedQuestions: 2,
            bookmarkedQuestions: 0,
            incorrectQuestions: 1,
            averageAccuracy: 0.5,
            frequencyCount: 5, // gapScore = 5 * (1 - 0.8) = 1.0
            yearsAppeared: [2021, 2022],
          ),
          TopicPyqSummary(
            topicId: 't2',
            topicName: 'Topic Two',
            totalQuestions: 2,
            solvedQuestions: 0,
            bookmarkedQuestions: 0,
            incorrectQuestions: 0,
            averageAccuracy: 0.0,
            frequencyCount: 2, // gapScore = 2 * (1 - 0.1) = 1.8 -> ranks first
            yearsAppeared: [2020],
          ),
          TopicPyqSummary(
            topicId: 't3',
            topicName: 'Never Appeared',
            totalQuestions: 0,
            solvedQuestions: 0,
            bookmarkedQuestions: 0,
            incorrectQuestions: 0,
            averageAccuracy: 0.0,
            frequencyCount: 0, // must be excluded entirely
            yearsAppeared: [],
          ),
        ]),
      );

      final result = await repository.getCutoffAnalysis(userId, examId, category: 'OC');

      expect(result.isRight(), isTrue);
      final analysis = result.getOrElse(() => throw StateError('expected Right'));
      final recs = analysis.personalizedRecommendations;
      expect(recs.length, 2, reason: 'the zero-frequency topic must be dropped');
      expect(recs.first.topicId, 't2', reason: 'higher gapScore (1.8) must rank before t1 (1.0)');
      expect(recs.last.topicId, 't1');
    });
  });
}
