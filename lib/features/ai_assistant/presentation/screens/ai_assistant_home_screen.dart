import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/ai_assistant/presentation/providers/ai_assistant_providers.dart';
import 'package:prepnode/features/ai_assistant/presentation/widgets/ai_insight_card.dart';
import 'package:prepnode/features/ai_assistant/presentation/widgets/conversation_tile.dart';
import 'package:prepnode/features/ai_assistant/presentation/widgets/recommendation_card.dart';

/// AI Assistant Home Screen
/// Entry point for AI Assistant with conversations, recommendations, and insights
class AiAssistantHomeScreen extends ConsumerWidget {
  const AiAssistantHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final recommendationsAsync = ref.watch(aiRecommendationsProvider);
    final insightsAsync = ref.watch(aiInsightsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
            icon: const Icon(Icons.search),
            tooltip: 'Search conversations',
            onPressed: () => context.push('/ai-assistant/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.spaceLg),
            
            // Welcome Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.sage500, AppColors.azure500],
                          ),
                          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello! I\'m your AI study companion',
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeHeadlineSmall,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink900,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spaceXs),
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
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  
                  // Quick Action: Start New Chat
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/ai-assistant/chat');
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Start New Conversation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sage500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spaceMd,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.spaceXl),
            
            // AI Recommendations Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.marigold500,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Text(
                    'AI Recommendations',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeHeadlineSmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            recommendationsAsync.when(
              data: (recommendations) {
               if (recommendations.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                  child: Column(
                    children: recommendations.take(2).map((rec) {
                      return RecommendationCard(
                        recommendation: rec,
                        onTap: () => _handleRecommendationTap(context, rec),
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
            
            const SizedBox(height: AppConstants.spaceXl),
            
            // AI Insights Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: AppColors.azure500,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Text(
                    'Your Insights',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeHeadlineSmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            insightsAsync.when(
              data: (insights) {
                if (insights.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                  child: Column(
                    children: insights.take(2).map((insight) {
                      return AIInsightCard(
                        insight: insight,
                        onAction: () {
                          // Insights are computed fresh from live data each
                          // call rather than stored (see
                          // AiAssistantRepositoryImpl.markInsightActioned),
                          // so there's no row to persist an "actioned" flag
                          // on — acknowledge the tap honestly instead of
                          // silently doing nothing.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Noted for this session')),
                          );
                        },
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
            
            const SizedBox(height: AppConstants.spaceXl),
            
            // Recent Conversations Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: AppColors.sage500,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Expanded(
                    // scaleDown so this header can never lose characters to an
                    // ellipsis at a large system font scale.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recent Conversations',
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeTitleMedium,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/ai-assistant/history');
                    },
                    child: Text(
                      'See All',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeBodyMedium,
                        color: AppColors.sage500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            conversationsAsync.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: AppColors.graphite700,
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          Text(
                            'No conversations yet',
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeBodyMedium,
                              color: AppColors.graphite700,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceSm),
                          Text(
                            'Start a conversation to get personalized help',
                            style: GoogleFonts.inter(
                              fontSize: AppConstants.fontSizeBodySmall,
                              color: AppColors.graphite700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                  child: Column(
                    children: conversations.take(3).map((conv) {
                      return ConversationTile(
                        conversation: conv,
                        onTap: () {
                          context.push('/ai-assistant/chat/${conv.id}');
                        },
                        onBookmarkToggle: () async {
                          await ref.read(aiAssistantRepositoryProvider).updateConversation(
                                conv.id,
                                isBookmarked: !conv.isBookmarked,
                              );
                          ref.invalidate(conversationsProvider);
                        },
                        onDelete: () => _confirmDelete(context, ref, conv.id),
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Unable to load conversations',
                        style: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodyMedium,
                          color: AppColors.graphite700,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      TextButton(
                        onPressed: () => ref.invalidate(conversationsProvider),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  void _handleRecommendationTap(BuildContext context, dynamic recommendation) {
    switch (recommendation.targetModule) {
      case 'planner':
        context.push('/planner');
        break;
      case 'resources':
        context.push('/resources/recommended');
        break;
      case 'knowledge_graph':
        if (recommendation.targetId != null) {
          context.push('/learn/topic/${recommendation.targetId}');
        } else {
          context.go('/learn');
        }
        break;
      case 'pyq':
        context.go('/practice');
        break;
      default:
        context.push('/ai-assistant/chat');
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String conversationId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'Are you sure you want to delete this conversation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(aiAssistantRepositoryProvider).deleteConversation(conversationId);
              ref.invalidate(conversationsProvider);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.rose500),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
