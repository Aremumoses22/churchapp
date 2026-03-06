import 'dart:ui';

import '../models/chat.dart';
import '../theme/app_colors.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CHAT REPOSITORY
// ──────────────────────────────────────────────────────────────────────────────

abstract class ChatRepository {
  List<ChatPreview> getChats();
  Map<String, ChatMeta> getAllChatMeta();
  ChatMeta? getChatMeta(String chatId);
  List<ChatMessage> getMessages(String chatId);
}

class MockChatRepository implements ChatRepository {
  @override
  List<ChatPreview> getChats() => [
        const ChatPreview(
          id: 'c1',
          name: 'Pastor James Wilson',
          initials: 'PJ',
          avatarColor: Color(0xFFF59E0B),
          lastMessage:
              'Thank you for your faithfulness, brother. Keep pressing on!',
          time: '2m ago',
          unreadCount: 2,
          isOnline: true,
          isPinned: true,
        ),
        const ChatPreview(
          id: 'c2',
          name: 'Young Adults Group',
          initials: 'YA',
          avatarColor: Color(0xFF8B5CF6),
          lastMessage:
              'Sarah: Who is bringing snacks to the meeting Thursday?',
          time: '15m ago',
          unreadCount: 5,
          isGroup: true,
        ),
        const ChatPreview(
          id: 'c3',
          name: 'Sarah Mitchell',
          initials: 'SM',
          avatarColor: Color(0xFF8B5CF6),
          lastMessage:
              'That Bible study was so good! Thanks for the notes.',
          time: '1h ago',
          unreadCount: 1,
          isOnline: true,
        ),
        const ChatPreview(
          id: 'c4',
          name: 'Worship Team',
          initials: 'WT',
          avatarColor: Color(0xFF3B82F6),
          lastMessage:
              'David: Rehearsal is moved to 5 PM this Saturday.',
          time: '3h ago',
          isGroup: true,
        ),
        const ChatPreview(
          id: 'c5',
          name: 'Grace Lee',
          initials: 'GL',
          avatarColor: Color(0xFF3B82F6),
          lastMessage:
              'I will be praying for you! Isaiah 41:10',
          time: '5h ago',
          isOnline: true,
        ),
        const ChatPreview(
          id: 'c6',
          name: 'Prayer Chain',
          initials: 'PC',
          avatarColor: Color(0xFFEC4899),
          lastMessage:
              'Michael: Adding David K. to our prayers for surgery.',
          time: 'Yesterday',
          isGroup: true,
          isMuted: true,
        ),
        const ChatPreview(
          id: 'c7',
          name: 'David Kim',
          initials: 'DK',
          avatarColor: Color(0xFFEF4444),
          lastMessage:
              'Thanks for the encouragement! Feeling more at peace now.',
          time: 'Yesterday',
        ),
        const ChatPreview(
          id: 'c8',
          name: 'Michael Roberts',
          initials: 'MR',
          avatarColor: Color(0xFF059669),
          lastMessage:
              'Sure, I can help with setup on Sunday morning.',
          time: '2 days ago',
        ),
        const ChatPreview(
          id: 'c9',
          name: 'Serve Team',
          initials: 'ST',
          avatarColor: Color(0xFF059669),
          lastMessage:
              'Rebecca: Schedule for March is posted!',
          time: '3 days ago',
          isGroup: true,
        ),
        const ChatPreview(
          id: 'c10',
          name: 'Rebecca Taylor',
          initials: 'RT',
          avatarColor: Color(0xFFEC4899),
          lastMessage: 'See you at small group tomorrow!',
          time: '4 days ago',
        ),
      ];

  @override
  Map<String, ChatMeta> getAllChatMeta() => const {
        'c1': ChatMeta(
            name: 'Pastor James Wilson',
            initials: 'PJ',
            color: Color(0xFFF59E0B),
            isOnline: true),
        'c2': ChatMeta(
            name: 'Young Adults Group',
            initials: 'YA',
            color: Color(0xFF8B5CF6),
            isOnline: false,
            isGroup: true,
            memberCount: 12),
        'c3': ChatMeta(
            name: 'Sarah Mitchell',
            initials: 'SM',
            color: Color(0xFF8B5CF6),
            isOnline: true),
        'c4': ChatMeta(
            name: 'Worship Team',
            initials: 'WT',
            color: Color(0xFF3B82F6),
            isOnline: false,
            isGroup: true,
            memberCount: 8),
        'c5': ChatMeta(
            name: 'Grace Lee',
            initials: 'GL',
            color: Color(0xFF3B82F6),
            isOnline: true),
        'c6': ChatMeta(
            name: 'Prayer Chain',
            initials: 'PC',
            color: Color(0xFFEC4899),
            isOnline: false,
            isGroup: true,
            memberCount: 15),
        'c7': ChatMeta(
            name: 'David Kim',
            initials: 'DK',
            color: Color(0xFFEF4444),
            isOnline: false),
        'c8': ChatMeta(
            name: 'Michael Roberts',
            initials: 'MR',
            color: Color(0xFF059669),
            isOnline: false),
        'c9': ChatMeta(
            name: 'Serve Team',
            initials: 'ST',
            color: Color(0xFF059669),
            isOnline: false,
            isGroup: true,
            memberCount: 10),
        'c10': ChatMeta(
            name: 'Rebecca Taylor',
            initials: 'RT',
            color: Color(0xFFEC4899),
            isOnline: false),
      };

