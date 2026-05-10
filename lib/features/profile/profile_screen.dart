import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/providers/user_providers.dart';
import '../../core/theme/theme.dart';
import '../../core/services/services.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PROFILE SCREEN — Section 12
//
// Avatar with gold border, name/dept/church, stats row, menu sections (My
// Activity, Account, Support), logout with confirmation bottom sheet.
// Now wired to userNotifierProvider for real profile data.
// ──────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile if not already loaded
    Future.microtask(() {
      final state = ref.read(userNotifierProvider);
      if (state.profile == null && !state.isLoading) {
        ref.read(userNotifierProvider.notifier).fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userState = ref.watch(userNotifierProvider);
    final profile = userState.profile;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Profile',
        actions: [IconButton(
          onPressed: () => context.push('/settings'),
          icon: Icon(Icons.settings_outlined,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        )],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sp6),

            // ── Avatar ─────────────────────────────────────────────────
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 106,
                  height: 106,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        isDark ? AppColors.primaryLight : AppColors.skyLight,
                    backgroundImage: profile?.avatarUrl != null
                        ? NetworkImage(profile!.avatarUrl!)
                        : null,
                    child: profile?.avatarUrl == null
                        ? Text(
                            (profile?.name.isNotEmpty == true
                                ? profile!.name[0]
                                : 'U')
                                .toUpperCase(),
                            style: AppTextStyles.displayLarge.copyWith(
                              color: isDark
                                  ? AppColors.textInverse
                                  : AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.bgDark : AppColors.warmWhite,
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 14, color: AppColors.textInverse),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sp3),

            // ── Name ───────────────────────────────────────────────────
            Text(
              profile?.name ?? 'User',
              style: AppTextStyles.headingLarge.copyWith(
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp1),

            // Department badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.skyDark : AppColors.skyLight,
                borderRadius: AppRadius.borderRadiusFull,
              ),
              child: Text(
                profile?.department ?? 'Member',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp1),
            Text(
              profile?.joinedDate != null
                  ? 'Joined ${profile!.joinedDate}'
                  : '',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold),
            ),

            const SizedBox(height: AppSpacing.sp5),

            // ── Stats row ──────────────────────────────────────────────
            AppCard(
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _stat('–', 'Sermons', isDark),
                    VerticalDivider(
                      color: isDark
                          ? AppColors.borderDark
                          : const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                    _stat('–', 'Given', isDark),
                    VerticalDivider(
                      color: isDark
                          ? AppColors.borderDark
                          : const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                    _stat('–', 'Events', isDark),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── My Activity ────────────────────────────────────────────
            _sectionLabel('MY ACTIVITY', isDark),
            const SizedBox(height: AppSpacing.sp2),
            _menuGroup([
              _MenuItem(Icons.volunteer_activism, 'My Giving History',
                  () => context.push('/profile/giving-history')),
              _MenuItem(Icons.event, 'My Events',
                  () => context.push('/profile/my-events')),
              _MenuItem(Icons.favorite_border, 'Prayer Requests',
                  () => context.push('/profile/prayer-requests')),
              _MenuItem(Icons.bookmark_border, 'Saved Sermons',
                  () => context.push(AppRoutes.savedSermons)),
              _MenuItem(Icons.bookmarks_outlined, 'Saved Items',
                  () => context.push(AppRoutes.savedItems)),
              _MenuItem(Icons.timeline, 'Spiritual Journey',
                  () => context.push(AppRoutes.spiritualJourney)),
              _MenuItem(Icons.calendar_today_outlined, 'Attendance History',
                  () => context.push(AppRoutes.attendanceHistory)),
            ], isDark),

            const SizedBox(height: AppSpacing.sp6),

            // ── Community ──────────────────────────────────────────────
            _sectionLabel('COMMUNITY', isDark),
            const SizedBox(height: AppSpacing.sp2),
            _menuGroup([
              _MenuItem(Icons.campaign_outlined, 'Announcements',
                  () => context.push(AppRoutes.announcements)),
              _MenuItem(Icons.groups_outlined, 'Connect Groups',
                  () => context.push(AppRoutes.connectGroups)),
              _MenuItem(Icons.format_quote_outlined, 'Testimonies',
                  () => context.push(AppRoutes.testimonies)),
              _MenuItem(Icons.people_outline, 'Church Directory',
                  () => context.push(AppRoutes.churchDirectory)),
              _MenuItem(Icons.share_outlined, 'Invite Friends',
                  () => context.push(AppRoutes.inviteFriends)),
            ], isDark),

            const SizedBox(height: AppSpacing.sp6),

            // ── Volunteering & Media ───────────────────────────────────
            _sectionLabel('SERVE & MEDIA', isDark),
            const SizedBox(height: AppSpacing.sp2),
            _menuGroup([
              _MenuItem(Icons.volunteer_activism_outlined, 'Volunteer',
                  () => context.push(AppRoutes.volunteer)),
              _MenuItem(Icons.calendar_month_outlined, 'My Roster',
                  () => context.push(AppRoutes.serviceRoster)),
              _MenuItem(Icons.child_care_outlined, 'Kids Check-In',
                  () => context.push(AppRoutes.kidsCheckin)),
              _MenuItem(Icons.photo_library_outlined, 'Photo Gallery',
                  () => context.push(AppRoutes.photoGallery)),
              _MenuItem(Icons.lyrics_outlined, 'Worship Lyrics',
                  () => context.push(AppRoutes.worshipLyrics)),
              _MenuItem(Icons.podcasts_outlined, 'Podcast',
                  () => context.push(AppRoutes.podcastFeed)),
            ], isDark),

            const SizedBox(height: AppSpacing.sp6),

            // ── Account ────────────────────────────────────────────────
            _sectionLabel('ACCOUNT', isDark),
            const SizedBox(height: AppSpacing.sp2),
            _menuGroup([
              _MenuItem(Icons.person_outline, 'Edit Profile',
                  () => context.push(AppRoutes.editProfile)),
              _MenuItem(Icons.notifications_none, 'Notification Settings',
                  () => context.push(AppRoutes.manageNotifications)),
              _MenuItem(Icons.palette_outlined, 'App Theme',
                  () => context.push(AppRoutes.settings)),
              _MenuItem(Icons.language, 'Language',
                  () => context.push(AppRoutes.settings)),
            ], isDark),

            const SizedBox(height: AppSpacing.sp6),

            // ── Support ────────────────────────────────────────────────
            _sectionLabel('SUPPORT', isDark),
            const SizedBox(height: AppSpacing.sp2),
            _menuGroup([
              _MenuItem(Icons.help_outline, 'Help & FAQ',
                  () => context.push(AppRoutes.helpFaq)),
              _MenuItem(Icons.mail_outline, 'Contact Church',
                  () => context.push(AppRoutes.contactUs)),
              _MenuItem(Icons.church_outlined, 'About Church',
                  () => context.push(AppRoutes.aboutChurch)),
              _MenuItem(Icons.people_outline, 'Pastors & Leadership',
                  () => context.push(AppRoutes.pastors)),
              _MenuItem(Icons.location_on_outlined, 'Our Locations',
                  () => context.push(AppRoutes.campuses)),
              _MenuItem(Icons.shield_outlined, 'Privacy Policy', () {}),
              _MenuItem(Icons.description_outlined, 'Terms of Service', () {}),
            ], isDark),

            const SizedBox(height: AppSpacing.sp6),

            // ── Logout ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showLogoutSheet(context, isDark),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Log Out', style: AppTextStyles.labelLarge),
              ),
            ),

            const SizedBox(height: AppSpacing.sp8),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  Widget _stat(String value, String label, bool isDark) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: AppTextStyles.labelAllCaps.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _menuGroup(List<_MenuItem> items, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onTap,
              splashColor: isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.1)
                  : AppColors.skyLight,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
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
                child: Row(
                  children: [
                    Icon(item.icon,
                        size: 20,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sp3),
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16,
                        color: AppColors.textDisabled),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showLogoutSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sp4,
          AppSpacing.sp4,
          AppSpacing.sp4,
          AppSpacing.sp8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: AppRadius.borderRadiusFull,
              ),
            ),
            const SizedBox(height: AppSpacing.sp6),
            Text(
              'Are you sure you want to log out?',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sp6),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                label: 'Log Out',
                onPressed: () async {
                  await AuthService.instance.logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sp3),
            SizedBox(
              width: double.infinity,
              child: AppGhostButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── MenuItem data ───────────────────────────────────────────────────────────

class _MenuItem {
  const _MenuItem(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
