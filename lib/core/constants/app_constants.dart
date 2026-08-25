import 'package:flutter/animation.dart';

/// PrepGraph Application Constants
/// Centralized constants for the application
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'PrepGraph';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleAuth = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String mockTests = '/mock-test';
  static const String appTagline = 'Prepare with Purpose';
  static const String appVersion = '1.0.0';

  // Spacing System (4px base)
  static const double space4xs = 2.0;
  static const double space3xs = 4.0;
  static const double space2xs = 8.0;
  static const double spaceXs = 12.0;
  static const double spaceSm = 16.0;
  static const double spaceMd = 24.0;
  static const double spaceLg = 32.0;
  static const double spaceXl = 48.0;
  static const double space2xl = 64.0;
  static const double space3xl = 96.0;

  // Corner Radius
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 999.0;

  // Elevation
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 3.0;
  static const double elevation3 = 6.0;
  static const double elevation4 = 8.0;
  static const double elevation5 = 12.0;

  // Animation Durations (ms)
  static const int durationShort1 = 100;
  static const int durationShort4 = 200;
  static const int durationMedium2 = 300;
  static const int durationLong2 = 500;

  // Touch Targets
  static const double minTouchTarget = 48.0;
  static const double minTouchGap = 8.0;

  // Screen Margins
  static const double screenMarginMobile = 16.0;
  static const double screenMarginTablet = 24.0;
  static const double contentMaxWidth = 720.0;

  // Card Grid
  static const int cardGridColumnsCompact = 2;
  static const int cardGridColumnsMedium = 3;
  static const double cardGridGutter = 16.0;

  // Bottom Navigation
  static const double bottomNavHeight = 80.0;

  // Typography
  static const double fontSizeDisplayLarge = 57.0;
  static const double fontSizeDisplayMedium = 45.0;
  static const double fontSizeHeadlineLarge = 32.0;
  static const double fontSizeHeadlineMedium = 28.0;
  static const double fontSizeHeadlineSmall = 24.0;
  static const double fontSizeTitleLarge = 22.0;
  static const double fontSizeTitleMedium = 16.0;
  static const double fontSizeTitleSmall = 14.0;
  static const double fontSizeBodyLarge = 16.0;
  static const double fontSizeBodyMedium = 14.0;
  static const double fontSizeBodySmall = 12.0;
  static const double fontSizeLabelLarge = 14.0;
  static const double fontSizeLabelMedium = 12.0;
  static const double fontSizeLabelSmall = 11.0;

  // Icon Sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeStandard = 24.0;
  static const double iconSizeLarge = 32.0;

  // Dialog
  static const double dialogMaxWidth = 360.0;
  static const double dialogMinWidth = 320.0;

  // Search Bar
  static const double searchBarHeight = 56.0;

  // Button
  static const double buttonHeightDefault = 48.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonHorizontalPadding = 24.0;

  // Mastery Thresholds (percentage)
  static const double masteryThresholdNotStarted = 0.0;
  static const double masteryThresholdInProgress = 0.5;
  static const double masteryThresholdMastered = 0.8;

  // Study Streak
  static const int streakConsistencyDays = 3;

  // Shadow Tokens (warm-tinted shadows based on ink.900)
  static const String shadowXs = '0 1px 2px rgba(27,42,74,0.06)';
  static const String shadowSm = '0 2px 6px rgba(27,42,74,0.08)';
  static const String shadowMd = '0 4px 12px rgba(27,42,74,0.10)';
  static const String shadowLg = '0 8px 24px rgba(27,42,74,0.12)';
  static const String shadowXl = '0 16px 40px rgba(27,42,74,0.16)';

  // Easing Curves (Material 3)
  static const Curve emphasizedEasing = Cubic(0.2, 0.0, 0, 1.0);
  static const Curve standardEasing = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  // Shimmer Animation Duration
  static const int shimmerDuration = 1200;
}
