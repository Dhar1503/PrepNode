/// Exam Entity
/// Represents an available exam
class Exam {
  final String id;
  final String name;
  final String? description;
  final String? conductingBody;
  final bool comingSoon;

  const Exam({
    required this.id,
    required this.name,
    this.description,
    this.conductingBody,
    this.comingSoon = false,
  });
}
