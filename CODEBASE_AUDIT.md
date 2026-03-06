# Church App — Comprehensive Codebase Audit

> **Generated for architectural planning: model / repository / provider layer design**
> Covers every `.dart` file under `lib/` (93 files, ~28,000+ lines)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Core Infrastructure](#2-core-infrastructure)
3. [Shared Widgets](#3-shared-widgets)
4. [Feature: auth/](#4-feature-auth)
5. [Feature: onboarding/](#5-feature-onboarding)
6. [Feature: splash/](#6-feature-splash)
7. [Feature: home/](#7-feature-home)
8. [Feature: sermons/](#8-feature-sermons)
9. [Feature: events/](#9-feature-events)
10. [Feature: giving/](#10-feature-giving)
11. [Feature: bible/](#11-feature-bible)
12. [Feature: community/](#12-feature-community)
13. [Feature: chat/](#13-feature-chat)
14. [Feature: forum/](#14-feature-forum)
15. [Feature: prayer/](#15-feature-prayer)
16. [Feature: notifications/](#16-feature-notifications)
17. [Feature: profile/](#17-feature-profile)
18. [Feature: search/](#18-feature-search)
19. [Feature: church\_info/](#19-feature-church_info)
20. [Feature: media/](#20-feature-media)
21. [Feature: volunteering/](#21-feature-volunteering)
22. [Architectural Observations & Recommendations](#22-architectural-observations--recommendations)

---

## 1. Executive Summary

| Metric | Value |
|---|---|
| Total `.dart` files | 93 |
| Feature folders | 18 |
| Private data classes (need model extraction) | **~65+** |
| Private enums (need extraction) | **~8** |
| Screens using `setState` (no state management) | **~50+** |
| Services beyond `AuthService` | **0** |
| Repository / data layer classes | **0** |
| State management library | **None** |
| Navigation | GoRouter with `StatefulShellRoute` |
| Theme system | Complete design tokens (7 files) |

### Key Finding

**Every screen embeds its own mock data as `static const`/`static final` lists and uses inline private `_DataClass` definitions.** There is zero separation between UI and data. All state is local `setState`. The only service is `AuthService` (a `ChangeNotifier` singleton backed by `SharedPreferences`).

---

## 2. Core Infrastructure

### 2.1 `lib/main.dart` (69 lines)

| Item | Detail |
|---|---|
| State | `ValueNotifier<ThemeMode> themeNotifier` (global, persisted to `SharedPreferences`) |
| Init | `AuthService.instance.init()` called before `runApp` |
| Theme | `AppTheme.light()` / `AppTheme.dark()` via `themeNotifier` |
| Router | `AppRouter.router` passed to `MaterialApp.router` |

### 2.2 `lib/core/services/auth_service.dart` (119 lines)

| Item | Detail |
|---|---|
| Pattern | Singleton (`AuthService.instance`) + `ChangeNotifier` |
| Storage | `SharedPreferences` keys: `hasSeenOnboarding`, `isLoggedIn`, `hasCompletedSetup`, `userEmail`, `userName` |
| Enum | `AuthState { unknown, firstLaunch, unauthenticated, needsSetup, authenticated }` |
| API surface | `init()`, `login(email, name)`, `completeSetup()`, `completeOnboarding()`, `logout()`, `state` getter |
| Mock behaviour | `login()` simply writes flags — no backend call |

### 2.3 `lib/core/navigation/app_router.dart` (888 lines)

| Item | Detail |
|---|---|
| Router | `GoRouter` with `refreshListenable: AuthService.instance` |
| Auth redirect | `redirect` callback maps `AuthState` → `/splash`, `/onboarding`, `/login`, `/profile-setup`, or `null` |
| Shell | `StatefulShellRoute.indexedStack` with 5 branches |
| Branches | Home `/`, Sermons `/sermons`, Events `/events`, Giving `/giving`, Profile `/profile` |
| Overlay routes | ~30 additional top-level `GoRoute` entries for prayer, notifications, bible, community, forum, search, chat, church\_info, volunteering, media screens |
| Data passing | Constructor params hydrated from `:pathParam` and `?queryParam` via `state.pathParameters` / `state.uri.queryParameters` |
| Transitions | Custom `_buildPage()` applies `SlideTransition` / `FadeTransition` / `ScaleTransition` per-route |

### 2.4 `lib/core/navigation/main_shell.dart` (small)

Wraps `StatefulNavigationShell` + `AppPrayerFab` + `AppBottomNavBar`.

### 2.5 Theme System (`lib/core/theme/`)

| File | Exports |
|---|---|
| `app_colors.dart` | `AppColors` — primary `#1E3A8A`, gold `#FBBF24`, full light/dark palette |
| `app_text_styles.dart` | `AppTextStyles` — Inter font, `display28`…`labelSmall` + `withColor`/`bold` helpers |
| `app_gradients.dart` | `AppGradients` — `hero`, `goldShimmer`, `verseCard`, `darkOverlay`, `warmSunset`, `coolOcean` |
| `app_shadows.dart` | `AppShadows` — `xs`/`sm`/`md`/`lg` × light/dark |
| `app_radius.dart` | `AppRadius` — `xs=4` `sm=8` `md=12` `lg=16` `xl=20` `xxl=24` `full=999` |
| `app_spacing.dart` | `AppSpacing` — 4 px base scale: `xs=4` `sm=8` `md=12` `lg=16` `xl=24` `xxl=32` `xxxl=48` |
| `app_theme.dart` | `AppTheme.light()` / `AppTheme.dark()` — assembles `ThemeData` |

---

## 3. Shared Widgets (`lib/shared/widgets/`)

| File | Widgets | Notes |
|---|---|---|
| `cards.dart` (607 ln) | `AppCard`, `AppFeatureCard`, `AppVerseCard`, `AppEventCard`, `AppQuickAccessCard` | `AppVerseCard` has internal fade animation |
| `common.dart` | `AppDivider`, `AppSectionHeader`, `AppEmptyState` | Reusable layout helpers |
| `app_bottom_nav_bar.dart` | `AppBottomNavBar` | 5 tabs, animated scale + gold dot; private `_NavItem` data class (icon, activeIcon, label) |
| `buttons.dart` | Various button widgets | — |
| `inputs.dart` | Text field widgets | — |
| `filter_chips.dart` | Filter chip row | — |
| `app_bars.dart` | Custom app bars | — |
| `avatar.dart` | Avatar widget | — |
| `badge.dart` | Badge widget | — |
| `skeleton.dart` | Skeleton/shimmer loading | — |
| `prayer_fab.dart` | `AppPrayerFab` | Floating action button for prayer |
| `app_tap_animation.dart` | Tap scale animation wrapper | — |

---

## 4. Feature: `auth/` (7 files, ~1,714 lines)

### Files & Navigation

| File | Lines | Constructor Params |
|---|---|---|
| `login_screen.dart` | 273 | — |
| `register_screen.dart` | 223 | — |
| `email_verification_screen.dart` | 248 | `{String? email}` |
| `church_code_screen.dart` | 246 | — |
| `forgot_password_screen.dart` | 230 | — |
| `create_new_password_screen.dart` | 280 | `{String? token}` |
| `profile_setup_screen.dart` | 214 | — |

### Mock Data

None — auth screens interact with `AuthService` (which itself is mock-backed by `SharedPreferences`).

### State Variables

| File | Variables | `setState` calls |
|---|---|---|
| `login_screen.dart` | `_isLoading`, `_errorMessage` | ~3 |
| `register_screen.dart` | `_isLoading`, `_errorMessage` | ~3 |
| `email_verification_screen.dart` | `_isResending`, `_isVerified` | ~3 |
| `church_code_screen.dart` | 6× `TextEditingController`, 6× `FocusNode`, `_errorMessage` | ~2 |
| `forgot_password_screen.dart` | `_isLoading`, `_errorMessage`, `_submitted` | ~3 |
| `create_new_password_screen.dart` | `_isLoading`, `_errorMessage`, `_isSuccess` | ~3 |
| `profile_setup_screen.dart` | `_isLoading` | ~2 |

### Private Classes / Enums

None.

---

## 5. Feature: `onboarding/` (1 file, ~253 lines)

### `onboarding_screen.dart`

| Category | Detail |
|---|---|
| **Mock data** | `_slides` — `static const` list of 3 `_SlideData` items (emoji, title, subtitle) |
| **State** | `_currentPage` (int), `PageController` |
| **Private class** | `_SlideData { final String emoji; final String title; final String subtitle; }` |
| **Navigation** | Calls `AuthService.instance.completeOnboarding()` → navigates to `/login` |

---

## 6. Feature: `splash/` (1 file, ~132 lines)

### `splash_screen.dart`

| Category | Detail |
|---|---|
| **Mock data** | None |
| **State** | `AnimationController` + curved animation for scale/fade |
| **Navigation** | Auto-navigates after animation completes based on `AuthService.instance.state` |

---

## 7. Feature: `home/` (2 files, ~2,341 lines)

### 7.1 `home_screen.dart` (1,596 lines)

#### Inline Mock Data

| Variable | Type | Description |
|---|---|---|
| `_stories` | `List<_StoryData>` (7 items) | Emoji, label, color, description, dateLabel, route for each story circle |
| Verse text | Hardcoded `String` | `"Be still, and know that I am God..."` — Psalm 46:10 |
| Campaign data | Hardcoded `int` | `raised = 187500`, `goal = 250000` |
| Event cards | Inline widgets | "Youth Night", "Women's Conference", "Easter Celebration" with dates/locations |
| Sermon data | Hardcoded `String` | "The Power of Faith" title, speaker, duration |

#### State Variables (5 + 4 AnimationControllers)

| Variable | Type | Default |
|---|---|---|
| `_isServiceLive` | `bool` | `true` |
| `_liveBannerDismissed` | `bool` | `false` |
| `_hasCampaign` | `bool` | `true` |
| `_viewed` | `Set<int>` | `{}` |
| `_staggerCtrl` | `AnimationController` | 800 ms |
| `_greetCtrl` | `AnimationController` | 1200 ms |
| `_wavingCtrl` | `AnimationController` | repeating |
| `_livePulseCtrl` | `AnimationController` | repeating |

#### Private Classes

| Class | Fields |
|---|---|
| `_StoryData` | `emoji`, `label`, `color`, `description`, `dateLabel`, `route` |
| `_RainParticlePainter` | Custom `CustomPainter` for decorative rain |
| `_CampaignProgressCard` | Stateless — renders campaign progress bar |
| `_StaggerItem` | Animation helper widget |
| `_CommunityChip` | Action chip widget |
| `_LiveBanner` | Animated live service banner |
| `_HeroHeader` | Top hero area with greeting + verse |
| `_HighlightStories` | Horizontal story circle list |
| `_StoryCircle` | Individual story avatar |
| `_StoryViewer` | Full-screen story overlay |

#### Navigation

- Reads `AuthService.instance.userName` for greeting
- Pushes to: `/sermons/1`, `/events`, `/giving/campaign/1`, `/live`, `/community/*`, various story routes

### 7.2 `live_service_screen.dart` (745 lines)

#### Inline Mock Data

| Variable | Type | Description |
|---|---|---|
| `_seedMessages()` | `List<_ChatMsg>` (5 items) | name, text, time, isOwn |
| Prayers list | `List<String>` (3 items) | Prayer request strings |
| Bible text | Hardcoded `String` | Romans 8:28-31 multi-verse passage |

#### State Variables

| Variable | Type | Default |
|---|---|---|
| `_tabController` | `TabController` | 3 tabs: Chat / Prayer / Bible |
| `_msgController` | `TextEditingController` | — |
| `_messages` | `List<_ChatMsg>` | Seeded from `_seedMessages()` |
| `_emojis` | `List<_FloatingEmoji>` | `[]` |
| `_viewerCount` | `int` | `1243` |

#### Private Classes

| Class | Fields |
|---|---|
| `_ChatMsg` | `name`, `text`, `time`, `isOwn` |
| `_FloatingEmoji` | `id`, `emoji`, `startX`, `startY` |

---

## 8. Feature: `sermons/` (7 files, ~4,524 lines)

### 8.1 `sermons_screen.dart` (978 lines)

#### Inline Mock Data

| Variable | Type | Items | Key Fields |
|---|---|---|---|
| `_seriesList` | `List<_SeriesData>` | 5 | id, title, subtitle, emoji, color |
| `_sermons` | `List<_SermonData>` | 6 | id, title, speaker, duration, date, series?, downloadState, downloadProgress |
| `_nowPlayingTitle` | `String` | — | "The Power of Faith" |
| `_nowPlayingSpeaker` | `String` | — | "Pastor James Mitchell" |
| `_nowPlayingProgress` | `double` | — | `0.45` |

#### State Variables

| Variable | Type | Default |
|---|---|---|
| `_searchController` | `TextEditingController` | — |
| `_selectedFilter` | `int` | `0` |
| `_searchQuery` | `String` | `''` |
| `_isPlaying` | `bool` | `true` |

#### Private Classes / Enums

| Name | Type | Fields |
|---|---|---|
| `_DownloadState` | `enum` | `none`, `downloading`, `downloaded` |
| `_SeriesData` | `class` | `id`, `title`, `subtitle`, `emoji`, `color` |
| `_SermonData` | `class` | `id`, `title`, `speaker`, `duration`, `date`, `series?`, `downloadState`, `downloadProgress` |

#### Navigation

- Pushes to `/sermons/{id}`, `/series/{id}`, `/sermons/audio`, `/sermons/saved`, `/sermons/notes`

### 8.2 `sermon_detail_screen.dart` (417 lines)

| Category | Detail |
|---|---|
| **Constructor** | `SermonDetailScreen({required this.sermonId})` |
| **Mock data** | Hardcoded "The Power of Faith" sermon (speaker, date, duration, description, 3 key points, "Faith Series" tag), 2 related sermons inline |
| **State** | `_isPlaying`, `_isBookmarked`, `_progress = 0.3` |
| **Navigation** | Receives `sermonId` from GoRouter path param |

### 8.3 `series_detail_screen.dart` (136 lines)

| Category | Detail |
|---|---|
| **Constructor** | `SeriesDetailScreen({required this.seriesId})` — **StatelessWidget** |
| **Mock data** | Hardcoded "Faith Series" (description, 3 sermons with title/speaker/duration) |

### 8.4 `saved_sermons_screen.dart` (391 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_sermons` — mutable `List<_SavedSermon>` (6 items) |
| **State** | `_sermons` (supports swipe-to-remove + undo via `ScaffoldMessenger`) |
| **Private class** | `_SavedSermon { id, title, speaker, series, date, duration, savedDate, hasNotes }` |

### 8.5 `sermon_notes_screen.dart` (666 lines)

| Category | Detail |
|---|---|
| **Constructor** | `SermonNotesScreen({this.sermonId, this.sermonTitle, this.sermonSpeaker, this.sermonDate})` |
| **State** | `_titleController`, `_notesController`, `_notesFocus`, `_isSaved`, `_listMode`, `_bulletCount` |
| **Private enum** | `_ListMode { none, bullet, numbered }` |

### 8.6 `audio_player_screen.dart` (937 lines)

| Category | Detail |
|---|---|
| **Constructor** | `AudioPlayerScreen({this.sermonId, this.sermonTitle, this.sermonSpeaker, this.sermonSeries})` |
| **Mock data** | `_queue` (3 `_QueueItem`), `_currentPosition = "12:34"`, `_totalDuration = "35:20"`, `_speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]` |
| **State** | `_isPlaying`, `_progress = 0.35`, `_playbackSpeed = 1.0`, `_sleepTimerMinutes` (nullable int) |
| **Private class** | `_QueueItem { title, speaker, duration }` |

### 8.7 `video_player_screen.dart` (999 lines)

| Category | Detail |
|---|---|
| **Constructor** | `VideoPlayerScreen({this.sermonId, this.sermonTitle, this.sermonSpeaker})` |
| **Mock data** | `_qualities = ['Auto', '1080p', '720p', '480p']`, related sermons inline, `_currentPosition = "08:15"`, `_totalDuration = "42:30"` |
| **State** | `_isPlaying`, `_controlsVisible`, `_isFullscreen`, `_progress = 0.25`, `_selectedQuality = '1080p'` |

---

## 9. Feature: `events/` (2 files, ~1,621 lines)

### 9.1 `events_screen.dart` (1,310 lines)

#### Inline Mock Data

| Variable | Type | Items | Key Fields |
|---|---|---|---|
| `_eventsByDay` | `Map<int, List<_EventData>>` | 4 events across 3 days | id, title, date, location, imageColor, attendees, isRecurring, pastPhotos |
| `_nextEventTime` | `DateTime` | — | `DateTime(2026, 2, 25, 10, 0)` |

#### State Variables

| Variable | Type | Default |
|---|---|---|
| `_viewMode` | `int` | `0` (0=List, 1=Calendar, 2=Map) |
| `_focusMonth` | `DateTime` | `DateTime.now()` |
| `_selectedDay` | `int?` | `null` |
| `_countdownTimer` | `Timer?` | — |
| `_timeUntilNext` | `Duration` | computed |

#### Private Classes

| Class | Fields |
|---|---|
| `_EventData` | `id`, `title`, `date`, `location`, `imageColor`, `attendees`, `isRecurring`, `pastPhotos` |
| `_ViewModeChip` | UI widget |
| `_CountdownBanner` | Countdown display widget |
| `_MapGridPainter` | Custom `CustomPainter` for map placeholder |
| `_EventCard` | **Stateful** — has own `_registered` bool state |

#### Navigation

- Pushes to `/events/{id}` via `context.push`

### 9.2 `event_detail_screen.dart` (311 lines)

| Category | Detail |
|---|---|
| **Constructor** | `EventDetailScreen({required this.eventId})` |
| **Mock data** | Hardcoded "Worship Conference 2026" (date, location, description, 2 speakers with name/role) |
| **State** | `_registered` (bool) |

---

## 10. Feature: `giving/` (5 files, ~3,115 lines)

### 10.1 `giving_screen.dart` (1,227 lines)

#### Inline Mock Data

| Variable | Type | Description |
|---|---|---|
| `_savedCards` | `static const List<_SavedCard>` | Payment cards (brand, last4, color) |
| Amount presets | Inline `[1000, 2000, 5000, 10000, 20000, 50000]` | Quick amount buttons |
| Categories | Inline labels | Tithe, Offering, Seed, Building, Missions |

#### State Variables

| Variable | Type | Default |
|---|---|---|
| `_selectedCategory` | `int` | `0` |
| `_selectedAmount` | `int?` | `null` |
| `_isCustom` | `bool` | `false` |
| `_displayAmount` | `int` | `0` |
| `_targetAmount` | `int` | `0` |
| `_frequency` | `int` | `0` (One-time / Weekly / Monthly) |
| `_paymentMethod` | `int` | `0` |
| `_reminderEnabled` | `bool` | `false` |
| `_reminderFrequency` | `int` | `0` |

#### Private Classes

| Class | Fields |
|---|---|
| `_SavedCard` | `brand`, `last4`, `color` |
| `_GivingImpactCard` | UI widget |
| `_ImpactMetric` | UI widget |
| `_SavedCardOption` | UI widget |
| `_GivingReminderSection` | UI widget |
| `_ReminderChip` | UI widget |
| `_SegmentedControl` | Reusable segmented control |
| `_PaymentOption` | UI widget |
| `_ThousandsSeparatorFormatter` | `TextInputFormatter` subclass |
| `_QuickLink` | UI widget |

### 10.2 `giving_campaign_screen.dart` (494 lines)

| Category | Detail |
|---|---|
| **Constructor** | `GivingCampaignScreen({this.campaignId})` |
| **Mock data** | Hardcoded `_CampaignData` (title, subtitle, description, goalAmount, raisedAmount, daysRemaining, donorCount, startDate, endDate, heroEmoji), 3 `_DonorEntry` items |
| **Private classes** | `_CampaignData { title, subtitle, description, goalAmount, raisedAmount, daysRemaining, donorCount, startDate, endDate, heroEmoji }`, `_DonorEntry { name, amount, timeAgo }`, `_CountdownPill` (UI) |

### 10.3 `pledge_screen.dart` (655 lines)

| Category | Detail |
|---|---|
| **Constructor** | `PledgeScreen({this.campaignId})` |
| **Mock data** | Hardcoded `_PledgeData` (campaignName, totalPledged, totalPaid, monthlyAmount, frequency, startDate, nextDue, paymentsCompleted, totalPayments), 4 `_PledgePayment` items |
| **State** | `_hasExistingPledge = true`, `_selectedFrequency`, `_selectedDuration` |
| **Private classes** | `_PledgeData { campaignName, totalPledged, totalPaid, monthlyAmount, frequency, startDate, nextDue, paymentsCompleted, totalPayments }`, `_PledgePayment { date, amount, status }` |

### 10.4 `receipt_detail_screen.dart` (427 lines)

| Category | Detail |
|---|---|
| **Constructor** | `ReceiptDetailScreen({this.receiptId})` |
| **Mock data** | Hardcoded `_ReceiptData` with 16 fields |
| **Private classes** | `_ReceiptData { receiptNumber, donorName, donorEmail, amount, date, time, paymentMethod, category, campaign, transactionId, status, churchName, churchAddress, churchPhone, churchEin }`, `_ReceiptRow` (UI), `_DottedDivider` (UI) |

### 10.5 `giving_success_screen.dart` (312 lines)

| Category | Detail |
|---|---|
| **Mock data** | None (receives amount from previous screen) |
| **Private classes** | `_ConfettiParticle { color, startX, speed, drift, size }`, `_CheckmarkPainter` (CustomPainter), `_ConfettiPainter` (CustomPainter) |

---

## 11. Feature: `bible/` (3 files, ~2,340 lines)

### 11.1 `bible_reader_screen.dart` (994 lines)

#### Inline Mock Data

| Variable | Type | Description |
|---|---|---|
| `_oldTestament` | `List<String>` | 39 book names |
| `_newTestament` | `List<String>` | 27 book names |
| `_chapterCounts` | `static const Map<String, int>` | Chapter count for all 66 books |
| `_sampleVerses` | `List<String>` | Sample verse texts for the reader |

#### State Variables

| Variable | Type | Default |
|---|---|---|
| `_level` | `int` | `0` (0=Books, 1=Chapters, 2=Verses) |
| `_selectedBook` | `String` | `''` |
| `_selectedChapter` | `int` | `0` |
| `_nightMode` | `bool` | `false` |
| `_highlightedVerses` | `Set<int>` | `{}` |

#### Private Classes

| Class | Fields |
|---|---|
| `_SearchField` | UI widget |
| `_BookTile` | UI widget |
| `_ChapterCell` | UI widget |
| `_NavArrow` | Navigation arrow widget |
| `_HighlightBar` | Highlight toolbar |
| `_ActionRow` | Action row widget |

### 11.2 `daily_devotional_screen.dart` (569 lines)

| Category | Detail |
|---|---|
| **Mock data** | Hardcoded `_DevotionalData` instance (date, dayOfWeek, title, scripture, scriptureText, body, reflectionPrompt, author, readingTime, streakDays) |
| **State** | `_isMarkedRead` (bool) |
| **Private classes** | `_DevotionalData { date, dayOfWeek, title, scripture, scriptureText, body, reflectionPrompt, author, readingTime, streakDays }`, `_StreakBanner`, `_ScriptureCard`, `_ReflectionCard` |

### 11.3 `reading_plan_screen.dart` (777 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_plans` list of `_PlanData` items (3+ plans), today's checklist items |
| **State** | `_selectedTabIndex`, `_checked` (List&lt;bool&gt;) |
| **Private classes** | `_PlanData { title, description, progress, totalDays, participants, imageColor, isActive, todayReading?, todayTitle? }`, `_TabButton`, `_ActivePlanCard`, `_TodayChecklist`, `_ChecklistItem`, `_BrowsePlanCard`, `_ProgressRing`, `_RingPainter` (CustomPainter) |

---

## 12. Feature: `community/` (6 files, ~3,037 lines)

### 12.1 `announcements_screen.dart` (340 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_announcements` — `static const` list of `_Announcement` items |
| **Private classes** | `_Announcement { id, title, body, date, timeAgo, priority, isNew, hasImage, category }` |
| **Private enum** | `_Priority { urgent, high, normal }` |

### 12.2 `connect_groups_screen.dart` (550 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_categories` list of strings, `_groups` `static const` list of `_GroupData` |
| **State** | `_selectedCategory` (String, default `'All'`) |
| **Private class** | `_GroupData { id, name, description, category, memberCount, maxMembers, meetingDay, meetingTime, location, leader, color, isOpen }` |

### 12.3 `group_detail_screen.dart` (648 lines)

| Category | Detail |
|---|---|
| **Constructor** | `GroupDetailScreen({required this.groupId, this.groupName})` |
| **Mock data** | `_memberNames` `static const` list, group metadata inline |
| **Private class** | `_QuickInfoTile` (UI widget) |

### 12.4 `church_directory_screen.dart` (605 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_members` `static const` list of `_MemberData` |
| **State** | `_searchQuery` (String) |
| **Private class** | `_MemberData { name, department, role, joinedYear }` |

### 12.5 `testimonies_screen.dart` (398 lines)

| Category | Detail |
|---|---|
| **Mock data** | Inline testimonies list with author, date, content |
| **State** | Minimal `setState` usage |

### 12.6 `invite_friends_screen.dart` (496 lines)

| Category | Detail |
|---|---|
| **Mock data** | Invite link/code hardcoded |
| **State** | Copy/share interaction states |

---

## 13. Feature: `chat/` (2 files, ~1,673 lines)

### 13.1 `chat_list_screen.dart` (856 lines)

#### Inline Mock Data

| Variable | Type | Description |
|---|---|---|
| `_filterLabels` | `static const List<String>` | `['All', 'Direct', 'Groups']` |
| `_chats` | `List<_ChatPreview>` | Seeded from `_seedChats()` — **mutable** list (supports pin/mute/delete) |

#### State Variables

| Variable | Type | Default |
|---|---|---|
| `_searchCtrl` | `TextEditingController` | — |
| `_filterIndex` | `int` | `0` |
| `_searchQuery` | `String` | `''` |

#### Private Classes

| Class | Fields | Notes |
|---|---|---|
| `_ChatPreview` | `id`, `name`, `initials`, `lastMessage`, `time`, `unreadCount`, `isGroup`, `memberCount?`, `isOnline`, `isPinned`, `isMuted`, `color` | ⚠️ **Mutable fields**: `isPinned`, `isMuted` |

#### Navigation

- Pushes to `/chat/{id}?name={name}` via `context.push`

### 13.2 `chat_conversation_screen.dart` (817 lines)

#### Inline Mock Data

| Variable | Type | Description |
|---|---|---|
| `_chatMeta` | `static const Map<String, _ChatMeta>` | Maps chatId → metadata |
| `_seedMessages(chatId)` | `List<_Message>` | Returns seeded messages per chat |

#### State Variables

| Variable | Type | Default |
|---|---|---|
| `_messages` | `List<_Message>` | Seeded per `chatId` |
| `_isTyping` | `bool` | `false` |

#### Private Classes

| Class | Fields |
|---|---|
| `_ChatMeta` | `name`, `isGroup`, `memberCount`, `isOnline` |
| `_Message` | `text`, `isOwn`, `time`, `senderName?` |
| `_ChatBubble` | UI widget |
| `_TypingIndicator` | Animated dots widget |
| `_TimeSeparator` | Date separator widget |

#### Navigation

- `ChatConversationScreen({required this.chatId, this.chatName})`
- Has `_autoReply(input)` function that generates mock replies

---

## 14. Feature: `forum/` (4 files, ~2,942 lines)

### 14.1 `forum_screen.dart` (916 lines)

#### Inline Mock Data

| Variable | Type | Items |
|---|---|---|
| `_categories` | `List<_CategoryData>` | ~8 categories (name, emoji, threadCount, color) |
| `_trendingTopics` | `List<_TrendingData>` | ~5 trending items (title, replies, views) |
| `_recentThreads` | `List<_ThreadPreview>` | ~6 threads (id, title, author, preview, category, replies, views, timeAgo, isPinned) |

#### State

| Variable | Type |
|---|---|
| `_searchCtrl` | `TextEditingController` |
| `_searchQuery` | `String` |

#### Private Classes

| Class | Fields |
|---|---|
| `_CategoryData` | `name`, `emoji`, `threadCount`, `color` |
| `_TrendingData` | `title`, `replies`, `views` |
| `_ThreadPreview` | `id`, `title`, `author`, `preview`, `category`, `replies`, `views`, `timeAgo`, `isPinned` |

### 14.2 `forum_category_screen.dart` (627 lines)

| Category | Detail |
|---|---|
| **Constructor** | `ForumCategoryScreen({required this.categoryId, this.categoryName})` |
| **Mock data** | `_categoryMeta` (`Map<String, _CategoryMeta>`), `_threads` list of `_ThreadItem` |
| **State** | `_searchQuery`, `_sortIndex` |
| **Private classes** | `_CategoryMeta { name, emoji, description, threadCount, memberCount, color }`, `_ThreadItem { id, title, author, preview, replies, views, timeAgo, isPinned, isHot }` |

### 14.3 `forum_thread_screen.dart` (838 lines)

| Category | Detail |
|---|---|
| **Constructor** | `ForumThreadScreen({required this.threadId, this.threadTitle})` |
| **Mock data** | `_post` (`static const _PostData`), `_replies` list of `_ReplyData` |
| **State** | `_isLiked`, `_isBookmarked`, `_likeCount = 67`, `_replyCtrl` (TextEditingController) |
| **Private classes** | `_PostData { author, avatar, date, title, body, category, likes, views }`, `_ReplyData { author, avatar, text, timeAgo, likes, isLiked }` (⚠️ mutable `isLiked`) |

### 14.4 `create_post_screen.dart` (561 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_categories` list of `_CatOption` (name, emoji) |
| **State** | `_selectedCategory`, `_isSubmitting`, `_titleCtrl`, `_bodyCtrl` |
| **Private class** | `_CatOption { name, emoji }` |

---

## 15. Feature: `prayer/` (1 file, ~309 lines)

### `prayer_request_screen.dart`

| Category | Detail |
|---|---|
| **Mock data** | None (form-only screen) |
| **State** | `_isPublic` (bool), `_submitted` (bool), `_titleCtrl`, `_bodyCtrl` |
| **Navigation** | Accessed via FAB overlay route |

---

## 16. Feature: `notifications/` (1 file, ~688 lines)

### `notification_center_screen.dart`

#### Inline Mock Data

| Variable | Type | Description |
|---|---|---|
| `_filterLabels` | `static const List<String>` | Filter tab labels |
| `_groupOrder` | `static const List<String>` | Group ordering keys |
| `_notifications` | `List<_NotifData>` | Seeded from `_seedNotifications()` — **mutable** (isRead toggling, deletion) |

#### State Variables

| Variable | Type | Default |
|---|---|---|
| `_notifications` | `List<_NotifData>` | seeded |
| `_filterIndex` | `int` | `0` |

#### Private Classes / Enums

| Name | Type | Fields |
|---|---|---|
| `_NType` | `enum` | Notification type categories |
| `_NotifData` | `class` | `id`, `title`, `body`, `type`, `timeAgo`, `isRead`, `route?` — ⚠️ **mutable `isRead`** |

---

## 17. Feature: `profile/` (10 files, ~3,418 lines)

### 17.1 `profile_screen.dart` (446 lines)

| Category | Detail |
|---|---|
| **Mock data** | Menu items list with icons/labels/routes, user data (name, email, department, joined date) |
| **Private class** | `_MenuItem { icon, label, route, trailing? }` |
| **Navigation** | Pushes to 9+ sub-routes: edit-profile, settings, giving-history, my-events, prayer-requests, saved-items, attendance, spiritual-journey, manage-notifications, help-faq |

### 17.2 `edit_profile_screen.dart` (437 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_departments` `static const` list of strings (departments to choose from), pre-filled user data |
| **State** | `_saving` (bool), `_selectedDepartment`, `_nameCtrl`, `_emailCtrl`, `_phoneCtrl`, `_bioCtrl` |

### 17.3 `settings_screen.dart` (358 lines)

| Category | Detail |
|---|---|
| **State** | `_themeMode` (int), `_pushEnabled`, `_emailEnabled`, `_eventReminders`, `_prayerUpdates` (all bool) |
| **Navigation** | Reads/writes `themeNotifier` from `main.dart` |

### 17.4 `giving_history_screen.dart` (130 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_history` `static final` list of `_GivingRecord` |
| **Private class** | `_GivingRecord { date, amount, category, method }` |

### 17.5 `my_events_screen.dart` (157 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_events` `static const` list of `_MyEvent` |
| **Private class** | `_MyEvent { title, date, location, status }` |

### 17.6 `prayer_requests_screen.dart` (198 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_requests` `static const` list of `_PrayerItem` |
| **Private class** | `_PrayerItem { title, date, status, prayerCount }` |

### 17.7 `saved_items_screen.dart` (411 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_tabs` (tab labels), `_allItems` `static final` list of `_SavedItem` |
| **State** | `TabController` |
| **Private class** | `_SavedItem { title, subtitle, type, date, icon }` |

### 17.8 `spiritual_journey_screen.dart` (388 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_milestones` `static final` list of `_MilestoneData` |
| **Private class** | `_MilestoneData { title, date, description, icon, color }` |

### 17.9 `attendance_history_screen.dart` (496 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_attended` `static final Set<DateTime>`, `_monthNames`, `_dayLabels` |
| **State** | `_focusMonth` (DateTime, for calendar navigation) |

### 17.10 `manage_notifications_screen.dart` (397 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_prefs` `Map<String, List<bool>>` (category → [push, email, sms] toggles), `_icons` map, `_descriptions` map |
| **State** | `_globalPush`, `_globalEmail` (bool), individual category toggles via `_prefs` map |

---

## 18. Feature: `search/` (1 file, ~928 lines)

### `global_search_screen.dart`

#### Inline Mock Data

| Variable | Type | Description |
|---|---|---|
| `_recentSearches` | `List<String>` | Mutable list of recent search terms |
| `_trending` | `static const List<String>` | Trending search terms |
| `_allItems` | `List<_SearchItem>` | **~30+ items** spanning all content types (sermons, events, groups, etc.) |

#### State Variables

| Variable | Type |
|---|---|
| `_searchCtrl` | `TextEditingController` |
| `_query` | `String` |

#### Private Classes

| Class | Fields |
|---|---|
| `_SearchItem` | `title`, `subtitle`, `type` (category string), `icon`, `route` |

#### Navigation

- Cross-cutting: pushes to routes across all features based on `_SearchItem.route`

---

## 19. Feature: `church_info/` (5 files, ~2,462 lines)

### 19.1 `about_church_screen.dart` (680 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_coreValues` list of `_CoreValue`, `_timelineItems` list of `_TimelineData`, church mission/vision strings |
| **Private classes** | `_CoreValue { title, description, emoji }`, `_TimelineData { year, title, description }` |

### 19.2 `pastors_screen.dart` (425 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_leaders` list of `_LeaderData`, `_ministryLeaders` list of `_MinistryLeaderData` |
| **Private classes** | `_LeaderData { name, title, bio, color }`, `_MinistryLeaderData { name, role, ministry }` |

### 19.3 `campuses_screen.dart` (416 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_campuses` list of `_CampusData` |
| **Private class** | `_CampusData { name, address, phone, email, pastorName, memberCount, services (List<String>), color }` |

### 19.4 `contact_us_screen.dart` (389 lines)

| Category | Detail |
|---|---|
| **Mock data** | Hardcoded church contact info (address, phone, email, hours) |
| **State** | `_nameCtrl`, `_emailCtrl`, `_subjectCtrl`, `_messageCtrl`, `_isSubmitting` |

### 19.5 `help_faq_screen.dart` (552 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_categories` list of strings, `_faqs` list of `_FaqData` |
| **State** | `_searchQuery`, `_selectedCategory` |
| **Private class** | `_FaqData { question, answer, category }` |

---

## 20. Feature: `media/` (3 files, ~1,835 lines)

### 20.1 `photo_gallery_screen.dart` (498 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_albums` list (name, count, color), `_photos` generated list of 24 `_PhotoData` items |
| **State** | `_selectedAlbum` (String) |
| **Private class** | `_PhotoData { id, title, album, date, color }` |

### 20.2 `podcast_feed_screen.dart` (759 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_episodes` list of `_EpisodeData` |
| **State** | `_subscribed` (bool), `_autoDownload` (bool), `_playingIndex` (int?) |
| **Private class** | `_EpisodeData { title, description, date, duration, isNew }` |

### 20.3 `worship_lyrics_screen.dart` (578 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_setlist` list of `_SongData` |
| **State** | `_currentSong` (int), `_autoScroll` (bool), `_showChords` (bool), `_fontSize` (double) |
| **Private classes** | `_SongData { title, author, key, bpm, sections (List<_SongSection>) }`, `_SongSection { label, lines (List<_LyricLine>) }`, `_LyricLine { text, chord? }` |

---

## 21. Feature: `volunteering/` (3 files, ~1,929 lines)

### 21.1 `volunteer_screen.dart` (650 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_ministries` list (name, emoji), `_opportunities` list of `_OpportunityData` |
| **State** | `_selectedMinistry` (String, default `'All'`) |
| **Private class** | `_OpportunityData { title, ministry, description, commitment, spotsLeft, totalSpots, skills (List<String>), isUrgent }` |

### 21.2 `service_roster_screen.dart` (550 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_months` list, `_upcoming` list of `_ShiftData`, `_past` list of `_ShiftData` |
| **State** | `_selectedTab` (int), `_selectedMonth` (int) |
| **Private class** | `_ShiftData { date, role, service, status, swapRequested }` |

### 21.3 `kids_checkin_screen.dart` (729 lines)

| Category | Detail |
|---|---|
| **Mock data** | `_children` list of `_ChildData`, `_roomAssignments` map, `_rooms` `static const` map |
| **State** | `_step` (int, multi-step flow: 0=Select, 1=Confirm, 2=Done) |
| **Private class** | `_ChildData { name, age, allergies?, notes?, selected }` — ⚠️ **mutable `selected`** |

---

## 22. Architectural Observations & Recommendations

### 22.1 Critical Issues

| # | Issue | Impact |
|---|---|---|
| 1 | **Zero data layer** — no models, repositories, or services | Cannot connect to a backend, test data logic, or share state |
| 2 | **~65+ private data classes trapped inside screen files** | Not reusable, not testable, not serializable |
| 3 | **All data is hardcoded inline** | No path to real API integration |
| 4 | **100% `setState` state management** | Will not scale; no cross-screen state sharing |
| 5 | **Mutable data classes** (`_ChatPreview.isPinned`, `_NotifData.isRead`, `_ChildData.selected`, `_ReplyData.isLiked`) | Side-effect-prone, breaks immutability principles |
| 6 | **No dependency injection** | `AuthService.instance` is a global singleton |

### 22.2 Extracted Model Candidates (by domain)

| Domain | Models to Extract |
|---|---|
| **Auth** | `User`, `AuthState` (already exists as enum) |
| **Sermons** | `Sermon`, `SermonSeries`, `SermonNote`, `SavedSermon`, `QueueItem`, `DownloadState` |
| **Events** | `ChurchEvent`, `EventRegistration` |
| **Giving** | `GivingTransaction`, `Campaign`, `CampaignDonor`, `Pledge`, `PledgePayment`, `Receipt`, `SavedPaymentCard` |
| **Bible** | `BibleBook`, `BibleChapter`, `BibleVerse`, `Devotional`, `ReadingPlan`, `ReadingPlanDay` |
| **Community** | `Announcement`, `ConnectGroup`, `GroupMember`, `DirectoryMember`, `Testimony`, `InviteLink` |
| **Chat** | `ChatConversation`, `ChatMessage`, `ChatParticipant` |
| **Forum** | `ForumCategory`, `ForumThread`, `ForumPost`, `ForumReply` |
| **Notifications** | `AppNotification`, `NotificationType` |
| **Profile** | `UserProfile`, `GivingRecord`, `UserEvent`, `PrayerRequest`, `SavedItem`, `Milestone`, `AttendanceRecord`, `NotificationPreferences` |
| **Search** | `SearchResult`, `SearchCategory` |
| **Church Info** | `ChurchInfo`, `CoreValue`, `TimelineEvent`, `Pastor`, `MinistryLeader`, `Campus`, `FaqItem` |
| **Media** | `PhotoAlbum`, `Photo`, `PodcastEpisode`, `Song`, `SongSection`, `LyricLine` |
| **Volunteering** | `VolunteerOpportunity`, `RosterShift`, `CheckInChild`, `RoomAssignment` |
| **Prayer** | `PrayerRequest` |
| **Home** | `Story`, `LiveService` |
| **Onboarding** | `OnboardingSlide` |

### 22.3 Repository Candidates

| Repository | Responsibilities |
|---|---|
| `AuthRepository` | Login, register, verify email, forgot password, profile setup |
| `SermonRepository` | Fetch sermons, series, saved sermons; manage downloads |
| `EventRepository` | Fetch events, register/unregister |
| `GivingRepository` | Process gifts, fetch history, campaigns, pledges, receipts |
| `BibleRepository` | Fetch books/chapters/verses, devotionals, reading plans |
| `CommunityRepository` | Announcements, groups, directory, testimonies |
| `ChatRepository` | Conversations list, messages, send/receive |
| `ForumRepository` | Categories, threads, posts, replies |
| `NotificationRepository` | Fetch/mark-read/delete notifications |
| `ProfileRepository` | User profile CRUD, giving history, events, saved items, attendance |
| `SearchRepository` | Global search across content types |
| `ChurchInfoRepository` | About, pastors, campuses, contact, FAQ |
| `MediaRepository` | Photo albums, podcast episodes, worship lyrics |
| `VolunteerRepository` | Opportunities, roster, kids check-in |
| `PrayerRepository` | Submit/fetch prayer requests |

### 22.4 State Management Scope

Each feature needs at minimum one provider/notifier managing:

| Feature | State Scope |
|---|---|
| **Auth** | Global — `AuthState`, current `User` |
| **Home** | Live service status, stories viewed state |
| **Sermons** | Sermon list, filters, download states, playback state (global mini-player) |
| **Events** | Event list, view mode, registrations, countdown |
| **Giving** | Transaction form state, campaign data, history |
| **Bible** | Current book/chapter/verse, highlights, night mode, reading plan progress |
| **Community** | Announcements, groups, directory |
| **Chat** | Conversation list, active conversation messages, typing state |
| **Forum** | Category list, thread list, active thread + replies |
| **Notifications** | Notification list, unread count (needed in nav bar badge) |
| **Profile** | User profile, sub-screen data |
| **Search** | Query, results, recent searches |
| **Media** | Gallery, podcast playback, lyrics view |
| **Volunteering** | Opportunities, roster, check-in flow |

### 22.5 Suggested File Structure

```
lib/
├── core/
│   ├── models/           # Shared/base models
│   ├── services/         # AuthService, ApiClient, StorageService
│   ├── providers/        # Global providers (auth, theme, connectivity)
│   ├── navigation/       # (existing) GoRouter config
│   └── theme/            # (existing) Design tokens
├── features/
│   └── <feature>/
│       ├── models/       # Feature-specific models
│       ├── repositories/ # Data access layer
│       ├── providers/    # Feature state (Riverpod/Provider)
│       └── screens/      # UI (existing screens, refactored)
└── shared/
    └── widgets/          # (existing) Reusable widgets
```

### 22.6 Migration Priority

| Priority | Action | Effort |
|---|---|---|
| 🔴 P0 | Extract all private data classes → `models/` | Medium |
| 🔴 P0 | Add state management library (Riverpod recommended) | Medium |
| 🟠 P1 | Create repository interfaces per feature | Medium |
| 🟠 P1 | Replace inline mock data with repository calls | High |
| 🟡 P2 | Add API client service + real backend integration | High |
| 🟡 P2 | Make all models immutable + add `fromJson`/`toJson` | Medium |
| 🟢 P3 | Add proper error handling, loading states, caching | Medium |
| 🟢 P3 | Extract `_ThousandsSeparatorFormatter` and other utilities | Low |

---

*End of audit. This document covers all 93 `.dart` files across 18 feature folders, `core/`, and `shared/`.*
