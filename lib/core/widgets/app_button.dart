import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';

/// Label style for all buttons in this file.
///
/// Deliberately does NOT set a `height` multiplier. The theme's `labelLarge`
/// forces `height: 20/14`, a fixed line box that clipped the bottom of
/// glyphs inside these fixed-height buttons ("Login", "Log out", "Continue
/// with Google" all lost their descenders). Omitting `height` lets the font
/// supply its own ascent/descent, which always leaves room for descenders.
TextStyle _buttonLabelStyle(Color color) {
  return GoogleFonts.inter(
    fontSize: AppConstants.fontSizeLabelLarge,
    fontWeight: FontWeight.w600,
    color: color,
  );
}

/// App Primary Button
/// Reusable filled button with consistent styling
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.buttonHeightDefault,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.ink900,
          foregroundColor: textColor ?? AppColors.lightOnPrimary,
          disabledBackgroundColor: AppColors.ink900.withValues(alpha: 0.5),
          elevation: 1,
          // Horizontal-only. The app theme sets vertical: 16, which combined
          // with the fixed 48px SizedBox above left just 16px for the label —
          // less than a 14px line needs — so descenders (the tail on "g" in
          // "Login"/"Log out") were clipped off. Height is already fixed by
          // the SizedBox; the Row below centres the label within it.
          // spaceXs, not spaceLg: these buttons are width:infinity with a
          // centred label, so horizontal padding only ever acts as a minimum
          // inset. At spaceLg (32) it reserved 64px, which left no room for
          // the label in a narrow slot — the mock-test action row rendered
          // "Prev"/"Mark"/"Skip" as completely blank buttons.
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.lightOnPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppConstants.spaceXs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: _buttonLabelStyle(textColor ?? AppColors.lightOnPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// App Secondary Button
/// Outlined button variant
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;
  final Widget? icon;

  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.buttonHeightDefault,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink900,
          side: const BorderSide(color: AppColors.lightOutline),
          // See AppButton — same clipped-descender fix.
          // spaceXs, not spaceLg: these buttons are width:infinity with a
          // centred label, so horizontal padding only ever acts as a minimum
          // inset. At spaceLg (32) it reserved 64px, which left no room for
          // the label in a narrow slot — the mock-test action row rendered
          // "Prev"/"Mark"/"Skip" as completely blank buttons.
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppConstants.spaceXs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: _buttonLabelStyle(AppColors.ink900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// App Text Button
/// Text-only button for links
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final Color? textColor;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.ink900,
      ),
      child: Text(
        label,
        style: _buttonLabelStyle(
          enabled
              ? (textColor ?? AppColors.ink900)
              : AppColors.graphite700.withValues(alpha: 0.5),
        ).copyWith(decoration: TextDecoration.underline),
      ),
    );
  }
}
