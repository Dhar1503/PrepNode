import 'package:dartz/dartz.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/insights/domain/entities/learner_progress.dart';
import 'package:prepgraph/features/insights/domain/entities/mastery_analytics.dart';
import 'package:prepgraph/features/insights/domain/entities/pyq_performance.dart';
import 'package:prepgraph/features/insights/domain/entities/mock_test_analytics.dart';
import 'package:prepgraph/features/insights/domain/entities/study_habits.dart';
import 'package:prepgraph/features/insights/domain/entities/weak_area.dart';

/// Insights Repository Interface
/// Abstract repository for insights and analytics data
abstract class InsightsRepository {
  /// Get learner progress including PrepGraph Score
  Future<Either<Failure, LearnerProgress>> getLearnerProgress(String userId);

  /// Get mastery analytics across all topics
  Future<Either<Failure, MasteryAnalytics>> getMasteryAnalytics(String userId);

  /// Get PYQ performance analytics
  Future<Either<Failure, PyqPerformance>> getPyqPerformance(String userId);

  /// Get mock test analytics
  Future<Either<Failure, MockTestAnalytics>> getMockTestAnalytics(String userId);

  /// Get study habits and time analytics
  Future<Either<Failure, StudyHabits>> getStudyHabits(String userId);

  /// Get weak areas and recommendations
  Future<Either<Failure, WeakArea>> getWeakAreas(String userId);

  /// Get mastery analytics for a specific subject
  Future<Either<Failure, MasteryAnalytics>> getSubjectMastery(
    String userId,
    String subjectId,
  );

  /// Get PYQ performance for a specific subject
  Future<Either<Failure, PyqPerformance>> getSubjectPyqPerformance(
    String userId,
    String subjectId,
  );

  /// Mark a recommendation as completed
  Future<Either<Failure, void>> markRecommendationCompleted(
    String userId,
    String recommendationId,
  );
}
