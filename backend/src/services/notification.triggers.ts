// ═══════════════════════════════════════════════════════════════
// Push Notification Triggers
// All notification triggers for all modules, wired to the central
// notification service. Import and call from service methods.
// ═══════════════════════════════════════════════════════════════

import { notificationService } from './notification.service';
import prisma from '../config/database';
import { logger } from '../utils/logger';
import env from '../config/env';

// ═══════════════════════════════════════════════════════════════
// EVENTS (Phase 2)
// ═══════════════════════════════════════════════════════════════

export async function notifyEventRegistration(
  userId: string,
  eventId: string,
  status: 'REGISTERED' | 'WAITLISTED',
): Promise<void> {
  try {
    const event = await prisma.event.findUnique({
      where: { id: eventId },
      select: { title: true, startDate: true },
    });
    if (!event) return;

    const statusText = status === 'REGISTERED' ? 'confirmed' : 'waitlisted';
    await notificationService.sendToUser(userId, {
      type: 'EVENT',
      title: `Registration ${statusText}`,
      body: `You've been ${statusText} for "${event.title}"`,
      data: {
        entityId: eventId,
        entityType: 'event',
        deepLink: `${env.deepLinkScheme}://events/${eventId}`,
      },
    });
  } catch (error) {
    logger.error('notifyEventRegistration failed:', error);
  }
}

export async function notifyEventReminder(
  eventId: string,
  timeframe: string,
): Promise<void> {
  try {
    const event = await prisma.event.findUnique({
      where: { id: eventId },
      select: { title: true, churchId: true, startDate: true, location: true },
    });
    if (!event) return;

    const registrations = await prisma.eventRegistration.findMany({
      where: { eventId, status: 'REGISTERED' },
      select: { userId: true },
    });

    const userIds = registrations.map((r) => r.userId);
    await notificationService.sendToUsers(userIds, {
      type: 'EVENT',
      title: `Event Reminder (${timeframe})`,
      body: `"${event.title}" starts ${timeframe}${event.location ? ` at ${event.location}` : ''}`,
      data: {
        entityId: eventId,
        entityType: 'event',
        deepLink: `${env.deepLinkScheme}://events/${eventId}`,
      },
    });
  } catch (error) {
    logger.error('notifyEventReminder failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// GIVING (Phase 3)
// ═══════════════════════════════════════════════════════════════

export async function notifyDonationSuccess(
  userId: string,
  amount: number,
  currency: string,
  categoryName?: string,
  donationId?: string,
): Promise<void> {
  try {
    const target = categoryName ? ` to ${categoryName}` : '';
    await notificationService.sendToUser(userId, {
      type: 'GIVING',
      title: 'Donation Received 🎉',
      body: `Your ${currency} ${amount.toLocaleString()} donation${target} has been processed successfully. Thank you!`,
      data: {
        entityId: donationId || '',
        entityType: 'donation',
        deepLink: `${env.deepLinkScheme}://giving/history`,
      },
    });
  } catch (error) {
    logger.error('notifyDonationSuccess failed:', error);
  }
}

export async function notifyDonationFailed(
  userId: string,
  amount: number,
  currency: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'GIVING',
      title: 'Donation Failed',
      body: `Your ${currency} ${amount.toLocaleString()} donation could not be processed. Please try again.`,
      data: {
        entityType: 'donation',
        deepLink: `${env.deepLinkScheme}://giving`,
      },
    });
  } catch (error) {
    logger.error('notifyDonationFailed failed:', error);
  }
}

export async function notifyPledgeCreated(
  userId: string,
  pledgeTitle: string,
  totalAmount: number,
  pledgeId: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'GIVING',
      title: 'Pledge Created',
      body: `Your pledge "${pledgeTitle}" for ${totalAmount.toLocaleString()} has been created.`,
      data: {
        entityId: pledgeId,
        entityType: 'pledge',
        deepLink: `${env.deepLinkScheme}://giving/pledges`,
      },
    });
  } catch (error) {
    logger.error('notifyPledgeCreated failed:', error);
  }
}

