import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/auth/domain/entities/onboarding_page.dart';
import 'package:prepnode/features/auth/presentation/widgets/onboarding_page.dart';
import 'package:prepnode/features/auth/presentation/widgets/onboarding_page_indicator.dart';
import 'package:prepnode/features/auth/presentation/widgets/onboarding_skip_button.dart';

/// Onboarding Carousel Screen (S0.2)
/// 4-page carousel introducing PrepNode features
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      headline: 'Welcome to PrepNode.',
      supportingText:
          'A companion for your exam preparation — built around your syllabus, your pace, and your goals.',
      illustrationType: OnboardingIllustrationType.welcome,
    ),
    OnboardingPage(
      headline: 'Prepare with Purpose.',
      supportingText:
          'Each day, we highlight what matters most — based on your syllabus, previous years\' patterns, and where you\'re starting from.',
      illustrationType: OnboardingIllustrationType.prepareWithPurpose,
    ),
    OnboardingPage(
      headline: 'Learn with Clarity.',
      supportingText:
          'Topics aren\'t studied in isolation — see how they connect, so you always know what to revisit before moving on.',
      illustrationType: OnboardingIllustrationType.learnWithClarity,
    ),
    OnboardingPage(
      headline: 'Grow with Confidence.',
      supportingText:
          'Progress here is measured against your own starting point — never against anyone else\'s.',
      illustrationType: OnboardingIllustrationType.growWithConfidence,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleSkip() {
    context.go('/login');
  }

  void _handleNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  void _handlePageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper50,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _handlePageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageWidget(page: _pages[index]);
            },
          ),
          Positioned(
            top: 0,
            right: 0,
            child: OnboardingSkipButton(onPressed: _handleSkip),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceSm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingPageIndicator(
              currentPage: _currentPage,
              totalPages: _pages.length,
            ),
            const SizedBox(height: AppConstants.spaceLg),
            _buildPrimaryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    final isLastPage = _currentPage == _pages.length - 1;

    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeightDefault,
      child: ElevatedButton(
        onPressed: _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink900,
          foregroundColor: AppColors.lightOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
        ),
        child: Text(
          isLastPage ? 'Get started' : 'Next',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeLabelLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
