import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_button.dart';

/// Reschedule Bottom Sheet Widget
/// Bottom sheet for rescheduling tasks to a new date/time
class RescheduleBottomSheet extends StatefulWidget {
  final DateTime currentScheduledDate;
  final Function(DateTime) onReschedule;

  const RescheduleBottomSheet({
    super.key,
    required this.currentScheduledDate,
    required this.onReschedule,
  });

  @override
  State<RescheduleBottomSheet> createState() => _RescheduleBottomSheetState();
}

class _RescheduleBottomSheetState extends State<RescheduleBottomSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.currentScheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildDatePicker(),
          const SizedBox(height: AppConstants.spaceLg),
          _buildTimePicker(),
          const SizedBox(height: AppConstants.spaceXl),
          _buildActions(),
          const SizedBox(height: AppConstants.spaceLg),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: AppConstants.spaceSm),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.graphite700,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Column(
        children: [
          Text(
            'Reschedule Task',
            style: GoogleFonts.fraunces(
              fontSize: AppConstants.fontSizeHeadlineSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            'Choose a new date and time for this task',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.lightOutline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.graphite700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.ink900, size: 20),
                const SizedBox(width: AppConstants.spaceSm),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyLarge,
                    color: AppColors.ink900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.lightOutline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.graphite700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Row(
              children: [
                Icon(Icons.access_time, color: AppColors.ink900, size: 20),
                const SizedBox(width: AppConstants.spaceSm),
                Text(
                  '${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyLarge,
                    color: AppColors.ink900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: AppSecondaryButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: AppButton(
              label: 'Reschedule',
              onPressed: () {
                widget.onReschedule(_selectedDate);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
