import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/data/providers/data_providers.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/auth/presentation/widgets/logo_mark.dart';

/// Splash Screen (S0.1)
/// Brand introduction + silent session check before routing
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _wordmarkFadeAnimation;
  late Animation<double> _taglineFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupSystemUI();
    _startSplashSequence();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.durationLong2),
    );

    // Logo mark: fade in + scale (0-400ms)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.44, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.44, curve: Curves.easeOut),
      ),
    );

    // Wordmark: fade in (250-550ms)
    _wordmarkFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.28, 0.61, curve: Curves.easeOut),
      ),
    );

    // Tagline: fade in (400-650ms)
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.44, 0.72, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _startSplashSequence() async {
    // Start the session check immediately, but never route before the
    // animation's hold time has elapsed (900ms entrance + hold), even if the
    // check resolves earlier — the brand moment is never cut short.
    final destinationFuture = _resolveDestination();
    await Future.delayed(const Duration(milliseconds: 2000));
    final destination = await destinationFuture;
    if (mounted) {
      context.go(destination);
    }
  }

  /// Silent session check: ensures the database is ready, then looks for a
  /// persisted login (secure-storage token + local user record). Returns the
  /// route to land on — restoring a valid session straight to Home (or back
  /// to Profile Setup if it was never finished) so returning users never see
  /// onboarding or the login screen again.
  Future<String> _resolveDestination() async {
    try {
      await ref.read(databaseInitializationProvider.future);

      final authLocalDataSource = ref.read(authLocalDataSourceProvider);
      final isAuthenticated = await authLocalDataSource.isAuthenticated();
      if (!isAuthenticated) {
        return '/onboarding';
      }

      final userId = await authLocalDataSource.getCurrentUserId();
      final user = userId == null ? null : await authLocalDataSource.getUser(userId);
      if (user == null) {
        return '/onboarding';
      }

      // Session expiration handling: a persisted access token doesn't mean
      // the session is still valid — check the locally-tracked expiry
      // (covers both the offline-fallback session and a real backend
      // session's own refresh token) before restoring it.
      final sessionExpired = await authLocalDataSource.isCurrentSessionExpired();
      if (sessionExpired) {
        await authLocalDataSource.clearAuthData();
        return '/login';
      }

      ref.read(authProvider.notifier).restoreSession(user);
      return user.profileComplete ? '/home' : '/profile-setup';
    } catch (_) {
      return '/onboarding';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper50,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(flex: 38),
              _buildLogoMark(),
              const SizedBox(height: AppConstants.spaceSm),
              _buildWordmark(),
              const SizedBox(height: AppConstants.space2xs),
              _buildTagline(),
              const Spacer(flex: 62),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoMark() {
    return FadeTransition(
      opacity: _logoFadeAnimation,
      child: ScaleTransition(
        scale: _logoScaleAnimation,
        child: const LogoMark(size: 64.0),
      ),
    );
  }

  Widget _buildWordmark() {
    return FadeTransition(
      opacity: _wordmarkFadeAnimation,
      child: Text(
        'PrepNode',
        style: GoogleFonts.fraunces(
          fontSize: 24.0,
          fontWeight: FontWeight.w500,
          color: AppColors.ink900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _taglineFadeAnimation,
      child: Text(
        'Prepare with Purpose',
        style: GoogleFonts.inter(
          fontSize: 13.0,
          fontWeight: FontWeight.w400,
          color: AppColors.graphite700.withValues(alpha: 0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
