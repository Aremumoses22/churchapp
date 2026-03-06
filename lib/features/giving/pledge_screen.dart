import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PLEDGE SCREEN
//
// Make a giving pledge toward a campaign, pledge tracker showing progress
// vs. commitment.
// ──────────────────────────────────────────────────────────────────────────────

class PledgeScreen extends StatefulWidget {
  const PledgeScreen({super.key, this.campaignId});

  final String? campaignId;

  @override
  State<PledgeScreen> createState() => _PledgeScreenState();
}

class _PledgeScreenState extends State<PledgeScreen> {
  final _amountCtrl = TextEditingController();
  String _selectedFrequency = 'Monthly';
  int _selectedDuration = 12; // months
  bool _hasExistingPledge = true; // Toggle for demo

  // Existing pledge mock
  final _existingPledge = const _PledgeData(
    campaignName: 'New Youth Center',
    totalPledged: 6000,
    totalPaid: 3500,
    monthlyAmount: 500,
    frequency: 'Monthly',
    startDate: 'Sep 2025',
    nextDue: 'Mar 15, 2026',
    paymentsCompleted: 7,
    totalPayments: 12,
  );

  final _paymentHistory = const [
    _PledgePayment(date: 'Feb 15, 2026', amount: 500, status: 'Paid'),
    _PledgePayment(date: 'Jan 15, 2026', amount: 500, status: 'Paid'),
    _PledgePayment(date: 'Dec 15, 2025', amount: 500, status: 'Paid'),
    _PledgePayment(date: 'Nov 15, 2025', amount: 500, status: 'Paid'),
    _PledgePayment(date: 'Oct 15, 2025', amount: 500, status: 'Paid'),
    _PledgePayment(date: 'Sep 15, 2025', amount: 500, status: 'Paid'),
    _PledgePayment(date: 'Aug 15, 2025', amount: 500, status: 'Paid'),
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'My Pledge', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sp4),

            if (_hasExistingPledge) ...[
              _buildPledgeTracker(isDark),
              const SizedBox(height: AppSpacing.sp5),
              _buildPaymentHistory(isDark),
            ] else ...[
              _buildNewPledgeForm(isDark),
            ],

            const SizedBox(height: AppSpacing.sp4),

