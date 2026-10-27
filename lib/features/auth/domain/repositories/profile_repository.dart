import 'package:dartz/dartz.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/auth/domain/entities/exam.dart';
import 'package:prepnode/features/auth/domain/entities/user.dart';

/// Profile Repository Interface
/// Abstract contract for profile operations
abstract class ProfileRepository {
  /// Get available exams
  Future<Either<Failure, List<Exam>>> getExams();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? name,
    String? examId,
    DateTime? targetDate,
    int? dailyStudyHours,
    String? preparationLevel,
  });

  /// Get user profile
  Future<Either<Failure, User>> getProfile({
    required String userId,
  });

  /// Upload avatar
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required String filePath,
  });
}
