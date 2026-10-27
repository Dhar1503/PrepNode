import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/ai_assistant/presentation/providers/ai_assistant_providers.dart';
import 'package:prepnode/features/ai_assistant/presentation/widgets/chat_bubble.dart';
import 'package:prepnode/features/ai_assistant/presentation/widgets/input_bar.dart';

/// Doubt Explanation Screen
/// Context-aware screen for explaining doubts from specific modules (PYQ, Knowledge Graph, etc.)
class DoubtExplanationScreen extends ConsumerStatefulWidget {
  final String? topicId;
  final String? questionId;
  final String? subjectId;
  final String? moduleId; // 'knowledge_graph', 'pyq', 'mock_test', etc.
  final String? initialQuestion;

  const DoubtExplanationScreen({
    super.key,
    this.topicId,
    this.questionId,
    this.subjectId,
    this.moduleId,
    this.initialQuestion,
  });

  @override
  ConsumerState<DoubtExplanationScreen> createState() =>
      _DoubtExplanationScreenState();
}

class _DoubtExplanationScreenState extends ConsumerState<DoubtExplanationScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestion != null) {
      _messageController.text = widget.initialQuestion!;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    final notifier = ref.read(activeConversationProvider.notifier);
    
    if (notifier.currentConversationId == null) {
      final title = _getContextTitle();
      await notifier.createNewConversation(
        title: title,
        contextModule: widget.moduleId,
        contextId: widget.topicId ?? widget.questionId,
      );
    }

    await notifier.sendMessage(content);
  }

  String _getContextTitle() {
    switch (widget.moduleId) {
      case 'knowledge_graph':
        return 'Topic Explanation';
      case 'pyq':
        return 'Question Explanation';
      case 'mock_test':
        return 'Test Analysis';
      default:
        return 'Doubt Clarification';
    }
  }

  String _getScreenTitle() {
    switch (widget.moduleId) {
      case 'knowledge_graph':
        return 'Explain Concept';
      case 'pyq':
        return 'Explain Answer';
      case 'mock_test':
        return 'Analyze Mistake';
      default:
        return 'Get Explanation';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeConversationProvider);

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
          _getScreenTitle(),
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        actions: [
          if (widget.moduleId == 'pyq' && widget.questionId != null)
            TextButton.icon(
              onPressed: () async {
                final notifier = ref.read(activeConversationProvider.notifier);
                if (notifier.currentConversationId == null) {
                  await notifier.createNewConversation(
                    title: 'Question Explanation',
                    contextModule: widget.moduleId,
                    contextId: widget.questionId,
                  );
                }
                await notifier.sendMessage(
                  'Please explain why each option is correct or incorrect for this question.',
                );
              },
              icon: const Icon(Icons.help_outline, size: 18),
              label: const Text('Explain Options'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.sage500,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Context Banner
          if (widget.moduleId != null)
            Container(
              margin: const EdgeInsets.all(AppConstants.spaceLg),
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.sage500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                border: Border.all(
                  color: AppColors.sage500.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.sage500,
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Expanded(
                    child: Text(
                      'Context: ${_getContextTitle()}',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyMedium,
                        color: AppColors.sage500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: activeState.conversationId == null
                ? _buildEmptyState()
                : _buildChatContent(activeState),
          ),
          InputBar(
            controller: _messageController,
            onSend: _handleSendMessage,
            isLoading: activeState.isLoading,
            hintText: widget.initialQuestion != null
                ? 'Ask follow-up questions...'
                : 'What would you like to know?',
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
                Icons.school,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'Get personalized explanations',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'Ask me to explain concepts, answers, or analyze your mistakes',
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

  Widget _buildChatContent(ActiveConversationState state) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceLg),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        return ChatBubble(
          message: state.messages[index],
          onCopy: () {
            Clipboard.setData(ClipboardData(text: state.messages[index].content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
            );
          },
        );
      },
    );
  }
}
