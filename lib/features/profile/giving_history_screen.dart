import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING HISTORY SCREEN
//
// List of past donations with category, amount, date, reference.
// ──────────────────────────────────────────────────────────────────────────────

class GivingHistoryScreen extends StatelessWidget {
  const GivingHistoryScreen({super.key});

  static final _history = [
    _GivingRecord('Tithe', 10000, 'Feb 23, 2026', 'CH-20260223-4821'),
    _GivingRecord('Offering', 5000, 'Feb 16, 2026', 'CH-20260216-3102'),
    _GivingRecord('Building Fund', 20000, 'Feb 9, 2026', 'CH-20260209-7834'),
    _GivingRecord('Tithe', 10000, 'Feb 2, 2026', 'CH-20260202-1955'),
    _GivingRecord('Missions', 3000, 'Jan 26, 2026', 'CH-20260126-4517'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Giving History',
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        ),
      ),
      body: _history.isEmpty
          ? const AppEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No giving history yet',
              subtitle: 'Your generosity journey starts here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              itemCount: _history.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sp3),
              itemBuilder: (_, i) =>
                  _GivingTile(record: _history[i], isDark: isDark),
            ),
    );
  }
}

class _GivingTile extends StatelessWidget {
  const _GivingTile({required this.record, required this.isDark});
  final _GivingRecord record;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.15)
                  : AppColors.skyLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.volunteer_activism,
                size: 20,
                color: isDark ? AppColors.primaryLight : AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.category,
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(
                  '${record.date} \u00b7 ${record.ref}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatNaira(record.amount),
            style: AppTextStyles.bodyLargeSemiBold.copyWith(
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNaira(int amount) {
    final str = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return '\u20A6${buf.toString()}';
  }
}

class _GivingRecord {
  const _GivingRecord(this.category, this.amount, this.date, this.ref);
  final String category;
  final int amount;
  final String date;
  final String ref;
}
