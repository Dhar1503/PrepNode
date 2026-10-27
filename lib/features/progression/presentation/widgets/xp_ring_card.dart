import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/features/progression/domain/entities/progression.dart';
import 'package:prepnode/features/progression/presentation/providers/progression_providers.dart';

/// XP ring + level. The ring fills toward the next level rather than showing
/// lifetime XP, because "820 XP" means nothing on its own — "180 to
/// Strategist" is the number that pulls the next session.
class XpRingCard extends ConsumerWidget {
  const XpRingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpAsync = ref.watch(xpProvider);

    return xpAsync.when(
      loading: () => const SizedBox(height: 120),
      error: (_, _) => const SizedBox.shrink(),
      data: (xp) => _XpContent(xp: xp),
    );
  }
}

class _XpContent extends StatelessWidget {
  final XpState xp;

  const _XpContent({required this.xp});

  @override
  Widget build(BuildContext context) {
    final next = xp.nextLevel;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutlineVariant),
      ),
      child: Row(
        children: [
          _AnimatedRing(progress: xp.levelProgress, level: xp.level.index),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  xp.level.title,
                  style: GoogleFonts.fraunces(
                    fontSize: AppConstants.fontSizeTitleLarge,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${xp.totalXp} XP total',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    color: AppColors.graphite700,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXs),
                Text(
                  next == null
                      ? 'Highest level reached.'
                      : '${xp.xpToNextLevel} XP to ${next.title}',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sage500,
                  ),
                ),
                if (xp.todayXp > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+${xp.todayXp} XP today',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodySmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.marigold500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fills from empty on first build so XP gains read as movement rather than
/// a static number. Single 900ms tween — no repeat.
class _AnimatedRing extends StatelessWidget {
  final double progress;
  final int level;

  const _AnimatedRing({required this.progress, required this.level});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: 72,
          height: 72,
          child: CustomPaint(
            painter: _RingPainter(progress: value),
            child: Center(
              child: Text(
                '$level',
                style: GoogleFonts.fraunces(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 5;

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = AppColors.lightOutlineVariant
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke,
    );

    if (progress <= 0) return;

    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = AppColors.marigold500
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
