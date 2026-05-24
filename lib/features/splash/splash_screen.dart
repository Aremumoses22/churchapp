import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/push_notification_service.dart';
import '../../core/theme/theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SPLASH SCREEN
//
// § 6.1 — colorPrimary background, centered church logo (white).
//
// Animation:
//   Logo fades in (0 → 1.0 opacity, 800 ms)
//   Then scales slightly (1.0 → 1.05, 400 ms)
//   Total: 2 seconds, then auto-navigate.
//
// Navigate to: /onboarding (first-time) | /home (returning user).
// ──────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade in: 0 → 1.0 over 800 ms.
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Scale: 1.0 → 1.05 over 400 ms (starts after fade).
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Small initial delay so the screen settles.
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // Phase 1 — fade in.
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // Phase 2 — subtle scale.
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Navigate based on persisted auth state.
    final auth = AuthService.instance;
    switch (auth.state) {
      case AuthState.firstLaunch:
        context.go(AppRoutes.onboarding);
      case AuthState.unauthenticated:
        context.go(AppRoutes.login);
      case AuthState.needsSetup:
        context.go(AppRoutes.churchCode);
      case AuthState.authenticated:
        // If the app was launched by tapping a push notification, deep-link
        // directly to the relevant screen instead of just going to /home.
        final push = PushNotificationService.instance;
        final deepLink = push.extractDeepLink(push.initialMessage);
        if (deepLink != null) {
          context.go(deepLink);
        } else {
          context.go(AppRoutes.home);
        }
      case AuthState.unknown:
        context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Church logo placeholder (white icon).
                const Icon(
                  Icons.church,
                  size: 80,
                  color: AppColors.textInverse,
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  'Church App',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
