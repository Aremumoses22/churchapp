import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CREATE NEW PASSWORD SCREEN
//
// Reached via deep-link from the password-reset email.
// User enters and confirms a new password, then returns to login.
//
// Layout: lock icon → title → body → new password → confirm → submit button.
// Success state: checkmark + "Password Updated" → Back to Sign In.
// ──────────────────────────────────────────────────────────────────────────────

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key, this.token});

  /// The password-reset token passed via deep link.
  final String? token;

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  Future<void> _resetPassword() async {
    // Validation
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both fields.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Replace with real password-reset API call using widget.token.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
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
          onPressed: () => context.go(AppRoutes.login),
          semanticLabel: 'Back to login',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: _isSuccess
                ? _SuccessView(isDark: isDark, context: context)
                : _FormView(
                    isDark: isDark,
                    passwordController: _passwordController,
                    confirmController: _confirmController,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onSubmit: _resetPassword,
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Form view ─────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({
    required this.isDark,
    required this.passwordController,
    required this.confirmController,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  final bool isDark;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Icon ────────────────────────────────────────────────────────
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: isDark ? AppColors.skyDark : AppColors.skyLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_open_outlined,
            size: 56,
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp6),

        Text(
          'Create New Password',
          style: AppTextStyles.headingLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp2),

        Text(
          'Your new password must be at least 8 characters long.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp8),

        // ── Error banner ──────────────────────────────────────────────
        if (errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sp3),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 20, color: AppColors.error),
                const SizedBox(width: AppSpacing.sp2),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sp4),
        ],

        // ── Password field ──────────────────────────────────────────
        AppTextField(
          controller: passwordController,
          label: 'New Password',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.sp3),

        // ── Confirm password ────────────────────────────────────────
        AppTextField(
          controller: confirmController,
          label: 'Confirm New Password',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppSpacing.sp6),

        // ── Submit button ───────────────────────────────────────────
        AppPrimaryButton(
          label: 'Update Password',
          isLoading: isLoading,
          onPressed: isLoading ? null : onSubmit,
        ),
      ],
    );
  }
}

// ── Success view ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.isDark, required this.context});

  final bool isDark;
  final BuildContext context;

  @override
  Widget build(BuildContext innerContext) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 56,
            color: AppColors.textInverse,
          ),
        ),
        const SizedBox(height: AppSpacing.sp6),

        Text(
          'Password Updated!',
          style: AppTextStyles.headingLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp2),

        Text(
          'Your password has been changed successfully. You can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp8),

        AppPrimaryButton(
          label: 'Back to Sign In',
          onPressed: () => context.go(AppRoutes.login),
        ),
      ],
    );
  }
}
