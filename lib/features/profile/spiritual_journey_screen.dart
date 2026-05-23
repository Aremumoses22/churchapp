import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SPIRITUAL JOURNEY SCREEN
//
// Personal milestones loaded from GET /users/me/milestones.
// ──────────────────────────────────────────────────────────────────────────────

class SpiritualJourneyScreen extends ConsumerWidget {
  const SpiritualJourneyScreen({super.key});

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static IconData _iconForType(String? icon) {
    switch (icon) {
      case 'baptism': return Icons.water_drop_outlined;
      case 'sermon': return Icons.headphones_outlined;
      case 'group': return Icons.groups_outlined;
      case 'giving': return Icons.favorite_outline;
      case 'volunteer': return Icons.volunteer_activism_outlined;
      case 'reading': return Icons.menu_book_outlined;
      case 'celebration': return Icons.celebration_outlined;
      default: return Icons.church_outlined;
    }
  }

  static Color _colorForType(String? icon) {
    switch (icon) {
      case 'baptism': return const Color(0xFF7C3AED);
      case 'sermon': return const Color(0xFF2563EB);
      case 'group': return const Color(0xFF059669);
      case 'giving': return const Color(0xFFF59E0B);
      case 'volunteer': return const Color(0xFF10B981);
      case 'reading': return const Color(0xFF7C3AED);
      case 'celebration': return const Color(0xFFEC4899);
      default: return const Color(0xFF1E3A8A);
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${_monthNames[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userState = ref.watch(userNotifierProvider);
    final milestones = userState.milestones;

    if (milestones.isEmpty && userState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ref.read(userNotifierProvider.notifier).fetchMilestones());
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
        appBar: AppFilledAppBar(title: 'My Journey', showBack: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Trigger load if empty and not already loading
    if (milestones.isEmpty && !userState.isLoading) {
      Future.microtask(
          () => ref.read(userNotifierProvider.notifier).fetchMilestones());
    }

    if (milestones.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
        appBar: AppFilledAppBar(title: 'My Journey', showBack: true),
        body: const AppEmptyState(
          icon: Icons.timeline_outlined,
          title: 'No milestones yet',
          subtitle: 'Your spiritual journey is just beginning!',
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'My Journey', showBack: true),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
            padding: const EdgeInsets.all(AppSpacing.sp4),
            decoration: BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Row(
              children: [
                _StatPill(
                    value: '${milestones.length}',
                    label: 'Milestones'),
                _StatDivider(),
                _StatPill(value: 'Growing', label: 'Journey'),
                _StatDivider(),
                _StatPill(value: 'Faithful', label: 'Path'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontalPadding,
                  0,
                  AppSpacing.screenHorizontalPadding,
                  AppSpacing.sp12),
              itemCount: milestones.length,
              itemBuilder: (context, i) {
                final m = milestones[i];
                final isLast = i == milestones.length - 1;
                final color = _colorForType(m.icon);
                final iconData = _iconForType(m.icon);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 44,
                        child: Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.inputBorder,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sp4),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sp4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark
                                  : AppColors.surface,
                              borderRadius: AppRadius.borderRadiusMd,
                              boxShadow: isDark
                                  ? AppShadows.xsDark
                                  : AppShadows.xs,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius:
                                            AppRadius.borderRadiusSm,
                                      ),
                                      child: Icon(iconData,
                                          size: 18, color: color),
                                    ),
                                    const SizedBox(width: AppSpacing.sp3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.title,
                                            style: AppTextStyles.labelMedium
                                                .copyWith(
                                                    color: isDark
                                                        ? AppColors.textPrimaryDark
                                                        : AppColors.textPrimary),
                                          ),
                                          if (m.achievedAt != null)
                                            Text(
                                              _formatDate(m.achievedAt),
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                      color: color,
                                                      fontSize: 10),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (m.description != null &&
                                    m.description!.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.sp2),
                                  Text(
                                    m.description!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                        height: 1.4),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.headingMedium
                  .copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1,
        height: 36,
        color: Colors.white.withValues(alpha: 0.3));
  }
}
