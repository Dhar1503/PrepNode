import 'package:prepgraph/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/conversation.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/conversation_history.dart';

/// In-memory conversation/message store for the AI Assistant.
///
/// There is no live backend for this app (offline-first, local Drift DB is
/// the source of truth everywhere else), and conversation persistence
/// across app restarts was never built for this module — this class keeps
/// the same in-memory-for-the-session behavior it always had, but as a
/// real per-conversation store instead of one hardcoded demo conversation.
/// Actual AI content generation lives in AiResponseEngine, which reads
/// real local data (Insights, Planner, PYQ, Mock Test, Cutoff, Knowledge
/// Graph, Profile) — nothing here is fabricated.
class MockAiAssistantRemoteDataSource {
  static final List<Conversation> conversations = [];
  static final Map<String, List<ChatMessage>> messagesByConversation = {};

  Future<List<Conversation>> getConversations(String userId) async {
    return conversations.where((conv) => conv.userId == userId).toList();
  }

  Future<ConversationHistory> getConversationHistory(String conversationId) async {
    final conversation = conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => throw Exception('Conversation not found'),
    );
    final messages = messagesByConversation[conversationId] ?? const [];
    return ConversationHistory(conversation: conversation, messages: messages);
  }

  Future<Conversation> createConversation({
    required String userId,
    required String title,
    String? contextModule,
    String? contextId,
  }) async {
    final newConversation = Conversation(
      id: 'conv-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messageCount: 0,
      isBookmarked: false,
      contextModule: contextModule,
      contextId: contextId,
    );
    conversations.add(newConversation);
    return newConversation;
  }

  Future<Conversation> updateConversation(
    String conversationId, {
    String? title,
    bool? isBookmarked,
  }) async {
    final index = conversations.indexWhere((conv) => conv.id == conversationId);
    if (index == -1) {
      throw Exception('Conversation not found');
    }

    final updated = Conversation(
      id: conversations[index].id,
      userId: conversations[index].userId,
      title: title ?? conversations[index].title,
      createdAt: conversations[index].createdAt,
      updatedAt: DateTime.now(),
      messageCount: conversations[index].messageCount,
      isBookmarked: isBookmarked ?? conversations[index].isBookmarked,
      contextModule: conversations[index].contextModule,
      contextId: conversations[index].contextId,
    );

    conversations[index] = updated;
    return updated;
  }

  Future<void> deleteConversation(String conversationId) async {
    conversations.removeWhere((conv) => conv.id == conversationId);
    messagesByConversation.remove(conversationId);
  }

  /// Appends a real message (user or assistant) to a conversation's
  /// in-memory history and updates its message count/timestamp.
  Future<void> addMessage(String conversationId, ChatMessage message) async {
    final messages = messagesByConversation.putIfAbsent(conversationId, () => []);
    messages.add(message);

    final index = conversations.indexWhere((conv) => conv.id == conversationId);
    if (index != -1) {
      final existing = conversations[index];
      conversations[index] = Conversation(
        id: existing.id,
        userId: existing.userId,
        title: existing.title,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        messageCount: messages.length,
        isBookmarked: existing.isBookmarked,
        contextModule: existing.contextModule,
        contextId: existing.contextId,
      );
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    return messagesByConversation[conversationId] ?? const [];
  }

  Future<List<Conversation>> searchConversations({
    required String userId,
    required String query,
  }) async {
    return conversations
        .where((conv) =>
            conv.userId == userId && conv.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<ChatMessage>> searchMessages({
    required String conversationId,
    required String query,
  }) async {
    final messages = messagesByConversation[conversationId] ?? const [];
    return messages.where((msg) => msg.content.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
