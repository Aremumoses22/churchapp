# Church App — Complete API Integration Guide

> **Base URL:** `http://localhost:8080/api/v1`
> **Swagger UI:** `http://localhost:8080/api/docs`
> **Spec (JSON):** `http://localhost:8080/api/docs.json`
> **WebSocket:** `ws://localhost:8080` (Socket.io)

---

## Table of Contents

1. [Authentication & Authorization](#1-authentication--authorization)
2. [Standard Response Format](#2-standard-response-format)
3. [Auth Endpoints](#3-auth-endpoints)
4. [User Endpoints](#4-user-endpoints)
5. [Sermons Endpoints](#5-sermons-endpoints)
6. [Events Endpoints](#6-events-endpoints)
7. [Bible Endpoints](#7-bible-endpoints)
8. [Church Info Endpoints](#8-church-info-endpoints)
9. [Home Feed Endpoint](#9-home-feed-endpoint)
10. [Giving Endpoints](#10-giving-endpoints)
11. [Groups Endpoints](#11-groups-endpoints)
12. [Community Endpoints](#12-community-endpoints)
13. [Forum Endpoints](#13-forum-endpoints)
14. [Prayer Endpoints](#14-prayer-endpoints)
15. [Chat Endpoints](#15-chat-endpoints)
16. [Notifications Endpoints](#16-notifications-endpoints)
17. [Live Service Endpoints](#17-live-service-endpoints)
18. [Volunteer Endpoints](#18-volunteer-endpoints)
19. [Kids Check-In Endpoints](#19-kids-check-in-endpoints)
20. [Media Endpoints](#20-media-endpoints)
21. [Search Endpoints](#21-search-endpoints)
22. [Attendance Endpoints](#22-attendance-endpoints)
23. [Milestones Endpoints](#23-milestones-endpoints)
24. [Saved Items Endpoints](#24-saved-items-endpoints)
25. [WebSocket Events (Real-Time)](#25-websocket-events-real-time)
26. [Enums & Constants](#26-enums--constants)
27. [Error Codes Reference](#27-error-codes-reference)

---

## 1. Authentication & Authorization

### JWT Bearer Token

All protected endpoints require a Bearer token in the `Authorization` header:

```
Authorization: Bearer <accessToken>
```

### Token Flow

1. **Register** → returns success message (verification email sent)
2. **Verify Email** → activates account
3. **Login** → returns `{ accessToken, refreshToken, user }`
4. **Verify Church Code** → associates user with a church
5. **Complete Setup** → finishes onboarding (name, bio, department)
6. Use `accessToken` for all subsequent requests
7. When token expires (`15m`), call **Refresh Token** with the `refreshToken` to get a new pair

### User Roles

| Role | Description |
|------|-------------|
| `MEMBER` | Default role for all registered users |
| `LEADER` | Group/ministry leaders |
| `PASTOR` | Church pastors |
| `ADMIN` | Church administrators |
| `SUPER_ADMIN` | Platform-level super admin |

### Rate Limiting

- **General:** 100 requests/min per IP (all API routes)
- **Auth routes:** 10 requests/15 min per IP (register, login, password reset, etc.)

---

## 2. Standard Response Format

### Success Response

```json
{
  "success": true,
  "message": "Success",
  "data": { ... }
}
```

### Paginated Response

```json
{
  "success": true,
  "message": "Success",
  "data": [ ... ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Error Response

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Invalid email address"]
  }
}
```

### Common Query Parameters (Pagination)

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | integer | 1 | Page number (min: 1) |
| `limit` | integer | 20 | Items per page (min: 1, max: 100) |

---

## 3. Auth Endpoints

**Prefix:** `/auth`

### POST `/auth/register`

Register a new user account. Sends a verification email.

- **Auth:** None (public)
- **Rate Limited:** Yes (10/15min)

**Request Body:**

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "Member@123"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `name` | string | Yes | 2–255 characters |
| `email` | string | Yes | Valid email format |
| `password` | string | Yes | 8–128 chars, ≥1 uppercase, ≥1 lowercase, ≥1 digit |

**Responses:**

| Status | Description |
|--------|-------------|
| 201 | User registered, verification email sent |
| 400 | Validation error |
| 409 | Email already registered |
| 429 | Rate limited |

---

### POST `/auth/login`

Authenticate with email and password. Returns JWT token pair.

- **Auth:** None (public)
- **Rate Limited:** Yes

**Request Body:**

```json
{
  "email": "john@example.com",
  "password": "Member@123"
}
```

**Success Response (200):**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "accessToken": "eyJhbGci...",
    "refreshToken": "eyJhbGci...",
    "user": {
      "id": "uuid",
      "email": "john@example.com",
      "name": "John Doe",
      "role": "MEMBER",
      "churchId": "uuid | null",
      "avatarUrl": "https://... | null",
      "hasCompletedSetup": false
    }
  }
}
```

| Status | Description |
|--------|-------------|
| 200 | Login successful |
| 401 | Invalid credentials |
| 429 | Rate limited |

---

### GET `/auth/verify-email/:token`

Verify a user's email address using the token from the verification email.

- **Auth:** None (public)

| Param | In | Type | Required |
|-------|----|------|----------|
| `token` | path | string | Yes |

| Status | Description |
|--------|-------------|
| 200 | Email verified |
| 400 | Invalid or expired token |

---

### POST `/auth/resend-verification`

Resend the email verification email.

- **Auth:** None (public)
- **Rate Limited:** Yes

**Request Body:**

```json
{
  "email": "john@example.com"
}
```

| Status | Description |
|--------|-------------|
| 200 | Verification email sent |
| 429 | Rate limited |

---

### POST `/auth/forgot-password`

Request a password reset email.

- **Auth:** None (public)
- **Rate Limited:** Yes

**Request Body:**

```json
{
  "email": "john@example.com"
}
```

| Status | Description |
|--------|-------------|
| 200 | Reset email sent (always returns 200 for security) |
| 429 | Rate limited |

---

### POST `/auth/reset-password`

Reset password using the token from the reset email.

- **Auth:** None (public)
- **Rate Limited:** Yes

**Request Body:**

```json
{
  "token": "reset-token-from-email",
  "password": "NewPassword@123"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `token` | string | Yes | From reset email |
| `password` | string | Yes | Min 8 characters |

| Status | Description |
|--------|-------------|
| 200 | Password reset successful |
| 400 | Invalid or expired token |
| 429 | Rate limited |

---

### POST `/auth/refresh-token`

Get a new access/refresh token pair using a valid refresh token.

- **Auth:** None (public)

**Request Body:**

```json
{
  "refreshToken": "eyJhbGci..."
}
```

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "accessToken": "new-access-token",
    "refreshToken": "new-refresh-token"
  }
}
```

| Status | Description |
|--------|-------------|
| 200 | New token pair returned |
| 401 | Invalid refresh token |

---

### POST `/auth/verify-church-code`

Join a church by entering the church's unique code (from onboarding).

- **Auth:** Bearer Token ✅

**Request Body:**

```json
{
  "code": "ABC123"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `code` | string | Yes | 4–10 characters |

| Status | Description |
|--------|-------------|
| 200 | Church joined |
| 401 | Unauthorized |
| 404 | Invalid church code |

---

### POST `/auth/complete-setup`

Complete account setup after registration (name, bio, department).

- **Auth:** Bearer Token ✅

**Request Body:**

```json
{
  "name": "John Doe",
  "bio": "Lover of worship and community",
  "department": "Media"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `name` | string | Yes | 2–255 characters |
| `bio` | string | No | Max 1000 characters |
| `department` | string | No | Max 100 characters |

| Status | Description |
|--------|-------------|
| 200 | Setup completed |
| 401 | Unauthorized |

---

### POST `/auth/logout`

Logout and clear the refresh token.

- **Auth:** Bearer Token ✅

| Status | Description |
|--------|-------------|
| 200 | Logged out |
| 401 | Unauthorized |

---

### DELETE `/auth/account`

Permanently delete user account.

- **Auth:** Bearer Token ✅

| Status | Description |
|--------|-------------|
| 200 | Account deleted |
| 401 | Unauthorized |

---

## 4. User Endpoints

**Prefix:** `/users`
**Auth:** All routes require Bearer Token ✅

### GET `/users/me`

Get the current authenticated user's profile.

**Success Response (200):**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "churchId": "uuid",
    "email": "john@example.com",
    "name": "John Doe",
    "phone": "+1234567890",
    "bio": "Community member",
    "avatarUrl": "https://...",
    "department": "Media",
    "role": "MEMBER",
    "joinedDate": "2026-01-15",
    "isActive": true,
    "isDirectoryVisible": true,
    "hasCompletedSetup": true,
    "notificationPrefs": { ... },
    "createdAt": "2026-01-15T10:00:00Z"
  }
}
```

---

### PUT `/users/me`

Update current user's profile.

**Request Body:**

```json
{
  "name": "John Updated",
  "phone": "+1234567890",
  "bio": "Updated bio",
  "department": "Worship",
  "isDirectoryVisible": true
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `name` | string | No | 2–255 characters |
| `phone` | string | No | — |
| `bio` | string | No | Max 1000 characters |
| `department` | string | No | — |
| `isDirectoryVisible` | boolean | No | — |

---

### PUT `/users/me/avatar`

Upload a new profile picture.

- **Content-Type:** `multipart/form-data`

| Field | Type | Description |
|-------|------|-------------|
| `avatar` | file (binary) | Image file, max 5MB, image/* only |

**Success Response:** Returns Cloudinary URL.

| Status | Description |
|--------|-------------|
| 200 | Avatar updated |
| 400 | Invalid file type or size |

---

### PUT `/users/me/notification-prefs`

Update notification preferences.

**Request Body:**

```json
{
  "events": true,
  "sermons": true,
  "giving": true,
  "prayer": true,
  "community": true,
  "chat": true,
  "system": true
}
```

All fields are optional booleans.

---

### PUT `/users/me/fcm-token`

Register or update Firebase Cloud Messaging push token.

**Request Body:**

```json
{
  "token": "fcm-token-string",
  "platform": "ios"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `token` | string | Yes | FCM device token |
| `platform` | string | No | `ios`, `android`, or `web` |

---

### GET `/users/me/attendance`

Get user's attendance history and streak.

---

### GET `/users/me/milestones`

Get user's spiritual journey milestones.

---

### GET `/users/me/saved-items`

Get user's saved/bookmarked items.

---

### POST `/users/me/saved-items`

Bookmark/save an item.

**Request Body:**

```json
{
  "entityType": "SERMON",
  "entityId": "uuid"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `entityType` | string | Yes | `SERMON`, `EVENT`, `DEVOTIONAL`, `READING_PLAN` |
| `entityId` | string (uuid) | Yes | UUID of the entity |

---

### DELETE `/users/me/saved-items/:id`

Remove a saved item.

| Param | In | Type |
|-------|----|------|
| `id` | path | uuid |

---

## 5. Sermons Endpoints

**Prefix:** `/sermons`

### GET `/sermons`

List sermons with pagination and filters.

- **Auth:** Optional (public, auth adds user-specific data)

| Param | In | Type | Description |
|-------|----|------|-------------|
| `page` | query | integer | Page number |
| `limit` | query | integer | Items per page |
| `seriesId` | query | uuid | Filter by sermon series |
| `search` | query | string | Search by title/speaker |

**Response:** Paginated list of sermons.

---

### GET `/sermons/featured`

Get featured sermons.

- **Auth:** Optional

---

### GET `/sermons/saved`

Get the authenticated user's saved sermons.

- **Auth:** Bearer Token ✅

---

### GET `/sermons/:id`

Get a single sermon's full detail.

- **Auth:** Optional

| Param | In | Type |
|-------|----|------|
| `id` | path | uuid |

**Response includes:** sermon data, series info, user progress (if authenticated), notes.

| Status | Description |
|--------|-------------|
| 200 | Sermon detail |
| 404 | Not found |

---

### GET `/sermons/:id/stream`

Get streaming URL for a sermon and increment its play count.

- **Auth:** Bearer Token ✅

| Param | In | Type |
|-------|----|------|
| `id` | path | uuid |

**Response:**

```json
{
  "success": true,
  "data": {
    "audioUrl": "https://...",
    "videoUrl": "https://...",
    "playCount": 42
  }
}
```

---

### POST `/sermons/:id/progress`

Save playback progress for a sermon.

- **Auth:** Bearer Token ✅

**Request Body:**

```json
{
  "position": 120,
  "completed": false
}
```

| Field | Type | Description |
|-------|------|-------------|
| `position` | number | Position in seconds |
| `completed` | boolean | Whether playback is finished |

---

### POST `/sermons/:id/save`

Toggle save/unsave a sermon (bookmark).

- **Auth:** Bearer Token ✅

**Response:** `{ saved: true }` or `{ saved: false }`

---

### GET `/sermons/:id/notes`

Get user's personal notes for a sermon.

- **Auth:** Bearer Token ✅

---

### PUT `/sermons/:id/notes`

Save/update personal notes for a sermon.

- **Auth:** Bearer Token ✅

**Request Body:**

```json
{
  "content": "Key takeaway: God is faithful..."
}
```

---

### GET `/sermons/series/all`

List all sermon series.

- **Auth:** Optional

---

### GET `/sermons/series/:id`

Get a specific series with all its sermons.

- **Auth:** Optional

| Status | Description |
|--------|-------------|
| 200 | Series with sermons |
| 404 | Not found |

---

## 6. Events Endpoints

**Prefix:** `/events`

### GET `/events`

List events with pagination and filters.

- **Auth:** Optional

| Param | In | Type | Description |
|-------|----|------|-------------|
| `page` | query | integer | Page number |
| `limit` | query | integer | Items per page |
| `upcoming` | query | boolean | Filter upcoming only |
| `category` | query | string | Filter by category (`worship`, `conference`, `youth`, `prayer`, `outreach`, `fellowship`) |

---

### GET `/events/featured`

Get featured events.

- **Auth:** Optional

---

### GET `/events/my`

Get events the current user is registered for.

- **Auth:** Bearer Token ✅

---

### GET `/events/:id`

Get event detail including speakers.

- **Auth:** Optional

| Status | Description |
|--------|-------------|
| 200 | Event detail with speakers |
| 404 | Not found |

**Event object includes:**

```json
{
  "id": "uuid",
  "title": "Youth Conference 2026",
  "description": "...",
  "category": "conference",
  "imageUrl": "https://...",
  "location": "Main Auditorium",
  "startDate": "2026-03-15T09:00:00Z",
  "endDate": "2026-03-15T17:00:00Z",
  "isRecurring": false,
  "recurrenceRule": null,
  "registrationRequired": true,
  "maxCapacity": 500,
  "registeredCount": 127,
  "isFeatured": true,
  "tags": ["youth", "conference"],
  "speakers": [
    { "name": "Pastor James", "title": "Senior Pastor", "imageUrl": "..." }
  ]
}
```

---

### POST `/events/:id/register`

Register (RSVP) for an event.

- **Auth:** Bearer Token ✅

| Status | Description |
|--------|-------------|
| 200 | Registered |
| 409 | Already registered |

---

### DELETE `/events/:id/register`

Cancel event registration.

- **Auth:** Bearer Token ✅

---

## 7. Bible Endpoints

**Prefix:** `/bible`

### GET `/bible/books`

List all 66 Bible books.

- **Auth:** None (public)

**Response:**

```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Genesis",
      "abbreviation": "Gen",
      "testament": "OT",
      "bookOrder": 1,
      "chapterCount": 50
    }
  ]
}
```

---

### GET `/bible/:bookId/:chapter`

Get a Bible chapter with all its verses and user highlights.

- **Auth:** Optional (highlights included if authenticated)

| Param | In | Type |
|-------|----|------|
| `bookId` | path | uuid |
| `chapter` | path | integer |

---

### GET `/bible/search`

Search Bible verses by keyword.

- **Auth:** None (public)

| Param | In | Type | Required |
|-------|----|------|----------|
| `q` | query | string | Yes |

---

### GET `/bible/highlights`

Get all of the authenticated user's verse highlights.

- **Auth:** Bearer Token ✅

---

### POST `/bible/highlights`

Highlight a verse.

- **Auth:** Bearer Token ✅

**Request Body:**

```json
{
  "verseId": "uuid",
  "color": "yellow",
  "note": "Important verse"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `verseId` | uuid | Yes | — |
| `color` | string | Yes | `yellow`, `blue`, `green`, `pink`, `orange` |
| `note` | string | No | Optional note |

---

### DELETE `/bible/highlights/:id`

Remove a verse highlight.

- **Auth:** Bearer Token ✅

---

### GET `/bible/devotionals/today`

Get today's daily devotional.

- **Auth:** Bearer Token ✅

**Response:**

```json
{
  "data": {
    "id": "uuid",
    "title": "Walking in Faith",
    "content": "...",
    "scriptureRef": "Psalm 23:1-6",
    "scriptureText": "The Lord is my shepherd...",
    "date": "2026-03-07",
    "imageUrl": "https://...",
    "authorName": "Pastor James",
    "isRead": false
  }
}
```

| Status | Description |
|--------|-------------|
| 200 | Today's devotional |
| 404 | No devotional for today |

---

### GET `/bible/devotionals/streak`

Get the user's devotional reading streak.

- **Auth:** Bearer Token ✅

**Response:**

```json
{
  "data": {
    "currentStreak": 7,
    "longestStreak": 30,
    "totalReads": 45,
    "recentDates": ["2026-03-07", "2026-03-06", ...]
  }
}
```

---

### GET `/bible/devotionals/:date`

Get a devotional by specific date.

- **Auth:** Bearer Token ✅

| Param | In | Type | Example |
|-------|----|------|---------|
| `date` | path | string (date) | `2026-02-26` |

---

### POST `/bible/devotionals/:id/read`

Mark a devotional as read.

- **Auth:** Bearer Token ✅

---

### GET `/bible/reading-plans`

Browse available reading plans.

- **Auth:** Optional

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

---

### GET `/bible/reading-plans/my`

Get reading plans the user is enrolled in, with progress.

- **Auth:** Bearer Token ✅

---

### GET `/bible/reading-plans/:id`

Get reading plan detail with all days.

- **Auth:** Optional

| Status | Description |
|--------|-------------|
| 200 | Plan detail with days |
| 404 | Not found |

**Response includes:**

```json
{
  "data": {
    "id": "uuid",
    "title": "30 Days of Faith",
    "description": "...",
    "imageUrl": "https://...",
    "durationDays": 30,
    "category": "faith",
    "enrolledCount": 50,
    "days": [
      {
        "dayNumber": 1,
        "title": "Day 1: Trust",
        "scriptureRef": "Hebrews 11:1",
        "content": "..."
      }
    ],
    "userProgress": {
      "currentDay": 5,
      "completedDays": [1, 2, 3, 4]
    }
  }
}
```

---

### POST `/bible/reading-plans/:id/enroll`

Enroll in a reading plan.

- **Auth:** Bearer Token ✅

| Status | Description |
|--------|-------------|
| 200 | Enrolled |
| 409 | Already enrolled |

---

### POST `/bible/reading-plans/:id/progress`

Mark a reading plan day as complete.

- **Auth:** Bearer Token ✅

**Request Body:**

```json
{
  "day": 5
}
```

---

## 8. Church Info Endpoints

**Prefix:** `/church`
**Auth:** All routes require Bearer Token ✅

### GET `/church/about`

Get the user's church information.

**Response:**

```json
{
  "data": {
    "id": "uuid",
    "name": "Grace Community Church",
    "tagline": "Building faith together",
    "mission": "...",
    "vision": "...",
    "phone": "+1234567890",
    "email": "info@gracechurch.app",
    "website": "https://gracechurch.app",
    "address": "123 Faith Avenue",
    "logoUrl": "https://...",
    "coverImageUrl": "https://...",
    "socialLinks": {
      "facebook": "https://...",
      "instagram": "https://...",
      "youtube": "https://...",
      "twitter": "https://..."
    },
    "coreValues": [
      { "title": "Love", "description": "...", "iconUrl": "..." }
    ]
  }
}
```

---

### GET `/church/staff`

Get the church staff directory.

**Response:** Array of staff members with `name`, `title`, `bio`, `imageUrl`, `email`, `phone`.

---

### GET `/church/campuses`

Get church campuses with service times.

**Response:** Array of campuses, each with nested `serviceTimes`:

```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Main Campus",
      "address": "123 Faith Ave",
      "lat": 6.5244,
      "lng": 3.3792,
      "phone": "+1234567890",
      "imageUrl": "https://...",
      "isPrimary": true,
      "serviceTimes": [
        { "dayOfWeek": "Sunday", "time": "09:00", "label": "First Service" },
        { "dayOfWeek": "Sunday", "time": "11:00", "label": "Second Service" },
        { "dayOfWeek": "Wednesday", "time": "18:00", "label": "Bible Study" }
      ]
    }
  ]
}
```

---

### GET `/church/faqs`

Get church FAQs.

**Response:** Array of `{ question, answer, category, sortOrder }`.

---

### POST `/church/contact`

Submit a contact/inquiry form.

**Request Body:**

```json
{
  "subject": "Prayer request question",
  "message": "I have a question about..."
}
```

| Field | Type | Required |
|-------|------|----------|
| `subject` | string | Yes |
| `message` | string | Yes |

---

## 9. Home Feed Endpoint

**Prefix:** `/home`
**Auth:** Bearer Token ✅

### GET `/home/feed`

Get the personalized home feed aggregating multiple content types.

**Response:**

```json
{
  "data": {
    "greeting": "Good morning, John!",
    "verseOfTheDay": { "reference": "Psalm 23:1", "text": "..." },
    "todaysDevotional": { ... },
    "latestSermon": { ... },
    "upcomingEvents": [ ... ],
    "activeAnnouncements": [ ... ],
    "prayerRequests": [ ... ],
    "activeCampaigns": [ ... ],
    "readingPlanProgress": { ... }
  }
}
```

---

## 10. Giving Endpoints

**Prefix:** `/giving`
**Auth:** All routes require Bearer Token ✅ (except webhooks)

### GET `/giving/categories`

List giving categories (tithes, offerings, building fund, etc.).

**Response:**

```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Tithe",
      "description": "Regular tithe giving",
      "isActive": true,
      "sortOrder": 1
    }
  ]
}
```

---

### GET `/giving/summary`

Get user's giving summary with totals.

**Response:**

```json
{
  "data": {
    "totalGiven": 15000,
    "thisMonth": 2500,
    "thisYear": 15000,
    "donationCount": 12,
    "recentDonations": [ ... ]
  }
}
```

---

### POST `/giving/donate`

Initiate a donation (unified endpoint, handles Paystack/Stripe based on configuration).

**Request Body:**

```json
{
  "amount": 5000,
  "categoryId": "uuid",
  "paymentMethod": "CARD",
  "campaignId": "uuid (optional)",
  "isAnonymous": false,
  "notes": "Sunday offering"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `amount` | number | Yes | Min 1 |
| `categoryId` | uuid | Yes | — |
| `paymentMethod` | string | Yes | `CARD`, `BANK`, `MOBILE`, `WALLET` |
| `campaignId` | uuid | No | — |
| `isAnonymous` | boolean | No | Default: false |
| `notes` | string | No | — |

**Response:** Payment authorization URL or client secret (depends on provider).

---

### POST `/giving/verify`

Verify a transaction after payment callback.

**Request Body:**

```json
{
  "reference": "transaction-reference"
}
```

---

### GET `/giving/history`

Get donation history (paginated).

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

---

### GET `/giving/receipts/:id`

Get a donation receipt.

---

### GET `/giving/receipts/:id/download`

Download donation receipt as PDF.

| Status | Description |
|--------|-------------|
| 200 | PDF download URL |
| 404 | Not found |

---

### GET `/giving/payment-methods`

List user's saved payment methods.

---

### POST `/giving/payment-methods`

Add a new payment method.

**Request Body:**

```json
{
  "type": "CARD",
  "last4": "4242",
  "provider": "PAYSTACK",
  "expiryMonth": 12,
  "expiryYear": 2028,
  "bankName": null,
  "isDefault": true
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `type` | string | Yes | `CARD`, `BANK` |
| `last4` | string | Yes | Last 4 digits |
| `provider` | string | Yes | `PAYSTACK`, `STRIPE` |
| `expiryMonth` | integer | No | — |
| `expiryYear` | integer | No | — |
| `bankName` | string | No | — |
| `isDefault` | boolean | No | — |

---

### DELETE `/giving/payment-methods/:id`

Remove a saved payment method.

---

### GET `/giving/campaigns`

List giving campaigns (paginated).

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

**Response includes:** `title`, `description`, `imageUrl`, `goalAmount`, `raisedAmount`, `donorCount`, `startDate`, `endDate`, `isActive`.

---

### GET `/giving/campaigns/:id`

Get campaign detail.

| Status | Description |
|--------|-------------|
| 200 | Campaign detail |
| 404 | Not found |

---

### POST `/giving/campaigns/:id/donate`

Donate directly to a campaign.

---

### GET `/giving/pledges`

Get user's pledges (paginated).

---

### POST `/giving/pledges`

Create a new pledge.

**Request Body:**

```json
{
  "campaignId": "uuid",
  "totalAmount": 50000,
  "endDate": "2026-12-31"
}
```

| Field | Type | Required |
|-------|------|----------|
| `campaignId` | uuid | Yes |
| `totalAmount` | number | Yes (min: 1) |
| `endDate` | string (date) | No |

---

### POST `/giving/pledges/:id/pay`

Make a payment towards a pledge.

**Request Body:**

```json
{
  "amount": 5000,
  "paymentMethod": "CARD"
}
```

---

### DELETE `/giving/pledges/:id`

Cancel a pledge.

---

### GET `/giving/recurring`

List user's recurring donations.

---

### POST `/giving/recurring`

Set up a new recurring donation.

**Request Body:**

```json
{
  "amount": 10000,
  "categoryId": "uuid",
  "frequency": "MONTHLY",
  "paymentMethodId": "uuid"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `amount` | number | Yes | Min 1 |
| `categoryId` | uuid | Yes | — |
| `frequency` | string | Yes | `WEEKLY`, `BIWEEKLY`, `MONTHLY`, `QUARTERLY`, `ANNUALLY` |
| `paymentMethodId` | uuid | Yes | — |

---

### PUT `/giving/recurring/:id`

Update a recurring donation.

**Request Body:**

```json
{
  "amount": 15000,
  "frequency": "MONTHLY",
  "isActive": true
}
```

All fields optional.

---

### DELETE `/giving/recurring/:id`

Cancel a recurring donation.

---

### POST `/giving/webhooks/paystack`

Paystack webhook endpoint (public, signature verified internally via HMAC).

---

### POST `/giving/webhooks/stripe`

Stripe webhook endpoint (public, signature verified internally).

---

## 11. Groups Endpoints

**Prefix:** `/groups`
**Auth:** All routes require Bearer Token ✅

### GET `/groups`

List connect groups (paginated).

| Param | In | Type | Description |
|-------|----|------|-------------|
| `page` | query | integer | — |
| `limit` | query | integer | — |
| `category` | query | string | Filter: `BIBLE_STUDY`, `YOUTH`, `WOMEN`, `MEN`, `COUPLES`, `PRAYER`, `SERVICE`, `OTHER` |

**Response item:**

```json
{
  "id": "uuid",
  "name": "Young Adults Bible Study",
  "description": "...",
  "imageUrl": "https://...",
  "category": "BIBLE_STUDY",
  "meetingDay": "Wednesday",
  "meetingTime": "6:00 PM",
  "location": "Room 201",
  "memberCount": 15,
  "maxMembers": 25,
  "isActive": true,
  "leader": { "id": "uuid", "name": "Jane Doe", "avatarUrl": "..." }
}
```

---

### GET `/groups/:id`

Get group detail with members list.

| Status | Description |
|--------|-------------|
| 200 | Group detail with members |
| 404 | Not found |

---

### POST `/groups/:id/join`

Join a connect group.

| Status | Description |
|--------|-------------|
| 200 | Joined successfully |
| 409 | Already a member |

---

### DELETE `/groups/:id/leave`

Leave a connect group.

---

## 12. Community Endpoints

**Prefix:** `/community`
**Auth:** All routes require Bearer Token ✅ (except invite validation)

### GET `/community/announcements`

List active announcements (not expired).

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

**Response item:**

```json
{
  "id": "uuid",
  "title": "Church Picnic This Saturday",
  "content": "...",
  "imageUrl": "https://...",
  "category": "event",
  "isUrgent": false,
  "isPinned": true,
  "publishedAt": "2026-03-05T10:00:00Z",
  "expiresAt": "2026-03-10T23:59:59Z",
  "author": { "name": "Pastor James" },
  "isRead": false
}
```

---

### GET `/community/announcements/:id`

Get announcement detail.

---

### POST `/community/announcements/:id/read`

Mark an announcement as read.

---

### GET `/community/testimonies`

List approved testimonies (paginated).

---

### POST `/community/testimonies`

Submit a testimony (goes to pending approval).

**Request Body:**

```json
{
  "title": "God Healed Me",
  "content": "I want to share my testimony...",
  "isAnonymous": false
}
```

| Field | Type | Required |
|-------|------|----------|
| `title` | string | Yes |
| `content` | string | Yes |
| `isAnonymous` | boolean | No (default: false) |

| Status | Description |
|--------|-------------|
| 201 | Testimony submitted (pending approval) |

---

### POST `/community/testimonies/:id/react`

React to a testimony (like or pray — toggle).

**Request Body:**

```json
{
  "type": "LIKE"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `type` | string | Yes | `LIKE`, `PRAY` |

---

### GET `/community/directory`

Browse the church member directory.

| Param | In | Type | Description |
|-------|----|------|-------------|
| `page` | query | integer | — |
| `limit` | query | integer | — |
| `search` | query | string | Search by name |

**Members returned only if they have `isDirectoryVisible = true`.**

---

### POST `/community/invite/generate`

Generate an invite link/code.

**Response:**

```json
{
  "data": {
    "code": "ABC123XYZ",
    "link": "https://churchapp.link/invite/ABC123XYZ",
    "expiresAt": "2026-04-07T00:00:00Z"
  }
}
```

---

### GET `/community/invite/stats`

Get user's invite statistics.

**Response:**

```json
{
  "data": {
    "totalInvites": 5,
    "totalUsed": 3,
    "invites": [ ... ]
  }
}
```

---

### GET `/community/invite/:code`

Validate an invite code (public, no auth needed).

| Status | Description |
|--------|-------------|
| 200 | Invite details (church name, inviter name) |
| 404 | Invalid or expired code |

---

## 13. Forum Endpoints

**Prefix:** `/forum`
**Auth:** All routes require Bearer Token ✅

### GET `/forum/categories`

List forum categories with thread counts.

**Response:**

```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Prayer & Worship",
      "description": "...",
      "iconUrl": "https://...",
      "threadCount": 42
    }
  ]
}
```

---

### GET `/forum/trending`

Get trending forum threads (by engagement).

---

### GET `/forum/recent`

Get recent threads (paginated, sortable).

| Param | In | Type | Values |
|-------|----|------|--------|
| `page` | query | integer | — |
| `limit` | query | integer | — |
| `sort` | query | string | `recent`, `popular` |

---

### GET `/forum/categories/:id/threads`

Get all threads in a specific category (paginated).

| Param | In | Type |
|-------|----|------|
| `id` | path | uuid |
| `page` | query | integer |
| `limit` | query | integer |

---

### POST `/forum/threads`

Create a new thread.

**Request Body:**

```json
{
  "categoryId": "uuid",
  "title": "How to grow in faith?",
  "content": "I've been struggling with..."
}
```

| Field | Type | Required |
|-------|------|----------|
| `categoryId` | uuid | Yes |
| `title` | string | Yes |
| `content` | string | Yes |

---

### GET `/forum/threads/:id`

Get thread detail with paginated replies.

| Param | In | Type |
|-------|----|------|
| `id` | path | uuid |
| `page` | query | integer |
| `limit` | query | integer |

**Response includes:** thread data, author, reply count, likes, bookmarks, paginated replies with authors.

---

### POST `/forum/threads/:id/replies`

Reply to a thread.

**Request Body:**

```json
{
  "content": "I've found that daily devotion helps..."
}
```

---

### POST `/forum/threads/:id/like`

Toggle like on a thread.

**Response:** `{ liked: true }` or `{ liked: false }`

---

### POST `/forum/threads/:id/bookmark`

Toggle bookmark on a thread.

**Response:** `{ bookmarked: true }` or `{ bookmarked: false }`

---

### POST `/forum/replies/:id/like`

Toggle like on a reply.

---

## 14. Prayer Endpoints

**Prefix:** `/prayer-requests`
**Auth:** All routes require Bearer Token ✅

### GET `/prayer-requests`

List active prayer requests (paginated).

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

**Response item:**

```json
{
  "id": "uuid",
  "title": "Healing for my mother",
  "content": "...",
  "isAnonymous": false,
  "isUrgent": true,
  "status": "ACTIVE",
  "prayerCount": 15,
  "author": { "id": "uuid", "name": "John Doe", "avatarUrl": "..." },
  "hasPrayed": false,
  "createdAt": "2026-03-05T10:00:00Z"
}
```

---

### GET `/prayer-requests/my`

Get the current user's own prayer requests.

---

### POST `/prayer-requests`

Create a new prayer request.

**Request Body:**

```json
{
  "title": "Healing for my mother",
  "content": "Please pray for my mother who is ill...",
  "isAnonymous": false,
  "isUrgent": true
}
```

| Field | Type | Required |
|-------|------|----------|
| `title` | string | Yes |
| `content` | string | Yes |
| `isAnonymous` | boolean | No (default: false) |
| `isUrgent` | boolean | No (default: false) |

---

### POST `/prayer-requests/:id/pray`

Pray for a request (toggle — pray/un-pray).

**Response:** `{ prayed: true }` or `{ prayed: false }` with updated `prayerCount`.

---

### PUT `/prayer-requests/:id/status`

Update the status of a prayer request (owner only).

**Request Body:**

```json
{
  "status": "ANSWERED"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `status` | string | Yes | `ACTIVE`, `ANSWERED`, `CLOSED` |

---

## 15. Chat Endpoints

**Prefix:** `/chat`
**Auth:** All routes require Bearer Token ✅

### GET `/chat/conversations`

List all of the user's conversations with the last message preview.

**Response item:**

```json
{
  "id": "uuid",
  "type": "DIRECT",
  "name": null,
  "imageUrl": null,
  "lastMessageAt": "2026-03-07T10:00:00Z",
  "lastMessage": {
    "content": "See you Sunday!",
    "sender": { "name": "Jane" },
    "createdAt": "..."
  },
  "otherMember": { "id": "uuid", "name": "Jane Doe", "avatarUrl": "..." },
  "unreadCount": 3,
  "isPinned": false,
  "isMuted": false
}
```

---

### POST `/chat/conversations`

Create a new conversation (direct or group).

**Request Body:**

```json
{
  "type": "DIRECT",
  "name": null,
  "memberIds": ["uuid-of-other-user"]
}
```

For group chat:

```json
{
  "type": "GROUP",
  "name": "Youth Leaders",
  "memberIds": ["uuid1", "uuid2", "uuid3"]
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | `DIRECT` or `GROUP` |
| `name` | string | No | Required for GROUP type |
| `memberIds` | uuid[] | Yes | Array of user UUIDs to add |

---

### GET `/chat/conversations/:id/messages`

Get messages in a conversation (paginated, newest first).

| Param | In | Type |
|-------|----|------|
| `id` | path | uuid |
| `page` | query | integer |
| `limit` | query | integer |

**Message object:**

```json
{
  "id": "uuid",
  "content": "Hello!",
  "type": "TEXT",
  "mediaUrl": null,
  "replyToId": null,
  "isEdited": false,
  "isDeleted": false,
  "createdAt": "2026-03-07T10:00:00Z",
  "sender": { "id": "uuid", "name": "John", "avatarUrl": "..." },
  "replyTo": null
}
```

---

### POST `/chat/conversations/:id/messages`

Send a message in a conversation.

**Request Body:**

```json
{
  "content": "Hello! How are you?",
  "type": "TEXT",
  "mediaUrl": null,
  "replyToId": null
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `content` | string | Yes | — |
| `type` | string | No | `TEXT`, `IMAGE`, `VIDEO`, `AUDIO`, `FILE` (default: `TEXT`) |
| `mediaUrl` | string (uri) | No | URL of media attachment |
| `replyToId` | uuid | No | Message ID being replied to |

---

### PUT `/chat/conversations/:id/read`

Mark a conversation as read (updates `lastReadAt`).

---

### PUT `/chat/conversations/:id/pin`

Toggle pin on a conversation.

---

### PUT `/chat/conversations/:id/mute`

Toggle mute on a conversation.

---

## 16. Notifications Endpoints

**Prefix:** `/notifications`
**Auth:** All routes require Bearer Token ✅

### GET `/notifications`

List user notifications (paginated).

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

**Notification object:**

```json
{
  "id": "uuid",
  "type": "EVENT",
  "title": "New Event: Youth Conference",
  "body": "Don't miss the upcoming youth conference...",
  "data": {
    "entityId": "uuid",
    "entityType": "event",
    "deepLink": "churchapp://events/uuid"
  },
  "isRead": false,
  "readAt": null,
  "createdAt": "2026-03-07T10:00:00Z"
}
```

**Notification types:** `SERMON`, `EVENT`, `CHAT`, `GIVING`, `PRAYER`, `ANNOUNCEMENT`, `GROUP`, `FORUM`, `VOLUNTEER`, `KIDS`, `DEVOTIONAL`, `PERSONAL`, `SECURITY`, `SYSTEM`

---

### GET `/notifications/unread-count`

Get the number of unread notifications.

**Response:**

```json
{
  "data": { "count": 5 }
}
```

---

### PUT `/notifications/read-all`

Mark all notifications as read.

---

### PUT `/notifications/:id/read`

Mark a single notification as read.

---

### DELETE `/notifications/:id`

Delete a notification.

---

## 17. Live Service Endpoints

**Prefix:** `/live`
**Auth:** All routes require Bearer Token ✅

### GET `/live`

List live services (paginated, filterable by status).

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

**Response item:**

```json
{
  "id": "uuid",
  "title": "Sunday Worship Service",
  "description": "Join us live...",
  "streamUrl": "https://youtube.com/live/...",
  "status": "LIVE",
  "scheduledAt": "2026-03-07T09:00:00Z",
  "startedAt": "2026-03-07T09:05:00Z",
  "endedAt": null,
  "viewerCount": 145
}
```

**Status values:** `SCHEDULED`, `LIVE`, `ENDED`

---

### GET `/live/current`

Get the current live or next upcoming service.

---

### GET `/live/:id`

Get live service detail.

---

### GET `/live/:id/chat`

Get live chat messages for a service (paginated).

| Param | In | Type |
|-------|----|------|
| `id` | path | uuid |
| `page` | query | integer |
| `limit` | query | integer |

**Chat message:**

```json
{
  "id": "uuid",
  "content": "Amen! 🙏",
  "type": "MESSAGE",
  "createdAt": "2026-03-07T09:15:00Z",
  "user": { "id": "uuid", "name": "John", "avatarUrl": "..." }
}
```

**Live chat types:** `MESSAGE`, `PRAYER`, `REACTION`

---

## 18. Volunteer Endpoints

**Prefix:** `/volunteer`
**Auth:** All routes require Bearer Token ✅

### GET `/volunteer/opportunities`

List volunteer opportunities.

| Param | In | Type | Description |
|-------|----|------|-------------|
| `department` | query | string | Filter: `Media`, `Worship`, `Ushering`, `Children`, `Technical` |
| `active` | query | boolean | Filter active only |

**Response item:**

```json
{
  "id": "uuid",
  "title": "Worship Team Vocalist",
  "description": "Join the worship team...",
  "department": "Worship",
  "requirements": "Must be able to sing...",
  "imageUrl": "https://...",
  "isActive": true
}
```

---

### POST `/volunteer/signup`

Sign up for a volunteer opportunity.

**Request Body:**

```json
{
  "opportunityId": "uuid"
}
```

| Status | Description |
|--------|-------------|
| 201 | Signed up (pending approval) |
| 409 | Already signed up |

---

### GET `/volunteer/roster`

Get the user's shift roster.

| Param | In | Type | Description |
|-------|----|------|-------------|
| `upcoming` | query | boolean | Filter upcoming shifts only |

**Response item:**

```json
{
  "id": "uuid",
  "date": "2026-03-09",
  "startTime": "09:00",
  "endTime": "12:00",
  "status": "SCHEDULED",
  "checkinAt": null,
  "opportunity": { "title": "Ushering", "department": "Ushering" }
}
```

**Shift statuses:** `SCHEDULED`, `CHECKED_IN`, `COMPLETED`, `SWAPPED`

---

### POST `/volunteer/roster/:id/checkin`

Check in to a shift.

| Status | Description |
|--------|-------------|
| 200 | Checked in |
| 400 | Not a valid shift day |

---

### POST `/volunteer/roster/:id/swap`

Request a shift swap with another volunteer.

**Request Body:**

```json
{
  "targetUserId": "uuid"
}
```

---

## 19. Kids Check-In Endpoints

**Prefix:** `/kids`
**Auth:** All routes require Bearer Token ✅

### GET `/kids/children`

List parent's registered children with active check-in status.

**Response item:**

```json
{
  "id": "uuid",
  "firstName": "Sarah",
  "lastName": "Doe",
  "dateOfBirth": "2020-05-15",
  "allergies": "Peanuts",
  "medicalNotes": null,
  "photoUrl": "https://...",
  "activeCheckIn": {
    "id": "uuid",
    "roomName": "Sunshine Room",
    "checkedInAt": "2026-03-07T09:00:00Z",
    "securityCode": "ABC123"
  }
}
```

---

### POST `/kids/children`

Register a new child.

**Request Body:**

```json
{
  "firstName": "Sarah",
  "lastName": "Doe",
  "dateOfBirth": "2020-05-15",
  "allergies": "Peanuts",
  "medicalNotes": "None"
}
```

| Field | Type | Required |
|-------|------|----------|
| `firstName` | string | Yes |
| `lastName` | string | Yes |
| `dateOfBirth` | string (date) | Yes |
| `allergies` | string | No |
| `medicalNotes` | string | No |

---

### POST `/kids/checkin`

Check in a child to a room. Returns a security code needed for checkout.

**Request Body:**

```json
{
  "childId": "uuid",
  "roomId": "uuid"
}
```

**Response:**

```json
{
  "data": {
    "checkinId": "uuid",
    "securityCode": "ABC123",
    "room": { "name": "Sunshine Room" },
    "child": { "firstName": "Sarah" },
    "checkedInAt": "2026-03-07T09:00:00Z"
  }
}
```

| Status | Description |
|--------|-------------|
| 201 | Child checked in |
| 409 | Already checked in |

---

### POST `/kids/checkout`

Check out a child (requires the security code from check-in).

**Request Body:**

```json
{
  "checkinId": "uuid",
  "securityCode": "ABC123"
}
```

| Status | Description |
|--------|-------------|
| 200 | Child checked out |
| 403 | Invalid security code |

---

### GET `/kids/rooms`

List rooms with capacity information.

**Response item:**

```json
{
  "id": "uuid",
  "name": "Sunshine Room",
  "ageGroup": "3-5",
  "capacity": 20,
  "currentCount": 8
}
```

---

## 20. Media Endpoints

**Prefix:** `/media`
**Auth:** All routes require Bearer Token ✅

### GET `/media/albums`

List photo albums (paginated).

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

**Response item:**

```json
{
  "id": "uuid",
  "title": "Easter Sunday 2026",
  "description": "Photos from Easter celebration",
  "coverImageUrl": "https://...",
  "photoCount": 45,
  "eventId": "uuid",
  "createdAt": "2026-04-20T10:00:00Z"
}
```

---

### POST `/media/albums`

Create a new photo album (admin only).

**Request Body:**

```json
{
  "title": "Easter Sunday 2026",
  "description": "Photos from our Easter celebration",
  "eventId": "uuid (optional)"
}
```

---

### GET `/media/albums/:id`

Get album detail with all photos.

---

### POST `/media/albums/:albumId/photos`

Upload a photo to an album.

- **Content-Type:** `multipart/form-data`

| Field | Type | Description |
|-------|------|-------------|
| `photo` | file (binary) | Image file |
| `caption` | string | Optional caption |

---

### GET `/media/podcasts`

List podcast episodes (paginated).

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

**Response item:**

```json
{
  "id": "uuid",
  "title": "Faith Forward Episode 12",
  "description": "...",
  "audioUrl": "https://...",
  "duration": 1800,
  "thumbnailUrl": "https://...",
  "publishedAt": "2026-03-01T10:00:00Z",
  "playCount": 120,
  "userProgress": {
    "position": 600,
    "completed": false
  }
}
```

---

### GET `/media/podcasts/:id`

Get podcast episode detail.

---

### PUT `/media/podcasts/:id/progress`

Update podcast playback progress.

**Request Body:**

```json
{
  "position": 600,
  "completed": false
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `position` | number | Yes | Position in seconds |
| `completed` | boolean | No | Whether playback is finished |

---

### GET `/media/songs`

List worship songs (paginated, filterable).

| Param | In | Type | Description |
|-------|----|------|-------------|
| `page` | query | integer | — |
| `limit` | query | integer | — |
| `key` | query | string | Musical key filter (e.g., `C`, `G`, `Am`) |
| `search` | query | string | Search by title/artist |

---

### GET `/media/songs/:id`

Get song detail with sections and lyrics.

**Response:**

```json
{
  "data": {
    "id": "uuid",
    "title": "Amazing Grace",
    "artist": "Worship Team",
    "key": "G",
    "tempo": 72,
    "tags": ["hymn", "classic"],
    "sections": [
      {
        "type": "VERSE",
        "sortOrder": 1,
        "lines": [
          { "lineNumber": 1, "lyrics": "Amazing grace how sweet the sound", "chords": "G    G7    C    G" },
          { "lineNumber": 2, "lyrics": "That saved a wretch like me", "chords": "G    Em    D" }
        ]
      },
      {
        "type": "CHORUS",
        "sortOrder": 2,
        "lines": [ ... ]
      }
    ]
  }
}
```

**Song section types:** `VERSE`, `CHORUS`, `BRIDGE`, `PRE_CHORUS`, `OUTRO`, `INTRO`

---

## 21. Search Endpoints

**Prefix:** `/search`
**Auth:** All routes require Bearer Token ✅

### GET `/search`

Global search across all content types.

| Param | In | Type | Required | Description |
|-------|----|------|----------|-------------|
| `q` | query | string | Yes | Search query |
| `type` | query | string | No | Filter: `all`, `sermons`, `events`, `groups`, `people`, `media`, `forum` |

**Response:**

```json
{
  "data": {
    "sermons": [ ... ],
    "events": [ ... ],
    "groups": [ ... ],
    "people": [ ... ],
    "media": [ ... ],
    "forum": [ ... ]
  }
}
```

| Status | Description |
|--------|-------------|
| 200 | Results grouped by type |
| 400 | Missing `q` parameter |

---

### GET `/search/trending`

Get trending items across content types.

**Response:**

```json
{
  "data": {
    "sermons": [ ... ],
    "events": [ ... ],
    "groups": [ ... ]
  }
}
```

---

## 22. Attendance Endpoints

**Prefix:** `/attendance`
**Auth:** All routes require Bearer Token ✅

### POST `/attendance`

Record attendance for a service.

**Request Body:**

```json
{
  "serviceDate": "2026-03-07",
  "serviceType": "SUNDAY",
  "checkinMethod": "MANUAL"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `serviceDate` | string (date) | Yes | ISO date format |
| `serviceType` | string | Yes | `SUNDAY`, `MIDWEEK`, `SPECIAL`, `YOUTH`, `PRAYER` |
| `checkinMethod` | string | No | `MANUAL`, `QR`, `GEOFENCE` (default: `MANUAL`) |

| Status | Description |
|--------|-------------|
| 201 | Attendance recorded |
| 409 | Already recorded for this service |

---

### GET `/attendance`

Get attendance history (paginated).

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

---

### GET `/attendance/streak`

Get attendance streak information.

**Response:**

```json
{
  "data": {
    "currentStreak": 5,
    "totalAttendances": 42
  }
}
```

---

### DELETE `/attendance/:id`

Delete an attendance record.

---

### GET `/attendance/stats` *(Admin Only)*

Get attendance statistics (requires `ADMIN` or `PASTOR` role).

**Response:** Attendance stats by service type, trends, etc.

| Status | Description |
|--------|-------------|
| 200 | Stats data |
| 403 | Forbidden (insufficient role) |

---

## 23. Milestones Endpoints

**Prefix:** `/milestones`
**Auth:** All routes require Bearer Token ✅

### GET `/milestones`

List user's spiritual milestones (paginated).

| Param | In | Type |
|-------|----|------|
| `page` | query | integer |
| `limit` | query | integer |

**Response item:**

```json
{
  "id": "uuid",
  "type": "BAPTISM",
  "title": "Water Baptism",
  "description": "Baptized on March 1, 2026",
  "achievedAt": "2026-03-01T10:00:00Z",
  "iconUrl": "https://..."
}
```

---

### GET `/milestones/summary`

Get a summary of all milestone types with earned/unearned status.

**Response:**

```json
{
  "data": {
    "milestones": [
      { "type": "SALVATION", "title": "Salvation", "earned": true, "achievedAt": "..." },
      { "type": "BAPTISM", "title": "Water Baptism", "earned": true, "achievedAt": "..." },
      { "type": "FIRST_SERVE", "title": "First Volunteer Service", "earned": false, "achievedAt": null },
      { "type": "SMALL_GROUP", "title": "Joined a Small Group", "earned": true, "achievedAt": "..." },
      { "type": "MINISTRY_LEADER", "title": "Ministry Leader", "earned": false, "achievedAt": null },
      { "type": "FIRST_GIVE", "title": "First Giving", "earned": true, "achievedAt": "..." },
      { "type": "ONE_YEAR", "title": "One Year Anniversary", "earned": false, "achievedAt": null },
      { "type": "INVITE_FRIEND", "title": "Invited a Friend", "earned": false, "achievedAt": null }
    ],
    "earnedCount": 4,
    "totalCount": 8
  }
}
```

---

### POST `/milestones` *(Admin Only)*

Create a milestone for a user (requires `ADMIN` or `PASTOR` role).

**Request Body:**

```json
{
  "userId": "uuid",
  "type": "BAPTISM",
  "title": "Water Baptism",
  "description": "Baptized during Sunday service"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `userId` | uuid | Yes | — |
| `type` | string | Yes | See milestone types below |
| `title` | string | Yes | — |
| `description` | string | No | — |

**Milestone types:** `SALVATION`, `BAPTISM`, `FIRST_SERVE`, `SMALL_GROUP`, `MINISTRY_LEADER`, `FIRST_GIVE`, `ONE_YEAR`, `INVITE_FRIEND`

| Status | Description |
|--------|-------------|
| 201 | Milestone created |
| 403 | Forbidden |

---

### DELETE `/milestones/:id` *(Admin Only)*

Delete a milestone (requires `ADMIN` or `PASTOR` role).

| Status | Description |
|--------|-------------|
| 200 | Deleted |
| 403 | Forbidden |

---

## 24. Saved Items Endpoints

**Prefix:** `/saved-items`
**Auth:** All routes require Bearer Token ✅

### GET `/saved-items`

List saved/bookmarked items (paginated, filterable by type).

| Param | In | Type | Description |
|-------|----|------|-------------|
| `page` | query | integer | — |
| `limit` | query | integer | — |
| `entityType` | query | string | Filter: `SERMON`, `EVENT`, `DEVOTIONAL`, `READING_PLAN` |

---

### GET `/saved-items/check`

Check if a specific item is saved.

| Param | In | Type | Required |
|-------|----|------|----------|
| `entityType` | query | string | Yes |
| `entityId` | query | uuid | Yes |

**Response:**

```json
{
  "data": { "saved": true }
}
```

---

### POST `/saved-items`

Save/bookmark an item.

**Request Body:**

```json
{
  "entityType": "SERMON",
  "entityId": "uuid"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `entityType` | string | Yes | `SERMON`, `EVENT`, `DEVOTIONAL`, `READING_PLAN` |
| `entityId` | uuid | Yes | — |

| Status | Description |
|--------|-------------|
| 201 | Item saved |
| 409 | Already saved |

---

### DELETE `/saved-items/:id`

Remove a saved item by saved-item ID.

---

## 25. WebSocket Events (Real-Time)

### Connection

Connect using Socket.io with JWT authentication:

```dart
final socket = io('ws://localhost:8080', {
  'auth': {'token': accessToken},
  'transports': ['websocket'],
});
```

### Auto-Joined Rooms on Connect

| Room | Description |
|------|-------------|
| `user:{userId}` | Personal room for direct notifications |
| `church:{churchId}` | Church-wide broadcasts |
| `conversation:{id}` | All user's conversation rooms (auto-joined) |

### Presence Events

| Event | Direction | Payload |
|-------|-----------|---------|
| `presence:online` | Server → Client | `{ userId: string }` |
| `presence:offline` | Server → Client | `{ userId: string }` |

### Chat Events

| Event | Direction | Payload | Description |
|-------|-----------|---------|-------------|
| `chat:message` | Client → Server | `{ conversationId, content, type?, mediaUrl?, replyToId? }` | Send a message |
| `chat:message` | Server → Client | `{ message, conversationId }` | New message received |
| `chat:typing` | Client → Server | `{ conversationId, isTyping: boolean }` | Typing indicator |
| `chat:typing` | Server → Client | `{ userId, conversationId, isTyping }` | Someone is typing |
| `chat:read` | Client → Server | `{ conversationId }` | Mark conversation read |
| `chat:read` | Server → Client | `{ userId, conversationId, readAt }` | Read receipt |
| `chat:join` | Client → Server | `{ conversationId }` | Join a conversation room |
| `chat:error` | Server → Client | `{ message: string }` | Chat error |

### Live Service Events

| Event | Direction | Payload | Description |
|-------|-----------|---------|-------------|
| `live:join` | Client → Server | `{ liveServiceId }` | Join live service room |
| `live:leave` | Client → Server | `{ liveServiceId }` | Leave live service room |
| `live:message` | Client → Server | `{ liveServiceId, content, type? }` | Send live chat message |
| `live:message` | Server → Client | `{ id, user, content, type, createdAt }` | New live chat message |
| `live:reaction` | Client → Server | `{ liveServiceId, emoji }` | Send an emoji reaction |
| `live:reaction` | Server → Client | `{ userId, emoji }` | Reaction received |
| `live:viewers` | Server → Client | `{ liveServiceId, viewerCount }` | Viewer count update |
| `live:error` | Server → Client | `{ message: string }` | Live service error |

### Notification Events

| Event | Direction | Payload | Description |
|-------|-----------|---------|-------------|
| `notification:new` | Server → Client | Full notification object | New notification pushed to user |
| `notification:read` | Client → Server | `{ notificationId }` | Mark notification as read |
| `notification:read` | Server → Client | `{ notificationId, readAt }` | Read confirmation |

---

## 26. Enums & Constants

### User Roles

```
MEMBER | LEADER | PASTOR | ADMIN | SUPER_ADMIN
```

### Bible Testaments

```
OT | NT
```

### Event Registration Status

```
REGISTERED | WAITLISTED | CANCELLED
```

### Payment Methods

```
CARD | BANK | MOBILE | WALLET
```

### Payment Providers

```
PAYSTACK | STRIPE | MANUAL
```

### Donation Status

```
PENDING | SUCCESS | FAILED | REFUNDED
```

### Pledge Status

```
ACTIVE | COMPLETED | CANCELLED
```

### Giving Frequency

```
ONE_TIME | WEEKLY | BIWEEKLY | MONTHLY | QUARTERLY | ANNUALLY
```

### Recurring Status

```
ACTIVE | PAUSED | CANCELLED
```

### Group Categories

```
BIBLE_STUDY | YOUTH | WOMEN | MEN | COUPLES | PRAYER | SERVICE | OTHER
```

### Group Roles

```
MEMBER | LEADER
```

### Testimony Status

```
PENDING | APPROVED | REJECTED
```

### Reaction Types

```
LIKE | PRAY
```

### Prayer Request Status

```
ACTIVE | ANSWERED | CLOSED
```

### Conversation Type

```
DIRECT | GROUP
```

### Message Type

```
TEXT | IMAGE | AUDIO | VIDEO | SYSTEM
```

### Conversation Role

```
MEMBER | ADMIN
```

### Notification Types

```
SERMON | EVENT | CHAT | GIVING | PRAYER | ANNOUNCEMENT | GROUP | FORUM | VOLUNTEER | KIDS | DEVOTIONAL | PERSONAL | SECURITY | SYSTEM
```

### Live Service Status

```
SCHEDULED | LIVE | ENDED
```

### Live Chat Type

```
MESSAGE | PRAYER | REACTION
```

### Volunteer Signup Status

```
PENDING | APPROVED | REJECTED
```

### Shift Status

```
SCHEDULED | CHECKED_IN | COMPLETED | SWAPPED
```

### Check-In Status

```
CHECKED_IN | CHECKED_OUT
```

### Song Section Types

```
VERSE | CHORUS | BRIDGE | PRE_CHORUS | OUTRO | INTRO
```

### Service Types (Attendance)

```
SUNDAY | MIDWEEK | SPECIAL | YOUTH | PRAYER
```

### Check-In Methods

```
MANUAL | QR | GEOFENCE
```

### Milestone Types

```
SALVATION | BAPTISM | FIRST_SERVE | SMALL_GROUP | MINISTRY_LEADER | FIRST_GIVE | ONE_YEAR | INVITE_FRIEND
```

### Saved Entity Types

```
SERMON | EVENT | DEVOTIONAL | VERSE | THREAD | SONG
```

---

## 27. Error Codes Reference

| HTTP Status | Meaning | When |
|-------------|---------|------|
| 200 | OK | Successful request |
| 201 | Created | Resource created |
| 400 | Bad Request | Validation failed, invalid input |
| 401 | Unauthorized | Missing or invalid JWT token |
| 403 | Forbidden | Insufficient role/permissions |
| 404 | Not Found | Resource does not exist |
| 409 | Conflict | Duplicate (already registered, saved, etc.) |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |

### Common Error Response Shapes

**Validation Error (400):**

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Invalid email address"],
    "password": ["Must be at least 8 characters"]
  }
}
```

**Unauthorized (401):**

```json
{
  "success": false,
  "message": "Missing or invalid authorization header"
}
```

**Forbidden (403):**

```json
{
  "success": false,
  "message": "Forbidden: insufficient role"
}
```

**Rate Limited (429):**

```json
{
  "success": false,
  "message": "Rate limit exceeded. Try again in 30 seconds."
}
```
