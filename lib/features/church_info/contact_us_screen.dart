import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CONTACT US SCREEN
// ──────────────────────────────────────────────────────────────────────────────

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
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

  Future<void> _sendMessage() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in the subject and message.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
        ),
      );
      return;
    }
    await ref.read(contactFormProvider.notifier).send(subject, message);
    final state = ref.read(contactFormProvider);
    if (!mounted) return;
    if (state.success) {
      _subjectController.clear();
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message sent! We will respond soon.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
        ),
      );
      ref.read(contactFormProvider.notifier).reset();
    } else if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final church = ref.watch(churchAboutProvider).value;
    final formState = ref.watch(contactFormProvider);

    final phone = church?.phone ?? '(555) 123-4567';
    final email = church?.email ?? 'hello@grace.church';
    final address = church?.address ?? '1234 Grace Avenue, Downtown\nSpringfield, IL 62701';
    final socialLinks = church?.socialLinks;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Contact Us', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sp4),

            // ── Map placeholder ──────────────────────────────────────────
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
                    Icon(Icons.map_outlined, size: 48, color: isDark ? AppColors.textSecondaryDark : AppColors.primary.withValues(alpha: 0.4)),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      address,
                      style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── Contact info cards ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ContactTile(
                    icon: Icons.phone_outlined,
                    label: 'Call Us',
                    value: phone,
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
                    value: email,
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

            // ── Social media ─────────────────────────────────────────────
            Text(
              'Follow Us',
              style: AppTextStyles.headingSmall.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (socialLinks?.facebook != null || church == null)
                  _SocialButton(icon: Icons.facebook_outlined, label: 'Facebook', color: const Color(0xFF1877F2), isDark: isDark, onTap: () {}),
                const SizedBox(width: AppSpacing.sp4),
                if (socialLinks?.instagram != null || church == null)
                  _SocialButton(icon: Icons.camera_alt_outlined, label: 'Instagram', color: const Color(0xFFE1306C), isDark: isDark, onTap: () {}),
                const SizedBox(width: AppSpacing.sp4),
                if (socialLinks?.youtube != null || church == null)
                  _SocialButton(icon: Icons.play_circle_outline, label: 'YouTube', color: const Color(0xFFDC2626), isDark: isDark, onTap: () {}),
                const SizedBox(width: AppSpacing.sp4),
                _SocialButton(icon: Icons.language, label: 'Website', color: const Color(0xFF1E40AF), isDark: isDark, onTap: () {}),
              ],
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Send a message ───────────────────────────────────────────
            Text(
              'Send a Message',
              style: AppTextStyles.headingSmall.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              'Have a question or need prayer? We would love to hear from you.',
              style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
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
              label: formState.isLoading ? 'Sending...' : 'Send Message',
              onPressed: formState.isLoading ? null : _sendMessage,
              isFullWidth: true,
              icon: formState.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_outlined, color: Colors.white, size: 18),
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
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(child: Icon(icon, color: color, size: 20)),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textDisabled, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.labelSmall.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), textAlign: TextAlign.center),
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
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Center(child: Icon(icon, color: color, size: 22)),
          ),
          const SizedBox(height: AppSpacing.sp1),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}
