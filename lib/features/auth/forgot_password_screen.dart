import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FORGOT PASSWORD SCREEN
//
// Two-phase flow:
//   Phase 1 — Email entry: icon, title, body, email input, send button.
//   Phase 2 — Confirmation: success icon, message, back-to-login button.
// ──────────────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailSent = false;
  String? _errorMessage;

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success =
        await ref.read(authNotifierProvider.notifier).forgotPassword(email);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isLoading = false;
        _isEmailSent = true;
      });
    } else {
      final authState = ref.read(authNotifierProvider);
      setState(() {
        _isLoading = false;
        _errorMessage = authState.error ?? 'Failed to send reset link.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
          semanticLabel: 'Go back',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: _isEmailSent
                ? _ConfirmationView(isDark: isDark, context: context)
                : _EmailEntryView(
                    isDark: isDark,
                    controller: _emailController,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onSubmit: _sendResetLink,
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Phase 1: Email entry ──────────────────────────────────────────────────────

class _EmailEntryView extends StatelessWidget {
  const _EmailEntryView({
    required this.isDark,
    required this.controller,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  final bool isDark;
  final TextEditingController controller;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: isDark ? AppColors.skyDark : AppColors.skyLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset,
            size: 56,
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp6),

        Text(
          'Reset Password',
          style: AppTextStyles.headingLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp2),
        Text(
          "Enter your email and we'll send you a link to reset your password.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp8),

        // Error
        if (errorMessage != null) ...[
          Text(
            errorMessage!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.sp3),
        ],

        // Email input
        AppTextField(
          controller: controller,
          label: 'Email',
          hint: 'you@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppSpacing.sp6),

        // Send button
        AppPrimaryButton(
          label: 'Send Reset Link',
          isLoading: isLoading,
          onPressed: isLoading ? null : onSubmit,
        ),
      ],
    );
  }
}

// ── Phase 2: Confirmation ─────────────────────────────────────────────────────

class _ConfirmationView extends StatelessWidget {
  const _ConfirmationView({required this.isDark, required this.context});

  final bool isDark;
  final BuildContext context;

  @override
  Widget build(BuildContext innerContext) {
    return Column(
      children: [
        // Success icon
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 56,
            color: AppColors.textInverse,
          ),
        ),
        const SizedBox(height: AppSpacing.sp6),

        Text(
          'Check Your Email',
          style: AppTextStyles.headingLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp2),
        Text(
          "We've sent a password reset link to your email. Please check your inbox.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp8),

        AppPrimaryButton(
          label: 'Back to Sign In',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
