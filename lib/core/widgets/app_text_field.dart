import 'package:flutter/material.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';

/// App Text Field
/// Reusable text field with consistent styling per Design System
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onToggleVisibility;
  final Widget? suffixIcon;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.onToggleVisibility,
    this.suffixIcon,
    this.maxLines = 1,
    this.textInputAction,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: hasError ? AppColors.lightError : AppColors.graphite700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
        ],
        TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          // Explicit color so typed text never inherits the ambient
          // theme's text color (which flips light/dark with system theme)
          // while this field's own fill/border stay fixed to the light
          // palette — that mismatch was making typed text unreadable.
          style: TextStyle(color: AppColors.lightOnSurface),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            suffixIcon: widget.suffixIcon ??
                (widget.onToggleVisibility != null
                    ? IconButton(
                        icon: Icon(
                          widget.obscureText
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.graphite700,
                        ),
                        onPressed: widget.onToggleVisibility,
                      )
                    : null),
            filled: true,
            fillColor: widget.enabled
                ? AppColors.lightSurfaceVariant
                : AppColors.lightSurfaceVariant.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.lightError
                    : AppColors.lightOutline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.lightError
                    : AppColors.lightOutline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.lightError
                    : AppColors.lightPrimary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              borderSide: const BorderSide(
                color: AppColors.lightError,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              borderSide: const BorderSide(
                color: AppColors.lightError,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceSm,
              vertical: AppConstants.spaceSm,
            ),
          ),
        ),
      ],
    );
  }
}