            // Toggle for demo
            Center(
              child: TextButton(
                onPressed: () =>
                    setState(() => _hasExistingPledge = !_hasExistingPledge),
                child: Text(
                  _hasExistingPledge
                      ? 'Make a New Pledge'
                      : 'View Existing Pledge',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sp10),
          ],
        ),
      ),
    );
  }

  // ── Pledge tracker (existing pledge) ──────────────────────────────────

  Widget _buildPledgeTracker(bool isDark) {
    final progress =
        _existingPledge.totalPaid / _existingPledge.totalPledged;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusFull,
            ),
            child: Text(_existingPledge.campaignName,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.primary, fontSize: 11)),
          ),

          const SizedBox(height: AppSpacing.sp4),

          // Amounts
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_existingPledge.totalPaid.toStringAsFixed(0)}',
                style: AppTextStyles.displayMedium
                    .copyWith(color: AppColors.success),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                    'of \$${_existingPledge.totalPledged.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sp4),

          // Progress bar
          ClipRRect(
            borderRadius: AppRadius.borderRadiusFull,
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Container(
                    color:
                        isDark ? AppColors.borderDark : AppColors.inputFill,
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.success,
                          AppColors.success.withValues(alpha: 0.7),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp2),
          Text(
            '${(progress * 100).toInt()}% completed  •  '
            '${_existingPledge.paymentsCompleted}/${_existingPledge.totalPayments} payments',
            style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 11),
          ),

          const SizedBox(height: AppSpacing.sp5),
          const AppDivider(),
          const SizedBox(height: AppSpacing.sp4),

          // Details grid
          Row(
            children: [
              _DetailItem(
                  label: 'Amount',
                  value:
                      '\$${_existingPledge.monthlyAmount.toStringAsFixed(0)}/mo',
                  isDark: isDark),
              _DetailItem(
                  label: 'Frequency',
                  value: _existingPledge.frequency,
                  isDark: isDark),
            ],
          ),
          const SizedBox(height: AppSpacing.sp3),
          Row(
            children: [
              _DetailItem(
                  label: 'Since',
                  value: _existingPledge.startDate,
                  isDark: isDark),
              _DetailItem(
                  label: 'Next Due',
                  value: _existingPledge.nextDue,
                  isDark: isDark),
            ],
          ),

          const SizedBox(height: AppSpacing.sp5),

          // Remaining
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sp3),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: AppColors.gold),
                const SizedBox(width: AppSpacing.sp2),
                Text(
                  '\$${(_existingPledge.totalPledged - _existingPledge.totalPaid).toStringAsFixed(0)} remaining  •  '
                  '${_existingPledge.totalPayments - _existingPledge.paymentsCompleted} payments left',
                  style: AppTextStyles.bodySmall.copyWith(
                      color:
                          isDark ? AppColors.goldLight : AppColors.gold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment history ───────────────────────────────────────────────────

  Widget _buildPaymentHistory(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment History',
            style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.sp3),
        ..._paymentHistory.map((p) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sp2),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4, vertical: AppSpacing.sp3),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                borderRadius: AppRadius.borderRadiusMd,
                boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        size: 16, color: AppColors.success),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.date,
                            style: AppTextStyles.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary)),
                        Text(p.status,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.success, fontSize: 10)),
                      ],
                    ),
                  ),
                  Text('\$${p.amount}',
                      style: AppTextStyles.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)),
                ],
              ),
            )),
      ],
    );
  }

  // ── New pledge form ───────────────────────────────────────────────────

  Widget _buildNewPledgeForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sp5),
          decoration: BoxDecoration(
            gradient: AppGradients.hero,
            borderRadius: AppRadius.borderRadiusXl,
          ),
          child: Column(
            children: [
              const Icon(Icons.volunteer_activism_outlined,
                  color: Colors.white, size: 40),
              const SizedBox(height: AppSpacing.sp3),
              Text('Make a Pledge',
                  style: AppTextStyles.headingLarge
                      .copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.sp1),
              Text('Commit to regular giving toward a campaign',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white70),
                  textAlign: TextAlign.center),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sp5),

        // Amount
        Text('Pledge Amount',
            style: AppTextStyles.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.sp2),

        // Quick amounts
        Row(
          children: [50, 100, 250, 500]
              .map((a) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _amountCtrl.text = '$a';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sp2),
                          decoration: BoxDecoration(
                            color: _amountCtrl.text == '$a'
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.cardDark
                                    : AppColors.surface),
                            borderRadius: AppRadius.borderRadiusMd,
                            border: Border.all(
                                color: _amountCtrl.text == '$a'
                                    ? AppColors.primary
                                    : AppColors.inputBorder),
                          ),
                          child: Center(
                            child: Text('\$$a',
                                style: AppTextStyles.labelMedium.copyWith(
                                    color: _amountCtrl.text == '$a'
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary))),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),

        const SizedBox(height: AppSpacing.sp3),
        AppTextField(
          controller: _amountCtrl,
          label: 'Custom Amount',
          hint: 'Enter amount',
          prefixIcon: Icons.attach_money,
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: AppSpacing.sp5),

        // Frequency
        Text('Frequency',
            style: AppTextStyles.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.sp2),
        Row(
          children: ['Weekly', 'Bi-Weekly', 'Monthly']
              .map((f) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFrequency = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sp3),
                          decoration: BoxDecoration(
                            color: _selectedFrequency == f
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.cardDark
                                    : AppColors.surface),
                            borderRadius: AppRadius.borderRadiusMd,
                            border: Border.all(
                                color: _selectedFrequency == f
                                    ? AppColors.primary
                                    : AppColors.inputBorder),
                          ),
                          child: Center(
                            child: Text(f,
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: _selectedFrequency == f
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary))),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),

        const SizedBox(height: AppSpacing.sp5),

        // Duration
        Text('Duration',
            style: AppTextStyles.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.sp2),
        Row(
          children: [3, 6, 12, 24]
              .map((m) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDuration = m),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sp3),
                          decoration: BoxDecoration(
                            color: _selectedDuration == m
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.cardDark
                                    : AppColors.surface),
                            borderRadius: AppRadius.borderRadiusMd,
                            border: Border.all(
                                color: _selectedDuration == m
                                    ? AppColors.primary
                                    : AppColors.inputBorder),
                          ),
                          child: Center(
                            child: Text('$m mo',
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: _selectedDuration == m
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary))),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),

        const SizedBox(height: AppSpacing.sp6),

        // Summary card
        if (_amountCtrl.text.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sp4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.06),
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text('Pledge Summary',
                    style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.success)),
                const SizedBox(height: AppSpacing.sp2),
                Text(
                  '\$${_amountCtrl.text} $_selectedFrequency for $_selectedDuration months',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
                ),
                Text(
                  'Total: \$${_calculateTotal()}',
                  style: AppTextStyles.bodyLargeSemiBold
                      .copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sp5),
        ],

        // Submit
        AppPrimaryButton(
          label: 'Submit Pledge',
          icon: const Icon(Icons.handshake_outlined,
              color: Colors.white, size: 18),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Pledge submitted successfully!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusMd),
              ),
            );
          },
        ),
      ],
    );
  }

  String _calculateTotal() {
    final amount = int.tryParse(_amountCtrl.text) ?? 0;
    int multiplier;
    switch (_selectedFrequency) {
      case 'Weekly':
        multiplier = _selectedDuration * 4;
        break;
      case 'Bi-Weekly':
        multiplier = _selectedDuration * 2;
        break;
      default:
        multiplier = _selectedDuration;
    }
    return '${amount * multiplier}';
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textDisabled,
                  fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ── Data classes ────────────────────────────────────────────────────────────

class _PledgeData {
  const _PledgeData({
    required this.campaignName,
    required this.totalPledged,
    required this.totalPaid,
    required this.monthlyAmount,
    required this.frequency,
    required this.startDate,
    required this.nextDue,
    required this.paymentsCompleted,
    required this.totalPayments,
  });

  final String campaignName;
  final double totalPledged;
  final double totalPaid;
  final double monthlyAmount;
  final String frequency;
  final String startDate;
  final String nextDue;
  final int paymentsCompleted;
  final int totalPayments;
}

class _PledgePayment {
  const _PledgePayment({
    required this.date,
    required this.amount,
    required this.status,
  });

  final String date;
  final int amount;
  final String status;
}
