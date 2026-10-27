import 'package:flutter/material.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';

/// Skeleton Shimmer Effect
/// Provides a loading shimmer animation for skeleton screens
class SkeletonShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const SkeletonShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFEAE7DD),
    this.highlightColor = const Color(0xFFF5F3EB),
  });

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.shimmerDuration),
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: AppConstants.standardEasing),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: _animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Skeleton Card
/// Standard card skeleton with rounded corners
class SkeletonCard extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsets margin;

  const SkeletonCard({
    super.key,
    this.height,
    this.width,
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppConstants.spaceLg,
      vertical: AppConstants.spaceSm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height ?? 120,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
    );
  }
}

/// Skeleton List Tile
/// List item skeleton with avatar and text lines
class SkeletonListTile extends StatelessWidget {
  final EdgeInsets? padding;

  const SkeletonListTile({
    super.key,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceSm,
          ),
      child: Row(
        children: [
          _buildCircleAvatar(),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextLine(width: 0.6),
                const SizedBox(height: AppConstants.spaceXs),
                _buildTextLine(width: 0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTextLine({required double width}) {
    return Container(
      height: 16,
      width: width * double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Skeleton Grid Item
/// Grid card skeleton for dashboard cards
class SkeletonGridItem extends StatelessWidget {
  final double? aspectRatio;

  const SkeletonGridItem({
    super.key,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.lightOutlineVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextLine(width: 0.7),
                const SizedBox(height: AppConstants.spaceXs),
                _buildTextLine(width: 0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextLine({required double width}) {
    return Container(
      height: 12,
      width: width * double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Skeleton Hero Number
/// Large number skeleton for stats/progress cards
class SkeletonHeroNumber extends StatelessWidget {
  const SkeletonHeroNumber({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: 80,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

/// Skeleton Chart
/// Chart placeholder skeleton
class SkeletonChart extends StatelessWidget {
  final double? height;

  const SkeletonChart({
    super.key,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: CustomPaint(
        painter: _GridLinesPainter(),
      ),
    );
  }
}

class _GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lightOutlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 1; i < 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw vertical grid lines
    for (int i = 1; i < 5; i++) {
      final x = (size.width / 5) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
