import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/features/ai_assistant/domain/entities/suggested_question.dart';
import 'package:prepgraph/features/ai_assistant/presentation/providers/ai_assistant_providers.dart';
import 'package:prepgraph/features/ai_assistant/presentation/widgets/chat_bubble.dart';
import 'package:prepgraph/features/ai_assistant/presentation/widgets/input_bar.dart';
import 'package:prepgraph/features/ai_assistant/presentation/widgets/suggested_question_card.dart';
import 'package:prepgraph/features/ai_assistant/presentation/widgets/typing_indicator.dart';

/// Chat Screen
/// Main chat interface for AI Assistant conversations
class ChatScreen extends ConsumerStatefulWidget {
  final String? conversationId;
  final String? contextModule;
  final String? contextId;

  const ChatScreen({
    super.key,
    this.conversationId,
    this.contextModule,
    this.contextId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSuggestions = true;

  @override
  void initState() {
    super.initState();
    if (widget.conversationId != null) {
      // Deferred: Riverpod forbids modifying a provider synchronously
      // during initState (still mid-build).
      Future.microtask(
        () => ref.read(activeConversationProvider.notifier).loadConversation(widget.conversationId!),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    setState(() => _showSuggestions = false);

    final notifier = ref.read(activeConversationProvider.notifier);
    
    if (notifier.currentConversationId == null) {
      await notifier.createNewConversation(
        title: content.length > 30 ? '${content.substring(0, 30)}...' : content,
        contextModule: widget.contextModule,
        contextId: widget.contextId,
      );
    }

    await notifier.sendMessage(content);
    _scrollToBottom();
  }

  void _handleSuggestedQuestion(String question) {
    _messageController.text = question;
    _handleSendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeConversationProvider);
    final suggestedQuestionsAsync = ref.watch(
      suggestedQuestionsProvider((
        contextModule: widget.contextModule,
        contextId: widget.contextId,
      )),
    );

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(activeConversationProvider.notifier).clearConversation();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'AI Assistant',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/ai-assistant/history');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: activeState.conversationId == null
                ? _buildEmptyState()
                : _buildChatContent(activeState, suggestedQuestionsAsync),
          ),
          InputBar(
            controller: _messageController,
            onSend: _handleSendMessage,
            isLoading: activeState.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.sage500, AppColors.azure500],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'Start a conversation',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'Ask me anything about TNPSC preparation',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent(
    ActiveConversationState state,
    AsyncValue<List<SuggestedQuestion>> suggestedQuestionsAsync,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: AppConstants.spaceLg),
            itemCount: state.messages.length + 1,
            itemBuilder: (context, index) {
              if (index < state.messages.length) {
                return ChatBubble(
                  message: state.messages[index],
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: state.messages[index].content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                    );
                  },
                );
              } else {
                // Show suggestions or typing indicator
                if (state.isLoading) {
                  return const TypingIndicator();
                } else if (_showSuggestions && state.messages.isEmpty) {
                  return _buildSuggestions(suggestedQuestionsAsync);
                }
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(AsyncValue<List<SuggestedQuestion>> asyncQuestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.spaceLg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            'Suggested Questions',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        asyncQuestions.when(
          data: (questions) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Row(
                children: questions.map((question) {
                  return SuggestedQuestionCard(
                    question: question,
                    onTap: () => _handleSuggestedQuestion(question.question),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
