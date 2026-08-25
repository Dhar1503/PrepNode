import 'package:flutter/material.dart';
import 'package:prepgraph/core/theme/app_colors.dart';

/// PrepGraph Logo Mark
///
/// Three circular nodes joined into a closed triangle — the same mark used
/// for the launcher icon (see assets/images/prepgraph_logo_icon.svg).
/// Geometry is expressed as fractions of [size] so the mark scales
/// correctly at any size; the previous version hardcoded a 6px node radius
/// and 2px stroke regardless of size, so it only looked right at 48-64px.
class LogoMark extends StatelessWidget {
  final double size;

  const LogoMark({
    super.key,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoMarkPainter(),
      ),
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Proportional to the canvas, matching the SVG the launcher icon is
    // generated from (node r = 52/512 and 46/512, stroke = 20/512).
    final topRadius = size.width * (52 / 512);
    final baseRadius = size.width * (46 / 512);
    final strokeWidth = size.width * (20 / 512);

    final topNode = Offset(size.width * (256 / 512), size.height * (150 / 512));
    final leftNode = Offset(size.width * (155 / 512), size.height * (318 / 512));
    final rightNode = Offset(size.width * (357 / 512), size.height * (318 / 512));

    // Closed triangle: every node connects to both others. On the light
    // in-app background the edges use a muted steel blue so they read as
    // connections rather than competing with the nodes themselves.
    final edgePaint = Paint()
      ..color = const Color(0xFF6E82AB)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(topNode, leftNode, edgePaint);
    canvas.drawLine(topNode, rightNode, edgePaint);
    canvas.drawLine(leftNode, rightNode, edgePaint);

    canvas.drawCircle(
      topNode,
      topRadius,
      Paint()
        ..color = AppColors.ink900
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      leftNode,
      baseRadius,
      Paint()
        ..color = AppColors.sage500
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      rightNode,
      baseRadius,
      Paint()
        ..color = AppColors.marigold500
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
