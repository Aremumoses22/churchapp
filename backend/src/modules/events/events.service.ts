import prisma from '../../config/database';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import type { ListEventsInput } from './events.validation';
import { notifyEventRegistration } from '../../services/notification.triggers';

export const eventsService = {
  // ────────────────────────────────────────────────────
  // LIST EVENTS (paginated, filtered)
  // ────────────────────────────────────────────────────
  async list(churchId: string, input: ListEventsInput) {
    const { page, limit, category, upcoming, search } = input;
    const skip = (page - 1) * limit;
    const now = new Date();

    const where: any = { churchId };

    if (category) where.category = category;
    if (upcoming) {
      where.startDate = { gte: now };
    } else {
      where.startDate = { lt: now };
    }
    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [events, total] = await Promise.all([
      prisma.event.findMany({
        where,
        skip,
        take: limit,
        orderBy: upcoming ? { startDate: 'asc' } : { startDate: 'desc' },
        include: {
          speakers: { orderBy: { sortOrder: 'asc' } },
          _count: { select: { registrations: true } },
        },
      }),
      prisma.event.count({ where }),
    ]);

    return { events, total, page, limit };
  },

  // ────────────────────────────────────────────────────
  // GET FEATURED EVENTS
  // ────────────────────────────────────────────────────
  async getFeatured(churchId: string) {
    const events = await prisma.event.findMany({
      where: {
        churchId,
        isFeatured: true,
        startDate: { gte: new Date() },
      },
      orderBy: { startDate: 'asc' },
      take: 5,
      include: {
        speakers: { orderBy: { sortOrder: 'asc' } },
      },
    });

    return events;
  },

  // ────────────────────────────────────────────────────
  // GET EVENT BY ID
  // ────────────────────────────────────────────────────
  async getById(eventId: string, userId?: string) {
    const event = await prisma.event.findUnique({
      where: { id: eventId },
      include: {
        speakers: { orderBy: { sortOrder: 'asc' } },
      },
    });

    if (!event) throw ApiError.notFound('Event not found');

    // Check user's registration status if authenticated
    let isRegistered = false;
    let registrationStatus = null;

    if (userId) {
      const registration = await prisma.eventRegistration.findUnique({
        where: { userId_eventId: { userId, eventId } },
      });
      if (registration) {
        isRegistered = true;
        registrationStatus = registration.status;
      }
    }

    return { ...event, isRegistered, registrationStatus };
  },

  // ────────────────────────────────────────────────────
  // REGISTER FOR EVENT
  // ────────────────────────────────────────────────────
  async register(userId: string, eventId: string) {
    const event = await prisma.event.findUnique({ where: { id: eventId } });
    if (!event) throw ApiError.notFound('Event not found');

    if (!event.registrationRequired) {
      throw ApiError.badRequest('This event does not require registration');
    }

    // Check existing registration
    const existing = await prisma.eventRegistration.findUnique({
      where: { userId_eventId: { userId, eventId } },
    });

    if (existing && existing.status === 'REGISTERED') {
      throw ApiError.conflict('Already registered for this event');
    }

    // Check capacity
    let status: 'REGISTERED' | 'WAITLISTED' = 'REGISTERED';
    if (event.maxCapacity && event.registeredCount >= event.maxCapacity) {
      status = 'WAITLISTED';
    }

    // Create or update registration
    const registration = await prisma.eventRegistration.upsert({
      where: { userId_eventId: { userId, eventId } },
      update: { status, registeredAt: new Date() },
      create: { userId, eventId, status },
    });

    // Update registered count if newly registered
    if (status === 'REGISTERED') {
      await prisma.event.update({
        where: { id: eventId },
        data: { registeredCount: { increment: 1 } },
      });
    }

    logger.info(`User ${userId} registered for event ${eventId} (${status})`);

    // Fire notification trigger (non-blocking)
    notifyEventRegistration(userId, eventId, status).catch(() => {});

    return { registration, status };
  },

  // ────────────────────────────────────────────────────
  // CANCEL REGISTRATION
  // ────────────────────────────────────────────────────
  async cancelRegistration(userId: string, eventId: string) {
    const registration = await prisma.eventRegistration.findUnique({
      where: { userId_eventId: { userId, eventId } },
    });

    if (!registration) throw ApiError.notFound('Registration not found');

    const wasRegistered = registration.status === 'REGISTERED';

    await prisma.eventRegistration.update({
      where: { userId_eventId: { userId, eventId } },
      data: { status: 'CANCELLED' },
    });

    // Decrement registered count
    if (wasRegistered) {
      await prisma.event.update({
        where: { id: eventId },
        data: { registeredCount: { decrement: 1 } },
      });
    }

    logger.info(`User ${userId} cancelled registration for event ${eventId}`);
    return { message: 'Registration cancelled' };
  },

  // ────────────────────────────────────────────────────
  // GET MY REGISTERED EVENTS
  // ────────────────────────────────────────────────────
  async getMyEvents(userId: string) {
    const registrations = await prisma.eventRegistration.findMany({
      where: {
        userId,
        status: { not: 'CANCELLED' },
      },
      orderBy: { registeredAt: 'desc' },
      include: {
        event: {
          include: {
            speakers: { orderBy: { sortOrder: 'asc' } },
          },
        },
      },
    });

    return registrations.map((r) => ({
      ...r.event,
      registrationStatus: r.status,
      registeredAt: r.registeredAt,
    }));
  },
};
