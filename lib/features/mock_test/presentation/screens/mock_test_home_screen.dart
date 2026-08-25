import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/features/mock_test/domain/entities/mock_test.dart';
import 'package:prepgraph/features/mock_test/presentation/providers/mock_test_providers.dart';
import 'package:prepgraph/features/mock_test/presentation/widgets/test_type_card.dart';

/// Mock Test Home Screen (S6.1)
/// Test type selection with topic/subject/full mock options
class MockTestHomeScreen extends ConsumerStatefulWidget {
  const MockTestHomeScreen({super.key});

  @override
  ConsumerState<MockTestHomeScreen> createState() => _MockTestHomeScreenState();
}

class _MockTestHomeScreenState extends ConsumerState<MockTestHomeScreen> {
  MockTestType? _selectedType;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadTests);
  }

  void _loadTests() {
    ref.read(mockTestsProvider.notifier).loadMockTests(examId: 'tnpsc-group2');
  }

  void _handleTypeSelect(MockTestType type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _handleStartTest(MockTest test) {
    context.push('/mock-tests/instructions/${test.id}', extra: test);
  }

  @override
  Widget build(BuildContext context) {
    final mockTestsState = ref.watch(mockTestsProvider);
    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        title: Text(
          'Mock Tests',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: mockTestsState.isLoading
          ? _buildLoadingSkeleton()
          : _buildContent(mockTestsState),
    );
  }

  Widget _buildContent(MockTestsState state) {
    if (state.errorMessage != null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildTestTypes(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildAvailableTests(state.tests),
          const SizedBox(height: AppConstants.spaceLg),
          _buildRulesSummary(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Test Type',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Text(
          'Select a test type to see available mock tests',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.graphite700,
          ),
        ),
      ],
    );
  }

  Widget _buildTestTypes() {
    return Row(
      children: MockTestType.values.map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => _handleTypeSelect(type),
            child: Container(
              margin: EdgeInsets.only(
                right: type != MockTestType.values.last ? AppConstants.spaceSm : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.ink900 : AppColors.paper50,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.ink900 : AppColors.lightOutline,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _getTypeLabel(type),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.lightOnPrimary : AppColors.ink900,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getTypeLabel(MockTestType type) {
    switch (type) {
      case MockTestType.topic:
        return 'Topic';
      case MockTestType.subject:
        return 'Subject';
      case MockTestType.sectional:
        return 'Sectional';
      case MockTestType.full:
        return 'Full Mock';
    }
  }

  Widget _buildAvailableTests(List<MockTest> availableTests) {
    final filteredTests = _selectedType != null
        ? availableTests.where((test) => test.type == _selectedType).toList()
        : availableTests;

    if (filteredTests.isEmpty) {
      return _buildEmptyState(noDataAtAll: availableTests.isEmpty);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Tests',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        ...filteredTests.map((test) => Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
          child: TestTypeCard(
            type: test.type,
            title: test.title,
            description: test.description ?? '',
            durationMinutes: test.durationMinutes,
            questionCount: test.totalQuestions,
            onTap: () => _handleStartTest(test),
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyState({required bool noDataAtAll}) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXl),
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 48,
            color: AppColors.graphite700,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            noDataAtAll
                ? 'No offline mock test data is available yet — the question bank doesn\'t have enough content for this exam.'
                : 'No tests available for this type',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSummary() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.graphite700,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                'Test Rules',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          _buildRule('• Each correct answer: +2 marks'),
          _buildRule('• Each incorrect answer: -0.33 marks'),
          _buildRule('• Unanswered questions: 0 marks'),
          _buildRule('• Timer auto-submits when time expires'),
          _buildRule('• Questions can be marked for review'),
        ],
      ),
    );
  }

  Widget _buildRule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          color: AppColors.graphite700,
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.graphite700,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            "Couldn't load tests",
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyLarge,
              color: AppColors.graphite700,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          ElevatedButton(
            onPressed: _loadTests,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink900,
              foregroundColor: AppColors.lightOnPrimary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
