/// Data Transfer Objects for Practice & Assessment-related entities
/// UserQuestionAttempts, MockTests, MockTestQuestions, MockTestAnswers
library;

class UserQuestionAttemptDto {
  final String attemptId;
  final String userId;
  final String questionId;
  final String selectedAnswer;
  final bool isCorrect;
  final int? timeTakenSeconds;
  final DateTime attemptDate;

  UserQuestionAttemptDto({
    required this.attemptId,
    required this.userId,
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    this.timeTakenSeconds,
    required this.attemptDate,
  });

  factory UserQuestionAttemptDto.fromJson(Map<String, dynamic> json) {
    return UserQuestionAttemptDto(
      attemptId: json['attemptId'] as String,
      userId: json['userId'] as String,
      questionId: json['questionId'] as String,
      selectedAnswer: json['selectedAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      timeTakenSeconds: json['timeTakenSeconds'] as int?,
      attemptDate: DateTime.parse(json['attemptDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attemptId': attemptId,
      'userId': userId,
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'timeTakenSeconds': timeTakenSeconds,
      'attemptDate': attemptDate.toIso8601String(),
    };
  }

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

class MockTestDto {
  final String testId;
  final String userId;
  final String examId;
  final String type;
  final String? subjectId;
  final String? topicId;
  final int durationMinutes;
  final String status;
  final double? score;
  final DateTime startedAt;
  final DateTime? submittedAt;

  MockTestDto({
    required this.testId,
    required this.userId,
    required this.examId,
    required this.type,
    this.subjectId,
    this.topicId,
    required this.durationMinutes,
    required this.status,
    this.score,
    required this.startedAt,
    this.submittedAt,
  });

  factory MockTestDto.fromJson(Map<String, dynamic> json) {
    return MockTestDto(
      testId: json['testId'] as String,
      userId: json['userId'] as String,
      examId: json['examId'] as String,
      type: json['type'] as String,
      subjectId: json['subjectId'] as String?,
      topicId: json['topicId'] as String?,
      durationMinutes: json['durationMinutes'] as int,
      status: json['status'] as String? ?? 'in_progress',
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      startedAt: DateTime.parse(json['startedAt'] as String),
      submittedAt: json['submittedAt'] != null 
          ? DateTime.parse(json['submittedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
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
      'startedAt': startedAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

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

class MockTestQuestionDto {
  final String testId;
  final String questionId;
  final int questionOrder;

  MockTestQuestionDto({
    required this.testId,
    required this.questionId,
    required this.questionOrder,
  });

  factory MockTestQuestionDto.fromJson(Map<String, dynamic> json) {
    return MockTestQuestionDto(
      testId: json['testId'] as String,
      questionId: json['questionId'] as String,
      questionOrder: json['questionOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'questionId': questionId,
      'questionOrder': questionOrder,
    };
  }

  Map<String, dynamic> toDomainMap() {
    return {
      'testId': testId,
      'questionId': questionId,
      'questionOrder': questionOrder,
    };
  }
}

class MockTestAnswerDto {
  final String testId;
  final String questionId;
  final String? selectedAnswer;
  final bool? isCorrect;

  MockTestAnswerDto({
    required this.testId,
    required this.questionId,
    this.selectedAnswer,
    this.isCorrect,
  });

  factory MockTestAnswerDto.fromJson(Map<String, dynamic> json) {
    return MockTestAnswerDto(
      testId: json['testId'] as String,
      questionId: json['questionId'] as String,
      selectedAnswer: json['selectedAnswer'] as String?,
      isCorrect: json['isCorrect'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
    };
  }

  Map<String, dynamic> toDomainMap() {
    return {
      'testId': testId,
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
    };
  }
}
