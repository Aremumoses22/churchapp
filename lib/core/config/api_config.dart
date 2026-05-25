// ──────────────────────────────────────────────────────────────────────────────
// API CONFIGURATION
//
// Central place for base URL and endpoint paths.
// Matches the backend running at http://localhost:8080/api/v1.
// ──────────────────────────────────────────────────────────────────────────────

abstract final class ApiConfig {
  /// Physical device: use your Mac's LAN IP (e.g. 192.168.3.31).
  /// iOS simulator / macOS: use localhost.
  /// Android emulator: use 10.0.2.2.
  static const String baseUrl = 'http://192.168.3.31:8080/api/v1';

  /// WebSocket URL (Socket.io).
  static const String wsUrl = 'ws://192.168.3.31:8080';

  /// Request timeout durations.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}

/// Centralised endpoint paths — no raw strings scattered in code.
abstract final class Endpoints {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyEmail = '/auth/verify-email'; // + /:token
  static const String resendVerification = '/auth/resend-verification';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String verifyChurchCode = '/auth/verify-church-code';
  static const String completeSetup = '/auth/complete-setup';
  static const String logout = '/auth/logout';
  static const String deleteAccount = '/auth/account';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const String userProfile = '/users/me';
  static const String userAvatar = '/users/me/avatar';
  static const String notificationPrefs = '/users/me/notification-prefs';
  static const String fcmToken = '/users/me/fcm-token';
  static const String attendance = '/users/me/attendance';
  static const String milestones = '/users/me/milestones';
  static const String savedItems = '/users/me/saved-items';
  /// DELETE /users/me/saved-items/:id
  static String savedItem(String id) => '/users/me/saved-items/$id';

  // ── Sermons ───────────────────────────────────────────────────────────────
  static const String sermons = '/sermons';
  static const String sermonsFeatured = '/sermons/featured';
  static const String sermonsSaved = '/sermons/saved';
  static const String sermonSeriesAll = '/sermons/series/all';
  /// GET /sermons/:id
  static String sermon(String id) => '/sermons/$id';
  /// GET /sermons/:id/stream
  static String sermonStream(String id) => '/sermons/$id/stream';
  /// POST /sermons/:id/progress
  static String sermonProgress(String id) => '/sermons/$id/progress';
  /// POST /sermons/:id/save (toggle bookmark)
  static String sermonSave(String id) => '/sermons/$id/save';
  /// GET / PUT /sermons/:id/notes
  static String sermonNotes(String id) => '/sermons/$id/notes';
  /// GET /sermons/series/:id
  static String sermonSeries(String id) => '/sermons/series/$id';

  // ── Events ────────────────────────────────────────────────────────────────
  static const String events = '/events';
  static const String eventsFeatured = '/events/featured';
  static const String eventsMy = '/events/my';
  static String event(String id) => '/events/$id';
  static String eventRegister(String id) => '/events/$id/register';

  // ── Church Info ───────────────────────────────────────────────────────────
  static const String churchAbout = '/church/about';
  static const String churchStaff = '/church/staff';
  static const String churchCampuses = '/church/campuses';
  static const String churchFaqs = '/church/faqs';
  static const String churchContact = '/church/contact';

  // ── Home Feed ─────────────────────────────────────────────────────────────
  static const String homeFeed = '/home/feed';

  // ── Giving ────────────────────────────────────────────────────────────────
  static const String givingCategories = '/giving/categories';
  static const String givingSummary = '/giving/summary';
  static const String givingDonate = '/giving/donate';
  static const String givingVerify = '/giving/verify';
  static const String givingHistory = '/giving/history';
  static const String givingPaymentMethods = '/giving/payment-methods';
  static const String givingCampaigns = '/giving/campaigns';
  static const String givingPledges = '/giving/pledges';
  static const String givingRecurring = '/giving/recurring';
  static String givingReceipt(String id) => '/giving/receipts/$id';
  static String givingReceiptDownload(String id) => '/giving/receipts/$id/download';
  static String givingPaymentMethod(String id) => '/giving/payment-methods/$id';
  static String givingCampaign(String id) => '/giving/campaigns/$id';
  static String givingCampaignDonate(String id) => '/giving/campaigns/$id/donate';
  static String givingPledgeItem(String id) => '/giving/pledges/$id';
  static String givingPledgePay(String id) => '/giving/pledges/$id/pay';
  static String givingRecurringItem(String id) => '/giving/recurring/$id';

  // ── Groups ────────────────────────────────────────────────────────────────
  static const String groups = '/groups';
  static String group(String id) => '/groups/$id';
  static String groupJoin(String id) => '/groups/$id/join';
  static String groupLeave(String id) => '/groups/$id/leave';

