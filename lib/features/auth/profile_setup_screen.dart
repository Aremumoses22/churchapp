import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PROFILE SETUP SCREEN
//
// Shown once after church-code entry (first-time registration flow).
// Lets the user optionally add a profile photo, display name, and a short bio
// before entering the main app.
//
// Layout: avatar circle → name input → bio input → "Complete Setup" button
//         + "Skip for now" ghost link.
//
// On completion → marks setup as done in AuthService → navigates to /home.
// ──────────────────────────────────────────────────────────────────────────────

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with name from registration if available.
    final savedName = AuthService.instance.userName;
    if (savedName != null) {
      _displayNameController.text = savedName;
    }
  }

  Future<void> _completeSetup() async {
    setState(() => _isLoading = true);

    // TODO: Upload profile data to backend.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Persist that setup is complete.
    await AuthService.instance.completeSetup();

    setState(() => _isLoading = false);
    if (!mounted) return;

    context.go(AppRoutes.home);
  }

  Future<void> _skip() async {
    await AuthService.instance.completeSetup();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
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
              children: [
                const SizedBox(height: AppSpacing.sp8),

                // ── Title ───────────────────────────────────────────────
                Text(
                  'Set Up Your Profile',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp2),
                Text(
                  'Help your church community get to know you.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp8),

                // ── Avatar placeholder ──────────────────────────────────
                GestureDetector(
                  onTap: () {
                    // TODO: Pick image from gallery / camera.
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.skyDark : AppColors.skyLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.inputBorder,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 56,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.bgDark
                                : AppColors.warmWhite,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: AppColors.textInverse,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sp3),
                Text(
                  'Tap to add photo',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp6),

                // ── Display name ────────────────────────────────────────
                AppTextField(
                  controller: _displayNameController,
                  label: 'Display Name',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.sp3),

                // ── Bio ─────────────────────────────────────────────────
                AppTextField(
                  controller: _bioController,
                  label: 'Short Bio (optional)',
                  hint: 'Tell your community a little about yourself...',
                  prefixIcon: Icons.edit_outlined,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.sp8),

                // ── Complete Setup button ───────────────────────────────
                AppPrimaryButton(
                  label: 'Complete Setup',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _completeSetup,
                ),
                const SizedBox(height: AppSpacing.sp4),

                // ── Skip link ───────────────────────────────────────────
                AppGhostButton(
                  label: 'Skip for now',
                  onPressed: _skip,
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
