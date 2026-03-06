import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/search.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SEARCH REPOSITORY
// ──────────────────────────────────────────────────────────────────────────────

abstract class SearchRepository {
  List<SearchItem> getAllItems();
  List<String> getDefaultRecentSearches();
  List<String> getTrending();
}

class MockSearchRepository implements SearchRepository {
  @override
  List<String> getDefaultRecentSearches() => const [
        'Sunday worship',
        'Youth group events',
        'Pastor James sermon',
        'Bible study Genesis',
        'Volunteering signup',
      ];

  @override
  List<String> getTrending() => const [
        'Easter service',
        'Prayer meeting',
        'Small groups',
        'Baptism',
        'Worship night',
        'Mission trip',
      ];

  @override
  List<SearchItem> getAllItems() => const [
        // ── Sermons ───────────────────────────────────────────────────────
        SearchItem(
          title: 'The Power of Faith',
          subtitle: 'Pastor James Wilson | Feb 16, 2026',
          category: 'Sermons',
          icon: Icons.mic_outlined,
          color: Color(0xFF3B82F6),
          route: '/sermons/1',
        ),
        SearchItem(
          title: 'Walking in Grace',
          subtitle: 'Pastor James Wilson | Feb 9, 2026',
          category: 'Sermons',
          icon: Icons.mic_outlined,
          color: Color(0xFF3B82F6),
          route: '/sermons/2',
        ),
        SearchItem(
          title: 'Finding Hope in Hard Times',
          subtitle: 'Pastor Sarah Chen | Feb 2, 2026',
          category: 'Sermons',
          icon: Icons.mic_outlined,
          color: Color(0xFF3B82F6),
          route: '/sermons/3',
        ),
        SearchItem(
          title: 'Unshakeable Faith Series',
          subtitle: '6-part series | 12 episodes',
          category: 'Sermons',
          icon: Icons.playlist_play_outlined,
          color: Color(0xFF3B82F6),
          route: '/series/1',
        ),

        // ── Events ────────────────────────────────────────────────────────
        SearchItem(
          title: 'Easter Sunrise Service',
          subtitle: 'Apr 5, 2026 | 6:00 AM | Main Campus',
          category: 'Events',
          icon: Icons.event_outlined,
          color: Color(0xFFEF4444),
          route: '/events/1',
        ),
        SearchItem(
          title: 'Youth Camp 2026',
          subtitle: 'Jun 15-20 | Lake Retreat Center',
          category: 'Events',
          icon: Icons.event_outlined,
          color: Color(0xFFEF4444),
          route: '/events/2',
        ),
        SearchItem(
          title: 'Worship Night',
          subtitle: 'Every Friday | 7:00 PM | Main Auditorium',
          category: 'Events',
          icon: Icons.event_outlined,
          color: Color(0xFFEF4444),
          route: '/events/3',
        ),
        SearchItem(
          title: 'Marriage Retreat Weekend',
          subtitle: 'Mar 21-22 | Mountain Lodge',
          category: 'Events',
          icon: Icons.event_outlined,
          color: Color(0xFFEF4444),
          route: '/events/4',
        ),

        // ── People ────────────────────────────────────────────────────────
        SearchItem(
          title: 'Pastor James Wilson',
          subtitle: 'Senior Pastor | Main Campus',
          category: 'People',
          icon: Icons.person_outlined,
          color: Color(0xFF8B5CF6),
          route: '/pastors',
        ),
        SearchItem(
          title: 'Sarah Chen',
          subtitle: 'Associate Pastor | Youth Ministry',
          category: 'People',
          icon: Icons.person_outlined,
          color: Color(0xFF8B5CF6),
          route: '/pastors',
        ),
        SearchItem(
          title: 'David Kim',
          subtitle: 'Worship Director | Music Ministry',
          category: 'People',
          icon: Icons.person_outlined,
          color: Color(0xFF8B5CF6),
          route: '/church-directory',
        ),

        // ── Forum ─────────────────────────────────────────────────────────
        SearchItem(
          title: 'Please pray for healing',
          subtitle: 'Prayer Requests | David K. | 67 replies',
          category: 'Forum',
          icon: Icons.forum_outlined,
          color: Color(0xFF6366F1),
          route: '/forum/thread/1',
        ),
        SearchItem(
          title: 'Best Bible study apps?',
          subtitle: 'Questions & Answers | Sarah M. | 23 replies',
          category: 'Forum',
          icon: Icons.forum_outlined,
          color: Color(0xFF6366F1),
          route: '/forum/thread/2',
        ),
        SearchItem(
          title: 'How I found Christ - testimony',
          subtitle: 'Testimonies | Grace L. | 45 replies',
          category: 'Forum',
          icon: Icons.forum_outlined,
          color: Color(0xFF6366F1),
          route: '/forum/thread/3',
        ),

        // ── Bible ─────────────────────────────────────────────────────────
        SearchItem(
          title: 'Philippians 4:13',
          subtitle:
              'I can do all things through Christ who strengthens me.',
          category: 'Bible',
          icon: Icons.menu_book_outlined,
          color: Color(0xFF059669),
          route: '/bible',
        ),
        SearchItem(
          title: 'Jeremiah 29:11',
          subtitle:
              'For I know the plans I have for you, declares the Lord.',
          category: 'Bible',
          icon: Icons.menu_book_outlined,
          color: Color(0xFF059669),
          route: '/bible',
        ),
        SearchItem(
          title: 'Romans 8:28',
          subtitle:
              'All things work together for good to those who love God.',
          category: 'Bible',
          icon: Icons.menu_book_outlined,
          color: Color(0xFF059669),
          route: '/bible',
        ),
        SearchItem(
          title: 'Genesis Bible Study',
          subtitle: 'Reading Plan | 30 days | 12 participants',
          category: 'Bible',
          icon: Icons.auto_stories_outlined,
          color: Color(0xFF059669),
          route: '/reading-plan',
        ),

        // ── Groups ────────────────────────────────────────────────────────
        SearchItem(
          title: 'Young Adults Small Group',
          subtitle: 'Tuesdays 7 PM | 12 members | Open',
          category: 'Groups',
          icon: Icons.groups_outlined,
          color: Color(0xFFF59E0B),
          route: '/connect-groups/1',
        ),
        SearchItem(
          title: 'Mens Prayer Breakfast',
          subtitle: 'Saturdays 7 AM | 8 members | Open',
          category: 'Groups',
          icon: Icons.groups_outlined,
          color: Color(0xFFF59E0B),
          route: '/connect-groups/2',
        ),
        SearchItem(
          title: 'Womens Bible Study',
          subtitle: 'Wednesdays 10 AM | 15 members | Open',
          category: 'Groups',
          icon: Icons.groups_outlined,
          color: Color(0xFFF59E0B),
          route: '/connect-groups/3',
        ),

        // ── Giving ────────────────────────────────────────────────────────
        SearchItem(
          title: 'Building Fund Campaign',
          subtitle: '72% raised | \$360,000 of \$500,000',
          category: 'Giving',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFFEC4899),
          route: '/giving/campaign',
        ),

        // ── Media ─────────────────────────────────────────────────────────
        SearchItem(
          title: 'Sunday Worship Playlist',
          subtitle: '14 songs | Worship team favorites',
          category: 'Media',
          icon: Icons.music_note_outlined,
          color: Color(0xFF0EA5E9),
          route: '/worship-lyrics',
        ),
        SearchItem(
          title: 'Faith Talks Podcast',
          subtitle: 'Weekly discussions | 45 episodes',
          category: 'Media',
          icon: Icons.podcasts_outlined,
          color: Color(0xFF0EA5E9),
          route: '/podcast-feed',
        ),
      ];
}
