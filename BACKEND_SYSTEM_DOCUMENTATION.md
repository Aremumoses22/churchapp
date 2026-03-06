# 🛡️ Church App — Complete Backend System Documentation

> **Purpose:** This document maps **every** frontend screen, data model, and feature to
> the backend API endpoints, database tables, and services required. Nothing is left behind.
>
> **Approach:** Node.js (Express.js) + PostgreSQL + Custom JWT Auth + Firebase Cloud Messaging (Push) + Cloudinary (Storage) + Redis cache.

---

## Table of Contents

1. [Recommended Backend Architecture](#1-recommended-backend-architecture)
2. [Technology Stack](#2-technology-stack)
3. [Database Schema (All Tables)](#3-database-schema-all-tables)
4. [API Endpoints (Full List)](#4-api-endpoints-full-list)
5. [Section-by-Section Breakdown](#5-section-by-section-breakdown)
   - 5.1 [Authentication & Onboarding](#51-authentication--onboarding)
   - 5.2 [Home Screen](#52-home-screen)
   - 5.3 [Sermons & Media Playback](#53-sermons--media-playback)
   - 5.4 [Events](#54-events)
   - 5.5 [Giving & Finances](#55-giving--finances)
   - 5.6 [Bible, Devotionals & Reading Plans](#56-bible-devotionals--reading-plans)
   - 5.7 [Community & Groups](#57-community--groups)
   - 5.8 [Forum](#58-forum)
   - 5.9 [Chat & Messaging](#59-chat--messaging)
   - 5.10 [Notifications](#510-notifications)
   - 5.11 [Church Info (Static Content)](#511-church-info-static-content)
   - 5.12 [Volunteering & Service](#512-volunteering--service)
   - 5.13 [Media Library (Photos, Podcasts, Worship Lyrics)](#513-media-library-photos-podcasts-worship-lyrics)
   - 5.14 [Prayer Requests](#514-prayer-requests)
   - 5.15 [Profile & Account](#515-profile--account)
   - 5.16 [Search](#516-search)
6. [Real-Time Services](#6-real-time-services)
7. [File Storage & CDN](#7-file-storage--cdn)
8. [Background Jobs & Cron](#8-background-jobs--cron)
9. [Third-Party Integrations](#9-third-party-integrations)
10. [Admin Dashboard (Future Phase)](#10-admin-dashboard-future-phase)
11. [Implementation Roadmap](#11-implementation-roadmap)

---

## 1. Recommended Backend Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      FLUTTER MOBILE APP                         │
│  (iOS / Android — currently uses mock data via Riverpod)        │
└───────────────────────────┬─────────────────────────────────────┘
                            │  HTTPS / WSS
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    API GATEWAY / LOAD BALANCER                   │
│               (Nginx / AWS ALB / Cloudflare)                    │
└───────────────────────────┬─────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
   ┌──────────┐     ┌──────────┐     ┌──────────────┐
   │ REST API │     │WebSocket │     │  Admin API   │
   │  Server  │     │  Server  │     │   Server     │
   │(Express) │     │(Socket.io│     │  (Express)   │
   │          │     │  or WS)  │     │              │
   └────┬─────┘     └────┬─────┘     └──────┬───────┘
        │                │                   │
        └────────┬───────┴───────────────────┘
                 │
    ┌────────────┼────────────────┐
    ▼            ▼                ▼
┌────────┐ ┌─────────┐  ┌──────────┐ ┌───────────┐
│Postgres│ │  Redis   │  │ Firebase │ │ Cloudinary│
│  (DB)  │ │ (Cache,  │  │ (FCM     │ │ (Images,  │
│        │ │  Queues, │  │  Push    │ │  Audio,   │
│        │ │  Pub/Sub)│  │  only)   │ │  Video)   │
└────────┘ └─────────┘  └──────────┘ └───────────┘
```

### Why This Stack?

| Decision | Reason |
|----------|--------|
| **Node.js (Express.js)** | Same language (JS/TS) for backend + future web admin; huge ecosystem; real-time friendly |
| **PostgreSQL** | Relational data (users, giving records, events) with JSONB for flexible content; strong with queries |
| **Custom JWT Auth (bcrypt + jsonwebtoken)** | Full control over auth flow; bcrypt password hashing; JWT access + refresh tokens; no third-party auth dependency |
| **Firebase Cloud Messaging (FCM)** | Push notifications to iOS/Android with zero infrastructure |
| **Cloudinary** | Generous free tier for testing; auto image/video optimization; built-in CDN; transformations for thumbnails/resizing |
| **Redis** | Cache hot data (home screen, trending), rate limiting, pub/sub for real-time chat |
| **Socket.io / WebSockets** | Live chat, live service chat, real-time notifications |
| **BullMQ (on Redis)** | Background jobs: email sending, push notifications, giving receipt generation |

---

## 2. Technology Stack

```
Runtime:          Node.js 20 LTS + TypeScript
Framework:        Express.js
ORM:              Prisma (type-safe, migrations, PostgreSQL support)
Database:         PostgreSQL 16
Cache:            Redis 7
Auth:             Custom JWT (bcrypt + jsonwebtoken middleware)
Push:             Firebase Cloud Messaging (FCM)
File Storage:     Cloudinary (images, audio, video, documents + built-in CDN)
Real-time:        Socket.io (chat, live service, notifications)
Job Queue:        BullMQ (on Redis)
Email:            SendGrid / AWS SES (transactional emails)
Payments:         Paystack / Stripe (giving integration)
Search:           PostgreSQL full-text search (upgrade to Meilisearch if needed)
Deployment:       Docker → Railway / Render / AWS ECS
Monitoring:       Sentry (errors) + Axiom/Datadog (logs)
```

---

## 3. Database Schema (All Tables)

> Every table below maps directly to data displayed on one or more frontend screens.

### 3.1 — Core / Auth

```sql
-- ═══════════════════════════════════════════════════════════════
-- CHURCHES (multi-tenant: one backend can serve multiple churches)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE churches (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            VARCHAR(255) NOT NULL,        -- "Grace Community Church"
  tagline         VARCHAR(500),                 -- "Est. 1998 · Reaching the world"
  code            VARCHAR(10) UNIQUE NOT NULL,  -- 6-digit church code for onboarding
  mission         TEXT,
  vision          TEXT,
  ein             VARCHAR(20),                  -- tax ID for giving receipts
  phone           VARCHAR(20),
  email           VARCHAR(255),
  website         VARCHAR(500),
  address         TEXT,
  logo_url        VARCHAR(500),
  cover_image_url VARCHAR(500),
  social_links    JSONB DEFAULT '{}',           -- {facebook, instagram, youtube, twitter}
  settings        JSONB DEFAULT '{}',           -- feature flags, branding colors, etc.
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- USERS
-- Used by: Auth screens, Profile, Edit Profile, Church Directory
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE users (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id         UUID REFERENCES churches(id),
  email             VARCHAR(255) UNIQUE NOT NULL,
  password_hash     VARCHAR(255) NOT NULL,          -- bcrypt hashed password
  email_verified    BOOLEAN DEFAULT FALSE,
  verification_token VARCHAR(255),                  -- email verification token
  reset_token       VARCHAR(255),                   -- password reset token
  reset_token_expires TIMESTAMPTZ,                  -- reset token expiry
  refresh_token     VARCHAR(500),                   -- JWT refresh token
  name              VARCHAR(255) NOT NULL,
  phone             VARCHAR(20),
  bio               TEXT,
  avatar_url        VARCHAR(500),
  department        VARCHAR(100),                  -- Media, Worship, Children, etc.
  role              VARCHAR(50) DEFAULT 'member',  -- member, leader, pastor, admin
  joined_date       DATE DEFAULT CURRENT_DATE,
  is_active         BOOLEAN DEFAULT TRUE,
  is_directory_visible BOOLEAN DEFAULT TRUE,       -- opt-in for church directory
  fcm_tokens        TEXT[] DEFAULT '{}',           -- push notification device tokens
  notification_prefs JSONB DEFAULT '{}',           -- per-category push/email toggles
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);
```

### 3.2 — Sermons & Series

```sql
-- ═══════════════════════════════════════════════════════════════
-- SERMON SERIES
-- Used by: Sermons Screen (series carousel), Series Detail Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE sermon_series (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  title       VARCHAR(255) NOT NULL,       -- "Unshakeable Faith Series"
  subtitle    VARCHAR(500),                -- "6-part series"
  emoji       VARCHAR(10),                 -- "🔥"
  color       VARCHAR(7),                  -- "#3B82F6" hex
  cover_url   VARCHAR(500),
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- SERMONS
-- Used by: Sermons Screen, Sermon Detail, Audio/Video Player,
--          Home Screen (latest sermon), Search
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE sermons (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id       UUID REFERENCES churches(id),
  series_id       UUID REFERENCES sermon_series(id),
  title           VARCHAR(255) NOT NULL,       -- "The Power of Faith"
  speaker         VARCHAR(255) NOT NULL,       -- "Pastor James Wilson"
  description     TEXT,
  notes_content   TEXT,                        -- rich text sermon notes / outline
  scripture_refs  TEXT[],                       -- ["Hebrews 11:1", "2 Cor 5:7"]
  duration        VARCHAR(20),                 -- "42:15"
  duration_secs   INT,                         -- 2535
  audio_url       VARCHAR(500),                -- CDN link to .mp3
  video_url       VARCHAR(500),                -- CDN link to .mp4 or stream URL
  thumbnail_url   VARCHAR(500),
  published_at    TIMESTAMPTZ,                 -- sermon date
  is_featured     BOOLEAN DEFAULT FALSE,
  view_count      INT DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- User-specific sermon data
CREATE TABLE user_sermon_progress (
  user_id       UUID REFERENCES users(id),
  sermon_id     UUID REFERENCES sermons(id),
  progress_secs INT DEFAULT 0,                -- playback position
  is_completed  BOOLEAN DEFAULT FALSE,
  is_saved      BOOLEAN DEFAULT FALSE,        -- bookmarked/saved
  is_downloaded BOOLEAN DEFAULT FALSE,
  saved_at      TIMESTAMPTZ,
  PRIMARY KEY (user_id, sermon_id)
);

-- ═══════════════════════════════════════════════════════════════
-- SERMON NOTES (user-created notes per sermon)
-- Used by: Sermon Notes Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE user_sermon_notes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id),
  sermon_id   UUID REFERENCES sermons(id),
  title       VARCHAR(255),
  body        TEXT,                            -- user's personal notes
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, sermon_id)
);
```

### 3.3 — Events

```sql
-- ═══════════════════════════════════════════════════════════════
-- EVENTS
-- Used by: Events Screen, Event Detail, Home Screen,
--          My Events, Search
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE events (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id       UUID REFERENCES churches(id),
  title           VARCHAR(255) NOT NULL,       -- "Easter Sunrise Service"
  description     TEXT,
  category        VARCHAR(50),                 -- Conference, Workshop, Service, etc.
  location        VARCHAR(255),                -- "Grace Cathedral, Victoria Island"
  address         TEXT,                        -- full address for maps
  start_time      TIMESTAMPTZ NOT NULL,
  end_time        TIMESTAMPTZ,
  image_url       VARCHAR(500),
  color           VARCHAR(7),                  -- accent color hex
  is_recurring    BOOLEAN DEFAULT FALSE,
  recurrence_rule VARCHAR(255),                -- iCal RRULE format
  max_attendees   INT,
  is_featured     BOOLEAN DEFAULT FALSE,
  requires_registration BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Event speakers/hosts
CREATE TABLE event_speakers (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id  UUID REFERENCES events(id) ON DELETE CASCADE,
  name      VARCHAR(255) NOT NULL,
  role      VARCHAR(100),                     -- "Lead Pastor", "Worship Leader"
  bio       TEXT,
  photo_url VARCHAR(500),
  sort_order INT DEFAULT 0
);

-- Event registrations
CREATE TABLE event_registrations (
  user_id       UUID REFERENCES users(id),
  event_id      UUID REFERENCES events(id),
  status        VARCHAR(20) DEFAULT 'registered',  -- registered, cancelled, attended
  registered_at TIMESTAMPTZ DEFAULT NOW(),
  attended_at   TIMESTAMPTZ,
  PRIMARY KEY (user_id, event_id)
);
```

### 3.4 — Giving & Finances

```sql
-- ═══════════════════════════════════════════════════════════════
-- GIVING CATEGORIES
-- Used by: Giving Screen (category selector)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE giving_categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  name        VARCHAR(100) NOT NULL,           -- Tithe, Offering, Building Fund, etc.
  icon        VARCHAR(50),                     -- icon name/code
  sort_order  INT DEFAULT 0,
  is_active   BOOLEAN DEFAULT TRUE
);

-- ═══════════════════════════════════════════════════════════════
-- GIVING CAMPAIGNS
-- Used by: Giving Campaign Screen, Home Screen (campaign card),
--          Pledge Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE giving_campaigns (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id       UUID REFERENCES churches(id),
  title           VARCHAR(255) NOT NULL,       -- "New Youth Center"
  subtitle        VARCHAR(500),
  description     TEXT,
  goal_amount     DECIMAL(12,2) NOT NULL,       -- 250000.00
  raised_amount   DECIMAL(12,2) DEFAULT 0,
  donor_count     INT DEFAULT 0,
  start_date      DATE NOT NULL,
  end_date        DATE NOT NULL,
  hero_emoji      VARCHAR(10),                 -- "🏗️"
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- DONATIONS (every giving transaction)
-- Used by: Giving History, Receipt Detail, Campaign donors list
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE donations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES users(id),
  church_id       UUID REFERENCES churches(id),
  category_id     UUID REFERENCES giving_categories(id),
  campaign_id     UUID REFERENCES giving_campaigns(id),  -- nullable
  amount          DECIMAL(12,2) NOT NULL,
  currency        VARCHAR(3) DEFAULT 'USD',
  payment_method  VARCHAR(50),                 -- card, bank, apple_pay, google_pay
  payment_ref     VARCHAR(100),                -- Paystack/Stripe transaction ID
  receipt_number  VARCHAR(50) UNIQUE,          -- "RCP-2026-00847"
  status          VARCHAR(20) DEFAULT 'completed', -- pending, completed, failed, refunded
  is_anonymous    BOOLEAN DEFAULT FALSE,
  frequency       VARCHAR(20) DEFAULT 'one-time', -- one-time, weekly, monthly
  notes           TEXT,
  donated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- SAVED PAYMENT METHODS
-- Used by: Giving Screen (saved cards)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE payment_methods (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES users(id),
  provider_ref  VARCHAR(255),                  -- Stripe/Paystack customer token
  brand         VARCHAR(20),                   -- Visa, Mastercard, etc.
  last4         VARCHAR(4),
  exp_month     INT,
  exp_year      INT,
  is_default    BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- PLEDGES
-- Used by: Pledge Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE pledges (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES users(id),
  campaign_id     UUID REFERENCES giving_campaigns(id),
  total_amount    DECIMAL(12,2) NOT NULL,       -- 6000.00
  paid_amount     DECIMAL(12,2) DEFAULT 0,
  monthly_amount  DECIMAL(12,2),
  frequency       VARCHAR(20) DEFAULT 'monthly',
  total_payments  INT,                          -- 12
  payments_made   INT DEFAULT 0,
  start_date      DATE,
  next_due_date   DATE,
  status          VARCHAR(20) DEFAULT 'active', -- active, completed, cancelled
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Recurring giving schedule
CREATE TABLE recurring_donations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES users(id),
  category_id     UUID REFERENCES giving_categories(id),
  amount          DECIMAL(12,2) NOT NULL,
  frequency       VARCHAR(20) NOT NULL,         -- weekly, biweekly, monthly
  payment_method_id UUID REFERENCES payment_methods(id),
  next_charge_date DATE,
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### 3.5 — Bible, Devotionals & Reading Plans

```sql
-- ═══════════════════════════════════════════════════════════════
-- BIBLE (reference data — seeded, not user-created)
-- Used by: Bible Reader Screen
-- Note: Use a public Bible API (api.bible, bible-api.com) OR
--       store a licensed translation locally
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE bible_books (
  id              SERIAL PRIMARY KEY,
  name            VARCHAR(50) NOT NULL,         -- "Genesis"
  abbreviation    VARCHAR(10),                  -- "Gen"
  testament       VARCHAR(3) NOT NULL,          -- "OT" or "NT"
  chapter_count   INT NOT NULL,
  sort_order      INT NOT NULL
);

CREATE TABLE bible_verses (
  id          SERIAL PRIMARY KEY,
  book_id     INT REFERENCES bible_books(id),
  chapter     INT NOT NULL,
  verse       INT NOT NULL,
  text        TEXT NOT NULL,
  UNIQUE(book_id, chapter, verse)
);

-- User highlights
CREATE TABLE user_verse_highlights (
  user_id     UUID REFERENCES users(id),
  book_id     INT REFERENCES bible_books(id),
  chapter     INT NOT NULL,
  verse       INT NOT NULL,
  color       VARCHAR(7) DEFAULT '#D4A843',    -- gold highlight
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, book_id, chapter, verse)
);

-- ═══════════════════════════════════════════════════════════════
-- DAILY DEVOTIONALS
-- Used by: Daily Devotional Screen, Home Screen (verse of the day)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE devotionals (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id       UUID REFERENCES churches(id),
  date            DATE NOT NULL,
  title           VARCHAR(255) NOT NULL,        -- "Walking in Faith"
  scripture_ref   VARCHAR(100),                 -- "Hebrews 11:1"
  scripture_text  TEXT,
  body            TEXT NOT NULL,                -- devotional content
  reflection      TEXT,                         -- reflection prompt
  author          VARCHAR(255),                 -- "Pastor David Mitchell"
  reading_time_min INT DEFAULT 4,
  UNIQUE(church_id, date)
);

-- User devotional completion
CREATE TABLE user_devotional_reads (
  user_id       UUID REFERENCES users(id),
  devotional_id UUID REFERENCES devotionals(id),
  read_at       TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, devotional_id)
);

-- ═══════════════════════════════════════════════════════════════
-- READING PLANS
-- Used by: Reading Plan Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE reading_plans (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id       UUID REFERENCES churches(id),
  title           VARCHAR(255) NOT NULL,        -- "21 Days of Faith"
  description     TEXT,
  total_days      INT NOT NULL,
  cover_color     VARCHAR(7),
  participant_count INT DEFAULT 0,
  is_featured     BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE reading_plan_days (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id     UUID REFERENCES reading_plans(id) ON DELETE CASCADE,
  day_number  INT NOT NULL,
  title       VARCHAR(255),                    -- "Day 1: The Call of Abraham"
  reading_ref VARCHAR(255),                    -- "Hebrews 11:23-31"
  content     TEXT,
  UNIQUE(plan_id, day_number)
);

-- User enrollment + progress
CREATE TABLE user_reading_plans (
  user_id         UUID REFERENCES users(id),
  plan_id         UUID REFERENCES reading_plans(id),
  current_day     INT DEFAULT 1,
  started_at      TIMESTAMPTZ DEFAULT NOW(),
  completed_at    TIMESTAMPTZ,
  PRIMARY KEY (user_id, plan_id)
);

CREATE TABLE user_reading_plan_progress (
  user_id     UUID REFERENCES users(id),
  plan_id     UUID REFERENCES reading_plans(id),
  day_number  INT NOT NULL,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, plan_id, day_number)
);
```

### 3.6 — Community & Groups

```sql
-- ═══════════════════════════════════════════════════════════════
-- CONNECT GROUPS
-- Used by: Connect Groups Screen, Group Detail, Search
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE connect_groups (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id       UUID REFERENCES churches(id),
  name            VARCHAR(255) NOT NULL,        -- "Men's Fellowship"
  description     TEXT,
  category        VARCHAR(50),                  -- Men, Women, Youth, Couples, etc.
  meeting_day     VARCHAR(20),                  -- "Saturdays"
  meeting_time    VARCHAR(20),                  -- "8:00 AM"
  location        VARCHAR(255),                 -- "Room 201"
  leader_id       UUID REFERENCES users(id),
  color           VARCHAR(7),
  max_members     INT,
  is_open         BOOLEAN DEFAULT TRUE,
  image_url       VARCHAR(500),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE group_memberships (
  user_id     UUID REFERENCES users(id),
  group_id    UUID REFERENCES connect_groups(id),
  role        VARCHAR(20) DEFAULT 'member',    -- member, leader, co-leader
  joined_at   TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, group_id)
);

-- ═══════════════════════════════════════════════════════════════
-- ANNOUNCEMENTS
-- Used by: Announcements Screen, Home Screen, Notifications
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE announcements (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  title       VARCHAR(255) NOT NULL,
  body        TEXT NOT NULL,
  category    VARCHAR(50),
  priority    VARCHAR(10) DEFAULT 'normal',    -- urgent, high, normal
  image_url   VARCHAR(500),
  author_id   UUID REFERENCES users(id),
  published_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at  TIMESTAMPTZ,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE announcement_reads (
  user_id         UUID REFERENCES users(id),
  announcement_id UUID REFERENCES announcements(id),
  read_at         TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, announcement_id)
);

-- ═══════════════════════════════════════════════════════════════
-- TESTIMONIES
-- Used by: Testimonies Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE testimonies (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id),
  church_id   UUID REFERENCES churches(id),
  title       VARCHAR(255) NOT NULL,
  content     TEXT NOT NULL,
  category    VARCHAR(50),                     -- Healing, Salvation, Provision, etc.
  is_approved BOOLEAN DEFAULT FALSE,           -- admin moderation
  like_count  INT DEFAULT 0,
  prayer_count INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE testimony_reactions (
  user_id       UUID REFERENCES users(id),
  testimony_id  UUID REFERENCES testimonies(id),
  reaction_type VARCHAR(10),                   -- 'like', 'prayer'
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, testimony_id, reaction_type)
);
```

### 3.7 — Forum

```sql
-- ═══════════════════════════════════════════════════════════════
-- FORUM CATEGORIES
-- Used by: Forum Home Screen, Create Post Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE forum_categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  label       VARCHAR(100) NOT NULL,           -- "Prayer Requests"
  description TEXT,
  icon        VARCHAR(50),                     -- icon name
  color       VARCHAR(7),
  sort_order  INT DEFAULT 0
);

-- ═══════════════════════════════════════════════════════════════
-- FORUM THREADS
-- Used by: Forum Category Screen, Forum Thread Screen, Search
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE forum_threads (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id   UUID REFERENCES forum_categories(id),
  author_id     UUID REFERENCES users(id),
  title         VARCHAR(255) NOT NULL,
  body          TEXT NOT NULL,
  like_count    INT DEFAULT 0,
  reply_count   INT DEFAULT 0,
  view_count    INT DEFAULT 0,
  is_pinned     BOOLEAN DEFAULT FALSE,
  is_locked     BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- FORUM REPLIES
-- Used by: Forum Thread Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE forum_replies (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id   UUID REFERENCES forum_threads(id) ON DELETE CASCADE,
  author_id   UUID REFERENCES users(id),
  body        TEXT NOT NULL,
  like_count  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE forum_likes (
  user_id     UUID REFERENCES users(id),
  target_type VARCHAR(10) NOT NULL,            -- 'thread' or 'reply'
  target_id   UUID NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, target_type, target_id)
);

CREATE TABLE forum_bookmarks (
  user_id     UUID REFERENCES users(id),
  thread_id   UUID REFERENCES forum_threads(id),
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, thread_id)
);
```

### 3.8 — Chat & Messaging

```sql
-- ═══════════════════════════════════════════════════════════════
-- CHAT CONVERSATIONS
-- Used by: Chat List Screen, Chat Conversation Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE conversations (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  name        VARCHAR(255),                    -- null for 1:1, name for groups
  is_group    BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()        -- last message time
);

CREATE TABLE conversation_members (
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  user_id         UUID REFERENCES users(id),
  role            VARCHAR(20) DEFAULT 'member', -- member, admin
  is_muted        BOOLEAN DEFAULT FALSE,
  is_pinned       BOOLEAN DEFAULT FALSE,
  last_read_at    TIMESTAMPTZ,
  joined_at       TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE messages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id       UUID REFERENCES users(id),
  text            TEXT NOT NULL,
  message_type    VARCHAR(20) DEFAULT 'text',  -- text, image, file
  attachment_url  VARCHAR(500),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast chat loading
CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);
```

### 3.9 — Notifications

```sql
-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- Used by: Notification Center Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id),
  church_id   UUID REFERENCES churches(id),
  type        VARCHAR(30) NOT NULL,            -- live, event, prayer, sermon, giving, etc.
  title       VARCHAR(255) NOT NULL,
  body        TEXT NOT NULL,
  group_label VARCHAR(50),                     -- "Today", "This Week", etc.
  action_url  VARCHAR(500),                    -- deep link route
  action_label VARCHAR(50),                    -- "Watch Now", "View Event"
  is_read     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, created_at DESC);
```

### 3.10 — Church Info & Campuses

```sql
-- ═══════════════════════════════════════════════════════════════
-- CAMPUSES
-- Used by: Campuses Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE campuses (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  name        VARCHAR(255) NOT NULL,           -- "Main Campus"
  address     TEXT NOT NULL,
  city        VARCHAR(100),
  phone       VARCHAR(20),
  pastor_name VARCHAR(255),
  description TEXT,
  color       VARCHAR(7),
  latitude    DECIMAL(10,8),
  longitude   DECIMAL(11,8),
  sort_order  INT DEFAULT 0
);

CREATE TABLE service_times (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campus_id   UUID REFERENCES campuses(id) ON DELETE CASCADE,
  label       VARCHAR(100) NOT NULL,           -- "1st Service"
  time        VARCHAR(20) NOT NULL,            -- "8:00 AM"
  day_of_week VARCHAR(10) DEFAULT 'Sunday'
);

-- ═══════════════════════════════════════════════════════════════
-- CHURCH CORE VALUES
-- Used by: About Church Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE core_values (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  title       VARCHAR(100) NOT NULL,
  description TEXT,
  icon        VARCHAR(50),
  sort_order  INT DEFAULT 0
);

-- ═══════════════════════════════════════════════════════════════
-- PASTORS & STAFF
-- Used by: Pastors Screen, Home Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE staff_members (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  user_id     UUID REFERENCES users(id),       -- nullable (some staff may not have app accounts)
  name        VARCHAR(255) NOT NULL,
  title       VARCHAR(100) NOT NULL,           -- "Senior Pastor"
  bio         TEXT,
  photo_url   VARCHAR(500),
  category    VARCHAR(50),                     -- pastoral_team, ministry_leader
  sort_order  INT DEFAULT 0,
  is_featured BOOLEAN DEFAULT FALSE
);

-- ═══════════════════════════════════════════════════════════════
-- FAQ
-- Used by: Help & FAQ Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE faqs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  question    TEXT NOT NULL,
  answer      TEXT NOT NULL,
  category    VARCHAR(50),
  sort_order  INT DEFAULT 0
);
```

### 3.11 — Volunteering

```sql
-- ═══════════════════════════════════════════════════════════════
-- VOLUNTEER OPPORTUNITIES
-- Used by: Volunteer Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE volunteer_opportunities (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id       UUID REFERENCES churches(id),
  title           VARCHAR(255) NOT NULL,        -- "Camera Operator"
  ministry        VARCHAR(100) NOT NULL,        -- "Media"
  description     TEXT,
  commitment      VARCHAR(100),                 -- "2 Sundays / month"
  schedule        VARCHAR(100),                 -- "8:00 AM - 12:00 PM"
  total_spots     INT,
  filled_spots    INT DEFAULT 0,
  skills          TEXT[],                        -- ["Attention to detail", "Team player"]
  icon            VARCHAR(50),
  color           VARCHAR(7),
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE volunteer_signups (
  user_id         UUID REFERENCES users(id),
  opportunity_id  UUID REFERENCES volunteer_opportunities(id),
  status          VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
  signed_up_at    TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, opportunity_id)
);

-- ═══════════════════════════════════════════════════════════════
-- SERVICE ROSTER (volunteer shifts)
-- Used by: Service Roster Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE roster_shifts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id       UUID REFERENCES churches(id),
  user_id         UUID REFERENCES users(id),
  role            VARCHAR(100) NOT NULL,        -- "Camera Operator"
  ministry        VARCHAR(100),                 -- "Media"
  service_label   VARCHAR(100),                 -- "1st Service — 8:00 AM"
  team_lead       VARCHAR(255),
  shift_date      DATE NOT NULL,
  can_check_in    BOOLEAN DEFAULT FALSE,
  checked_in      BOOLEAN DEFAULT FALSE,
  checked_in_at   TIMESTAMPTZ,
  color           VARCHAR(7),
  icon            VARCHAR(50)
);

-- ═══════════════════════════════════════════════════════════════
-- KIDS CHECK-IN
-- Used by: Kids Check-In Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE children (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id   UUID REFERENCES users(id),
  name        VARCHAR(255) NOT NULL,
  age         INT,
  allergies   VARCHAR(500),
  photo_url   VARCHAR(500),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE rooms (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  name        VARCHAR(100) NOT NULL,           -- "Nursery A"
  room_number VARCHAR(20),                     -- "Room 101"
  age_min     INT,
  age_max     INT,
  capacity    INT
);

CREATE TABLE checkins (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id    UUID REFERENCES children(id),
  room_id     UUID REFERENCES rooms(id),
  parent_id   UUID REFERENCES users(id),
  qr_code     VARCHAR(100) UNIQUE,             -- generated QR for pickup
  checked_in  TIMESTAMPTZ DEFAULT NOW(),
  checked_out TIMESTAMPTZ,
  service_date DATE DEFAULT CURRENT_DATE
);
```

### 3.12 — Media

```sql
-- ═══════════════════════════════════════════════════════════════
-- PHOTO ALBUMS & PHOTOS
-- Used by: Photo Gallery Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE photo_albums (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  name        VARCHAR(255) NOT NULL,           -- "Sunday Services"
  cover_url   VARCHAR(500),
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE photos (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id    UUID REFERENCES photo_albums(id) ON DELETE CASCADE,
  url         VARCHAR(500) NOT NULL,
  thumbnail_url VARCHAR(500),
  caption     TEXT,
  width       INT,
  height      INT,
  uploaded_by UUID REFERENCES users(id),
  taken_at    DATE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- PODCAST EPISODES
-- Used by: Podcast Feed Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE podcast_episodes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id       UUID REFERENCES churches(id),
  title           VARCHAR(255) NOT NULL,
  series          VARCHAR(255),
  speaker         VARCHAR(255),
  description     TEXT,
  audio_url       VARCHAR(500) NOT NULL,
  duration        VARCHAR(20),
  duration_secs   INT,
  published_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_podcast_progress (
  user_id       UUID REFERENCES users(id),
  episode_id    UUID REFERENCES podcast_episodes(id),
  progress_secs INT DEFAULT 0,
  is_completed  BOOLEAN DEFAULT FALSE,
  is_downloaded BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (user_id, episode_id)
);

-- ═══════════════════════════════════════════════════════════════
-- WORSHIP SONGS & LYRICS
-- Used by: Worship Lyrics Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE worship_songs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  title       VARCHAR(255) NOT NULL,           -- "Great Are You Lord"
  artist      VARCHAR(255),
  music_key   VARCHAR(5),                      -- "G"
  bpm         INT,
  sort_order  INT DEFAULT 0
);

CREATE TABLE song_sections (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  song_id     UUID REFERENCES worship_songs(id) ON DELETE CASCADE,
  label       VARCHAR(50),                     -- "Verse 1", "Chorus", "Bridge"
  sort_order  INT NOT NULL
);

CREATE TABLE lyric_lines (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id  UUID REFERENCES song_sections(id) ON DELETE CASCADE,
  text        TEXT NOT NULL,                   -- lyric line text
  chord       VARCHAR(20),                     -- "G", "Em", "C" — nullable
  sort_order  INT NOT NULL
);
```

### 3.13 — Prayer Requests

```sql
-- ═══════════════════════════════════════════════════════════════
-- PRAYER REQUESTS
-- Used by: Prayer Request Screen, Prayer Requests (profile),
--          Notifications
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE prayer_requests (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id),
  church_id   UUID REFERENCES churches(id),
  title       VARCHAR(255) NOT NULL,
  details     TEXT,
  is_public   BOOLEAN DEFAULT TRUE,
  prayer_count INT DEFAULT 0,
  status      VARCHAR(20) DEFAULT 'active',    -- active, answered, closed
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE prayer_interactions (
  user_id       UUID REFERENCES users(id),
  request_id    UUID REFERENCES prayer_requests(id),
  prayed_at     TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, request_id)
);
```

### 3.14 — Attendance & Spiritual Journey

```sql
-- ═══════════════════════════════════════════════════════════════
-- ATTENDANCE
-- Used by: Attendance History Screen, Spiritual Journey
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE attendance (
  user_id       UUID REFERENCES users(id),
  campus_id     UUID REFERENCES campuses(id),
  service_date  DATE NOT NULL,
  service_label VARCHAR(100),                  -- "1st Service"
  checked_in_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, service_date, service_label)
);

-- ═══════════════════════════════════════════════════════════════
-- SPIRITUAL MILESTONES
-- Used by: Spiritual Journey Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE spiritual_milestones (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id),
  type        VARCHAR(50) NOT NULL,            -- membership, sermon, group, giving, baptism, volunteer
  title       VARCHAR(255) NOT NULL,
  subtitle    VARCHAR(500),
  milestone_date DATE NOT NULL,
  is_highlight BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### 3.15 — Saved Items & Bookmarks

```sql
-- ═══════════════════════════════════════════════════════════════
-- SAVED ITEMS (unified bookmarks)
-- Used by: Saved Items Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE saved_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id),
  item_type   VARCHAR(20) NOT NULL,            -- sermon, event, verse, devotional
  item_id     VARCHAR(255) NOT NULL,           -- ID of the saved item
  title       VARCHAR(255),                    -- cached title for display
  subtitle    VARCHAR(500),
  saved_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, item_type, item_id)
);
```

### 3.16 — Live Service

```sql
-- ═══════════════════════════════════════════════════════════════
-- LIVE SERVICES
-- Used by: Home Screen (live badge), Live Service Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE live_services (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  church_id   UUID REFERENCES churches(id),
  title       VARCHAR(255),                    -- "Sunday Morning Worship"
  stream_url  VARCHAR(500),                    -- YouTube/Vimeo/custom RTMP
  is_live     BOOLEAN DEFAULT FALSE,
  viewer_count INT DEFAULT 0,
  started_at  TIMESTAMPTZ,
  ended_at    TIMESTAMPTZ,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE live_chat_messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id  UUID REFERENCES live_services(id) ON DELETE CASCADE,
  user_id     UUID REFERENCES users(id),
  text        TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### 3.17 — Invite / Referral

```sql
-- ═══════════════════════════════════════════════════════════════
-- INVITE LINKS
-- Used by: Invite Friends Screen
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE invite_links (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id),
  church_id   UUID REFERENCES churches(id),
  code        VARCHAR(20) UNIQUE NOT NULL,     -- "abc123"
  uses        INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 4. API Endpoints (Full List)

> Base URL: `https://api.churchapp.com/v1`
> All protected endpoints require `Authorization: Bearer <jwt_token>`

### 4.1 — Authentication

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `POST` | `/auth/register` | Create account (hash password, create DB user, send verification email) | Register Screen |
| `POST` | `/auth/login` | Verify email/password, return JWT access + refresh tokens | Login Screen |
| `POST` | `/auth/forgot-password` | Trigger password reset email | Forgot Password Screen |
| `POST` | `/auth/reset-password` | Reset password with token | Create New Password Screen |
| `POST` | `/auth/resend-verification` | Resend email verification | Email Verification Screen |
| `GET` | `/auth/verify-email/:token` | Verify email address via token from email link | Email Verification |
| `POST` | `/auth/refresh-token` | Refresh JWT using refresh token | App (automatic) |
| `POST` | `/auth/verify-church-code` | Validate 6-digit church code | Church Code Screen |
| `POST` | `/auth/complete-setup` | Mark profile setup complete | Profile Setup Screen |
| `POST` | `/auth/logout` | Clear FCM tokens, invalidate session | Settings Screen |
| `DELETE` | `/auth/account` | Delete account + data | Settings Screen |

### 4.2 — User Profile

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `GET` | `/users/me` | Get current user profile | Profile Screen |
| `PUT` | `/users/me` | Update name, bio, phone, department | Edit Profile Screen |
| `PUT` | `/users/me/avatar` | Upload profile photo | Edit Profile Screen |
| `PUT` | `/users/me/notification-prefs` | Update notification preferences | Manage Notifications Screen |
| `PUT` | `/users/me/fcm-token` | Register/update FCM device token | App startup |
| `GET` | `/users/me/attendance` | Attendance history (dates) | Attendance History Screen |
| `GET` | `/users/me/milestones` | Spiritual journey milestones | Spiritual Journey Screen |
| `GET` | `/users/me/saved-items` | All saved/bookmarked items | Saved Items Screen |
| `POST` | `/users/me/saved-items` | Bookmark an item | Various screens |
| `DELETE` | `/users/me/saved-items/:id` | Remove bookmark | Saved Items Screen |

### 4.3 — Home

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `GET` | `/home/feed` | Combined home screen data (verse of day, latest sermon, upcoming events, live status, campaign) | Home Screen |

### 4.4 — Sermons

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `GET` | `/sermons` | List sermons (paginated, filter by series/speaker/date) | Sermons Screen |
| `GET` | `/sermons/featured` | Featured/latest sermons | Sermons Screen, Home Screen |
| `GET` | `/sermons/:id` | Sermon detail with notes, scripture | Sermon Detail Screen |
| `GET` | `/sermons/:id/stream` | Get audio/video stream URL | Audio/Video Player |
| `POST` | `/sermons/:id/progress` | Save playback position | Audio/Video Player |
| `POST` | `/sermons/:id/save` | Toggle save/bookmark | Sermon Detail |
| `GET` | `/sermons/saved` | User's saved sermons | Saved Sermons Screen |
| `GET` | `/series` | List all sermon series | Sermons Screen |
| `GET` | `/series/:id` | Series detail with sermon list | Series Detail Screen |
| `GET` | `/sermons/:id/notes` | Get user's notes for sermon | Sermon Notes Screen |
| `PUT` | `/sermons/:id/notes` | Save/update user sermon notes | Sermon Notes Screen |

### 4.5 — Events

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `GET` | `/events` | List events (upcoming/past, filter by category) | Events Screen |
| `GET` | `/events/featured` | Featured/next events | Home Screen |
| `GET` | `/events/:id` | Event detail with speakers | Event Detail Screen |
| `POST` | `/events/:id/register` | Register for event | Event Detail Screen |
| `DELETE` | `/events/:id/register` | Cancel registration | Event Detail Screen |
| `GET` | `/events/my` | User's registered events | My Events Screen |

### 4.6 — Giving

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `GET` | `/giving/categories` | Giving category list | Giving Screen |
| `POST` | `/giving/donate` | Process donation (Paystack/Stripe) | Giving Screen |
| `GET` | `/giving/history` | User's donation history | Giving History Screen |
| `GET` | `/giving/receipts/:id` | Receipt detail | Receipt Detail Screen |
| `GET` | `/giving/payment-methods` | Saved payment methods | Giving Screen |
| `POST` | `/giving/payment-methods` | Add payment method | Giving Screen |
| `DELETE` | `/giving/payment-methods/:id` | Remove payment method | Giving Screen |
| `GET` | `/giving/campaigns` | Active campaigns | Giving Campaign Screen |
| `GET` | `/giving/campaigns/:id` | Campaign detail + donor list | Giving Campaign Screen |
| `POST` | `/giving/campaigns/:id/donate` | Donate to campaign | Giving Campaign Screen |
| `GET` | `/giving/pledges` | User's pledges | Pledge Screen |
| `POST` | `/giving/pledges` | Create pledge | Pledge Screen |
| `GET` | `/giving/recurring` | Recurring donation schedules | Giving Screen |
| `POST` | `/giving/recurring` | Setup recurring giving | Giving Screen |
| `PUT` | `/giving/recurring/:id` | Update recurring schedule | Giving Screen |
| `DELETE` | `/giving/recurring/:id` | Cancel recurring giving | Giving Screen |

### 4.7 — Bible & Devotionals

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `GET` | `/bible/books` | List books with chapter counts | Bible Reader Screen |
| `GET` | `/bible/:book/:chapter` | Get verses for chapter | Bible Reader Screen |
| `GET` | `/bible/search?q=` | Search Bible text | Bible Reader Screen |
| `GET` | `/bible/highlights` | User's highlighted verses | Bible Reader Screen |
| `POST` | `/bible/highlights` | Add highlight | Bible Reader Screen |
| `DELETE` | `/bible/highlights` | Remove highlight | Bible Reader Screen |
| `GET` | `/devotionals/today` | Today's devotional | Daily Devotional Screen |
| `GET` | `/devotionals/:date` | Devotional by date | Daily Devotional Screen |
| `POST` | `/devotionals/:id/read` | Mark as read | Daily Devotional Screen |
| `GET` | `/devotionals/streak` | Current read streak | Daily Devotional Screen |
| `GET` | `/reading-plans` | Browse all reading plans | Reading Plan Screen |
| `GET` | `/reading-plans/:id` | Plan detail with days | Reading Plan Screen |
| `POST` | `/reading-plans/:id/enroll` | Join a reading plan | Reading Plan Screen |
| `POST` | `/reading-plans/:id/progress` | Mark day complete | Reading Plan Screen |
| `GET` | `/reading-plans/my` | User's enrolled plans | Reading Plan Screen |

### 4.8 — Community

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `GET` | `/groups` | List connect groups (filter by category) | Connect Groups Screen |
| `GET` | `/groups/:id` | Group detail with members | Group Detail Screen |
| `POST` | `/groups/:id/join` | Join group | Group Detail Screen |
| `DELETE` | `/groups/:id/leave` | Leave group | Group Detail Screen |
| `GET` | `/announcements` | Church announcements | Announcements Screen |
| `GET` | `/announcements/:id` | Announcement detail | Announcements Screen |
| `POST` | `/announcements/:id/read` | Mark as read | Announcements Screen |
| `GET` | `/testimonies` | Approved testimonies | Testimonies Screen |
| `POST` | `/testimonies` | Submit testimony (pending approval) | Testimonies Screen |
| `POST` | `/testimonies/:id/react` | Like or pray for testimony | Testimonies Screen |
| `GET` | `/directory` | Church directory (opted-in members) | Church Directory Screen |
| `POST` | `/invite/generate` | Generate personal invite link | Invite Friends Screen |
| `GET` | `/invite/:code` | Validate invite link | Register Screen |

### 4.9 — Forum

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `GET` | `/forum/categories` | Forum categories with thread counts | Forum Home Screen |
| `GET` | `/forum/trending` | Trending threads | Forum Home Screen |
| `GET` | `/forum/recent` | Recent threads | Forum Home Screen |
| `GET` | `/forum/categories/:id/threads` | Threads in category (sort, search, paginate) | Forum Category Screen |
| `GET` | `/forum/threads/:id` | Thread detail with post + replies | Forum Thread Screen |
| `POST` | `/forum/threads` | Create new thread | Create Post Screen |
| `POST` | `/forum/threads/:id/replies` | Reply to thread | Forum Thread Screen |
| `POST` | `/forum/threads/:id/like` | Toggle like on thread | Forum Thread Screen |
| `POST` | `/forum/threads/:id/bookmark` | Toggle bookmark | Forum Thread Screen |
| `POST` | `/forum/replies/:id/like` | Toggle like on reply | Forum Thread Screen |

### 4.10 — Chat ✅ BUILT

| Method | Endpoint | Description | Frontend Screen | Status |
|--------|----------|-------------|-----------------|--------|
| `GET` | `/chat/conversations` | User's conversations (with last message, unread count) | Chat List Screen | ✅ |
| `POST` | `/chat/conversations` | Create conversation (DIRECT dedup, GROUP) | Chat List Screen | ✅ |
| `GET` | `/chat/conversations/:id/messages` | Messages (paginated) | Chat Conversation Screen | ✅ |
| `POST` | `/chat/conversations/:id/messages` | Send message (also emits via Socket.io) | Chat Conversation Screen | ✅ |
| `PUT` | `/chat/conversations/:id/read` | Mark conversation as read | Chat Conversation Screen | ✅ |
| `PUT` | `/chat/conversations/:id/pin` | Toggle pin | Chat List Screen | ✅ |
| `PUT` | `/chat/conversations/:id/mute` | Toggle mute | Chat List Screen | ✅ |
| **WebSocket** | `chat:message` / `chat:typing` / `chat:read` / `chat:join` | Real-time message delivery | Chat Conversation Screen | ✅ |

### 4.11 — Notifications ✅ BUILT

| Method | Endpoint | Description | Frontend Screen | Status |
|--------|----------|-------------|-----------------|--------|
| `GET` | `/notifications` | User's notifications (paginated, filter by type/unread) | Notification Center Screen | ✅ |
| `GET` | `/notifications/unread-count` | Unread notification count | Badge on nav | ✅ |
| `PUT` | `/notifications/:id/read` | Mark notification as read | Notification Center Screen | ✅ |
| `PUT` | `/notifications/read-all` | Mark all as read | Notification Center Screen | ✅ |
| `DELETE` | `/notifications/:id` | Dismiss notification | Notification Center Screen | ✅ |

### 4.12 — Church Info

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `GET` | `/church/about` | Mission, vision, values, history | About Church Screen |
| `GET` | `/church/staff` | Pastors + ministry leaders | Pastors Screen |
| `GET` | `/church/campuses` | Campus list with service times | Campuses Screen |
| `GET` | `/church/faqs` | FAQ list by category | Help & FAQ Screen |
| `POST` | `/church/contact` | Submit contact form message | Contact Us Screen |

### 4.13 — Volunteering ✅ BUILT

| Method | Endpoint | Description | Frontend Screen | Status |
|--------|----------|-------------|-----------------|--------|
| `GET` | `/volunteer/opportunities` | List volunteer opportunities (paginated, filter by active) | Volunteer Screen | ✅ |
| `POST` | `/volunteer/signup` | Sign up for a volunteer opportunity | Volunteer Screen | ✅ |
| `GET` | `/volunteer/roster` | Get volunteer roster/shifts (upcoming/past) | Service Roster Screen | ✅ |
| `POST` | `/volunteer/checkin` | Check in for a shift | Service Roster Screen | ✅ |
| `POST` | `/volunteer/swap-shift` | Request a shift swap | Service Roster Screen | ✅ |
| `GET` | `/kids/children` | List registered children | Kids Check-In Screen | ✅ |
| `POST` | `/kids/register` | Register a child | Kids Check-In Screen | ✅ |
| `POST` | `/kids/checkin` | Check in child (generates QR code + security code) | Kids Check-In Screen | ✅ |
| `POST` | `/kids/checkout` | Check out child (validates security code) | Kids Check-In Screen | ✅ |
| `GET` | `/kids/rooms` | List rooms with availability | Kids Check-In Screen | ✅ |

### 4.14 — Media ✅ BUILT

| Method | Endpoint | Description | Frontend Screen | Status |
|--------|----------|-------------|-----------------|--------|
| `GET` | `/media/albums` | List photo albums | Photo Gallery Screen | ✅ |
| `POST` | `/media/albums` | Create a photo album | Photo Gallery Screen | ✅ |
| `GET` | `/media/albums/:id` | Get album details with photos | Photo Gallery Screen | ✅ |
| `POST` | `/media/albums/:id/photos` | Upload/add a photo to album | Photo Gallery Screen | ✅ |
| `GET` | `/media/podcasts` | List podcast episodes (paginated) | Podcast Feed Screen | ✅ |
| `GET` | `/media/podcasts/:id` | Get podcast episode detail | Podcast Feed Screen | ✅ |
| `POST` | `/media/podcasts/:id/progress` | Update podcast progress (also increments play count) | Podcast Feed Screen | ✅ |
| `GET` | `/media/songs` | List worship songs | Worship Lyrics Screen | ✅ |
| `GET` | `/media/songs/search` | Search worship songs | Worship Lyrics Screen | ✅ |
| `GET` | `/media/songs/:id` | Get worship song with sections & lyrics | Worship Lyrics Screen | ✅ |

### 4.15 — Prayer

| Method | Endpoint | Description | Frontend Screen |
|--------|----------|-------------|-----------------|
| `GET` | `/prayer-requests` | Public prayer requests | Prayer Requests (profile) |
| `GET` | `/prayer-requests/my` | User's own requests | Prayer Requests (profile) |
| `POST` | `/prayer-requests` | Submit new request | Prayer Request Screen |
| `POST` | `/prayer-requests/:id/pray` | Mark "I prayed" | Prayer Requests list |
| `PUT` | `/prayer-requests/:id/status` | Update status (answered) | Prayer Requests (profile) |

### 4.16 — Search ✅ BUILT

| Method | Endpoint | Description | Frontend Screen | Status |
|--------|----------|-------------|-----------------|--------|
| `GET` | `/search` | Search across sermons, events, groups, users, forums, albums, podcasts | Global Search Screen | ✅ |
| `GET` | `/search/trending` | Get trending content (by play count, registrations, memberships) | Global Search Screen | ✅ |

### 4.17 — Live Service ✅ BUILT

| Method | Endpoint | Description | Frontend Screen | Status |
|--------|----------|-------------|-----------------|--------|
| `GET` | `/live` | List all live services (paginated) | Live Services Screen | ✅ |
| `GET` | `/live/current` | Current live service or next upcoming | Home Screen, Live Service Screen | ✅ |
| `GET` | `/live/:id` | Live service detail | Live Service Screen | ✅ |
| `GET` | `/live/:id/chat` | Chat messages for a live service | Live Service Screen | ✅ |
| **WebSocket** | `live:join` / `live:message` / `live:reaction` / `live:prayer` | Real-time live interaction | Live Service Screen | ✅ |

---

## 5. Section-by-Section Breakdown

### 5.1 Authentication & Onboarding

**Screens:** Splash, Onboarding, Login, Register, Email Verification, Forgot Password, Create New Password, Church Code, Profile Setup

**Flow:**
```
App Launch → Splash
  ├─ First launch → Onboarding (3 slides) → Login/Register
  ├─ Not logged in → Login
  ├─ Logged in, no church code → Church Code Screen
  ├─ Logged in, no profile → Profile Setup
  └─ Fully authenticated → Home
```

**Backend responsibilities:**
- Backend handles email/password registration with bcrypt password hashing
- Backend generates JWT access tokens (short-lived) + refresh tokens (long-lived)
- JWT verification middleware on every protected request
- Church code validation matches against `churches.code`
- Backend creates `users` row on registration
- Password reset: generate secure token → send via SendGrid → verify token on reset
- Email verification: generate verification token → send via SendGrid → verify on click
- Social sign-in (Google/Apple) handled via OAuth2 → backend issues JWT tokens
- Backend stores `hasCompletedSetup` flag on user

**Data from frontend auth screens:**
| Field | Screen | Notes |
|-------|--------|-------|
| name | Register | stored in users.name |
| email | Register, Login | stored in users.email |
| password | Register, Login | hashed with bcrypt, stored in users.password_hash |
| church_code | Church Code | validated against churches.code |
| display_name | Profile Setup | updates users.name |
| bio | Profile Setup | updates users.bio |
| avatar | Profile Setup | upload to Cloudinary, URL in users.avatar_url |

---

### 5.2 Home Screen

**Screen:** Home Screen

**API Call:** `GET /home/feed` — returns a combined payload:

```json
{
  "greeting_name": "John",
  "verse_of_day": {
    "reference": "Psalm 46:10",
    "text": "Be still and know that I am God..."
  },
  "is_live": true,
  "live_service": { "id": "...", "title": "Sunday Worship", "viewer_count": 1243 },
  "active_campaign": { "id": "...", "title": "New Youth Center", "progress": 0.75 },
  "latest_sermon": { "id": "...", "title": "The Power of Faith", "speaker": "Pastor James", "duration": "42 min" },
  "upcoming_events": [ { "id": "...", "title": "Youth Night", "date": "Feb 28", "location": "Main Auditorium" } ],
  "story_highlights": [ { "id": "...", "label": "Worship", "image_url": "..." } ],
  "devotional_streak": 12,
  "devotional_day": 54,
  "unread_notifications": 3,
  "unread_messages": 2
}
```

**Why a combined endpoint?** The home screen displays data from ~8 different domains. A single endpoint avoids 8 parallel requests on app open and enables server-side caching with Redis (TTL: 60s).

---

### 5.3 Sermons & Media Playback

**Screens:** Sermons Screen, Sermon Detail, Series Detail, Audio Player, Video Player, Sermon Notes, Saved Sermons

**Key backend logic:**
- **Audio/Video streaming:** Store files on Cloudinary, return optimized CDN URLs with adaptive streaming
- **Playback progress:** Auto-save every 10s via `POST /sermons/:id/progress`
- **Download tracking:** Mark `is_downloaded` so user can see offline sermons
- **Sermon notes:** Per-user rich text notes stored in DB, auto-saved on changes
- **Series grouping:** Sermons belong to optional series; series page shows all sermons in order
- **Search:** Sermons searchable by title, speaker, scripture reference

---

### 5.4 Events

**Screens:** Events Screen, Event Detail, My Events

**Key backend logic:**
- **Registration:** Toggle-based (register/cancel); track `attendee_count` via trigger
- **Countdown timer:** Frontend calculates from `start_time`; backend just returns the timestamp
- **Category filter:** `category` field on events table
- **Recurring events:** Store `recurrence_rule` in iCal RRULE format; expand on query
- **Attendance marking:** Admin marks attendees at the event → feeds into attendance history
- **Event speakers:** Separate `event_speakers` table linked to event

---

### 5.5 Giving & Finances

**Screens:** Giving Screen, Giving Success, Giving Campaign, Pledge, Receipt Detail, Giving History

**Key backend logic:**
- **Payment processing:** Integrate Paystack (Africa) or Stripe (global)
  - Frontend gets a payment intent/token → sends to backend → backend charges via API
  - On success: create `donations` row, generate receipt number, send confirmation push + email
- **Recurring donations:** Backend schedules charges via Paystack/Stripe subscriptions
- **Campaigns:** Track raised amount (aggregate of donations with that campaign_id)
- **Pledges:** Track commitment vs. actual payments; send reminder on `next_due_date`
- **Receipts:** Auto-generate with church EIN for tax purposes; PDF generation for download
- **Saved payment methods:** Store tokenized card references (never raw card numbers)
- **Giving reminders:** Cron job sends push notification based on user's `reminder_frequency`

---

### 5.6 Bible, Devotionals & Reading Plans

**Screens:** Bible Reader, Daily Devotional, Reading Plan

**Key backend logic:**
- **Bible text:** Either use a public Bible API (api.bible) or seed a licensed translation into `bible_verses` table
- **Verse highlights:** Per-user highlights synced to backend
- **Devotionals:** Admin creates daily devotionals; served by date
- **Verse of the day:** Curated by admin or auto-selected from a schedule
- **Reading plans:** Admin creates plans with day-by-day readings; users enroll and track progress
- **Streak tracking:** Count consecutive days with a `user_devotional_reads` entry

---

### 5.7 Community & Groups

**Screens:** Connect Groups, Group Detail, Announcements, Testimonies, Church Directory, Invite Friends

**Key backend logic:**
- **Groups:** CRUD by admin; members join/leave; member count is `COUNT(group_memberships)`
- **Announcements:** Admin publishes; priority levels affect display order; push notification on urgent
- **Testimonies:** User-submitted, admin-moderated (`is_approved`); reactions (like/prayer) are toggleable
- **Church directory:** Only `is_directory_visible = true` users appear; searchable by name/department
- **Invite links:** Generate unique short codes; track usage; deep-link opens app registration

---

### 5.8 Forum

**Screens:** Forum Home, Forum Category, Forum Thread, Create Post

**Key backend logic:**
- **Categories:** Admin-created; thread count is `COUNT(forum_threads)` per category
- **Threads:** Paginated, sortable (latest, most-liked, most-replied); full-text search on title+body
- **Replies:** Paginated within thread; newest-first or oldest-first toggle
- **Likes:** Toggle-based (insert/delete from `forum_likes`); count cached on thread/reply
- **Bookmarks:** Toggle-based per user
- **Pinned/locked threads:** Admin-only toggle
- **View count:** Increment on `GET /forum/threads/:id`

---

### 5.9 Chat & Messaging

**Screens:** Chat List, Chat Conversation

**Key backend logic:**
- **Real-time via WebSocket (Socket.io):**
  - On connect: join rooms for all user's conversations
  - On message: broadcast to room → persist to DB → send push to offline users
- **Conversation types:** 1:1 and group chats
- **Unread count:** Compare `last_read_at` with latest message timestamp
- **Pin/mute:** Per-user flags on `conversation_members`
- **Online status:** Track via Socket.io connection/disconnect events → Redis set
- **Message history:** Paginated, cursor-based (by `created_at`)

---

### 5.10 Notifications & Push Notification System ⭐ CORE FEATURE

**Screens:** Notification Center, Manage Notifications

> **⚠️ Push notifications are a CRITICAL feature of this app.** Every major user action, content update, and engagement trigger should generate a push notification. This is the primary mechanism for keeping users engaged with the church community.

**Push Notification Strategy (Firebase Cloud Messaging — the ONLY Firebase service used):**

FCM is the **only Firebase service** in this app (no Firebase Auth, no Firebase Storage). It powers ALL push notifications across iOS, Android, and Web.

**Notification Triggers (ALL must be implemented):**

| Trigger Event | Recipients | Priority | Category |
|--------------|------------|----------|----------|
| New sermon published | All users (if pref enabled) | Normal | `sermons` |
| Live service started | All users (if pref enabled) | **High** | `live` |
| Event reminder (24h before) | Registered attendees | Normal | `events` |
| Event reminder (1h before) | Registered attendees | **High** | `events` |
| New chat message (user offline) | Conversation members | **High** | `chat` |
| Giving receipt confirmation | Donor | Normal | `giving` |
| Recurring donation processed | Donor | Normal | `giving` |
| Pledge due reminder (3 days) | Pledger | Normal | `giving` |
| Giving reminder (user-set frequency) | User | Normal | `giving` |
| Someone prayed for your request | Requester | Normal | `prayer` |
| Prayer request marked answered | Prayer warriors | Normal | `prayer` |
| New urgent announcement | All users | **High** | `announcements` |
| New normal announcement | All users (if pref enabled) | Normal | `announcements` |
| Group activity update | Group members | Normal | `groups` |
| Forum reply to your thread | Thread author | Normal | `forum` |
| Forum reply to bookmarked thread | Bookmarkers | Low | `forum` |
| Volunteer shift reminder (24h) | Volunteer | Normal | `volunteering` |
| Volunteer shift swap approved | Volunteer | Normal | `volunteering` |
| Kids check-in alert | Parent | **High** | `kids` |
| Daily devotional reminder | Enrolled users | Normal | `devotionals` |
| Reading plan reminder | Enrolled users | Normal | `devotionals` |
| Birthday/anniversary greetings | User | Normal | `personal` |
| Welcome message (new user) | New user | Normal | `system` |
| Account security alert | User | **High** | `security` |

**FCM Implementation Details:**
- **Device token management:** Store multiple FCM tokens per user (supports multiple devices in `fcm_tokens` array)
- **Token refresh:** Update token on app startup via `PUT /users/me/fcm-token`
- **Token cleanup:** Background job removes stale tokens (devices not seen in 30+ days)
- **Topic subscriptions:** Subscribe users to topics (e.g., `church_{id}_sermons`, `church_{id}_live`) for efficient bulk messaging
- **Data messages vs Notification messages:** Use data messages for custom in-app handling; notification messages for background/killed state delivery
- **Notification channels (Android):** Separate channels per category (chat, events, giving, sermons, etc.) for OS-level user control
- **Silent push:** For badge count sync and background data refresh
- **Batch sending:** Use FCM `sendEachForMulticast()` for bulk notifications (max 500 tokens per batch)
- **Fallback:** If FCM send fails, retry up to 3 times with exponential backoff via BullMQ

**In-app notification system:**
- **Stored in `notifications` table:** Every push also creates an in-app notification record
- **Paginated feed:** Cursor-based pagination with time-based grouping ("Today", "This Week", "Earlier")
- **Read/unread tracking:** Individual and bulk mark-as-read
- **Deep linking:** Each notification carries a `deep_link` field that navigates to the relevant screen
- **Real-time badge:** Unread count pushed via Socket.io → updates app badge instantly

**Notification preferences:**
- **Per-category toggles:** Users enable/disable push + email per category (stored in `users.notification_prefs` JSONB)
- **Quiet hours:** Optional quiet hours setting (e.g., no push between 10 PM - 7 AM)
- **Frontend screens:** Manage Notifications Screen controls per-category toggles; Settings Screen has master push toggle

---

### 5.11 Church Info (Static Content)

**Screens:** About Church, Pastors, Campuses, Contact Us, Help & FAQ

**Key backend logic:**
- Mostly **admin-managed content** (CMS-like)
- **About:** Church mission, vision, core values, history
- **Staff:** Pastors + ministry leaders with bios and photos
- **Campuses:** Locations, service times, directions (lat/lng for maps)
- **Contact form:** Saves message to DB → sends email to church admin
- **FAQ:** Categorized, searchable, admin-editable

---

### 5.12 Volunteering & Service

**Screens:** Volunteer, Service Roster, Kids Check-In

**Key backend logic:**
- **Opportunities:** Admin creates volunteer roles; tracks spots filled
- **Signup flow:** User selects role → pending approval → admin approves → added to roster
- **Roster:** Admin schedules shifts; user sees their upcoming/past shifts
- **Check-in:** User taps "Check In" on service day (geovalidation optional)
- **Shift swap:** User requests swap → notifies admin → admin approves
- **Kids check-in:** Parent registers children → selects room → system generates unique QR code → parent shows QR at pickup
- **QR code:** Generated server-side (or client-side with server validation); single-use per service

---

### 5.13 Media Library (Photos, Podcasts, Worship Lyrics)

**Screens:** Photo Gallery, Podcast Feed, Worship Lyrics

**Key backend logic:**
- **Photos:** Admin uploads to albums; stored on Cloudinary; thumbnails auto-generated via Cloudinary transformations
- **Podcasts:** RSS-like feed; audio hosted on Cloudinary; playback progress tracked per user
- **Worship lyrics:** Admin manages setlist, songs, sections, and chord charts
- **Chord transpose:** Can be computed client-side; backend stores original key

---

### 5.14 Prayer Requests

**Screens:** Prayer Request (submit form), Prayer Requests (profile list)

**Key backend logic:**
- **Public/private:** Private requests only visible to submitter + pastors
- **Prayer count:** Toggle-based (one prayer per user per request)
- **Status updates:** User can mark as "answered"
- **Notifications:** Notify requester when someone prays for their request

---

### 5.15 Profile & Account

**Screens:** Profile, Edit Profile, Settings, Giving History, My Events, Prayer Requests, Saved Items, Attendance History, Spiritual Journey, Manage Notifications

**Key backend logic:**
- **Profile data:** Aggregated from multiple tables (user, attendance, giving, milestones)
- **Stats row on profile screen:** Total attendance, total giving, groups joined — computed server-side
- **Spiritual journey:** Auto-generated milestones on key events:
  - First login → "Joined Grace Community"
  - First sermon watched → "First Sermon"
  - Joined group → "Joined a Connect Group"
  - First donation → "First Tithe"
  - Baptism (admin-recorded) → "Water Baptism"
  - Volunteer signup → "Started Volunteering"
  - Giving milestones → "$500 in Total Giving"
- **Attendance heatmap:** Query `attendance` table for date range → return set of dates
- **Theme preference:** Stored client-side (SharedPreferences) — no backend needed
- **Account deletion:** GDPR-compliant cascade delete of all user data

---

### 5.16 Search

**Screen:** Global Search Screen

**Key backend logic:**
- **Unified search:** Single endpoint searches across sermons, events, people, forum threads, Bible verses, groups, media
- **Implementation:** PostgreSQL full-text search with `tsvector` + `tsquery`; upgrade to Meilisearch for speed/relevance if needed
- **Result grouping:** Backend returns results grouped by category with counts
- **Trending:** Track search terms in Redis sorted set; return top N
- **Recent searches:** Stored client-side (or optionally server-side per user)

---

## 6. Real-Time Services

| Service | Technology | Used By |
|---------|------------|---------|
| **Live chat** | Socket.io room per service | Live Service Screen |
| **Direct messaging** | Socket.io room per conversation | Chat Conversation Screen |
| **Typing indicators** | Socket.io events | Chat Conversation Screen |
| **Online presence** | Redis set + Socket.io connect/disconnect | Chat List Screen |
| **Live viewer count** | Redis counter + Socket.io broadcast | Live Service Screen |
| **Real-time notifications** | Socket.io personal channel | Notification badge |
| **Live reactions** | Socket.io broadcast | Live Service Screen |

---

## 7. File Storage & CDN

| Content Type | Storage | Max Size | Format |
|-------------|---------|----------|--------|
| Profile avatars | Cloudinary (image) | 5 MB | JPEG/PNG, auto-resize via transformation |
| Sermon audio | Cloudinary (video/raw) | 200 MB | MP3, 128kbps |
| Sermon video | Cloudinary (video) | 2 GB | MP4 / HLS adaptive streaming |
| Event images | Cloudinary (image) | 10 MB | JPEG/PNG, auto-optimize |
| Photo gallery | Cloudinary (image) | 15 MB | JPEG, auto-thumbnail via transformation |
| Podcast audio | Cloudinary (video/raw) | 200 MB | MP3 |
| Church logo/covers | Cloudinary (image) | 5 MB | PNG/SVG |
| Kids check-in QR | Generated on-the-fly | N/A | PNG/SVG |
| Giving receipts (PDF) | Cloudinary (raw) | N/A | PDF |

---

## 8. Background Jobs & Cron

| Job | Schedule | Description |
|-----|----------|-------------|
| **Recurring donations** | Daily at 6 AM | Charge due recurring donations via Paystack/Stripe |
| **Pledge reminders** | Daily at 9 AM | Push + email for pledges due in 3 days |
| **Event reminders** | Hourly | Push to registered users 24h and 1h before event |
| **Devotional publish** | Daily at 5 AM | Ensure today's devotional is ready; push notification |
| **Giving receipt email** | On donation | Generate PDF receipt → email to donor |
| **Attendance streak calc** | Daily at midnight | Update devotional/attendance streaks |
| **Campaign progress update** | On donation | Recalculate `raised_amount` and `donor_count` |
| **Milestone generation** | On key events | Auto-create spiritual journey milestones |
| **Cleanup expired sessions** | Daily | Remove stale FCM tokens, expired invites |
| **Search index rebuild** | Weekly | Refresh full-text search indexes |

---

## 9. Third-Party Integrations

| Service | Purpose | Used By |
|---------|---------|---------|
| **Custom JWT Auth (bcrypt + jsonwebtoken)** | User authentication (email/password, OAuth2 for Google/Apple) | All auth screens |
| **Firebase Cloud Messaging** | Push notifications | All notification triggers |
| **Cloudinary** | All file storage (images, audio, video, documents) + CDN delivery | All media, profile, sermons, church info |
| **Paystack / Stripe** | Payment processing | Giving, pledges, recurring |
| **SendGrid / AWS SES** | Transactional emails (receipts, resets, invites) | Auth, giving, reminders |
| **YouTube / Vimeo API** | Live stream embedding | Live Service Screen |
| **Google Maps SDK** | Campus directions | Campuses Screen |
| **Bible API (api.bible)** | Scripture text (if not self-hosted) | Bible Reader Screen |
| **Deep linking (Branch)** | Invite links, notification deep links | Invite Friends, notifications |
| **Sentry** | Error tracking | All |

---

## 10. Admin Dashboard (Future Phase)

> Built AFTER the backend is complete. Two dashboards:

### 10.1 — Super Admin (Platform Owner)
- Manage churches (create, suspend, configure)
- View platform-wide analytics
- Manage Bible translations & global content

### 10.2 — Church Admin Dashboard
| Section | Features |
|---------|----------|
| **Dashboard** | Total members, giving this month, attendance trends, active groups |
| **Members** | User list, roles, departments, directory management |
| **Sermons** | Upload audio/video, create series, publish, manage notes |
| **Events** | Create/edit events, manage registrations, track attendance |
| **Giving** | View donations, manage campaigns, generate reports, tax receipts |
| **Content** | Devotionals, announcements, testimonies (approve/reject), FAQs |
| **Groups** | Create/manage groups, assign leaders, monitor activity |
| **Forum** | Moderate threads, pin/lock, manage categories |
| **Volunteering** | Create opportunities, manage roster, approve signups |
| **Kids** | Manage rooms, view check-in history |
| **Media** | Upload photos, manage albums, podcast episodes, worship setlists |
| **Notifications** | Send targeted push notifications, manage templates |
| **Settings** | Church profile, branding, service times, campuses, staff |
| **Reports** | Giving reports, attendance reports, growth analytics, export CSV |

---

## 11. Implementation Roadmap

### Phase 1 — Foundation (Week 1-2) ✅ COMPLETE
```
✅ Project setup (Express + TypeScript + Prisma + PostgreSQL)
✅ Database schema & migrations (20260226122844_init)
✅ Custom JWT auth middleware (bcrypt + jsonwebtoken)
✅ User registration & login flow (email/password + email verification)
✅ JWT refresh token mechanism
✅ Church code validation
✅ Profile CRUD
✅ File upload service (Cloudinary integration)
✅ FCM push notification service setup ⭐ (core infrastructure — integrate with ALL features)
```

### Phase 2 — Core Content (Week 3-4) ✅ COMPLETE — 31/31 tests
```
✅ Sermons CRUD + series + streaming URLs
✅ Events CRUD + registration
✅ Bible books/chapters/verses (seed data)
✅ Devotionals CRUD + daily endpoint
✅ Reading plans CRUD + enrollment + progress
✅ Church info (about, staff, campuses, FAQs, contact)
✅ Home feed endpoint (combined)
✅ Migration: 20260226140448_phase2_core_content
```

### Phase 3 — Giving & Finance (Week 5-6) ✅ COMPLETE — 25/25 tests
```
✅ Payment gateway integration (Paystack + Stripe with isDevStub())
✅ Donation processing
✅ Giving categories + campaigns
✅ Recurring donations
✅ Pledges
✅ Receipt generation (PDF via pdfkit)
✅ Giving history
✅ Webhook handlers with signature verification
✅ Migration: 20260226145435_phase3_giving
```

### Phase 4 — Community & Communication (Week 7-8) ✅ COMPLETE — 30/30 tests
```
✅ Connect groups CRUD + membership (4 endpoints)
✅ Announcements CRUD (3 endpoints)
✅ Testimonies CRUD + moderation (3 endpoints)
✅ Forum (categories, threads, replies, likes, bookmarks — 10 endpoints)
✅ Prayer requests (5 endpoints)
✅ Church directory (1 endpoint)
✅ Invite system (3 endpoints: generate, validate, stats)
✅ Home feed updated with announcements + urgentPrayerRequests
✅ Migration: 20260226155214_phase4_community
```

### Phase 5 — Real-Time & Messaging (Week 9-10) ✅ COMPLETE — 18/18 tests
```
✅ Socket.io infrastructure with JWT auth + Redis adapter for horizontal scaling
✅ Chat system — 7 REST endpoints + 4 WebSocket events
✅ Notification system — 5 REST endpoints + central dispatcher (DB + Socket.io + FCM)
✅ Live service — 4 REST endpoints + 5 WebSocket events
✅ Online presence tracking (Redis SET per church)
✅ 20+ notification trigger functions wired into 6 existing service files
✅ Migration: 20260226174757_phase5_realtime (6 enums + 6 models)
✅ Seed data: conversations, messages, notifications, live services, live chat
```

### Phase 6 — Operations & Media (Week 11-12) ✅ COMPLETE — 40/40 tests
```
✅ Volunteer opportunities + signups (5 endpoints)
✅ Kids check-in system (QR code + security code generation, 5 endpoints)
✅ Photo gallery + albums (4 endpoints)
✅ Podcast feed + progress tracking (3 endpoints)
✅ Worship songs with lyrics + chords (3 endpoints)
✅ Unified search across 7 entity types (2 endpoints)
✅ 5 notification triggers wired (kids check-in/out, volunteer signup/shift/swap)
✅ Migration: phase6_operations_media (4 new enums + 13 models)
✅ Dependencies: qrcode, @types/qrcode
```

### Phase 7 — Polish & Integration (Week 13-14) ✅ COMPLETE
```
✅ BullMQ background jobs (13 cron jobs across 7 queues: giving, events, devotionals, attendance, milestones, maintenance, volunteering)
✅ Email templates (9 total: welcome, verification, password reset, giving receipt, recurring summary, event registration, pledge reminder, volunteer shift, birthday greeting)
✅ Attendance tracking module (record, history, streak, stats — with QR/manual/geofence methods)
✅ Spiritual milestone engine (8 types: SALVATION, BAPTISM, FIRST_SERVE, SMALL_GROUP, MINISTRY_LEADER, FIRST_GIVE, ONE_YEAR, INVITE_FRIEND)
✅ Saved items / polymorphic bookmarks (SERMON, EVENT, DEVOTIONAL, READING_PLAN)
✅ Redis caching service (home feed, sermons, events, bible, church info, search trending, live viewers)
✅ User profile endpoints completed (attendance, milestones, saved items)
✅ 3 new Prisma models + 4 enums, migration applied
✅ Integration testing: 46/46 Phase 7 tests + 165/165 regression tests all passing
✅ TypeScript: 0 compilation errors
```

### Phase 8 — Admin Dashboard (Week 15-18) ⬜ NOT STARTED
```
⬜ Next.js admin web app
⬜ Super admin panel
⬜ Church admin dashboard
⬜ Analytics & reporting
⬜ Content management
```

---

## Appendix A: Frontend File Map (64 Screens)

| # | Feature Area | Screen File | Backend Endpoints Needed |
|---|-------------|-------------|------------------------|
| 1 | Splash | `splash/splash_screen.dart` | None (local auth check) |
| 2 | Onboarding | `onboarding/onboarding_screen.dart` | None (local flag) |
| 3 | Auth | `auth/login_screen.dart` | `POST /auth/login` |
| 4 | Auth | `auth/register_screen.dart` | `POST /auth/register` |
| 5 | Auth | `auth/email_verification_screen.dart` | `POST /auth/resend-verification` |
| 6 | Auth | `auth/forgot_password_screen.dart` | `POST /auth/forgot-password` |
| 7 | Auth | `auth/create_new_password_screen.dart` | `POST /auth/reset-password` |
| 8 | Auth | `auth/church_code_screen.dart` | `POST /auth/verify-church-code` |
| 9 | Auth | `auth/profile_setup_screen.dart` | `POST /auth/complete-setup` |
| 10 | Home | `home/home_screen.dart` | `GET /home/feed` |
| 11 | Home | `home/live_service_screen.dart` | `GET /live/current`, `WS /live/:id` |
| 12 | Sermons | `sermons/sermons_screen.dart` | `GET /sermons`, `GET /series` |
| 13 | Sermons | `sermons/sermon_detail_screen.dart` | `GET /sermons/:id` |
| 14 | Sermons | `sermons/series_detail_screen.dart` | `GET /series/:id` |
| 15 | Sermons | `sermons/audio_player_screen.dart` | `GET /sermons/:id/stream` |
| 16 | Sermons | `sermons/video_player_screen.dart` | `GET /sermons/:id/stream` |
| 17 | Sermons | `sermons/sermon_notes_screen.dart` | `GET/PUT /sermons/:id/notes` |
| 18 | Sermons | `sermons/saved_sermons_screen.dart` | `GET /sermons/saved` |
| 19 | Events | `events/events_screen.dart` | `GET /events` |
| 20 | Events | `events/event_detail_screen.dart` | `GET /events/:id`, `POST /events/:id/register` |
| 21 | Giving | `giving/giving_screen.dart` | `GET /giving/categories`, `POST /giving/donate` |
| 22 | Giving | `giving/giving_success_screen.dart` | None (confirmation UI) |
| 23 | Giving | `giving/giving_campaign_screen.dart` | `GET /giving/campaigns/:id` |
| 24 | Giving | `giving/pledge_screen.dart` | `GET/POST /giving/pledges` |
| 25 | Giving | `giving/receipt_detail_screen.dart` | `GET /giving/receipts/:id` |
| 26 | Bible | `bible/bible_reader_screen.dart` | `GET /bible/books`, `GET /bible/:book/:chapter` |
| 27 | Bible | `bible/daily_devotional_screen.dart` | `GET /devotionals/today` |
| 28 | Bible | `bible/reading_plan_screen.dart` | `GET /reading-plans` |
| 29 | Community | `community/connect_groups_screen.dart` | `GET /groups` |
| 30 | Community | `community/group_detail_screen.dart` | `GET /groups/:id` |
| 31 | Community | `community/announcements_screen.dart` | `GET /announcements` |
| 32 | Community | `community/testimonies_screen.dart` | `GET /testimonies` |
| 33 | Community | `community/church_directory_screen.dart` | `GET /directory` |
| 34 | Community | `community/invite_friends_screen.dart` | `POST /invite/generate` |
| 35 | Forum | `forum/forum_screen.dart` | `GET /forum/categories`, `GET /forum/trending` |
| 36 | Forum | `forum/forum_category_screen.dart` | `GET /forum/categories/:id/threads` |
| 37 | Forum | `forum/forum_thread_screen.dart` | `GET /forum/threads/:id` |
| 38 | Forum | `forum/create_post_screen.dart` | `POST /forum/threads` |
| 39 | Chat | `chat/chat_list_screen.dart` | `GET /chat/conversations` |
| 40 | Chat | `chat/chat_conversation_screen.dart` | `GET/POST /chat/:id/messages`, `WS` |
| 41 | Notifications | `notifications/notification_center_screen.dart` | `GET /notifications` |
| 42 | Church Info | `church_info/about_church_screen.dart` | `GET /church/about` |
| 43 | Church Info | `church_info/pastors_screen.dart` | `GET /church/staff` |
| 44 | Church Info | `church_info/campuses_screen.dart` | `GET /church/campuses` |
| 45 | Church Info | `church_info/contact_us_screen.dart` | `POST /church/contact` |
| 46 | Church Info | `church_info/help_faq_screen.dart` | `GET /church/faqs` |
| 47 | Volunteering | `volunteering/volunteer_screen.dart` | `GET /volunteer/opportunities` |
| 48 | Volunteering | `volunteering/service_roster_screen.dart` | `GET /volunteer/roster` |
| 49 | Volunteering | `volunteering/kids_checkin_screen.dart` | `POST /kids/checkin` |
| 50 | Media | `media/photo_gallery_screen.dart` | `GET /media/albums` |
| 51 | Media | `media/podcast_feed_screen.dart` | `GET /media/podcasts` |
| 52 | Media | `media/worship_lyrics_screen.dart` | `GET /media/worship/setlist` |
| 53 | Prayer | `prayer/prayer_request_screen.dart` | `POST /prayer-requests` |
| 54 | Profile | `profile/profile_screen.dart` | `GET /users/me` |
| 55 | Profile | `profile/edit_profile_screen.dart` | `PUT /users/me` |
| 56 | Profile | `profile/settings_screen.dart` | `POST /auth/logout` |
| 57 | Profile | `profile/giving_history_screen.dart` | `GET /giving/history` |
| 58 | Profile | `profile/my_events_screen.dart` | `GET /events/my` |
| 59 | Profile | `profile/prayer_requests_screen.dart` | `GET /prayer-requests/my` |
| 60 | Profile | `profile/saved_items_screen.dart` | `GET /users/me/saved-items` |
| 61 | Profile | `profile/attendance_history_screen.dart` | `GET /users/me/attendance` |
| 62 | Profile | `profile/spiritual_journey_screen.dart` | `GET /users/me/milestones` |
| 63 | Profile | `profile/manage_notifications_screen.dart` | `PUT /users/me/notification-prefs` |
| 64 | Search | `search/global_search_screen.dart` | `GET /search` |

---

## Appendix B: Current Frontend Models → Backend Mapping

| Frontend Model | File | Backend Table(s) |
|---------------|------|-------------------|
| `UserProfile` | `models/user.dart` | `users` |
| `Sermon` | `models/sermon.dart` | `sermons` |
| `SermonSeries` | `models/sermon.dart` | `sermon_series` |
| `Event` | `models/event.dart` | `events` |
| `SavedCard` | `models/giving.dart` | `payment_methods` |
| `ChatPreview` | `models/chat.dart` | `conversations` + `conversation_members` + latest `messages` |
| `ChatMessage` | `models/chat.dart` | `messages` |
| `ChatMeta` | `models/chat.dart` | `conversations` + `conversation_members` |
| `AppNotification` | `models/notification.dart` | `notifications` |
| `ConnectGroup` | `models/community.dart` | `connect_groups` + `group_memberships` count |
| `ForumCategory` | `models/forum.dart` | `forum_categories` |
| `ForumThread` | `models/forum.dart` | `forum_threads` + author `users` |
| `ForumPost` | `models/forum.dart` | `forum_threads` (detail view) |
| `ForumReply` | `models/forum.dart` | `forum_replies` + author `users` |
| `BibleBook` | `models/bible.dart` | `bible_books` |
| `SearchItem` | `models/search.dart` | Computed from multiple tables via search |

---

## Appendix C: Environment Variables

```env
# Server
NODE_ENV=production
PORT=8080
API_VERSION=v1

# Database
DATABASE_URL=postgresql://user:pass@host:5432/churchapp

# Redis
REDIS_URL=redis://host:6379

# JWT Authentication
JWT_SECRET=xxxxx
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=xxxxx
JWT_REFRESH_EXPIRES_IN=30d

# Firebase Cloud Messaging (Push Notifications ONLY — no Firebase Auth, no Firebase Storage)
FCM_PROJECT_ID=churchapp-xxxxx
FCM_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\n..."
FCM_CLIENT_EMAIL=firebase-adminsdk@churchapp.iam.gserviceaccount.com

# Payments
PAYSTACK_SECRET_KEY=sk_live_xxxxx
STRIPE_SECRET_KEY=sk_live_xxxxx

# Email
SENDGRID_API_KEY=SG.xxxxx
EMAIL_FROM=noreply@gracechurch.app

# Cloudinary (File Storage + CDN — free tier for testing)
CLOUDINARY_CLOUD_NAME=churchapp
CLOUDINARY_API_KEY=xxxxx
CLOUDINARY_API_SECRET=xxxxx

# App
CHURCH_APP_URL=https://churchapp.com
DEEP_LINK_SCHEME=churchapp
```

---

> **This document covers all 64 screens, 11 models, 10 repositories, 12 providers,
> 50+ database tables, 163+ API endpoints, 12 WebSocket events, 13 background jobs, and every mock data point currently
> hardcoded in the Flutter frontend. Nothing has been left behind.**
>
> **Current status:** Phases 1–7 complete (163+ endpoints, 211/211 tests passing). Next: Phase 8 — Admin Dashboard (Next.js).
