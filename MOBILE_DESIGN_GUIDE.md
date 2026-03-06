# 📱 Church App — Mobile Frontend Design Guide

> **Framework:** Flutter (primary) · React Native / Expo (compatible)
> **Last Updated:** February 23, 2026
> **Design Philosophy:** Peaceful · Modern · Fast · Spiritually Uplifting
> **Rule:** Every screen must breathe. White space is part of worship.

---

## Table of Contents

1. [Design System Setup](#1-design-system-setup)
2. [Typography System](#2-typography-system)
3. [Spacing & Layout Grid](#3-spacing--layout-grid)
4. [Component Library](#4-component-library)
5. [Navigation Structure](#5-navigation-structure)
6. [Screen — Onboarding & Auth](#6-screen--onboarding--auth)
7. [Screen — Home](#7-screen--home)
8. [Screen — Sermons](#8-screen--sermons)
9. [Screen — Live Service](#9-screen--live-service)
10. [Screen — Events](#10-screen--events)
11. [Screen — Giving](#11-screen--giving)
12. [Screen — Profile](#12-screen--profile)
13. [Screen — Prayer Request (Floating)](#13-screen--prayer-request-floating)
14. [Micro-Animations & Motion](#14-micro-animations--motion)
15. [Empty States](#15-empty-states)
16. [Loading States](#16-loading-states)
17. [Dark Mode](#17-dark-mode)
18. [Accessibility](#18-accessibility)
19. [Implementation Checklist](#19-implementation-checklist)

---

## 1. Design System Setup

> **Goal:** Establish the full token system before writing a single widget.
> Complete this section 100% before moving to any screen.

---

### 1.1 Color Tokens

Define all colors as named constants. Never hardcode hex values in widgets.

#### Primary Palette

| Token Name | Hex | Usage |
|---|---|---|
| `colorPrimary` | `#1E3A8A` | App bar, CTAs, active nav tab, headers |
| `colorPrimaryLight` | `#2D4EAF` | Hover/pressed state of primary |
| `colorPrimaryDark` | `#152B6B` | Deep tones, dark mode primary |
| `colorGold` | `#FBBF24` | Accents, badges, giving icon, premium highlights |
| `colorGoldLight` | `#FCD34D` | Gold hover state |

#### Secondary Palette

| Token Name | Hex | Usage |
|---|---|---|
| `colorSkyLight` | `#E0F2FE` | Card backgrounds, tinted surfaces |
| `colorWarmWhite` | `#FAFAFA` | Main background (light mode) |
| `colorSurface` | `#FFFFFF` | Cards, modals, sheets |

#### Text Colors

| Token Name | Hex | Usage |
|---|---|---|
| `colorTextPrimary` | `#111827` | Headings, main body text |
| `colorTextSecondary` | `#6B7280` | Subtitles, captions, placeholders |
| `colorTextDisabled` | `#9CA3AF` | Disabled inputs, inactive labels |
| `colorTextInverse` | `#FFFFFF` | Text on dark/primary backgrounds |

#### Semantic Colors

| Token Name | Hex | Usage |
|---|---|---|
| `colorSuccess` | `#10B981` | Success states, giving confirmed |
| `colorError` | `#EF4444` | Errors, destructive actions |
| `colorWarning` | `#F59E0B` | Warnings, reminder badges |
| `colorInfo` | `#3B82F6` | Info banners, tooltips |

#### Dark Mode Overrides

| Token Name | Hex | Usage |
|---|---|---|
| `colorBgDark` | `#0B1220` | Dark mode background |
| `colorCardDark` | `#111827` | Dark mode card surface |
| `colorBorderDark` | `#1F2937` | Dark mode dividers/borders |

---

### 1.2 Gradient Definitions

```
// Hero Gradient (Home screen header)
LinearGradient:
  Start → #1E3A8A (Deep Royal Blue)
  End   → #1E40AF (Blue 700)
  Angle → 135°

// Gold Shimmer (Giving screen, donation card)
LinearGradient:
  Start → #FBBF24
  End   → #F59E0B
  Angle → 90°

// Verse Card Gradient (Today's verse overlay)
LinearGradient:
  Start → rgba(30, 58, 138, 0.85)
  End   → rgba(30, 58, 138, 0.40)
  Direction → Bottom to Top
```

---

### 1.3 Elevation & Shadow System

Define 4 shadow levels used across all cards and components.

| Level | Usage | CSS/Flutter Shadow |
|---|---|---|
| `shadow-xs` | Input focus rings | `0 1px 2px rgba(0,0,0,0.05)` |
| `shadow-sm` | Default cards | `0 2px 8px rgba(0,0,0,0.08)` |
| `shadow-md` | Elevated cards, nav bar | `0 4px 16px rgba(0,0,0,0.12)` |
| `shadow-lg` | Modals, bottom sheets | `0 8px 32px rgba(0,0,0,0.18)` |

---

### 1.4 Border Radius System

| Token | Value | Usage |
|---|---|---|
| `radius-xs` | `4px` | Chips, small tags |
| `radius-sm` | `8px` | Input fields, small buttons |
| `radius-md` | `12px` | Buttons, small cards |
| `radius-lg` | `16px` | Standard cards |
| `radius-xl` | `24px` | Feature cards, hero cards |
| `radius-full` | `999px` | Pills, avatars, FABs |

---

### ✅ Section 1 Checklist

- [ ] All color tokens defined in `app_colors.dart` (or `theme/colors.js`)
- [ ] All gradients defined and named
- [ ] Shadow helpers created
- [ ] Border radius constants defined
- [ ] Light theme assembled
- [ ] Dark theme assembled
- [ ] Theme switcher logic hooked to user preference

---

## 2. Typography System

> **Goal:** Set up the font scale once. Every text element must use a named style — no raw font sizes.

---

### 2.1 Font Families

```
Primary Font: Inter (Google Fonts)
  Fallback (iOS): SF Pro Display
  Fallback (Android): Roboto

Load weights: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)
```

---

### 2.2 Type Scale

| Style Name | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `displayLarge` | 32px | Bold 700 | 40px | Splash/hero headlines |
| `displayMedium` | 28px | Bold 700 | 36px | Screen titles |
| `headingLarge` | 24px | Bold 700 | 32px | Section headers |
| `headingMedium` | 20px | SemiBold 600 | 28px | Card titles |
| `headingSmall` | 18px | SemiBold 600 | 26px | Sub-section titles |
| `bodyLarge` | 16px | Regular 400 | 24px | Primary body copy |
| `bodyMedium` | 14px | Regular 400 | 22px | Secondary body, list items |
| `bodySmall` | 12px | Regular 400 | 18px | Captions, timestamps |
| `labelLarge` | 16px | SemiBold 600 | 24px | Buttons, tabs |
| `labelMedium` | 14px | SemiBold 600 | 20px | Chips, small buttons |
| `labelSmall` | 12px | Medium 500 | 16px | Badges, tags |

---

### 2.3 Letter Spacing

| Usage | Value |
|---|---|
| Display headings | `-0.5px` |
| Body text | `0px` |
| Button labels | `0.2px` |
| ALL CAPS labels | `1.0px` |

---

### 2.4 Accessibility — Large Text Mode

When the user enables large text mode, scale all font sizes by `1.2×`.

| Style | Normal | Large Mode |
|---|---|---|
| `bodyLarge` | 16px | 19px |
| `bodyMedium` | 14px | 17px |
| `headingLarge` | 24px | 29px |

> ⚠️ Test all screens with large font mode enabled before marking any screen as done.

---

### ✅ Section 2 Checklist

- [ ] Inter font loaded with all required weights
- [ ] All text styles defined in `app_text_styles.dart` (or `typography.js`)
- [ ] No raw `fontSize` values used anywhere in screens
- [ ] Large text mode scaling implemented
- [ ] Fonts tested on both iOS and Android

---

## 3. Spacing & Layout Grid

> **Rule:** All spacing must use multiples of 4px. No arbitrary spacing values.

---

### 3.1 Spacing Scale

| Token | Value | Usage |
|---|---|---|
| `space-1` | `4px` | Icon padding, micro gaps |
| `space-2` | `8px` | Tight element gaps |
| `space-3` | `12px` | Related element gaps |
| `space-4` | `16px` | Standard padding, card inner padding |
| `space-5` | `20px` | Section gaps |
| `space-6` | `24px` | Large section padding |
| `space-8` | `32px` | Screen-level top/bottom padding |
| `space-10` | `40px` | Hero sections |
| `space-12` | `48px` | Bottom nav clearance |

---

### 3.2 Screen Layout Rules

```
Screen horizontal padding:  16px (left + right)
Content max width:          100% (mobile-first, no max-width cap)
Bottom nav height:          64px
Status bar clearance:       Auto (SafeArea / EdgeInsets)
Bottom safe area:           Auto (SafeArea)
Card inner padding:         16px all sides
Card gap (vertical list):   12px
Section gap:                24px between sections
```

---

### 3.3 Grid System

```
Columns:         4
Gutter:          16px
Margin:          16px
```

> Use 2-column grid for sermon cards in landscape / tablet view.
> Use 1-column stack for all phone portrait views.

---

### ✅ Section 3 Checklist

- [ ] Spacing constants defined (no hardcoded values in widgets)
- [ ] Screen padding helper created (`screenPadding`)
- [ ] Bottom nav clearance added to all scrollable screens
- [ ] SafeArea wrapping applied to all screens

---

## 4. Component Library

> **Goal:** Build every reusable component in this section before building screens. Screens are assembled from components.

---

### 4.1 Button Components

#### Primary Button

```
Height:           52px
Width:            Full width (stretch) or Hug content
Background:       colorPrimary (#1E3A8A)
Text style:       labelLarge, colorTextInverse
Border radius:    radius-md (12px)
Padding:          16px horizontal
Press animation:  scale(0.96) over 100ms
Shadow:           shadow-sm
Disabled:         opacity 0.4
```

#### Secondary Button (Outlined)

```
Height:           52px
Background:       Transparent
Border:           1.5px solid colorPrimary
Text color:       colorPrimary
Border radius:    radius-md (12px)
Press animation:  Background fills to colorSkyLight
```

#### Ghost Button (Text only)

```
Background:       Transparent
Text color:       colorPrimary
No border, no shadow
Underline optional on press
```

#### Icon Button (Circular)

```
Size:             40px × 40px
Background:       colorSkyLight or colorCardDark (dark mode)
Border radius:    radius-full (20px)
Icon size:        20px
```

#### FAB — Prayer Button

```
Size:             56px × 56px
Background:       colorGold (#FBBF24)
Icon:             Praying hands (white)
Border radius:    radius-full
Shadow:           shadow-lg
Position:         Fixed, bottom-right, above bottom nav (bottom: 76px, right: 16px)
Press animation:  scale(0.92) → bounce back
```

---

### 4.2 Card Components

#### Standard Card

```
Background:       colorSurface
Border radius:    radius-xl (24px)
Padding:          16px
Shadow:           shadow-sm
Tap animation:    Lift (translateY -2px + shadow-md) over 150ms
```

#### Feature Card (Horizontal)

```
Height:           120px
Background:       colorSurface
Border radius:    radius-xl
Layout:           Row — Left thumbnail (80px) + Right content
Thumbnail:        80px × 80px, radius-lg, object-fit cover
```

#### Verse Card

```
Height:           160px
Background:       LinearGradient (Hero Gradient)
Border radius:    radius-xl
Padding:          20px
Text color:       White
Animation:        Fade in over 600ms on screen load
Icon:             Open book (gold, top-right)
```

#### Event Card

```
Height:           200px
Background:       colorSurface
Border radius:    radius-xl
Image:            Full-width banner, height 120px, top radius 24px
Date badge:       Absolute top-right, colorPrimary bg, white text, radius-md
Content area:     Padding 12px
```

#### Giving Amount Chip

```
Min width:        100px
Height:           48px
Background:       colorSkyLight (unselected) → colorPrimary (selected)
Text color:       colorPrimary (unselected) → white (selected)
Border radius:    radius-full
Border:           1.5px solid colorPrimary (unselected) → none (selected)
Animation:        Background crossfade 200ms
```

---

### 4.3 Input Components

#### Text Input

```
Height:           52px
Background:       colorWarmWhite / colorCardDark (dark)
Border:           1px solid #E5E7EB (default)
Border focus:     1.5px solid colorPrimary
Border radius:    radius-sm (8px)
Padding:          16px horizontal, 14px vertical
Label:            bodyMedium, colorTextSecondary, floats on focus
Error state:      Border colorError, error message below in bodySmall
```

#### Search Bar

```
Height:           48px
Background:       #F3F4F6 / colorCardDark
Border radius:    radius-full
Padding left:     44px (icon space)
Icon:             Search, 20px, colorTextSecondary, absolute left 12px
Clear button:     Appears when input has value, right 12px
```

---

### 4.4 Navigation Components

#### Bottom Navigation Bar

```
Height:           64px (+ bottom safe area)
Background:       colorSurface
Shadow:           shadow-md (upward)
Border top:       1px solid rgba(0,0,0,0.06)
Tabs:             5 tabs — Home, Sermons, Events, Giving, Profile

Each Tab:
  Icon size:      24px
  Label:          labelSmall
  Active color:   colorPrimary (icon + label)
  Inactive color: colorTextSecondary
  Active indicator: Small dot (4px) below icon, colorGold
  Transition:     Icon scale 1.0 → 1.15 on activation (150ms)
```

#### App Bar / Top Bar

```
Height:           56px (+ status bar)
Background:       Transparent (overlays hero) OR colorSurface
Leading:          Church logo (left) — 36px height, auto width
Trailing:         Notification bell icon button + Avatar (right)
Title:            headingMedium, centered (used on inner screens)
```

---

### 4.5 Chips & Filters

#### Filter Chip

```
Height:           36px
Padding:          12px horizontal
Background:       #F3F4F6 (unselected) → colorPrimary (selected)
Text:             labelMedium, colorTextSecondary → white
Border radius:    radius-full
Gap between chips: 8px
Scroll:           Horizontal scroll row, no scrollbar visible
```

---

### 4.6 Avatar Component

```
Sizes:
  sm:  32px
  md:  48px
  lg:  72px
  xl:  100px

Shape:            Circle (radius-full)
Fallback:         Initials on colorPrimary background
Border:           2px solid white (when used on colored bg)
```

---

### 4.7 Badge Component

```
Min size:         20px × 20px
Padding:          4px 6px
Background:       colorError (notification count) | colorGold (premium)
Text:             labelSmall, white, bold
Border radius:    radius-full
Position:         Absolute top-right of parent icon
```

---

### 4.8 Divider

```
Height:           1px
Color:            #F3F4F6 (light) | colorBorderDark (dark)
Margin vertical:  12px (default) or as needed
```

---

### ✅ Section 4 Checklist

- [ ] All button variants built and documented
- [ ] All card variants built
- [ ] Input fields built with all states (default, focus, error, disabled)
- [ ] Search bar built
- [ ] Bottom nav bar built with animation
- [ ] App bar built (transparent + filled variant)
- [ ] Filter chips built with horizontal scroll
- [ ] Avatar component with fallback
- [ ] Badge component
- [ ] FAB (Prayer button) built
- [ ] All components tested in light + dark mode
- [ ] All components tested with large font mode

---

## 5. Navigation Structure

> **Goal:** Define the full route tree before building any screen. Every screen must know its place in the hierarchy.

---

### 5.1 Route Tree

```
App
├── /splash                         # Splash / loading
├── /onboarding                     # First-time welcome (3 slides)
├── /auth
│   ├── /login                      # Login
│   ├── /register                   # Sign up
│   ├── /church-code                # Enter church code
│   └── /forgot-password            # Reset password
│
└── /app (Main shell — Bottom Nav)
    ├── /home                       # Tab 1
    │   └── /live                   # → Live Service (pushed)
    ├── /sermons                    # Tab 2
    │   ├── /sermons/:id            # Sermon detail
    │   └── /series/:id             # Series view
    ├── /events                     # Tab 3
    │   └── /events/:id             # Event detail
    ├── /giving                     # Tab 4
    │   └── /giving/success         # Success screen
    └── /profile                    # Tab 5
        ├── /profile/giving-history
        ├── /profile/my-events
        ├── /profile/prayer-requests
        └── /profile/settings

Overlay routes (can appear on top of any tab):
    /prayer-request                 # Prayer request sheet (FAB)
    /notification-center            # Slide-in from right
```

---

### 5.2 Navigation Transitions

| Transition Type | Used For |
|---|---|
| **Slide + Fade** (right→left) | Pushing inner screens (detail pages) |
| **Slide Up** | Bottom sheets, prayer modal |
| **Fade** | Tab switches (bottom nav) |
| **Scale + Fade** | Modals, alerts |

---

### ✅ Section 5 Checklist

- [ ] Full route tree implemented in GoRouter / React Navigation
- [ ] Bottom nav shell built
- [ ] Tab state preserved on tab switch (no re-renders)
- [ ] Navigation transitions defined per route
- [ ] Deep link support configured for notifications
- [ ] Back navigation behavior defined for each screen

---

## 6. Screen — Onboarding & Auth

> Build this section before any other screen. Users cannot access the app without it.

---

### 6.1 Splash Screen

```
Background:    colorPrimary (#1E3A8A)
Content:       Church logo centered (white version)
               App name below logo in displayMedium, white
Animation:     Logo fades in (0 → 1.0 opacity, 800ms)
               Then scales slightly (1.0 → 1.05, 400ms)
Duration:      2 seconds total, then auto-navigate
Navigate to:   /onboarding (first-time) | /home (returning user)
```

---

### 6.2 Onboarding Slides (3 Screens)

```
Layout:
  Full-screen illustration (top 60%)
  White card (bottom 40%) with rounded top corners (32px)

Slide 1 — "Stay Connected"
  Illustration: Community/church building
  Title: "Stay Connected to Your Church"
  Body: "Watch sermons, join events, and grow in faith — anytime, anywhere."

Slide 2 — "Give With Purpose"
  Illustration: Hands offering / generosity
  Title: "Give Generously"
  Body: "Support your church with secure, easy giving in seconds."

Slide 3 — "Pray Together"
  Illustration: Praying hands / candle
  Title: "Never Pray Alone"
  Body: "Share prayer requests and stand in faith with your community."

Controls:
  Page dots:   Bottom of slides, colorGold (active) | #D1D5DB (inactive)
  Skip button: Top right, ghost style, labelMedium
  Next button: Primary button, "Next" | "Get Started" (last slide)
  Transition:  Horizontal slide between slides
```

---

### 6.3 Login Screen

```
Layout:         Single scroll column, 16px horizontal padding

Elements (top → bottom):
  1. Church logo               — centered, 60px height, 24px top margin
  2. "Welcome Back 👋"         — headingLarge, centered, 24px margin top
  3. Subtitle                  — "Sign in to your church account"
                                  bodyMedium, colorTextSecondary, centered
  4. Email input               — 24px top margin
  5. Password input            — 12px top margin, show/hide toggle
  6. "Forgot Password?"        — ghost button, right-aligned, 8px top margin
  7. Sign In button            — primary button, 24px top margin
  8. Divider with "OR"         — 24px top margin
  9. Google sign-in button     — outlined, Google icon left, 12px top margin
  10. Apple sign-in button     — outlined, Apple icon left, 12px top margin
  11. "Don't have an account?  Sign Up" — centered, 24px top margin

States:
  Loading:    Spinner inside Sign In button, button disabled
  Error:      Red banner below form — "Invalid email or password"
  Success:    Navigate to /church-code (first login) | /home
```

---

### 6.4 Church Code Screen

```
Purpose:    User enters the unique code to join a specific church.
            Shown once after first registration.

Layout:
  Illustration:  Church building, centered, 200px
  Title:         "Join Your Church"   — headingLarge, centered
  Body:          "Enter the 6-digit code your church provided."
                  bodyMedium, colorTextSecondary, centered
  Input:         Large centered code input (6 boxes, digit-only)
                  Each box: 52px × 56px, radius-sm, border
                  Auto-focus next box on digit entry
  Button:        "Join Church" — primary button, 24px top margin
  Link:          "Don't have a code? Browse churches" — ghost, centered

Validation:
  Error: "Invalid code. Please check with your church admin."
  Success animation: Checkmark bounce, then navigate to /home
```

---

### ✅ Section 6 Checklist

- [ ] Splash screen with logo animation
- [ ] 3 onboarding slides with page dots
- [ ] Login screen with all states
- [ ] Registration screen
- [ ] Church code input screen
- [ ] Forgot password flow (email entry → confirmation screen)
- [ ] Auth state persisted (user stays logged in on reopen)

---

## 7. Screen — Home

---

### 7.1 Screen Layout (Top → Bottom)

```
1. App Bar (transparent overlay)
2. Hero Header
3. Today's Verse Card
4. Section: Quick Actions
5. Section: Feature Cards
6. Section: Upcoming Events (horizontal scroll)
7. Section: Latest Sermon
```

---

### 7.2 App Bar (Home)

```
Background:         Transparent (overlaid on Hero gradient)
Left:               Church logo — white version, 36px height
Right (row):        Notification bell + Member avatar (36px)
Notification bell:  Has badge (red dot) if unread notifications exist
```

---

### 7.3 Hero Header

```
Height:             200px
Background:         LinearGradient (Hero Gradient, #1E3A8A → #1E40AF)
Padding:            24px horizontal, 40px top

Content:
  Line 1: "Good Morning, Moses 🙏"  → headingLarge, white
  Line 2: "Sunday, February 23"     → bodyMedium, rgba(255,255,255,0.7)
  Below (12px gap): Church name tag → colorGold background, white text,
                    labelSmall, radius-full pill, padding 4px 10px

Bottom shape:      Curved bottom edge (24px border-radius on bottom corners
                   or ClipRRect / custom painter)
```

---

### 7.4 Today's Verse Card

```
Margin:           16px horizontal, 16px top
Height:           160px
Background:       Verse Card gradient (see Section 1.3)
Border radius:    radius-xl (24px)
Animation:        Fade in from opacity 0 → 1, translateY +10px → 0
                  Duration: 600ms, ease-out, delay 200ms

Layout:
  Top-right:      Open-book icon, 24px, colorGold
  Bottom section:
    Scripture reference: labelMedium, colorGold (e.g. "Psalm 46:10")
    Verse text:         bodyLarge, white, italic
                        Max 2 lines, truncate with "..."
```

---

### 7.5 Feature Cards Grid

```
Margin top:       24px
Padding:          16px horizontal
Section label:    "Quick Access" — headingSmall, colorTextPrimary, 16px bottom

Cards (2×2 grid, gap 12px):
  ┌──────────────────┬──────────────────┐
  │  Watch Live      │  Latest Sermon   │
  │  (play icon)     │  (headphones)    │
  ├──────────────────┼──────────────────┤
  │  Next Event      │  Daily Devotional│
  │  (calendar icon) │  (book icon)     │
  └──────────────────┴──────────────────┘

Each Card:
  Height:           130px
  Background:       colorSurface
  Border radius:    radius-xl (24px)
  Shadow:           shadow-sm
  Layout:
    Icon (top-left):  32px, colorPrimary on colorSkyLight bg, radius-md, 8px padding
    Label (bottom):   labelMedium, colorTextPrimary
    Sub label:        bodySmall, colorTextSecondary (e.g. "Today 10:00 AM")

  "Watch Live" card variant:
    Has LIVE badge (top-right): Red background, "● LIVE", white, labelSmall
    Icon background: colorPrimary, icon white

Animation:
  All cards slide up from translateY +24px → 0
  Stagger: 100ms between each card
  Duration: 400ms, ease-out
```

---

### 7.6 Upcoming Events (Horizontal Scroll)

```
Margin top:       24px
Section header:
  Left:   "Upcoming Events" — headingSmall
  Right:  "See all" — labelMedium, colorPrimary, ghost button

Horizontal scroll row:
  Padding:          16px horizontal start/end
  Gap:              12px between cards

Event Card (horizontal item):
  Width:            220px
  Height:           200px
  Background:       colorSurface
  Border radius:    radius-xl
  Shadow:           shadow-sm

  Image:            Full width, 120px height, top radius
  Date badge:       Absolute, top-right, 8px from edges
                    colorPrimary bg, white text, bodySmall, radius-sm, padding 4px 8px
  Title:            bodyMedium, colorTextPrimary, 12px top, 12px horizontal
  Location:         bodySmall, colorTextSecondary, pin icon, 4px top
```

---

### 7.7 Latest Sermon Card

```
Margin:           16px horizontal, 16px top
Section header:
  Left:   "Latest Message" — headingSmall
  Right:  "All Sermons" — labelMedium, colorPrimary

Card:
  Height:           100px
  Background:       colorSurface
  Border radius:    radius-xl
  Shadow:           shadow-sm
  Layout:           Row — Thumbnail (left) + Content (right) + Play button (far right)

  Thumbnail:        80px × 80px, radius-lg, left margin 12px
  Content:
    Title:          bodyLarge, colorTextPrimary, SemiBold
    Speaker:        bodySmall, colorTextSecondary
    Duration:       bodySmall, colorTextSecondary, clock icon
  Play button:      40px circle, colorPrimary bg, white play icon
```

---

### ✅ Section 7 Checklist

- [ ] App bar (transparent, with logo + icons)
- [ ] Hero header with gradient and greeting
- [ ] Verse card with fade animation
- [ ] 2×2 feature card grid with stagger animation
- [ ] LIVE badge on Watch Live card (shown when service is live)
- [ ] Horizontal events scroll
- [ ] Latest sermon row card
- [ ] All data connected to API providers
- [ ] Pull-to-refresh working
- [ ] Skeleton loaders for all sections

---

## 8. Screen — Sermons

---

### 8.1 Screen Layout (Top → Bottom)

```
1. App Bar (filled, "Messages" title)
2. Search Bar
3. Filter Chips (horizontal scroll)
4. Sermon List (vertical scroll)
```

---

### 8.2 App Bar

```
Background:     colorSurface
Title:          "Messages" — headingMedium
Shadow:         shadow-xs (subtle separator)
Trailing:       Filter icon button (toggles filter panel)
```

---

### 8.3 Search Bar

```
Margin:         16px horizontal, 16px top
Style:          See Component 4.3 Search Bar
Placeholder:    "Search sermons, series, speakers..."
Behavior:       Debounce 300ms, live filter results
                Results show below as filtered list
```

---

### 8.4 Filter Chips

```
Margin top:     12px
Padding left:   16px
Chips (in order): All · Sunday Service · Series · Guest Speaker · Recent
Default active: "All"
Behavior:       Single select, re-fetches / filters list on change
```

---

### 8.5 Sermon Card (List Item)

```
Height:         100px
Background:     colorSurface
Border radius:  radius-xl
Shadow:         shadow-sm
Margin:         0 16px, 12px bottom

Layout (horizontal):
  Left:   Thumbnail — 80px × 80px, radius-lg, object-fit cover
  Center: Content column
            Series tag:   labelSmall, colorGold, colorGoldLight bg, radius-xs, padding 2px 6px
            Title:        bodyLarge, colorTextPrimary, SemiBold, max 2 lines
            Speaker:      bodySmall, colorTextSecondary, person icon
            Duration:     bodySmall, colorTextSecondary, clock icon
  Right:  Play button — 40px circle, colorPrimary

Bookmark icon:
  Position: Absolute top-right of card
  State:    Outline (not saved) | Filled colorGold (saved)
  Tap:      Toggle with scale animation
```

---

### 8.6 Sermon Detail Screen (Expanded/Pushed)

```
Navigation:     Pushed from sermon card (slide + fade)

Layout (Top → Bottom):
  1. Full-width thumbnail (250px, no border radius — edge to edge)
     Back arrow overlay (top-left, white circle button)
  2. White card starts with radius-xl top corners, overlapping image (–24px)
  3. Inside card:
       Series tag
       Title:        displayMedium, colorTextPrimary
       Speaker + Date: bodyMedium, colorTextSecondary
       Action row:   Play | Download | Share | Bookmark (icon buttons, row)
       Divider
       "Sermon Notes" section
       Notes content: bodyMedium, colorTextPrimary, formatted text
       Divider
       "Related Sermons" horizontal scroll

  Audio/Video player bar (sticky bottom):
    Height:       80px
    Background:   colorSurface
    Shadow:       shadow-lg
    Controls:     ← 15s | Play/Pause | → 15s
    Scrubber:     colorPrimary fill, colorGold thumb
    Time display: bodySmall, colorTextSecondary
```

---

### ✅ Section 8 Checklist

- [ ] Search bar with debounce filtering
- [ ] Filter chips with single-select state
- [ ] Sermon list with all card elements
- [ ] Bookmark toggle with animation
- [ ] Sermon detail screen (full layout)
- [ ] Audio player (sticky bottom bar)
- [ ] Video player (full-width, controls overlay)
- [ ] Download for offline (progress indicator)
- [ ] Empty state when search returns no results

---

## 9. Screen — Live Service

---

### 9.1 Screen Layout

```
1. Status bar (hidden / full-screen)
2. Video Player (top 45% of screen)
3. Live Info Bar
4. Tabs: Chat | Prayer | Bible
5. Tab content area (scrollable)
6. Floating reaction buttons (right edge)
7. Message input (sticky bottom, appears in Chat tab)
```

---

### 9.2 Video Player

```
Background:       Black
Aspect ratio:     16:9 (scales to fill width)
Controls:
  Tap to show/hide overlay
  Overlay:
    Top-left:     "● LIVE" red badge
    Top-right:    Fullscreen icon, chromecast icon
    Bottom:       Play/pause, volume, scrubber (for replay)

Live badge:
  Background:     colorError (#EF4444)
  Text:           "● LIVE" — labelSmall, white, bold
  Animation:      Dot pulses every 2s (scale 1.0 → 1.3 → 1.0)
```

---

### 9.3 Live Info Bar

```
Height:           56px
Background:       colorSurface
Padding:          16px horizontal
Layout (row):
  Left:   Service title — bodyLarge, SemiBold
  Right:  Viewer count — bodySmall, colorTextSecondary, eye icon
          (e.g. "👁 1,243 watching")
```

---

### 9.4 Tabs (Chat / Prayer / Bible)

```
Tab bar:
  Background:     colorSurface
  Active tab:     colorPrimary text + 2px colorPrimary bottom border
  Inactive tab:   colorTextSecondary
  Tab indicator:  Animated slide (follows active tab)

Chat Tab:
  Scrollable message list (bottom-pinned, newest at bottom)
  Message bubble:
    Own messages:   Right-aligned, colorPrimary background, white text
    Others:         Left-aligned, colorSurface, colorTextPrimary
    Avatar:         24px circle, left of other-message bubble
    Name:           labelSmall, colorGold (above other's message)
    Timestamp:      bodySmall, colorTextDisabled, right-aligned below bubble
  Message input:
    Background:   #F3F4F6 / colorCardDark
    Border radius: radius-full
    Send button:  colorPrimary circle, right side

Prayer Tab:
  List of live prayer requests
  Submit prayer request input (bottom of tab)

Bible Tab:
  Inline Bible reader widget
  Current preaching passage pre-loaded
  Verse tap → highlight
```

---

### 9.5 Floating Reactions

```
Position:         Fixed, right edge, vertical center of screen
Buttons (top → bottom):
  🙏  Pray
  ❤️  Love
  🔥  Fire

Each button:
  Size:           44px circle
  Background:     rgba(0,0,0,0.4) backdrop blur
  Emoji:          24px

Tap animation:
  Emoji floats upward from tap position
  Particle: emoji + slight rotation, opacity 1 → 0
  Travel:   translateY -120px over 1200ms, ease-out
  Multiple simultaneous particles allowed
  Show count briefly (+1) next to button after tap
```

---

### ✅ Section 9 Checklist

- [ ] Video player (YouTube/Vimeo embed or HLS stream)
- [ ] LIVE pulsing badge
- [ ] Live info bar (viewer count updates real-time)
- [ ] Chat tab with real-time messages (WebSocket / Firebase)
- [ ] Message input with send button
- [ ] Prayer tab
- [ ] Bible tab
- [ ] Floating reaction buttons with float animation
- [ ] Fullscreen video support

---

## 10. Screen — Events

---

### 10.1 Screen Layout

```
1. App Bar ("Events" title + calendar toggle button)
2. Month Header (if calendar view)
3. Calendar or List view
4. Event Cards
```

---

### 10.2 App Bar

```
Title:      "Events"
Trailing:   Toggle button — "List" icon | "Calendar" icon
            Switches between list and calendar view
```

---

### 10.3 Calendar View

```
Month navigation:
  Row: ← Prev | "February 2026" (headingSmall) | Next →
  Tap: Animate slide (next month slides in from right)

Calendar grid:
  7 columns (Sun → Sat)
  Day headers: labelSmall, colorTextSecondary, uppercase
  Day cells:
    Normal:       bodyMedium, colorTextPrimary, 36px circle
    Has event:    colorGold dot (4px) below date number
    Today:        colorPrimary circle background, white text
    Selected:     colorPrimary ring (outline), colorSkyLight bg
    Tap:          Scale 0.95 animation, shows events for that day below

Selected day event list:
  Appears below calendar as a bottom sheet / inline section
  Animated slide down
```

---

### 10.4 Event Card (Full Width)

```
Background:     colorSurface
Border radius:  radius-xl (24px)
Shadow:         shadow-sm
Margin:         0 16px, 12px bottom

Layout (vertical):
  Top: Banner image — full width, 160px, top radius
  Bottom content: 16px padding
    Date badge (row):  Calendar icon (colorGold) + "Sun, Feb 23 · 10:00 AM"
                       bodySmall, colorTextSecondary
    Title:             headingSmall, colorTextPrimary
    Location:          bodySmall, colorTextSecondary, pin icon
    Attendees:         Row of stacked avatars (3 max) + "+24 attending"
    Register button:   Primary button, full width, 12px top

Register button states:
  Default:    "Register Now"
  Loading:    Spinner (in-button)
  Registered: "✓ Registered" — colorSuccess background, white text
              Checkmark draw animation (stroke draws from 0% → 100%, 400ms)
```

---

### 10.5 Event Detail Screen

```
Navigation:     Pushed from event card tap

Layout:
  1. Hero image (full-width, 240px, no border radius)
     Back button overlay (top-left, white circle)
     Share icon (top-right, white circle)
  2. White card (overlaps image –24px, radius-xl top)
     Category tag: labelSmall pill (colorGold)
     Title: displayMedium
     Date + Time row: calendar icon, bodyMedium
     Location row: pin icon + map link (colorPrimary, underline)
     Divider
     "About this Event": headingSmall
     Description: bodyMedium, colorTextSecondary
     Divider
     "Speakers / Organizers" (if applicable)
     Divider
     Registration count + Register button (sticky footer)

Sticky footer:
  Height:   80px
  Shadow:   shadow-lg
  Left:     Attendee count text
  Right:    Register button (hug width)
```

---

### ✅ Section 10 Checklist

- [ ] List view and calendar view toggle
- [ ] Calendar grid with event dots
- [ ] Month navigation with animation
- [ ] Event card (list view)
- [ ] Register button with checkmark animation
- [ ] Event detail screen (full layout)
- [ ] Add to device calendar functionality
- [ ] Sticky registration footer on detail screen
- [ ] Empty state for days/months with no events

---

## 11. Screen — Giving

---

### 11.1 Screen Layout

```
1. App Bar ("Give" title)
2. Giving Category selector
3. Amount selector (preset chips)
4. Custom amount input
5. Giving frequency toggle
6. Payment method selector
7. Give button (sticky footer)
```

---

### 11.2 App Bar

```
Title:    "Give"
Trailing: History icon → navigates to /profile/giving-history
```

---

### 11.3 Category Selector

```
Margin:         16px all
Label:          "Select Category" — bodyMedium, colorTextSecondary
Options row:    Horizontal scroll chips
  Options:      Tithe · Offering · Building Fund · Missions · Special Seed
  Style:        Filter chip (see Component 4.5)
  Default:      "Tithe" selected
```

---

### 11.4 Amount Selector

```
Label:          "Select Amount" — bodyMedium, colorTextSecondary, 24px top
Chips row:      2-column grid or 3-per-row wrap
  ₦1,000
  ₦5,000
  ₦10,000
  ₦50,000
  Custom...

Chip style:     Giving Amount Chip (see Component 4.2)
Selection:      Single select
"Custom...":    Tapping opens custom input (see 11.5)

Selected chip animation:
  Background transitions: colorSkyLight → colorPrimary (200ms)
  Scale: 1.0 → 1.05 → 1.0 (bounce, 300ms)
```

---

### 11.5 Custom Amount Input

```
Visible only when "Custom..." chip is selected
Animated slide down (height 0 → auto, 300ms ease-out)

Currency symbol:  "₦" — headingLarge, colorTextSecondary, left of input
Input:            headingLarge, colorTextPrimary, centered
                  Numeric keyboard
                  No border box — underline style only
                  Underline: 2px colorPrimary

Formatted display: Auto-format with commas as user types
                   e.g. "25000" → "₦25,000"
```

---

### 11.6 Giving Frequency

```
Label:          "Frequency"
Toggle row:     One-time | Weekly | Monthly
Style:          Segmented control
  Height:       44px
  Background:   #F3F4F6 / colorCardDark
  Active pill:  White (light) / colorCardDark (dark), shadow-xs
                Slides smoothly to active segment (200ms ease)
  Text:         labelMedium
```

---

### 11.7 Payment Method Selector

```
Label:          "Pay with"
Options (vertical list, radio-style):

  Card option:
    Icon:       Credit card icon (colorPrimary)
    Label:      "Debit / Credit Card"
    Sub:        "Visa, Mastercard, Verve"
    Right:      Radio indicator

  Transfer option:
    Icon:       Bank transfer icon
    Label:      "Bank Transfer"
    Sub:        "Direct bank payment"

  Wallet option:
    Icon:       Wallet icon (colorGold)
    Label:      "Wallet"
    Sub:        "Balance: ₦12,500"

Each option:
  Height:       72px
  Background:   colorSurface
  Border:       1px solid #E5E7EB (default) | 1.5px solid colorPrimary (selected)
  Border radius: radius-lg
  Margin bottom: 8px
  Selected:     colorSkyLight tint + colorPrimary border
```

---

### 11.8 Give Button (Sticky Footer)

```
Container:
  Height:       80px
  Background:   colorSurface
  Shadow:       shadow-lg

Button:
  Label:        "Give ₦10,000" (dynamically shows selected amount)
  Style:        Primary button, full width (minus 32px padding)
  Loading state: Spinner + "Processing..."
  Disabled:     If no amount selected or amount is 0
```

---

### 11.9 Giving Success Screen

```
Trigger:        After successful payment confirmation

Full-screen overlay:
  Background:   colorWarmWhite
  Animation sequence:
    1. Confetti burst from top (200 particles, colorPrimary + colorGold + white)
       Duration: 3 seconds, gravity-fall
    2. Checkmark circle (center): 
       Circle draws from 0 → 360°, colorSuccess (600ms)
       Checkmark strokes in (200ms after circle)
       Both spring-bounce scale: 0.5 → 1.1 → 1.0

  Content (below animation):
    Title:      "Thank You for Your Generosity 🙏"
                headingLarge, colorTextPrimary, centered
    Amount:     "₦10,000" — displayLarge, colorPrimary, centered
    Category:   "Tithe" — bodyMedium, colorTextSecondary, centered
    Reference:  "Ref: CH-20260223-4821" — bodySmall, colorTextDisabled, centered

  Buttons:
    Primary:    "Back to Home"
    Ghost:      "View Receipt" (downloads/opens PDF)
```

---

### ✅ Section 11 Checklist

- [ ] Category selector chips
- [ ] Preset amount chips (grid layout)
- [ ] Custom amount input with live formatting
- [ ] Frequency segmented control with slide animation
- [ ] Payment method radio list
- [ ] Dynamic "Give ₦X" button label
- [ ] Payment processing (Paystack / Flutterwave / Stripe)
- [ ] Success screen with confetti + checkmark animation
- [ ] Giving history screen (under Profile)
- [ ] Receipt download/view

---

## 12. Screen — Profile

---

### 12.1 Screen Layout

```
1. App Bar ("Profile" title + Settings gear icon)
2. Profile Header (avatar, name, dept)
3. Stats Row
4. Menu Sections
5. Logout button
```

---

### 12.2 Profile Header

```
Margin top:     24px
Alignment:      Center

Avatar:
  Size:         xl (100px)
  Border:       3px solid colorGold
  Edit overlay: Camera icon bottom-right, 28px, colorPrimary bg

Name:           headingLarge, colorTextPrimary, centered, 12px top
Department:     bodyMedium, colorTextSecondary, centered, pill badge colorSkyLight
Church:         bodySmall, colorGold, centered, 4px top
```

---

### 12.3 Stats Row

```
Margin:         16px horizontal, 20px top
Background:     colorSurface
Border radius:  radius-xl
Shadow:         shadow-sm
Height:         80px
Layout:         Row, 3 equal columns, dividers between

Each stat:
  Value:        headingMedium, colorPrimary, bold
  Label:        bodySmall, colorTextSecondary
  Examples:
    "24"         "Sermons"
    "₦48,000"   "Given (2026)"
    "8"          "Events"
```

---

### 12.4 Menu Sections

```
Section 1: My Activity
  - My Giving History     → /profile/giving-history
  - My Events             → /profile/my-events
  - Prayer Requests       → /profile/prayer-requests
  - Saved Sermons         → /profile/saved-sermons

Section 2: Account
  - Edit Profile          → /profile/edit
  - Notification Settings → /profile/notifications
  - App Theme             → toggles light/dark mode (inline toggle)
  - Language              → language picker (future)

Section 3: Support
  - Help & FAQ
  - Contact Church
  - Privacy Policy
  - Terms of Service

Menu Item Style:
  Height:       56px
  Layout:       Icon (left, 20px) | Label (bodyMedium) | Chevron (right, 16px)
  Background:   colorSurface
  Border bottom: 1px solid #F3F4F6 (except last item in section)
  Press:        Background tints to colorSkyLight

Section label:
  labelSmall, colorTextSecondary, ALL CAPS, 8px padding top, 16px left
  Space between sections: 24px
```

---

### 12.5 Logout Button

```
Margin:         16px horizontal, 24px top
Style:          Outlined button, colorError border + text
Label:          "Log Out"
Tap:            Confirmation dialog (bottom sheet):
                  "Are you sure you want to log out?"
                  "Log Out" (colorError) | "Cancel"
```

---

### ✅ Section 12 Checklist

- [ ] Profile header with avatar upload
- [ ] Stats row with real data
- [ ] Menu sections with correct navigation
- [ ] Dark/light mode toggle (Profile → App Theme)
- [ ] Logout with confirmation dialog
- [ ] Giving history list screen
- [ ] My events list screen
- [ ] Prayer requests list screen

---

## 13. Screen — Prayer Request (Floating)

---

### 13.1 FAB Behavior

```
Position:     Fixed over all tabs (above bottom nav)
Bottom:       80px (sits above nav bar)
Right:        16px
Size:         56px circle
Background:   colorGold
Icon:         Praying hands (white, 24px)
Shadow:       shadow-lg

Tap:          Opens Prayer Request bottom sheet
              Sheet animates up from bottom (slide-up, 350ms ease-out)
              Background dims to rgba(0,0,0,0.5)
```

---

### 13.2 Prayer Request Bottom Sheet

```
Background:     colorSurface
Top corners:    radius-xl (24px)
Handle:         4px × 32px rounded pill, #D1D5DB, centered top, 8px top margin
Max height:     75% of screen height

Content (top → bottom):
  Title:        "Share a Prayer Request" — headingMedium, 16px top
  Subtitle:     "Let your church family stand with you in prayer."
                bodyMedium, colorTextSecondary, 4px top

  Title input:  "Prayer title (e.g. Healing, Provision)" — standard input
                16px top margin
  Details input:Multiline textarea, 120px height
                "Share details (optional)"
  Visibility toggle:
    Row:        "🔓 Share with church" | "🔒 Private (just for me)"
    Style:      Toggle pill switch

  Submit button: "Send Prayer Request" — primary, full width
                 16px top, 24px bottom (above keyboard)

Keyboard behavior:
  Sheet shifts up when keyboard opens (avoid hiding input)
```

---

### 13.3 Success Confirmation

```
After submit:
  Sheet content replaces with:
    Animated praying hands Lottie (80px, centered)
    "Prayer Sent 🙏" — headingMedium, centered, 12px top
    "We're praying with you." — bodyMedium, colorTextSecondary
  Auto-dismiss after 2 seconds
```

---

### ✅ Section 13 Checklist

- [ ] FAB visible on all main tabs (Home, Sermons, Events, Giving, Profile)
- [ ] FAB hidden on inner/pushed screens
- [ ] Bottom sheet with all fields
- [ ] Visibility toggle (public vs private)
- [ ] Keyboard-aware sheet (adjusts on keyboard open)
- [ ] Success animation and auto-dismiss

---

## 14. Micro-Animations & Motion

> **Rule:** Every interaction should have a response. If the user touches it, it reacts.

---

### 14.1 Button & Tap Animations

| Element | Animation | Duration |
|---|---|---|
| Any button press | `scale(0.96)` | 100ms ease-in, restore 100ms ease-out |
| FAB press | `scale(0.90)` → spring back | 150ms |
| Card tap | `translateY(-2px)` + shadow increase | 150ms ease-out |
| Nav tab switch | Icon `scale(1.0 → 1.15)` | 150ms ease |
| Chip select | Background color crossfade | 200ms ease |
| Toggle switch | Thumb slides + color fills | 200ms ease |

---

### 14.2 Screen Entry Animations

| Screen | Animation |
|---|---|
| Home screen | Cards slide up from +24px, stagger 100ms per card |
| Today's verse | Fade in + translateY +10px → 0, 600ms, delay 200ms |
| Sermon list | Items fade in from bottom, stagger 50ms per item |
| Events list | Cards fade in, stagger 80ms |
| Giving screen | Sections slide in from right, stagger 100ms |

---

### 14.3 Transition Animations

| Transition | Type | Duration |
|---|---|---|
| Tab switch | Crossfade | 200ms |
| Push screen | Slide left + fade in | 300ms ease-out |
| Pop screen | Slide right + fade out | 250ms ease-out |
| Modal / Sheet | Slide up | 350ms ease-out |
| Modal dismiss | Slide down | 300ms ease-in |
| Alert dialog | Scale(0.85→1.0) + fade in | 250ms spring |

---

### 14.4 Feedback Animations

| Trigger | Animation |
|---|---|
| Form submit loading | Button text hides, spinner appears (fade in) |
| Success checkmark | Circle stroke draws → checkmark stroke draws → spring scale |
| Giving success | Confetti burst (3s), then checkmark |
| Register event | Checkmark replaces button (stroke draw, 400ms) |
| Prayer emoji reaction | Emoji floats up, fade out at top (1200ms) |
| LIVE badge | Dot pulses every 2s |
| Notification badge | Bounce on arrival |

---

### 14.5 Lottie Animations (Required Files)

| File Name | Used On | Description |
|---|---|---|
| `prayer_success.json` | Prayer confirmation | Praying hands glow |
| `confetti.json` | Giving success | Colorful confetti burst |
| `checkmark.json` | Event register, form success | Green checkmark draws |
| `empty_church.json` | Empty states | Simple church illustration |
| `loading_cross.json` | Splash / loading | Cross pulse (optional) |

---

### ✅ Section 14 Checklist

- [ ] Global button press animation (`0.96` scale) applied to all buttons
- [ ] Card tap lift animation applied to all cards
- [ ] Home screen stagger animation on mount
- [ ] Screen push/pop transitions defined in router
- [ ] Bottom sheet slide-up transition
- [ ] All Lottie files added to assets
- [ ] Confetti on giving success
- [ ] Checkmark animation on event registration
- [ ] Emoji float on Live Service reactions
- [ ] All animations tested on low-end devices (no jank)

---

## 15. Empty States

> Every list, tab, or content area that can be empty must have a designed empty state.

---

### 15.1 Empty State Component

```
Layout (centered, vertical):
  Illustration:     Lottie or static SVG — 160px × 160px
  Title:            headingSmall, colorTextPrimary, centered
  Subtitle:         bodyMedium, colorTextSecondary, centered, max 2 lines
  Button:           Secondary button (optional), centered, 16px top
```

---

### 15.2 Empty State Definitions

| Screen | Illustration | Title | Subtitle | Button |
|---|---|---|---|---|
| Sermons (no results) | Empty church | "No sermons found" | "Try a different search or filter." | Clear filters |
| Events | Calendar + sun | "No upcoming events" | "Check back soon for new events." | "Browse past events" |
| Giving history | Empty wallet | "No giving history yet" | "Your generosity journey starts here." | "Give Now" |
| Prayer requests | Candle | "No prayer requests yet" | "Share your heart — your church is here for you." | "Submit a Prayer" |
| Notifications | Bell | "You're all caught up!" | "No new notifications." | *(no button)* |
| Groups | Community | "No groups yet" | "Small groups are coming soon." | *(no button)* |
| Saved sermons | Bookmark | "No saved sermons" | "Bookmark sermons to listen later." | "Browse Sermons" |

---

### ✅ Section 15 Checklist

- [ ] Empty state component built (reusable)
- [ ] All 7 empty state definitions implemented
- [ ] Empty states show after loading (not during skeleton)
- [ ] Empty state buttons route correctly

---

## 16. Loading States

> **Rule:** No spinners. Only skeleton loaders.

---

### 16.1 Skeleton Loader Rules

```
Color:          #E5E7EB (light) | #1F2937 (dark)
Animation:      Shimmer — gradient sweeps left to right, 1.5s loop
Border radius:  Match the element it represents
```

---

### 16.2 Skeleton Definitions Per Screen

#### Home Screen Skeleton

```
App bar:          Skip (always visible)
Verse card:       160px × full-width block
Feature grid:     4 × 130px square blocks (2×2)
Events row:       3 × 200px × 220px horizontal blocks
Sermon card:      100px full-width block
```

#### Sermons Screen Skeleton

```
Search bar:       48px full-width block
Filter chips:     4 × 80px × 36px blocks (row)
Sermon cards:     5 × 100px full-width blocks
```

#### Events Screen Skeleton

```
Calendar:         300px full-width block
Event cards:      3 × 200px full-width blocks
```

#### Giving Screen Skeleton

```
Category chips:   3 × 90px chips
Amount chips:     6 chips (2×3 grid)
Payment options:  3 × 72px blocks
```

---

### ✅ Section 16 Checklist

- [ ] Shimmer skeleton component built
- [ ] Home screen skeleton defined and implemented
- [ ] Sermons screen skeleton implemented
- [ ] Events screen skeleton implemented
- [ ] Giving screen skeleton implemented
- [ ] Profile screen skeleton implemented
- [ ] Skeleton → real content transition (fade in, 300ms)

---

## 17. Dark Mode

> **Goal:** Every screen must look intentional and premium in dark mode — not just "dark backgrounds."

---

### 17.1 Dark Mode Token Mapping

| Light Token | Dark Replacement |
|---|---|
| `colorWarmWhite` (#FAFAFA) | `colorBgDark` (#0B1220) |
| `colorSurface` (#FFFFFF) | `colorCardDark` (#111827) |
| `colorSkyLight` (#E0F2FE) | `#1E293B` (slate-800) |
| `colorTextPrimary` (#111827) | `#F9FAFB` |
| `colorTextSecondary` (#6B7280) | `#9CA3AF` |
| Divider (#F3F4F6) | `colorBorderDark` (#1F2937) |
| Shadow | Reduce opacity by 50% in dark mode |

---

### 17.2 Elements That Stay The Same in Dark Mode

```
- colorPrimary (#1E3A8A) — stays (use colorPrimaryLight in some surfaces)
- colorGold (#FBBF24) — stays (gold always pops)
- colorSuccess / colorError — stays
- Card border radius — stays
- Verse card gradient — slightly lighter: #1E3A8A → #2563EB
```

---

### 17.3 Dark Mode Toggle

```
Location:       Profile → App Theme
Options:        Light | Dark | System (follow device setting)
Style:          Segmented control (3 options)
Persistence:    Save to local storage, apply on app launch
Transition:     Full-screen crossfade (300ms) on theme switch
```

---

### ✅ Section 17 Checklist

- [ ] All color tokens have dark mode overrides
- [ ] Theme provider wraps entire app
- [ ] Theme toggle in Profile → App Theme
- [ ] System theme detection implemented
- [ ] Theme persisted across sessions
- [ ] Every screen reviewed in dark mode
- [ ] No hardcoded colors in any widget (all use tokens)

---

## 18. Accessibility

---

### 18.1 Touch Targets

```
Minimum tap target size: 44px × 44px (Apple HIG + Material guideline)
Apply to:
  - All icon buttons
  - Navigation tabs
  - Checkboxes, toggles, radio buttons
  - Small chips (use extra invisible padding if needed)
```

---

### 18.2 Color Contrast

| Combination | Minimum Ratio | Check |
|---|---|---|
| White text on `colorPrimary` | 4.5:1 (AA) | ✅ Pass |
| `colorTextPrimary` on white | 4.5:1 (AA) | ✅ Pass |
| `colorTextSecondary` on white | 3:1 (AA Large) | ⚠️ Verify |
| White text on `colorGold` | Must verify | ⚠️ May fail — use dark text on gold |

> ⚠️ Use dark text (`#111827`) on gold (`#FBBF24`) backgrounds. White on gold fails contrast.

---

### 18.3 Screen Reader Support

```
Every interactive element must have:
  - Semantic label (accessibilityLabel / Semantics)
  - Hint where needed (accessibilityHint)
  - State announcement (e.g. "Bookmarked" / "Not bookmarked")

Images must have:
  - Alt text or marked as decorative (accessibilityLabel: "")

Custom components must:
  - Use proper semantic roles (button, header, link)
  - Not rely on color alone to convey state
```

---

### 18.4 Large Font Mode

```
Use:            Dynamic font scaling (Flutter: textScaleFactor / RN: allowFontScaling)
Test at:        1.0× (normal) and 1.3× (large)
Layouts must:   Not break, overflow, or truncate at 1.3×
                Use flexible layouts (Flexible, Expanded in Flutter)
                Avoid fixed-height containers containing text
```

---

### 18.5 High Contrast Mode

```
When enabled (system or in-app toggle):
  - Increase all border widths by 1px
  - Use colorPrimary borders on all cards (instead of shadow)
  - Remove subtle tints, use pure white/black
  - Increase text weight by one step (Regular → Medium, Medium → SemiBold)
```

---

### ✅ Section 18 Checklist

- [ ] All tap targets ≥ 44px × 44px
- [ ] Contrast ratios verified for all text/background combos
- [ ] Dark text used on gold backgrounds
- [ ] All images have alt text or marked decorative
- [ ] All buttons and interactive elements have accessibility labels
- [ ] All screens tested with screen reader (VoiceOver / TalkBack)
- [ ] All screens tested at font scale 1.3×
- [ ] High contrast toggle implemented in Settings
- [ ] No layout breaks at large font size

---

## 19. Implementation Checklist

> Use this as your master progress tracker. Check off sections as they are fully designed AND implemented.

---

### Design System

- [ ] **1.0** Color tokens defined
- [ ] **1.1** Gradients defined
- [ ] **1.2** Shadows defined
- [ ] **1.3** Border radius tokens defined
- [ ] **2.0** Typography scale defined
- [ ] **2.1** Large text mode implemented
- [ ] **3.0** Spacing tokens defined
- [ ] **3.1** Screen layout rules applied

### Component Library

- [ ] **4.1** All button variants
- [ ] **4.2** All card variants
- [ ] **4.3** Input fields (all states)
- [ ] **4.4** Navigation (bottom nav + app bar)
- [ ] **4.5** Filter chips
- [ ] **4.6** Avatar
- [ ] **4.7** Badge
- [ ] **4.8** Divider
- [ ] **FAB** Prayer button

### Navigation

- [ ] **5.0** Full route tree implemented
- [ ] **5.1** Navigation transitions defined
- [ ] **5.2** Deep link support

### Screens

- [ ] **6.0** Splash screen
- [ ] **6.1** Onboarding (3 slides)
- [ ] **6.2** Login screen
- [ ] **6.3** Register screen
- [ ] **6.4** Church code screen
- [ ] **6.5** Forgot password flow
- [ ] **7.0** Home screen (full)
- [ ] **8.0** Sermons screen + detail
- [ ] **9.0** Live Service screen
- [ ] **10.0** Events screen + detail
- [ ] **11.0** Giving screen + success
- [ ] **12.0** Profile screen
- [ ] **13.0** Prayer request sheet

### Polish

- [ ] **14.0** All micro-animations applied
- [ ] **15.0** All empty states implemented
- [ ] **16.0** All skeleton loaders implemented
- [ ] **17.0** Dark mode (all screens)
- [ ] **18.0** Accessibility audit complete
- [ ] Final review — every screen "breathes"

---

> **Final Design Principle:** This app must feel peaceful, modern, fast, and spiritually uplifting.
> Never cluttered. Every screen must breathe. White space is part of worship.

---

*Guide Version: 1.0 · Created: February 23, 2026*
