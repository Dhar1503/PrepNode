import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';

/// Neutral Timer Widget
/// Displays remaining time in a neutral color (never red)
class NeutralTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback? onTimeUp;
  final bool isRunning;

  const NeutralTimer({
    super.key,
    required this.totalSeconds,
    this.onTimeUp,
    this.isRunning = true,
  });

  @override
  State<NeutralTimer> createState() => _NeutralTimerState();
}

class _NeutralTimerState extends State<NeutralTimer> {
  late Timer _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    if (widget.isRunning) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(NeutralTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _startTimer();
      } else {
        _timer.cancel();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        widget.onTimeUp?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightOutlineVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 18,
            color: AppColors.graphite700,
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Text(
            _formattedTime,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
            ),
          ),
        ],
      ),
    );
  }
}