export async function notifyPledgePayment(
  userId: string,
  pledgeTitle: string,
  amountPaid: number,
  remainingAmount: number,
): Promise<void> {
  try {
    const body = remainingAmount <= 0
      ? `Your pledge "${pledgeTitle}" is now fully paid! 🎉`
      : `Payment of ${amountPaid.toLocaleString()} recorded for "${pledgeTitle}". Remaining: ${remainingAmount.toLocaleString()}`;

    await notificationService.sendToUser(userId, {
      type: 'GIVING',
      title: remainingAmount <= 0 ? 'Pledge Completed! 🎉' : 'Pledge Payment Recorded',
      body,
      data: {
        entityType: 'pledge',
        deepLink: `${env.deepLinkScheme}://giving/pledges`,
      },
    });
  } catch (error) {
    logger.error('notifyPledgePayment failed:', error);
  }
}

export async function notifyRecurringSetup(
  userId: string,
  amount: number,
  currency: string,
  frequency: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'GIVING',
      title: 'Recurring Giving Setup ✅',
      body: `Your ${frequency.toLowerCase()} recurring donation of ${currency} ${amount.toLocaleString()} has been set up.`,
      data: {
        entityType: 'recurring',
        deepLink: `${env.deepLinkScheme}://giving/recurring`,
      },
    });
  } catch (error) {
    logger.error('notifyRecurringSetup failed:', error);
  }
}

