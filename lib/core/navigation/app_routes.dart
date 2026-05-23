/// Named route path constants.
///
/// Every route in the app references these constants — no raw strings
/// scattered across the codebase.
abstract final class AppRoutes {
  // ── Top-level ──────────────────────────────────────────────────────────────
  static const splash = '/splash';
  static const onboarding = '/onboarding';

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const emailVerification = '/auth/email-verification';
  static const churchCode = '/auth/church-code';
  static const forgotPassword = '/auth/forgot-password';
  static const createNewPassword = '/auth/create-new-password';
  static const profileSetup = '/auth/profile-setup';

  // ── Main app (bottom nav shell) ────────────────────────────────────────────
  static const home = '/home';
  static const live = '/home/live';

  static const sermons = '/sermons';
  static const sermonDetail = '/sermons/:id';
  static const seriesDetail = '/series/:id';

  static const events = '/events';
  static const eventDetail = '/events/:id';

  static const giving = '/giving';
  static const givingCheckout = '/giving/checkout';
  static const givingSuccess = '/giving/success';

  static const profile = '/profile';
  static const givingHistory = '/profile/giving-history';
  static const myEvents = '/profile/my-events';
  static const prayerRequests = '/profile/prayer-requests';
  static const settings = '/profile/settings';

  // ── Bible & Devotional ───────────────────────────────────────────────────────
  static const bible = '/bible';
  static const devotional = '/devotional';
  static const readingPlan = '/reading-plan';

  // ── Sermon extras ──────────────────────────────────────────────────────────
  static const sermonNotes = '/sermons/notes';
  static const savedSermons = '/profile/saved-sermons';
  static const audioPlayer = '/audio-player';
  static const videoPlayer = '/video-player';

  // ── Community & Connection ───────────────────────────────────────────────
  static const announcements = '/announcements';
  static const connectGroups = '/connect-groups';
  static const groupDetail = '/connect-groups/:id';
  static const testimonies = '/testimonies';
  static const churchDirectory = '/church-directory';
  static const inviteFriends = '/invite-friends';

  // ── Church Info ─────────────────────────────────────────────────────────
  static const aboutChurch = '/about-church';
  static const pastors = '/pastors';
  static const campuses = '/campuses';
  static const contactUs = '/contact-us';
  static const helpFaq = '/help-faq';

  // ── Volunteering & Service ─────────────────────────────────────────────
  static const volunteer = '/volunteer';
  static const serviceRoster = '/service-roster';
  static const kidsCheckin = '/kids-checkin';

  // ── Content & Media ────────────────────────────────────────────────────
  static const photoGallery = '/photo-gallery';
  static const worshipLyrics = '/worship-lyrics';
  static const podcastFeed = '/podcast-feed';

  // ── Profile & Account ──────────────────────────────────────────────────
  static const editProfile = '/profile/edit-profile';
  static const manageNotifications = '/profile/manage-notifications';
  static const savedItems = '/profile/saved-items';
  static const spiritualJourney = '/profile/spiritual-journey';
  static const attendanceHistory = '/profile/attendance-history';

  // ── Giving Enhancements ────────────────────────────────────────────────
  static const givingCampaign = '/giving/campaign';
  static const pledge = '/giving/pledge';
  static const receiptDetail = '/giving/receipt';

  // ── Forum ────────────────────────────────────────────────────────────
  static const forum = '/forum';
  static const forumCategory = '/forum/category/:id';
  static const forumThread = '/forum/thread/:id';
  static const forumCreatePost = '/forum/create-post';

  // ── Search ──────────────────────────────────────────────────────────
  static const globalSearch = '/search';

  // ── Chat / Messaging ───────────────────────────────────────────────
  static const chatList = '/chat';
  static const chatConversation = '/chat/:id';

  // ── Overlay routes (appear on top of any tab) ──────────────────────────────
  static const prayerRequest = '/prayer-request';
  static const notificationCenter = '/notification-center';
}
