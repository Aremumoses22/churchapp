import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { notificationService } from '../../services/notification.service';
import { emitToUser } from '../../socket/index';

export const chatService = {
  /**
   * List user's conversations with last message and unread count
   */
  async listConversations(userId: string, page: number, limit: number) {
    const skip = (page - 1) * limit;

    const memberships = await prisma.conversationMember.findMany({
      where: { userId },
      select: { conversationId: true, lastReadAt: true, isPinned: true, isMuted: true },
    });

    const conversationIds = memberships.map((m) => m.conversationId);

    const [conversations, total] = await Promise.all([
      prisma.conversation.findMany({
        where: { id: { in: conversationIds } },
        orderBy: { lastMessageAt: { sort: 'desc', nulls: 'last' } },
        skip,
        take: limit,
        include: {
          members: {
            include: {
              user: {
                select: { id: true, name: true, avatarUrl: true },
              },
            },
          },
          messages: {
            orderBy: { createdAt: 'desc' },
            take: 1,
            include: {
              sender: {
                select: { id: true, name: true },
              },
            },
          },
        },
      }),
      prisma.conversation.count({
        where: { id: { in: conversationIds } },
      }),
    ]);

    // Compute unread counts
    const membershipMap = new Map(
      memberships.map((m) => [m.conversationId, m]),
    );

    const enriched = await Promise.all(
      conversations.map(async (conv) => {
        const membership = membershipMap.get(conv.id);
        const lastReadAt = membership?.lastReadAt;

        const unreadCount = lastReadAt
          ? await prisma.message.count({
              where: {
                conversationId: conv.id,
                createdAt: { gt: lastReadAt },
                senderId: { not: userId },
              },
            })
          : await prisma.message.count({
              where: {
                conversationId: conv.id,
                senderId: { not: userId },
              },
            });

        return {
          id: conv.id,
          type: conv.type,
          name: conv.type === 'DIRECT'
            ? conv.members.find((m) => m.userId !== userId)?.user.name || 'Unknown'
            : conv.name,
          imageUrl: conv.type === 'DIRECT'
            ? conv.members.find((m) => m.userId !== userId)?.user.avatarUrl
            : conv.imageUrl,
          members: conv.members.map((m) => ({
            ...m.user,
            role: m.role,
          })),
          lastMessage: conv.messages[0] || null,
          unreadCount,
          isPinned: membership?.isPinned || false,
          isMuted: membership?.isMuted || false,
          lastMessageAt: conv.lastMessageAt,
        };
      }),
    );

    // Sort: pinned first, then by lastMessageAt
    enriched.sort((a, b) => {
      if (a.isPinned !== b.isPinned) return a.isPinned ? -1 : 1;
      const aTime = a.lastMessageAt?.getTime() || 0;
      const bTime = b.lastMessageAt?.getTime() || 0;
      return bTime - aTime;
    });

    return {
      conversations: enriched,
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },

  /**
   * Create a new conversation (direct or group)
   */
  async createConversation(
    userId: string,
    churchId: string,
    data: { type: string; name?: string; memberIds: string[] },
  ) {
    // For DIRECT, check if conversation already exists between these two users
    if (data.type === 'DIRECT') {
      if (data.memberIds.length !== 1) {
        throw ApiError.badRequest('Direct conversations must have exactly one other member');
      }

      const otherUserId = data.memberIds[0];
      if (otherUserId === userId) {
        throw ApiError.badRequest('Cannot create a conversation with yourself');
      }

      // Check if direct conversation already exists
      const existing = await prisma.conversation.findFirst({
        where: {
          type: 'DIRECT',
          AND: [
            { members: { some: { userId } } },
            { members: { some: { userId: otherUserId } } },
          ],
        },
        include: {
          members: {
            include: {
              user: { select: { id: true, name: true, avatarUrl: true } },
            },
          },
        },
      });

      if (existing) {
        return existing;
      }
    }

    // Include the creator in the member list
    const allMemberIds = [...new Set([userId, ...data.memberIds])];

    const conversation = await prisma.conversation.create({
      data: {
        churchId,
        type: data.type as any,
        name: data.name,
        createdById: userId,
        members: {
          create: allMemberIds.map((memberId) => ({
            userId: memberId,
            role: memberId === userId ? 'ADMIN' : 'MEMBER',
          })),
        },
      },
      include: {
        members: {
          include: {
            user: { select: { id: true, name: true, avatarUrl: true } },
          },
        },
      },
    });

    return conversation;
  },

  /**
   * Get messages for a conversation (paginated)
   */
  async getMessages(
    userId: string,
    conversationId: string,
    page: number,
    limit: number,
    before?: string,
  ) {
    // Verify membership
    const membership = await prisma.conversationMember.findUnique({
      where: {
        conversationId_userId: { conversationId, userId },
      },
    });

    if (!membership) {
      throw ApiError.forbidden('Not a member of this conversation');
    }

    const skip = (page - 1) * limit;
    const where: any = { conversationId };
    if (before) {
      where.createdAt = { lt: new Date(before) };
    }

    const [messages, total] = await Promise.all([
      prisma.message.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
        include: {
          sender: {
            select: { id: true, name: true, avatarUrl: true },
          },
          replyTo: {
            select: {
              id: true,
              content: true,
              sender: { select: { id: true, name: true } },
            },
          },
        },
      }),
      prisma.message.count({ where }),
    ]);

    return {
      messages: messages.reverse(), // Return in chronological order
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  },

  /**
   * Send a message in a conversation (REST endpoint version)
   */
  async sendMessage(
    userId: string,
    conversationId: string,
    data: { content: string; type?: string; mediaUrl?: string; replyToId?: string },
  ) {
    // Verify membership
    const membership = await prisma.conversationMember.findUnique({
      where: {
        conversationId_userId: { conversationId, userId },
      },
    });

    if (!membership) {
      throw ApiError.forbidden('Not a member of this conversation');
    }

    const message = await prisma.message.create({
      data: {
        conversationId,
        senderId: userId,
        content: data.content,
        type: (data.type as any) || 'TEXT',
        mediaUrl: data.mediaUrl,
        replyToId: data.replyToId,
      },
      include: {
        sender: {
          select: { id: true, name: true, avatarUrl: true },
        },
        replyTo: {
          select: {
            id: true,
            content: true,
            sender: { select: { id: true, name: true } },
          },
        },
      },
    });

    // Update conversation lastMessageAt
    await prisma.conversation.update({
      where: { id: conversationId },
      data: { lastMessageAt: new Date() },
    });

    // Send push notification to other members
    const otherMembers = await prisma.conversationMember.findMany({
      where: {
        conversationId,
        userId: { not: userId },
        isMuted: false,
      },
      select: { userId: true },
    });

    const senderName = message.sender.name;
    for (const member of otherMembers) {
      // Emit via socket
      emitToUser(member.userId, 'chat:message', { message, conversationId });

      // Send push notification
      await notificationService.sendToUser(member.userId, {
        type: 'CHAT',
        title: senderName,
        body: data.content.length > 100 ? data.content.substring(0, 100) + '…' : data.content,
        data: {
          entityId: conversationId,
          entityType: 'conversation',
          deepLink: `churchapp://chat/${conversationId}`,
        },
      });
    }

    return message;
  },

  /**
   * Mark conversation as read
   */
  async markAsRead(userId: string, conversationId: string) {
    return prisma.conversationMember.update({
      where: {
        conversationId_userId: { conversationId, userId },
      },
      data: { lastReadAt: new Date() },
    });
  },

  /**
   * Toggle pin on a conversation
   */
  async togglePin(userId: string, conversationId: string) {
    const membership = await prisma.conversationMember.findUnique({
      where: {
        conversationId_userId: { conversationId, userId },
      },
    });

    if (!membership) {
      throw ApiError.notFound('Conversation not found');
    }

    return prisma.conversationMember.update({
      where: {
        conversationId_userId: { conversationId, userId },
      },
      data: { isPinned: !membership.isPinned },
    });
  },

  /**
   * Toggle mute on a conversation
   */
  async toggleMute(userId: string, conversationId: string) {
    const membership = await prisma.conversationMember.findUnique({
      where: {
        conversationId_userId: { conversationId, userId },
      },
    });

    if (!membership) {
      throw ApiError.notFound('Conversation not found');
    }

    return prisma.conversationMember.update({
      where: {
        conversationId_userId: { conversationId, userId },
      },
      data: { isMuted: !membership.isMuted },
    });
  },
};
