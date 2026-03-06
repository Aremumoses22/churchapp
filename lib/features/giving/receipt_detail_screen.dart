import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// RECEIPT DETAIL SCREEN
//
// Full-page receipt with church logo, donor name, amount, date, payment
// method, reference — downloadable as PDF.
// ──────────────────────────────────────────────────────────────────────────────

class ReceiptDetailScreen extends StatelessWidget {
  const ReceiptDetailScreen({super.key, this.receiptId});

  final String? receiptId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock receipt data
    const receipt = _ReceiptData(
      receiptNumber: 'RCP-2026-00847',
      donorName: 'John Doe',
      donorEmail: 'john.doe@email.com',
      amount: 250.00,
      date: 'February 23, 2026',
      time: '10:32 AM',
      paymentMethod: 'Visa •••• 4242',
      category: 'Tithe',
      campaign: 'General Fund',
      transactionId: 'TXN-8F3K2L9M',
      status: 'Completed',
      churchName: 'Grace Community Church',
      churchAddress: '1234 Faith Avenue, Springfield, IL 62704',
      churchPhone: '(217) 555-0198',
      churchEin: '45-1234567',
    );

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sp5),

            // ── Receipt card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                borderRadius: AppRadius.borderRadiusXl,
                boxShadow: isDark ? AppShadows.mdDark : AppShadows.md,
              ),
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────
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
                        // Church logo placeholder
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
                        Text(receipt.churchName,
                            style: AppTextStyles.headingSmall
                                .copyWith(color: Colors.white),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 2),
                        Text('Donation Receipt',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white60)),
                      ],
                    ),
                  ),

                  // ── Amount section ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sp6),
                    child: Column(
                      children: [
                        Text('Amount',
                            style: AppTextStyles.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '\$${receipt.amount.toStringAsFixed(2)}',
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
                            color:
                                AppColors.success.withValues(alpha: 0.1),
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle,
                                  size: 14, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text(receipt.status,
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.success)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Dotted divider ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp4),
                    child: _DottedDivider(isDark: isDark),
                  ),

                  // ── Details ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sp5),
                    child: Column(
                      children: [
                        _ReceiptRow(
                            label: 'Receipt #',
                            value: receipt.receiptNumber,
                            isDark: isDark),
                        _ReceiptRow(
                            label: 'Date',
                            value: receipt.date,
                            isDark: isDark),
                        _ReceiptRow(
                            label: 'Time',
                            value: receipt.time,
                            isDark: isDark),
                        _ReceiptRow(
                            label: 'Donor',
                            value: receipt.donorName,
                            isDark: isDark),
                        _ReceiptRow(
                            label: 'Email',
                            value: receipt.donorEmail,
                            isDark: isDark),
                        _ReceiptRow(
                            label: 'Category',
                            value: receipt.category,
                            isDark: isDark),
                        _ReceiptRow(
                            label: 'Campaign',
                            value: receipt.campaign,
                            isDark: isDark),
                        _ReceiptRow(
                            label: 'Payment',
                            value: receipt.paymentMethod,
                            isDark: isDark),
                        _ReceiptRow(
                            label: 'Transaction',
                            value: receipt.transactionId,
                            isDark: isDark,
                            isLast: true),
                      ],
                    ),
                  ),

                  // ── Footer ──────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sp4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.bgDark
                          : AppColors.warmWhite,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(AppRadius.xl),
                        bottomRight: Radius.circular(AppRadius.xl),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(receipt.churchName,
                            style: AppTextStyles.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                fontSize: 10)),
                        Text(receipt.churchAddress,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textDisabled,
                                fontSize: 9),
                            textAlign: TextAlign.center),
                        Text('EIN: ${receipt.churchEin}',
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

            // ── Action buttons ────────────────────────────────────────
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
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

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

// ── Data class ──────────────────────────────────────────────────────────────

class _ReceiptData {
  const _ReceiptData({
    required this.receiptNumber,
    required this.donorName,
    required this.donorEmail,
    required this.amount,
    required this.date,
    required this.time,
    required this.paymentMethod,
    required this.category,
    required this.campaign,
    required this.transactionId,
    required this.status,
    required this.churchName,
    required this.churchAddress,
    required this.churchPhone,
    required this.churchEin,
  });

  final String receiptNumber;
  final String donorName;
  final String donorEmail;
  final double amount;
  final String date;
  final String time;
  final String paymentMethod;
  final String category;
  final String campaign;
  final String transactionId;
  final String status;
  final String churchName;
  final String churchAddress;
  final String churchPhone;
  final String churchEin;
}
