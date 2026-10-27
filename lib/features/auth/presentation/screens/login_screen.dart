import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/core/widgets/app_text_field.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';
import 'package:prepnode/features/auth/presentation/widgets/logo_mark.dart';

/// Login Screen (S0.3)
/// Authenticate a returning user
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go('/home');
    } else if (authState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper50,
      // Default (true): the Column below is laid out in the space the
      // keyboard leaves, which is what keeps the pinned footer above it.
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Only the form scrolls. The register section is a sibling of
            // the scroll view rather than its last child, so it sits at the
            // bottom of the screen regardless of how tall the form is —
            // previously it just followed the content and landed wherever
            // the form happened to end.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceLg,
                  AppConstants.spaceLg,
                  AppConstants.spaceLg,
                  AppConstants.spaceMd,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppConstants.spaceXl),
                      _buildLogo(),
                      const SizedBox(height: AppConstants.spaceLg),
                      _buildHeadline(),
                      const SizedBox(height: AppConstants.spaceXl),
                      _buildEmailField(),
                      const SizedBox(height: AppConstants.spaceMd),
                      _buildPasswordField(),
                      const SizedBox(height: AppConstants.spaceLg),
                      _buildLoginButton(),
                      const SizedBox(height: AppConstants.spaceMd),
                      // "Continue with Google" removed: it can only ever show a
                      // "not available yet" message because no OAuth sign-in
                      // package is wired up, and a button that always dead-ends is
                      // worse than no button. authProvider.loginWithGoogle is left
                      // intact for whenever a real sign-in flow is added.
                      _buildForgotPasswordLink(),
                    ],
                  ),
                ),
              ),
            ),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: const LogoMark(size: 48.0),
    );
  }

  Widget _buildHeadline() {
    return Text(
      'Welcome back!',
      style: GoogleFonts.fraunces(
        fontSize: AppConstants.fontSizeHeadlineSmall,
        fontWeight: FontWeight.w500,
        color: AppColors.ink900,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Email',
      hint: 'Enter your email',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return AppTextField(
      label: 'Password',
      hint: 'Enter your password',
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onToggleVisibility: _togglePasswordVisibility,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    final isLoading = ref.watch(authProvider).isLoading;
    return AppButton(
      label: 'Login',
      onPressed: _handleLogin,
      isLoading: isLoading,
    );
  }

  Widget _buildForgotPasswordLink() {
    return Center(
      child: AppTextButton(
        label: 'Forgot password?',
        onPressed: () {
          context.push('/forgot-password');
        },
      ),
    );
  }

  /// Pinned bottom-centre register prompt.
  ///
  /// Laid out as a [Wrap], not the previous `Text.rich` + `WidgetSpan`. A
  /// WidgetSpan embeds the 48px-tall AppTextButton into a line of body
  /// text, so the line box could not contain it and "Register" was pushed
  /// onto its own line, indented to wherever the span happened to break —
  /// which is the misalignment on screen. A Wrap centres both parts on one
  /// line, and on a narrow screen (or at the 1.3x font scale this device
  /// runs) it drops "Register" to a second *centred* line instead of
  /// overflowing.
  Widget _buildRegisterLink() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceSm,
        AppConstants.spaceLg,
        AppConstants.spaceMd,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeBodyMedium,
              color: AppColors.graphite700,
            ),
          ),
          AppTextButton(
            label: 'Register',
            onPressed: () {
              context.push('/register');
            },
            textColor: AppColors.ink900,
          ),
        ],
      ),
    );
  }
}
