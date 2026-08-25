/// Mock Test Entity
/// Represents a mock test configuration
class MockTest {
  final String id;
  final String examId;
  final String title;
  final String? description;
  final MockTestType type;
  final int durationMinutes;
  final int totalQuestions;
  final int totalMarks;
  final double negativeMarking;
  final List<TestSection> sections;
  final List<String> subjectIds;
  final String? topicId;
  final bool isActive;
  final DateTime? scheduledAt;

  const MockTest({
    required this.id,
    required this.examId,
    required this.title,
    this.description,
    required this.type,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.totalMarks,
    required this.negativeMarking,
    required this.sections,
    required this.subjectIds,
    this.topicId,
    this.isActive = true,
    this.scheduledAt,
  });

  MockTest copyWith({
    String? id,
    String? examId,
    String? title,
    String? description,
    MockTestType? type,
    int? durationMinutes,
    int? totalQuestions,
    int? totalMarks,
    double? negativeMarking,
    List<TestSection>? sections,
    List<String>? subjectIds,
    String? topicId,
    bool? isActive,
    DateTime? scheduledAt,
  }) {
    return MockTest(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalMarks: totalMarks ?? this.totalMarks,
      negativeMarking: negativeMarking ?? this.negativeMarking,
      sections: sections ?? this.sections,
      subjectIds: subjectIds ?? this.subjectIds,
      topicId: topicId ?? this.topicId,
      isActive: isActive ?? this.isActive,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }
}

enum MockTestType {
  topic,
  subject,
  sectional,
  full,
}

class TestSection {
  final String id;
  final String name;
  final int questionCount;
  final int marks;
  final int durationMinutes;
  final String? subjectId;

  const TestSection({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.marks,
    required this.durationMinutes,
    this.subjectId,
  });

  TestSection copyWith({
    String? id,
    String? name,
    int? questionCount,
    int? marks,
    int? durationMinutes,
    String? subjectId,
  }) {
    return TestSection(
      id: id ?? this.id,
      name: name ?? this.name,
      questionCount: questionCount ?? this.questionCount,
      marks: marks ?? this.marks,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      subjectId: subjectId ?? this.subjectId,
    );
  }
}
