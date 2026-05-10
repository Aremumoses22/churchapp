import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/user_providers.dart';
import '../../core/repositories/user_repository.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SAVED ITEMS SCREEN
//
// Unified view of all bookmarks: sermons, events, verses, devotionals —
// with filter tabs.  Now wired to userNotifierProvider.fetchSavedItems().
// ──────────────────────────────────────────────────────────────────────────────

class SavedItemsScreen extends ConsumerStatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  ConsumerState<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends ConsumerState<SavedItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = ['All', 'Sermons', 'Events', 'Verses', 'Devotionals'];

  /// Map entityType from backend to our tab names.
  static const _typeMap = {
    'SERMON': 'Sermons',
    'EVENT': 'Events',
    'VERSE': 'Verses',
    'DEVOTIONAL': 'Devotionals',
    'READING_PLAN': 'Devotionals',
  };

  static const _typeIcons = <String, IconData>{
    'Sermons': Icons.headphones_outlined,
    'Events': Icons.event_outlined,
    'Verses': Icons.menu_book_outlined,
    'Devotionals': Icons.wb_sunny_outlined,
  };

  static const _typeColors = <String, Color>{
    'Sermons': Color(0xFF2563EB),
    'Events': Color(0xFFF59E0B),
    'Verses': Color(0xFF7C3AED),
    'Devotionals': Color(0xFFEC4899),
  };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    // Load saved items
    Future.microtask(
        () => ref.read(userNotifierProvider.notifier).fetchSavedItems());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  String _tabName(SavedItem item) =>
      _typeMap[item.entityType.toUpperCase()] ?? 'Devotionals';

  List<SavedItem> get _allItems =>
      ref.read(userNotifierProvider).savedItems;

  List<SavedItem> get _filtered {
    final all = _allItems;
    if (_tabCtrl.index == 0) return all;
    final tabName = _tabs[_tabCtrl.index];
    return all.where((i) => _tabName(i) == tabName).toList();
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${_monthNames[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Watch for state changes
    final savedItems = ref.watch(userNotifierProvider).savedItems;

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
                    ? savedItems.length
                    : savedItems
                        .where((it) => _tabName(it) == _tabs[i])
                        .length;

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
                      final typeName = _tabName(item);
                      final color =
                          _typeColors[typeName] ?? const Color(0xFF2563EB);
                      final icon =
                          _typeIcons[typeName] ?? Icons.bookmark_outlined;
                      // Try to extract title from entity, fallback to entityType + entityId
                      final title = item.entity?['title'] as String? ??
                          '${item.entityType} item';
                      final subtitle =
                          item.entity?['description'] as String? ??
                              item.entity?['subtitle'] as String? ??
                              '';

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sp3),
                        child: Dismissible(
                          key: ValueKey(item.id),
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
                            ref
                                .read(userNotifierProvider.notifier)
                                .removeSavedItem(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Removed "$title"'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        AppRadius.borderRadiusSm),
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
                                    color:
                                        color.withValues(alpha: 0.1),
                                    borderRadius:
                                        AppRadius.borderRadiusMd,
                                  ),
                                  child: Icon(icon,
                                      color: color, size: 22),
                                ),
                                const SizedBox(
                                    width: AppSpacing.sp3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(title,
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
                                      Text(subtitle,
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
                                        color: color
                                            .withValues(alpha: 0.1),
                                        borderRadius: AppRadius
                                            .borderRadiusFull,
                                      ),
                                      child: Text(typeName,
                                          style: AppTextStyles
                                              .bodySmall
                                              .copyWith(
                                                  color: color,
                                                  fontSize: 9)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        _formatDate(item.createdAt),
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
