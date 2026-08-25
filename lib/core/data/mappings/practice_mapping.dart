import '../dtos/practice_dto.dart';

/// Mapping extensions for Practice & Assessment entities

extension UserQuestionAttemptDtoMapping on UserQuestionAttemptDto {
  /// Convert UserQuestionAttemptDto to Domain entity (placeholder)
  Map<String, dynamic> toDomainMap() {
    return {
      'attemptId': attemptId,
      'userId': userId,
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'timeTakenSeconds': timeTakenSeconds,
      'attemptDate': attemptDate,
    };
  }
}

extension MockTestDtoMapping on MockTestDto {
  /// Convert MockTestDto to Domain entity (placeholder)
  Map<String, dynamic> toDomainMap() {
    return {
      'testId': testId,
      'userId': userId,
      'examId': examId,
      'type': type,
      'subjectId': subjectId,
      'topicId': topicId,
      'durationMinutes': durationMinutes,
      'status': status,
      'score': score,
      'startedAt': startedAt,
      'submittedAt': submittedAt,
    };
  }
}

extension MockTestQuestionDtoMapping on MockTestQuestionDto {
  /// Convert MockTestQuestionDto to Domain entity (placeholder)
  Map<String, dynamic> toDomainMap() {
    return {
      'testId': testId,
      'questionId': questionId,
      'questionOrder': questionOrder,
    };
  }
}

extension MockTestAnswerDtoMapping on MockTestAnswerDto {
  /// Convert MockTestAnswerDto to Domain entity (placeholder)
  Map<String, dynamic> toDomainMap() {
    return {
      'testId': testId,
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
    };
  }
}

