/// Onboarding Page Entity
/// Represents a single page in the onboarding carousel
class OnboardingPage {
  final String headline;
  final String supportingText;
  final OnboardingIllustrationType illustrationType;

  const OnboardingPage({
    required this.headline,
    required this.supportingText,
    required this.illustrationType,
  });
}

enum OnboardingIllustrationType {
  welcome,
  prepareWithPurpose,
  learnWithClarity,
  growWithConfidence,
}
