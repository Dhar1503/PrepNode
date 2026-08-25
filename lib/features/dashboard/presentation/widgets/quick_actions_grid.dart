import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepgraph/core/theme/app_colors.dart';
import 'package:prepgraph/core/constants/app_constants.dart';
import 'package:prepgraph/core/widgets/skeleton_loader.dart';

/// Quick Actions Grid
/// Grid of quick access buttons to main modules
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.psychology,
        label: 'AI Planner',
        route: '/planner',
        color: AppColors.marigold500,
      ),
      _QuickAction(
        icon: Icons.account_tree,
        label: 'Knowledge Graph',
        route: '/learn',
        color: AppColors.sage500,
      ),
      _QuickAction(
        icon: Icons.quiz,
        label: 'PYQs',
        route: '/practice',
        color: AppColors.ink900,
      ),
      _QuickAction(
        icon: Icons.assignment,
        label: 'Mock Tests',
        route: '/mock-tests',
        color: AppColors.marigold500,
      ),
      _QuickAction(
        icon: Icons.menu_book,
        label: 'Resources',
        route: '/resources',
        color: AppColors.sage500,
      ),
      // Cutoff Intelligence tile removed: the cutoff_data it displays was
      // never sourced from any TNPSC document, and showing invented
      // historical cutoffs to exam aspirants is actively misleading. The
      // routes and screens remain in the repo, just unreachable, ready for
      // when verified figures exist.
      _QuickAction(
        icon: Icons.analytics,
        label: 'Insights',
        route: '/insights',
        color: AppColors.azure500,
      ),
      _QuickAction(
        icon: Icons.smart_toy,
        label: 'AI Assistant',
        route: '/ai-assistant',
        color: AppColors.amethyst500,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid: 2 columns on compact, 3 on medium+, 4 on expanded
          final crossAxisCount = constraints.maxWidth > 840
              ? 4
              : constraints.maxWidth > 600
                  ? 3
                  : 2;
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.2,
              crossAxisSpacing: AppConstants.spaceMd,
              mainAxisSpacing: AppConstants.spaceMd,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return _QuickActionCard(action: actions[index]);
            },
          );
        },
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  // '/learn', '/practice' and '/insights' are bottom-nav tabs — go() switches
  // branches within the shell. Everything else is a detail screen, which
  // needs push() so the back gesture returns here instead of exiting the app.
  static const _shellTabRoutes = {'/learn', '/practice', '/insights'};

  void _navigate(BuildContext context) {
    if (_shellTabRoutes.contains(action.route)) {
      context.go(action.route);
    } else {
      context.push(action.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _navigate(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper50,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(color: AppColors.lightOutline),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink900.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _navigate(context);
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            splashColor: action.color.withValues(alpha: 0.1),
            highlightColor: action.color.withValues(alpha: 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  action.label,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodyMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink900,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
