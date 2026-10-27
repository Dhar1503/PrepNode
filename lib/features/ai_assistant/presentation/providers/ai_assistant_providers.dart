import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepnode/features/ai_assistant/data/datasources/ai_assistant_remote_datasource.dart';
import 'package:prepnode/features/ai_assistant/data/repositories/ai_assistant_repository_impl.dart';
import 'package:prepnode/features/ai_assistant/data/services/ai_response_engine.dart';
import 'package:prepnode/features/ai_assistant/domain/entities/ai_insight.dart';
import 'package:prepnode/features/ai_assistant/domain/entities/ai_recommendation.dart';
import 'package:prepnode/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:prepnode/features/ai_assistant/domain/entities/conversation.dart';
import 'package:prepnode/features/ai_assistant/domain/entities/conversation_history.dart';
import 'package:prepnode/features/ai_assistant/domain/entities/doubt_context.dart';
import 'package:prepnode/features/ai_assistant/domain/entities/suggested_question.dart';
import 'package:prepnode/features/ai_assistant/domain/repositories/ai_assistant_repository.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/cutoff/presentation/providers/cutoff_providers.dart';
import 'package:prepnode/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepnode/features/knowledge_graph/presentation/providers/knowledge_graph_providers.dart';
import 'package:prepnode/features/mock_test/presentation/providers/mock_test_providers.dart';
import 'package:prepnode/features/planner/presentation/providers/planner_providers.dart';
import 'package:prepnode/features/pyq/presentation/providers/pyq_providers.dart';
import 'package:prepnode/features/resources/presentation/providers/resource_providers.dart';
import 'package:prepnode/features/strategy/presentation/providers/strategy_providers.dart';

/// Real signed-in user id (was hardcoded to a fake 'mock_user_123' before —
/// every AI response is grounded in this user's actual local data, so it
/// must be the real session, not a placeholder).
final currentAiUserIdProvider = Provider<String>((ref) {
  return ref.watch(authProvider).userId ?? '';
});

// Data Source Provider
final aiAssistantDataSourceProvider =
    Provider<MockAiAssistantRemoteDataSource>((ref) {
  return MockAiAssistantRemoteDataSource();
});

