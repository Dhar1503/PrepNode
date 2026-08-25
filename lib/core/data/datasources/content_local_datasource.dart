import '../database/database.dart';
import '../dtos/content_dto.dart';
import '../failures.dart';
import '../result.dart';
import 'local_datasource.dart';
import 'package:drift/drift.dart';

/// Local data source for Content-related operations
/// Handles Exams, Subjects, Topics, Questions, Resources, Cutoff Data
class ContentLocalDataSource extends BaseLocalDataSource {
  ContentLocalDataSource(super.database);

  // ==================== EXAMS ====================

  /// Get all exams
  Future<Result<List<ExamDto>>> getAllExams() async {
    try {
      final results = await database.select(database.exams).get();

      final dtos = results.map((e) => ExamDto(
        examId: e.examId,
        examName: e.examName,
        description: e.description,
        conductingBody: e.conductingBody,
        comingSoon: e.comingSoon,
        createdAt: e.createdAt,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Get exam by ID
  Future<Result<ExamDto>> getExamById(String examId) async {
    try {
      final result = await (database.select(database.exams)
            ..where((tbl) => tbl.examId.equals(examId))
            ..limit(1))
          .getSingleOrNull();

      if (result == null) {
        return Result.failure(DatabaseFailure.notFound(entity: 'Exam'));
      }

      final dto = ExamDto(
        examId: result.examId,
        examName: result.examName,
        description: result.description,
        conductingBody: result.conductingBody,
        comingSoon: result.comingSoon,
        createdAt: result.createdAt,
      );

      return Result.success(dto);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Upsert exam
  Future<Result<ExamDto>> upsertExam(ExamDto exam) async {
    try {
      final existing = await (database.select(database.exams)
            ..where((tbl) => tbl.examId.equals(exam.examId)))
          .getSingleOrNull();

      if (existing != null) {
        await database.update(database.exams).replace(
          ExamsCompanion(
            examId: Value(exam.examId),
            examName: Value(exam.examName),
            description: Value(exam.description),
            conductingBody: Value(exam.conductingBody),
            comingSoon: Value(exam.comingSoon),
          ),
        );
      } else {
        await database.into(database.exams).insert(
          ExamsCompanion.insert(
            examId: exam.examId,
            examName: exam.examName,
            comingSoon: Value(exam.comingSoon),
          ),
        );
      }

      return Result.success(exam);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== SUBJECTS ====================

  /// Get subjects for an exam
  Future<Result<List<SubjectDto>>> getSubjectsByExam(String examId) async {
    try {
      final results = await (database.select(database.subjects)
            ..where((tbl) => tbl.examId.equals(examId)))
          .get();

      final dtos = results.map((s) => SubjectDto(
        subjectId: s.subjectId,
        examId: s.examId,
        subjectName: s.subjectName,
        importanceWeight: s.importanceWeight,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Upsert subject
  Future<Result<SubjectDto>> upsertSubject(SubjectDto subject) async {
    try {
      final existing = await (database.select(database.subjects)
            ..where((tbl) => tbl.subjectId.equals(subject.subjectId)))
          .getSingleOrNull();

      if (existing != null) {
        await database.update(database.subjects).replace(
          SubjectsCompanion(
            subjectId: Value(subject.subjectId),
            examId: Value(subject.examId),
            subjectName: Value(subject.subjectName),
            importanceWeight: Value(subject.importanceWeight),
          ),
        );
      } else {
        await database.into(database.subjects).insert(
          SubjectsCompanion.insert(
            subjectId: subject.subjectId,
            examId: subject.examId,
            subjectName: subject.subjectName,
            importanceWeight: Value(subject.importanceWeight),
          ),
        );
      }

      return Result.success(subject);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== TOPICS ====================

  /// Get topics for a subject
  Future<Result<List<TopicDto>>> getTopicsBySubject(String subjectId) async {
    try {
      final results = await (database.select(database.topics)
            ..where((tbl) => tbl.subjectId.equals(subjectId)))
          .get();

      final dtos = results.map((t) => TopicDto(
        topicId: t.topicId,
        subjectId: t.subjectId,
        parentTopicId: t.parentTopicId,
        topicName: t.topicName,
        difficulty: t.difficulty,
        importanceScore: t.importanceScore,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Get topic by ID
  Future<Result<TopicDto>> getTopicById(String topicId) async {
    try {
      final result = await (database.select(database.topics)
            ..where((tbl) => tbl.topicId.equals(topicId))
            ..limit(1))
          .getSingleOrNull();

      if (result == null) {
        return Result.failure(DatabaseFailure.notFound(entity: 'Topic'));
      }

      final dto = TopicDto(
        topicId: result.topicId,
        subjectId: result.subjectId,
        parentTopicId: result.parentTopicId,
        topicName: result.topicName,
        difficulty: result.difficulty,
        importanceScore: result.importanceScore,
      );

      return Result.success(dto);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Upsert topic
  Future<Result<TopicDto>> upsertTopic(TopicDto topic) async {
    try {
      final existing = await (database.select(database.topics)
            ..where((tbl) => tbl.topicId.equals(topic.topicId)))
          .getSingleOrNull();

      if (existing != null) {
        await database.update(database.topics).replace(
          TopicsCompanion(
            topicId: Value(topic.topicId),
            subjectId: Value(topic.subjectId),
            parentTopicId: Value(topic.parentTopicId),
            topicName: Value(topic.topicName),
            difficulty: Value(topic.difficulty),
            importanceScore: Value(topic.importanceScore),
          ),
        );
      } else {
        await database.into(database.topics).insert(
          TopicsCompanion.insert(
            topicId: topic.topicId,
            subjectId: topic.subjectId,
            topicName: topic.topicName,
            difficulty: Value(topic.difficulty),
            importanceScore: Value(topic.importanceScore),
          ),
        );
      }

      return Result.success(topic);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== QUESTIONS ====================

  /// Get questions for a topic
  Future<Result<List<QuestionDto>>> getQuestionsByTopic(String topicId) async {
    try {
      final results = await (database.select(database.questions)
            ..where((tbl) => tbl.topicId.equals(topicId)))
          .get();

      final dtos = results.map((q) => QuestionDto(
        questionId: q.questionId,
        examId: q.examId,
        subjectId: q.subjectId,
        topicId: q.topicId,
        year: q.year,
        questionText: q.questionText,
        optionA: q.optionA,
        optionB: q.optionB,
        optionC: q.optionC,
        optionD: q.optionD,
        correctAnswer: q.correctAnswer,
        explanation: q.explanation,
        difficulty: q.difficulty,
        createdAt: q.createdAt,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Upsert question
  Future<Result<QuestionDto>> upsertQuestion(QuestionDto question) async {
    try {
      final existing = await (database.select(database.questions)
            ..where((tbl) => tbl.questionId.equals(question.questionId)))
          .getSingleOrNull();

      if (existing != null) {
        await database.update(database.questions).replace(
          QuestionsCompanion(
            questionId: Value(question.questionId),
            examId: Value(question.examId),
            subjectId: Value(question.subjectId),
            topicId: Value(question.topicId),
            year: Value(question.year),
            questionText: Value(question.questionText),
            optionA: Value(question.optionA),
            optionB: Value(question.optionB),
            optionC: Value(question.optionC),
            optionD: Value(question.optionD),
            correctAnswer: Value(question.correctAnswer),
            explanation: Value(question.explanation),
            difficulty: Value(question.difficulty),
          ),
        );
      } else {
        await database.into(database.questions).insert(
          QuestionsCompanion.insert(
            questionId: question.questionId,
            examId: question.examId,
            subjectId: question.subjectId,
            topicId: question.topicId,
            year: question.year,
            questionText: question.questionText,
            optionA: question.optionA,
            optionB: question.optionB,
            optionC: question.optionC,
            optionD: question.optionD,
            correctAnswer: question.correctAnswer,
            difficulty: Value(question.difficulty),
          ),
        );
      }

      return Result.success(question);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== RESOURCES ====================

  /// Get resources for a topic
  Future<Result<List<ResourceDto>>> getResourcesByTopic(String topicId) async {
    try {
      final results = await (database.select(database.resources)
            ..where((tbl) => tbl.topicId.equals(topicId)))
          .get();

      final dtos = results.map((r) => ResourceDto(
        resourceId: r.resourceId,
        topicId: r.topicId,
        title: r.title,
        type: r.type,
        link: r.link,
        averageRating: r.averageRating,
        ratingCount: r.ratingCount,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Upsert resource
  Future<Result<ResourceDto>> upsertResource(ResourceDto resource) async {
    try {
      final existing = await (database.select(database.resources)
            ..where((tbl) => tbl.resourceId.equals(resource.resourceId)))
          .getSingleOrNull();

      if (existing != null) {
        await database.update(database.resources).replace(
          ResourcesCompanion(
            resourceId: Value(resource.resourceId),
            topicId: Value(resource.topicId),
            title: Value(resource.title),
            type: Value(resource.type),
            link: Value(resource.link),
            averageRating: Value(resource.averageRating),
            ratingCount: Value(resource.ratingCount),
          ),
        );
      } else {
        await database.into(database.resources).insert(
          ResourcesCompanion.insert(
            resourceId: resource.resourceId,
            topicId: resource.topicId,
            title: resource.title,
            type: resource.type,
            link: resource.link,
            averageRating: Value(resource.averageRating),
            ratingCount: Value(resource.ratingCount),
          ),
        );
      }

      return Result.success(resource);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  // ==================== CUTOFF DATA ====================

  /// Get cutoff data for an exam
  Future<Result<List<CutoffDatumDto>>> getCutoffDataByExam(String examId) async {
    try {
      final results = await (database.select(database.cutoffData)
            ..where((tbl) => tbl.examId.equals(examId)))
          .get();

      final dtos = results.map((c) => CutoffDatumDto(
        cutoffId: c.cutoffId,
        examId: c.examId,
        year: c.year,
        category: c.category,
        cutoffMark: c.cutoffMark,
        vacancyCount: c.vacancyCount,
      )).toList();

      return Result.success(dtos);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  /// Upsert cutoff data
  Future<Result<CutoffDatumDto>> upsertCutoffData(CutoffDatumDto cutoff) async {
    try {
      final existing = await (database.select(database.cutoffData)
            ..where((tbl) => tbl.cutoffId.equals(cutoff.cutoffId)))
          .getSingleOrNull();

      if (existing != null) {
        await database.update(database.cutoffData).replace(
          CutoffDataCompanion(
            cutoffId: Value(cutoff.cutoffId),
            examId: Value(cutoff.examId),
            year: Value(cutoff.year),
            category: Value(cutoff.category),
            cutoffMark: Value(cutoff.cutoffMark),
            vacancyCount: Value(cutoff.vacancyCount),
          ),
        );
      } else {
        await database.into(database.cutoffData).insert(
          CutoffDataCompanion.insert(
            cutoffId: cutoff.cutoffId,
            examId: cutoff.examId,
            year: cutoff.year,
            category: cutoff.category,
            cutoffMark: cutoff.cutoffMark,
            vacancyCount: Value(cutoff.vacancyCount),
          ),
        );
      }

      return Result.success(cutoff);
    } catch (e) {
      return Result.failure(handleDatabaseError(e));
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await database.delete(database.exams).go();
      await database.delete(database.subjects).go();
      await database.delete(database.topics).go();
      await database.delete(database.questions).go();
      await database.delete(database.resources).go();
      await database.delete(database.cutoffData).go();
      await database.delete(database.conceptRelationships).go();
    } catch (e) {
      throw handleDatabaseError(e);
    }
  }
}
