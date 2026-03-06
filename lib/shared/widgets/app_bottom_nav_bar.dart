import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BOTTOM NAVIGATION BAR
// ──────────────────────────────────────────────────────────────────────────────

/// Custom bottom nav with 5 tabs — icon scale animation on activation,
/// gold dot indicator, upward `shadow-md`.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(icon: Icons.headphones_outlined, activeIcon: Icons.headphones, label: 'Sermons'),
    _NavItem(icon: Icons.event_outlined, activeIcon: Icons.event, label: 'Events'),
    _NavItem(icon: Icons.volunteer_activism_outlined, activeIcon: Icons.volunteer_activism, label: 'Giving'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: AppSpacing.bottomNavHeight + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        boxShadow: isDark ? AppShadows.mdUpDark : AppShadows.mdUp,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final isActive = i == currentIndex;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Semantics(
                label: item.label,
                selected: isActive,
                child: _NavTabItem(
                  icon: isActive ? item.activeIcon : item.icon,
                  label: item.label,
                  isActive: isActive,
                  isDark: isDark,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final color = isActive ? activeColor : inactiveColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon with scale animation
        AnimatedScale(
          scale: isActive ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 2),
        // Gold dot
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isActive ? 4 : 0,
          height: isActive ? 4 : 0,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
}
