import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/cutoff/presentation/providers/cutoff_providers.dart';
import 'package:prepnode/features/cutoff/presentation/widgets/cutoff_card.dart';

/// Cutoff Home Screen
/// Entry point for Cutoff Intelligence module
class CutoffHomeScreen extends ConsumerWidget {
  const CutoffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(availableExamsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        title: Text(
          'Cutoff Intelligence',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: examsAsync.when(
        data: (exams) => _buildContent(context, ref, exams),
        loading: () => _buildLoading(),
        error: (_, _) => _buildError(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, exams) {
    if (exams.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          
          // Disclaimer banner
          _buildDisclaimerBanner(),
          
          const SizedBox(height: AppConstants.spaceLg),
          
          // Exam list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
            child: Text(
              'Available Exams',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeHeadlineSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          
          ...exams.map((exam) => CutoffCard(
            examCutoff: exam,
            onTap: () {
              context.push('/cutoff/${exam.examId}');
            },
          )),
          
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.ink900.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: AppColors.ink900.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.ink500,
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              'These cutoff figures are illustrative and not yet confirmed against an official TNPSC notification. Do not treat them as official.',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                color: AppColors.graphite700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: AppColors.graphite700,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'No cutoff data available',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ],
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
            'Unable to load cutoff data',
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
