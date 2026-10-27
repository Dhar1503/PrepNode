import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/auth/domain/entities/onboarding_page.dart';

/// Onboarding Page Widget
/// Single page in the carousel with illustration, headline, and supporting text
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppConstants.spaceLg),
          _buildIllustration(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildHeadline(),
          const SizedBox(height: AppConstants.spaceSm),
          _buildSupportingText(),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 220,
      child: Center(
        child: _getIllustration(),
      ),
    );
  }

  Widget _getIllustration() {
    switch (page.illustrationType) {
      case OnboardingIllustrationType.welcome:
        return _WelcomeIllustration();
      case OnboardingIllustrationType.prepareWithPurpose:
        return _PrepareIllustration();
      case OnboardingIllustrationType.learnWithClarity:
        return _LearnIllustration();
      case OnboardingIllustrationType.growWithConfidence:
        return _GrowIllustration();
    }
  }

  Widget _buildHeadline() {
    return Text(
      page.headline,
      style: GoogleFonts.fraunces(
        fontSize: AppConstants.fontSizeHeadlineMedium,
        fontWeight: FontWeight.w500,
        color: AppColors.ink900,
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSupportingText() {
    return Text(
      page.supportingText,
      style: GoogleFonts.inter(
        fontSize: AppConstants.fontSizeBodyMedium,
        fontWeight: FontWeight.w400,
        color: AppColors.graphite700,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Welcome Illustration - Open notebook with marigold dot
class _WelcomeIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(160, 160),
      painter: _WelcomeIllustrationPainter(),
    );
  }
}

class _WelcomeIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink900
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Notebook outline
    final rect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.6,
      size.height * 0.5,
    );
    canvas.drawRect(rect, paint);

    // Notebook spine line
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.3),
      Offset(size.width * 0.35, size.height * 0.8),
      paint,
    );

    // Marigold dot (bookmark/highlight)
    final dotPaint = Paint()
      ..color = AppColors.marigold500
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.55),
      4,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Prepare Illustration - Calendar grid with one filled cell
class _PrepareIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 120),
      painter: _PrepareIllustrationPainter(),
    );
  }
}

class _PrepareIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink900
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cellWidth = size.width / 7;
    final cellHeight = size.height;

   // Draw 7 day cells
    for (int i = 0; i < 7; i++) {
      final rect = Rect.fromLTWH(
        i * cellWidth,
        0,
        cellWidth,
        cellHeight,
      );
      canvas.drawRect(rect, paint);
    }

    // Fill one cell with marigold (day 3)
    final fillPaint = Paint()
      ..color = AppColors.marigold500.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(2 * cellWidth, 0, cellWidth, cellHeight),
      fillPaint,
    );

    // Checkmark in filled cell
    final checkPaint = Paint()
      ..color = AppColors.marigold500
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final checkCenter = Offset(2.5 * cellWidth, cellHeight / 2);
    canvas.drawLine(
      Offset(checkCenter.dx - 6, checkCenter.dy),
      Offset(checkCenter.dx - 2, checkCenter.dy + 6),
      checkPaint,
    );
    canvas.drawLine(
      Offset(checkCenter.dx - 2, checkCenter.dy + 6),
      Offset(checkCenter.dx + 6, checkCenter.dy - 4),
      checkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Learn Illustration - Three connected nodes
class _LearnIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(160, 160),
      painter: _LearnIllustrationPainter(),
    );
  }
}

class _LearnIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink900
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final nodeRadius = 8.0;

    // Three nodes
    final node1 = Offset(size.width * 0.3, size.height * 0.4);
    final node2 = Offset(size.width * 0.5, size.height * 0.7);
    final node3 = Offset(size.width * 0.7, size.height * 0.4);

    // Connections
    canvas.drawLine(node1, node2, paint);
    canvas.drawLine(node2, node3, paint);

    // Bolder connection (node1 to node2)
    final boldPaint = Paint()
      ..color = AppColors.ink900
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(node1, node2, boldPaint);

    // Nodes
    final nodePaint = Paint()
      ..color = AppColors.ink900
      ..style = PaintingStyle.fill;
    canvas.drawCircle(node1, nodeRadius, nodePaint);
    canvas.drawCircle(node2, nodeRadius, nodePaint);
    canvas.drawCircle(node3, nodeRadius, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Grow Illustration - Rising line with sage dots
class _GrowIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(160, 160),
      painter: _GrowIllustrationPainter(),
    );
  }
}

class _GrowIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink900
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Rising line
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    canvas.drawPath(path, paint);

    // Sage dots along the line
    final dotPaint = Paint()
      ..color = AppColors.sage500
      ..style = PaintingStyle.fill;

    final dot1 = Offset(size.width * 0.3, size.height * 0.65);
    final dot2 = Offset(size.width * 0.5, size.height * 0.5);
    final dot3 = Offset(size.width * 0.7, size.height * 0.35);

    canvas.drawCircle(dot1, 5, dotPaint);
    canvas.drawCircle(dot2, 7, dotPaint);
    canvas.drawCircle(dot3, 9, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
