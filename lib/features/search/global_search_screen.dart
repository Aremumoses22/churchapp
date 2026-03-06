import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/search.dart';
import '../../core/providers/search_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_tap_animation.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// GLOBAL SEARCH SCREEN
///
/// Unified search across sermons, events, people, forum threads, bible verses,
/// and more. Features:
///   - Auto-focus search bar with clear button
///   - Recent searches (persisted visually)
///   - Trending / popular searches
///   - Real-time filtered results grouped by category
///   - Category-specific icons & navigation
/// ══════════════════════════════════════════════════════════════════════════════

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Auto-focus the search bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      ref.read(searchNotifierProvider.notifier).setQuery(val.trim());
    });
  }

  void _setQuery(String val) {
    _searchCtrl.text = val;
    ref.read(searchNotifierProvider.notifier).setQuery(val.trim());
  }

  void _clearSearch() {
    _searchCtrl.clear();
    ref.read(searchNotifierProvider.notifier).setQuery('');
    _focusNode.requestFocus();
  }

  void _removeRecent(int index) {
    final sState = ref.read(searchNotifierProvider);
    if (index < sState.recentSearches.length) {
      ref.read(searchNotifierProvider.notifier).removeRecentSearch(sState.recentSearches[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sState = ref.watch(searchNotifierProvider);
    final hasResults = sState.results.isNotEmpty;
    final hasQuery = sState.hasQuery;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp3, AppSpacing.sp3, AppSpacing.sp4, 0,
              ),
              child: Row(
                children: [
                  // Back button
                  AppTapAnimation(
                    onTap: () => context.pop(),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Icon(Icons.arrow_back_rounded, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp1),
                  // Search field
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : const Color(0xFFF1F5F9),
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search sermons, events, people...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          suffixIcon: hasQuery
                              ? AppTapAnimation(
                                  onTap: _clearSearch,
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sp3),

            // ── Content ─────────────────────────────────────────────────
            Expanded(
              child: hasQuery
                  ? (hasResults
                      ? _buildResults(isDark)
                      : _buildNoResults(isDark))
                  : _buildIdleState(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ── Idle state: recent + trending ─────────────────────────────────────
  Widget _buildIdleState(bool isDark) {
    final sState = ref.read(searchNotifierProvider);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
      children: [
        // Recent searches
        if (sState.recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Text(
                'RECENT SEARCHES',
                style: AppTextStyles.labelAllCaps.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              AppTapAnimation(
                onTap: () => ref.read(searchNotifierProvider.notifier).clearRecentSearches(),
                child: Text(
                  'Clear all',
                  style: AppTextStyles.labelSmall.copyWith(
                    color:
                        isDark ? AppColors.primaryLight : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp2),
          ...List.generate(sState.recentSearches.length, (i) {
            return AppTapAnimation(
              onTap: () => _setQuery(sState.recentSearches[i]),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sp2),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled,
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    Expanded(
                      child: Text(
                        sState.recentSearches[i],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AppTapAnimation(
                      onTap: () => _removeRecent(i),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.sp5),
        ],

        // Trending
        Text(
          'TRENDING',
          style: AppTextStyles.labelAllCaps.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp3),
        Wrap(
          spacing: AppSpacing.sp2,
          runSpacing: AppSpacing.sp2,
          children: sState.trending.map((tag) {
            return AppTapAnimation(
              onTap: () => _setQuery(tag),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF1F5F9),
                  borderRadius: AppRadius.borderRadiusFull,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tag,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.sp5),

        // Quick access categories
        Text(
          'BROWSE BY CATEGORY',
          style: AppTextStyles.labelAllCaps.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sp3),
        ..._categoryQuickLinks(isDark),
      ],
    );
  }

  List<Widget> _categoryQuickLinks(bool isDark) {
    const cats = <(IconData, String, Color, String)>[
      (Icons.mic_outlined, 'Sermons', Color(0xFF3B82F6), '/sermons'),
      (Icons.event_outlined, 'Events', Color(0xFFEF4444), '/events'),
      (Icons.groups_outlined, 'Groups', Color(0xFFF59E0B), '/connect-groups'),
      (Icons.forum_outlined, 'Forum', Color(0xFF6366F1), '/forum'),
      (Icons.menu_book_outlined, 'Bible', Color(0xFF059669), '/bible'),
      (
        Icons.person_outlined,
        'People',
        Color(0xFF8B5CF6),
        '/church-directory'
      ),
      (
        Icons.music_note_outlined,
        'Media',
        Color(0xFF0EA5E9),
        '/worship-lyrics'
      ),
      (
        Icons.volunteer_activism_outlined,
        'Giving',
        Color(0xFFEC4899),
        '/giving'
      ),
    ];

    return cats.map((c) {
      return AppTapAnimation(
        onTap: () => context.push(c.$4),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sp1),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp3, vertical: AppSpacing.sp3),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white,
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.$3.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Icon(c.$1, color: c.$3, size: 18),
                ),
                const SizedBox(width: AppSpacing.sp3),
                Text(
                  c.$2,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── Results view ──────────────────────────────────────────────────────
  Widget _buildResults(bool isDark) {
    final sState = ref.read(searchNotifierProvider);
    final groups = sState.groupedResults;
    final totalCount = sState.results.length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
      children: [
        // Result count
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
          child: Text(
            '$totalCount result${totalCount == 1 ? '' : 's'} found',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),

        ...groups.entries.expand((entry) {
          return [
            // Category header
            Padding(
              padding: const EdgeInsets.only(
                  top: AppSpacing.sp2, bottom: AppSpacing.sp2),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: entry.value.first.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.key.toUpperCase(),
                    style: AppTextStyles.labelAllCaps.copyWith(
                      color: entry.value.first.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: entry.value.first.color
                          .withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderRadiusFull,
                    ),
                    child: Text(
                      '${entry.value.length}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: entry.value.first.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Items
            ...entry.value.map((item) => _ResultTile(
                  item: item,
                  isDark: isDark,
                  query: sState.query,
                  onTap: () => context.push(item.route),
                )),
            const SizedBox(height: AppSpacing.sp2),
          ];
        }),
      ],
    );
  }

  // ── No results ────────────────────────────────────────────────────────
  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 32,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Text(
              'No results found',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              'Try different keywords or browse by category below.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp6),
            // Show category quick links
            ..._categoryQuickLinks(isDark),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RESULT TILE — single search result with highlighted match
// ═══════════════════════════════════════════════════════════════════════════════

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.item,
    required this.isDark,
    required this.query,
    required this.onTap,
  });

  final SearchItem item;
  final bool isDark;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sp1),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp3, vertical: AppSpacing.sp3),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: AppRadius.borderRadiusMd,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.sp3),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _highlightedText(
                    item.title,
                    query,
                    AppTextStyles.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    item.color,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }

  /// Build a RichText with the matching portion highlighted.
  Widget _highlightedText(
      String text, String query, TextStyle base, Color accent) {
    if (query.isEmpty) return Text(text, style: base);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final idx = lowerText.indexOf(lowerQuery);

    if (idx < 0) return Text(text, style: base);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          if (idx > 0) TextSpan(text: text.substring(0, idx), style: base),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: base.copyWith(
              color: accent,
              backgroundColor: accent.withValues(alpha: 0.1),
            ),
          ),
          if (idx + query.length < text.length)
            TextSpan(
                text: text.substring(idx + query.length), style: base),
        ],
      ),
    );
  }
}

