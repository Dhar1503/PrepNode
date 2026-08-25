import 'package:equatable/equatable.dart';

/// Represents a conversation session with the AI assistant
class Conversation extends Equatable {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final bool isBookmarked;
  final String? contextModule; // Where this conversation started (e.g., 'knowledge_graph', 'pyq')
  final String? contextId; // ID of the related entity (e.g., topicId, questionId)

  const Conversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    this.isBookmarked = false,
    this.contextModule,
    this.contextId,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        createdAt,
        updatedAt,
        messageCount,
        isBookmarked,
        contextModule,
        contextId,
      ];
}
