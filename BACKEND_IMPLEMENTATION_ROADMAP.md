# ⛪ Church App — Backend Implementation Roadmap

> **Purpose:** A comprehensive, phase-by-phase blueprint of every task, model, endpoint, service, and integration required to fully build the backend. Use this as the master checklist — nothing should be left behind.
>
> **Last Updated:** February 26, 2026
> **Frontend Status:** 64 screens, 18 feature folders — fully built with mock data
> **Backend Status:** Phases 1–6 ✅ Complete (Foundation, Core Content, Giving, Community, Real-Time & Notifications, Operations & Media)

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Phase 1 — Foundation ✅ COMPLETE](#2-phase-1--foundation--complete)
3. [Phase 2 — Core Content ✅ COMPLETE](#3-phase-2--core-content--complete)
4. [Phase 3 — Giving & Finances ✅ COMPLETE](#4-phase-3--giving--finances--complete)
5. [Phase 4 — Community & Engagement ✅ COMPLETE](#5-phase-4--community--engagement--complete)
6. [Phase 5 — Real-Time & Notifications ✅ COMPLETE](#6-phase-5--real-time--notifications--complete)
7. [Phase 6 — Operations & Media ✅ COMPLETE](#7-phase-6--operations--media--complete)
8. [Phase 7 — Polish, Jobs & Testing](#8-phase-7--polish-jobs--testing)
9. [Phase 8 — Admin Dashboard (Web)](#9-phase-8--admin-dashboard-web)
10. [Database Model Tracker](#10-database-model-tracker)
11. [API Endpoint Tracker](#11-api-endpoint-tracker)
12. [Push Notification Trigger Tracker](#12-push-notification-trigger-tracker)
13. [Background Job Tracker](#13-background-job-tracker)
14. [WebSocket Event Tracker](#14-websocket-event-tracker)
15. [File Upload Requirements](#15-file-upload-requirements)
16. [Deployment Checklist](#16-deployment-checklist)

---

## 1. Architecture Overview

| Layer | Technology | Status |
|---|---|---|
| Runtime | Node.js 20+ / TypeScript 5.9 | ✅ Installed |
| Framework | Express.js 5 | ✅ Configured |
| ORM | Prisma 7.4 (PostgreSQL adapter) | ✅ Configured |
| Database | PostgreSQL 16 | ✅ Running locally |
| Cache / Queue | Redis 8.6 + BullMQ | ✅ Redis running (Homebrew) |
| Auth | Custom JWT (bcrypt + jsonwebtoken) | ✅ Working |
| Push Notifications | Firebase Cloud Messaging (FCM only) | ✅ Service created |
| File Storage | Cloudinary (images, audio, video, docs) | ✅ Service created |
| Email | SendGrid (with dev console fallback) | ✅ Service created |
| Real-Time | Socket.io + Redis adapter | ✅ Working |
| Payments | Paystack / Stripe | ✅ Dev stubs working |
| Search | PostgreSQL full-text (upgrade to Meilisearch later) | ✅ Working |
| Validation | Zod | ✅ Working |
| Rate Limiting | Redis sliding window | ✅ Built (falls back if Redis down) |

---

## 2. Phase 1 — Foundation ✅ COMPLETE

> **Timeline:** Weeks 1–2 | **Status:** ✅ Done

### What Was Built

- [x] Project scaffold (package.json, tsconfig.json, ESM, path aliases)
- [x] Prisma schema: `Church`, `User`, `Role` enum
- [x] Prisma migration applied (`20260226122844_init`)
- [x] Database seeded (1 church, 2 users)
- [x] Config layer: env.ts, database.ts (PrismaPg adapter), cloudinary.ts, redis.ts
- [x] Utilities: apiError, apiResponse, logger, helpers
- [x] Middleware: auth (JWT), validate (Zod), rateLimiter (Redis), errorHandler
- [x] Shared services: token, email, upload (Cloudinary), push (FCM)
- [x] **Auth module** — 11 endpoints (register, login, verify email, resend verification, forgot/reset password, church code, complete setup, refresh token, logout, delete account)
- [x] **Users module** — 10 endpoints (profile CRUD, avatar upload, notification prefs, FCM token, placeholders for attendance/milestones/saved-items)
- [x] App.ts with all middleware + error handling
- [x] Server.ts with graceful shutdown
- [x] TypeScript: 0 errors
- [x] All endpoints tested via curl

### Verified Endpoints

| Route | Method | Status |
|---|---|---|
| `/health` | GET | ✅ |
| `/api/v1/auth/register` | POST | ✅ |
| `/api/v1/auth/login` | POST | ✅ |
| `/api/v1/auth/verify-email/:token` | GET | ✅ |
| `/api/v1/auth/resend-verification` | POST | ✅ |
| `/api/v1/auth/forgot-password` | POST | ✅ |
| `/api/v1/auth/reset-password` | POST | ✅ |
| `/api/v1/auth/refresh-token` | POST | ✅ |
| `/api/v1/auth/verify-church-code` | POST | ✅ |
| `/api/v1/auth/complete-setup` | POST | ✅ |
| `/api/v1/auth/logout` | POST | ✅ |
| `/api/v1/auth/account` | DELETE | ✅ |
| `/api/v1/users/me` | GET | ✅ |
| `/api/v1/users/me` | PUT | ✅ |
| `/api/v1/users/me/avatar` | PUT | ✅ |
| `/api/v1/users/me/notification-prefs` | PUT | ✅ |
| `/api/v1/users/me/fcm-token` | PUT | ✅ |

---

## 3. Phase 2 — Core Content ✅ COMPLETE

> **Timeline:** Weeks 3–4 | **Status:** ✅ Complete — 31/31 tests passed
>
> **Goal:** Build the main content the app revolves around — sermons, events, Bible, devotionals, reading plans, church info, and the home feed that aggregates it all.
>
> **Migration:** `20260226140448_phase2_core_content` applied

---

### 2A. Prisma Models to Add

```
SermonSeries       — id, churchId, title, description, imageUrl, startDate, endDate, isActive, sortOrder, timestamps
Sermon             — id, churchId, seriesId?, title, speaker, description, date, duration, audioUrl, videoUrl, thumbnailUrl, scriptureRef, tags[], likeCount, playCount, isFeatured, timestamps
UserSermonProgress — id, userId, sermonId, position (seconds), completed, lastPlayedAt, timestamps  (@@unique userId+sermonId)
UserSermonNote     — id, userId, sermonId, content (text), timestamps  (@@unique userId+sermonId)

Event              — id, churchId, title, description, category, imageUrl, location, startDate, endDate, startTime, endTime, isRecurring, recurrenceRule?, registrationRequired, maxCapacity?, registeredCount, isFeatured, tags[], timestamps
EventSpeaker       — id, eventId, name, title, imageUrl, sortOrder
EventRegistration  — id, userId, eventId, status (REGISTERED/WAITLISTED/CANCELLED), registeredAt, timestamps  (@@unique userId+eventId)

BibleBook          — id, name, abbreviation, testament (OT/NT), bookOrder, chapterCount
BibleVerse         — id, bookId, chapter, verse, text, searchVector?  (@@unique bookId+chapter+verse)
UserVerseHighlight — id, userId, verseId, color, note?, timestamps  (@@unique userId+verseId)

Devotional         — id, churchId, title, content, scriptureRef, scriptureText, date (unique), imageUrl?, authorName, timestamps
UserDevotionalRead — id, userId, devotionalId, readAt, timestamps  (@@unique userId+devotionalId)

ReadingPlan        — id, churchId, title, description, imageUrl, durationDays, category, enrolledCount, timestamps
ReadingPlanDay     — id, planId, dayNumber, title, scriptureRef, content, timestamps  (@@unique planId+dayNumber)
UserReadingPlan    — id, userId, planId, startedAt, completedAt?, currentDay, timestamps  (@@unique userId+planId)
UserReadingPlanProgress — id, userReadingPlanId, dayNumber, completedAt, timestamps  (@@unique userReadingPlanId+dayNumber)

Campus             — id, churchId, name, address, lat?, lng?, phone?, email?, imageUrl, isPrimary, timestamps
ServiceTime        — id, campusId, dayOfWeek, time, label?, timestamps
CoreValue          — id, churchId, title, description, iconUrl?, sortOrder, timestamps
StaffMember        — id, churchId, name, title, bio, imageUrl, email?, phone?, sortOrder, timestamps
FAQ                — id, churchId, question, answer, category?, sortOrder, timestamps
```

### 2B. Module: Sermons (`/api/v1/sermons`)

| # | Task | Details |
|---|---|---|
| 1 | Create Prisma models | `SermonSeries`, `Sermon`, `UserSermonProgress`, `UserSermonNote` |
| 2 | Create `sermons.validation.ts` | Schemas for list params (pagination, filter by series/speaker/date), get by ID, progress update, notes CRUD |
| 3 | Create `sermons.service.ts` | `list()` with pagination/filters, `getFeatured()`, `getById()` with user progress, `getStreamUrl()`, `saveProgress()`, `toggleBookmark()`, `getSaved()`, `getNotes()`, `saveNotes()` |
| 4 | Create `sermons.controller.ts` | Express handlers for all 11 endpoints |
| 5 | Create `sermons.routes.ts` | Protected routes + public listing |
| 6 | Create `series.service.ts` | `listSeries()`, `getSeriesById()` with sermons |
| 7 | Register in app.ts | Uncomment `sermonsRoutes` |
| 8 | Seed sample data | 2 series, 6 sermons with audio/video URLs |

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/sermons` | Optional | List sermons (paginated, filter by series/speaker/date) |
| GET | `/sermons/featured` | Optional | Featured/latest sermons |
| GET | `/sermons/:id` | Optional | Sermon detail (includes user progress if logged in) |
| GET | `/sermons/:id/stream` | Required | Get audio/video stream URL |
| POST | `/sermons/:id/progress` | Required | Save playback position (seconds) |
| POST | `/sermons/:id/save` | Required | Toggle bookmark |
| GET | `/sermons/saved` | Required | User's bookmarked sermons |
| GET | `/sermons/:id/notes` | Required | User's notes for a sermon |
| PUT | `/sermons/:id/notes` | Required | Save/update notes |
| GET | `/series` | Optional | All sermon series |
| GET | `/series/:id` | Optional | Series detail with sermon list |

---

### 2C. Module: Events (`/api/v1/events`)

| # | Task | Details |
|---|---|---|
| 1 | Create Prisma models | `Event`, `EventSpeaker`, `EventRegistration` |
| 2 | Create `events.validation.ts` | List params (upcoming/past, filter by category), registration |
| 3 | Create `events.service.ts` | `list()`, `getFeatured()`, `getById()`, `register()`, `cancelRegistration()`, `getMyEvents()` |
| 4 | Create `events.controller.ts` | Express handlers |
| 5 | Create `events.routes.ts` | Public listing + protected registration |
| 6 | Register in app.ts | Uncomment `eventsRoutes` |
| 7 | Seed sample data | 4 events with speakers |
| 8 | **Push triggers** | Wire up event reminder jobs (24h + 1h before) — BullMQ delayed jobs |

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/events` | Optional | List events (upcoming/past, category filter) |
| GET | `/events/featured` | Optional | Featured/next events |
| GET | `/events/:id` | Optional | Event detail with speakers |
| POST | `/events/:id/register` | Required | Register for event |
| DELETE | `/events/:id/register` | Required | Cancel registration |
| GET | `/events/my` | Required | User's registered events |

---

### 2D. Module: Bible & Devotionals (`/api/v1/bible`)

| # | Task | Details |
|---|---|---|
| 1 | Create Prisma models | `BibleBook`, `BibleVerse`, `UserVerseHighlight`, `Devotional`, `UserDevotionalRead`, `ReadingPlan`, `ReadingPlanDay`, `UserReadingPlan`, `UserReadingPlanProgress` |
| 2 | **Import Bible data** | Seed all 66 books + 31,102 verses (KJV or chosen translation) — likely a JSON import script |
| 3 | Create `bible.validation.ts` | Book/chapter params, search query, highlight CRUD |
| 4 | Create `bible.service.ts` | `getBooks()`, `getChapter()`, `searchVerses()`, `getHighlights()`, `addHighlight()`, `removeHighlight()` |
| 5 | Create `devotionals.service.ts` | `getToday()`, `getByDate()`, `markRead()`, `getStreak()` |
| 6 | Create `readingPlans.service.ts` | `browse()`, `getById()`, `enroll()`, `markDayComplete()`, `getMyPlans()` |
| 7 | Create controllers + routes | Bible, devotionals, and reading plans |
| 8 | Register in app.ts | Uncomment `bibleRoutes` |
| 9 | Seed data | 10 devotionals, 2 reading plans with daily content |
| 10 | **Push triggers** | Daily devotional reminder, reading plan reminder |

**Endpoints (Bible):**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/bible/books` | Public | All books with chapter counts |
| GET | `/bible/:book/:chapter` | Public | Verses for a chapter |
| GET | `/bible/search?q=` | Public | Full-text search across Bible |
| GET | `/bible/highlights` | Required | User's highlighted verses |
| POST | `/bible/highlights` | Required | Add a highlight (color + optional note) |
| DELETE | `/bible/highlights/:id` | Required | Remove a highlight |

**Endpoints (Devotionals):**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/bible/devotionals/today` | Required | Today's devotional |
| GET | `/bible/devotionals/:date` | Required | Devotional by date |
| POST | `/bible/devotionals/:id/read` | Required | Mark as read |
| GET | `/bible/devotionals/streak` | Required | Devotional reading streak |

**Endpoints (Reading Plans):**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/bible/reading-plans` | Optional | Browse available plans |
| GET | `/bible/reading-plans/:id` | Optional | Plan detail with days |
| POST | `/bible/reading-plans/:id/enroll` | Required | Join a plan |
| POST | `/bible/reading-plans/:id/progress` | Required | Mark day complete |
| GET | `/bible/reading-plans/my` | Required | User's enrolled plans with progress |

---

### 2E. Module: Church Info (`/api/v1/church`)

| # | Task | Details |
|---|---|---|
| 1 | Create Prisma models | `Campus`, `ServiceTime`, `CoreValue`, `StaffMember`, `FAQ` |
| 2 | Create `church.service.ts` | `getAbout()`, `getStaff()`, `getCampuses()`, `getFAQs()`, `submitContact()` |
| 3 | Create controller + routes | All public endpoints |
| 4 | Register in app.ts | Uncomment `churchRoutes` |
| 5 | Seed data | 1 campus, 3 service times, 3 values, 4 staff, 5 FAQs |

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/church/about` | Public | Church info, mission, vision, core values |
| GET | `/church/staff` | Public | Pastor & leader profiles |
| GET | `/church/campuses` | Public | Campuses with service times |
| GET | `/church/faqs` | Public | FAQ list |
| POST | `/church/contact` | Required | Submit contact/prayer form (sends email) |

---

### 2F. Module: Home Feed (`/api/v1/home`)

| # | Task | Details |
|---|---|---|
| 1 | Create `home.service.ts` | Aggregation endpoint — combines data from sermons, events, devotionals, live, giving campaigns, user stats |
| 2 | Create controller + route | Single endpoint |
| 3 | Register in app.ts | Uncomment `homeRoutes` |
| 4 | **Caching** | Cache home feed per-user in Redis (60s TTL) |

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/home/feed` | Required | Combined: verse of the day, latest sermon, upcoming events, live status, active campaign, devotional streak, unread notification count |

**Home Feed Response Shape:**
```jsonc
{
  "verseOfTheDay": { "reference": "...", "text": "..." },
  "latestSermon": { "id", "title", "speaker", "thumbnailUrl", "duration" },
  "upcomingEvents": [/* next 3 events */],
  "liveService": { "isLive": false, "title?", "viewerCount?" },
  "activeCampaign": { "id", "title", "goal", "raised", "percentage" },
  "devotionalStreak": { "currentStreak": 5, "todayCompleted": true },
  "unreadNotifications": 3,
  "quickActions": ["give", "bible", "prayer", "events"]
}
```

---

### 2G. Phase 2 Migration & Testing Checklist

- [x] Add all Phase 2 models to `schema.prisma`
- [x] Run `npx prisma migrate dev --name phase2_core_content`
- [x] Run `npx prisma generate`
- [x] Implement all 6 modules (sermons, events, bible, devotionals, reading plans, church info, home)
- [x] Register all routes in `app.ts`
- [x] Seed all sample data
- [x] Test every endpoint — 31/31 passed
- [x] Run `npx tsc --noEmit` — 0 errors

---

## 4. Phase 3 — Giving & Finances ✅ COMPLETE

> **Timeline:** Weeks 5–6 | **Status:** ✅ Complete — 25/25 tests passed
>
> **Goal:** Full giving system — one-time donations, recurring giving, campaigns, pledges, payment method management, receipts.
>
> **Migration:** `20260226145435_phase3_giving` applied

---

### 3A. Prisma Models to Add

```
GivingCategory     — id, churchId, name, description, isActive, sortOrder, timestamps
GivingCampaign     — id, churchId, title, description, imageUrl, goalAmount, raisedAmount, donorCount, startDate, endDate, isActive, timestamps
Donation           — id, userId, churchId, categoryId?, campaignId?, amount, currency, paymentMethod (CARD/BANK/MOBILE), paymentProvider (PAYSTACK/STRIPE), transactionRef, status (PENDING/SUCCESS/FAILED/REFUNDED), metadata (JSON), timestamps
PaymentMethod      — id, userId, type (CARD/BANK), provider, last4, brand?, expiryMonth?, expiryYear?, isDefault, providerToken, timestamps
Pledge             — id, userId, churchId, campaignId?, title, totalAmount, paidAmount, frequency (WEEKLY/MONTHLY/QUARTERLY/ANNUAL), startDate, endDate?, status (ACTIVE/COMPLETED/CANCELLED), nextDueDate, timestamps
RecurringDonation  — id, userId, churchId, categoryId, paymentMethodId, amount, currency, frequency (WEEKLY/BIWEEKLY/MONTHLY), nextChargeDate, status (ACTIVE/PAUSED/CANCELLED), failureCount, lastChargedAt?, timestamps
```

### 3B. External Integrations

| Integration | Purpose | Tasks |
|---|---|---|
| **Paystack** | Primary payment processor (Africa) | Create `paystack.service.ts` — initialize transaction, verify, charge auth, create subscription, webhooks |
| **Stripe** | Secondary payment processor (Global) | Create `stripe.service.ts` — payment intents, customer management, subscriptions, webhooks |
| **Webhook handler** | Process payment callbacks | Create `webhooks.controller.ts` — signature verification, idempotent processing |
| **PDF Generation** | Giving receipts | Install `pdfkit` or `@react-pdf/renderer`, create `receipt.service.ts` |

### 3C. Module: Giving (`/api/v1/giving`)

| # | Task | Details |
|---|---|---|
| 1 | Create Prisma models | All 6 giving models |
| 2 | Create `paystack.service.ts` | Initialize, verify, charge, refund, webhooks |
| 3 | Create `stripe.service.ts` | Payment intents, customers, subscriptions |
| 4 | Create `receipt.service.ts` | Generate PDF receipt, upload to Cloudinary, email to donor |
| 5 | Create `giving.validation.ts` | All giving input schemas |
| 6 | Create `giving.service.ts` | Donation flow, history, categories, campaigns, pledges, recurring |
| 7 | Create `giving.controller.ts` | Express handlers |
| 8 | Create `giving.routes.ts` | All protected routes |
| 9 | Create `webhooks.controller.ts` | Paystack/Stripe webhook handler (signature verify) |
| 10 | Register in app.ts | Uncomment `givingRoutes` + add webhook route |
| 11 | **Background jobs** | Recurring charge job (daily), pledge reminder job |
| 12 | **Push triggers** | Giving receipt, recurring processed, pledge due reminder, giving reminder |
| 13 | Seed data | 3 categories, 1 campaign, sample donations |

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/giving/categories` | Required | Giving categories (tithe, offering, building fund, etc.) |
| POST | `/giving/donate` | Required | Process a one-time donation |
| GET | `/giving/history` | Required | User's donation history (paginated) |
| GET | `/giving/receipts/:id` | Required | Single receipt detail |
| GET | `/giving/payment-methods` | Required | User's saved payment methods |
| POST | `/giving/payment-methods` | Required | Add a payment method |
| DELETE | `/giving/payment-methods/:id` | Required | Remove a payment method |
| GET | `/giving/campaigns` | Required | Active giving campaigns |
| GET | `/giving/campaigns/:id` | Required | Campaign detail with progress + top donors |
| POST | `/giving/campaigns/:id/donate` | Required | Donate to a specific campaign |
| GET | `/giving/pledges` | Required | User's pledges |
| POST | `/giving/pledges` | Required | Create a new pledge |
| GET | `/giving/recurring` | Required | User's recurring donation schedules |
| POST | `/giving/recurring` | Required | Set up recurring giving |
| PUT | `/giving/recurring/:id` | Required | Update recurring (amount, frequency, pause) |
| DELETE | `/giving/recurring/:id` | Required | Cancel recurring donation |
| POST | `/giving/webhooks/paystack` | Public* | Paystack webhook callback (*signature verified) |
| POST | `/giving/webhooks/stripe` | Public* | Stripe webhook callback (*signature verified) |

### 3D. Background Jobs (BullMQ)

| Job | Queue | Schedule | Details |
|---|---|---|---|
| `process-recurring-donations` | `giving` | Daily 6:00 AM | Charge all `RecurringDonation` records where `nextChargeDate <= today`. On success: update `nextChargeDate`, create `Donation`, send receipt. On failure: increment `failureCount`, retry next day (max 3). |
| `send-pledge-reminders` | `giving` | Daily 9:00 AM | Find pledges where `nextDueDate` is within 3 days. Send push notification + email. |
| `update-campaign-totals` | `giving` | On every donation | Recalculate `raisedAmount` and `donorCount` on the campaign. |

### 3E. Phase 3 Checklist

- [x] Add all Phase 3 models to `schema.prisma`
- [x] Run migration `phase3_giving`
- [ ] Install Redis locally (`brew install redis`) — deferred to Phase 5
- [x] Install BullMQ job processing infrastructure — ✅ done in Phase 7
- [x] Install `pdfkit` for receipt generation
- [x] Implement Paystack integration (with `isDevStub()` for dev mode)
- [x] Implement Stripe integration (with `isDevStub()` for dev mode)
- [x] Implement all giving endpoints (18 endpoints)
- [x] Implement webhook handlers with signature verification
- [x] Implement receipt PDF generation + Cloudinary upload + email
- [x] Create recurring donation + pledge reminder background jobs — ✅ done in Phase 7 (BullMQ)
- [ ] Wire up all 4 giving push triggers — deferred to Phase 5 (notification service)
- [x] Seed sample data (categories, campaigns, donations, payment methods, pledges, recurring)
- [x] Test all endpoints — 25/25 passed
- [x] `npx tsc --noEmit` — 0 errors

---

## 5. Phase 4 — Community & Engagement ✅ COMPLETE

> **Timeline:** Weeks 7–8 | **Status:** ✅ Complete — 30/30 tests passed
>
> **Goal:** Build community features — groups, announcements, testimonies, forum, prayer requests, church directory, and invite system.
>
> **Migration:** `20260226155214_phase4_community` applied

---

### 4A. Prisma Models to Add

```
ConnectGroup       — id, churchId, name, description, imageUrl, category (BIBLE_STUDY/YOUTH/WOMEN/MEN/COUPLES/PRAYER/SERVICE), meetingDay, meetingTime, location, leaderId (→User), maxMembers?, memberCount, isActive, timestamps
GroupMembership    — id, userId, groupId, role (MEMBER/LEADER), joinedAt, timestamps  (@@unique userId+groupId)

Announcement       — id, churchId, title, content, imageUrl?, category?, isUrgent, isPinned, publishedAt, expiresAt?, authorId (→User), timestamps
AnnouncementRead   — id, userId, announcementId, readAt, timestamps  (@@unique userId+announcementId)

Testimony          — id, userId, churchId, title, content, isAnonymous, status (PENDING/APPROVED/REJECTED), approvedAt?, approvedById?, likeCount, prayerCount, timestamps
TestimonyReaction  — id, userId, testimonyId, type (LIKE/PRAY), timestamps  (@@unique userId+testimonyId)

ForumCategory      — id, churchId, name, description, iconUrl?, threadCount, sortOrder, timestamps
ForumThread        — id, categoryId, churchId, authorId (→User), title, content, isPinned, isLocked, viewCount, likeCount, replyCount, lastActivityAt, timestamps
ForumReply         — id, threadId, authorId (→User), content, likeCount, timestamps
ForumLike          — id, userId, threadId?, replyId?, timestamps  (@@unique userId+threadId or userId+replyId)
ForumBookmark      — id, userId, threadId, timestamps  (@@unique userId+threadId)

PrayerRequest      — id, userId, churchId, title, content, isAnonymous, isUrgent, status (ACTIVE/ANSWERED/CLOSED), prayerCount, timestamps
PrayerInteraction  — id, userId, prayerRequestId, type (PRAYED), timestamps  (@@unique userId+prayerRequestId)

InviteLink         — id, userId, churchId, code (unique), usedCount, maxUses?, expiresAt, timestamps
```

### 4B. Module: Groups (`/api/v1/groups`)

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/groups` | Required | List groups (filter by category, search) |
| GET | `/groups/:id` | Required | Group detail with member list |
| POST | `/groups/:id/join` | Required | Join a group |
| DELETE | `/groups/:id/leave` | Required | Leave a group |

### 4C. Module: Announcements (nested under community or separate)

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/community/announcements` | Required | Announcements (paginated, filter by category) |
| GET | `/community/announcements/:id` | Required | Announcement detail |
| POST | `/community/announcements/:id/read` | Required | Mark as read |

### 4D. Module: Testimonies

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/community/testimonies` | Required | Approved testimonies (paginated) |
| POST | `/community/testimonies` | Required | Submit a testimony |
| POST | `/community/testimonies/:id/react` | Required | Like or "I prayed" reaction |

### 4E. Module: Forum (`/api/v1/forum`)

| # | Task | Details |
|---|---|---|
| 1 | Create all forum Prisma models | `ForumCategory`, `ForumThread`, `ForumReply`, `ForumLike`, `ForumBookmark` |
| 2 | Create `forum.service.ts` | Categories, trending, recent, threads by category, thread detail, create thread, create reply, toggle like, toggle bookmark |
| 3 | Create controller + routes | All 10 endpoints |

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/forum/categories` | Required | Categories with thread counts |
| GET | `/forum/trending` | Required | Trending threads (by likes + replies in last 7 days) |
| GET | `/forum/recent` | Required | Most recent threads |
| GET | `/forum/categories/:id/threads` | Required | Threads in a category (paginated) |
| GET | `/forum/threads/:id` | Required | Thread detail with replies (paginated) |
| POST | `/forum/threads` | Required | Create a new thread |
| POST | `/forum/threads/:id/replies` | Required | Reply to a thread |
| POST | `/forum/threads/:id/like` | Required | Toggle like on thread |
| POST | `/forum/threads/:id/bookmark` | Required | Toggle bookmark |
| POST | `/forum/replies/:id/like` | Required | Like a reply |

### 4F. Module: Prayer Requests (`/api/v1/prayer-requests`)

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/prayer-requests` | Required | Public prayer requests (paginated) |
| GET | `/prayer-requests/my` | Required | User's own requests |
| POST | `/prayer-requests` | Required | Submit a prayer request |
| POST | `/prayer-requests/:id/pray` | Required | "I prayed for this" |
| PUT | `/prayer-requests/:id/status` | Required | Update status (ANSWERED/CLOSED) — owner only |

### 4G. Module: Directory & Invites

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/community/directory` | Required | Church member directory (filtered by `isDirectoryVisible`) |
| POST | `/community/invite/generate` | Required | Generate invite link with unique code |
| GET | `/community/invite/:code` | Public | Validate invite link |

### 4H. Push Notification Triggers (Phase 4)

| Trigger | When | Recipients |
|---|---|---|
| New urgent announcement | On publish (isUrgent=true) | All church members |
| New normal announcement | On publish | All church members |
| Group activity update | New member joins or event | Group members |
| Forum reply to your thread | Reply created | Thread author |
| Forum reply to bookmarked thread | Reply created | Thread bookmarkers |
| Someone prayed for your request | PrayerInteraction created | Request author |
| Prayer request marked answered | Status updated | All who prayed |

### 4I. Phase 4 Checklist

- [x] Add all Phase 4 models to `schema.prisma` (5 enums + 14 models)
- [x] Run migration `phase4_community`
- [x] Implement groups module (4 endpoints)
- [x] Implement announcements module (3 endpoints)
- [x] Implement testimonies module (3 endpoints)
- [x] Implement forum module (10 endpoints)
- [x] Implement prayer requests module (5 endpoints)
- [x] Implement directory + invite module (4 endpoints: directory, generate, validate, stats)
- [x] Register all routes in `app.ts`
- [ ] Wire up all 7 push triggers — deferred to Phase 5 (notification service)
- [x] Seed community data (6 groups, 4 announcements, 4 testimonies, 8 forum categories, 4 threads, 5 replies, 5 prayer requests, 1 invite)
- [x] Test all endpoints — 30/30 passed
- [x] `npx tsc --noEmit` — 0 errors

---

## 6. Phase 5 — Real-Time & Notifications ✅ COMPLETE

> **Timeline:** Weeks 9–10 | **Status:** ✅ Complete — 18/18 tests passed
>
> **Goal:** Add Socket.io for real-time chat, live service experience, and notification system. Wire up push notification triggers across all existing modules.

---

### 5A. Prisma Models to Add

```
Conversation       — id, churchId, type (DIRECT/GROUP), name?, imageUrl?, createdById, lastMessageAt, timestamps
ConversationMember — id, conversationId, userId, role (MEMBER/ADMIN), isPinned, isMuted, lastReadAt, joinedAt, timestamps  (@@unique conversationId+userId)
Message            — id, conversationId, senderId (→User), content, type (TEXT/IMAGE/AUDIO/VIDEO/SYSTEM), mediaUrl?, replyToId? (→Message), isEdited, isDeleted, timestamps

Notification       — id, userId, type (enum: SERMON/EVENT/CHAT/GIVING/PRAYER/ANNOUNCEMENT/GROUP/FORUM/VOLUNTEER/KIDS/DEVOTIONAL/PERSONAL/SECURITY/SYSTEM), title, body, data (JSON — entityId, entityType, deepLink), isRead, readAt?, timestamps

LiveService        — id, churchId, title, description, streamUrl?, status (SCHEDULED/LIVE/ENDED), scheduledAt, startedAt?, endedAt?, viewerCount, timestamps
LiveChatMessage    — id, liveServiceId, userId, content, type (MESSAGE/PRAYER/REACTION), timestamps
```

### 5B. Socket.io Architecture

| # | Task | Details |
|---|---|---|
| 1 | Install + configure Socket.io | Attach to HTTP server, JWT authentication middleware for socket connections |
| 2 | Create `socket.service.ts` | Central socket manager — authenticate, join rooms, emit events |
| 3 | Create `chat.socket.ts` | Namespace: `/chat` — send message, typing indicator, read receipt, online status |
| 4 | Create `live.socket.ts` | Namespace: `/live` — join service room, live chat, reactions, viewer count, prayer request |
| 5 | Create `notification.socket.ts` | Namespace: `/notifications` — real-time notification push to connected clients |
| 6 | **Redis adapter** | Use `@socket.io/redis-adapter` for horizontal scaling |
| 7 | **Online presence** | Track online users in Redis SET, broadcast status changes |

### 5C. Module: Chat (`/api/v1/chat`)

**Endpoints (REST + WebSocket):**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/chat/conversations` | Required | User's conversations (with last message, unread count) |
| POST | `/chat/conversations` | Required | Create conversation (direct or group) |
| GET | `/chat/conversations/:id/messages` | Required | Messages (paginated, cursor-based) |
| POST | `/chat/conversations/:id/messages` | Required | Send message (also emits via Socket) |
| PUT | `/chat/conversations/:id/read` | Required | Mark conversation as read |
| PUT | `/chat/conversations/:id/pin` | Required | Toggle pin |
| PUT | `/chat/conversations/:id/mute` | Required | Toggle mute |

**WebSocket Events:**
| Event | Direction | Payload |
|---|---|---|
| `chat:message` | Server → Client | New message in conversation |
| `chat:typing` | Client ↔ Server | User is typing indicator |
| `chat:read` | Server → Client | Read receipt update |
| `chat:online` | Server → Client | User online/offline status change |

### 5D. Module: Notifications (`/api/v1/notifications`)

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/notifications` | Required | User's notifications (paginated, filter by type, unread) |
| PUT | `/notifications/:id/read` | Required | Mark single notification as read |
| PUT | `/notifications/read-all` | Required | Mark all as read |
| DELETE | `/notifications/:id` | Required | Dismiss a notification |

**Notification Service Tasks:**
| # | Task |
|---|---|
| 1 | Create `notification.service.ts` — `create()`, `markRead()`, `markAllRead()`, `delete()`, `getUnreadCount()` |
| 2 | Every notification creation should: save to DB, emit via Socket.io, send FCM push (if user offline + prefs allow) |
| 3 | Wire up **ALL 24 push notification triggers** across all existing modules |
| 4 | Implement user preference checking — respect per-category toggles and quiet hours |

### 5E. Module: Live Service (`/api/v1/live`)

**Endpoints (REST + WebSocket):**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/live/current` | Optional | Current live service info (or null if not live) |
| POST | `/live/:id/chat` | Required | Send live chat message (REST fallback) |
| POST | `/live/:id/prayer` | Required | Submit live prayer request |

**WebSocket Events (namespace `/live`):**
| Event | Direction | Payload |
|---|---|---|
| `live:join` | Client → Server | Join live room |
| `live:leave` | Client → Server | Leave live room |
| `live:message` | Server → Client | New live chat message |
| `live:reaction` | Client ↔ Server | Emoji reaction burst |
| `live:viewers` | Server → Client | Updated viewer count |
| `live:prayer` | Client → Server | Live prayer request |
| `live:status` | Server → Client | Service status change (LIVE/ENDED) |

### 5F. All 24 Push Notification Triggers — Master Wiring

| # | Trigger | Source Module | Priority | Category |
|---|---|---|---|---|
| 1 | New sermon published | Sermons (Phase 2) | Normal | `sermons` |
| 2 | Live service started | Live (Phase 5) | **High** | `live` |
| 3 | Event reminder — 24h before | Events (Phase 2) | Normal | `events` |
| 4 | Event reminder — 1h before | Events (Phase 2) | **High** | `events` |
| 5 | New chat message (user offline) | Chat (Phase 5) | **High** | `chat` |
| 6 | Giving receipt confirmation | Giving (Phase 3) | Normal | `giving` |
| 7 | Recurring donation processed | Giving (Phase 3) | Normal | `giving` |
| 8 | Pledge due reminder (3 days) | Giving (Phase 3) | Normal | `giving` |
| 9 | Giving reminder (user-set) | Giving (Phase 3) | Normal | `giving` |
| 10 | Someone prayed for your request | Prayer (Phase 4) | Normal | `prayer` |
| 11 | Prayer request marked answered | Prayer (Phase 4) | Normal | `prayer` |
| 12 | New urgent announcement | Community (Phase 4) | **High** | `announcements` |
| 13 | New normal announcement | Community (Phase 4) | Normal | `announcements` |
| 14 | Group activity update | Groups (Phase 4) | Normal | `groups` |
| 15 | Forum reply to your thread | Forum (Phase 4) | Normal | `forum` |
| 16 | Forum reply to bookmarked thread | Forum (Phase 4) | Low | `forum` |
| 17 | Volunteer shift reminder (24h) | Volunteer (Phase 6) | Normal | `volunteering` |
| 18 | Volunteer shift swap approved | Volunteer (Phase 6) | Normal | `volunteering` |
| 19 | Kids check-in alert | Kids (Phase 6) | **High** | `kids` |
| 20 | Daily devotional reminder | Devotionals (Phase 2) | Normal | `devotionals` |
| 21 | Reading plan reminder | Reading Plans (Phase 2) | Normal | `devotionals` |
| 22 | Birthday/anniversary greeting | Cron job (Phase 7) | Normal | `personal` |
| 23 | Welcome message (new user) | Auth (Phase 1) | Normal | `system` |
| 24 | Account security alert | Auth (Phase 1) | **High** | `security` |

### 5G. What Was Built

- [x] Add 6 enums + 6 models to `schema.prisma` (Conversation, ConversationMember, Message, Notification, LiveService, LiveChatMessage)
- [x] Run migration `20260226174757_phase5_realtime`
- [x] **Install and start Redis** locally (Redis 8.6.1 via Homebrew, running as service)
- [x] Configure Socket.io with JWT auth middleware + **Redis adapter** for horizontal scaling
- [x] Create `src/socket/index.ts` — Central socket manager: auth, presence tracking (Redis SET), room management
- [x] Create `src/socket/chat.socket.ts` — Chat real-time events (message, typing, read, join)
- [x] Create `src/socket/live.socket.ts` — Live service events (join, leave, message, reaction, prayer)
- [x] Create `src/socket/notification.socket.ts` — Notification socket events (read, read-all, unread-count)
- [x] Implement chat module — 7 REST endpoints + WebSocket events
- [x] Implement notification module — 5 endpoints (list, unread-count, mark-read, mark-all-read, delete)
- [x] Implement live service module — 4 endpoints (list, current, get-by-id, chat-messages) + WebSocket events
- [x] Implement online presence tracking (Redis SET: `online:{churchId}`)
- [x] Create `notification.service.ts` — Central dispatcher: DB + Socket.io + FCM push
- [x] Create `notification.triggers.ts` — 20+ trigger functions covering events, giving, groups, prayer, forum, community, live, security
- [x] **Wire notification triggers** into 6 existing service files (community, prayer, forum, groups, events, giving)
- [x] Register chat, notifications, live routes in `app.ts`
- [x] Update `server.ts` with `initializeSocket(server)` call
- [x] Seed: 2 conversations + 4 messages, 6 notifications, 3 live services + 5 chat messages
- [x] `npx tsc --noEmit` — 0 errors
- [x] All 18 endpoint tests passed

### Verified Endpoints

| Route | Method | Status |
|---|---|---|
| `/api/v1/notifications` | GET | ✅ |
| `/api/v1/notifications/unread-count` | GET | ✅ |
| `/api/v1/notifications/:id/read` | PUT | ✅ |
| `/api/v1/notifications/read-all` | PUT | ✅ |
| `/api/v1/notifications/:id` | DELETE | ✅ |
| `/api/v1/chat/conversations` | GET | ✅ |
| `/api/v1/chat/conversations` | POST | ✅ |
| `/api/v1/chat/conversations/:id/messages` | GET | ✅ |
| `/api/v1/chat/conversations/:id/messages` | POST | ✅ |
| `/api/v1/chat/conversations/:id/read` | PUT | ✅ |
| `/api/v1/chat/conversations/:id/pin` | PUT | ✅ |
| `/api/v1/chat/conversations/:id/mute` | PUT | ✅ |
| `/api/v1/live` | GET | ✅ |
| `/api/v1/live/current` | GET | ✅ |
| `/api/v1/live/:id` | GET | ✅ |
| `/api/v1/live/:id/chat` | GET | ✅ |

### New Files Created

| File | Description |
|---|---|
| `src/socket/index.ts` | Socket.io server + Redis adapter + presence |
| `src/socket/chat.socket.ts` | Chat WebSocket handlers |
| `src/socket/live.socket.ts` | Live service WebSocket handlers |
| `src/socket/notification.socket.ts` | Notification WebSocket handlers |
| `src/services/notification.service.ts` | Central notification dispatcher |
| `src/services/notification.triggers.ts` | 20+ trigger functions |
| `src/modules/notifications/notification.validation.ts` | Zod schemas |
| `src/modules/notifications/notification.controller.ts` | Route handlers |
| `src/modules/notifications/notification.routes.ts` | Express routes |
| `src/modules/chat/chat.validation.ts` | Zod schemas |
| `src/modules/chat/chat.service.ts` | Chat business logic |
| `src/modules/chat/chat.controller.ts` | Route handlers |
| `src/modules/chat/chat.routes.ts` | Express routes |
| `src/modules/live/live.validation.ts` | Zod schemas |
| `src/modules/live/live.service.ts` | Live service business logic |
| `src/modules/live/live.controller.ts` | Route handlers |
| `src/modules/live/live.routes.ts` | Express routes |

---

## 7. Phase 6 — Operations & Media ✅ COMPLETE

> **Timeline:** Weeks 11–12 | **Status:** ✅ Complete — 40/40 tests passed
>
> **Goal:** Volunteering system, kids check-in, media library (photos, podcasts, worship lyrics), and unified search.
>
> **Migration:** `phase6_operations_media` applied
>
> **Dependencies added:** `qrcode`, `@types/qrcode`

---

### 6A. Prisma Schema Additions

**4 new enums:**
```
VolunteerSignupStatus — PENDING, APPROVED, REJECTED
ShiftStatus           — SCHEDULED, CHECKED_IN, COMPLETED, SWAPPED
CheckInStatus         — CHECKED_IN, CHECKED_OUT
SongSectionType       — VERSE, CHORUS, BRIDGE, PRE_CHORUS, OUTRO
```

**Updated enum:**
```
NotificationType — added KIDS
```

**13 new models:**
```
VolunteerOpportunity — id, churchId, title, description, department, requirements, imageUrl, isActive, timestamps
VolunteerSignup      — id, userId, opportunityId, status (PENDING/APPROVED/REJECTED), appliedAt, timestamps  (@@unique userId+opportunityId)
RosterShift          — id, churchId, userId, opportunityId, date, startTime, endTime, status (SCHEDULED/CHECKED_IN/COMPLETED/SWAPPED), checkinAt?, timestamps

Child                — id, parentId (→User), churchId, firstName, lastName, dateOfBirth, allergies?, medicalNotes?, photoUrl?, timestamps
Room                 — id, churchId, name, ageGroup, capacity, currentCount, timestamps
CheckIn              — id, childId, roomId, parentId (→User), checkedInBy (→User), securityCode, qrCodeData, status (CHECKED_IN/CHECKED_OUT), checkedInAt, checkedOutAt?, timestamps

PhotoAlbum           — id, churchId, title, description?, coverImageUrl?, photoCount, eventId?, timestamps
Photo                — id, albumId, churchId, uploadedById (→User), imageUrl, thumbnailUrl, caption?, timestamps

PodcastEpisode       — id, churchId, title, description, audioUrl, duration, thumbnailUrl?, publishedAt, playCount, timestamps
UserPodcastProgress  — id, userId, episodeId, position (seconds), completed, timestamps  (@@unique userId+episodeId)

WorshipSong          — id, churchId, title, artist, key?, tempo?, tags[], timestamps
SongSection          — id, songId, type (VERSE/CHORUS/BRIDGE/PRE_CHORUS/OUTRO), sortOrder, timestamps
LyricLine           — id, sectionId, lineNumber, lyrics, chords?, timestamps
```

### 6B. Module: Volunteering (`/api/v1/volunteer`)

| # | Task | Details |
|---|---|---|
| 1 | Create Prisma models | `VolunteerOpportunity`, `VolunteerSignup`, `RosterShift` |
| 2 | Create `volunteer.validation.ts` | Schemas for listing, signup, check-in, shift swap |
| 3 | Create `volunteer.service.ts` | `listOpportunities()`, `signup()`, `getRoster()`, `checkin()`, `swapShift()` |
| 4 | Create `volunteer.controller.ts` | Express handlers for all 5 endpoints |
| 5 | Create `volunteer.routes.ts` | Protected routes |
| 6 | Register in app.ts | Uncomment `volunteerRoutes` |
| 7 | Seed sample data | 4 opportunities, 2 signups, 3 roster shifts |

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/volunteer/opportunities` | Required | List volunteer opportunities (paginated, filter by active) |
| POST | `/volunteer/signup` | Required | Sign up for a volunteer opportunity |
| GET | `/volunteer/roster` | Required | Get volunteer roster/shifts (upcoming/past) |
| POST | `/volunteer/checkin` | Required | Check in for a shift |
| POST | `/volunteer/swap-shift` | Required | Request a shift swap |

### 6C. Module: Kids Check-In (`/api/v1/kids`)

| # | Task | Details |
|---|---|---|
| 1 | Install QR code library | `qrcode` + `@types/qrcode` npm packages |
| 2 | Create `kids.validation.ts` | Schemas for listing, register, check-in, check-out, rooms |
| 3 | Create `kids.service.ts` | `listChildren()`, `registerChild()`, `checkin()` (generates QR + security code), `checkout()` (validates security code), `listRooms()` |
| 4 | Create `kids.controller.ts` | Express handlers for all 5 endpoints |
| 5 | Create `kids.routes.ts` | Protected routes |
| 6 | Register in app.ts | Uncomment `kidsRoutes` |
| 7 | **Push triggers** | `notifyKidsCheckIn()`, `notifyKidsCheckOut()` — notify parent on child check-in/out |
| 8 | Seed sample data | 3 children, 3 rooms, 2 check-ins |

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/kids/children` | Required | List registered children |
| POST | `/kids/register` | Required | Register a child |
| POST | `/kids/checkin` | Required | Check in a child (generates QR code + security code) |
| POST | `/kids/checkout` | Required | Check out a child (validates security code) |
| GET | `/kids/rooms` | Required | List rooms with availability |

### 6D. Module: Media Library (`/api/v1/media`)

| # | Task | Details |
|---|---|---|
| 1 | Create Prisma models | `PhotoAlbum`, `Photo`, `PodcastEpisode`, `UserPodcastProgress`, `WorshipSong`, `SongSection`, `LyricLine` |
| 2 | Create `media.validation.ts` | Schemas for albums, photos, podcasts, progress, songs, search |
| 3 | Create `media.service.ts` | `listAlbums()`, `createAlbum()`, `getAlbumDetail()`, `addPhoto()`, `listPodcasts()`, `getPodcastDetail()`, `updatePodcastProgress()`, `listSongs()`, `searchSongs()`, `getSongDetail()` |
| 4 | Create `media.controller.ts` | Express handlers for all 10 endpoints |
| 5 | Create `media.routes.ts` | Protected routes |
| 6 | Register in app.ts | Uncomment `mediaRoutes` |
| 7 | Seed sample data | 2 albums with 4 photos, 3 podcast episodes, 3 worship songs with sections & lyrics |

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/media/albums` | Required | List photo albums |
| POST | `/media/albums` | Required | Create a photo album |
| GET | `/media/albums/:id` | Required | Get album details with photos |
| POST | `/media/albums/:id/photos` | Required | Upload/add a photo to album |
| GET | `/media/podcasts` | Required | List podcast episodes (paginated) |
| GET | `/media/podcasts/:id` | Required | Get podcast episode detail |
| POST | `/media/podcasts/:id/progress` | Required | Update podcast progress (also increments play count) |
| GET | `/media/songs` | Required | List worship songs |
| GET | `/media/songs/search` | Required | Search worship songs |
| GET | `/media/songs/:id` | Required | Get worship song with sections & lyrics |

### 6E. Module: Unified Search (`/api/v1/search`)

| # | Task | Details |
|---|---|---|
| 1 | Create `search.validation.ts` | Schemas for search query, type filter, trending |
| 2 | Create `search.service.ts` | Unified search across: sermons, events, groups, users, forums, albums, podcasts |
| 3 | Use PostgreSQL `ILIKE` / full-text | Search on key text columns across 7 entity types |
| 4 | Trending content | Calculate trending by play count, registrations, memberships |
| 5 | Create `search.controller.ts` | Express handlers for 2 endpoints |
| 6 | Create `search.routes.ts` | Protected routes |
| 7 | Register in app.ts | Uncomment `searchRoutes` |

**Endpoints:**
| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/search` | Required | Search across sermons, events, groups, users, forums, albums, podcasts |
| GET | `/search/trending` | Required | Get trending content (by play count, registrations, memberships) |

### 6F. Push Notification Triggers (Phase 6)

| Trigger | When | Recipients | Function |
|---|---|---|---|
| Kids check-in alert | Child checked in | Parent | `notifyKidsCheckIn()` |
| Kids check-out alert | Child checked out | Parent | `notifyKidsCheckOut()` |
| Volunteer signup approved | Signup status → APPROVED | Volunteer | `notifyVolunteerSignupApproved()` |
| Volunteer shift reminder (24h) | Cron job | Volunteer | `notifyVolunteerShiftReminder()` |
| Volunteer shift swap | Swap requested | Other volunteer | `notifyVolunteerShiftSwap()` |

### 6G. What Was Built

- [x] Add 4 enums + 13 models to `schema.prisma` (VolunteerOpportunity, VolunteerSignup, RosterShift, Child, Room, CheckIn, PhotoAlbum, Photo, PodcastEpisode, UserPodcastProgress, WorshipSong, SongSection, LyricLine)
- [x] Added `KIDS` to existing `NotificationType` enum
- [x] Run migration `phase6_operations_media`
- [x] Install `qrcode` + `@types/qrcode` for kids check-in QR code generation
- [x] Implement volunteering module — 5 endpoints (opportunities, signup, roster, checkin, swap-shift)
- [x] Implement kids check-in module — 5 endpoints (children, register, checkin, checkout, rooms)
- [x] Implement media library module — 10 endpoints (albums CRUD, photos, podcasts, progress, songs, search)
- [x] Implement unified search module — 2 endpoints (search across 7 entity types, trending content)
- [x] Register all routes in `app.ts` (volunteer, kids, media, search)
- [x] Wire up 5 push notification triggers (notifyKidsCheckIn, notifyKidsCheckOut, notifyVolunteerSignupApproved, notifyVolunteerShiftReminder, notifyVolunteerShiftSwap)
- [x] Seed data: 4 volunteer opportunities, 2 signups, 3 roster shifts, 3 children, 3 rooms, 2 check-ins, 2 albums with 4 photos, 3 podcast episodes, 3 worship songs with sections & lyrics
- [x] `npx tsc --noEmit` — 0 errors
- [x] All 40 endpoint tests passed

### Verified Endpoints

| Route | Method | Status |
|---|---|---|
| `/api/v1/volunteer/opportunities` | GET | ✅ |
| `/api/v1/volunteer/signup` | POST | ✅ |
| `/api/v1/volunteer/roster` | GET | ✅ |
| `/api/v1/volunteer/checkin` | POST | ✅ |
| `/api/v1/volunteer/swap-shift` | POST | ✅ |
| `/api/v1/kids/children` | GET | ✅ |
| `/api/v1/kids/register` | POST | ✅ |
| `/api/v1/kids/checkin` | POST | ✅ |
| `/api/v1/kids/checkout` | POST | ✅ |
| `/api/v1/kids/rooms` | GET | ✅ |
| `/api/v1/media/albums` | GET | ✅ |
| `/api/v1/media/albums` | POST | ✅ |
| `/api/v1/media/albums/:id` | GET | ✅ |
| `/api/v1/media/albums/:id/photos` | POST | ✅ |
| `/api/v1/media/podcasts` | GET | ✅ |
| `/api/v1/media/podcasts/:id` | GET | ✅ |
| `/api/v1/media/podcasts/:id/progress` | POST | ✅ |
| `/api/v1/media/songs` | GET | ✅ |
| `/api/v1/media/songs/search` | GET | ✅ |
| `/api/v1/media/songs/:id` | GET | ✅ |
| `/api/v1/search` | GET | ✅ |
| `/api/v1/search/trending` | GET | ✅ |

### New Files Created

| File | Description |
|---|---|
| `src/modules/volunteer/volunteer.validation.ts` | Zod schemas |
| `src/modules/volunteer/volunteer.service.ts` | Volunteering business logic |
| `src/modules/volunteer/volunteer.controller.ts` | Route handlers |
| `src/modules/volunteer/volunteer.routes.ts` | Express routes |
| `src/modules/kids/kids.validation.ts` | Zod schemas |
| `src/modules/kids/kids.service.ts` | Kids check-in business logic (QR generation) |
| `src/modules/kids/kids.controller.ts` | Route handlers |
| `src/modules/kids/kids.routes.ts` | Express routes |
| `src/modules/media/media.validation.ts` | Zod schemas |
| `src/modules/media/media.service.ts` | Media library business logic |
| `src/modules/media/media.controller.ts` | Route handlers |
| `src/modules/media/media.routes.ts` | Express routes |
| `src/modules/search/search.validation.ts` | Zod schemas |
| `src/modules/search/search.service.ts` | Unified search business logic |
| `src/modules/search/search.controller.ts` | Route handlers |
| `src/modules/search/search.routes.ts` | Express routes |

---

## 8. Phase 7 — Polish, Jobs & Testing ✅ COMPLETE

> **Timeline:** Weeks 13–14 | **Status:** ✅ Complete
>
> **Goal:** Background jobs, attendance tracking, spiritual journey, caching, email templates, documentation, and testing.

---

### 7A. Prisma Models to Add

```
Attendance          — id, userId, churchId, serviceDate, serviceType (SUNDAY/MIDWEEK/SPECIAL), checkinMethod (MANUAL/QR/GEOFENCE), timestamps  (@@unique userId+serviceDate+serviceType)
SpiritualMilestone  — id, userId, churchId, type (SALVATION/BAPTISM/FIRST_SERVE/SMALL_GROUP/MINISTRY_LEADER/FIRST_GIVE/ONE_YEAR/INVITE_FRIEND), title, description, achievedAt, iconUrl?, timestamps
SavedItem           — id, userId, entityType (SERMON/EVENT/DEVOTIONAL/VERSE/THREAD/SONG), entityId, timestamps  (@@unique userId+entityType+entityId)
```

### 7B. Background Jobs (Complete BullMQ System)

| Job | Queue | Schedule | Details |
|---|---|---|---|
| `process-recurring-donations` | `giving` | Daily 6:00 AM | Charge via Paystack/Stripe |
| `send-pledge-reminders` | `giving` | Daily 9:00 AM | Push + email for pledges due in 3 days |
| `send-event-reminders` | `events` | Every 15 min | Push 24h and 1h before events |
| `publish-daily-devotional` | `devotionals` | Daily 5:00 AM | Ensure today's devotional exists; send push |
| `send-reading-plan-reminders` | `devotionals` | Daily 7:00 AM | Push for users enrolled in active plans |
| `calculate-attendance-streaks` | `attendance` | Daily midnight | Update consecutive attendance counts |
| `generate-milestones` | `milestones` | On key events | Auto-create spiritual journey milestones |
| `cleanup-expired-data` | `maintenance` | Daily 2:00 AM | Remove expired invites, stale FCM tokens, old sessions |
| `send-birthday-greetings` | `personal` | Daily 8:00 AM | Push + email for birthday/anniversary |
| `rebuild-search-indexes` | `maintenance` | Weekly Sunday 3:00 AM | Refresh full-text search indexes |
| `send-volunteer-shift-reminders` | `volunteering` | Every 15 min | Push 24h before shift |

**BullMQ Infrastructure Tasks:**
| # | Task |
|---|---|
| 1 | Create `src/jobs/queue.ts` — BullMQ queue factory with Redis connection |
| 2 | Create `src/jobs/worker.ts` — Central worker that processes all queues |
| 3 | Create `src/jobs/scheduler.ts` — Define all cron-based repeatable jobs |
| 4 | Create individual job processors: `recurringDonation.job.ts`, `eventReminder.job.ts`, `devotionalPublish.job.ts`, etc. |
| 5 | Add BullMQ dashboard (optional — `bull-board` for dev) |
| 6 | Start workers alongside server in `server.ts` |

### 7C. Attendance & Spiritual Journey

**Tasks:**
| # | Task |
|---|---|
| 1 | Create attendance service — record, list history, calculate streaks |
| 2 | Create milestones service — auto-generate milestones on: first login, first give, first serve, join group, 1 year, baptism date, invite friend |
| 3 | Implement saved items service — polymorphic bookmarks across all content types |
| 4 | Complete the placeholder endpoints in the users module |

### 7D. Caching Strategy (Redis)

| Cache Key Pattern | TTL | Data |
|---|---|---|
| `home:feed:{userId}` | 60s | Home feed response |
| `sermons:list:{page}:{filters}` | 5 min | Sermon listings |
| `events:upcoming` | 5 min | Upcoming events |
| `bible:{book}:{chapter}` | 24h | Bible chapter (immutable) |
| `church:about:{churchId}` | 1h | Church info |
| `search:trending` | 15 min | Trending search terms |
| `live:viewers:{serviceId}` | N/A | Live viewer count (Redis counter) |
| `online:{churchId}` | N/A | Online users (Redis SET) |

### 7E. Email Templates

| Template | Trigger | Content |
|---|---|---|
| Welcome email | Registration complete | Welcome message + getting started guide |
| Email verification | Registration | Verify link |
| Password reset | Forgot password | Reset link (1h expiry) |
| Giving receipt | Donation processed | PDF receipt attachment |
| Recurring donation summary | Monthly | Summary of all recurring charges |
| Event registration | Register for event | Confirmation + calendar invite (.ics) |
| Pledge reminder | Pledge due | Amount + payment link |
| Volunteer shift | Shift assigned/reminder | Date, time, location |

### 7F. API Documentation

| # | Task |
|---|---|
| 1 | Install `swagger-jsdoc` + `swagger-ui-express` |
| 2 | Add JSDoc annotations to all route files |
| 3 | Generate OpenAPI 3.0 spec |
| 4 | Mount Swagger UI at `/api/docs` |
| 5 | Export Postman collection from spec |

### 7G. Testing

| # | Task | Tool |
|---|---|---|
| 1 | Unit tests for services | Vitest |
| 2 | Integration tests for API endpoints | Supertest + Vitest |
| 3 | Database tests with test containers | Prisma + test database |
| 4 | Auth flow E2E test | Full register → verify → login → protected route |
| 5 | Giving flow E2E test | Donate → verify webhook → receipt generated |
| 6 | Chat E2E test | Connect socket → send message → receive in real-time |
| 7 | Load testing | Artillery or k6 |

### 7H. Phase 7 Checklist

- [x] Add Attendance, Milestone, SavedItem models (+ 4 enums: ServiceType, CheckinMethod, MilestoneType, SavedEntityType)
- [x] Run migration `phase7_attendance_milestones_saved_items`
- [x] Implement complete BullMQ job system (12 cron jobs across 7 queues)
- [x] Implement attendance tracking service (record, history, streak, stats)
- [x] Implement spiritual milestone auto-generation (8 milestone types)
- [x] Implement saved items / polymorphic bookmarks (SERMON, EVENT, DEVOTIONAL, READING_PLAN)
- [x] Complete all placeholder endpoints in users module (attendance, milestones, saved items)
- [x] Implement Redis caching across hot endpoints (cache.service.ts)
- [x] Create all email HTML templates (9 total: 4 original + 5 new Phase 7)
- [ ] Set up Swagger documentation — deferred to Phase 8
- [x] Write integration tests — 46/46 Phase 7 tests passed
- [x] `npx tsc --noEmit` — 0 errors
- [x] All regression tests pass — Phases 2-6: 165/165 tests passing

---

## 9. Phase 8 — Admin Dashboard (Web)

> **Timeline:** Weeks 15–18 | **Status:** ⬜ Not Started
>
> **Goal:** Build a Next.js web admin dashboard for church administrators to manage all content.

---

### 8A. Technology

| Layer | Technology |
|---|---|
| Framework | Next.js 15 (App Router) |
| UI | Tailwind CSS + shadcn/ui |
| State | TanStack Query |
| Auth | Same JWT tokens as mobile app |
| Charts | Recharts |
| Tables | TanStack Table |

### 8B. Admin API Endpoints to Add

All admin endpoints require `ADMIN` or `SUPER_ADMIN` role.

| Module | Admin Endpoints Needed |
|---|---|
| **Users** | List all users, update roles, deactivate, view analytics |
| **Sermons** | CRUD series, CRUD sermons, upload audio/video, manage featured |
| **Events** | CRUD events, manage speakers, view registrations, export attendees |
| **Giving** | View all donations, manage categories/campaigns, export financial reports, issue refunds |
| **Bible** | CRUD devotionals, CRUD reading plans, manage plan days |
| **Community** | CRUD announcements, approve/reject testimonies, manage groups |
| **Forum** | Moderate threads, pin/lock/delete threads, manage categories |
| **Notifications** | Send bulk push, broadcast announcements |
| **Church** | Update church info, manage staff, campuses, service times, FAQs, core values |
| **Volunteer** | CRUD opportunities, manage roster, view signups |
| **Kids** | Manage rooms, view check-in history |
| **Media** | CRUD albums, upload photos, CRUD podcast episodes, CRUD worship songs/lyrics |
| **Live** | Start/end live service, moderate live chat |
| **Analytics** | Attendance trends, giving trends, engagement metrics, growth dashboard |

### 8C. Dashboard Pages

| Page | Features |
|---|---|
| Dashboard Home | Key metrics: total members, weekly attendance, monthly giving, active groups, recent activity feed |
| Members | Data table with search, filter by role/department, bulk actions, export CSV |
| Sermons | Series manager, sermon uploader (audio/video), drag-sort, featured toggle |
| Events | Calendar view + list view, create/edit event, speaker management, registration export |
| Giving | Financial dashboard with charts, donation list, campaign manager, refund button, export reports |
| Devotionals | Calendar-based editor, bulk import, preview |
| Reading Plans | Plan builder with day-by-day content editor |
| Announcements | Create/schedule, urgent toggle, delivery stats |
| Groups | CRUD, member management, leader assignment |
| Forum | Moderation queue, reported content, pin/lock controls |
| Notifications | Compose push/email, target by segment, delivery analytics |
| Church Info | Edit about, manage staff, campuses, FAQs, core values |
| Volunteer | Opportunity manager, roster scheduler, shift calendar |
| Kids | Room manager, check-in dashboard (real-time), historical reports |
| Media | Album manager, photo uploader (drag-drop batch), podcast manager, worship song editor |
| Live | Start/end controls, live chat moderation, analytics |
| Settings | Church settings, feature flags, branding colors, payment config, email config |

### 8D. Phase 8 Checklist

- [ ] Scaffold Next.js 15 project in `/admin/`
- [ ] Configure Tailwind + shadcn/ui
- [ ] Implement JWT auth (login page, token management, role guard)
- [ ] Build all admin API endpoints (add to existing Express backend)
- [ ] Build all dashboard pages (16+ pages)
- [ ] Implement file upload UI (drag-drop for sermons, photos, etc.)
- [ ] Implement analytics dashboard with charts
- [ ] Add role-based access control (ADMIN vs SUPER_ADMIN)
- [ ] Testing + polish

---

## 10. Database Model Tracker

> Track which models have been added to `prisma/schema.prisma`.

| Model | Phase | Status |
|---|---|---|
| `Church` | 1 | ✅ |
| `User` | 1 | ✅ |
| `Role` (enum) | 1 | ✅ |
| `SermonSeries` | 2 | ✅ |
| `Sermon` | 2 | ✅ |
| `UserSermonProgress` | 2 | ✅ |
| `UserSermonNote` | 2 | ✅ |
| `Event` | 2 | ✅ |
| `EventSpeaker` | 2 | ✅ |
| `EventRegistration` | 2 | ✅ |
| `BibleBook` | 2 | ✅ |
| `BibleVerse` | 2 | ✅ |
| `UserVerseHighlight` | 2 | ✅ |
| `Devotional` | 2 | ✅ |
| `UserDevotionalRead` | 2 | ✅ |
| `ReadingPlan` | 2 | ✅ |
| `ReadingPlanDay` | 2 | ✅ |
| `UserReadingPlan` | 2 | ✅ |
| `UserReadingPlanProgress` | 2 | ✅ |
| `Campus` | 2 | ✅ |
| `ServiceTime` | 2 | ✅ |
| `CoreValue` | 2 | ✅ |
| `StaffMember` | 2 | ✅ |
| `FAQ` | 2 | ✅ |
| `GivingCategory` | 3 | ✅ |
| `GivingCampaign` | 3 | ✅ |
| `Donation` | 3 | ✅ |
| `PaymentMethod` | 3 | ✅ |
| `Pledge` | 3 | ✅ |
| `RecurringDonation` | 3 | ✅ |
| `ConnectGroup` | 4 | ✅ |
| `GroupMembership` | 4 | ✅ |
| `Announcement` | 4 | ✅ |
| `AnnouncementRead` | 4 | ✅ |
| `Testimony` | 4 | ✅ |
| `TestimonyReaction` | 4 | ✅ |
| `ForumCategory` | 4 | ✅ |
| `ForumThread` | 4 | ✅ |
| `ForumReply` | 4 | ✅ |
| `ForumLike` | 4 | ✅ |
| `ForumBookmark` | 4 | ✅ |
| `PrayerRequest` | 4 | ✅ |
| `PrayerInteraction` | 4 | ✅ |
| `InviteLink` | 4 | ✅ |
| `Conversation` | 5 | ✅ |
| `ConversationMember` | 5 | ✅ |
| `Message` | 5 | ✅ |
| `Notification` | 5 | ✅ |
| `LiveService` | 5 | ✅ |
| `LiveChatMessage` | 5 | ✅ |
| `VolunteerOpportunity` | 6 | ✅ |
| `VolunteerSignup` | 6 | ✅ |
| `RosterShift` | 6 | ✅ |
| `Child` | 6 | ✅ |
| `Room` | 6 | ✅ |
| `CheckIn` | 6 | ✅ |
| `PhotoAlbum` | 6 | ✅ |
| `Photo` | 6 | ✅ |
| `PodcastEpisode` | 6 | ✅ |
| `UserPodcastProgress` | 6 | ✅ |
| `WorshipSong` | 6 | ✅ |
| `SongSection` | 6 | ✅ |
| `LyricLine` | 6 | ✅ |
| `Attendance` | 7 | ⬜ |
| `SpiritualMilestone` | 7 | ⬜ |
| `SavedItem` | 7 | ⬜ |

**Total: 63 done / 66 models total** (includes 4 new enums from Phase 6)

---

## 11. API Endpoint Tracker

> Total endpoints across all phases.

| Phase | Module | Endpoint Count | Status |
|---|---|---|---|
| 1 | Auth | 11 | ✅ |
| 1 | Users | 10 | ✅ (5 placeholder) |
| 2 | Sermons | 11 | ✅ |
| 2 | Events | 6 | ✅ |
| 2 | Bible | 6 | ✅ |
| 2 | Devotionals | 4 | ✅ |
| 2 | Reading Plans | 5 | ✅ |
| 2 | Church Info | 5 | ✅ |
| 2 | Home Feed | 1 | ✅ |
| 3 | Giving | 18 | ✅ |
| 4 | Groups | 4 | ✅ |
| 4 | Announcements | 3 | ✅ |
| 4 | Testimonies | 3 | ✅ |
| 4 | Forum | 10 | ✅ |
| 4 | Prayer Requests | 5 | ✅ |
| 4 | Directory/Invites | 4 | ✅ |
| 5 | Chat | 7 | ✅ |
| 5 | Notifications | 5 | ✅ |
| 5 | Live Service | 4 | ✅ |
| 6 | Volunteering | 5 | ✅ |
| 6 | Kids Check-In | 5 | ✅ |
| 6 | Media | 10 | ✅ |
| 6 | Search | 2 | ✅ |
| **Total** | | **163** | **163 done** |

---

## 12. Push Notification Trigger Tracker

| # | Trigger | Phase Built | Wired? | Notes |
|---|---|---|---|---|
| 1 | New sermon published | 2 | ⬜ | Needs background job or admin action |
| 2 | Live service started | 5 | ✅ | `notifyLiveServiceStarted()` in triggers |
| 3 | Event reminder (24h) | 2 | ✅ | `notifyEventReminder()` trigger created (needs cron) |
| 4 | Event reminder (1h) | 2 | ✅ | `notifyEventReminder()` trigger created (needs cron) |
| 5 | New chat message (offline) | 5 | ✅ | Wired in `chat.socket.ts` via socket events |
| 6 | Giving receipt | 3 | ✅ | `notifyDonationSuccess()` wired in `giving.service.ts` |
| 7 | Recurring donation processed | 3 | ✅ | `notifyRecurringSetup()` / `notifyRecurringCancelled()` wired |
| 8 | Pledge due reminder | 3 | ✅ | `sendPledgeReminders` cron job built in Phase 7 |
| 9 | Giving reminder (user-set) | 3 | ✅ | Covered by `sendPledgeReminders` cron job |
| 10 | Someone prayed for you | 4 | ✅ | `notifyPrayerInteraction()` wired in `prayer.service.ts` |
| 11 | Prayer marked answered | 4 | ✅ | `notifyPrayerAnswered()` wired in `prayer.service.ts` |
| 12 | Urgent announcement | 4 | ✅ | `notifyNewAnnouncement()` trigger created |
| 13 | Normal announcement | 4 | ✅ | `notifyNewAnnouncement()` trigger created |
| 14 | Group activity update | 4 | ✅ | `notifyGroupJoin()` / `notifyGroupLeave()` wired in `groups.service.ts` |
| 15 | Forum reply (your thread) | 4 | ✅ | `notifyForumReply()` wired in `forum.service.ts` |
| 16 | Forum reply (bookmarked) | 4 | ⬜ | Needs bookmark tracking enhancement |
| 17 | Volunteer shift reminder | 6 | ✅ | `notifyVolunteerShiftReminder()` trigger created (needs cron) |
| 18 | Shift swap approved | 6 | ✅ | `notifyVolunteerShiftSwap()` wired in `volunteer.service.ts` |
| 19 | Kids check-in alert | 6 | ✅ | `notifyKidsCheckIn()` / `notifyKidsCheckOut()` wired in `kids.service.ts` |
| 20 | Daily devotional reminder | 2 | ✅ | `notifyDailyDevotional()` trigger created (needs cron) |
| 21 | Reading plan reminder | 2 | ✅ | `sendReadingPlanReminders` cron job built in Phase 7 |
| 22 | Birthday/anniversary | 7 | ✅ | `sendBirthdayGreetings` cron job built in Phase 7 |
| 23 | Welcome message | 1 | ⬜ | Wire during auth registration |
| 24 | Security alert | 1 | ✅ | `notifyPasswordChanged()` / `notifyNewLogin()` triggers created |

**Phase 7 progress: 21/24 triggers created and wired. All cron-dependent triggers now have BullMQ jobs. Remaining: #1 (new sermon published — admin action), #16 (forum bookmark tracking enhancement), #23 (welcome message in auth registration).**

---

## 13. Background Job Tracker

| Job | Queue | Phase | Status |
|---|---|---|---|
| Process recurring donations | `giving` | 7 | ✅ |
| Send pledge reminders | `giving` | 7 | ✅ |
| Update campaign totals | `giving` | 7 | ✅ |
| Send giving receipt | `giving` | 7 | ✅ |
| Send event reminders (24h + 1h) | `events` | 7 | ✅ |
| Publish daily devotional | `devotionals` | 7 | ✅ |
| Send reading plan reminders | `devotionals` | 7 | ✅ |
| Calculate attendance streaks | `attendance` | 7 | ✅ |
| Generate spiritual milestones | `milestones` | 7 | ✅ |
| Cleanup expired data | `maintenance` | 7 | ✅ |
| Send birthday greetings | `maintenance` | 7 | ✅ |
| Rebuild search indexes | `maintenance` | 7 | ✅ |
| Send volunteer shift reminders | `volunteering` | 7 | ✅ |

**Total: 13 / 13 jobs built ✅**

---

## 14. WebSocket Event Tracker

| Namespace | Event | Phase | Status |
|---|---|---|---|
| default | `chat:message` | 5 | ✅ |
| default | `chat:typing` | 5 | ✅ |
| default | `chat:read` | 5 | ✅ |
| default | `chat:join` | 5 | ✅ |
| default | `live:join` | 5 | ✅ |
| default | `live:leave` | 5 | ✅ |
| default | `live:message` | 5 | ✅ |
| default | `live:reaction` | 5 | ✅ |
| default | `live:prayer` | 5 | ✅ |
| default | `notification:read` | 5 | ✅ |
| default | `notification:read-all` | 5 | ✅ |
| default | `notification:unread-count` | 5 | ✅ |

**Total: 12 / 12 events built**

---

## 15. File Upload Requirements

| Content Type | Cloudinary Folder | Max Size | Transform | Phase |
|---|---|---|---|---|
| Profile avatar | `churchapp/avatars` | 5 MB | 400x400 face crop | 1 ✅ |
| Sermon audio | `churchapp/sermons/audio` | 200 MB | MP3 128kbps | 2 |
| Sermon video | `churchapp/sermons/video` | 2 GB | HLS adaptive | 2 |
| Sermon thumbnail | `churchapp/sermons/thumbs` | 10 MB | Auto optimize | 2 |
| Event image | `churchapp/events` | 10 MB | Auto optimize | 2 |
| Photo gallery | `churchapp/photos` | 15 MB | Auto thumbnail | 6 |
| Podcast audio | `churchapp/podcasts` | 200 MB | MP3 | 6 |
| Church logo/cover | `churchapp/church` | 5 MB | Auto optimize | 2 |
| Chat media | `churchapp/chat` | 15 MB | Auto compress | 5 |
| Giving receipt PDF | `churchapp/receipts` | N/A | Raw upload | 3 |
| QR code (kids) | Generated in-memory | N/A | PNG buffer | 6 |

---

## 16. Deployment Checklist

> When all phases are complete, before going to production:

### Infrastructure
- [ ] Set up production PostgreSQL (AWS RDS / Supabase / Railway)
- [ ] Set up production Redis (AWS ElastiCache / Upstash)
- [ ] Configure Cloudinary production account + upload presets
- [ ] Set up SendGrid production account with verified domain
- [ ] Set up Paystack production keys (or Stripe)
- [ ] Set up Firebase project with FCM production credentials

### Security
- [ ] Set all environment variables in production
- [ ] Enable HTTPS only
- [ ] Set secure CORS origins
- [ ] Enable helmet with strict CSP
- [ ] Rate limit all endpoints (Redis-backed)
- [ ] Input sanitization on all user content
- [ ] SQL injection protection (Prisma handles this)
- [ ] File upload validation (type, size, content inspection)
- [ ] JWT secret rotation strategy
- [ ] Audit logging for admin actions

### Performance
- [ ] Redis caching on all hot endpoints
- [ ] Database connection pooling configured
- [ ] Pagination on all list endpoints
- [ ] Image optimization via Cloudinary transforms
- [ ] Gzip compression (already enabled)
- [ ] Database indexes reviewed and optimized

### Monitoring
- [ ] Application logging (structured JSON in production)
- [ ] Error tracking (Sentry)
- [ ] Uptime monitoring (Better Uptime / UptimeRobot)
- [ ] Database monitoring and alerts
- [ ] API response time tracking

### CI/CD
- [ ] GitHub Actions pipeline: lint → type-check → test → build → deploy
- [ ] Database migration runs in pipeline before deploy
- [ ] Environment-based config (dev / staging / production)
- [ ] Zero-downtime deployment strategy
- [ ] Rollback plan documented

---

## Summary Progress Bar

```
Phase 1 — Foundation         ██████████████████████ 100%  ✅
Phase 2 — Core Content       ██████████████████████ 100%  ✅  (31/31 tests)
Phase 3 — Giving & Finances  ██████████████████████ 100%  ✅  (26/26 tests)
Phase 4 — Community          ██████████████████████ 100%  ✅  (30/30 tests)
Phase 5 — Real-Time          ██████████████████████ 100%  ✅  (18/18 tests)
Phase 6 — Operations & Media ██████████████████████ 100%  ✅  (40/40 tests)
Phase 7 — Polish & Testing   ██████████████████████ 100%  ✅  (46/46 tests)
Phase 8 — Admin Dashboard    ░░░░░░░░░░░░░░░░░░░░░   0%  ⬜

Overall: ███████████████████░░ ~87%
```

---

> **Next Step:** Begin Phase 8 — Admin Dashboard (Next.js web admin panel for church administrators)
