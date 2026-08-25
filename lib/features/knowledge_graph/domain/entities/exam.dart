/// Exam Entity
/// Represents a competitive exam in the knowledge graph domain
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

  Exam copyWith({
    String? id,
    String? name,
    String? description,
    String? conductingBody,
    bool? comingSoon,
  }) {
    return Exam(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      conductingBody: conductingBody ?? this.conductingBody,
      comingSoon: comingSoon ?? this.comingSoon,
    );
  }
}
