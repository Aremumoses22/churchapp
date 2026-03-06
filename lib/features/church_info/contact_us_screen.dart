import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CONTACT US SCREEN
//
// Church address with map placeholder, phone, email, social media links,
// "Send a Message" form.
// ──────────────────────────────────────────────────────────────────────────────

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Contact Us',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sp4),

            // ── Map placeholder ──────────────────────────────────────
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.skyLight,
                borderRadius: AppRadius.borderRadiusLg,
                boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.primary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      '1234 Grace Avenue, Downtown\nSpringfield, IL 62701',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── Contact info cards ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ContactTile(
                    icon: Icons.phone_outlined,
                    label: 'Call Us',
                    value: '(555) 123-4567',
                    color: const Color(0xFF059669),
                    isDark: isDark,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(
                  child: _ContactTile(
                    icon: Icons.mail_outlined,
                    label: 'Email',
                    value: 'hello@grace.church',
                    color: const Color(0xFF3B82F6),
                    isDark: isDark,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.cardGap),

            Row(
              children: [
                Expanded(
                  child: _ContactTile(
                    icon: Icons.access_time_outlined,
                    label: 'Office Hours',
                    value: 'Mon-Fri 9-5',
                    color: const Color(0xFFF59E0B),
                    isDark: isDark,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(
                  child: _ContactTile(
                    icon: Icons.location_on_outlined,
                    label: 'Directions',
                    value: 'Get Directions',
                    color: const Color(0xFFEF4444),
                    isDark: isDark,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Social media ─────────────────────────────────────────
            Text(
              'Follow Us',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _SocialButton(
                  icon: Icons.language,
                  label: 'Website',
                  color: const Color(0xFF1E40AF),
                  isDark: isDark,
                  onTap: () {},
                ),
                const SizedBox(width: AppSpacing.sp4),
                _SocialButton(
                  icon: Icons.play_circle_outline,
                  label: 'YouTube',
                  color: const Color(0xFFDC2626),
                  isDark: isDark,
                  onTap: () {},
                ),
                const SizedBox(width: AppSpacing.sp4),
                _SocialButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  color: const Color(0xFFE1306C),
                  isDark: isDark,
                  onTap: () {},
                ),
                const SizedBox(width: AppSpacing.sp4),
                _SocialButton(
                  icon: Icons.facebook_outlined,
                  label: 'Facebook',
                  color: const Color(0xFF1877F2),
                  isDark: isDark,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Send a message ───────────────────────────────────────
            Text(
              'Send a Message',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              'Have a question or need prayer? We would love to hear from you.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.sp4),

            AppTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: AppSpacing.sp4),
            AppTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              prefixIcon: Icons.mail_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.sp4),
            AppTextField(
              controller: _subjectController,
              label: 'Subject',
              hint: 'What is this about?',
              prefixIcon: Icons.subject,
            ),
            const SizedBox(height: AppSpacing.sp4),
            AppTextField(
              controller: _messageController,
              label: 'Message',
              hint: 'Type your message here...',
              maxLines: 5,
            ),

            const SizedBox(height: AppSpacing.sp6),

            AppPrimaryButton(
              label: 'Send Message',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Message sent! We will respond soon.'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                  ),
                );
              },
              isFullWidth: true,
              icon: const Icon(Icons.send_outlined, color: Colors.white, size: 18),
            ),

            const SizedBox(height: AppSpacing.sp12),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusMd,
          boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 22),
            ),
          ),
          const SizedBox(height: AppSpacing.sp1),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
