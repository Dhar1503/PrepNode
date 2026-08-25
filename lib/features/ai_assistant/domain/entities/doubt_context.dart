import 'package:equatable/equatable.dart';

/// Represents the context for a doubt/question
class DoubtContext extends Equatable {
  final String id;
  final String? topicId;
  final String? questionId;
  final String? subjectId;
  final String? moduleId; // e.g., 'pyq', 'mock_test', 'knowledge_graph'
  final Map<String, dynamic>? additionalContext;

  const DoubtContext({
    required this.id,
    this.topicId,
    this.questionId,
    this.subjectId,
    this.moduleId,
    this.additionalContext,
  });

  @override
  List<Object?> get props => [
        id,
        topicId,
        questionId,
        subjectId,
        moduleId,
        additionalContext,
      ];
}
