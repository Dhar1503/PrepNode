import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/data/providers/data_providers.dart';
import 'package:prepnode/core/utils/failures.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/settings/presentation/providers/settings_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings Screen (S10.4)
/// App-level configuration, reusing the existing auth/profile/cache
/// architecture — no new backend, no fabricated toggles.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Your progress is saved and will be here when you return.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Log out', style: TextStyle(color: AppColors.ink900)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final refreshToken = await ref.read(authLocalDataSourceProvider).getRefreshToken();
    await ref.read(authProvider.notifier).logout(refreshToken: refreshToken ?? '');

    if (!context.mounted) return;
    context.go('/login');
  }

  Future<void> _handleClearCache(BuildContext context, WidgetRef ref) async {
    final cacheManager = await ref.read(cacheManagerProvider.future);
    final result = await cacheManager.clearAllCacheTimestamps();

    if (!context.mounted) return;
    result.fold(
      onFailure: (failure) {
        final message = failure is Failure ? failure.message : failure.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't clear cache: $message")),
        );
      },
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared. Your progress and account are untouched.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.paper50,
      appBar: AppBar(
        backgroundColor: AppColors.paper50,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.fraunces(
            fontSize: AppConstants.fontSizeHeadlineSmall,
            fontWeight: FontWeight.w500,
            color: AppColors.ink900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        children: [
          _sectionHeader('Appearance'),
          _themeSelector(context, ref, themeMode),
          if (themeMode != ThemeMode.light) ...[
            const SizedBox(height: AppConstants.spaceXs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
              child: Text(
                'Dark and System themes are still being polished — some screens may not look right yet.',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spaceLg),
          _sectionHeader('Account'),
          _navTile(
            context,
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => context.go('/profile'),
          ),
          _navTile(
            context,
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => context.push('/notifications'),
          ),
          _disabledTile(
            icon: Icons.tune,
            label: 'Notification preferences',
            note: 'Not available in this prototype yet',
          ),
          const SizedBox(height: AppConstants.spaceLg),
          _sectionHeader('Data'),
          _navTile(
            context,
            icon: Icons.cleaning_services_outlined,
            label: 'Clear cache',
            subtitle: "Frees up cached data — your progress and account aren't affected",
            onTap: () => _handleClearCache(context, ref),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          _sectionHeader('About'),
          _infoTile('App version', AppConstants.appVersion),
          _navTile(
            context,
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            subtitle: 'Opens in your browser',
            trailing: const Icon(Icons.open_in_new, size: 20),
            onTap: () => _openPrivacyPolicy(context),
          ),
          _disabledTile(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            note: 'Not available in this prototype yet',
          ),
          const SizedBox(height: AppConstants.spaceXl),
          AppSecondaryButton(
            label: 'Log out',
            onPressed: () => _handleLogout(context, ref),
          ),
          const SizedBox(height: AppConstants.spaceLg),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: AppConstants.fontSizeBodySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.graphite700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _themeSelector(BuildContext context, WidgetRef ref, ThemeMode current) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceSm),
      margin: const EdgeInsets.only(bottom: AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: ThemeMode.values.map((mode) {
          final isSelected = mode == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
              child: Container(
                margin: EdgeInsets.only(
                  right: mode != ThemeMode.values.last ? AppConstants.spaceXs : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSm),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.ink900 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Text(
                  _themeModeLabel(mode),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeBodySmall,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.lightOnPrimary : AppColors.ink900,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    /// Overrides the default chevron. An external link uses an
    /// open-in-new icon instead, so the row does not promise in-app
    /// navigation when it actually hands off to the browser.
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.ink900),
        title: Text(
          label,
          style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodyMedium, color: AppColors.ink900),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeBodySmall,
                  color: AppColors.graphite700,
                ),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// The policy is hosted, not bundled — Play requires a reachable URL, and
  /// a copy inside the app could silently drift from the published one.
  Future<void> _openPrivacyPolicy(BuildContext context) async {
    const url = 'https://dhar1503.github.io/prepnode-privacy/';
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(url);

    // externalApplication, not the in-app webview: this is the one screen
    // where the user may want to keep the policy open, share it, or check
    // the address bar to confirm what they are reading.
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Couldn\'t open the privacy policy: $url')),
      );
    }
  }

  Widget _disabledTile({
    required IconData icon,
    required String label,
    required String note,
  }) {
    final disabledColor = AppColors.graphite700.withValues(alpha: 0.5);
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: disabledColor),
        title: Text(
          label,
          style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodyMedium, color: disabledColor),
        ),
        subtitle: Text(
          note,
          style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodySmall, color: disabledColor),
        ),
        enabled: false,
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper50,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodyMedium, color: AppColors.ink900),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: AppConstants.fontSizeBodyMedium, color: AppColors.graphite700),
          ),
        ],
      ),
    );
  }
}
