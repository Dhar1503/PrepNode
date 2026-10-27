import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prepnode/core/theme/app_colors.dart';
import 'package:prepnode/core/constants/app_constants.dart';
import 'package:prepnode/core/widgets/app_button.dart';
import 'package:prepnode/core/widgets/app_text_field.dart';
import 'package:prepnode/features/auth/presentation/providers/auth_providers.dart';

/// Forgot Password Screen (S0.5)
/// Request password reset
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ref.read(authRepositoryProvider).forgotPassword(
          email: _emailController.text.trim(),
        );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      },
    );
  }

  void _handleBackToLogin() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spaceXl),
                _buildBackButton(),
                const SizedBox(height: AppConstants.spaceLg),
                _buildHeadline(),
                const SizedBox(height: AppConstants.spaceSm),
                _buildDescription(),
                const SizedBox(height: AppConstants.spaceXl),
                if (!_emailSent) ...[
                  _buildEmailField(),
                  const SizedBox(height: AppConstants.spaceLg),
                  _buildSendButton(),
                ] else ...[
                  _buildSuccessMessage(),
                  const SizedBox(height: AppConstants.spaceLg),
                  _buildBackButton(),
                ],
                const SizedBox(height: AppConstants.spaceXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _handleBackToLogin,
        color: AppColors.ink900,
      ),
    );
  }

  Widget _buildHeadline() {
    return Text(
      'Forgot password?',
      style: GoogleFonts.fraunces(
        fontSize: AppConstants.fontSizeHeadlineSmall,
        fontWeight: FontWeight.w500,
        color: AppColors.ink900,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      _emailSent
          ? 'We\'ve sent a password reset link to your email. Please check your inbox and follow the instructions.'
          : 'Enter your email address and we\'ll send you a link to reset your password.',
      style: GoogleFonts.inter(
        fontSize: AppConstants.fontSizeBodyMedium,
        color: AppColors.graphite700,
        height: 1.5,
      ),
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Email',
      hint: 'Enter your email',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
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

  Widget _buildSendButton() {
    return AppButton(
      label: 'Send Reset Link',
      onPressed: _handleSendResetLink,
      isLoading: _isLoading,
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.sage500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: AppColors.sage500,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.sage500,
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              'Reset link sent!',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeBodyMedium,
                fontWeight: FontWeight.w500,
                color: AppColors.sage500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
