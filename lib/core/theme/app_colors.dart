import 'package:flutter/material.dart';

/// PrepGraph Design System Colors
/// Based on Design System v1.0 - "Prepare with Purpose"
/// Core palette: Ink, Marigold, Sage, Paper
class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color ink900 = Color(0xFF1B2A4A); // Primary
  static const Color ink500 = Color(0xFF3A538C);
  static const Color marigold500 = Color(0xFFE5A73B); // Secondary
  static const Color sage500 = Color(0xFF5C8A72); // Tertiary
  static const Color paper50 = Color(0xFFFBFAF6); // Background
  static const Color graphite700 = Color(0xFF2E2E33);
  
  // Additional Colors for AI Assistant and other features
  static const Color azure500 = Color(0xFF4A90E2);
  static const Color rose500 = Color(0xFFE57373);
  static const Color amethyst500 = Color(0xFF9C27B0);
  static const Color teal500 = Color(0xFF009688);

  // Material 3 Light Scheme
  static const Color lightPrimary = Color(0xFF1B2A4A);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFDCE3F5);
  static const Color lightOnPrimaryContainer = Color(0xFF0E1830);
  static const Color lightSecondary = Color(0xFFB4791F);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFFCE9C7);
  static const Color lightOnSecondaryContainer = Color(0xFF4A3308);
  static const Color lightTertiary = Color(0xFF3E6B54);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFD7ECE0);
  static const Color lightOnTertiaryContainer = Color(0xFF0E2A1C);
  static const Color lightError = Color(0xFF8C4A3D); // Muted terracotta
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFF4DCD5);
  static const Color lightOnErrorContainer = Color(0xFF3B1A12);
  static const Color lightBackground = Color(0xFFFBFAF6);
  static const Color lightOnBackground = Color(0xFF2E2E33);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF2E2E33);
  static const Color lightSurfaceVariant = Color(0xFFEAE7DD);
  static const Color lightOnSurfaceVariant = Color(0xFF4A4842);
  static const Color lightOutline = Color(0xFF8D8B84);
  static const Color lightOutlineVariant = Color(0xFFDCD9CE);

  // Convenience aliases (default to light theme)
  static const Color surface = lightSurface;
  static const Color surfaceVariant = lightSurfaceVariant;
  static const Color outlineVariant = lightOutlineVariant;
  static const Color error = lightError;
  static const Color errorContainer = lightErrorContainer;
  static const Color onError = lightOnError;
  static const Color onErrorContainer = lightOnErrorContainer;

  // Material 3 Dark Scheme
  static const Color darkPrimary = Color(0xFFAEC1EC);
  static const Color darkOnPrimary = Color(0xFF12213F);
  static const Color darkPrimaryContainer = Color(0xFF293B60);
  static const Color darkOnPrimaryContainer = Color(0xFFDCE3F5);
  static const Color darkSecondary = Color(0xFFF0C578);
  static const Color darkOnSecondary = Color(0xFF402B04);
  static const Color darkSecondaryContainer = Color(0xFF5C4009);
  static const Color darkOnSecondaryContainer = Color(0xFFFCE9C7);
  static const Color darkTertiary = Color(0xFF9FCBB0);
  static const Color darkOnTertiary = Color(0xFF0E2A1C);
  static const Color darkTertiaryContainer = Color(0xFF27503C);
  static const Color darkOnTertiaryContainer = Color(0xFFD7ECE0);
  static const Color darkError = Color(0xFFE3A897);
  static const Color darkOnError = Color(0xFF4A241A);
  static const Color darkErrorContainer = Color(0xFF663527);
  static const Color darkOnErrorContainer = Color(0xFFF4DCD5);
  static const Color darkBackground = Color(0xFF15161A);
  static const Color darkOnBackground = Color(0xFFE7E5DF);
  static const Color darkSurface = Color(0xFF1D1E23);
  static const Color darkOnSurface = Color(0xFFE7E5DF);
  static const Color darkSurfaceVariant = Color(0xFF333139);
  static const Color darkOnSurfaceVariant = Color(0xFFC6C3BA);
  static const Color darkOutline = Color(0xFF8D8B84);
}
