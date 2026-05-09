import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// HOME SCREEN — § 7  (Enhanced)
//
// Layout (top → bottom):
//   0. Live service banner (pulsing red, conditionally shown)
//   1. Hero header — weather-aware greeting with fade-in name & waving hand
//   2. Story-style highlight circles (horizontal scroll)
//   3. Today's verse card (fade-in animation)
//   4. Campaign progress card (if active)
//   5. Quick-access 2×2 grid (stagger animation)
//   6. Upcoming events (horizontal scroll)
//   7. Latest sermon row card
//   8. Community & More / Service & Media rows
// ──────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final AnimationController _greetingController;
  late final AnimationController _wavingHandController;
  late final AnimationController _livePulseController;

  late final Animation<double> _greetingFade;
  late final Animation<Offset> _greetingSlide;
  late final Animation<double> _handRotation;
  late final Animation<double> _livePulse;

  bool _isServiceLive = true; // mock: service is live
  bool _liveBannerDismissed = false;
  static const bool _hasCampaign = true; // mock: active campaign

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // Greeting fade-in
    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _greetingFade = CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeOut,
    );
    _greetingSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeOut,
    ));

    // Waving hand (repeat 3 times)
    _wavingHandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _handRotation = Tween<double>(begin: 0, end: 0.2).animate(
      CurvedAnimation(parent: _wavingHandController, curve: Curves.easeInOut),
    );

    // Live pulse
    _livePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _livePulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _livePulseController, curve: Curves.easeInOut),
    );

    // Stagger the greeting after a frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _greetingController.forward();
      _waveHand();
    });
  }

  Future<void> _waveHand() async {
    for (var i = 0; i < 3; i++) {
      await _wavingHandController.forward();
      await _wavingHandController.reverse();
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _greetingController.dispose();
    _wavingHandController.dispose();
    _livePulseController.dispose();
    super.dispose();
  }

  String get _weatherGreeting {
    final hour = DateTime.now().hour;
    // Mock weather — cycle through conditions for demo
    const conditions = ['clear', 'rainy', 'cloudy'];
    final condition = conditions[DateTime.now().day % conditions.length];

    String timeWord;
    if (hour < 12) {
      timeWord = 'morning';
    } else if (hour < 17) {
      timeWord = 'afternoon';
    } else {
      timeWord = 'evening';
    }

    switch (condition) {
      case 'rainy':
        return 'Blessed rainy $timeWord';
      case 'cloudy':
        return 'Blessed cloudy $timeWord';
      default:
        return 'Blessed $timeWord';
    }
  }

  String get _weatherCondition {
    const conditions = ['clear', 'rainy', 'cloudy'];
    return conditions[DateTime.now().day % conditions.length];
  }

  String get _dateString {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = AuthService.instance.userName ?? 'Friend';

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: CustomScrollView(
        slivers: [
          // ── 0. Live Service Banner ────────────────────────────────────
          if (_isServiceLive && !_liveBannerDismissed)
            SliverToBoxAdapter(
              child: _LiveBanner(
                pulseAnim: _livePulse,
                onTap: () {
                  setState(() => _liveBannerDismissed = true);
                  context.push(AppRoutes.live);
                },
                onDismiss: () =>
                    setState(() => _liveBannerDismissed = true),
              ),
            ),

          // ── 1. Hero Header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroHeader(
              greeting: _weatherGreeting,
              userName: userName,
              dateString: _dateString,
              isDark: isDark,
              weatherCondition: _weatherCondition,
              greetingFade: _greetingFade,
              greetingSlide: _greetingSlide,
              handRotation: _handRotation,
              onNotificationTap: () =>
                  context.push(AppRoutes.notificationCenter),
            ),
          ),

          // ── 2. Story-style Highlight Circles ──────────────────────────
          SliverToBoxAdapter(
            child: _HighlightStories(isDark: isDark),
          ),

          // ── 3. Today's verse ──────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: AppSpacing.sp4),
              child: AppVerseCard(
                reference: 'Psalm 46:10',
                verseText:
                    '"Be still, and know that I am God; I will be exalted among the nations, I will be exalted in the earth."',
              ),
            ),
          ),

          // ── 4. Campaign Progress Card ─────────────────────────────────
          if (_hasCampaign)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sp4),
                child: _CampaignProgressCard(
                  isDark: isDark,
                  onTap: () => context.push(AppRoutes.givingCampaign),
                ),
              ),
            ),

          // ── 5. Quick Access Grid ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sp6),
              child: AppSectionHeader(
                title: 'Quick Access',
                onAction: () {},
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sp4,
              vertical: AppSpacing.sp4,
            ),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sp3,
              crossAxisSpacing: AppSpacing.sp3,
              childAspectRatio: 1.15,
              children: [
                _StaggerItem(
                  controller: _staggerController,
                  delay: 0.0,
                  child: AppQuickAccessCard(
                    label: 'Watch Live',
                    icon: Icons.play_circle_outlined,
                    subLabel: 'Sunday 10:00 AM',
                    isLive: true,
                    onTap: () => context.push(AppRoutes.live),
                  ),
                ),
                _StaggerItem(
                  controller: _staggerController,
                  delay: 0.1,
                  child: AppQuickAccessCard(
                    label: 'Latest Sermon',
                    icon: Icons.headphones_outlined,
                    subLabel: 'The Power of Faith',
                    onTap: () => context.push('/sermons/1'),
                  ),
                ),
                _StaggerItem(
                  controller: _staggerController,
                  delay: 0.2,
                  child: AppQuickAccessCard(
                    label: 'Next Event',
                    icon: Icons.calendar_today_outlined,
                    subLabel: 'Youth Night — Feb 28',
                    onTap: () => context.push('/events/1'),
                  ),
                ),
                _StaggerItem(
                  controller: _staggerController,
                  delay: 0.3,
                  child: AppQuickAccessCard(
                    label: 'Daily Devotional',
                    icon: Icons.menu_book_outlined,
                    subLabel: 'Day 54 of 365',
                    onTap: () => context.push(AppRoutes.devotional),
                  ),
                ),
              ],
            ),
          ),

          // ── 6. Upcoming Events (horizontal scroll) ────────────────────
          SliverToBoxAdapter(
            child: AppSectionHeader(
              title: 'Upcoming Events',
              actionLabel: 'See all',
              onAction: () => context.go(AppRoutes.events),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 212,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4,
                  vertical: AppSpacing.sp3,
                ),
                children: [
                  AppEventCard(
                    title: 'Youth Night',
                    date: 'Feb 28',
                    location: 'Main Campus',
                    imageUrl: 'https://picsum.photos/seed/youth_night/440/240',
                    width: 220,
                    onTap: () => context.push('/events/1'),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  AppEventCard(
                    title: 'Women Conference',
                    date: 'Mar 8',
                    location: 'Fellowship Hall',
                    imageUrl: 'https://picsum.photos/seed/women_conf/440/240',
                    width: 220,
                    onTap: () => context.push('/events/2'),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  AppEventCard(
                    title: 'Easter Celebration',
                    date: 'Apr 5',
                    location: 'Church Grounds',
                    imageUrl: 'https://picsum.photos/seed/easter_cel/440/240',
                    width: 220,
                    onTap: () => context.push('/events/3'),
                  ),
                ],
              ),
            ),
          ),

          // ── 7. Latest Sermon ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sp3),
              child: AppSectionHeader(
                title: 'Latest Message',
                actionLabel: 'All Sermons',
                onAction: () => context.go(AppRoutes.sermons),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp4,
                vertical: AppSpacing.sp3,
              ),
              child: AppFeatureCard(
                title: 'The Power of Faith',
                subtitle: 'Pastor James · 42 min',
                thumbnailUrl: 'https://picsum.photos/seed/sermon_home/160/160',
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: AppColors.textInverse, size: 20),
                ),
                onTap: () => context.push('/sermons/1'),
              ),
            ),
          ),

          // ── 8. Community & Explore ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sp3),
              child: AppSectionHeader(
                title: 'Community & More',
                actionLabel: '',
                onAction: () {},
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4,
                  vertical: AppSpacing.sp3,
                ),
                children: [
                  _CommunityChip(
                    icon: Icons.forum_outlined,
                    label: 'Community\nForum',
                    color: const Color(0xFF6366F1),
                    onTap: () => context.push(AppRoutes.forum),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.chat_outlined,
                    label: 'Messages',
                    color: const Color(0xFF0EA5E9),
                    onTap: () => context.push(AppRoutes.chatList),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.campaign_outlined,
                    label: 'Announcements',
                    color: const Color(0xFFEF4444),
                    onTap: () => context.push(AppRoutes.announcements),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.groups_outlined,
                    label: 'Connect\nGroups',
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.push(AppRoutes.connectGroups),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.format_quote_outlined,
                    label: 'Testimonies',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => context.push(AppRoutes.testimonies),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.people_outline,
                    label: 'Church\nDirectory',
                    color: const Color(0xFF059669),
                    onTap: () => context.push(AppRoutes.churchDirectory),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.church_outlined,
                    label: 'About\nChurch',
                    color: const Color(0xFF1E40AF),
                    onTap: () => context.push(AppRoutes.aboutChurch),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.share_outlined,
                    label: 'Invite\nFriends',
                    color: const Color(0xFFF59E0B),
                    onTap: () => context.push(AppRoutes.inviteFriends),
                  ),
                ],
              ),
            ),
          ),

          // ── Service & Media ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sp1),
              child: AppSectionHeader(
                title: 'Service & Media',
                actionLabel: '',
                onAction: () {},
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4,
                  vertical: AppSpacing.sp3,
                ),
                children: [
                  _CommunityChip(
                    icon: Icons.volunteer_activism_outlined,
                    label: 'Volunteer',
                    color: const Color(0xFF10B981),
                    onTap: () => context.push(AppRoutes.volunteer),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.calendar_month_outlined,
                    label: 'My Roster',
                    color: const Color(0xFF2563EB),
                    onTap: () => context.push(AppRoutes.serviceRoster),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.child_care_outlined,
                    label: 'Kids\nCheck-In',
                    color: const Color(0xFFEC4899),
                    onTap: () => context.push(AppRoutes.kidsCheckin),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.photo_library_outlined,
                    label: 'Photo\nGallery',
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.push(AppRoutes.photoGallery),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.lyrics_outlined,
                    label: 'Worship\nLyrics',
                    color: const Color(0xFFF59E0B),
                    onTap: () => context.push(AppRoutes.worshipLyrics),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _CommunityChip(
                    icon: Icons.podcasts_outlined,
                    label: 'Podcast',
                    color: const Color(0xFFDC2626),
                    onTap: () => context.push(AppRoutes.podcastFeed),
                  ),
                ],
              ),
            ),
          ),

          // Bottom clearance
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.sp12),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LIVE SERVICE BANNER — Pulsing red banner
// ═══════════════════════════════════════════════════════════════════════════════

