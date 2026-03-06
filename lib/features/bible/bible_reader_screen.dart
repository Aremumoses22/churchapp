import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/bible_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BIBLE READER SCREEN
//
// Three-level navigation: Book Picker → Chapter Grid → Verse View.
// Features: serif typography, tap-to-highlight in gold, copy/share verse,
// night reading mode toggle.
// ──────────────────────────────────────────────────────────────────────────────

class BibleReaderScreen extends ConsumerStatefulWidget {
  const BibleReaderScreen({super.key});

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;


  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _animateTransition(VoidCallback action) {
    _fadeController.reverse().then((_) {
      action();
      _fadeController.forward();
    });
  }

  void _goBack() {
    final bState = ref.read(bibleNotifierProvider);
    if (bState.level > 0) {
      _animateTransition(() => ref.read(bibleNotifierProvider.notifier).goBack());
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bState = ref.watch(bibleNotifierProvider);
    final effectiveNight = bState.nightMode || isDark;

    final bgColor = effectiveNight
        ? const Color(0xFF1A1A2E)
        : AppColors.warmWhite;

    final textColor = effectiveNight
        ? const Color(0xFFE8E8E8)
        : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(effectiveNight, textColor),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: bState.level == 0
            ? _buildBookPicker(effectiveNight, textColor)
            : bState.level == 1
                ? _buildChapterGrid(effectiveNight, textColor)
                : _buildVerseView(effectiveNight, textColor),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool nightMode, Color textColor) {
    final bState = ref.read(bibleNotifierProvider);
    final title = bState.level == 0
        ? 'Bible'
        : bState.level == 1
            ? bState.selectedBook
            : '${bState.selectedBook} ${bState.selectedChapter}';

    return AppBar(
      backgroundColor: nightMode
          ? const Color(0xFF1A1A2E)
          : AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          bState.level == 0 ? Icons.close : Icons.arrow_back_ios_new,
          color: textColor,
          size: 20,
        ),
        onPressed: _goBack,
      ),
      title: Text(
        title,
        style: AppTextStyles.headingMedium.copyWith(color: textColor),
      ),
      actions: [
        // Night mode toggle
        IconButton(
          icon: Icon(
            bState.nightMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: textColor,
            size: 22,
          ),
          onPressed: () => ref.read(bibleNotifierProvider.notifier).toggleNightMode(),
          tooltip: bState.nightMode ? 'Day mode' : 'Night mode',
        ),
        // Search
        IconButton(
          icon: Icon(Icons.search, color: textColor, size: 22),
          onPressed: () {
            // TODO: search Bible
          },
          tooltip: 'Search',
        ),
        const SizedBox(width: AppSpacing.sp2),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: nightMode
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.divider,
        ),
      ),
    );
  }

  // ── Level 0 — Book Picker ─────────────────────────────────────────────────

  Widget _buildBookPicker(bool nightMode, Color textColor) {
    final bState = ref.read(bibleNotifierProvider);
    final secondaryColor = nightMode
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontalPadding,
        vertical: AppSpacing.sp4,
      ),
      children: [
        // Quick search bar
        _SearchField(nightMode: nightMode),
        const SizedBox(height: AppSpacing.sp6),

        // Old Testament
        Text(
          'OLD TESTAMENT',
          style: AppTextStyles.labelAllCaps.copyWith(
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: AppSpacing.sp3),
        ...bState.oldTestament.map((book) => _BookTile(
              book: book,
              chapters: bState.books.where((b) => b.name == book).firstOrNull?.chapters ?? 0,
              textColor: textColor,
              secondaryColor: secondaryColor,
              nightMode: nightMode,
              onTap: () => _animateTransition(() => ref.read(bibleNotifierProvider.notifier).selectBook(book)),
            )),

        const SizedBox(height: AppSpacing.sp8),

        // New Testament
        Text(
          'NEW TESTAMENT',
          style: AppTextStyles.labelAllCaps.copyWith(
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: AppSpacing.sp3),
        ...bState.newTestament.map((book) => _BookTile(
              book: book,
              chapters: bState.books.where((b) => b.name == book).firstOrNull?.chapters ?? 0,
              textColor: textColor,
              secondaryColor: secondaryColor,
              nightMode: nightMode,
              onTap: () => _animateTransition(() => ref.read(bibleNotifierProvider.notifier).selectBook(book)),
            )),
      ],
    );
  }

  // ── Level 1 — Chapter Grid ────────────────────────────────────────────────

  Widget _buildChapterGrid(bool nightMode, Color textColor) {
    final bState = ref.read(bibleNotifierProvider);
    final chapters = bState.chapterCount;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sp2),
          Text(
            'Select a Chapter',
            style: AppTextStyles.bodyMedium.copyWith(
              color: nightMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sp5),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: chapters,
              itemBuilder: (context, index) {
                final chapter = index + 1;
                return _ChapterCell(
                  chapter: chapter,
                  nightMode: nightMode,
                  textColor: textColor,
                  onTap: () => _animateTransition(() => ref.read(bibleNotifierProvider.notifier).selectChapter(chapter)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Level 2 — Verse View ──────────────────────────────────────────────────

  Widget _buildVerseView(bool nightMode, Color textColor) {
    final bState = ref.read(bibleNotifierProvider);
    return Column(
      children: [
        // Chapter navigation row
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
            vertical: AppSpacing.sp3,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavArrow(
                icon: Icons.chevron_left,
                label: 'Prev',
                enabled: bState.selectedChapter > 1,
                nightMode: nightMode,
                onTap: () {
                  if (bState.selectedChapter > 1) {
                    _animateTransition(() => ref.read(bibleNotifierProvider.notifier).selectChapter(bState.selectedChapter - 1));
                  }
                },
              ),
              Column(
                children: [
                  Text(
                    'Chapter ${bState.selectedChapter}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bState.selectedBook,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: nightMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              _NavArrow(
                icon: Icons.chevron_right,
                label: 'Next',
                enabled: bState.selectedChapter < bState.chapterCount,
                nightMode: nightMode,
                onTap: () {
                  if (bState.selectedChapter < bState.chapterCount) {
                    _animateTransition(() => ref.read(bibleNotifierProvider.notifier).selectChapter(bState.selectedChapter + 1));
                  }
                },
              ),
            ],
          ),
        ),

        // Verse list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sp6,
              vertical: AppSpacing.sp4,
            ),
            itemCount: bState.verses.length,
            itemBuilder: (context, index) {
              final verseNum = index + 1;
              final isHighlighted = bState.highlightedVerses.contains(verseNum);

              return GestureDetector(
                onTap: () {
                  ref.read(bibleNotifierProvider.notifier).toggleHighlight(verseNum);
                  HapticFeedback.lightImpact();
                },
                onLongPress: () => _showVerseActions(verseNum),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sp4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp4,
                    vertical: AppSpacing.sp3,
                  ),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? AppColors.gold.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: AppRadius.borderRadiusSm,
                    border: isHighlighted
                        ? Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$verseNum  ',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isHighlighted
                                ? AppColors.gold
                                : (nightMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textDisabled),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: bState.verses[index],
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1.8,
                            color: isHighlighted
                                ? (nightMode
                                    ? AppColors.gold
                                    : const Color(0xFF92400E))
                                : textColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Highlighted verse count bar
        if (bState.highlightedVerses.isNotEmpty)
          _HighlightBar(
            count: bState.highlightedVerses.length,
            nightMode: nightMode,
            onCopy: () => _copyHighlightedVerses(),
            onShare: () {
              // TODO: share highlighted verses
            },
            onClear: () => ref.read(bibleNotifierProvider.notifier).clearHighlights(),
          ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showVerseActions(int verseNum) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bState = ref.read(bibleNotifierProvider);
    final nightMode = bState.nightMode || isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: nightMode ? const Color(0xFF1F1F3A) : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.sp6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: nightMode ? Colors.white24 : AppColors.inactive,
                borderRadius: AppRadius.borderRadiusFull,
              ),
            ),
            const SizedBox(height: AppSpacing.sp5),
            Text(
              '${bState.selectedBook} ${bState.selectedChapter}:$verseNum',
              style: AppTextStyles.headingSmall.copyWith(
                color: nightMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp6),
            _ActionRow(
              icon: Icons.highlight_outlined,
              label: 'Highlight',
              color: AppColors.gold,
              onTap: () {
                ref.read(bibleNotifierProvider.notifier).toggleHighlight(verseNum);
                Navigator.pop(ctx);
              },
            ),
            _ActionRow(
              icon: Icons.copy_outlined,
              label: 'Copy Verse',
              color: nightMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
              onTap: () {
                Clipboard.setData(ClipboardData(
                  text:
                      '"${bState.verses[verseNum - 1]}" — ${bState.selectedBook} ${bState.selectedChapter}:$verseNum',
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verse copied')),
                );
              },
            ),
            _ActionRow(
              icon: Icons.share_outlined,
              label: 'Share',
              color: nightMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
              onTap: () {
                Navigator.pop(ctx);
                // TODO: share verse
              },
            ),
            _ActionRow(
              icon: Icons.bookmark_add_outlined,
              label: 'Bookmark',
              color: nightMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _copyHighlightedVerses() {
    final bState = ref.read(bibleNotifierProvider);
    final sorted = bState.highlightedVerses.toList()..sort();
    final text = sorted
        .map((v) =>
            '"${bState.verses[v - 1]}" — ${bState.selectedBook} ${bState.selectedChapter}:$v')
        .join('\n\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sorted.length} verse(s) copied'),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// PRIVATE SUB-WIDGETS
// ──────────────────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({required this.nightMode});
  final bool nightMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: nightMode
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.inputFill,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp3),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 20,
            color: nightMode ? Colors.white54 : AppColors.textDisabled,
          ),
          const SizedBox(width: AppSpacing.sp2),
          Expanded(
            child: TextField(
              style: AppTextStyles.bodyMedium.copyWith(
                color: nightMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search books...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: nightMode
                      ? Colors.white38
                      : AppColors.textDisabled,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({
    required this.book,
    required this.chapters,
    required this.textColor,
    required this.secondaryColor,
    required this.nightMode,
    required this.onTap,
  });

  final String book;
  final int chapters;
  final Color textColor;
  final Color secondaryColor;
  final bool nightMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp4,
          vertical: AppSpacing.sp3 + 2,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: nightMode
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.divider,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                book,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$chapters ch.',
              style: AppTextStyles.bodySmall.copyWith(
                color: secondaryColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sp2),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: secondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterCell extends StatelessWidget {
  const _ChapterCell({
    required this.chapter,
    required this.nightMode,
    required this.textColor,
    required this.onTap,
  });

  final int chapter;
  final bool nightMode;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: nightMode
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.skyLight,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: nightMode
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.inputBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '$chapter',
            style: AppTextStyles.labelLarge.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.nightMode,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final bool nightMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? (nightMode ? AppColors.textPrimaryDark : AppColors.primary)
        : (nightMode ? Colors.white24 : AppColors.textDisabled);

    return AppTapAnimation(
      onTap: enabled ? onTap : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon == Icons.chevron_left) Icon(icon, size: 20, color: color),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
          if (icon == Icons.chevron_right) Icon(icon, size: 20, color: color),
        ],
      ),
    );
  }
}

class _HighlightBar extends StatelessWidget {
  const _HighlightBar({
    required this.count,
    required this.nightMode,
    required this.onCopy,
    required this.onShare,
    required this.onClear,
  });

  final int count;
  final bool nightMode;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.sp4,
        right: AppSpacing.sp4,
        top: AppSpacing.sp3,
        bottom: AppSpacing.sp3 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: nightMode ? const Color(0xFF1F1F3A) : AppColors.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sp3,
              vertical: AppSpacing.sp1,
            ),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderRadiusFull,
            ),
            child: Text(
              '$count selected',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.gold,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 20),
            color: nightMode
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
            onPressed: onCopy,
            tooltip: 'Copy',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: nightMode
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
            onPressed: onShare,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: nightMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            onPressed: onClear,
            tooltip: 'Clear',
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp3),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: AppSpacing.sp4),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
