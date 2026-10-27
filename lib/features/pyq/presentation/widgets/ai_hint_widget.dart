import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';

/// AI Hint Widget
/// Displays AI-generated hints for questions
class AiHintWidget extends StatefulWidget {
  final String hint;
  final VoidCallback? onDismiss;

  const AiHintWidget({
    super.key,
    required this.hint,
    this.onDismiss,
  });

  @override
  State<AiHintWidget> createState() => _AiHintWidgetState();
}

class _AiHintWidgetState extends State<AiHintWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.marigold500.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.marigold500),
        ),
        child: Row(
          children: [
            Icon(
              Icons.psychology,
              color: AppColors.marigold500,
              size: 20,
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Hint',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.marigold500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.hint,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      color: AppColors.ink900,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.onDismiss != null)
              GestureDetector(
                onTap: widget.onDismiss,
                child: Icon(
                  Icons.close,
                  color: AppColors.graphite700,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
