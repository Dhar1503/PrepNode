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

/// Register Screen (S0.4)
/// Create a new account
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _handleRegister() async {
    // AppButton already nulls out onPressed while loading, but a second tap
    // can still land in the frame between the tap and the state update.
    if (ref.read(authProvider).isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dismiss the keyboard so the result (snackbar or route change) is not
    // competing with it for the bottom of the screen.
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go('/profile-setup');
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
      // Default (true) so the Column below is laid out inside the space the
      // keyboard leaves behind, which is what keeps the pinned footer above
      // the keyboard instead of under it.
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Only the form scrolls. The action footer is a sibling, not the
            // last child of the scroll view, so the Create Account button can
            // never scroll out of reach or end up behind the keyboard — the
            // scrollable simply gets shorter.
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
                      const SizedBox(height: AppConstants.spaceLg),
                      _buildLogo(),
                      const SizedBox(height: AppConstants.spaceLg),
                      _buildHeadline(),
                      const SizedBox(height: AppConstants.spaceXl),
                      // Uniform spaceMd between every field, so the four
                      // inputs read as one evenly spaced group.
                      _buildNameField(),
                      const SizedBox(height: AppConstants.spaceMd),
                      _buildEmailField(),
                      const SizedBox(height: AppConstants.spaceMd),
                      _buildPasswordField(),
                      const SizedBox(height: AppConstants.spaceMd),
                      _buildConfirmPasswordField(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionFooter(),
          ],
        ),
      ),
    );
  }

  /// Pinned footer: the primary action plus the link back to login.
  /// "Continue with Google" was removed — see login_screen.dart for why
  /// (no OAuth package, so it always dead-ends).
  Widget _buildActionFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceMd,
        AppConstants.spaceLg,
        AppConstants.spaceMd,
      ),
      decoration: const BoxDecoration(
        color: AppColors.paper50,
        border: Border(
          top: BorderSide(color: AppColors.lightOutlineVariant, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRegisterButton(),
          const SizedBox(height: AppConstants.spaceSm),
          _buildLoginLink(),
        ],
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
      'Create your account',
      style: GoogleFonts.fraunces(
        fontSize: AppConstants.fontSizeHeadlineSmall,
        fontWeight: FontWeight.w500,
        color: AppColors.ink900,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNameField() {
    return AppTextField(
      label: 'Name',
      hint: 'Enter your name',
      controller: _nameController,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Name is required';
        }
        if (value.length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
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
      hint: 'Create a password',
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      onToggleVisibility: _togglePasswordVisibility,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return AppTextField(
      label: 'Confirm Password',
      hint: 'Confirm your password',
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      onToggleVisibility: _toggleConfirmPasswordVisibility,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    final isLoading = ref.watch(authProvider).isLoading;
    return AppButton(
      label: 'Create Account',
      onPressed: _handleRegister,
      isLoading: isLoading,
    );
  }

  /// Centred "Already have an account? Log in" prompt.
  ///
  /// Laid out as a [Wrap], not the previous `Text.rich` + `WidgetSpan`. A
  /// WidgetSpan embeds the 48px-tall AppTextButton into a line of body
  /// text, so the line box could not contain it and "Log in" was pushed
  /// onto its own line, indented to wherever the span happened to break.
  /// A Wrap centres both parts on one line, and on a narrow screen (or at
  /// the 1.3x font scale this device runs) it drops "Log in" to a second
  /// *centred* line instead of overflowing. Mirrors the same fix on the
  /// login screen's register prompt.
  Widget _buildLoginLink() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeBodyMedium,
            color: AppColors.graphite700,
          ),
        ),
        AppTextButton(
          label: 'Log in',
          onPressed: () {
            context.pop();
          },
          textColor: AppColors.ink900,
        ),
      ],
    );
  }
}
