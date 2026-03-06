import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// WORSHIP LYRICS SCREEN
//
// Song lyrics displayed during live service, auto-scroll, large readable
// font, chord toggle for musicians.
// ──────────────────────────────────────────────────────────────────────────────

class WorshipLyricsScreen extends StatefulWidget {
  const WorshipLyricsScreen({super.key});

  @override
  State<WorshipLyricsScreen> createState() => _WorshipLyricsScreenState();
}

class _WorshipLyricsScreenState extends State<WorshipLyricsScreen>
    with SingleTickerProviderStateMixin {
  bool _showChords = false;
  bool _autoScroll = false;
  int _currentSong = 0;
  double _fontSize = 20;
  late ScrollController _scrollController;

  static final _setlist = [
    _SongData(
      title: 'Great Are You Lord',
      artist: 'All Sons & Daughters',
      key: 'G',
      bpm: 72,
      sections: [
        _SongSection('Verse 1', [
          _LyricLine('You give life, You are love', chord: 'G'),
          _LyricLine('You bring light to the darkness', chord: 'Em7'),
          _LyricLine('You give hope, You restore', chord: 'Csus2'),
          _LyricLine('Every heart that is broken', chord: 'D'),
        ]),
        _SongSection('Pre-Chorus', [
          _LyricLine('And great are You, Lord', chord: 'G'),
        ]),
        _SongSection('Chorus', [
          _LyricLine("It's Your breath in our lungs", chord: 'G'),
          _LyricLine('So we pour out our praise', chord: 'Em7'),
          _LyricLine('We pour out our praise', chord: 'Csus2'),
          _LyricLine("It's Your breath in our lungs", chord: 'D'),
          _LyricLine('So we pour out our praise to You only', chord: 'G'),
        ]),
        _SongSection('Verse 2', [
          _LyricLine('You give life, You are love', chord: 'G'),
          _LyricLine('You bring light to the darkness', chord: 'Em7'),
          _LyricLine('You give hope, You restore', chord: 'Csus2'),
          _LyricLine('Every heart that is broken', chord: 'D'),
        ]),
        _SongSection('Bridge', [
          _LyricLine('All the earth will shout Your praise', chord: 'G'),
          _LyricLine('Our hearts will cry, these bones will sing', chord: 'Em7'),
          _LyricLine('Great are You, Lord', chord: 'Csus2  D'),
        ]),
      ],
    ),
    _SongData(
      title: 'Way Maker',
      artist: 'Sinach',
      key: 'E',
      bpm: 68,
      sections: [
        _SongSection('Verse 1', [
          _LyricLine('You are here, moving in our midst', chord: 'E'),
          _LyricLine('I worship You, I worship You', chord: 'B'),
          _LyricLine('You are here, working in this place', chord: 'C#m'),
          _LyricLine('I worship You, I worship You', chord: 'A'),
        ]),
        _SongSection('Chorus', [
          _LyricLine('Way maker, miracle worker', chord: 'E'),
          _LyricLine('Promise keeper, light in the darkness', chord: 'B'),
          _LyricLine('My God, that is who You are', chord: 'C#m  A'),
        ]),
        _SongSection('Verse 2', [
          _LyricLine('You are here, touching every heart', chord: 'E'),
          _LyricLine('I worship You, I worship You', chord: 'B'),
          _LyricLine('You are here, healing every heart', chord: 'C#m'),
          _LyricLine('I worship You, I worship You', chord: 'A'),
        ]),
        _SongSection('Bridge', [
          _LyricLine('Even when I don\'t see it, You\'re working',
              chord: 'E'),
          _LyricLine('Even when I don\'t feel it, You\'re working',
              chord: 'B'),
          _LyricLine('You never stop, You never stop working',
              chord: 'C#m  A'),
        ]),
      ],
    ),
    _SongData(
      title: 'Build My Life',
      artist: 'Housefires',
      key: 'G',
      bpm: 68,
      sections: [
        _SongSection('Verse 1', [
          _LyricLine('Worthy of every song we could ever sing', chord: 'G'),
          _LyricLine('Worthy of all the praise we could ever bring',
              chord: 'Em'),
          _LyricLine('Worthy of every breath we could ever breathe',
              chord: 'C'),
          _LyricLine('We live for You', chord: 'D'),
        ]),
        _SongSection('Chorus', [
          _LyricLine('I will build my life upon Your love', chord: 'G'),
          _LyricLine('It is a firm foundation', chord: 'Em'),
          _LyricLine('I will put my trust in You alone', chord: 'C'),
          _LyricLine('And I will not be shaken', chord: 'D'),
        ]),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleAutoScroll() {
    setState(() => _autoScroll = !_autoScroll);
    if (_autoScroll) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    if (!_autoScroll || !mounted) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final remaining = maxScroll - currentScroll;
    if (remaining <= 0) {
      setState(() => _autoScroll = false);
      return;
    }
    // ~30 seconds to scroll remaining content
    final duration = Duration(milliseconds: (remaining * 50).toInt());
    _scrollController
        .animateTo(maxScroll, duration: duration, curve: Curves.linear)
        .then((_) {
      if (mounted) setState(() => _autoScroll = false);
    });
  }

  void _stopAutoScroll() {
    _scrollController.jumpTo(_scrollController.offset); // Stop animation
    setState(() => _autoScroll = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final song = _setlist[_currentSong];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Worship',
        showBack: true,
        actions: [
          IconButton(
            icon: Icon(
              _showChords ? Icons.music_note : Icons.music_off_outlined,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => setState(() => _showChords = !_showChords),
            tooltip: 'Toggle Chords',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Song selector ────────────────────────────────────────
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                  vertical: AppSpacing.sp3),
              itemCount: _setlist.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sp3),
              itemBuilder: (context, i) {
                final sel = _currentSong == i;
                final s = _setlist[i];
                return GestureDetector(
                  onTap: () {
                    if (_autoScroll) _stopAutoScroll();
                    _scrollController.jumpTo(0);
                    setState(() => _currentSong = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp4, vertical: AppSpacing.sp2),
                    decoration: BoxDecoration(
                      color: sel
                          ? (isDark ? AppColors.primaryLight : AppColors.primary)
                              .withValues(alpha: 0.12)
                          : (isDark
                              ? AppColors.cardDark
                              : AppColors.surface),
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(
                        color: sel
                            ? (isDark
                                ? AppColors.primaryLight
                                : AppColors.primary)
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.inputBorder),
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.title,
                            style: AppTextStyles.labelSmall.copyWith(
                                color: sel
                                    ? (isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary)
                                    : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary),
                                fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('Key: ${s.key} • ${s.bpm} BPM',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textDisabled,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Song info bar ────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp4, vertical: AppSpacing.sp2),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.surface,
              borderRadius: AppRadius.borderRadiusMd,
              boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title,
                          style: AppTextStyles.bodyLargeSemiBold.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary)),
                      Text(song.artist,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Text('Key: ${song.key}',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.gold, fontSize: 11)),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sp3),

          // ── Lyrics body ──────────────────────────────────────────
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification && _autoScroll) {
                  _stopAutoScroll();
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...song.sections.map((section) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sp5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.skyDark
                                      : AppColors.skyLight,
                                  borderRadius: AppRadius.borderRadiusFull,
                                ),
                                child: Text(
                                  section.label.toUpperCase(),
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                      fontSize: 10,
                                      letterSpacing: 1),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sp3),
                              ...section.lines.map((line) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sp2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (_showChords &&
                                            line.chord != null) ...[
                                          Text(
                                            line.chord!,
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                                    color: AppColors.gold,
                                                    fontSize: _fontSize * 0.65,
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                          const SizedBox(height: 1),
                                        ],
                                        Text(
                                          line.text,
                                          style: AppTextStyles.bodyLarge
                                              .copyWith(
                                                  fontSize: _fontSize,
                                                  color: isDark
                                                      ? AppColors
                                                          .textPrimaryDark
                                                      : AppColors.textPrimary,
                                                  height: 1.6),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        )),
                    const SizedBox(height: AppSpacing.sp10),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom controls ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.surface,
              boxShadow: isDark ? AppShadows.mdDark : AppShadows.md,
            ),
            padding: EdgeInsets.fromLTRB(
                AppSpacing.sp4,
                AppSpacing.sp3,
                AppSpacing.sp4,
                MediaQuery.of(context).padding.bottom + AppSpacing.sp3),
            child: Row(
              children: [
                // Font size controls
                GestureDetector(
                  onTap: () {
                    if (_fontSize > 14) setState(() => _fontSize -= 2);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.bgDark : AppColors.inputFill,
                    ),
                    child: Icon(Icons.text_decrease, size: 16,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sp2),
                  child: Text('${_fontSize.toInt()}',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)),
                ),
                GestureDetector(
                  onTap: () {
                    if (_fontSize < 36) setState(() => _fontSize += 2);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.bgDark : AppColors.inputFill,
                    ),
                    child: Icon(Icons.text_increase, size: 16,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                  ),
                ),

                const Spacer(),

                // Auto-scroll toggle
                GestureDetector(
                  onTap: _toggleAutoScroll,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp3, vertical: AppSpacing.sp1),
                    decoration: BoxDecoration(
                      color: _autoScroll
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.bgDark
                              : AppColors.inputFill),
                      borderRadius: AppRadius.borderRadiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _autoScroll
                              ? Icons.pause
                              : Icons.expand_more,
                          size: 16,
                          color: _autoScroll
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _autoScroll ? 'Scrolling' : 'Auto-Scroll',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _autoScroll
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Prev / Next
                GestureDetector(
                  onTap: _currentSong > 0
                      ? () {
                          if (_autoScroll) _stopAutoScroll();
                          _scrollController.jumpTo(0);
                          setState(() => _currentSong--);
                        }
                      : null,
                  child: Icon(Icons.skip_previous_outlined,
                      size: 24,
                      color: _currentSong > 0
                          ? (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.inactive)),
                ),
                const SizedBox(width: AppSpacing.sp4),
                GestureDetector(
                  onTap: _currentSong < _setlist.length - 1
                      ? () {
                          if (_autoScroll) _stopAutoScroll();
                          _scrollController.jumpTo(0);
                          setState(() => _currentSong++);
                        }
                      : null,
                  child: Icon(Icons.skip_next_outlined,
                      size: 24,
                      color: _currentSong < _setlist.length - 1
                          ? (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.inactive)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _SongData {
  const _SongData({
    required this.title,
    required this.artist,
    required this.key,
    required this.bpm,
    required this.sections,
  });

  final String title;
  final String artist;
  final String key;
  final int bpm;
  final List<_SongSection> sections;
}

class _SongSection {
  const _SongSection(this.label, this.lines);

  final String label;
  final List<_LyricLine> lines;
}

class _LyricLine {
  const _LyricLine(this.text, {this.chord});

  final String text;
  final String? chord;
}
