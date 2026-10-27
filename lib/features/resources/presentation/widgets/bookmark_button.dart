import 'package:flutter/material.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';

/// Bookmark Button Widget
/// Reusable bookmark button with animation
class BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onTap;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onTap,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBookmarked != oldWidget.isBookmarked) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spaceSm),
              decoration: BoxDecoration(
                color: widget.isBookmarked
                    ? AppColors.sage500.withValues(alpha: 0.1)
                    : AppColors.graphite700.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Icon(
                widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: widget.isBookmarked ? AppColors.sage500 : AppColors.graphite700,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}
