import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ONBOARDING SCREEN — 3 horizontal slides
//
// § 6.2 — Full-screen illustration (top 60 %) + white card (bottom 40 %)
//   with rounded top corners (32 px).
//
// Controls: page dots (gold active), Skip (top-right ghost), Next / Get Started.
// ──────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = <_SlideData>[
    _SlideData(
      icon: Icons.people_outline,
      title: 'Stay Connected to Your Church',
      body:
          'Watch sermons, join events, and grow in faith — anytime, anywhere.',
    ),
    _SlideData(
      icon: Icons.volunteer_activism_outlined,
      title: 'Give Generously',
      body: 'Support your church with secure, easy giving in seconds.',
    ),
    _SlideData(
      icon: Icons.favorite_border,
      title: 'Never Pray Alone',
      body:
          'Share prayer requests and stand in faith with your community.',
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    // Mark onboarding as seen so it never shows again.
    AuthService.instance.completeOnboarding();
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Skip button (top-right) ──────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.sp4,
                  top: AppSpacing.sp2,
                ),
                child: AppGhostButton(
                  label: 'Skip',
                  onPressed: _finish,
                ),
              ),
            ),

            // ── Page content ─────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _OnboardingSlide(slide: slide, isDark: isDark);
                },
              ),
            ),

            // ── Bottom section: dots + button ────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4,
                  vertical: AppSpacing.sp6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.gold
                                : AppColors.inactive,
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.sp6),

                    // Next / Get Started button
                    AppPrimaryButton(
                      label: _currentPage == _slides.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide widget ──────────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.slide, required this.isDark});

  final _SlideData slide;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
      child: Column(
        children: [
          // ── Illustration area (top 55 %) ─────────────────────────────
          Expanded(
            flex: 55,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.skyDark : AppColors.skyLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  slide.icon,
                  size: 80,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ),
          ),

          // ── White card (bottom 45 %) ─────────────────────────────────
          Expanded(
            flex: 45,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp6,
                AppSpacing.sp8,
                AppSpacing.sp6,
                AppSpacing.sp4,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  Text(
                    slide.body,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}
