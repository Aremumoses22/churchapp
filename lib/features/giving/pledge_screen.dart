import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/giving.dart';
import '../../core/providers/giving_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PLEDGE SCREEN
//
// Shows existing pledges (from /giving/pledges) and a form to create a new one.
// ──────────────────────────────────────────────────────────────────────────────

class PledgeScreen extends ConsumerStatefulWidget {
  const PledgeScreen({super.key, this.campaignId});

  final String? campaignId;

  @override
  ConsumerState<PledgeScreen> createState() => _PledgeScreenState();
}

class _PledgeScreenState extends ConsumerState<PledgeScreen> {
  final _amountCtrl = TextEditingController();
  String _selectedFrequency = 'Monthly';
  int _selectedDuration = 12;
  bool _showForm = false;
  bool _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(bool isDark) async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    if (widget.campaignId == null || widget.campaignId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No campaign selected. Open a campaign first.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final res = await ref.read(givingRepositoryProvider).createPledge(
          campaignId: widget.campaignId!,
          totalAmount: amount * _multiplier(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (res.success) {
      ref.invalidate(givingPledgesProvider);
      setState(() {
        _showForm = false;
        _amountCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pledge submitted successfully!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusMd),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message.isNotEmpty
              ? res.message
              : 'Failed to submit pledge.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  int _multiplier() {
    switch (_selectedFrequency) {
      case 'Weekly':
        return _selectedDuration * 4;
      case 'Bi-Weekly':
        return _selectedDuration * 2;
      default:
        return _selectedDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pledgesAsync = ref.watch(givingPledgesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'My Pledge', showBack: true),
      body: pledgesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: AppSpacing.sp3),
              Text('Failed to load pledges',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sp3),
              AppSecondaryButton(
                label: 'Retry',
                onPressed: () => ref.invalidate(givingPledgesProvider),
              ),
            ],
          ),
        ),
        data: (pledges) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sp4),

                // ── Existing pledges ──────────────────────────────────
                if (pledges.isNotEmpty && !_showForm) ...[
                  ...pledges.map((p) => _PledgeCard(
                        pledge: p,
                        isDark: isDark,
                      )),
                  const SizedBox(height: AppSpacing.sp4),
                  Center(
                    child: AppSecondaryButton(
                      label: 'Make a New Pledge',
                      onPressed: () => setState(() => _showForm = true),
                    ),
                  ),
                ],

                // ── New pledge form ───────────────────────────────────
                if (pledges.isEmpty || _showForm) ...[
                  if (_showForm && pledges.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sp4),
                      child: AppSecondaryButton(
                        label: '← Back to My Pledges',
                        onPressed: () =>
                            setState(() => _showForm = false),
                      ),
                    ),
                  _buildForm(isDark),
                ],

                const SizedBox(height: AppSpacing.sp10),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── New pledge form ────────────────────────────────────────────────────────

  Widget _buildForm(bool isDark) {
    final totalAmount = (double.tryParse(_amountCtrl.text) ?? 0) * _multiplier();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header banner
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
              Text(
                widget.campaignId != null
                    ? 'Commit to regular giving toward this campaign'
                    : 'Open a campaign and tap "Give" to start a pledge',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sp5),

        // Amount
        Text('Pledge Amount per Period',
            style: AppTextStyles.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.sp2),
        Row(
          children: [1000, 5000, 10000, 25000]
              .map((a) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _amountCtrl.text = '$a'),
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
                            child: Text(
                              '₦${_fmtNum(a)}',
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: _amountCtrl.text == '$a'
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary)),
                            ),
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
          label: 'Custom Amount (₦)',
          hint: 'Enter amount',
          prefixIcon: Icons.attach_money,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
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
                        onTap: () =>
                            setState(() => _selectedFrequency = f),
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
        Text('Duration (months)',
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

        // Summary
        if (_amountCtrl.text.isNotEmpty && totalAmount > 0) ...[
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
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.success)),
                const SizedBox(height: AppSpacing.sp2),
                Text(
                  '₦${_amountCtrl.text} $_selectedFrequency '
                  'for $_selectedDuration months',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
                ),
                Text(
                  'Total: ₦${_fmtNum(totalAmount.toInt())}',
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
          label: _submitting ? 'Submitting…' : 'Submit Pledge',
          icon: _submitting
              ? null
              : const Icon(Icons.handshake_outlined,
                  color: Colors.white, size: 18),
          onPressed: _submitting ? null : () => _submit(isDark),
        ),
      ],
    );
  }

  String _fmtNum(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ── Pledge tracker card ───────────────────────────────────────────────────────

class _PledgeCard extends StatelessWidget {
  const _PledgeCard({required this.pledge, required this.isDark});

  final Pledge pledge;
  final bool isDark;

  String _formatDate(String? iso) {
    if (iso == null) return 'N/A';
    try {
      final dt = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = pledge.progressPercent;
    final remaining = pledge.totalAmount - pledge.paidAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sp4),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusFull,
            ),
            child: Text(
              pledge.campaignTitle ?? 'Campaign Pledge',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.primary, fontSize: 11),
            ),
          ),

          const SizedBox(height: AppSpacing.sp4),

          // Amounts
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₦${pledge.paidAmount.toInt()}',
                style: AppTextStyles.displayMedium
                    .copyWith(color: AppColors.success),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'of ₦${pledge.totalAmount.toInt()}',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                ),
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
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.inputFill),
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
            '${(progress * 100).toInt()}% completed',
            style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 11),
          ),

          const SizedBox(height: AppSpacing.sp4),
          const AppDivider(),
          const SizedBox(height: AppSpacing.sp4),

          // Details row
          Row(
            children: [
              _DetailItem(
                label: 'Status',
                value: pledge.status?.toUpperCase() ?? 'ACTIVE',
                isDark: isDark,
              ),
              if (pledge.endDate != null)
                _DetailItem(
                  label: 'End Date',
                  value: _formatDate(pledge.endDate),
                  isDark: isDark,
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.sp4),

          // Remaining info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sp3),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusMd,
              border:
                  Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.gold),
                const SizedBox(width: AppSpacing.sp2),
                Expanded(
                  child: Text(
                    '₦${remaining.toInt()} remaining',
                    style: AppTextStyles.bodySmall.copyWith(
                        color:
                            isDark ? AppColors.goldLight : AppColors.gold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