// Response Engine Provider — composes the existing repositories from every
// other module; this is the only place AI content is generated, entirely
// from real local data (no online LLM, no remote API).
final aiResponseEngineProvider = Provider<AiResponseEngine>((ref) {
  return AiResponseEngine(
    insightsRepository: ref.watch(insightsRepositoryProvider),
    plannerRepository: ref.watch(plannerRepositoryProvider),
    pyqRepository: ref.watch(pyqRepositoryProvider),
    mockTestRepository: ref.watch(mockTestRepositoryProvider),
    cutoffRepository: ref.watch(cutoffRepositoryProvider),
    knowledgeGraphRepository: ref.watch(knowledgeGraphRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    resourceRepository: ref.watch(resourceRepositoryProvider),
    strategyRepository: ref.watch(strategyRepositoryProvider),
  );
});

// Repository Provider
final aiAssistantRepositoryProvider =
    Provider<AiAssistantRepository>((ref) {
  final dataSource = ref.watch(aiAssistantDataSourceProvider);
  final engine = ref.watch(aiResponseEngineProvider);
  return AiAssistantRepositoryImpl(remoteDataSource: dataSource, engine: engine);
});

// Conversations Provider
final conversationsProvider =
    FutureProvider<List<Conversation>>((ref) async {
  final repository = ref.watch(aiAssistantRepositoryProvider);
  final userId = ref.watch(currentAiUserIdProvider);
  final result = await repository.getConversations(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (conversations) => conversations,
  );
});

// Conversation History Provider
final conversationHistoryProvider =
    FutureProvider.family<ConversationHistory, String>((ref, conversationId) async {
  final repository = ref.watch(aiAssistantRepositoryProvider);
  final result = await repository.getConversationHistory(conversationId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (history) => history,
  );
});

// Messages Provider
final messagesProvider =
    FutureProvider.family<List<ChatMessage>, String>((ref, conversationId) async {
  final repository = ref.watch(aiAssistantRepositoryProvider);
  final result = await repository.getMessages(conversationId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (messages) => messages,
  );
});

// Suggested Questions Provider
//
// Keyed on a record, not a Map literal — a fresh Map is never == to the
// previous one, so Riverpod treated every rebuild as a brand-new family
// parameter and refetched from scratch instead of reusing the cached
// future (the same bug that made Subject Resources spin forever). Dart 3
// records have real structural equality, which is exactly what a family
// key needs.
typedef SuggestedQuestionsParams = ({String? contextModule, String? contextId});

final suggestedQuestionsProvider =
    FutureProvider.family<List<SuggestedQuestion>, SuggestedQuestionsParams>((ref, params) async {
  final repository = ref.watch(aiAssistantRepositoryProvider);
  final contextModule = params.contextModule;
  final contextId = params.contextId;
  final result = await repository.getSuggestedQuestions(
    contextModule: contextModule,
    contextId: contextId,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (questions) => questions,
  );
});

// AI Recommendations Provider
final aiRecommendationsProvider =
    FutureProvider<List<AIRecommendation>>((ref) async {
  final repository = ref.watch(aiAssistantRepositoryProvider);
  final userId = ref.watch(currentAiUserIdProvider);
  final result = await repository.getRecommendations(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (recommendations) => recommendations,
  );
});

// AI Insights Provider
final aiInsightsProvider =
    FutureProvider<List<AIInsight>>((ref) async {
  final repository = ref.watch(aiAssistantRepositoryProvider);
  final userId = ref.watch(currentAiUserIdProvider);
  final result = await repository.getInsights(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (insights) => insights,
  );
});

// Active Conversation State Provider (for chat screen)
class ActiveConversationState {
  final String? conversationId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ActiveConversationState({
    this.conversationId,
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ActiveConversationState copyWith({
    String? conversationId,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ActiveConversationState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final activeConversationProvider =
    StateNotifierProvider<ActiveConversationNotifier, ActiveConversationState>((ref) {
  return ActiveConversationNotifier(ref);
});

class ActiveConversationNotifier extends StateNotifier<ActiveConversationState> {
  final Ref ref;
  String? currentConversationId;

  ActiveConversationNotifier(this.ref)
      : super(ActiveConversationState());

  Future<void> loadConversation(String conversationId) async {
    currentConversationId = conversationId;
    state = state.copyWith(
      conversationId: conversationId,
      isLoading: true,
      error: null,
    );

    final repository = ref.read(aiAssistantRepositoryProvider);
    final result = await repository.getMessages(conversationId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (messages) {
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  Future<void> sendMessage(String content, {DoubtContext? context}) async {
    if (currentConversationId == null) return;

    // Add user message immediately
    final userMessage = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: currentConversationId!,
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    final repository = ref.read(aiAssistantRepositoryProvider);
    final result = await repository.sendMessage(
      conversationId: currentConversationId!,
      content: content,
      context: context,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (assistantMessage) {
        state = state.copyWith(
          messages: [...state.messages, assistantMessage],
          isLoading: false,
          error: null,
        );
      },
    );
  }

  Future<void> createNewConversation({
    required String title,
    String? contextModule,
    String? contextId,
  }) async {
    state = state.copyWith(isLoading: true);

    final repository = ref.read(aiAssistantRepositoryProvider);
    final userId = ref.read(currentAiUserIdProvider);
    final result = await repository.createConversation(
      userId: userId,
      title: title,
      contextModule: contextModule,
      contextId: contextId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (conversation) {
        currentConversationId = conversation.id;
        state = state.copyWith(
          conversationId: conversation.id,
          messages: [],
          isLoading: false,
          error: null,
        );
      },
    );
  }

  void clearConversation() {
    currentConversationId = null;
    state = ActiveConversationState();
  }
}

// Search Conversations Provider
final searchConversationsProvider =
    FutureProvider.family<List<Conversation>, String>((ref, query) async {
  final repository = ref.watch(aiAssistantRepositoryProvider);
  final userId = ref.watch(currentAiUserIdProvider);
  final result = await repository.searchConversations(
    userId: userId,
    query: query,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (conversations) => conversations,
  );
});
