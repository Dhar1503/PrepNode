import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';

/// Input Bar Widget
/// Chat input field with send button
class InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final String? hintText;

  const InputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
    this.hintText,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: !widget.isLoading,
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Ask me anything...',
                hintStyle: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.graphite700,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  borderSide: BorderSide(color: AppColors.sage500),
                ),
                filled: true,
                fillColor: AppColors.paper50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                  vertical: AppConstants.spaceSm,
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.ink900,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.isLoading
                  ? AppColors.graphite700
                  : AppColors.sage500,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: IconButton(
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
              onPressed: widget.isLoading ? null : widget.onSend,
            ),
          ),
        ],
      ),
    );
  }
}
