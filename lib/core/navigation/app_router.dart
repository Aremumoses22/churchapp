import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/church_code_screen.dart';
import '../../features/auth/create_new_password_screen.dart';
import '../../features/auth/email_verification_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/profile_setup_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/bible/bible_reader_screen.dart';
import '../../features/bible/daily_devotional_screen.dart';
import '../../features/bible/reading_plan_screen.dart';
import '../../features/church_info/about_church_screen.dart';
import '../../features/church_info/campuses_screen.dart';
import '../../features/church_info/contact_us_screen.dart';
import '../../features/church_info/help_faq_screen.dart';
import '../../features/church_info/pastors_screen.dart';
import '../../features/community/announcements_screen.dart';
import '../../features/community/church_directory_screen.dart';
import '../../features/community/connect_groups_screen.dart';
import '../../features/community/group_detail_screen.dart';
import '../../features/community/invite_friends_screen.dart';
import '../../features/community/testimonies_screen.dart';
import '../../features/media/photo_gallery_screen.dart';
import '../../features/media/podcast_feed_screen.dart';
import '../../features/media/worship_lyrics_screen.dart';
import '../../features/volunteering/kids_checkin_screen.dart';
import '../../features/volunteering/service_roster_screen.dart';
import '../../features/volunteering/volunteer_screen.dart';
import '../services/auth_service.dart';
import '../../features/events/event_detail_screen.dart';
import '../../features/events/events_screen.dart';
import '../../features/chat/chat_conversation_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/forum/create_post_screen.dart';
import '../../features/forum/forum_category_screen.dart';
import '../../features/forum/forum_screen.dart';
import '../../features/forum/forum_thread_screen.dart';
import '../../features/search/global_search_screen.dart';
import '../../features/giving/giving_campaign_screen.dart';
import '../../features/giving/giving_screen.dart';
import '../../features/giving/giving_success_screen.dart';
import '../../features/giving/paystack_checkout_screen.dart';
import '../../features/giving/pledge_screen.dart';
import '../../features/giving/receipt_detail_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/live_service_screen.dart';
import '../../features/notifications/notification_center_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/prayer/prayer_request_screen.dart';
import '../../features/profile/attendance_history_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/giving_history_screen.dart';
import '../../features/profile/manage_notifications_screen.dart';
import '../../features/profile/my_events_screen.dart';
import '../../features/profile/prayer_requests_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/saved_items_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/profile/spiritual_journey_screen.dart';
import '../../features/sermons/audio_player_screen.dart';
import '../../features/sermons/saved_sermons_screen.dart';
import '../../features/sermons/series_detail_screen.dart';
import '../../features/sermons/sermon_detail_screen.dart';
import '../../features/sermons/sermon_notes_screen.dart';
import '../../features/sermons/sermons_screen.dart';
import '../../features/sermons/video_player_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'app_routes.dart';
import 'main_shell.dart';
import 'page_transitions.dart';

