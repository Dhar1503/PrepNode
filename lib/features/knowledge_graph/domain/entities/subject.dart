/// Subject Entity
/// Represents a subject under a given exam
class Subject {
  final String id;
  final String examId;
  final String name;
  final double importanceWeight;

  const Subject({
    required this.id,
    required this.examId,
    required this.name,
    this.importanceWeight = 0.5,
  });

  Subject copyWith({
    String? id,
    String? examId,
    String? name,
    double? importanceWeight,
  }) {
    return Subject(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      name: name ?? this.name,
      importanceWeight: importanceWeight ?? this.importanceWeight,
    );
  }
}
