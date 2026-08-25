import 'package:equatable/equatable.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/conversation.dart';

/// Represents the history of a conversation with all its messages
class ConversationHistory extends Equatable {
  final Conversation conversation;
  final List<ChatMessage> messages;

  const ConversationHistory({
    required this.conversation,
    required this.messages,
  });

  @override
  List<Object?> get props => [conversation, messages];
}
