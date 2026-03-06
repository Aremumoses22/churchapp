import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SAVED ITEMS SCREEN
//
// Unified view of all bookmarks: sermons, events, verses, devotionals —
// with filter tabs.
// ──────────────────────────────────────────────────────────────────────────────

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = ['All', 'Sermons', 'Events', 'Verses', 'Devotionals'];

  static final _allItems = <_SavedItem>[
    _SavedItem(
      type: 'Sermons',
      title: 'Walking by Faith, Not by Sight',
      subtitle: 'Pastor James • Faith Foundations',
      date: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.headphones_outlined,
      color: const Color(0xFF2563EB),
    ),
    _SavedItem(
      type: 'Verses',
      title: 'Jeremiah 29:11',
      subtitle:
          '"For I know the plans I have for you," declares the LORD...',
      date: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.menu_book_outlined,
      color: const Color(0xFF7C3AED),
    ),
    _SavedItem(
      type: 'Events',
      title: 'Youth Worship Night',
      subtitle: 'March 15 • 6:00 PM • Main Auditorium',
      date: DateTime.now().subtract(const Duration(days: 4)),
      icon: Icons.event_outlined,
      color: const Color(0xFFF59E0B),
    ),
    _SavedItem(
      type: 'Devotionals',
      title: 'Morning Grace — Day 14',
      subtitle: 'Finding Peace in the Storm',
      date: DateTime.now().subtract(const Duration(days: 5)),
      icon: Icons.wb_sunny_outlined,
      color: const Color(0xFFEC4899),
    ),
    _SavedItem(
      type: 'Sermons',
      title: 'The Power of Prayer',
      subtitle: 'Pastor James • Faith Foundations',
      date: DateTime.now().subtract(const Duration(days: 8)),
      icon: Icons.headphones_outlined,
      color: const Color(0xFF2563EB),
    ),
    _SavedItem(
      type: 'Verses',
      title: 'Psalm 23:1-4',
      subtitle:
          'The LORD is my shepherd; I shall not want...',
      date: DateTime.now().subtract(const Duration(days: 10)),
      icon: Icons.menu_book_outlined,
      color: const Color(0xFF7C3AED),
    ),
    _SavedItem(
      type: 'Events',
      title: 'Easter Service',
      subtitle: 'April 20 • 9:00 AM • All Campuses',
      date: DateTime.now().subtract(const Duration(days: 12)),
      icon: Icons.event_outlined,
      color: const Color(0xFFF59E0B),
    ),
    _SavedItem(
      type: 'Sermons',
      title: 'Grace Upon Grace',
      subtitle: 'Pastor Sarah • Unmerited Favor',
      date: DateTime.now().subtract(const Duration(days: 15)),
      icon: Icons.headphones_outlined,
      color: const Color(0xFF2563EB),
    ),
    _SavedItem(
      type: 'Devotionals',
      title: 'Evening Reflections — Day 7',
      subtitle: 'Trusting God in the Waiting',
      date: DateTime.now().subtract(const Duration(days: 18)),
      icon: Icons.wb_sunny_outlined,
      color: const Color(0xFFEC4899),
    ),
    _SavedItem(
      type: 'Verses',
      title: 'Romans 8:28',
      subtitle:
          'And we know that in all things God works for the good...',
      date: DateTime.now().subtract(const Duration(days: 20)),
      icon: Icons.menu_book_outlined,
      color: const Color(0xFF7C3AED),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<_SavedItem> get _filtered {
    if (_tabCtrl.index == 0) return _allItems;
    return _allItems.where((i) => i.type == _tabs[_tabCtrl.index]).toList();
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${_monthNames[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Saved Items', showBack: true),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sp3),

          // ── Tab bar ──────────────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding),
              itemCount: _tabs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sp2),
              itemBuilder: (context, i) {
                final sel = _tabCtrl.index == i;
                final count = i == 0
                    ? _allItems.length
                    : _allItems.where((it) => it.type == _tabs[i]).length;

                return GestureDetector(
                  onTap: () => _tabCtrl.animateTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp4),
                    decoration: BoxDecoration(
                      color: sel
                          ? (isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                          : (isDark
                              ? AppColors.cardDark
                              : AppColors.inputFill),
                      borderRadius: AppRadius.borderRadiusFull,
                      border: sel
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.inputBorder),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_tabs[i],
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: sel
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary))),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: sel
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.inputBorder),
                              borderRadius: AppRadius.borderRadiusFull,
                            ),
                            child: Text('$count',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: sel
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textDisabled),
                                    fontSize: 10)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sp4),

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: AppEmptyState(
                      icon: Icons.bookmark_border,
                      title: 'No Saved Items',
                      subtitle: 'Items you bookmark will appear here',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontalPadding),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final item = _filtered[i];
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sp3),
                        child: Dismissible(
                          key: ValueKey(item.title + item.type),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.only(right: AppSpacing.sp4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: AppRadius.borderRadiusLg,
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          onDismissed: (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Removed "${item.title}"'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        AppRadius.borderRadiusSm),
                                action: SnackBarAction(
                                    label: 'Undo', onPressed: () {}),
                              ),
                            );
                          },
                          child: Container(
                            padding:
                                const EdgeInsets.all(AppSpacing.sp4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark
                                  : AppColors.surface,
                              borderRadius: AppRadius.borderRadiusLg,
                              boxShadow: isDark
                                  ? AppShadows.xsDark
                                  : AppShadows.xs,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: item.color
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        AppRadius.borderRadiusMd,
                                  ),
                                  child: Icon(item.icon,
                                      color: item.color, size: 22),
                                ),
                                const SizedBox(
                                    width: AppSpacing.sp3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title,
                                          style: AppTextStyles
                                              .bodyLargeSemiBold
                                              .copyWith(
                                                  color: isDark
                                                      ? AppColors
                                                          .textPrimaryDark
                                                      : AppColors
                                                          .textPrimary),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis),
                                      const SizedBox(height: 3),
                                      Text(item.subtitle,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                  color: isDark
                                                      ? AppColors
                                                          .textSecondaryDark
                                                      : AppColors
                                                          .textSecondary,
                                                  fontSize: 11),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                    width: AppSpacing.sp2),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2),
                                      decoration: BoxDecoration(
                                        color: item.color
                                            .withValues(alpha: 0.1),
                                        borderRadius: AppRadius
                                            .borderRadiusFull,
                                      ),
                                      child: Text(item.type,
                                          style: AppTextStyles
                                              .bodySmall
                                              .copyWith(
                                                  color: item.color,
                                                  fontSize: 9)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_formatDate(item.date),
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                color: isDark
                                                    ? AppColors
                                                        .textSecondaryDark
                                                    : AppColors
                                                        .textDisabled,
                                                fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

// ── Data ─────────────────────────────────────────────────────────────────────

class _SavedItem {
  const _SavedItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String type;
  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;
}
