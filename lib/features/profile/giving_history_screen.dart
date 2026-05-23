import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/giving.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/providers/giving_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING HISTORY SCREEN
//
// List of past donations fetched from /giving/history.
// Tapping a row opens the receipt detail.
// ──────────────────────────────────────────────────────────────────────────────

class GivingHistoryScreen extends ConsumerWidget {
  const GivingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(givingHistoryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Giving History', showBack: true),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined,
                  size: 48,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textDisabled),
              const SizedBox(height: AppSpacing.sp3),
              Text('Failed to load history',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sp3),
              AppSecondaryButton(
                label: 'Retry',
                onPressed: () => ref.invalidate(givingHistoryProvider),
              ),
            ],
          ),
        ),
        data: (donations) => donations.isEmpty
            ? const AppEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No giving history yet',
                subtitle: 'Your generosity journey starts here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.sp4),
                itemCount: donations.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sp3),
                itemBuilder: (_, i) => _GivingTile(
                  donation: donations[i],
                  isDark: isDark,
                  onTap: () => context.push(
                    '${AppRoutes.receiptDetail}?id=${donations[i].id}',
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Tile ─────────────────────────────────────────────────────────────────────

class _GivingTile extends StatelessWidget {
  const _GivingTile({
    required this.donation,
    required this.isDark,
    required this.onTap,
  });

  final Donation donation;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: AppCard(
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
                  color:
                      isDark ? AppColors.primaryLight : AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.categoryName ?? 'Donation',
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(donation.createdAt),
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
              _formatNaira(donation.amount),
              style: AppTextStyles.bodyLargeSemiBold.copyWith(
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
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
}
