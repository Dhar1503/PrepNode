import 'package:dartz/dartz.dart';
import 'package:prepgraph/core/utils/failures.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/ai_insight.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/ai_recommendation.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/conversation.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/conversation_history.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/doubt_context.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/suggested_question.dart';

/// Repository interface for AI Assistant operations
/// Backend-ready abstraction for AI-powered features
abstract class AiAssistantRepository {
  // Conversation Management
  
  /// Get all conversations for a user
  Future<Either<Failure, List<Conversation>>> getConversations(String userId);
  
  /// Get conversation history with all messages
  Future<Either<Failure, ConversationHistory>> getConversationHistory(String conversationId);
  
  /// Create a new conversation
  Future<Either<Failure, Conversation>> createConversation({
    required String userId,
    required String title,
    String? contextModule,
    String? contextId,
  });
  
  /// Update conversation title or bookmark status
  Future<Either<Failure, Conversation>> updateConversation(
    String conversationId, {
    String? title,
    bool? isBookmarked,
  });
  
  /// Delete a conversation
  Future<Either<Failure, void>> deleteConversation(String conversationId);
  
  // Chat Operations
  
  /// Send a message and get AI response
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationId,
    required String content,
    DoubtContext? context,
  });
  
  /// Get messages for a conversation
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId);
  
  /// Stream messages for real-time chat (optional for streaming UI)
  Stream<ChatMessage> streamMessageResponse({
    required String conversationId,
    required String content,
    DoubtContext? context,
  });
  
  // Suggested Questions
  
  /// Get suggested questions based on context
  Future<Either<Failure, List<SuggestedQuestion>>> getSuggestedQuestions({
    String? contextModule,
    String? contextId,
  });
  
  // AI Recommendations
  
  /// Get AI-generated recommendations for the user
  Future<Either<Failure, List<AIRecommendation>>> getRecommendations(String userId);
  
  /// Generate a specific recommendation based on context
  Future<Either<Failure, AIRecommendation>> generateRecommendation({
    required String userId,
    required RecommendationType type,
    String? targetModule,
    String? targetId,
  });
  
  // AI Insights
  
  /// Get AI insights about user performance
  Future<Either<Failure, List<AIInsight>>> getInsights(String userId);
  
  /// Generate an insight based on specific data
  Future<Either<Failure, AIInsight>> generateInsight({
    required String userId,
    required InsightCategory category,
    Map<String, dynamic>? data,
  });
  
  /// Mark an insight as actioned
  Future<Either<Failure, AIInsight>> markInsightActioned(String insightId);
  
  // Context-Aware Operations
  
  /// Explain a concept from Knowledge Graph. [userId], when supplied,
  /// personalizes the explanation with the learner's real mastery.
  Future<Either<Failure, ChatMessage>> explainConcept({
    required String topicId,
    required String conversationId,
    String? userId,
  });
  
  /// Explain a PYQ answer
  Future<Either<Failure, ChatMessage>> explainAnswer({
    required String questionId,
    required String conversationId,
    bool explainIncorrectOptions = false,
  });
  
  /// Generate a hint for a question
  Future<Either<Failure, ChatMessage>> generateHint({
    required String questionId,
    required String conversationId,
  });
  
  /// Analyze mock test mistakes. [userId], when supplied, is used to look
  /// up the real test in the learner's own history (falling back to their
  /// most recent test if the exact id isn't found there).
  Future<Either<Failure, ChatMessage>> analyzeMistakes({
    required String testResultId,
    required String conversationId,
    String? userId,
  });
  
  /// Explain analytics/charts from Insights
  Future<Either<Failure, ChatMessage>> explainAnalytics({
    required String userId,
    required String conversationId,
    String? specificMetric,
  });
  
  /// Explain cutoff readiness prediction
  Future<Either<Failure, ChatMessage>> explainReadiness({
    required String examId,
    required String userId,
    required String conversationId,
  });
  
  /// Recommend resources based on context
  Future<Either<Failure, List<AIRecommendation>>> recommendResources({
    required String userId,
    String? topicId,
    String? subjectId,
  });
  
  // Search
  
  /// Search conversations by query
  Future<Either<Failure, List<Conversation>>> searchConversations({
    required String userId,
    required String query,
  });
  
  /// Search within a conversation
  Future<Either<Failure, List<ChatMessage>>> searchMessages({
    required String conversationId,
    required String query,
  });
}
