import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/theme/app_colors.dart';

/// Search Bar Widget
/// Reusable search bar for resources
class ResourceSearchBar extends StatefulWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback? onFilterTap;

  const ResourceSearchBar({
    super.key,
    required this.query,
    required this.onQueryChanged,
    this.onFilterTap,
  });

  @override
  State<ResourceSearchBar> createState() => _ResourceSearchBarState();
}

class _ResourceSearchBarState extends State<ResourceSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _controller.addListener(() {
      widget.onQueryChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ResourceSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) {
      _controller.text = widget.query;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppConstants.spaceMd),
          Icon(
            Icons.search,
            color: AppColors.graphite700,
            size: 24,
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search resources, topics, authors...',
                hintStyle: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodyMedium,
                  color: AppColors.graphite700,
                ),
                border: InputBorder.none,
              ),
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                color: AppColors.ink900,
              ),
            ),
          ),
          if (widget.onFilterTap != null)
            IconButton(
              icon: Icon(
                Icons.tune,
                color: AppColors.graphite700,
              ),
              onPressed: widget.onFilterTap,
            ),
          if (widget.query.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: AppColors.graphite700,
              ),
              onPressed: () {
                _controller.clear();
                widget.onQueryChanged('');
              },
            ),
        ],
      ),
    );
  }
}
