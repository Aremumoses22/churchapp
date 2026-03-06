import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PHOTO GALLERY SCREEN
//
// Masonry grid of church event photos, tap to full-screen lightbox with
// swipe, download/share actions.
// ──────────────────────────────────────────────────────────────────────────────

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  int _selectedAlbum = 0;

  static const _albums = [
    'All',
    'Sunday Services',
    'Youth Camp 2024',
    'Easter Celebration',
    'Christmas Concert',
    'Community Outreach',
    'Baptisms',
  ];

  // Mock photo data — using placeholder colors + icons
  static final _photos = List.generate(24, (i) {
    final albumIndex = (i % 6) + 1;
    return _PhotoData(
      id: 'photo_$i',
      album: _albums[albumIndex],
      date: DateTime.now().subtract(Duration(days: i * 3)),
      aspectRatio: i % 3 == 0 ? 1.0 : (i % 3 == 1 ? 0.75 : 1.3),
      colorSeed: i,
    );
  });

  List<_PhotoData> get _filtered {
    if (_selectedAlbum == 0) return _photos;
    return _photos.where((p) => p.album == _albums[_selectedAlbum]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Photo Gallery',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined,
                color: Colors.white, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Upload photos coming soon!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusSm),
              ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Album chips ──────────────────────────────────────────
          const SizedBox(height: AppSpacing.sp3),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding),
              itemCount: _albums.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sp2),
              itemBuilder: (context, i) {
                final sel = _selectedAlbum == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAlbum = i),
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
                      child: Text(_albums[i],
                          style: AppTextStyles.labelSmall.copyWith(
                              color: sel
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary),
                              fontSize: 12)),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sp2),

          // Photo count
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filtered.length} photos',
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sp3),

          // ── Masonry grid ─────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: AppEmptyState(
                      icon: Icons.photo_library_outlined,
                      title: 'No Photos',
                      subtitle: 'This album is empty',
                    ),
                  )
                : _MasonryGrid(
                    photos: _filtered,
                    isDark: isDark,
                    onPhotoTap: (index) =>
                        _openLightbox(context, index, isDark),
                  ),
          ),
        ],
      ),
    );
  }

  void _openLightbox(BuildContext context, int initialIndex, bool isDark) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _LightboxView(
          photos: _filtered,
          initialIndex: initialIndex,
          isDark: isDark,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _PhotoData {
  const _PhotoData({
    required this.id,
    required this.album,
    required this.date,
    required this.aspectRatio,
    required this.colorSeed,
  });

  final String id;
  final String album;
  final DateTime date;
  final double aspectRatio;
  final int colorSeed;
}

// ── Masonry Grid ─────────────────────────────────────────────────────────────

class _MasonryGrid extends StatelessWidget {
  const _MasonryGrid({
    required this.photos,
    required this.isDark,
    required this.onPhotoTap,
  });

  final List<_PhotoData> photos;
  final bool isDark;
  final void Function(int index) onPhotoTap;

  @override
  Widget build(BuildContext context) {
    // Simple 2-column layout
    final col1 = <int>[];
    final col2 = <int>[];
    double h1 = 0, h2 = 0;

    for (int i = 0; i < photos.length; i++) {
      final height = 1.0 / photos[i].aspectRatio;
      if (h1 <= h2) {
        col1.add(i);
        h1 += height;
      } else {
        col2.add(i);
        h2 += height;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildColumn(col1)),
            const SizedBox(width: AppSpacing.sp2),
            Expanded(child: _buildColumn(col2)),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<int> indices) {
    return Column(
      children: indices
          .map((i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
                child: _PhotoTile(
                  photo: photos[i],
                  isDark: isDark,
                  onTap: () => onPhotoTap(i),
                ),
              ))
          .toList(),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.isDark,
    required this.onTap,
  });

  final _PhotoData photo;
  final bool isDark;
  final VoidCallback onTap;

  // Generate a pastel-ish color from seed
  Color _seedColor() {
    final hue = (photo.colorSeed * 37.0) % 360;
    return HSLColor.fromAHSL(1, hue, 0.35, isDark ? 0.25 : 0.85).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final baseHeight = 120.0 + (photo.colorSeed % 5) * 30.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: baseHeight,
        decoration: BoxDecoration(
          color: _seedColor(),
          borderRadius: AppRadius.borderRadiusMd,
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.image_outlined,
                size: 32,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: AppRadius.borderRadiusXs,
                ),
                child: Text(
                  photo.album.length > 14
                      ? '${photo.album.substring(0, 14)}…'
                      : photo.album,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lightbox ─────────────────────────────────────────────────────────────────

class _LightboxView extends StatefulWidget {
  const _LightboxView({
    required this.photos,
    required this.initialIndex,
    required this.isDark,
  });

  final List<_PhotoData> photos;
  final int initialIndex;
  final bool isDark;

  @override
  State<_LightboxView> createState() => _LightboxViewState();
}

class _LightboxViewState extends State<_LightboxView> {
  late PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _seedColor(int seed) {
    final hue = (seed * 37.0) % 360;
    return HSLColor.fromAHSL(1, hue, 0.35, 0.25).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_current];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Swipeable photos
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              final p = widget.photos[i];
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.sp6),
                  decoration: BoxDecoration(
                    color: _seedColor(p.colorSeed),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: AspectRatio(
                    aspectRatio: p.aspectRatio,
                    child: Center(
                      child: Icon(Icons.image_outlined,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              );
            },
          ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                Text(
                  '${_current + 1} / ${widget.photos.length}',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: Colors.white70),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Bottom info
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sp4,
            left: AppSpacing.sp6,
            right: AppSpacing.sp6,
            child: Column(
              children: [
                Text(photo.album,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  '${photo.date.day}/${photo.date.month}/${photo.date.year}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.white54),
                ),
                const SizedBox(height: AppSpacing.sp4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LightboxAction(
                        icon: Icons.download_outlined, label: 'Save'),
                    const SizedBox(width: AppSpacing.sp8),
                    _LightboxAction(
                        icon: Icons.share_outlined, label: 'Share'),
                    const SizedBox(width: AppSpacing.sp8),
                    _LightboxAction(
                        icon: Icons.favorite_border, label: 'Like'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LightboxAction extends StatelessWidget {
  const _LightboxAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
