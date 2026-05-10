import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/event.dart';
import '../../core/providers/event_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EVENT DETAIL SCREEN — Section 10.5
//
// Hero image, overlapping white card, category tag, description,
// sticky registration footer.  Now fully wired to eventDetailProvider.
// ──────────────────────────────────────────────────────────────────────────────

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncEvent = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: asyncEvent.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    size: 48),
                const SizedBox(height: AppSpacing.sp3),
                Text('Could not load event',
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    )),
                const SizedBox(height: AppSpacing.sp2),
                AppPrimaryButton(
                  label: 'Retry',
                  onPressed: () =>
                      ref.invalidate(eventDetailProvider(eventId)),
                ),
              ],
            ),
          ),
        ),
        data: (event) => _EventDetailBody(
          event: event,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _EventDetailBody extends ConsumerStatefulWidget {
  const _EventDetailBody({
    required this.event,
    required this.isDark,
  });

  final Event event;
  final bool isDark;

  @override
  ConsumerState<_EventDetailBody> createState() => _EventDetailBodyState();
}

class _EventDetailBodyState extends ConsumerState<_EventDetailBody> {
  late bool _registered;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _registered = widget.event.isRegistered;
  }

  @override
  void didUpdateWidget(covariant _EventDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.isRegistered != widget.event.isRegistered) {
      _registered = widget.event.isRegistered;
    }
  }

  Future<void> _toggleRegistration() async {
    setState(() => _loading = true);
    final notifier = ref.read(eventNotifierProvider.notifier);
    bool success;
    if (_registered) {
      success = await notifier.unregisterFromEvent(widget.event.id);
    } else {
      success = await notifier.registerForEvent(widget.event.id);
    }
    if (mounted) {
      setState(() {
        if (success) _registered = !_registered;
        _loading = false;
      });
      // Refresh detail
      ref.invalidate(eventDetailProvider(widget.event.id));
    }
  }

  Color _categoryColor(EventCategory cat) {
    switch (cat) {
      case EventCategory.worship:
        return AppColors.gold;
      case EventCategory.conference:
        return AppColors.primary;
      case EventCategory.youth:
        return const Color(0xFF7C4DFF);
      case EventCategory.prayer:
        return const Color(0xFF26A69A);
      case EventCategory.outreach:
        return const Color(0xFFFF7043);
      case EventCategory.fellowship:
        return const Color(0xFF42A5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final isDark = widget.isDark;
    final catColor = _categoryColor(e.category);

    // Build date + time text
    final dateTimeText =
        '${e.dateFormatted} \u00b7 ${e.timeFormatted}';

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // ── Hero image ──────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (e.imageUrl != null && e.imageUrl!.isNotEmpty)
                      Image.network(e.imageUrl!, fit: BoxFit.cover)
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? AppGradients.heroDark
                              : AppGradients.hero,
                        ),
                        child: Center(
                          child: Icon(Icons.event,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 80),
                        ),
                      ),
                    // Back + Share overlays
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sp4),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            _circleButton(
                                Icons.arrow_back, () => context.pop()),
                            _circleButton(Icons.share, () {}),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content card ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.cardDark : AppColors.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sp4,
                    AppSpacing.sp6,
                    AppSpacing.sp4,
                    100, // space for sticky footer
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: AppRadius.borderRadiusFull,
                        ),
                        child: Text(
                          e.category.name[0].toUpperCase() +
                              e.category.name.substring(1),
                          style: AppTextStyles.labelSmall
                              .copyWith(color: catColor),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp3),

                      // Title
                      Text(
                        e.title,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp4),

                      // Date row
                      _infoRow(Icons.calendar_today, dateTimeText, isDark),
                      const SizedBox(height: AppSpacing.sp2),

                      // Location row
                      if (e.location != null && e.location!.isNotEmpty)
                        _infoRow(
                            Icons.location_on, e.location!, isDark,
                            isLink: true),

                      if (e.tags.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sp3),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: e.tags
                              .map((t) => Chip(
                                    label: Text(t,
                                        style: AppTextStyles.labelSmall),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.sp4),
                      const AppDivider(),
                      const SizedBox(height: AppSpacing.sp4),

                      // About
                      Text(
                        'About this Event',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      Text(
                        e.description ?? 'No description available.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      // Speakers
                      if (e.speakers.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sp4),
                        const AppDivider(),
                        const SizedBox(height: AppSpacing.sp4),
                        Text(
                          'Speakers',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp3),
                        ...e.speakers.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.sp2),
                            child: _speakerTile(
                              s.name,
                              s.title ?? '',
                              isDark,
                              imageUrl: s.imageUrl,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Sticky registration footer ───────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.surface,
              boxShadow: isDark ? AppShadows.lgDark : AppShadows.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${e.registeredCount} attending',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: _loading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          ),
                        )
                      : _registered
                          ? AppPrimaryButton(
                              label: '\u2713 Registered',
                              onPressed: _toggleRegistration,
                              isFullWidth: true,
                            )
                          : e.isFull
                              ? AppPrimaryButton(
                                  label: 'Event Full',
                                  onPressed: null,
                                  isFullWidth: true,
                                )
                              : AppPrimaryButton(
                                  label: 'Register Now',
                                  onPressed: _toggleRegistration,
                                  isFullWidth: true,
                                ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, bool isDark,
      {bool isLink = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLink
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
              decoration: isLink ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _speakerTile(String name, String role, bool isDark,
      {String? imageUrl}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
              isDark ? AppColors.primaryLight : AppColors.skyLight,
          backgroundImage:
              imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null
              ? Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: AppTextStyles.labelMedium.copyWith(
                    color:
                        isDark ? AppColors.textInverse : AppColors.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(width: AppSpacing.sp3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: AppTextStyles.bodyLargeSemiBold.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                )),
            if (role.isNotEmpty)
              Text(role,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  )),
          ],
        ),
      ],
    );
  }
}
