import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/insights/domain/entities/mastery_analytics.dart';
import 'package:prepnode/features/insights/presentation/providers/insights_providers.dart';
import 'package:prepnode/features/insights/presentation/widgets/mastery_topic_card.dart';

/// Mastery Overview Screen (S8.2)
/// Full radial/graph mastery visualization
class MasteryOverviewScreen extends ConsumerWidget {
  const MasteryOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masteryAnalyticsAsync = ref.watch(masteryAnalyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Strength Map',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: masteryAnalyticsAsync.when(
        data: (analytics) => _buildContent(context, analytics),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MasteryAnalytics analytics) {
    // Group by subject
    final subjectGroups = <String, List<TopicMastery>>{};
    for (var topic in analytics.topicMasteries) {
      subjectGroups.putIfAbsent(topic.subjectId, () => []);
      subjectGroups[topic.subjectId]!.add(topic);
    }

    // Without this the screen rendered a legend over blank space, which
    // reads as broken rather than "nothing practised yet".
    if (subjectGroups.isEmpty) {
      return _buildNothingPractisedYet(context);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          
          // Mastery Legend
          _buildMasteryLegend(),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Subject Sections
          ...subjectGroups.entries.map((entry) {
            return _buildSubjectSection(entry.key, entry.value);
          }),

          
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildMasteryLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      // Wrap, not Row: four labels don't fit one line on a narrow phone —
      // "Not Started" was being cut off at the screen edge.
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: AppConstants.spaceMd,
        runSpacing: AppConstants.spaceXs,
        children: [
          _buildLegendItem('Mastered', AppColors.sage500),
          _buildLegendItem('Building', AppColors.marigold500),
          _buildLegendItem('In Progress', AppColors.ink500),
          _buildLegendItem('Not Started', AppColors.outlineVariant),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppConstants.spaceXs),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodySmall,
            color: AppColors.graphite700,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSection(String subjectId, List<TopicMastery> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
          child: Text(
            topics.first.subjectName,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...topics.map((topic) => MasteryTopicCard(
          topic: topic,
          onTap: () {
            // Navigate to topic detail
          },
        )),
        const SizedBox(height: AppConstants.spaceLg),
      ],
    );
  }

  /// Explains what this screen is for and sends the user somewhere useful,
  /// rather than showing an unexplained blank page.
  Widget _buildNothingPractisedYet(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights_outlined, size: 64, color: AppColors.ink500),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'Your strength map builds as you practise',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeTitleMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'Answer questions in PYQ Practice or take a mock test, and each '
              'topic will appear here coloured by how well you know it.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.graphite700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            ElevatedButton(
              onPressed: () => context.go('/practice'),
              child: const Text('Start practising'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'Unable to load mastery data',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }
}





