import '../datasources/content_local_datasource.dart';
import '../dtos/content_dto.dart';
import '../result.dart';
import 'base_repository.dart';
import 'package:uuid/uuid.dart';

/// Repository for Content-related operations
/// Handles Exams, Subjects, Topics, Questions, Resources, Cutoff Data
class ContentRepository extends BaseRepositoryImpl {
  final ContentLocalDataSource _localDataSource;

  ContentRepository(this._localDataSource);

  // ==================== EXAMS ====================

  /// Get all exams
  Future<Result<List<Map<String, dynamic>>>> getAllExams() async {
    try {
      final result = await _localDataSource.getAllExams();
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Get exam by ID
  Future<Result<Map<String, dynamic>>> getExamById(String examId) async {
    try {
      final result = await _localDataSource.getExamById(examId);
      return result.fold(
        onSuccess: (dto) => Result.success(dto.toDomainMap()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Upsert exam
  Future<Result<void>> upsertExam(Map<String, dynamic> examData) async {
    try {
      final dto = ExamDto(
        examId: examData['id'] as String? ?? const Uuid().v4(),
        examName: examData['name'] as String,
        description: examData['description'] as String?,
        conductingBody: examData['conductingBody'] as String?,
        comingSoon: examData['comingSoon'] as bool? ?? false,
        createdAt: examData['createdAt'] as DateTime? ?? DateTime.now(),
      );

      final result = await _localDataSource.upsertExam(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== SUBJECTS ====================

  /// Get subjects for an exam
  Future<Result<List<Map<String, dynamic>>>> getSubjectsByExam(String examId) async {
    try {
      final result = await _localDataSource.getSubjectsByExam(examId);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Upsert subject
  Future<Result<void>> upsertSubject(Map<String, dynamic> subjectData) async {
    try {
      final dto = SubjectDto(
        subjectId: subjectData['id'] as String? ?? const Uuid().v4(),
        examId: subjectData['examId'] as String,
        subjectName: subjectData['name'] as String,
        importanceWeight: (subjectData['importanceWeight'] as num?)?.toDouble() ?? 0.50,
      );

      final result = await _localDataSource.upsertSubject(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== TOPICS ====================

  /// Get topics for a subject
  Future<Result<List<Map<String, dynamic>>>> getTopicsBySubject(String subjectId) async {
    try {
      final result = await _localDataSource.getTopicsBySubject(subjectId);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Get topic by ID
  Future<Result<Map<String, dynamic>>> getTopicById(String topicId) async {
    try {
      final result = await _localDataSource.getTopicById(topicId);
      return result.fold(
        onSuccess: (dto) => Result.success(dto.toDomainMap()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Upsert topic
  Future<Result<void>> upsertTopic(Map<String, dynamic> topicData) async {
    try {
      final dto = TopicDto(
        topicId: topicData['id'] as String? ?? const Uuid().v4(),
        subjectId: topicData['subjectId'] as String,
        parentTopicId: topicData['parentTopicId'] as String?,
        topicName: topicData['name'] as String,
        difficulty: topicData['difficulty'] as String? ?? 'medium',
        importanceScore: (topicData['importanceScore'] as num?)?.toDouble() ?? 0.50,
      );

      final result = await _localDataSource.upsertTopic(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== QUESTIONS ====================

  /// Get questions for a topic
  Future<Result<List<Map<String, dynamic>>>> getQuestionsByTopic(String topicId) async {
    try {
      final result = await _localDataSource.getQuestionsByTopic(topicId);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Upsert question
  Future<Result<void>> upsertQuestion(Map<String, dynamic> questionData) async {
    try {
      final dto = QuestionDto(
        questionId: questionData['id'] as String? ?? const Uuid().v4(),
        examId: questionData['examId'] as String,
        subjectId: questionData['subjectId'] as String,
        topicId: questionData['topicId'] as String,
        year: questionData['year'] as int,
        questionText: questionData['text'] as String,
        optionA: questionData['options'][0] as String,
        optionB: questionData['options'][1] as String,
        optionC: questionData['options'][2] as String,
        optionD: questionData['options'][3] as String,
        correctAnswer: questionData['correctAnswer'] as String,
        explanation: questionData['explanation'] as String?,
        difficulty: questionData['difficulty'] as String? ?? 'medium',
        createdAt: questionData['createdAt'] as DateTime? ?? DateTime.now(),
      );

      final result = await _localDataSource.upsertQuestion(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== RESOURCES ====================

  /// Get resources for a topic
  Future<Result<List<Map<String, dynamic>>>> getResourcesByTopic(String topicId) async {
    try {
      final result = await _localDataSource.getResourcesByTopic(topicId);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Upsert resource
  Future<Result<void>> upsertResource(Map<String, dynamic> resourceData) async {
    try {
      final dto = ResourceDto(
        resourceId: resourceData['id'] as String? ?? const Uuid().v4(),
        topicId: resourceData['topicId'] as String,
        title: resourceData['title'] as String,
        type: resourceData['type'] as String,
        link: resourceData['link'] as String,
        averageRating: (resourceData['averageRating'] as num?)?.toDouble() ?? 0.0,
        ratingCount: resourceData['ratingCount'] as int? ?? 0,
      );

      final result = await _localDataSource.upsertResource(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  // ==================== CUTOFF DATA ====================

  /// Get cutoff data for an exam
  Future<Result<List<Map<String, dynamic>>>> getCutoffDataByExam(String examId) async {
    try {
      final result = await _localDataSource.getCutoffDataByExam(examId);
      return result.fold(
        onSuccess: (dtos) => Result.success(dtos.map((d) => d.toDomainMap()).toList()),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  /// Upsert cutoff data
  Future<Result<void>> upsertCutoffData(Map<String, dynamic> cutoffData) async {
    try {
      final dto = CutoffDatumDto(
        cutoffId: cutoffData['id'] as String? ?? const Uuid().v4(),
        examId: cutoffData['examId'] as String,
        year: cutoffData['year'] as int,
        category: cutoffData['category'] as String,
        cutoffMark: (cutoffData['cutoffMark'] as num).toDouble(),
        vacancyCount: cutoffData['vacancyCount'] as int?,
      );

      final result = await _localDataSource.upsertCutoffData(dto);
      return result.fold(
        onSuccess: (_) => Result.success(null),
        onFailure: (failure) => Result.failure(failure),
      );
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }

  @override
  Future<Result<void>> clearCache() async {
    try {
      await _localDataSource.clearAll();
      return Result.success(null);
    } catch (e) {
      return Result.failure(handleError(e));
    }
  }
}
