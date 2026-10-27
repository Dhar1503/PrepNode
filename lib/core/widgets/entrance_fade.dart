import 'package:flutter/material.dart';

/// Fades a card in and lifts it 8px, staggered by [index].
///
/// Built from TweenAnimationBuilder alone — no animation package, no
/// controller to dispose. It runs exactly once, when the widget first
/// builds; there is no repeat and nothing rebuilds it on scroll, so the
/// dashboard does not re-animate every time a provider ticks.
///
/// The stagger is capped: with a dozen sections on the dashboard, an
/// uncapped 60ms step would leave the last card arriving most of a second
/// late, which reads as jank rather than sequence.
class EntranceFade extends StatelessWidget {
  final Widget child;
  final int index;

  /// Per-index delay. 60ms is short enough to feel like one movement.
  static const Duration step = Duration(milliseconds: 60);

  /// Nothing waits longer than this before starting.
  static const Duration maxDelay = Duration(milliseconds: 240);

  const EntranceFade({
    super.key,
    required this.child,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final delayMs =
        (step.inMilliseconds * index).clamp(0, maxDelay.inMilliseconds);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      // Total stays under 400ms including the longest stagger.
      duration: Duration(milliseconds: 260 + delayMs),
      curve: Interval(
        // Express the delay as the leading dead zone of one curve rather
        // than a Future.delayed — no timer to leak if the widget goes away
        // mid-flight.
        delayMs / (260 + delayMs),
        1.0,
        curve: Curves.easeOut,
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