// ──────────────────────────────────────────────────────────────────────────────
// APP ROUTER
//
// Full route tree per MOBILE_DESIGN_GUIDE § 5.1.
//
// Transition map (§ 5.2):
//   • Slide + Fade  → detail pages (push into a tab)
//   • Slide Up      → bottom sheets / prayer modal
//   • Fade          → tab switches (handled by StatefulShellRoute)
//   • Scale + Fade  → modals / alerts
//
// Deep-link support is built-in — every route has a unique path.
// ──────────────────────────────────────────────────────────────────────────────

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,

  // ── Auth redirect ─────────────────────────────────────────────────────────
  redirect: (context, state) {
    final auth = AuthService.instance;
    final location = state.matchedLocation;

    // Allow splash to load (it handles its own navigation).
    if (location == AppRoutes.splash) return null;

    // Public routes that don't require auth.
    const publicRoutes = [
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.createNewPassword,
      AppRoutes.emailVerification,
    ];
    final isPublic = publicRoutes.contains(location);

    // First-time user hasn't seen onboarding.
    if (auth.state == AuthState.firstLaunch && location != AppRoutes.onboarding) {
      return AppRoutes.onboarding;
    }

    // Not logged in → send to login (unless already on a public route).
    if (auth.state == AuthState.unauthenticated && !isPublic) {
      return AppRoutes.login;
    }

    // Logged in but needs setup → send to church-code.
    if (auth.state == AuthState.needsSetup &&
        !isPublic &&
        location != AppRoutes.churchCode &&
        location != AppRoutes.profileSetup) {
      return AppRoutes.churchCode;
    }

    // Fully authenticated user trying to visit auth pages → send to home.
    if (auth.state == AuthState.authenticated && isPublic) {
      return AppRoutes.home;
    }

    return null;
  },

  routes: [
    // ── Top-level routes (no bottom nav) ───────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        name: 'splash',
        child: const SplashScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        name: 'onboarding',
        child: const OnboardingScreen(),
      ),
    ),

    // ── Auth routes ────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'login',
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'register',
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.emailVerification,
      name: 'email-verification',
      pageBuilder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return slideFadePage(
          key: state.pageKey,
          name: 'email-verification',
          child: EmailVerificationScreen(email: email),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.churchCode,
      name: 'church-code',
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'church-code',
        child: const ChurchCodeScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgot-password',
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'forgot-password',
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.createNewPassword,
      name: 'create-new-password',
      pageBuilder: (context, state) {
        final token = state.uri.queryParameters['token'];
        return slideFadePage(
          key: state.pageKey,
          name: 'create-new-password',
          child: CreateNewPasswordScreen(token: token),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.profileSetup,
      name: 'profile-setup',
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'profile-setup',
        child: const ProfileSetupScreen(),
      ),
    ),

    // ── Main app shell (bottom nav) ────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              pageBuilder: (context, state) => fadePage(
                key: state.pageKey,
                name: 'home',
                child: const HomeScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'live',
                  name: 'live',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'live',
                    child: const LiveServiceScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Tab 1 — Sermons
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.sermons,
              name: 'sermons',
              pageBuilder: (context, state) => fadePage(
                key: state.pageKey,
                name: 'sermons',
                child: const SermonsScreen(),
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'sermon-detail',
                  pageBuilder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return slideFadePage(
                      key: state.pageKey,
                      name: 'sermon-detail',
                      child: SermonDetailScreen(sermonId: id),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/series/:id',
              name: 'series-detail',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                return slideFadePage(
                  key: state.pageKey,
                  name: 'series-detail',
                  child: SeriesDetailScreen(seriesId: id),
                );
              },
            ),
          ],
        ),

        // Tab 2 — Events
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.events,
              name: 'events',
              pageBuilder: (context, state) => fadePage(
                key: state.pageKey,
                name: 'events',
                child: const EventsScreen(),
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'event-detail',
                  pageBuilder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return slideFadePage(
                      key: state.pageKey,
                      name: 'event-detail',
                      child: EventDetailScreen(eventId: id),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // Tab 3 — Giving
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.giving,
              name: 'giving',
              pageBuilder: (context, state) => fadePage(
                key: state.pageKey,
                name: 'giving',
                child: const GivingScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'checkout',
                  name: 'giving-checkout',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'giving-checkout',
                    child: PaystackCheckoutScreen(
                      amount: int.tryParse(
                              state.uri.queryParameters['amount'] ?? '') ??
                          0,
                      categoryId:
                          state.uri.queryParameters['categoryId'] ?? '',
                      categoryName:
                          state.uri.queryParameters['categoryName'] ?? '',
                      paymentMethod:
                          state.uri.queryParameters['method'] ?? 'CARD',
                    ),
                  ),
                ),
                GoRoute(
                  path: 'success',
                  name: 'giving-success',
                  pageBuilder: (context, state) => scaleFadePage(
                    key: state.pageKey,
                    name: 'giving-success',
                    child: GivingSuccessScreen(
                      amount: double.tryParse(
                          state.uri.queryParameters['amount'] ?? ''),
                      reference: state.uri.queryParameters['ref'],
                      category: state.uri.queryParameters['category'],
                    ),
                  ),
                ),
                GoRoute(
                  path: 'campaign',
                  name: 'giving-campaign',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'giving-campaign',
                    child: GivingCampaignScreen(
                      campaignId: state.uri.queryParameters['id'],
                    ),
                  ),
                ),
                GoRoute(
                  path: 'pledge',
                  name: 'pledge',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'pledge',
                    child: PledgeScreen(
                      campaignId: state.uri.queryParameters['id'],
                    ),
                  ),
                ),
                GoRoute(
                  path: 'receipt',
                  name: 'receipt-detail',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'receipt-detail',
                    child: ReceiptDetailScreen(
                      receiptId: state.uri.queryParameters['id'],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Tab 4 — Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              pageBuilder: (context, state) => fadePage(
                key: state.pageKey,
                name: 'profile',
                child: const ProfileScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'giving-history',
                  name: 'giving-history',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'giving-history',
                    child: const GivingHistoryScreen(),
                  ),
                ),
                GoRoute(
                  path: 'my-events',
                  name: 'my-events',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'my-events',
                    child: const MyEventsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'prayer-requests',
                  name: 'prayer-requests',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'prayer-requests',
                    child: const PrayerRequestsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'settings',
                  name: 'settings',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'settings',
                    child: const SettingsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'saved-sermons',
                  name: 'saved-sermons',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'saved-sermons',
                    child: const SavedSermonsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'edit-profile',
                  name: 'edit-profile',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'edit-profile',
                    child: const EditProfileScreen(),
                  ),
                ),
                GoRoute(
                  path: 'manage-notifications',
                  name: 'manage-notifications',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'manage-notifications',
                    child: const ManageNotificationsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'saved-items',
                  name: 'saved-items',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'saved-items',
                    child: const SavedItemsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'spiritual-journey',
                  name: 'spiritual-journey',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'spiritual-journey',
                    child: const SpiritualJourneyScreen(),
                  ),
                ),
                GoRoute(
                  path: 'attendance-history',
                  name: 'attendance-history',
                  pageBuilder: (context, state) => slideFadePage(
                    key: state.pageKey,
                    name: 'attendance-history',
                    child: const AttendanceHistoryScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ── Overlay routes (appear on top of any tab) ──────────────────────────
    GoRoute(
      path: AppRoutes.prayerRequest,
      name: 'prayer-request',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideUpPage(
        key: state.pageKey,
        name: 'prayer-request',
        child: const PrayerRequestScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.notificationCenter,
      name: 'notification-center',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'notification-center',
        child: const NotificationCenterScreen(),
      ),
    ),

    // ── Bible & Devotional routes ──────────────────────────────────────────
    GoRoute(
      path: AppRoutes.bible,
      name: 'bible',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'bible',
        child: const BibleReaderScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.devotional,
      name: 'devotional',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'devotional',
        child: const DailyDevotionalScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.readingPlan,
      name: 'reading-plan',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'reading-plan',
        child: const ReadingPlanScreen(),
      ),
    ),

    // ── Sermon extras routes ───────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.sermonNotes,
      name: 'sermon-notes',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final title = state.uri.queryParameters['title'];
        final speaker = state.uri.queryParameters['speaker'];
        final date = state.uri.queryParameters['date'];
        final id = state.uri.queryParameters['id'];
        return slideFadePage(
          key: state.pageKey,
          name: 'sermon-notes',
          child: SermonNotesScreen(
            sermonId: id,
            sermonTitle: title,
            sermonSpeaker: speaker,
            sermonDate: date,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.audioPlayer,
      name: 'audio-player',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final title = state.uri.queryParameters['title'];
        final speaker = state.uri.queryParameters['speaker'];
        final series = state.uri.queryParameters['series'];
        final id = state.uri.queryParameters['id'];
        return slideUpPage(
          key: state.pageKey,
          name: 'audio-player',
          child: AudioPlayerScreen(
            sermonId: id,
            sermonTitle: title,
            sermonSpeaker: speaker,
            sermonSeries: series,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.videoPlayer,
      name: 'video-player',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final title = state.uri.queryParameters['title'];
        final speaker = state.uri.queryParameters['speaker'];
        final id = state.uri.queryParameters['id'];
        return fadePage(
          key: state.pageKey,
          name: 'video-player',
          child: VideoPlayerScreen(
            sermonId: id,
            sermonTitle: title,
            sermonSpeaker: speaker,
          ),
        );
      },
    ),

    // ── Community & Connection ─────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.announcements,
      name: 'announcements',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'announcements',
        child: const AnnouncementsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.connectGroups,
      name: 'connect-groups',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'connect-groups',
        child: const ConnectGroupsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.groupDetail,
      name: 'group-detail',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return slideFadePage(
          key: state.pageKey,
          name: 'group-detail',
          child: GroupDetailScreen(groupId: id),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.testimonies,
      name: 'testimonies',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'testimonies',
        child: const TestimoniesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.churchDirectory,
      name: 'church-directory',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'church-directory',
        child: const ChurchDirectoryScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.inviteFriends,
      name: 'invite-friends',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'invite-friends',
        child: const InviteFriendsScreen(),
      ),
    ),

    // ── Forum ──────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.forum,
      name: 'forum',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'forum',
        child: const ForumScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.forumCategory,
      name: 'forum-category',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return slideFadePage(
          key: state.pageKey,
          name: 'forum-category',
          child: ForumCategoryScreen(categoryId: id),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.forumThread,
      name: 'forum-thread',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return slideFadePage(
          key: state.pageKey,
          name: 'forum-thread',
          child: ForumThreadScreen(threadId: id),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.forumCreatePost,
      name: 'forum-create-post',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return slideFadePage(
          key: state.pageKey,
          name: 'forum-create-post',
          child: CreatePostScreen(preselectedCategory: category),
        );
      },
    ),

    // ── Search ──────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.globalSearch,
      name: 'global-search',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => fadePage(
        key: state.pageKey,
        name: 'global-search',
        child: const GlobalSearchScreen(),
      ),
    ),

    // ── Chat / Messaging ───────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.chatList,
      name: 'chat-list',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'chat-list',
        child: const ChatListScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.chatConversation,
      name: 'chat-conversation',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        final name = state.uri.queryParameters['name'];
        return slideFadePage(
          key: state.pageKey,
          name: 'chat-conversation',
          child: ChatConversationScreen(chatId: id, chatName: name),
        );
      },
    ),

    // ── Church Info ────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.aboutChurch,
      name: 'about-church',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'about-church',
        child: const AboutChurchScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.pastors,
      name: 'pastors',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'pastors',
        child: const PastorsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.campuses,
      name: 'campuses',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'campuses',
        child: const CampusesScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.contactUs,
      name: 'contact-us',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'contact-us',
        child: const ContactUsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.helpFaq,
      name: 'help-faq',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'help-faq',
        child: const HelpFaqScreen(),
      ),
    ),

    // ── Volunteering & Service ────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.volunteer,
      name: 'volunteer',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'volunteer',
        child: const VolunteerScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.serviceRoster,
      name: 'service-roster',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'service-roster',
        child: const ServiceRosterScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.kidsCheckin,
      name: 'kids-checkin',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'kids-checkin',
        child: const KidsCheckinScreen(),
      ),
    ),

    // ── Content & Media ──────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.photoGallery,
      name: 'photo-gallery',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'photo-gallery',
        child: const PhotoGalleryScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.worshipLyrics,
      name: 'worship-lyrics',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'worship-lyrics',
        child: const WorshipLyricsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.podcastFeed,
      name: 'podcast-feed',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => slideFadePage(
        key: state.pageKey,
        name: 'podcast-feed',
        child: const PodcastFeedScreen(),
      ),
    ),
  ],
);