class _LiveBanner extends StatelessWidget {
  const _LiveBanner({
    required this.pulseAnim,
    required this.onTap,
    required this.onDismiss,
  });

  final Animation<double> pulseAnim;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, child) {
        return Container(
          color: Color.lerp(
            const Color(0xFFDC2626),
            const Color(0xFFEF4444),
            pulseAnim.value,
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4, vertical: AppSpacing.sp2),
              child: Row(
                children: [
                  // Pulsing dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: pulseAnim.value),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(
                              alpha: pulseAnim.value * 0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp2),
                  Expanded(
                    child: GestureDetector(
                      onTap: onTap,
                      child: Text(
                        'Sunday Service is LIVE  \u2192',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onDismiss,
                    child: const Icon(Icons.close,
                        size: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HERO HEADER — Weather-aware greeting with animated name & waving hand
// ═══════════════════════════════════════════════════════════════════════════════

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.greeting,
    required this.userName,
    required this.dateString,
    required this.isDark,
    required this.weatherCondition,
    required this.greetingFade,
    required this.greetingSlide,
    required this.handRotation,
    required this.onNotificationTap,
  });

  final String greeting;
  final String userName;
  final String dateString;
  final bool isDark;
  final String weatherCondition;
  final Animation<double> greetingFade;
  final Animation<Offset> greetingSlide;
  final Animation<double> handRotation;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.heroDark : AppGradients.hero,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Weather particles overlay
          if (weatherCondition == 'rainy')
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: CustomPaint(
                  painter: _RainParticlePainter(),
                ),
              ),
            ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // App bar row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp4,
                    vertical: AppSpacing.sp2,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.church_outlined,
                          color: AppColors.textInverse, size: 28),
                      const Spacer(),
                      AppTapAnimation(
                        onTap: () => context.push(AppRoutes.globalSearch),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Icon(Icons.search,
                                color: AppColors.textInverse, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp1),
                      AppTapAnimation(
                        onTap: onNotificationTap,
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Icon(Icons.notifications_outlined,
                                color: AppColors.textInverse, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp2),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight,
                          border: Border.all(
                              color: AppColors.textInverse, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Animated greeting
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sp6,
                    AppSpacing.sp4,
                    AppSpacing.sp6,
                    AppSpacing.sp8,
                  ),
                  child: FadeTransition(
                    opacity: greetingFade,
                    child: SlideTransition(
                      position: greetingSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '$greeting, $userName',
                                  style: AppTextStyles.headingLarge
                                      .copyWith(color: AppColors.textInverse),
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedBuilder(
                                animation: handRotation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: handRotation.value *
                                        math.sin(handRotation.value * math.pi),
                                    child: child,
                                  );
                                },
                                child: const Text('\u{1F44B}',
                                    style: TextStyle(fontSize: 24)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sp1),
                          Row(
                            children: [
                              if (weatherCondition == 'rainy')
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Text('\u{1F327}\u{FE0F}',
                                      style: TextStyle(fontSize: 14)),
                                )
                              else if (weatherCondition == 'cloudy')
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Text('\u{26C5}',
                                      style: TextStyle(fontSize: 14)),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Text('\u{2600}\u{FE0F}',
                                      style: TextStyle(fontSize: 14)),
                                ),
                              Text(
                                dateString,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textInverse
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sp3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: AppRadius.borderRadiusFull,
                            ),
                            child: Text(
                              'Grace Community Church',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RAIN PARTICLE PAINTER — subtle diagonal rain lines
// ═══════════════════════════════════════════════════════════════════════════════

class _RainParticlePainter extends CustomPainter {
  final _random = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 40; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 4, y + 12),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// STORY-STYLE HIGHLIGHT CIRCLES
// ═══════════════════════════════════════════════════════════════════════════════

class _HighlightStories extends StatefulWidget {
  const _HighlightStories({required this.isDark});
  final bool isDark;

  @override
  State<_HighlightStories> createState() => _HighlightStoriesState();
}

class _HighlightStoriesState extends State<_HighlightStories> {
  final _viewed = <int>{};

  static const _stories = [
    _StoryData(
      '\u{1F3B5}',
      'Worship\nNight',
      Color(0xFF8B5CF6),
      'Last Friday we had an incredible night of worship. Over 200 people gathered to lift their voices!',
      'Feb 21, 2026',
      AppRoutes.worshipLyrics,
    ),
    _StoryData(
      '\u{1F4D6}',
      'Bible\nStudy',
      Color(0xFF3B82F6),
      'Join us every Wednesday as we dive deeper into the book of Romans this month.',
      'Every Wednesday',
      AppRoutes.bible,
    ),
    _StoryData(
      '\u{1F64F}',
      'Prayer\nWalk',
      Color(0xFF10B981),
      'Our community prayer walk through the city brought together 50 faithful intercessors.',
      'Feb 18, 2026',
      AppRoutes.prayerRequests,
    ),
    _StoryData(
      '\u{1F476}',
      'Kids\nSunday',
      Color(0xFFEC4899),
      'The children put on an amazing presentation! Check out the highlights from Kids Sunday.',
      'Every Sunday',
      AppRoutes.kidsCheckin,
    ),
    _StoryData(
      '\u{1F3A4}',
      'Guest\nSpeaker',
      Color(0xFFF59E0B),
      'Bishop Thomas delivered a powerful message on "Building Strong Foundations" last Sunday.',
      'Feb 16, 2026',
      '/sermons/4',
    ),
    _StoryData(
      '\u{2764}\u{FE0F}',
      'Outreach\nDay',
      Color(0xFFEF4444),
      'We served over 300 meals and distributed clothing to families in need across the city.',
      'Feb 15, 2026',
      AppRoutes.volunteer,
    ),
    _StoryData(
      '\u{1F3B6}',
      'Choir\nSpecial',
      Color(0xFF6366F1),
      'Our choir performed a special Easter cantata rehearsal preview. Full performance on Easter Sunday!',
      'Feb 14, 2026',
      AppRoutes.photoGallery,
    ),
  ];

  void _openStory(int index) {
    setState(() => _viewed.add(index));
    final isDark = widget.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StoryViewer(
        stories: _stories,
        initialIndex: index,
        isDark: isDark,
        onClose: () => Navigator.pop(ctx),
        onNavigate: (route) {
          Navigator.pop(ctx);
          context.push(route);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp4, AppSpacing.sp4, AppSpacing.sp4, 0),
        itemCount: _stories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sp3),
        itemBuilder: (_, index) {
          final s = _stories[index];
          return _StoryCircle(
            story: s,
            isDark: widget.isDark,
            isViewed: _viewed.contains(index),
            onTap: () => _openStory(index),
          );
        },
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  const _StoryCircle({
    required this.story,
    required this.isDark,
    required this.isViewed,
    required this.onTap,
  });
  final _StoryData story;
  final bool isDark;
  final bool isViewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isViewed
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          story.color,
                          story.color.withValues(alpha: 0.5),
                        ],
                      ),
                color: isViewed
                    ? (isDark
                        ? AppColors.borderDark
                        : AppColors.inputBorder)
                    : null,
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.cardDark : AppColors.surface,
                ),
                child: Center(
                  child:
                      Text(story.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              story.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 9,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STORY VIEWER — full-screen modal with swipe navigation
// ═══════════════════════════════════════════════════════════════════════════════

class _StoryViewer extends StatefulWidget {
  const _StoryViewer({
    required this.stories,
    required this.initialIndex,
    required this.isDark,
    required this.onClose,
    required this.onNavigate,
  });

  final List<_StoryData> stories;
  final int initialIndex;
  final bool isDark;
  final VoidCallback onClose;
  final ValueChanged<String> onNavigate;

  @override
  State<_StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<_StoryViewer>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _progressController.forward(from: 0.0);
    } else {
      widget.onClose();
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _progressController.forward(from: 0.0);
    } else {
      _progressController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            story.color,
            story.color.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: AppRadius.borderRadiusFull,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Progress indicators
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
              child: Row(
                children: List.generate(widget.stories.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 2),
                      child: ClipRRect(
                        borderRadius: AppRadius.borderRadiusFull,
                        child: SizedBox(
                          height: 3,
                          child: i < _currentIndex
                              ? Container(color: Colors.white)
                              : i == _currentIndex
                                  ? AnimatedBuilder(
                                      animation: _progressController,
                                      builder: (_, _) =>
                                          LinearProgressIndicator(
                                        value:
                                            _progressController.value,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.3),
                                        color: Colors.white,
                                        minHeight: 3,
                                      ),
                                    )
                                  : Container(
                                      color: Colors.white
                                          .withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),

            // Header row (emoji + title + close)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.sp5),
              child: Row(
                children: [
                  Text(story.emoji,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: AppSpacing.sp3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.label.replaceAll('\n', ' '),
                          style: AppTextStyles.headingSmall
                              .copyWith(color: Colors.white),
                        ),
                        Text(
                          story.dateLabel,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // Tap zones for prev/next
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final width = MediaQuery.of(context).size.width;
                  if (details.globalPosition.dx < width * 0.3) {
                    _prevStory();
                  } else {
                    _nextStory();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp5,
                      vertical: AppSpacing.sp6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Story content
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(AppSpacing.sp5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppRadius.borderRadiusXl,
                          border: Border.all(
                              color: Colors.white
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          story.description,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Spacer(),

                      // Tap hint
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          if (_currentIndex > 0)
                            Icon(Icons.chevron_left,
                                size: 16,
                                color: Colors.white
                                    .withValues(alpha: 0.5)),
                          Text(
                            _currentIndex < widget.stories.length - 1
                                ? 'Tap right for next \u00b7 Tap left for previous'
                                : 'Tap to close',
                            style:
                                AppTextStyles.bodySmall.copyWith(
                              color: Colors.white
                                  .withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          ),
                          if (_currentIndex <
                              widget.stories.length - 1)
                            Icon(Icons.chevron_right,
                                size: 16,
                                color: Colors.white
                                    .withValues(alpha: 0.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // CTA button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp5, 0, AppSpacing.sp5, AppSpacing.sp5),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      widget.onNavigate(story.route),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.25),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusFull,
                      side: BorderSide(
                          color: Colors.white
                              .withValues(alpha: 0.4)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Open ${story.label.replaceAll('\n', ' ')}',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryData {
  const _StoryData(
    this.emoji,
    this.label,
    this.color,
    this.description,
    this.dateLabel,
    this.route,
  );
  final String emoji;
  final String label;
  final Color color;
  final String description;
  final String dateLabel;
  final String route;
}

// ═══════════════════════════════════════════════════════════════════════════════
// CAMPAIGN PROGRESS CARD — compact card with progress bar
// ═══════════════════════════════════════════════════════════════════════════════

class _CampaignProgressCard extends StatelessWidget {
  const _CampaignProgressCard({
    required this.isDark,
    required this.onTap,
  });

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const raised = 187500.0;
    const goal = 250000.0;
    const progress = raised / goal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
      child: AppTapAnimation(
        onTap: onTap,
        liftEffect: true,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sp4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surface,
            borderRadius: AppRadius.borderRadiusXl,
            boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Center(
                  child: Text('\u{1F3D7}\u{FE0F}',
                      style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Youth Center',
                        style: AppTextStyles.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    // Progress bar
                    ClipRRect(
                      borderRadius: AppRadius.borderRadiusFull,
                      child: SizedBox(
                        height: 6,
                        child: Stack(
                          children: [
                            Container(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.inputFill),
                            FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    AppColors.success,
                                    AppColors.gold,
                                  ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}% funded  \u00b7  43 days left',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sp2),
              Icon(Icons.chevron_right,
                  size: 18,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STAGGER ANIMATION WRAPPER
// ═══════════════════════════════════════════════════════════════════════════════

class _StaggerItem extends StatelessWidget {
  const _StaggerItem({
    required this.controller,
    required this.delay,
    required this.child,
  });

  final AnimationController controller;
  final double delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.4).clamp(0.0, 1.0);

    final opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, end, curve: Curves.easeOut),
      ),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, end, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMMUNITY CHIP — for horizontal scroll sections
// ═══════════════════════════════════════════════════════════════════════════════

class _CommunityChip extends StatelessWidget {
  const _CommunityChip({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTapAnimation(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Center(
                child: Icon(icon, color: color, size: 26),
              ),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 11,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
