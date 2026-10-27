import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/ai_assistant/presentation/providers/ai_assistant_providers.dart';
import 'package:prepnode/features/ai_assistant/presentation/widgets/conversation_tile.dart';

/// Conversation History Screen
/// Displays all user conversations with search and filter options
class ConversationHistoryScreen extends ConsumerStatefulWidget {
  const ConversationHistoryScreen({super.key});

  @override
  ConsumerState<ConversationHistoryScreen> createState() =>
      _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState
    extends ConsumerState<ConversationHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(
      _searchQuery.isEmpty
          ? conversationsProvider
          : searchConversationsProvider(_searchQuery),
    );

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
          'Conversation History',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.graphite700,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                  vertical: AppConstants.spaceSm,
                ),
              ),
            ),
          ),
          // Conversations List
          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return ConversationTile(
                      conversation: conversation,
                      onTap: () {
                        context.push('/ai-assistant/chat/${conversation.id}');
                      },
                      onBookmarkToggle: () async {
                        await ref
                            .read(aiAssistantRepositoryProvider)
                            .updateConversation(
                              conversation.id,
                              isBookmarked: !conversation.isBookmarked,
                            );
                        ref.invalidate(conversationsProvider);
                      },
                      onDelete: () {
                        _showDeleteDialog(conversation.id);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, _) => _buildErrorState(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/ai-assistant/chat');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Chat'),
        backgroundColor: AppColors.sage500,
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
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.graphite700,
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              _searchQuery.isEmpty
                  ? 'No conversations yet'
                  : 'No conversations found',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              _searchQuery.isEmpty
                  ? 'Start a conversation to get personalized help'
                  : 'Try a different search term',
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.rose500,
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'Unable to load conversations',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(conversationsProvider);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'Are you sure you want to delete this conversation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(aiAssistantRepositoryProvider)
                  .deleteConversation(conversationId);
              ref.invalidate(conversationsProvider);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.rose500,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
