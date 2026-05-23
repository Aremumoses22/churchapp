import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/giving.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/providers/giving_providers.dart';
import '../../core/repositories/giving_repository.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING SCREEN — Section 11  (Enhanced)
//
// Layout:
//   1. Giving impact card — year-to-date impact metrics
//   2. Category selector
//   3. Animated amount chips with count-up display
//   4. Custom amount input
//   5. Frequency toggle
//   6. Saved payment methods (last-4 + brand icon)
//   7. Other payment options
//   8. Giving reminders toggle
//   9. Quick links + sticky footer
// ──────────────────────────────────────────────────────────────────────────────

class GivingScreen extends ConsumerStatefulWidget {
  const GivingScreen({super.key});

  @override
  ConsumerState<GivingScreen> createState() => _GivingScreenState();
}

class _GivingScreenState extends ConsumerState<GivingScreen>
    with SingleTickerProviderStateMixin {
  final _customCtrl = TextEditingController();

  // Animated amount display (kept local — animation is UI-only)
  late AnimationController _amountAnimController;
  late Animation<double> _amountAnim;
  int _displayAmount = 0;
  int _targetAmount = 0;

  @override
  void initState() {
    super.initState();
    _amountAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _amountAnim = CurvedAnimation(
      parent: _amountAnimController,
      curve: Curves.easeOutCubic,
    );
    _amountAnimController.addListener(() {
      setState(() {
        _displayAmount =
            (_targetAmount * _amountAnim.value).round();
      });
    });
  }

  void _selectAmount(int amount) {
    ref.read(givingNotifierProvider.notifier).selectAmount(amount);
    _targetAmount = amount;
    _amountAnimController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    _amountAnimController.dispose();
    super.dispose();
  }

  String _resolvePaymentMethodType(int index, List<PaymentMethod> saved) {
    if (index < saved.length) return saved[index].type;
    if (index == saved.length) return 'CARD';
    if (index == saved.length + 1) return 'BANK_TRANSFER';
    return 'WALLET';
  }

  void _submit(
    GivingState gState,
    List<PaymentMethod> savedMethods,
  ) {
    final categories = ref.read(givingCategoriesProvider).maybeWhen(
          data: (cats) => cats,
          orElse: () => <GivingCategory>[],
        );
    if (categories.isEmpty) return;

    final cat = gState.selectedCategoryIndex < categories.length
        ? categories[gState.selectedCategoryIndex]
        : categories.first;
    final methodType =
        _resolvePaymentMethodType(gState.paymentMethod, savedMethods);

    ref.read(givingNotifierProvider.notifier).reset();

    context.push(
      '${AppRoutes.givingCheckout}'
      '?amount=${gState.currentAmount}'
      '&categoryId=${Uri.encodeComponent(cat.id)}'
      '&categoryName=${Uri.encodeComponent(cat.name)}'
      '&method=${Uri.encodeComponent(methodType)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gState = ref.watch(givingNotifierProvider);
    final categoryLabels = ref.watch(givingCategoriesProvider).maybeWhen(
      data: (cats) => cats.map((c) => c.name).toList(),
      orElse: () => <String>['General Offering'],
    );
    final savedMethods = ref.watch(givingPaymentMethodsProvider).maybeWhen(
      data: (methods) => methods,
      orElse: () => <PaymentMethod>[],
    );
    final amountPresets = GivingRepository.amountPresets;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Give',
        actions: [
          IconButton(
            onPressed: () => context.push('/profile/giving-history'),
            icon: Icon(Icons.history,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp4,
              AppSpacing.sp4,
              AppSpacing.sp4,
              100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Giving Impact Card ────────────────────────────────
                _GivingImpactCard(isDark: isDark),
                const SizedBox(height: AppSpacing.sp5),

                // ── Category selector ─────────────────────────────────
                _sectionLabel('Select Category', isDark),
                const SizedBox(height: AppSpacing.sp3),
                AppFilterChips(
                  labels: categoryLabels,
                  selectedIndex: gState.selectedCategoryIndex,
                  onSelected: (i) => ref
                      .read(givingNotifierProvider.notifier)
                      .selectCategory(i),
                ),

                const SizedBox(height: AppSpacing.sp6),

                // ── Animated Amount Display ───────────────────────────
                if (gState.selectedAmount != null && !gState.isCustom) ...[
                  Center(
                    child: AnimatedBuilder(
                      animation: _amountAnim,
                      builder: (_, _) => Text(
                        _formatNaira(_displayAmount),
                        style: AppTextStyles.headingLarge.copyWith(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                ],

                // ── Amount selector ───────────────────────────────────
                _sectionLabel('Select Amount', isDark),
                const SizedBox(height: AppSpacing.sp3),
                Wrap(
                  spacing: AppSpacing.sp3,
                  runSpacing: AppSpacing.sp3,
                  children: [
                    ...amountPresets.map((a) => AppGivingAmountChip(
                          label: _formatNaira(a),
                          isSelected:
                              !gState.isCustom && gState.selectedAmount == a,
                          onTap: () => _selectAmount(a),
                        )),
                    AppGivingAmountChip(
                      label: 'Custom...',
                      isSelected: gState.isCustom,
                      onTap: () {
                        ref.read(givingNotifierProvider.notifier).enableCustom();
                        setState(() {
                          _displayAmount = 0;
                          _targetAmount = 0;
                        });
                      },
                    ),
                  ],
                ),

                // ── Custom amount input ───────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: gState.isCustom
                      ? Padding(
                          padding: const EdgeInsets.only(
                              top: AppSpacing.sp4),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\u20A6',
                                style: AppTextStyles.headingLarge
                                    .copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _customCtrl,
                                  keyboardType:
                                      TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                    _ThousandsSeparatorFormatter(),
                                  ],
                                  style: AppTextStyles.headingLarge
                                      .copyWith(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: AppTextStyles
                                        .headingLarge
                                        .copyWith(
                                      color:
                                          AppColors.textDisabled,
                                    ),
                                    border:
                                        const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 2),
                                    ),
                                    focusedBorder:
                                        const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 2),
                                    ),
                                    contentPadding:
                                        EdgeInsets.zero,
                                  ),
                                  onChanged: (val) {
                                    final cleaned = val.replaceAll(',', '');
                                    ref.read(givingNotifierProvider.notifier).setCustomAmount(cleaned);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: AppSpacing.sp6),

                // ── Frequency toggle ──────────────────────────────────
                _sectionLabel('Frequency', isDark),
                const SizedBox(height: AppSpacing.sp3),
                _SegmentedControl(
                  labels: const [
                    'One-time',
                    'Weekly',
                    'Monthly',
                  ],
                  selected: gState.frequency,
                  onChanged: (i) => ref
                      .read(givingNotifierProvider.notifier)
                      .setFrequency(i),
                  isDark: isDark,
                ),

                const SizedBox(height: AppSpacing.sp6),

                // ── Saved Payment Methods ─────────────────────────────
                if (savedMethods.isNotEmpty) ...[
                  _sectionLabel('Saved Cards', isDark),
                  const SizedBox(height: AppSpacing.sp3),
                  ...List.generate(savedMethods.length, (i) {
                    final card = _methodToCard(savedMethods[i]);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
                      child: _SavedCardOption(
                        card: card,
                        isSelected: gState.paymentMethod == i,
                        isDark: isDark,
                        onTap: () => ref
                            .read(givingNotifierProvider.notifier)
                            .setPaymentMethod(i),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.sp4),
                ],

                // ── Other Payment Methods ─────────────────────────────
                _sectionLabel('Other Methods', isDark),
                const SizedBox(height: AppSpacing.sp3),
                _PaymentOption(
                  icon: Icons.credit_card,
                  iconColor: isDark
                      ? AppColors.primaryLight
                      : AppColors.primary,
                  label: 'New Card',
                  sub: 'Add a new debit or credit card',
                  isSelected:
                      gState.paymentMethod == savedMethods.length,
                  isDark: isDark,
                  onTap: () => ref
                      .read(givingNotifierProvider.notifier)
                      .setPaymentMethod(savedMethods.length),
                ),
                const SizedBox(height: AppSpacing.sp2),
                _PaymentOption(
                  icon: Icons.account_balance,
                  iconColor: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  label: 'Bank Transfer',
                  sub: 'Direct bank payment',
                  isSelected:
                      gState.paymentMethod == savedMethods.length + 1,
                  isDark: isDark,
                  onTap: () => ref
                      .read(givingNotifierProvider.notifier)
                      .setPaymentMethod(savedMethods.length + 1),
                ),
                const SizedBox(height: AppSpacing.sp2),
                _PaymentOption(
                  icon: Icons.account_balance_wallet,
                  iconColor: AppColors.gold,
                  label: 'Wallet',
                  sub: 'Balance: ₦12,500',
                  isSelected:
                      gState.paymentMethod == savedMethods.length + 2,
                  isDark: isDark,
                  onTap: () => ref
                      .read(givingNotifierProvider.notifier)
                      .setPaymentMethod(savedMethods.length + 2),
                ),

                const SizedBox(height: AppSpacing.sp6),

                // ── Giving Reminders ──────────────────────────────────
                _GivingReminderSection(
                  enabled: gState.reminderEnabled,
                  frequency: gState.reminderFrequency,
                  isDark: isDark,
                  onToggle: (_) => ref
                      .read(givingNotifierProvider.notifier)
                      .toggleReminder(),
                  onFrequencyChanged: (i) => ref
                      .read(givingNotifierProvider.notifier)
                      .setReminderFrequency(i),
                ),

                const SizedBox(height: AppSpacing.sp6),

                // ── Quick links ───────────────────────────────────────
                _sectionLabel('More', isDark),
                const SizedBox(height: AppSpacing.sp3),
                Row(
                  children: [
                    _QuickLink(
                      icon: Icons.campaign_outlined,
                      label: 'Campaigns',
                      isDark: isDark,
                      onTap: () =>
                          context.push(AppRoutes.givingCampaign),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    _QuickLink(
                      icon: Icons.handshake_outlined,
                      label: 'My Pledge',
                      isDark: isDark,
                      onTap: () =>
                          context.push(AppRoutes.pledge),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    _QuickLink(
                      icon: Icons.receipt_long_outlined,
                      label: 'Receipts',
                      isDark: isDark,
                      onTap: () =>
                          context.push(AppRoutes.receiptDetail),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Sticky footer ───────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark
                    : AppColors.surface,
                boxShadow:
                    isDark ? AppShadows.lgDark : AppShadows.lg,
              ),
              child: Center(
                child: AppPrimaryButton(
                  label: gState.currentAmount > 0
                      ? 'Give ${_formatNaira(gState.currentAmount)}'
                      : 'Select an Amount',
                  onPressed: gState.currentAmount > 0
                      ? () => _submit(gState, savedMethods)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondary,
      ),
    );
  }

  String _formatNaira(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '\u20A6${buffer.toString()}';
  }
}

SavedCard _methodToCard(PaymentMethod pm) {
  const brandColors = {
    'Visa': Color(0xFF1A1F71),
    'Mastercard': Color(0xFFEB001B),
    'Verve': Color(0xFF00754A),
  };
  final brand = pm.provider.isNotEmpty ? pm.provider : pm.type;
  return SavedCard(
    brand: brand,
    last4: pm.last4,
    color: brandColors[brand] ?? const Color(0xFF64748B),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// GIVING IMPACT CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _GivingImpactCard extends ConsumerWidget {
  const _GivingImpactCard({required this.isDark});
  final bool isDark;

  String _fmt(double amount) {
    final v = amount.toInt();
    final str = v.toString();
    final buf = StringBuffer('₦');
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(givingSummaryProvider);
    final summary = summaryAsync.maybeWhen(
      data: (s) => s,
      orElse: () => null,
    );
    final isLoading = summaryAsync is AsyncLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primaryLight.withValues(alpha: 0.15),
                  AppColors.gold.withValues(alpha: 0.08),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.goldLight.withValues(alpha: 0.3),
                ],
        ),
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(
          color: isDark
              ? AppColors.primaryLight.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite,
                  size: 18,
                  color: isDark ? AppColors.goldLight : AppColors.gold),
              const SizedBox(width: AppSpacing.sp2),
              Text(
                'Your giving overview',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp4),
          Row(
            children: [
              _ImpactMetric(
                value: isLoading ? '—' : _fmt(summary?.thisYear ?? 0),
                label: 'Year to date',
                icon: Icons.calendar_today_outlined,
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.sp3),
              _ImpactMetric(
                value: isLoading ? '—' : '${summary?.donationCount ?? 0}',
                label: 'Donations',
                icon: Icons.volunteer_activism_outlined,
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.sp3),
              _ImpactMetric(
                value: isLoading ? '—' : _fmt(summary?.thisMonth ?? 0),
                label: 'This month',
                icon: Icons.today_outlined,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactMetric extends StatelessWidget {
  const _ImpactMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sp3, horizontal: AppSpacing.sp2),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDark.withValues(alpha: 0.5)
              : AppColors.surface.withValues(alpha: 0.8),
          borderRadius: AppRadius.borderRadiusMd,
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 20,
                color: isDark
                    ? AppColors.goldLight
                    : AppColors.gold),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SAVED CARD OPTION — shows brand icon + last 4 digits
// ═══════════════════════════════════════════════════════════════════════════════

class _SavedCardOption extends StatelessWidget {
  const _SavedCardOption({
    required this.card,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final SavedCard card;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 72,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primaryLight
                      .withValues(alpha: 0.1)
                  : AppColors.skyLight)
              : (isDark
                  ? AppColors.cardDark
                  : AppColors.surface),
          border: Border.all(
            color: isSelected
                ? (isDark
                    ? AppColors.primaryLight
                    : AppColors.primary)
                : (isDark
                    ? AppColors.borderDark
                    : const Color(0xFFE5E7EB)),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Row(
          children: [
            // Card brand icon
            Container(
              width: 40,
              height: 28,
              decoration: BoxDecoration(
                color: card.color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  card.brand == 'Visa' ? 'V' : 'MC',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: card.brand == 'Visa' ? 16 : 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.brand,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '\u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022  ${card.last4}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      letterSpacing: 1.5,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Radio dot
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (isDark
                          ? AppColors.primaryLight
                          : AppColors.primary)
                      : AppColors.textDisabled,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GIVING REMINDER SECTION
// ═══════════════════════════════════════════════════════════════════════════════

class _GivingReminderSection extends StatelessWidget {
  const _GivingReminderSection({
    required this.enabled,
    required this.frequency,
    required this.isDark,
    required this.onToggle,
    required this.onFrequencyChanged,
  });

  final bool enabled;
  final int frequency;
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onFrequencyChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(Icons.notifications_active_outlined,
                  size: 20,
                  color: isDark
                      ? AppColors.primaryLight
                      : AppColors.primary),
              const SizedBox(width: AppSpacing.sp2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giving Reminders',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Get a gentle nudge to give',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: onToggle,
                activeTrackColor: isDark
                    ? AppColors.primaryLight
                    : AppColors.primary,
              ),
            ],
          ),
          // Frequency selector (visible when enabled)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: enabled
                ? Padding(
                    padding:
                        const EdgeInsets.only(top: AppSpacing.sp3),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const AppDivider(),
                        const SizedBox(height: AppSpacing.sp3),
                        Text(
                          'Remind me',
                          style:
                              AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp2),
                        Row(
                          children: [
                            _ReminderChip(
                              label: 'Weekly',
                              isSelected: frequency == 0,
                              isDark: isDark,
                              onTap: () =>
                                  onFrequencyChanged(0),
                            ),
                            const SizedBox(width: 8),
                            _ReminderChip(
                              label: 'Bi-weekly',
                              isSelected: frequency == 1,
                              isDark: isDark,
                              onTap: () =>
                                  onFrequencyChanged(1),
                            ),
                            const SizedBox(width: 8),
                            _ReminderChip(
                              label: 'Monthly',
                              isSelected: frequency == 2,
                              isDark: isDark,
                              onTap: () =>
                                  onFrequencyChanged(2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ReminderChip extends StatelessWidget {
  const _ReminderChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primaryLight
                  : AppColors.primary)
              : Colors.transparent,
          borderRadius: AppRadius.borderRadiusFull,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark
                    ? AppColors.borderDark
                    : AppColors.inputBorder),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEGMENTED CONTROL
// ═══════════════════════════════════════════════════════════════════════════════

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.labels,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark
            : const Color(0xFFF3F4F6),
        borderRadius: AppRadius.borderRadiusMd,
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark
                          ? AppColors.bgDark
                          : AppColors.surface)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(9),
                  boxShadow: isActive
                      ? (isDark
                          ? AppShadows.xsDark
                          : AppShadows.xs)
                      : null,
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style:
                        AppTextStyles.labelMedium.copyWith(
                      color: isActive
                          ? (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)
                          : (isDark
                              ? AppColors
                                  .textSecondaryDark
                              : AppColors
                                  .textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAYMENT OPTION
// ═══════════════════════════════════════════════════════════════════════════════

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sub,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String sub;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 72,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primaryLight
                      .withValues(alpha: 0.1)
                  : AppColors.skyLight)
              : (isDark
                  ? AppColors.cardDark
                  : AppColors.surface),
          border: Border.all(
            color: isSelected
                ? (isDark
                    ? AppColors.primaryLight
                    : AppColors.primary)
                : (isDark
                    ? AppColors.borderDark
                    : const Color(0xFFE5E7EB)),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style:
                        AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    sub,
                    style:
                        AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (isDark
                          ? AppColors.primaryLight
                          : AppColors.primary)
                      : AppColors.textDisabled,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// THOUSANDS SEPARATOR FORMATTER
// ═══════════════════════════════════════════════════════════════════════════════

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final number =
        int.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) return oldValue;

    final str = number.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection:
          TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// QUICK LINK
// ═══════════════════════════════════════════════════════════════════════════════

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sp3),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDark
                : AppColors.surface,
            borderRadius: AppRadius.borderRadiusMd,
            boxShadow:
                isDark ? AppShadows.xsDark : AppShadows.xs,
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
