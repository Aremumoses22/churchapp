import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// INVITE FRIENDS SCREEN
//
// Share church app via link/QR code, personalized invite message,
// share options, referral tracking.
// ──────────────────────────────────────────────────────────────────────────────

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  static const _inviteLink = 'https://gracechurch.app/invite/abc123';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Invite Friends',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sp4),

            // ── Illustration area ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sp8),
              decoration: BoxDecoration(
                gradient: AppGradients.hero,
                borderRadius: AppRadius.borderRadiusXl,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                  Text(
                    'Invite Someone to Church',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    'Share the love of God with friends and family.\nEvery invitation can change a life.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── QR Code section ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sp6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                borderRadius: AppRadius.borderRadiusLg,
                boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
              ),
              child: Column(
                children: [
                  Text(
                    'Your Invite QR Code',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                  // QR placeholder
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.bgDark
                          : AppColors.warmWhite,
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.inputBorder,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 100,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textPrimary,
                          ),
                          const SizedBox(height: AppSpacing.sp2),
                          Text(
                            'Scan to join',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                  AppGhostButton(
                    label: 'Save QR Code',
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined, size: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── Invite link ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sp4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                borderRadius: AppRadius.borderRadiusLg,
                boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Link',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp3,
                      vertical: AppSpacing.sp3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.bgDark
                          : AppColors.inputFill,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _inviteLink,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp2),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              const ClipboardData(text: _inviteLink),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Link copied!'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.borderRadiusSm,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sp3,
                              vertical: AppSpacing.sp1,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              borderRadius: AppRadius.borderRadiusSm,
                            ),
                            child: Text(
                              'Copy',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── Share options ──────────────────────────────────────────
            Text(
              'Share Via',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.message_outlined,
                  label: 'Message',
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                  onTap: () {},
                ),
                _ShareOption(
                  icon: Icons.mail_outlined,
                  label: 'Email',
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                  onTap: () {},
                ),
                _ShareOption(
                  icon: Icons.share_outlined,
                  label: 'More',
                  color: const Color(0xFF8B5CF6),
                  isDark: isDark,
                  onTap: () {},
                ),
                _ShareOption(
                  icon: Icons.link,
                  label: 'Copy Link',
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Referral stats ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sp4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.skyDark
                    : AppColors.skyLight,
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      value: '12',
                      label: 'Invites Sent',
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.inputBorder,
                  ),
                  Expanded(
                    child: _StatItem(
                      value: '5',
                      label: 'Joined',
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.inputBorder,
                  ),
                  Expanded(
                    child: _StatItem(
                      value: '3',
                      label: 'Active',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Personalized message ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sp4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                borderRadius: AppRadius.borderRadiusLg,
                boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit_note,
                        size: 20,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sp2),
                      Text(
                        'Personalize Your Message',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sp3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.bgDark
                          : AppColors.inputFill,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Text(
                      "Hey! I'd love for you to join me at Grace Community Church. We have amazing worship, inspiring messages, and a welcoming community. Download the app and let's connect! \u2764\uFE0F",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  AppGhostButton(
                    label: 'Edit Message',
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp12),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: AppSpacing.sp2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.isDark,
  });

  final String value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headingMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
