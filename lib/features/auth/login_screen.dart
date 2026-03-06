import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// LOGIN SCREEN
//
// § 6.3 — Single scroll column, 16 px horizontal padding.
//
// Elements (top → bottom):
//   1. Church logo · 2. "Welcome Back 👋" · 3. Subtitle
//   4. Email input · 5. Password input · 6. Forgot Password?
//   7. Sign In button · 8. Divider "OR" · 9. Google btn · 10. Apple btn
//   11. "Don't have an account? Sign Up"
//
// States: Loading (spinner in button), Error (red banner), Success (navigate).
// ──────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Replace with real auth logic.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Mark user as logged in.
    final email = _emailController.text.trim();
    await AuthService.instance.login(email: email);

    setState(() => _isLoading = false);

    if (!mounted) return;

    // Route based on setup completion:
    //   First-time login → church code, returning user → home.
    if (AuthService.instance.hasCompletedSetup) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.churchCode);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sp6),

                // 1 ── Church logo
                Center(
                  child: Icon(
                    Icons.church,
                    size: 60,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp6),

                // 2 ── Welcome heading
                Text(
                  'Welcome Back 👋',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp2),

                // 3 ── Subtitle
                Text(
                  'Sign in to your church account',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp6),

                // ── Error banner ──────────────────────────────────────────
                if (_errorMessage != null) ...[
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
                            _errorMessage!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                ],

                // 4 ── Email input
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.sp3),

                // 5 ── Password input
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _signIn(),
                ),
                const SizedBox(height: AppSpacing.sp2),

                // 6 ── Forgot Password?
                Align(
                  alignment: Alignment.centerRight,
                  child: AppGhostButton(
                    label: 'Forgot Password?',
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.sp6),

                // 7 ── Sign In button
                AppPrimaryButton(
                  label: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _signIn,
                ),
                const SizedBox(height: AppSpacing.sp6),

                // 8 ── Divider with "OR"
                _OrDivider(isDark: isDark),
                const SizedBox(height: AppSpacing.sp3),

                // 9 ── Google sign-in
                AppSecondaryButton(
                  label: 'Continue with Google',
                  icon: Icon(
                    Icons.g_mobiledata,
                    size: 24,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                  onPressed: () {
                    // TODO: Google sign-in
                  },
                ),
                const SizedBox(height: AppSpacing.sp3),

                // 10 ── Apple sign-in
                AppSecondaryButton(
                  label: 'Continue with Apple',
                  icon: Icon(
                    Icons.apple,
                    size: 24,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                  onPressed: () {
                    // TODO: Apple sign-in
                  },
                ),
                const SizedBox(height: AppSpacing.sp6),

                // 11 ── Sign Up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    AppGhostButton(
                      label: 'Sign Up',
                      onPressed: () => context.push(AppRoutes.register),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── "OR" divider ──────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        isDark ? AppColors.borderDark : AppColors.divider;
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
          child: Text(
            'OR',
            style: AppTextStyles.labelSmall.copyWith(color: textColor),
          ),
        ),
        Expanded(child: Divider(color: dividerColor, height: 1)),
      ],
    );
  }
}
