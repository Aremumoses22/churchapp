import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/forum.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FORUM REPOSITORY
// ──────────────────────────────────────────────────────────────────────────────

abstract class ForumRepository {
  List<ForumCategory> getCategories();
  List<ForumThread> getTrendingTopics();
  List<ForumThread> getRecentThreads();
  List<ForumThread> getThreadsForCategory(String categoryId);
  ForumCategory? getCategoryMeta(String categoryId);
  ForumPost getPost(String threadId);
  List<ForumReply> getReplies(String threadId);
}

class MockForumRepository implements ForumRepository {
  @override
  List<ForumCategory> getCategories() => const [
        ForumCategory(
          id: 'prayer',
          label: 'Prayer\nRequests',
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFFEF4444),
          threadCount: 128,
          description: 'Share and support prayer needs',
        ),
        ForumCategory(
          id: 'bible-study',
          label: 'Bible\nDiscussion',
          icon: Icons.menu_book_outlined,
          color: Color(0xFF3B82F6),
          threadCount: 95,
          description: 'Explore scripture together',
        ),
        ForumCategory(
          id: 'testimonies',
          label: 'Testimonies',
          icon: Icons.stars_outlined,
          color: Color(0xFF8B5CF6),
          threadCount: 64,
          description: 'Share what God has done',
        ),
        ForumCategory(
          id: 'general',
          label: 'General',
          icon: Icons.chat_bubble_outline,
          color: Color(0xFF059669),
          threadCount: 210,
          description: 'Fellowship and conversation',
        ),
        ForumCategory(
          id: 'youth',
          label: 'Youth\nForum',
          icon: Icons.school_outlined,
          color: Color(0xFFF59E0B),
          threadCount: 47,
          description: 'Young adults community',
        ),
        ForumCategory(
          id: 'events',
          label: 'Events &\nMeetups',
          icon: Icons.event_outlined,
          color: Color(0xFFEC4899),
          threadCount: 33,
          description: 'Plan and discuss events',
        ),
        ForumCategory(
          id: 'volunteer',
          label: 'Serve &\nVolunteer',
          icon: Icons.handshake_outlined,
          color: Color(0xFF0EA5E9),
          threadCount: 22,
          description: 'Service opportunities',
        ),
        ForumCategory(
          id: 'qna',
          label: 'Q & A',
          icon: Icons.help_outline,
          color: Color(0xFF6366F1),
          threadCount: 156,
          description: 'Ask questions, get answers',
        ),
      ];

  @override
  List<ForumThread> getTrendingTopics() => const [
        ForumThread(
          id: 't1',
          title: 'Sunday sermon discussion - "Walking by Faith"',
          author: '',
          authorInitials: '',
          avatarColor: Color(0xFF3B82F6),
          body: '',
          replies: 34,
          likes: 0,
          timeAgo: '',
          category: 'Bible Discussion',
          categoryColor: Color(0xFF3B82F6),
        ),
        ForumThread(
          id: 't2',
          title: 'Prayer chain for the Johnson family',
          author: '',
          authorInitials: '',
          avatarColor: Color(0xFFEF4444),
          body: '',
          replies: 52,
          likes: 0,
          timeAgo: '',
          category: 'Prayer Requests',
          categoryColor: Color(0xFFEF4444),
        ),
        ForumThread(
          id: 't3',
          title: 'Volunteers needed for community outreach Sat',
          author: '',
          authorInitials: '',
          avatarColor: Color(0xFF0EA5E9),
          body: '',
          replies: 18,
          likes: 0,
          timeAgo: '',
          category: 'Serve & Volunteer',
          categoryColor: Color(0xFF0EA5E9),
        ),
      ];

  @override
  List<ForumThread> getRecentThreads() => const [
        ForumThread(
          id: 'r1',
          title: 'How has your quiet time changed this year?',
          author: 'Sarah M.',
          authorInitials: 'SM',
          avatarColor: Color(0xFF8B5CF6),
          category: 'General',
          categoryColor: Color(0xFF059669),
          body:
              'I have been using a journaling method for my quiet time and it has completely transformed how I engage with scripture...',
          replies: 12,
          likes: 28,
          timeAgo: '2h ago',
        ),
        ForumThread(
          id: 'r2',
          title: 'Please pray for healing - upcoming surgery',
          author: 'David K.',
          authorInitials: 'DK',
          avatarColor: Color(0xFFEF4444),
          category: 'Prayer Requests',
          categoryColor: Color(0xFFEF4444),
          body:
              'I have surgery scheduled for next Thursday. Would really appreciate the church family covering me in prayer...',
          replies: 31,
          likes: 67,
          timeAgo: '4h ago',
          isPinned: true,
        ),
        ForumThread(
          id: 'r3',
          title: 'Youth camp photos & highlights!',
          author: 'Pastor James',
          authorInitials: 'PJ',
          avatarColor: Color(0xFFF59E0B),
          category: 'Youth Forum',
          categoryColor: Color(0xFFF59E0B),
          body:
              'What an incredible week at summer camp! 23 young people gave their lives to Christ. Here are some highlights...',
          replies: 19,
          likes: 94,
          timeAgo: '6h ago',
        ),
        ForumThread(
          id: 'r4',
          title: 'Understanding Romans 8:28 in difficult seasons',
          author: 'Grace L.',
          authorInitials: 'GL',
          avatarColor: Color(0xFF3B82F6),
          category: 'Bible Discussion',
          categoryColor: Color(0xFF3B82F6),
          body:
              'I have been studying Romans 8 and wanted to share some thoughts on how "all things work together" does not mean all things are good...',
          replies: 24,
          likes: 45,
          timeAgo: '1d ago',
        ),
        ForumThread(
          id: 'r5',
          title: 'Testimony: God provided a job after 6 months',
          author: 'Michael R.',
          authorInitials: 'MR',
          avatarColor: Color(0xFF059669),
          category: 'Testimonies',
          categoryColor: Color(0xFF8B5CF6),
          body:
              'I want to glorify God for His faithfulness. After 6 months of unemployment and many tears, He opened a door...',
          replies: 42,
          likes: 118,
          timeAgo: '1d ago',
        ),
      ];

  @override
  List<ForumThread> getThreadsForCategory(String categoryId) => [
        ForumThread(
          id: '$categoryId-1',
          title: 'Welcome to this category - read first!',
          author: 'Admin',
          authorInitials: 'AD',
          avatarColor: const Color(0xFF1E40AF),
          body:
              'Welcome! Please read the community guidelines before posting. Be respectful, kind, and Christ-centered in all interactions.',
          replies: 8,
          likes: 45,
          timeAgo: '3d ago',
          isPinned: true,
        ),
        ForumThread(
          id: '$categoryId-2',
          title: 'What has been on your heart lately?',
          author: 'Rebecca T.',
          authorInitials: 'RT',
          avatarColor: const Color(0xFF8B5CF6),
          body:
              'I wanted to open a space for us to share what God has been putting on our hearts this season. I will go first...',
          replies: 23,
          likes: 56,
          timeAgo: '5h ago',
        ),
        ForumThread(
          id: '$categoryId-3',
          title: 'Book recommendation: "Mere Christianity"',
          author: 'Thomas A.',
          authorInitials: 'TA',
          avatarColor: const Color(0xFF059669),
          body:
              'I just finished re-reading C.S. Lewis and was reminded how powerfully he articulates the faith. Anyone else a fan?',
          replies: 15,
          likes: 38,
          timeAgo: '12h ago',
        ),
        ForumThread(
          id: '$categoryId-4',
          title: 'How do you handle doubt in your faith?',
          author: 'Nathan W.',
          authorInitials: 'NW',
          avatarColor: const Color(0xFF3B82F6),
          body:
              'Honest question - I have been going through a season of doubt and wondering if anyone else has experienced this...',
          replies: 41,
          likes: 89,
          timeAgo: '1d ago',
        ),
        ForumThread(
          id: '$categoryId-5',
          title: 'Favourite worship songs this month?',
          author: 'Lydia P.',
          authorInitials: 'LP',
          avatarColor: const Color(0xFFEC4899),
          body:
              'What songs have been speaking to your soul? I cannot stop listening to "Goodness of God" by Bethel...',
          replies: 29,
          likes: 61,
          timeAgo: '1d ago',
        ),
        ForumThread(
          id: '$categoryId-6',
          title: 'Starting a small group - who is interested?',
          author: 'Pastor James',
          authorInitials: 'PJ',
          avatarColor: const Color(0xFFF59E0B),
          body:
              'Thinking about starting a Tuesday evening study group. We would go through Philippians together over 6 weeks.',
          replies: 17,
          likes: 44,
          timeAgo: '2d ago',
        ),
        ForumThread(
          id: '$categoryId-7',
          title: 'Encouraging verse for hard days',
          author: 'Grace L.',
          authorInitials: 'GL',
          avatarColor: const Color(0xFF6366F1),
          body:
              '"Come to me, all who are weary and burdened, and I will give you rest." - Matthew 11:28. This verse has carried me.',
          replies: 33,
          likes: 102,
          timeAgo: '3d ago',
        ),
      ];

  @override
  ForumCategory? getCategoryMeta(String categoryId) {
    final categories = getCategories();
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  ForumPost getPost(String threadId) => const ForumPost(
        title: 'Please pray for healing - upcoming surgery',
        author: 'David K.',
        authorInitials: 'DK',
        avatarColor: Color(0xFFEF4444),
        body:
            'Dear church family,\n\nI have surgery scheduled for next Thursday and I am honestly nervous. The doctors say the procedure is routine, but I would really appreciate the church family covering me in prayer during this time.\n\nSpecifically, I am asking for:\n  - Peace and calm leading up to the day\n  - Wisdom and skill for the surgical team\n  - A quick and complete recovery\n  - Strength for my wife and kids during the wait\n\n"Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God." - Philippians 4:6\n\nThank you all for your love and support. This community means everything to me. God bless you all.',
        category: 'Prayer Requests',
        categoryColor: Color(0xFFEF4444),
        timeAgo: '4 hours ago',
        views: 234,
      );

  @override
  List<ForumReply> getReplies(String threadId) => const [
        ForumReply(
          id: 'rep1',
          author: 'Sarah M.',
          authorInitials: 'SM',
          avatarColor: Color(0xFF8B5CF6),
          body:
              'Praying for you, David! God is in control and He will see you through. "The Lord is my shepherd, I shall not want." You have got this!',
          timeAgo: '3h ago',
          likes: 12,
        ),
        ForumReply(
          id: 'rep2',
          author: 'Pastor James',
          authorInitials: 'PJ',
          avatarColor: Color(0xFFF59E0B),
          body:
              'Brother David, I will be praying specifically for you and your family this week. I would also like to organize a prayer chain for Thursday morning - will announce at Wednesday service. You are covered!',
          timeAgo: '3h ago',
          likes: 24,
        ),
        ForumReply(
          id: 'rep3',
          author: 'Grace L.',
          authorInitials: 'GL',
          avatarColor: Color(0xFF3B82F6),
          body:
              'Just prayed for you right now. Isaiah 41:10 - "Fear not, for I am with you; be not dismayed, for I am your God." Standing with you in faith!',
          timeAgo: '2h ago',
          likes: 9,
        ),
        ForumReply(
          id: 'rep4',
          author: 'Michael R.',
          authorInitials: 'MR',
          avatarColor: Color(0xFF059669),
          body:
              'David, I went through a similar surgery last year. God was so faithful. If you need anything - meals, rides, someone to talk to - do not hesitate. We are family!',
          timeAgo: '1h ago',
          likes: 15,
        ),
        ForumReply(
          id: 'rep5',
          author: 'Rebecca T.',
          authorInitials: 'RT',
          avatarColor: Color(0xFFEC4899),
          body:
              'Lifting you up. Our small group will be praying for you at our meeting tomorrow night. You are so loved by this church!',
          timeAgo: '45m ago',
          likes: 7,
        ),
      ];
}
