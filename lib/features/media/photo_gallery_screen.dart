import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/media.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PHOTO GALLERY SCREEN
//
// Albums loaded from GET /media/albums. Tap album to view photos.
// ──────────────────────────────────────────────────────────────────────────────

class PhotoGalleryScreen extends ConsumerWidget {
  const PhotoGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final albumsAsync = ref.watch(albumsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Photo Gallery', showBack: true),
      body: albumsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: AppSpacing.sp3),
              Text('Failed to load albums', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sp3),
              AppSecondaryButton(
                label: 'Retry',
                onPressed: () => ref.invalidate(albumsProvider),
              ),
            ],
          ),
        ),
        data: (albums) => albums.isEmpty
            ? const AppEmptyState(
                icon: Icons.photo_library_outlined,
                title: 'No albums yet',
                subtitle: 'Church photo albums will appear here.',
              )
            : GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.sp4),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.sp3,
                  mainAxisSpacing: AppSpacing.sp3,
                  childAspectRatio: 0.85,
                ),
                itemCount: albums.length,
                itemBuilder: (context, i) => _AlbumCard(
                  album: albums[i],
                  isDark: isDark,
                  onTap: () => _openAlbum(context, ref, albums[i], isDark),
                ),
              ),
      ),
    );
  }

  void _openAlbum(BuildContext context, WidgetRef ref,
      PhotoAlbum album, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx2, scroll) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surface,
            borderRadius: AppRadius.borderRadiusXlTop,
          ),
          child: _AlbumPhotosSheet(
            album: album,
            isDark: isDark,
            scrollController: scroll,
          ),
        ),
      ),
    );
  }
}

// ── Album card ────────────────────────────────────────────────────────────────

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.album,
    required this.isDark,
    required this.onTap,
  });

  final PhotoAlbum album;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: album.coverUrl != null
                  ? Image.network(
                      album.coverUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: isDark
                            ? AppColors.skyDark
                            : AppColors.inputFill,
                        child: Center(
                          child: Icon(Icons.photo_library_outlined,
                              size: 40,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textDisabled),
                        ),
                      ),
                    )
                  : Container(
                      color: isDark
                          ? AppColors.skyDark
                          : AppColors.inputFill,
                      child: Center(
                        child: Icon(Icons.photo_library_outlined,
                            size: 40,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sp3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(album.title,
                      style: AppTextStyles.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${album.photoCount} photos',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Album photos sheet ────────────────────────────────────────────────────────

class _AlbumPhotosSheet extends ConsumerWidget {
  const _AlbumPhotosSheet({
    required this.album,
    required this.isDark,
    required this.scrollController,
  });

  final PhotoAlbum album;
  final bool isDark;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(albumPhotosProvider(album.id));

    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color:
                    isDark ? AppColors.borderDark : AppColors.inactive,
                borderRadius: AppRadius.borderRadiusFull),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sp4),
          child: Text(album.title,
              style: AppTextStyles.headingSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary)),
        ),
        Expanded(
          child: photosAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
                child: Text('Failed to load photos',
                    style: AppTextStyles.bodyMedium)),
            data: (photos) => photos.isEmpty
                ? const AppEmptyState(
                    icon: Icons.photo_outlined,
                    title: 'No photos',
                    subtitle: 'This album has no photos yet.',
                  )
                : GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.sp3),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: AppRadius.borderRadiusSm,
                      child: Image.network(
                        photos[i].url,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: isDark
                              ? AppColors.skyDark
                              : AppColors.inputFill,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