  // ── Community ─────────────────────────────────────────────────────────────
  static const String announcements = '/community/announcements';
  static String announcement(String id) => '/community/announcements/$id';
  static String announcementRead(String id) => '/community/announcements/$id/read';
  static const String testimonies = '/community/testimonies';
  static String testimonyReact(String id) => '/community/testimonies/$id/react';
  static const String directory = '/community/directory';
  static const String inviteGenerate = '/community/invite/generate';
  static const String inviteStats = '/community/invite/stats';
  static String inviteValidate(String code) => '/community/invite/$code';

  // ── Forum ─────────────────────────────────────────────────────────────────
  static const String forumCategories = '/forum/categories';
  static const String forumTrending = '/forum/trending';
  static const String forumRecent = '/forum/recent';
  static String forumCategoryThreads(String id) => '/forum/categories/$id/threads';
  static const String forumThreads = '/forum/threads';
  static String forumThread(String id) => '/forum/threads/$id';
  static String forumThreadReplies(String id) => '/forum/threads/$id/replies';
  static String forumThreadLike(String id) => '/forum/threads/$id/like';
  static String forumThreadBookmark(String id) => '/forum/threads/$id/bookmark';
  static String forumReplyLike(String id) => '/forum/replies/$id/like';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';
  static String notificationDelete(String id) => '/notifications/$id';

  // ── Search ────────────────────────────────────────────────────────────────
  static const String search = '/search';
  static const String searchTrending = '/search/trending';

  // ── Live Service ─────────────────────────────────────────────────────────
  static const String liveCurrent = '/live/current';
  static const String liveList = '/live';
  static String liveById(String id) => '/live/$id';
  static String liveChat(String id) => '/live/$id/chat';

  // ── Chat ──────────────────────────────────────────────────────────────────
  static const String chatConversations = '/chat/conversations';
  static String chatMessages(String id) => '/chat/conversations/$id/messages';
  static String chatMarkRead(String id) => '/chat/conversations/$id/read';
  static String chatPin(String id) => '/chat/conversations/$id/pin';
  static String chatMute(String id) => '/chat/conversations/$id/mute';

  // ── Prayer Requests ───────────────────────────────────────────────────────
  static const String prayerRequests = '/prayer-requests';
  static const String myPrayerRequests = '/prayer-requests/my';
  static String prayerRequestPray(String id) => '/prayer-requests/$id/pray';

  // ── Kids Check-In ─────────────────────────────────────────────────────────
  static const String kidsChildren = '/kids/children';
  static const String kidsRooms = '/kids/rooms';
  static const String kidsCheckin = '/kids/checkin';
  static const String kidsCheckout = '/kids/checkout';

  // ── Volunteer ─────────────────────────────────────────────────────────────
  static const String volunteerOpportunities = '/volunteer/opportunities';
  static const String volunteerRoster = '/volunteer/roster';
  static String volunteerSignup(String id) => '/volunteer/opportunities/$id/signup';
  static String volunteerCheckin(String id) => '/volunteer/roster/$id/checkin';
  static String volunteerSwap(String id) => '/volunteer/roster/$id/swap';

  // ── Media ─────────────────────────────────────────────────────────────────
  static const String mediaAlbums = '/media/albums';
  static String mediaAlbum(String id) => '/media/albums/$id';
  static String mediaAlbumPhotos(String id) => '/media/albums/$id/photos';
  static const String mediaPodcasts = '/media/podcasts';
  static String mediaPodcast(String id) => '/media/podcasts/$id';
  static String mediaPodcastProgress(String id) => '/media/podcasts/$id/progress';
  static const String mediaSongs = '/media/songs';
  static String mediaSong(String id) => '/media/songs/$id';

  // ── Bible ─────────────────────────────────────────────────────────────────
  static const String bibleBooks = '/bible/books';
  static String bibleChapter(String bookId, int chapter) =>
      '/bible/$bookId/$chapter';
  static const String bibleSearch = '/bible/search';
  static const String bibleHighlights = '/bible/highlights';
  static String bibleHighlight(String id) => '/bible/highlights/$id';
  static const String devotionalsToday = '/bible/devotionals/today';
  static const String devotionalsStreak = '/bible/devotionals/streak';
  static String devotionalRead(String id) => '/bible/devotionals/$id/read';
  static const String readingPlans = '/bible/reading-plans';
  static const String myReadingPlans = '/bible/reading-plans/my';
  static String readingPlan(String id) => '/bible/reading-plans/$id';
  static String readingPlanEnroll(String id) =>
      '/bible/reading-plans/$id/enroll';
  static String readingPlanProgress(String id) =>
      '/bible/reading-plans/$id/progress';
}
