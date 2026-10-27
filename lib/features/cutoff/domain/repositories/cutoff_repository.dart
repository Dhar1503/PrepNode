import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/cutoff/domain/entities/cutoff_analysis.dart';
import 'package:prepnode/features/cutoff/domain/entities/exam_cutoff.dart';
import 'package:prepnode/features/cutoff/domain/entities/readiness_prediction.dart';

/// Repository interface for cutoff intelligence operations
/// Abstracts data source to enable easy backend integration later
abstract class CutoffRepository {
  /// Get historical cutoff data for a specific exam
  Future<Either<Failure, ExamCutoff>> getExamCutoff(String examId);

  /// Get comprehensive cutoff analysis for a user, compared against the
  /// cutoff for their reservation [category] (defaults to 'OC').
  Future<Either<Failure, CutoffAnalysis>> getCutoffAnalysis(
    String userId,
    String examId, {
    String category = 'OC',
  });

  /// Get readiness prediction for a user, compared against the cutoff for
  /// their reservation [category] (defaults to 'OC').
  Future<Either<Failure, ReadinessPrediction>> getReadinessPrediction(
    String userId,
    String examId, {
    String category = 'OC',
  });

  /// Get list of available exams with cutoff data
  Future<Either<Failure, List<ExamCutoff>>> getAvailableExams();
}
