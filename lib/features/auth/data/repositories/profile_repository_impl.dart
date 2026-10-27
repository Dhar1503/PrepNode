import 'package:dartz/dartz.dart';
import 'package:prepnode/core/data/database/database_service.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:prepnode/features/auth/domain/entities/exam.dart';
import 'package:prepnode/features/auth/domain/entities/user.dart';
import 'package:prepnode/features/auth/domain/repositories/profile_repository.dart';

/// Profile Repository Implementation
/// Persists profile data via the local Drift database (users/exams tables).
class ProfileRepositoryImpl implements ProfileRepository {
  final AuthLocalDataSource _localDataSource;
  final DatabaseService _databaseService;

  ProfileRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required DatabaseService databaseService,
  })  : _localDataSource = localDataSource,
        _databaseService = databaseService;

  @override
  Future<Either<Failure, List<Exam>>> getExams() async {
    try {
      final db = _databaseService.database;
      final exams = await db.select(db.exams).get();

      return Right(exams
          .map((exam) => Exam(
                id: exam.examId,
                name: exam.examName,
                description: exam.description,
                conductingBody: exam.conductingBody,
                comingSoon: exam.comingSoon,
              ))
          .toList());
    } catch (e) {
      return Left(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? name,
    String? examId,
    DateTime? targetDate,
    int? dailyStudyHours,
    String? preparationLevel,
  }) async {
    try {
      if (dailyStudyHours != null && (dailyStudyHours < 1 || dailyStudyHours > 16)) {
        return const Left(ValidationFailure('Daily study hours must be between 1 and 16'));
      }

      if (targetDate != null && targetDate.isBefore(DateTime.now())) {
        return const Left(ValidationFailure('Target date cannot be in the past'));
      }

      final existingUser = await _localDataSource.getUser(userId);
      if (existingUser == null) {
        return Left(DatabaseFailure.notFound(entity: 'User'));
      }

      final mergedExamId = examId ?? existingUser.examId;
      final mergedTargetDate = targetDate ?? existingUser.targetDate;
      final mergedDailyStudyHours = dailyStudyHours ?? existingUser.dailyStudyHours;
      final mergedPreparationLevel = preparationLevel ?? existingUser.preparationLevel;
      final isComplete = mergedExamId != null &&
          mergedTargetDate != null &&
          mergedDailyStudyHours != null &&
          mergedPreparationLevel != null;

      final updatedUser = existingUser.copyWith(
        name: name,
        examId: examId,
        targetDate: targetDate,
        dailyStudyHours: dailyStudyHours,
        preparationLevel: preparationLevel,
        profileComplete: isComplete,
      );

      await _localDataSource.saveUser(updatedUser);

      return Right(updatedUser);
    } catch (e) {
      return Left(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile({
    required String userId,
  }) async {
    try {
      final user = await _localDataSource.getUser(userId);
      if (user == null) {
        return Left(DatabaseFailure.notFound(entity: 'User'));
      }
      return Right(user);
    } catch (e) {
      return Left(DatabaseFailure.queryFailed(originalError: e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    // No remote file-storage backend exists in this project; persist the
    // given path against the user record so the local reference survives.
    try {
      final existingUser = await _localDataSource.getUser(userId);
      if (existingUser == null) {
        return Left(DatabaseFailure.notFound(entity: 'User'));
      }

      final updatedUser = existingUser.copyWith(avatarUrl: filePath);
      await _localDataSource.saveUser(updatedUser);

      return Right(filePath);
    } catch (e) {
      return Left(DatabaseFailure.queryFailed(originalError: e));
    }
  }
}
