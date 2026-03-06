import prisma from '../../config/database';
import { emailService } from '../../services/email.service';
import { ApiError } from '../../utils/apiError';
import { logger } from '../../utils/logger';
import type { ContactFormInput } from './church.validation';

export const churchService = {
  // ────────────────────────────────────────────────────
  // GET ABOUT (church info + core values)
  // ────────────────────────────────────────────────────
  async getAbout(churchId: string) {
    const church = await prisma.church.findUnique({
      where: { id: churchId },
      select: {
        id: true,
        name: true,
        tagline: true,
        mission: true,
        vision: true,
        phone: true,
        email: true,
        website: true,
        address: true,
        logoUrl: true,
        coverImageUrl: true,
        socialLinks: true,
      },
    });

    if (!church) throw ApiError.notFound('Church not found');

    const coreValues = await prisma.coreValue.findMany({
      where: { churchId },
      orderBy: { sortOrder: 'asc' },
      select: { id: true, title: true, description: true, iconUrl: true },
    });

    return { ...church, coreValues };
  },

  // ────────────────────────────────────────────────────
  // GET STAFF
  // ────────────────────────────────────────────────────
  async getStaff(churchId: string) {
    const staff = await prisma.staffMember.findMany({
      where: { churchId },
      orderBy: { sortOrder: 'asc' },
      select: {
        id: true,
        name: true,
        title: true,
        bio: true,
        imageUrl: true,
        email: true,
      },
    });

    return staff;
  },

  // ────────────────────────────────────────────────────
  // GET CAMPUSES (with service times)
  // ────────────────────────────────────────────────────
  async getCampuses(churchId: string) {
    const campuses = await prisma.campus.findMany({
      where: { churchId },
      orderBy: [{ isPrimary: 'desc' }, { name: 'asc' }],
      include: {
        serviceTimes: {
          select: { id: true, dayOfWeek: true, time: true, label: true },
        },
      },
    });

    return campuses;
  },

  // ────────────────────────────────────────────────────
  // GET FAQS
  // ────────────────────────────────────────────────────
  async getFAQs(churchId: string) {
    const faqs = await prisma.fAQ.findMany({
      where: { churchId },
      orderBy: { sortOrder: 'asc' },
      select: { id: true, question: true, answer: true, category: true },
    });

    return faqs;
  },

  // ────────────────────────────────────────────────────
  // SUBMIT CONTACT FORM
  // ────────────────────────────────────────────────────
  async submitContact(churchId: string, userId: string, input: ContactFormInput) {
    // Get church email for forwarding
    const church = await prisma.church.findUnique({
      where: { id: churchId },
      select: { email: true, name: true },
    });

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { name: true, email: true },
    });

    if (!church || !user) throw ApiError.notFound('Church or user not found');

    // Send email to church
    if (church.email) {
      await emailService.sendContactFormEmail(
        church.email,
        church.name,
        user.name,
        user.email,
        input.subject,
        input.message,
        input.category,
      ).catch((err) => {
        logger.error('Failed to send contact form email:', err);
      });
    }

    logger.info(`Contact form submitted by ${userId} to church ${churchId}`);
    return { message: 'Your message has been sent. We\'ll get back to you soon.' };
  },
};