  @override
  ChatMeta? getChatMeta(String chatId) => getAllChatMeta()[chatId];

  @override
  List<ChatMessage> getMessages(String chatId) {
    switch (chatId) {
      case 'c1':
        return [
          ChatMessage(
              id: 'm1',
              text:
                  'Good morning Pastor! I wanted to thank you for the sermon yesterday. It really spoke to me.',
              sender: 'You',
              senderInitials: 'ME',
              senderColor: AppColors.primary,
              time: '9:15 AM',
              isMe: true,
              timeGroup: 'Today'),
          const ChatMessage(
              id: 'm2',
              text:
                  'Good morning! That blesses me to hear. Which part resonated with you the most?',
              sender: 'Pastor James',
              senderInitials: 'PJ',
              senderColor: Color(0xFFF59E0B),
              time: '9:20 AM',
              isMe: false),
          ChatMessage(
              id: 'm3',
              text:
                  'The part about trusting God during uncertainty. I have been going through a tough season and it gave me so much hope.',
              sender: 'You',
              senderInitials: 'ME',
              senderColor: AppColors.primary,
              time: '9:22 AM',
              isMe: true),
          const ChatMessage(
              id: 'm4',
              text:
                  'I am sorry to hear you are going through a tough time. Remember Romans 8:28 - God works all things together for good. Would you like to meet for coffee this week to talk and pray?',
              sender: 'Pastor James',
              senderInitials: 'PJ',
              senderColor: Color(0xFFF59E0B),
              time: '9:25 AM',
              isMe: false),
          ChatMessage(
              id: 'm5',
              text:
                  'I would love that! Thank you so much for caring.',
              sender: 'You',
              senderInitials: 'ME',
              senderColor: AppColors.primary,
              time: '9:26 AM',
              isMe: true),
          const ChatMessage(
              id: 'm6',
              text:
                  'Thank you for your faithfulness, brother. Keep pressing on!',
              sender: 'Pastor James',
              senderInitials: 'PJ',
              senderColor: Color(0xFFF59E0B),
              time: '9:28 AM',
              isMe: false),
        ];
      case 'c2':
        return [
          ChatMessage(
              id: 'm1',
              text:
                  'Hey everyone! Just a reminder that our meeting is this Thursday.',
              sender: 'You',
              senderInitials: 'ME',
              senderColor: AppColors.primary,
              time: '2:00 PM',
              isMe: true,
              timeGroup: 'Yesterday'),
          const ChatMessage(
              id: 'm2',
              text:
                  'Awesome! I will be there. Should I bring anything?',
              sender: 'Grace',
              senderInitials: 'GL',
              senderColor: Color(0xFF3B82F6),
              time: '2:05 PM',
              isMe: false),
          ChatMessage(
              id: 'm3',
              text: 'Maybe some snacks would be great!',
              sender: 'You',
              senderInitials: 'ME',
              senderColor: AppColors.primary,
              time: '2:06 PM',
              isMe: true),
          const ChatMessage(
              id: 'm4',
              text:
                  'Who is bringing snacks to the meeting Thursday?',
              sender: 'Sarah',
              senderInitials: 'SM',
              senderColor: Color(0xFF8B5CF6),
              time: '3:15 PM',
              isMe: false,
              timeGroup: 'Today'),
        ];
      default:
        return [
          ChatMessage(
              id: 'm1',
              text: 'Hey! How are you doing?',
              sender: 'You',
              senderInitials: 'ME',
              senderColor: AppColors.primary,
              time: '10:00 AM',
              isMe: true,
              timeGroup: 'Today'),
          const ChatMessage(
              id: 'm2',
              text:
                  'Doing great, thanks for asking! How about you?',
              sender: 'Friend',
              senderInitials: '??',
              senderColor: Color(0xFF059669),
              time: '10:05 AM',
              isMe: false),
          ChatMessage(
              id: 'm3',
              text:
                  'Blessed and grateful! Looking forward to Sunday service.',
              sender: 'You',
              senderInitials: 'ME',
              senderColor: AppColors.primary,
              time: '10:07 AM',
              isMe: true),
        ];
    }
  }
}
