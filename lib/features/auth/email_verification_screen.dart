import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EMAIL VERIFICATION SCREEN
//
// Shown after registration. The user is asked to check their inbox and
// tap the verification link. Includes:
//   • Envelope illustration
//   • Title / body explaining what to do
//   • "Open Email App" primary button
//   • "Resend Email" ghost button with cooldown timer
//   • "Change Email" ghost link to go back
//
// Once verified → navigates to /auth/login so user can sign in.
// ──────────────────────────────────────────────────────────────────────────────

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key, this.email});

  /// The email address the verification was sent to (displayed on screen).
  final String? email;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isResending = false;
  bool _isVerified = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  late final AnimationController _checkController;
  late final Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _checkController.dispose();
    super.dispose();
  }

  /// Resend the verification email via the API.
  Future<void> _resendEmail() async {
    if (_resendCooldown > 0 || widget.email == null) return;

    setState(() => _isResending = true);

    final success = await ref
        .read(authNotifierProvider.notifier)
        .resendVerification(widget.email!);

    if (!mounted) return;

    setState(() {
      _isResending = false;
      if (success) {
        _resendCooldown = 30;
      }
    });

    if (success) {
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) timer.cancel();
        });
      });
    }
  }

  /// Navigate to login so the user can sign in after verifying.
  Future<void> _checkVerification() async {
    // Show a brief success animation, then send to login.
    setState(() => _isVerified = true);
    _checkController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayEmail = widget.email ?? 'your email';

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
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sp4),

                // ── Illustration ───────────────────────────────────────
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.skyDark : AppColors.skyLight,
                    shape: BoxShape.circle,
                  ),
                  child: _isVerified
                      ? ScaleTransition(
                          scale: _checkAnimation,
                          child: const Icon(
                            Icons.check_circle,
                            size: 64,
                            color: AppColors.success,
                          ),
                        )
                      : Icon(
                          Icons.mark_email_unread_outlined,
                          size: 64,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                        ),
                ),
                const SizedBox(height: AppSpacing.sp6),

                // ── Title ──────────────────────────────────────────────
                Text(
                  _isVerified ? 'Email Verified!' : 'Verify Your Email',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp2),

                // ── Body text ──────────────────────────────────────────
                if (!_isVerified)
                  Text.rich(
                    TextSpan(
                      text: "We sent a verification link to ",
                      children: [
                        TextSpan(
                          text: displayEmail,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                        ),
                        const TextSpan(
                          text:
                              '. Please check your inbox and tap the link to continue.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  )
                else
                  Text(
                    'Your email has been verified successfully.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sp8),

                // ── Open Email button ──────────────────────────────────
                if (!_isVerified) ...[
                  AppPrimaryButton(
                    label: "I've Verified My Email",
                    onPressed: _checkVerification,
                  ),
                  const SizedBox(height: AppSpacing.sp4),

                  // ── Resend link ──────────────────────────────────────
                  _isResending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : AppGhostButton(
                          label: _resendCooldown > 0
                              ? 'Resend in ${_resendCooldown}s'
                              : 'Resend Verification Email',
                          onPressed:
                              _resendCooldown > 0 ? null : _resendEmail,
                        ),
                  const SizedBox(height: AppSpacing.sp4),

                  // ── Change email ─────────────────────────────────────
                  AppGhostButton(
                    label: 'Change Email Address',
                    onPressed: () => context.pop(),
                  ),
                ],

                const SizedBox(height: AppSpacing.sp8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
