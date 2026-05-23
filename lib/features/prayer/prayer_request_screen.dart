import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PRAYER REQUEST SCREEN
//
// Bottom-sheet form: submits to POST /prayer-requests via prayerRequestsProvider.
// ──────────────────────────────────────────────────────────────────────────────

class PrayerRequestScreen extends ConsumerStatefulWidget {
  const PrayerRequestScreen({super.key});

  @override
  ConsumerState<PrayerRequestScreen> createState() =>
      _PrayerRequestScreenState();
}

class _PrayerRequestScreenState extends ConsumerState<PrayerRequestScreen> {
  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  bool _isPublic = true;
  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.cardDark : AppColors.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _submitted
              ? _SuccessContent(isDark: isDark)
              : _FormContent(
                  titleCtrl: _titleCtrl,
                  detailsCtrl: _detailsCtrl,
                  isPublic: _isPublic,
                  isLoading: _isLoading,
                  onToggleVisibility: () =>
                      setState(() => _isPublic = !_isPublic),
                  onSubmit: _submit,
                  isDark: isDark,
                ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _isLoading = true);

    final ok = await ref.read(prayerRequestsProvider.notifier).submit(
          title: title,
          content: _detailsCtrl.text.trim().isEmpty
              ? null
              : _detailsCtrl.text.trim(),
          isAnonymous: !_isPublic,
        );

    if (!mounted) return;

    if (ok) {
      setState(() {
        _isLoading = false;
        _submitted = true;
      });
      Timer(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to submit prayer request. Try again.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusMd),
        ),
      );
    }
  }
}

// ── Form content ──────────────────────────────────────────────────────────────

class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.titleCtrl,
    required this.detailsCtrl,
    required this.isPublic,
    required this.isLoading,
    required this.onToggleVisibility,
    required this.onSubmit,
    required this.isDark,
  });

  final TextEditingController titleCtrl;
  final TextEditingController detailsCtrl;
  final bool isPublic;
  final bool isLoading;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.sp4,
        right: AppSpacing.sp4,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.sp6,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: AppRadius.borderRadiusFull,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Text(
              'Share a Prayer Request',
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp1),
            Text(
              'Let your church family stand with you in prayer.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            AppTextField(
              controller: titleCtrl,
              label: 'Prayer title',
              hint: 'e.g. Healing, Provision, Guidance',
            ),
            const SizedBox(height: AppSpacing.sp4),
            Text(
              'Details (optional)',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDark : const Color(0xFFF9FAFB),
                borderRadius: AppRadius.borderRadiusMd,
                border: Border.all(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.inputBorder,
                ),
              ),
              child: TextField(
                controller: detailsCtrl,
                maxLines: null,
                expands: true,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Share details about your prayer request...',
                  hintStyle:
                      AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            GestureDetector(
              onTap: onToggleVisibility,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp3,
                    vertical: AppSpacing.sp2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.bgDark
                      : (isPublic
                          ? AppColors.skyLight
                          : const Color(0xFFF3F4F6)),
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPublic ? Icons.lock_open : Icons.lock,
                      size: 16,
                      color: isPublic
                          ? (isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPublic
                          ? 'Share with church'
                          : 'Private (just for me)',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isPublic
                            ? (isDark
                                ? AppColors.primaryLight
                                : AppColors.primary)
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp5),
            AppPrimaryButton(
              label: isLoading ? 'Sending...' : 'Send Prayer Request',
              onPressed: isLoading ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success content ────────────────────────────────────────────────────────────

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sp8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sp6),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.15)
                  : AppColors.skyLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('\u{1F64F}', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            'Prayer Sent',
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sp2),
          Text(
            "We're praying with you.",
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sp6),
        ],
      ),
    );
  }
}
