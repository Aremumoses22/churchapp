import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/theme_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SETTINGS SCREEN
//
// Theme toggle (Light/Dark/System), notification preferences,
// general settings.
// ──────────────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late int _themeMode;
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _eventReminders = true;
  bool _prayerUpdates = true;

  @override
  void initState() {
    super.initState();
    // Sync with the persisted theme preference
    final current = ref.read(themeNotifierProvider);
    switch (current) {
      case ThemeMode.light:
        _themeMode = 0;
      case ThemeMode.dark:
        _themeMode = 1;
      case ThemeMode.system:
        _themeMode = 2;
    }
  }

  void _onThemeChanged(int i) {
    setState(() => _themeMode = i);
    final mode = switch (i) {
      0 => ThemeMode.light,
      1 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    ref.read(themeNotifierProvider.notifier).setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Settings',
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.sp4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Theme ─────────────────────────────────────────────
            _sectionLabel('APP THEME', isDark),
            const SizedBox(height: AppSpacing.sp3),
            _ThemeSelector(
              selected: _themeMode,
              onChanged: _onThemeChanged,
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── Notifications ─────────────────────────────────────────
            _sectionLabel('NOTIFICATIONS', isDark),
            const SizedBox(height: AppSpacing.sp3),
            _settingsGroup([
              _SettingToggle(
                icon: Icons.notifications_active,
                label: 'Push Notifications',
                value: _pushEnabled,
                onChanged: (v) => setState(() => _pushEnabled = v),
              ),
              _SettingToggle(
                icon: Icons.email_outlined,
                label: 'Email Notifications',
                value: _emailEnabled,
                onChanged: (v) => setState(() => _emailEnabled = v),
              ),
              _SettingToggle(
                icon: Icons.event,
                label: 'Event Reminders',
                value: _eventReminders,
                onChanged: (v) => setState(() => _eventReminders = v),
              ),
              _SettingToggle(
                icon: Icons.favorite_border,
                label: 'Prayer Updates',
                value: _prayerUpdates,
                onChanged: (v) => setState(() => _prayerUpdates = v),
              ),
            ], isDark),

            const SizedBox(height: AppSpacing.sp6),

            // ── About ─────────────────────────────────────────────────
            _sectionLabel('ABOUT', isDark),
            const SizedBox(height: AppSpacing.sp3),
            _settingsGroup([
              _SettingInfo(
                  icon: Icons.info_outline, label: 'Version', value: '1.0.0'),
              _SettingInfo(
                  icon: Icons.phone_android, label: 'Build', value: '2026.02'),
            ], isDark),

            const SizedBox(height: AppSpacing.sp8),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: AppTextStyles.labelAllCaps.copyWith(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
    );
  }

  Widget _settingsGroup(List<Widget> items, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(items.length, (i) {
          final isLast = i == items.length - 1;
          return Container(
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : const Color(0xFFF3F4F6),
                        width: 1,
                      ),
                    ),
            ),
            child: items[i],
          );
        }),
      ),
    );
  }
}

// ── Theme selector ──────────────────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  final int selected;
  final ValueChanged<int> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const labels = ['Light', 'Dark', 'System'];
    const icons = [Icons.light_mode, Icons.dark_mode, Icons.phone_android];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFF3F4F6),
        borderRadius: AppRadius.borderRadiusMd,
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark ? AppColors.bgDark : AppColors.surface)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isActive
                      ? (isDark ? AppShadows.xsDark : AppShadows.xs)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icons[i],
                      size: 16,
                      color: isActive
                          ? (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      labels[i],
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isActive
                            ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Toggle setting ──────────────────────────────────────────────────────────

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: isDark ? AppColors.primaryLight : AppColors.primary,
              thumbColor: WidgetStatePropertyAll(AppColors.textInverse),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info setting ────────────────────────────────────────────────────────────

class _SettingInfo extends StatelessWidget {
  const _SettingInfo({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
