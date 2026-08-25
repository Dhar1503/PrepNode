import 'package:equatable/equatable.dart';

/// Represents a suggested question the user can ask
class SuggestedQuestion extends Equatable {
  final String id;
  final String question;
  final String? category; // e.g., 'concept', 'practice', 'revision'
  final int displayOrder;
  final bool isPopular;

  const SuggestedQuestion({
    required this.id,
    required this.question,
    this.category,
    required this.displayOrder,
    this.isPopular = false,
  });

  @override
  List<Object?> get props => [
        id,
        question,
        category,
        displayOrder,
        isPopular,
      ];
}