export async function notifyRecurringCancelled(
  userId: string,
  amount: number,
  currency: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'GIVING',
      title: 'Recurring Giving Cancelled',
      body: `Your recurring donation of ${currency} ${amount.toLocaleString()} has been cancelled.`,
      data: {
        entityType: 'recurring',
        deepLink: `${env.deepLinkScheme}://giving/recurring`,
      },
    });
  } catch (error) {
    logger.error('notifyRecurringCancelled failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// GROUPS (Phase 4)
// ═══════════════════════════════════════════════════════════════

export async function notifyGroupJoin(
  groupId: string,
  userId: string,
): Promise<void> {
  try {
    const [group, user] = await Promise.all([
      prisma.connectGroup.findUnique({
        where: { id: groupId },
        select: { name: true, leaderId: true },
      }),
      prisma.user.findUnique({
        where: { id: userId },
        select: { name: true },
      }),
    ]);
    if (!group || !user) return;

    // Notify group leader
    if (group.leaderId && group.leaderId !== userId) {
      await notificationService.sendToUser(group.leaderId, {
        type: 'GROUP',
        title: 'New Group Member',
        body: `${user.name} joined "${group.name}"`,
        data: {
          entityId: groupId,
          entityType: 'group',
          deepLink: `${env.deepLinkScheme}://groups/${groupId}`,
        },
      });
    }
  } catch (error) {
    logger.error('notifyGroupJoin failed:', error);
  }
}

export async function notifyGroupLeave(
  groupId: string,
  userId: string,
): Promise<void> {
  try {
    const [group, user] = await Promise.all([
      prisma.connectGroup.findUnique({
        where: { id: groupId },
        select: { name: true, leaderId: true },
      }),
      prisma.user.findUnique({
        where: { id: userId },
        select: { name: true },
      }),
    ]);
    if (!group || !user) return;

    if (group.leaderId && group.leaderId !== userId) {
      await notificationService.sendToUser(group.leaderId, {
        type: 'GROUP',
        title: 'Member Left Group',
        body: `${user.name} left "${group.name}"`,
        data: {
          entityId: groupId,
          entityType: 'group',
          deepLink: `${env.deepLinkScheme}://groups/${groupId}`,
        },
      });
    }
  } catch (error) {
    logger.error('notifyGroupLeave failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// ANNOUNCEMENTS (Phase 4)
// ═══════════════════════════════════════════════════════════════

export async function notifyNewAnnouncement(
  churchId: string,
  announcementId: string,
  title: string,
  isUrgent: boolean,
): Promise<void> {
  try {
    await notificationService.sendToChurch(churchId, {
      type: 'ANNOUNCEMENT',
      title: isUrgent ? '🚨 Urgent Announcement' : '📢 New Announcement',
      body: title,
      data: {
        entityId: announcementId,
        entityType: 'announcement',
        deepLink: `${env.deepLinkScheme}://announcements/${announcementId}`,
      },
    });
  } catch (error) {
    logger.error('notifyNewAnnouncement failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// TESTIMONIES (Phase 4)
// ═══════════════════════════════════════════════════════════════

export async function notifyTestimonyReaction(
  testimonyId: string,
  reactorId: string,
  reactionType: string,
): Promise<void> {
  try {
    const [testimony, reactor] = await Promise.all([
      prisma.testimony.findUnique({
        where: { id: testimonyId },
        select: { userId: true, title: true },
      }),
      prisma.user.findUnique({
        where: { id: reactorId },
        select: { name: true },
      }),
    ]);
    if (!testimony || !reactor) return;

    // Don't notify yourself
    if (testimony.userId === reactorId) return;

    const actionText = reactionType === 'LIKE' ? 'liked' : 'prayed for';
    await notificationService.sendToUser(testimony.userId, {
      type: 'PERSONAL',
      title: 'Testimony Reaction',
      body: `${reactor.name} ${actionText} your testimony "${testimony.title}"`,
      data: {
        entityId: testimonyId,
        entityType: 'testimony',
        deepLink: `${env.deepLinkScheme}://testimonies`,
      },
    });
  } catch (error) {
    logger.error('notifyTestimonyReaction failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// FORUM (Phase 4)
// ═══════════════════════════════════════════════════════════════

export async function notifyForumReply(
  threadId: string,
  replyAuthorId: string,
): Promise<void> {
  try {
    const [thread, replyAuthor] = await Promise.all([
      prisma.forumThread.findUnique({
        where: { id: threadId },
        select: { authorId: true, title: true },
      }),
      prisma.user.findUnique({
        where: { id: replyAuthorId },
        select: { name: true },
      }),
    ]);
    if (!thread || !replyAuthor) return;

    // Notify thread author (if not the replier)
    if (thread.authorId !== replyAuthorId) {
      await notificationService.sendToUser(thread.authorId, {
        type: 'FORUM',
        title: 'New Reply to Your Thread',
        body: `${replyAuthor.name} replied to "${thread.title}"`,
        data: {
          entityId: threadId,
          entityType: 'thread',
          deepLink: `${env.deepLinkScheme}://forum/threads/${threadId}`,
        },
      });
    }

    // Notify bookmarkers (excluding author and replier)
    const bookmarkers = await prisma.forumBookmark.findMany({
      where: {
        threadId,
        userId: { notIn: [thread.authorId, replyAuthorId] },
      },
      select: { userId: true },
    });

    if (bookmarkers.length > 0) {
      const userIds = bookmarkers.map((b) => b.userId);
      await notificationService.sendToUsers(userIds, {
        type: 'FORUM',
        title: 'New Reply in Bookmarked Thread',
        body: `${replyAuthor.name} replied to "${thread.title}"`,
        data: {
          entityId: threadId,
          entityType: 'thread',
          deepLink: `${env.deepLinkScheme}://forum/threads/${threadId}`,
        },
      });
    }
  } catch (error) {
    logger.error('notifyForumReply failed:', error);
  }
}

export async function notifyForumThreadLike(
  threadId: string,
  likerId: string,
): Promise<void> {
  try {
    const [thread, liker] = await Promise.all([
      prisma.forumThread.findUnique({
        where: { id: threadId },
        select: { authorId: true, title: true },
      }),
      prisma.user.findUnique({
        where: { id: likerId },
        select: { name: true },
      }),
    ]);
    if (!thread || !liker) return;

    if (thread.authorId !== likerId) {
      await notificationService.sendToUser(thread.authorId, {
        type: 'FORUM',
        title: 'Thread Liked',
        body: `${liker.name} liked your thread "${thread.title}"`,
        data: {
          entityId: threadId,
          entityType: 'thread',
          deepLink: `${env.deepLinkScheme}://forum/threads/${threadId}`,
        },
      });
    }
  } catch (error) {
    logger.error('notifyForumThreadLike failed:', error);
  }
}

export async function notifyForumReplyLike(
  replyId: string,
  likerId: string,
): Promise<void> {
  try {
    const [reply, liker] = await Promise.all([
      prisma.forumReply.findUnique({
        where: { id: replyId },
        select: { authorId: true, threadId: true, content: true },
      }),
      prisma.user.findUnique({
        where: { id: likerId },
        select: { name: true },
      }),
    ]);
    if (!reply || !liker) return;

    if (reply.authorId !== likerId) {
      await notificationService.sendToUser(reply.authorId, {
        type: 'FORUM',
        title: 'Reply Liked',
        body: `${liker.name} liked your reply: "${reply.content.substring(0, 80)}…"`,
        data: {
          entityId: reply.threadId,
          entityType: 'thread',
          deepLink: `${env.deepLinkScheme}://forum/threads/${reply.threadId}`,
        },
      });
    }
  } catch (error) {
    logger.error('notifyForumReplyLike failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// PRAYER REQUESTS (Phase 4)
// ═══════════════════════════════════════════════════════════════

export async function notifyPrayerInteraction(
  prayerRequestId: string,
  prayerId: string,
): Promise<void> {
  try {
    const [request, prayer] = await Promise.all([
      prisma.prayerRequest.findUnique({
        where: { id: prayerRequestId },
        select: { userId: true, title: true },
      }),
      prisma.user.findUnique({
        where: { id: prayerId },
        select: { name: true },
      }),
    ]);
    if (!request || !prayer) return;

    if (request.userId !== prayerId) {
      await notificationService.sendToUser(request.userId, {
        type: 'PRAYER',
        title: 'Someone Prayed for You 🙏',
        body: `${prayer.name} prayed for your request "${request.title}"`,
        data: {
          entityId: prayerRequestId,
          entityType: 'prayer',
          deepLink: `${env.deepLinkScheme}://prayer-requests`,
        },
      });
    }
  } catch (error) {
    logger.error('notifyPrayerInteraction failed:', error);
  }
}

export async function notifyPrayerAnswered(
  prayerRequestId: string,
): Promise<void> {
  try {
    const request = await prisma.prayerRequest.findUnique({
      where: { id: prayerRequestId },
      select: { title: true, userId: true },
    });
    if (!request) return;

    // Get all who prayed for this request
    const interactions = await prisma.prayerInteraction.findMany({
      where: { prayerRequestId, userId: { not: request.userId } },
      select: { userId: true },
    });

    const userIds = interactions.map((i) => i.userId);
    if (userIds.length > 0) {
      await notificationService.sendToUsers(userIds, {
        type: 'PRAYER',
        title: 'Prayer Answered! 🎉',
        body: `"${request.title}" has been marked as answered!`,
        data: {
          entityId: prayerRequestId,
          entityType: 'prayer',
          deepLink: `${env.deepLinkScheme}://prayer-requests`,
        },
      });
    }
  } catch (error) {
    logger.error('notifyPrayerAnswered failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// DEVOTIONALS (Phase 2)
// ═══════════════════════════════════════════════════════════════

export async function notifyDailyDevotional(
  churchId: string,
  devotionalId: string,
  title: string,
): Promise<void> {
  try {
    await notificationService.sendToChurch(churchId, {
      type: 'DEVOTIONAL',
      title: '📖 Daily Devotional',
      body: title,
      data: {
        entityId: devotionalId,
        entityType: 'devotional',
        deepLink: `${env.deepLinkScheme}://devotionals/today`,
      },
    });
  } catch (error) {
    logger.error('notifyDailyDevotional failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// LIVE SERVICE (Phase 5)
// ═══════════════════════════════════════════════════════════════

export async function notifyLiveServiceStarted(
  churchId: string,
  serviceId: string,
  title: string,
): Promise<void> {
  try {
    await notificationService.sendToChurch(churchId, {
      type: 'SYSTEM',
      title: '🔴 We\'re Live!',
      body: `"${title}" is now live. Join us!`,
      data: {
        entityId: serviceId,
        entityType: 'live',
        deepLink: `${env.deepLinkScheme}://live/${serviceId}`,
      },
    });
  } catch (error) {
    logger.error('notifyLiveServiceStarted failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// SECURITY (Phase 1)
// ═══════════════════════════════════════════════════════════════

export async function notifyPasswordChanged(userId: string): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'SECURITY',
      title: 'Password Changed',
      body: 'Your password was successfully changed. If this wasn\'t you, please contact support.',
      data: {
        entityType: 'security',
        deepLink: `${env.deepLinkScheme}://settings`,
      },
    });
  } catch (error) {
    logger.error('notifyPasswordChanged failed:', error);
  }
}

export async function notifyNewLogin(
  userId: string,
  deviceInfo?: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'SECURITY',
      title: 'New Login',
      body: `New login detected${deviceInfo ? ` from ${deviceInfo}` : ''}. If this wasn't you, please change your password.`,
      data: {
        entityType: 'security',
        deepLink: `${env.deepLinkScheme}://settings`,
      },
    });
  } catch (error) {
    logger.error('notifyNewLogin failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// KIDS CHECK-IN (Phase 6)
// ═══════════════════════════════════════════════════════════════

export async function notifyKidsCheckIn(
  parentId: string,
  childName: string,
  roomName: string,
  securityCode: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(parentId, {
      type: 'KIDS',
      title: 'Child Checked In',
      body: `${childName} has been checked into ${roomName}. Your security code is ${securityCode}.`,
      data: {
        entityType: 'kids-checkin',
        deepLink: `${env.deepLinkScheme}://kids`,
      },
    });
  } catch (error) {
    logger.error('notifyKidsCheckIn failed:', error);
  }
}

export async function notifyKidsCheckOut(
  parentId: string,
  childName: string,
  roomName: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(parentId, {
      type: 'KIDS',
      title: 'Child Checked Out',
      body: `${childName} has been checked out from ${roomName}.`,
      data: {
        entityType: 'kids-checkout',
        deepLink: `${env.deepLinkScheme}://kids`,
      },
    });
  } catch (error) {
    logger.error('notifyKidsCheckOut failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// VOLUNTEERING (Phase 6)
// ═══════════════════════════════════════════════════════════════

export async function notifyVolunteerSignupApproved(
  userId: string,
  opportunityTitle: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'VOLUNTEER',
      title: 'Volunteer Signup Confirmed',
      body: `Your signup for "${opportunityTitle}" has been confirmed.`,
      data: {
        entityType: 'volunteer',
        deepLink: `${env.deepLinkScheme}://volunteer`,
      },
    });
  } catch (error) {
    logger.error('notifyVolunteerSignupApproved failed:', error);
  }
}

export async function notifyVolunteerShiftReminder(
  userId: string,
  shiftDate: string,
  startTime: string,
  opportunityTitle: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'VOLUNTEER',
      title: 'Upcoming Volunteer Shift',
      body: `Reminder: You have a shift for "${opportunityTitle}" on ${shiftDate} at ${startTime}.`,
      data: {
        entityType: 'volunteer-shift',
        deepLink: `${env.deepLinkScheme}://volunteer/roster`,
      },
    });
  } catch (error) {
    logger.error('notifyVolunteerShiftReminder failed:', error);
  }
}

export async function notifyVolunteerShiftSwap(
  targetUserId: string,
  fromUserName: string,
  opportunityTitle: string,
  shiftDate: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(targetUserId, {
      type: 'VOLUNTEER',
      title: 'Shift Swap Received',
      body: `${fromUserName} has swapped their "${opportunityTitle}" shift on ${shiftDate} to you.`,
      data: {
        entityType: 'volunteer-swap',
        deepLink: `${env.deepLinkScheme}://volunteer/roster`,
      },
    });
  } catch (error) {
    logger.error('notifyVolunteerShiftSwap failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// Phase 7: Additional Triggers for Background Jobs
// ═══════════════════════════════════════════════════════════════

export async function notifyPledgeReminder(
  userId: string,
  pledgeId: string,
  remainingAmount: number,
): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'GIVING',
      title: 'Pledge Reminder',
      body: `You have a remaining pledge balance. Keep up the faithful giving! 🙏`,
      data: {
        entityId: pledgeId,
        entityType: 'pledge',
        deepLink: `${env.deepLinkScheme}://giving/pledges/${pledgeId}`,
      },
    });
  } catch (error) {
    logger.error('notifyPledgeReminder failed:', error);
  }
}

export async function notifyReadingPlanReminder(
  userId: string,
  planId: string,
): Promise<void> {
  try {
    const plan = await prisma.readingPlan.findUnique({
      where: { id: planId },
      select: { title: true },
    });
    if (!plan) return;

    await notificationService.sendToUser(userId, {
      type: 'DEVOTIONAL',
      title: 'Reading Plan Reminder',
      body: `Don't forget today's reading in "${plan.title}" 📖`,
      data: {
        entityId: planId,
        entityType: 'reading-plan',
        deepLink: `${env.deepLinkScheme}://bible/reading-plans/${planId}`,
      },
    });
  } catch (error) {
    logger.error('notifyReadingPlanReminder failed:', error);
  }
}

export async function notifyBirthdayAnniversary(
  userId: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'SYSTEM',
      title: 'Happy Anniversary! 🎉',
      body: `Today marks your anniversary with us. We're grateful for you!`,
      data: {
        entityType: 'anniversary',
        deepLink: `${env.deepLinkScheme}://profile`,
      },
    });
  } catch (error) {
    logger.error('notifyBirthdayAnniversary failed:', error);
  }
}

export async function notifyNewSermon(
  churchId: string,
  sermonId: string,
  sermonTitle: string,
): Promise<void> {
  try {
    const users = await prisma.user.findMany({
      where: { churchId, isActive: true },
      select: { id: true },
    });

    for (const user of users) {
      await notificationService.sendToUser(user.id, {
        type: 'SERMON',
        title: 'New Sermon Available 🎧',
        body: `"${sermonTitle}" is now available to watch.`,
        data: {
          entityId: sermonId,
          entityType: 'sermon',
          deepLink: `${env.deepLinkScheme}://sermons/${sermonId}`,
        },
      });
    }
  } catch (error) {
    logger.error('notifyNewSermon failed:', error);
  }
}

export async function notifyWelcome(
  userId: string,
  churchName: string,
): Promise<void> {
  try {
    await notificationService.sendToUser(userId, {
      type: 'SYSTEM',
      title: `Welcome to ${churchName}! 🙏`,
      body: `We're so glad you're here. Explore sermons, events, groups, and more.`,
      data: {
        entityType: 'welcome',
        deepLink: `${env.deepLinkScheme}://home`,
      },
    });
  } catch (error) {
    logger.error('notifyWelcome failed:', error);
  }
}

// ═══════════════════════════════════════════════════════════════
// Convenience namespace for use in job processors
// ═══════════════════════════════════════════════════════════════
export const notificationTriggers = {
  // Events
  onEventRegistration: notifyEventRegistration,
  onEventReminder24h: (userId: string, eventId: string) => notifyEventReminder(eventId, '24 hours'),
  onEventReminder1h: (userId: string, eventId: string) => notifyEventReminder(eventId, '1 hour'),

  // Giving
  onDonationSuccess: notifyDonationSuccess,
  onDonationFailed: notifyDonationFailed,
  onPledgeReminder: notifyPledgeReminder,

  // Devotionals
  onDailyVerse: notifyDailyDevotional,
  onReadingPlanReminder: notifyReadingPlanReminder,

  // Community
  onBirthdayAnniversary: notifyBirthdayAnniversary,
  onWelcome: notifyWelcome,
  onNewSermon: notifyNewSermon,

  // Volunteers
  onVolunteerShiftReminder: async (userId: string, shiftId: string) => {
    try {
      const shift = await prisma.rosterShift.findUnique({
        where: { id: shiftId },
        include: { opportunity: { select: { title: true } } },
      });
      if (!shift) return;
      await notifyVolunteerShiftReminder(userId, shift.date.toISOString().split('T')[0], shift.startTime, shift.opportunity.title);
    } catch (error) {
      logger.error('onVolunteerShiftReminder wrapper failed:', error);
    }
  },
};