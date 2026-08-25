import 'package:dartz/dartz.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/strategy/domain/entities/roadmap.dart';
import 'package:prepgraph/features/strategy/domain/entities/strategy_recommendation.dart';
import 'package:prepgraph/features/strategy/domain/entities/strategy_summary.dart';
import 'package:prepgraph/features/strategy/domain/entities/study_capacity.dart';

/// Strategy Repository Interface
///
/// The PrepGraph Strategy Engine's contract. Every implementation composes
/// existing repositories (Insights, PYQ, Planner, Cutoff, Knowledge Graph,
/// Profile) — there is no dedicated strategy datasource or backend; this is
/// a synthesis layer over data those modules already maintain.
abstract class StrategyRepository {
  Future<Either<Failure, StudyCapacity>> getStudyCapacity(String userId);

  Future<Either<Failure, List<StrategyRecommendation>>> getNextBestTopics({
    required String userId,
    required String examId,
    required String category,
    int limit = 5,
  });

  Future<Either<Failure, Roadmap>> getRoadmap({
    required String userId,
    required String examId,
    required String category,
    required int days,
  });

  Future<Either<Failure, StrategySummary>> getStrategySummary({
    required String userId,
    required String examId,
    required String category,
  });
}
