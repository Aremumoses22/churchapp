import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/giving.dart';
import '../../core/providers/giving_providers.dart';
import '../../core/providers/user_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// RECEIPT DETAIL SCREEN
//
// Full donation receipt loaded from /giving/receipts/:id.
// Donor name/email derived from the logged-in user profile.
// ──────────────────────────────────────────────────────────────────────────────

class ReceiptDetailScreen extends ConsumerWidget {
  const ReceiptDetailScreen({super.key, this.receiptId});

  final String? receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = receiptId ?? '';
    final donationAsync = ref.watch(givingReceiptProvider(id));
    final profile = ref.watch(userNotifierProvider).profile;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Receipt',
        showBack: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined,
                color: isDark ? Colors.white70 : Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sharing receipt...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusMd),
                ),
              );
            },
          ),
        ],
      ),
      body: donationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: AppSpacing.sp3),
              Text('Failed to load receipt',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sp3),
              AppSecondaryButton(
                label: 'Retry',
                onPressed: () =>
                    ref.invalidate(givingReceiptProvider(id)),
              ),
            ],
          ),
        ),
        data: (donation) {
          if (donation == null) {
            return Center(
              child: Text('Receipt not found',
                  style: AppTextStyles.bodyMedium),
            );
          }
          return _ReceiptBody(
            donation: donation,
            donorName: profile?.name ?? 'Anonymous',
            donorEmail: profile?.email ?? '',
            isDark: isDark,
          );
        },
      ),
    );
  }
}

// ── Receipt body ─────────────────────────────────────────────────────────────

class _ReceiptBody extends StatelessWidget {
  const _ReceiptBody({
    required this.donation,
    required this.donorName,
    required this.donorEmail,
    required this.isDark,
  });

  final Donation donation;
  final String donorName;
  final String donorEmail;
  final bool isDark;

  String _formatDate(String? iso) {
    if (iso == null) return 'N/A';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour > 12
          ? dt.hour - 12
          : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final p = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $p';
    } catch (_) {
      return '';
    }
  }

  String _formatNaira(double amount) {
    final str = amount.toInt().toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return '₦${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sp5),

          // ── Receipt card ────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.surface,
              borderRadius: AppRadius.borderRadiusXl,
              boxShadow: isDark ? AppShadows.mdDark : AppShadows.md,
            ),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sp5),
                  decoration: BoxDecoration(
                    gradient: AppGradients.hero,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.xl),
                      topRight: Radius.circular(AppRadius.xl),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.church_outlined,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      Text(
                        'Grace Community Church',
                        style: AppTextStyles.headingSmall
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text('Donation Receipt',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white60)),
                    ],
                  ),
                ),

                // Amount
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.sp6),
                  child: Column(
                    children: [
                      Text('Amount',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        _formatNaira(donation.amount),
                        style: AppTextStyles.displayLarge.copyWith(
                            color: AppColors.success,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.sp2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderRadiusFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              donation.status?.toUpperCase() ?? 'COMPLETED',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Dotted divider
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
                  child: _DottedDivider(isDark: isDark),
                ),

                // Details
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sp5),
                  child: Column(
                    children: [
                      _ReceiptRow(
                          label: 'Transaction ID',
                          value: donation.id,
                          isDark: isDark),
                      _ReceiptRow(
                          label: 'Date',
                          value: _formatDate(donation.createdAt),
                          isDark: isDark),
                      _ReceiptRow(
                          label: 'Time',
                          value: _formatTime(donation.createdAt),
                          isDark: isDark),
                      _ReceiptRow(
                          label: 'Donor',
                          value: donation.isAnonymous ? 'Anonymous' : donorName,
                          isDark: isDark),
                      if (!donation.isAnonymous && donorEmail.isNotEmpty)
                        _ReceiptRow(
                            label: 'Email',
                            value: donorEmail,
                            isDark: isDark),
                      _ReceiptRow(
                          label: 'Category',
                          value: donation.categoryName ?? 'Donation',
                          isDark: isDark),
                      if (donation.paymentMethod != null)
                        _ReceiptRow(
                            label: 'Payment',
                            value: donation.paymentMethod!,
                            isDark: isDark),
                      if (donation.notes != null)
                        _ReceiptRow(
                            label: 'Notes',
                            value: donation.notes!,
                            isDark: isDark,
                            isLast: true),
                    ],
                  ),
                ),

                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sp4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgDark : AppColors.warmWhite,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.xl),
                      bottomRight: Radius.circular(AppRadius.xl),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('Grace Community Church',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontSize: 10)),
                      Text('1234 Faith Avenue, Springfield, IL 62704',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textDisabled,
                              fontSize: 9),
                          textAlign: TextAlign.center),
                      Text('EIN: 45-1234567',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textDisabled,
                              fontSize: 9)),
                      const SizedBox(height: AppSpacing.sp2),
                      Text(
                        'This receipt may be used for tax purposes.\n'
                        'No goods or services were provided in exchange.',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                            fontSize: 8,
                            fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sp6),

          // Action buttons
          AppPrimaryButton(
            label: 'Download PDF',
            icon: const Icon(Icons.download_outlined,
                color: Colors.white, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Downloading receipt as PDF...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusMd),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sp3),
          AppSecondaryButton(
            label: 'Email Receipt',
            icon: const Icon(Icons.email_outlined,
                color: AppColors.primary, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sending receipt to email...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusMd),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sp10),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)),
              const SizedBox(width: AppSpacing.sp4),
              Flexible(
                child: Text(value,
                    style: AppTextStyles.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                    textAlign: TextAlign.end),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: isDark
                ? AppColors.borderDark.withValues(alpha: 0.4)
                : AppColors.divider,
          ),
      ],
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        50,
        (i) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            height: 1,
            color: i.isEven
                ? (isDark
                    ? AppColors.borderDark.withValues(alpha: 0.5)
                    : AppColors.divider)
                : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
