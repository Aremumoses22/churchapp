import env from '../config/env';
import { logger } from '../utils/logger';

// ────────────────────────────────────────────────────
// Email Service (SendGrid)
// In development, emails are logged to console instead
// ────────────────────────────────────────────────────

interface EmailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

/**
 * Send an email via SendGrid (or log in development)
 */
async function sendEmail(options: EmailOptions): Promise<boolean> {
  const { to, subject, html, text } = options;

  // In development, just log the email
  if (env.isDev || !env.sendgridApiKey) {
    logger.info('📧 Email (dev mode):', { to, subject });
    logger.debug('Email body:', { html: html.substring(0, 200) + '...' });
    return true;
  }

  try {
    // Dynamic import to avoid requiring SendGrid in dev
    const sgMail = await import('@sendgrid/mail');
    sgMail.default.setApiKey(env.sendgridApiKey);

    await sgMail.default.send({
      to,
      from: { email: env.emailFrom, name: env.appName },
      subject,
      html,
      text: text || html.replace(/<[^>]*>/g, ''),
    });

    logger.info(`📧 Email sent to ${to}: ${subject}`);
    return true;
  } catch (error) {
    logger.error('Failed to send email:', error);
    return false;
  }
}

// ── Pre-built email templates ─────────────────────────

export const emailService = {
  sendEmail,

  /**
   * Send email verification link
   */
  async sendVerificationEmail(to: string, name: string, token: string): Promise<boolean> {
    const verifyUrl = `${env.appUrl}/auth/verify-email?token=${token}`;
    return sendEmail({
      to,
      subject: `${env.appName} — Verify your email`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Welcome to ${env.appName}, ${name}! 🎉</h2>
          <p>Please verify your email address by clicking the button below:</p>
          <a href="${verifyUrl}" 
             style="display: inline-block; padding: 12px 24px; background: #6C63FF; 
                    color: white; text-decoration: none; border-radius: 8px; margin: 16px 0;">
            Verify Email
          </a>
          <p style="color: #666; font-size: 14px;">
            Or copy this link: <br>${verifyUrl}
          </p>
          <p style="color: #999; font-size: 12px;">
            This link expires in 24 hours. If you didn't create an account, ignore this email.
          </p>
        </div>
      `,
    });
  },

  /**
   * Send password reset link
   */
  async sendPasswordResetEmail(to: string, name: string, token: string): Promise<boolean> {
    const resetUrl = `${env.appUrl}/auth/reset-password?token=${token}`;
    return sendEmail({
      to,
      subject: `${env.appName} — Reset your password`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Password Reset Request</h2>
          <p>Hi ${name}, we received a request to reset your password.</p>
          <a href="${resetUrl}" 
             style="display: inline-block; padding: 12px 24px; background: #6C63FF; 
                    color: white; text-decoration: none; border-radius: 8px; margin: 16px 0;">
            Reset Password
          </a>
          <p style="color: #666; font-size: 14px;">
            Or copy this link: <br>${resetUrl}
          </p>
          <p style="color: #999; font-size: 12px;">
            This link expires in 1 hour. If you didn't request this, ignore this email.
          </p>
        </div>
      `,
    });
  },

  /**
   * Send welcome email after setup complete
   */
  async sendWelcomeEmail(to: string, name: string, churchName: string): Promise<boolean> {
    return sendEmail({
      to,
      subject: `Welcome to ${churchName}! 🙏`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Welcome, ${name}! 🎉</h2>
          <p>You've successfully joined <strong>${churchName}</strong> on ${env.appName}.</p>
          <p>Here's what you can do:</p>
          <ul>
            <li>🎧 Watch and listen to sermons</li>
            <li>📅 Register for upcoming events</li>
            <li>💰 Give tithes and offerings</li>
            <li>📖 Read daily devotionals</li>
            <li>🤝 Join connect groups</li>
            <li>🙏 Share prayer requests</li>
          </ul>
          <p>Open the app to get started!</p>
        </div>
      `,
    });
  },

  /**
   * Send contact form submission to church admin email
   */
  async sendContactFormEmail(
    churchEmail: string,
    churchName: string,
    userName: string,
    userEmail: string,
    subject: string,
    message: string,
    category: string,
  ): Promise<boolean> {
    return sendEmail({
      to: churchEmail,
      subject: `[${env.appName}] Contact Form: ${subject}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>New Contact Form Submission</h2>
          <p>A member has submitted a contact form through the ${env.appName} app.</p>
          <table style="width: 100%; border-collapse: collapse; margin: 16px 0;">
            <tr>
              <td style="padding: 8px; border-bottom: 1px solid #eee; font-weight: bold; width: 120px;">From:</td>
              <td style="padding: 8px; border-bottom: 1px solid #eee;">${userName} (${userEmail})</td>
            </tr>
            <tr>
              <td style="padding: 8px; border-bottom: 1px solid #eee; font-weight: bold;">Category:</td>
              <td style="padding: 8px; border-bottom: 1px solid #eee;">${category}</td>
            </tr>
            <tr>
              <td style="padding: 8px; border-bottom: 1px solid #eee; font-weight: bold;">Subject:</td>
              <td style="padding: 8px; border-bottom: 1px solid #eee;">${subject}</td>
            </tr>
          </table>
          <div style="background: #f9f9f9; padding: 16px; border-radius: 8px; margin: 16px 0;">
            <p style="margin: 0; white-space: pre-wrap;">${message}</p>
          </div>
          <p style="color: #999; font-size: 12px;">
            This message was sent from the ${churchName} app contact form.
            Reply directly to this email to respond to ${userName}.
          </p>
        </div>
      `,
    });
  },

  // ═══════════════════════════════════════════════════════════════
  // Phase 7: Additional Email Templates
  // ═══════════════════════════════════════════════════════════════

  /**
   * Send giving receipt email
   */
  async sendGivingReceiptEmail(
    to: string,
    name: string,
    amount: number,
    currency: string,
    category: string,
    churchName: string,
    receiptNumber: string,
  ): Promise<boolean> {
    const formattedAmount = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: currency || 'USD',
    }).format(amount);

    return sendEmail({
      to,
      subject: `${env.appName} — Giving Receipt #${receiptNumber}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Thank You for Your Generosity, ${name}! 🙏</h2>
          <p>Your gift to <strong>${churchName}</strong> has been received.</p>
          <table style="width: 100%; border-collapse: collapse; margin: 16px 0; background: #f9f9f9; border-radius: 8px;">
            <tr>
              <td style="padding: 12px 16px; font-weight: bold;">Amount:</td>
              <td style="padding: 12px 16px;">${formattedAmount}</td>
            </tr>
            <tr>
              <td style="padding: 12px 16px; border-top: 1px solid #eee; font-weight: bold;">Category:</td>
              <td style="padding: 12px 16px; border-top: 1px solid #eee;">${category}</td>
            </tr>
            <tr>
              <td style="padding: 12px 16px; border-top: 1px solid #eee; font-weight: bold;">Receipt #:</td>
              <td style="padding: 12px 16px; border-top: 1px solid #eee;">${receiptNumber}</td>
            </tr>
            <tr>
              <td style="padding: 12px 16px; border-top: 1px solid #eee; font-weight: bold;">Date:</td>
              <td style="padding: 12px 16px; border-top: 1px solid #eee;">${new Date().toLocaleDateString()}</td>
            </tr>
          </table>
          <p style="color: #666; font-size: 14px;">
            This receipt is for your records. Please keep it for tax purposes.
          </p>
        </div>
      `,
    });
  },

  /**
   * Send recurring donation summary email
   */
  async sendRecurringSummaryEmail(
    to: string,
    name: string,
    amount: number,
    currency: string,
    frequency: string,
    nextDate: Date,
  ): Promise<boolean> {
    const formattedAmount = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: currency || 'USD',
    }).format(amount);

    return sendEmail({
      to,
      subject: `${env.appName} — Recurring Donation Processed`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Recurring Donation Processed 💝</h2>
          <p>Hi ${name}, your ${frequency.toLowerCase()} recurring donation of <strong>${formattedAmount}</strong> has been processed.</p>
          <p>Your next donation is scheduled for <strong>${nextDate.toLocaleDateString()}</strong>.</p>
          <p style="color: #666; font-size: 14px;">
            You can manage your recurring donations in the app at any time.
          </p>
        </div>
      `,
    });
  },

  /**
   * Send event registration confirmation email
   */
  async sendEventRegistrationEmail(
    to: string,
    name: string,
    eventTitle: string,
    eventDate: Date,
    eventLocation: string,
  ): Promise<boolean> {
    return sendEmail({
      to,
      subject: `${env.appName} — Registration Confirmed: ${eventTitle}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>You're Registered! 🎉</h2>
          <p>Hi ${name}, you've successfully registered for:</p>
          <div style="background: #f9f9f9; padding: 16px; border-radius: 8px; margin: 16px 0;">
            <h3 style="margin: 0 0 8px;">${eventTitle}</h3>
            <p style="margin: 4px 0;">📅 ${eventDate.toLocaleDateString()} at ${eventDate.toLocaleTimeString()}</p>
            <p style="margin: 4px 0;">📍 ${eventLocation || 'TBA'}</p>
          </div>
          <p>We look forward to seeing you there!</p>
        </div>
      `,
    });
  },

  /**
   * Send pledge reminder email
   */
  async sendPledgeReminderEmail(
    to: string,
    name: string,
    campaignName: string,
    remainingAmount: number,
    currency: string,
    targetDate: Date | null,
  ): Promise<boolean> {
    const formattedRemaining = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: currency || 'USD',
    }).format(remainingAmount);

    return sendEmail({
      to,
      subject: `${env.appName} — Pledge Reminder: ${campaignName}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Pledge Reminder 🙏</h2>
          <p>Hi ${name}, this is a friendly reminder about your pledge to <strong>${campaignName}</strong>.</p>
          <div style="background: #f9f9f9; padding: 16px; border-radius: 8px; margin: 16px 0;">
            <p style="margin: 4px 0;">Remaining balance: <strong>${formattedRemaining}</strong></p>
            ${targetDate ? `<p style="margin: 4px 0;">Target date: <strong>${targetDate.toLocaleDateString()}</strong></p>` : ''}
          </div>
          <p>Every contribution matters. Thank you for your faithfulness!</p>
        </div>
      `,
    });
  },

  /**
   * Send volunteer shift reminder email
   */
  async sendVolunteerShiftEmail(
    to: string,
    name: string,
    opportunityTitle: string,
    department: string,
    shiftDate: Date,
    startTime: string,
    endTime: string,
  ): Promise<boolean> {
    return sendEmail({
      to,
      subject: `${env.appName} — Volunteer Shift Reminder`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Upcoming Volunteer Shift ⭐</h2>
          <p>Hi ${name}, you have an upcoming volunteer shift:</p>
          <div style="background: #f9f9f9; padding: 16px; border-radius: 8px; margin: 16px 0;">
            <h3 style="margin: 0 0 8px;">${opportunityTitle}</h3>
            <p style="margin: 4px 0;">🏢 Department: ${department}</p>
            <p style="margin: 4px 0;">📅 ${shiftDate.toLocaleDateString()}</p>
            <p style="margin: 4px 0;">🕐 ${startTime} — ${endTime}</p>
          </div>
          <p>Thank you for serving! If you can't make it, please let your team lead know.</p>
        </div>
      `,
    });
  },
};