import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// MANAGE NOTIFICATIONS SCREEN
//
// Granular toggles per category: Sermons, Events, Giving Receipts, Prayer
// Updates, Announcements, Live Alerts — each with push + email toggles.
// ──────────────────────────────────────────────────────────────────────────────

class ManageNotificationsScreen extends StatefulWidget {
  const ManageNotificationsScreen({super.key});

  @override
  State<ManageNotificationsScreen> createState() =>
      _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  bool _globalPush = true;
  bool _globalEmail = true;

  // Per-category state: [push, email]
  final Map<String, List<bool>> _prefs = {
    'Sermons': [true, true],
    'Events': [true, true],
    'Giving Receipts': [true, true],
    'Prayer Updates': [true, false],
    'Announcements': [true, true],
    'Live Alerts': [true, false],
  };

  static const _icons = {
    'Sermons': Icons.headphones_outlined,
    'Events': Icons.event_outlined,
    'Giving Receipts': Icons.receipt_long_outlined,
    'Prayer Updates': Icons.volunteer_activism_outlined,
    'Announcements': Icons.campaign_outlined,
    'Live Alerts': Icons.cell_tower_outlined,
  };

  static const _descriptions = {
    'Sermons': 'New sermons, series updates, and recommendations',
    'Events': 'Event reminders, registration confirmations, changes',
    'Giving Receipts': 'Donation confirmations and tax receipts',
    'Prayer Updates': 'Prayer request responses and community prayers',
    'Announcements': 'Church-wide announcements and news',
    'Live Alerts': 'Notifications when a live service starts',
  };

  void _toggleGlobal(bool isPush, bool value) {
    setState(() {
      if (isPush) {
        _globalPush = value;
        for (final key in _prefs.keys) {
          _prefs[key]![0] = value;
        }
      } else {
        _globalEmail = value;
        for (final key in _prefs.keys) {
          _prefs[key]![1] = value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Notifications', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sp4),

            // ── Global toggles ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              decoration: BoxDecoration(
                gradient: AppGradients.hero,
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined,
                          color: Colors.white, size: 22),
                      const SizedBox(width: AppSpacing.sp3),
                      Expanded(
                        child: Text('Master Controls',
                            style: AppTextStyles.bodyLargeSemiBold
                                .copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                  Row(
                    children: [
                      _GlobalToggle(
                        label: 'Push',
                        icon: Icons.phone_android,
                        enabled: _globalPush,
                        onChanged: (v) => _toggleGlobal(true, v),
                      ),
                      const SizedBox(width: AppSpacing.sp3),
                      _GlobalToggle(
                        label: 'Email',
                        icon: Icons.email_outlined,
                        enabled: _globalEmail,
                        onChanged: (v) => _toggleGlobal(false, v),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp6),

            Text('BY CATEGORY',
                style: AppTextStyles.labelAllCaps.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled)),

            const SizedBox(height: AppSpacing.sp3),

            // ── Category cards ─────────────────────────────────────────
            ..._prefs.entries.map((entry) {
              final cat = entry.key;
              final push = entry.value[0];
              final email = entry.value[1];

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
                child: Container(
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
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.borderRadiusMd,
                            ),
                            child: Icon(_icons[cat],
                                size: 20,
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary),
                          ),
                          const SizedBox(width: AppSpacing.sp3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat,
                                    style:
                                        AppTextStyles.bodyLargeSemiBold.copyWith(
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(_descriptions[cat] ?? '',
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                        fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      Row(
                        children: [
                          Expanded(
                            child: _ChannelToggle(
                              icon: Icons.phone_android,
                              label: 'Push',
                              enabled: push,
                              isDark: isDark,
                              onChanged: (v) {
                                setState(() => _prefs[cat]![0] = v);
                                if (!v && _globalPush) {
                                  setState(() => _globalPush = false);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp3),
                          Expanded(
                            child: _ChannelToggle(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              enabled: email,
                              isDark: isDark,
                              onChanged: (v) {
                                setState(() => _prefs[cat]![1] = v);
                                if (!v && _globalEmail) {
                                  setState(() => _globalEmail = false);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.sp4),

            // ── Quiet hours hint ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sp3),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Row(
                children: [
                  const Icon(Icons.bedtime_outlined,
                      size: 18, color: AppColors.info),
                  const SizedBox(width: AppSpacing.sp2),
                  Expanded(
                    child: Text(
                      'Quiet Hours: Push notifications are muted from 10 PM to 7 AM.',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info, height: 1.4, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp10),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _GlobalToggle extends StatelessWidget {
  const _GlobalToggle({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(!enabled),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sp3, vertical: AppSpacing.sp2),
          decoration: BoxDecoration(
            color: enabled
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderRadiusMd,
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: enabled
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5)),
              const SizedBox(width: AppSpacing.sp2),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: enabled
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5))),
              ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: enabled
                      ? AppColors.gold
                      : Colors.white.withValues(alpha: 0.15),
                ),
                child: enabled
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelToggle extends StatelessWidget {
  const _ChannelToggle({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.isDark,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!enabled),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp3, vertical: AppSpacing.sp2),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.08)
              : (isDark ? AppColors.bgDark : AppColors.inputFill),
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.3)
                : (isDark ? AppColors.borderDark : AppColors.inputBorder),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: enabled
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled)),
            const SizedBox(width: AppSpacing.sp2),
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(
                    color: enabled
                        ? (isDark ? AppColors.primaryLight : AppColors.primary)
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled),
                    fontSize: 11)),
            const Spacer(),
            Switch.adaptive(
              value: enabled,
              onChanged: (v) => onChanged(v),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
