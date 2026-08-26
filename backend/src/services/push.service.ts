import env from '../config/env';
import { logger } from '../utils/logger';

// ────────────────────────────────────────────────────
// Firebase Cloud Messaging (FCM) — Push Notification Service
// This is the ONLY Firebase service used in the app
// ────────────────────────────────────────────────────

let adminApp: FirebaseAdminApp | null = null;

type FirebaseAdminApp = import('firebase-admin').app.App;

/**
 * Initialize Firebase Admin SDK (lazy — only when first push is sent)
 */
async function getFirebaseAdmin(): Promise<FirebaseAdminApp> {
  if (adminApp) return adminApp;

  if (!env.fcmProjectId || !env.fcmPrivateKey || !env.fcmClientEmail) {
    throw new Error('FCM credentials not configured. Push notifications disabled.');
  }

  const admin = await import('firebase-admin');

  adminApp = admin.initializeApp({
    credential: admin.credential.cert({
      projectId: env.fcmProjectId,
      privateKey: env.fcmPrivateKey,
      clientEmail: env.fcmClientEmail,
    }),
  });

  logger.info('🔔 Firebase Admin initialized (FCM push only)');
  return adminApp;
}

interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;   // Custom data for deep linking
  imageUrl?: string;
}

/**
 * Push Notification Service
 */
export const pushService = {
  /**
   * Send push to a single device token
   */
  async sendToDevice(token: string, payload: PushPayload): Promise<boolean> {
    try {
      const app = await getFirebaseAdmin();
      const admin = await import('firebase-admin');
      const messaging = admin.messaging(app);

      await messaging.send({
        token,
        notification: {
          title: payload.title,
          body: payload.body,
          imageUrl: payload.imageUrl,
        },
        data: payload.data,
        android: {
          priority: 'high',
          notification: {
            channelId: 'high_importance_channel',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: payload.data?.badge ? parseInt(payload.data.badge) : undefined,
            },
          },
        },
      });

      return true;
    } catch (error: any) {
      // Token is invalid/expired — should be cleaned up
      if (error.code === 'messaging/registration-token-not-registered') {
        logger.warn(`Stale FCM token detected: ${token.substring(0, 20)}...`);
        return false;
      }
      logger.error('FCM send error:', error);
      return false;
    }
  },

  /**
   * Send push to multiple device tokens (batch, max 500 per call)
   */
  async sendToMultiple(tokens: string[], payload: PushPayload): Promise<string[]> {
    if (tokens.length === 0) return [];

    const failedTokens: string[] = [];

    try {
      const app = await getFirebaseAdmin();
      const admin = await import('firebase-admin');
      const messaging = admin.messaging(app);

      // Process in batches of 500 (FCM limit)
      const batchSize = 500;
      for (let i = 0; i < tokens.length; i += batchSize) {
        const batch = tokens.slice(i, i + batchSize);

        const messages = batch.map((token) => ({
          token,
          notification: {
            title: payload.title,
            body: payload.body,
            imageUrl: payload.imageUrl,
          },
          data: payload.data,
          android: {
            priority: 'high' as const,
            notification: {
              channelId: 'high_importance_channel',
              sound: 'default',
            },
          },
          apns: {
            payload: {
              aps: { sound: 'default' },
            },
          },
        }));

        const response = await messaging.sendEach(messages);

        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(batch[idx]);
          }
        });
      }
    } catch (error) {
      logger.error('FCM batch send error:', error);
    }

    if (failedTokens.length > 0) {
      logger.warn(`FCM: ${failedTokens.length} failed tokens out of ${tokens.length}`);
    }

    return failedTokens;
  },

  /**
   * Subscribe tokens to a topic (for bulk messaging)
   */
  async subscribeToTopic(tokens: string[], topic: string): Promise<void> {
    try {
      const app = await getFirebaseAdmin();
      const admin = await import('firebase-admin');
      const messaging = admin.messaging(app);
      await messaging.subscribeToTopic(tokens, topic);
      logger.debug(`Subscribed ${tokens.length} tokens to topic: ${topic}`);
    } catch (error) {
      logger.error('FCM topic subscribe error:', error);
    }
  },

  /**
   * Send push to a topic (all subscribers)
   */
  async sendToTopic(topic: string, payload: PushPayload): Promise<boolean> {
    try {
      const app = await getFirebaseAdmin();
      const admin = await import('firebase-admin');
      const messaging = admin.messaging(app);

      await messaging.send({
        topic,
        notification: {
          title: payload.title,
          body: payload.body,
          imageUrl: payload.imageUrl,
        },
        data: payload.data,
      });

      logger.info(`Push sent to topic: ${topic}`);
      return true;
    } catch (error) {
      logger.error('FCM topic send error:', error);
      return false;
    }
  },
};
