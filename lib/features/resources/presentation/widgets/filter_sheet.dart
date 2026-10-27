import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/theme/app_colors.dart';

/// Filter Sheet Widget
/// Bottom sheet for filtering resources
class ResourceFilterSheet extends StatefulWidget {
  final String? selectedSubject;
  final String? selectedType;
  final String? selectedDifficulty;
  final Function(String?) onSubjectChanged;
  final Function(String?) onTypeChanged;
  final Function(String?) onDifficultyChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const ResourceFilterSheet({
    super.key,
    this.selectedSubject,
    this.selectedType,
    this.selectedDifficulty,
    required this.onSubjectChanged,
    required this.onTypeChanged,
    required this.onDifficultyChanged,
    required this.onReset,
    required this.onApply,
  });

  @override
  State<ResourceFilterSheet> createState() => _ResourceFilterSheetState();
}

class _ResourceFilterSheetState extends State<ResourceFilterSheet> {
  static const List<String> subjects = [
    'All Subjects',
    'Indian Polity',
    'Indian Economy',
    'Tamil Nadu History',
    'Geography',
    'General Science',
    'Reasoning',
    'Current Affairs',
  ];

  static const List<String> types = [
    'All Types',
    'PDF',
    'Book',
    'Video',
    'Website',
    'Government Material',
    'Previous Papers',
    'Notes',
  ];

  static const List<String> difficulties = [
    'All Levels',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppConstants.spaceSm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.graphite700.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter Resources',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeHeadlineSmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: widget.onReset,
                  child: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeBodyMedium,
                      color: AppColors.sage500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Filters
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject filter
                  _buildSectionTitle('Subject'),
                  const SizedBox(height: AppConstants.spaceSm),
                  Wrap(
                    spacing: AppConstants.spaceSm,
                    runSpacing: AppConstants.spaceSm,
                    children: subjects.map((subject) {
                      final isSelected = widget.selectedSubject == subject ||
                          (widget.selectedSubject == null && subject == 'All Subjects');
                      return FilterChip(
                        label: Text(subject),
                        selected: isSelected,
                        onSelected: (_) {
                          widget.onSubjectChanged(
                            subject == 'All Subjects' ? null : subject,
                          );
                        },
                        selectedColor: AppColors.sage500.withValues(alpha: 0.2),
                        labelStyle: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodyMedium,
                          color: isSelected ? AppColors.sage500 : AppColors.graphite700,
                        ),
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected ? AppColors.sage500 : AppColors.outlineVariant,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: AppConstants.spaceLg),
                  
                  // Type filter
                  _buildSectionTitle('Resource Type'),
                  const SizedBox(height: AppConstants.spaceSm),
                  Wrap(
                    spacing: AppConstants.spaceSm,
                    runSpacing: AppConstants.spaceSm,
                    children: types.map((type) {
                      final isSelected = widget.selectedType == type ||
                          (widget.selectedType == null && type == 'All Types');
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (_) {
                          widget.onTypeChanged(
                            type == 'All Types' ? null : type,
                          );
                        },
                        selectedColor: AppColors.sage500.withValues(alpha: 0.2),
                        labelStyle: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodyMedium,
                          color: isSelected ? AppColors.sage500 : AppColors.graphite700,
                        ),
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected ? AppColors.sage500 : AppColors.outlineVariant,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: AppConstants.spaceLg),
                  
                  // Difficulty filter
                  _buildSectionTitle('Difficulty Level'),
                  const SizedBox(height: AppConstants.spaceSm),
                  Wrap(
                    spacing: AppConstants.spaceSm,
                    runSpacing: AppConstants.spaceSm,
                    children: difficulties.map((difficulty) {
                      final isSelected = widget.selectedDifficulty == difficulty ||
                          (widget.selectedDifficulty == null && difficulty == 'All Levels');
                      return FilterChip(
                        label: Text(difficulty),
                        selected: isSelected,
                        onSelected: (_) {
                          widget.onDifficultyChanged(
                            difficulty == 'All Levels' ? null : difficulty,
                          );
                        },
                        selectedColor: AppColors.sage500.withValues(alpha: 0.2),
                        labelStyle: GoogleFonts.inter(
                          fontSize: AppConstants.fontSizeBodyMedium,
                          color: isSelected ? AppColors.sage500 : AppColors.graphite700,
                        ),
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected ? AppColors.sage500 : AppColors.outlineVariant,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: AppConstants.spaceXl),
                ],
              ),
            ),
          ),
          
          // Apply button
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage500,
                  foregroundColor: AppColors.paper50,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spaceMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: AppConstants.fontSizeBodyLarge,
        fontWeight: FontWeight.w600,
        color: AppColors.ink900,
      ),
    );
  }
}
