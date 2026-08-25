import 'package:equatable/equatable.dart';

/// Represents a single message in a chat conversation
class ChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final List<String>? citations; // Source references
  final Map<String, dynamic>? metadata; // Additional context data

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.role,
    required this.timestamp,
    this.citations,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        conversationId,
        content,
        role,
        timestamp,
        citations,
        metadata,
      ];
}

enum MessageRole {
  user,
  assistant,
  system,
}
