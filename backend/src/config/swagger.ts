import swaggerJsdoc from 'swagger-jsdoc';
import env from './env';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.3',
    info: {
      title: 'Church App API',
      version: '1.0.0',
      description:
        'Complete REST API for the Church App mobile application. ' +
        'Covers authentication, content, giving, community, real-time features, ' +
        'volunteering, kids check-in, media, attendance, milestones, and more.',
      contact: { name: 'Church App Team' },
    },
    servers: [
      {
        url: `http://localhost:${env.port}/api/${env.apiVersion}`,
        description: 'Local development',
      },
    ],

    // ── Reusable components ─────────────────────────
    components: {
      securitySchemes: {
        BearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Enter your access token from POST /auth/login',
        },
      },

      schemas: {
        // ── Standard response wrappers ──────────────
        SuccessResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
            message: { type: 'string', example: 'Success' },
            data: { type: 'object' },
          },
        },
        PaginatedResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
            message: { type: 'string', example: 'Success' },
            data: { type: 'array', items: { type: 'object' } },
            meta: {
              type: 'object',
              properties: {
                page: { type: 'integer', example: 1 },
                limit: { type: 'integer', example: 20 },
                total: { type: 'integer', example: 100 },
                totalPages: { type: 'integer', example: 5 },
              },
            },
          },
        },
        ErrorResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string', example: 'Validation failed' },
            errors: { type: 'object' },
          },
        },

        // ── Auth schemas ────────────────────────────
        RegisterInput: {
          type: 'object',
          required: ['name', 'email', 'password'],
          properties: {
            name: { type: 'string', minLength: 2, maxLength: 255, example: 'John Doe' },
            email: { type: 'string', format: 'email', example: 'john@example.com' },
            password: {
              type: 'string',
              minLength: 8,
              maxLength: 128,
              example: 'Member@123',
              description: 'Min 8 chars, ≥1 uppercase, ≥1 lowercase, ≥1 digit',
            },
          },
        },
        LoginInput: {
          type: 'object',
          required: ['email', 'password'],
          properties: {
            email: { type: 'string', format: 'email', example: 'john@example.com' },
            password: { type: 'string', example: 'Member@123' },
          },
        },
        AuthTokens: {
          type: 'object',
          properties: {
            accessToken: { type: 'string' },
            refreshToken: { type: 'string' },
            user: {
              type: 'object',
              properties: {
                id: { type: 'string', format: 'uuid' },
                email: { type: 'string', format: 'email' },
                name: { type: 'string' },
                role: { type: 'string', enum: ['MEMBER', 'ADMIN', 'SUPER_ADMIN', 'PASTOR', 'LEADER'] },
                churchId: { type: 'string', format: 'uuid', nullable: true },
                avatarUrl: { type: 'string', nullable: true },
                hasCompletedSetup: { type: 'boolean' },
              },
            },
          },
        },
        ForgotPasswordInput: {
          type: 'object',
          required: ['email'],
          properties: {
            email: { type: 'string', format: 'email' },
          },
        },
        ResetPasswordInput: {
          type: 'object',
          required: ['token', 'password'],
          properties: {
            token: { type: 'string' },
            password: { type: 'string', minLength: 8 },
          },
        },
        RefreshTokenInput: {
          type: 'object',
          required: ['refreshToken'],
          properties: {
            refreshToken: { type: 'string' },
          },
        },
        VerifyChurchCodeInput: {
          type: 'object',
          required: ['code'],
          properties: {
            code: { type: 'string', minLength: 4, maxLength: 10 },
          },
        },
        CompleteSetupInput: {
          type: 'object',
          required: ['name'],
          properties: {
            name: { type: 'string', minLength: 2, maxLength: 255 },
            bio: { type: 'string', maxLength: 1000 },
            department: { type: 'string', maxLength: 100 },
          },
        },

        // ── User schemas ────────────────────────────
        UpdateProfileInput: {
          type: 'object',
          properties: {
            name: { type: 'string', minLength: 2, maxLength: 255 },
            phone: { type: 'string' },
            bio: { type: 'string', maxLength: 1000 },
            department: { type: 'string' },
            isDirectoryVisible: { type: 'boolean' },
          },
        },
        NotificationPrefsInput: {
          type: 'object',
          properties: {
            events: { type: 'boolean' },
            sermons: { type: 'boolean' },
            giving: { type: 'boolean' },
            prayer: { type: 'boolean' },
            community: { type: 'boolean' },
            chat: { type: 'boolean' },
            system: { type: 'boolean' },
          },
        },
        FcmTokenInput: {
          type: 'object',
          required: ['token'],
          properties: {
            token: { type: 'string' },
            platform: { type: 'string', enum: ['ios', 'android', 'web'] },
          },
        },

        // ── Giving schemas ──────────────────────────
        DonationInput: {
          type: 'object',
          required: ['amount', 'categoryId', 'paymentMethod'],
          properties: {
            amount: { type: 'number', minimum: 1 },
            categoryId: { type: 'string', format: 'uuid' },
            paymentMethod: { type: 'string', enum: ['CARD', 'BANK', 'MOBILE', 'WALLET'] },
            campaignId: { type: 'string', format: 'uuid' },
            isAnonymous: { type: 'boolean' },
            notes: { type: 'string' },
          },
        },
        PledgeInput: {
          type: 'object',
          required: ['campaignId', 'totalAmount'],
          properties: {
            campaignId: { type: 'string', format: 'uuid' },
            totalAmount: { type: 'number', minimum: 1 },
            endDate: { type: 'string', format: 'date' },
          },
        },
        RecurringDonationInput: {
          type: 'object',
          required: ['amount', 'categoryId', 'frequency', 'paymentMethodId'],
          properties: {
            amount: { type: 'number', minimum: 1 },
            categoryId: { type: 'string', format: 'uuid' },
            frequency: { type: 'string', enum: ['WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'ANNUALLY'] },
            paymentMethodId: { type: 'string', format: 'uuid' },
          },
        },

        // ── Attendance schemas ──────────────────────
        RecordAttendanceInput: {
          type: 'object',
          required: ['serviceDate', 'serviceType'],
          properties: {
            serviceDate: { type: 'string', format: 'date', example: '2026-02-26' },
            serviceType: { type: 'string', enum: ['SUNDAY', 'MIDWEEK', 'SPECIAL'] },
            checkinMethod: { type: 'string', enum: ['MANUAL', 'QR', 'GEOFENCE'], default: 'MANUAL' },
          },
        },

        // ── Milestone schemas ───────────────────────
        CreateMilestoneInput: {
          type: 'object',
          required: ['userId', 'type', 'title'],
          properties: {
            userId: { type: 'string', format: 'uuid' },
            type: {
              type: 'string',
              enum: ['SALVATION', 'BAPTISM', 'FIRST_SERVE', 'SMALL_GROUP', 'MINISTRY_LEADER', 'FIRST_GIVE', 'ONE_YEAR', 'INVITE_FRIEND'],
            },
            title: { type: 'string' },
            description: { type: 'string' },
          },
        },

        // ── Saved Item schemas ──────────────────────
        SaveItemInput: {
          type: 'object',
          required: ['entityType', 'entityId'],
          properties: {
            entityType: { type: 'string', enum: ['SERMON', 'EVENT', 'DEVOTIONAL', 'READING_PLAN'] },
            entityId: { type: 'string', format: 'uuid' },
          },
        },

        // ── Community schemas ───────────────────────
        TestimonyInput: {
          type: 'object',
          required: ['title', 'content'],
          properties: {
            title: { type: 'string' },
            content: { type: 'string' },
            isAnonymous: { type: 'boolean', default: false },
          },
        },
        TestimonyReactionInput: {
          type: 'object',
          required: ['type'],
          properties: {
            type: { type: 'string', enum: ['LIKE', 'PRAY'] },
          },
        },
        ContactInput: {
          type: 'object',
          required: ['subject', 'message'],
          properties: {
            subject: { type: 'string' },
            message: { type: 'string' },
          },
        },

        // ── Forum schemas ───────────────────────────
        CreateThreadInput: {
          type: 'object',
          required: ['categoryId', 'title', 'content'],
          properties: {
            categoryId: { type: 'string', format: 'uuid' },
            title: { type: 'string' },
            content: { type: 'string' },
          },
        },
        CreateReplyInput: {
          type: 'object',
          required: ['content'],
          properties: {
            content: { type: 'string' },
          },
        },

        // ── Prayer schemas ──────────────────────────
        PrayerRequestInput: {
          type: 'object',
          required: ['title', 'content'],
          properties: {
            title: { type: 'string' },
            content: { type: 'string' },
            isAnonymous: { type: 'boolean', default: false },
            isUrgent: { type: 'boolean', default: false },
          },
        },

        // ── Chat schemas ────────────────────────────
        CreateConversationInput: {
          type: 'object',
          required: ['type', 'memberIds'],
          properties: {
            type: { type: 'string', enum: ['DIRECT', 'GROUP'] },
            name: { type: 'string', description: 'Required for GROUP type' },
            memberIds: { type: 'array', items: { type: 'string', format: 'uuid' } },
          },
        },
        SendMessageInput: {
          type: 'object',
          required: ['content'],
          properties: {
            content: { type: 'string' },
            type: { type: 'string', enum: ['TEXT', 'IMAGE', 'VIDEO', 'AUDIO', 'FILE'], default: 'TEXT' },
            mediaUrl: { type: 'string', format: 'uri' },
            replyToId: { type: 'string', format: 'uuid' },
          },
        },

        // ── Kids schemas ────────────────────────────
        RegisterChildInput: {
          type: 'object',
          required: ['firstName', 'lastName', 'dateOfBirth'],
          properties: {
            firstName: { type: 'string' },
            lastName: { type: 'string' },
            dateOfBirth: { type: 'string', format: 'date' },
            allergies: { type: 'string' },
            medicalNotes: { type: 'string' },
          },
        },
        CheckinInput: {
          type: 'object',
          required: ['childId', 'roomId'],
          properties: {
            childId: { type: 'string', format: 'uuid' },
            roomId: { type: 'string', format: 'uuid' },
          },
        },
        CheckoutInput: {
          type: 'object',
          required: ['checkinId', 'securityCode'],
          properties: {
            checkinId: { type: 'string', format: 'uuid' },
            securityCode: { type: 'string' },
          },
        },

        // ── Volunteer schemas ───────────────────────
        VolunteerSignupInput: {
          type: 'object',
          required: ['opportunityId'],
          properties: {
            opportunityId: { type: 'string', format: 'uuid' },
          },
        },
        ShiftSwapInput: {
          type: 'object',
          required: ['targetUserId'],
          properties: {
            targetUserId: { type: 'string', format: 'uuid' },
          },
        },

        // ── Media schemas ───────────────────────────
        CreateAlbumInput: {
          type: 'object',
          required: ['title'],
          properties: {
            title: { type: 'string' },
            description: { type: 'string' },
            eventId: { type: 'string', format: 'uuid' },
          },
        },
        PodcastProgressInput: {
          type: 'object',
          required: ['position'],
          properties: {
            position: { type: 'number', description: 'Position in seconds' },
            completed: { type: 'boolean' },
          },
        },
      },

      // ── Common parameters ──────────────────────────
      parameters: {
        PageParam: {
          name: 'page',
          in: 'query',
          schema: { type: 'integer', default: 1, minimum: 1 },
          description: 'Page number',
        },
        LimitParam: {
          name: 'limit',
          in: 'query',
          schema: { type: 'integer', default: 20, minimum: 1, maximum: 100 },
          description: 'Items per page',
        },
        IdParam: {
          name: 'id',
          in: 'path',
          required: true,
          schema: { type: 'string', format: 'uuid' },
          description: 'Resource UUID',
        },
      },

      // ── Common responses ───────────────────────────
      responses: {
        Unauthorized: {
          description: 'Missing or invalid authentication token',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ErrorResponse' },
              example: { success: false, message: 'Missing or invalid authorization header' },
            },
          },
        },
        Forbidden: {
          description: 'Insufficient permissions',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ErrorResponse' },
              example: { success: false, message: 'Forbidden: insufficient role' },
            },
          },
        },
        NotFound: {
          description: 'Resource not found',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ErrorResponse' },
              example: { success: false, message: 'Resource not found' },
            },
          },
        },
        ValidationError: {
          description: 'Request body validation failed',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ErrorResponse' },
              example: { success: false, message: 'Validation failed', errors: { email: ['Invalid email address'] } },
            },
          },
        },
        RateLimited: {
          description: 'Too many requests',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ErrorResponse' },
              example: { success: false, message: 'Rate limit exceeded. Try again in 30 seconds.' },
            },
          },
        },
      },
    },

    // ── Tag groups ───────────────────────────────────
    tags: [
      { name: 'Health', description: 'Server health check' },
      { name: 'Auth', description: 'Registration, login, tokens, password reset' },
      { name: 'Users', description: 'User profile, avatar, preferences' },
      { name: 'Sermons', description: 'Sermons, series, progress, notes' },
      { name: 'Events', description: 'Events, registration, featured' },
      { name: 'Bible', description: 'Books, chapters, highlights, devotionals, reading plans' },
      { name: 'Church', description: 'Church info, staff, campuses, FAQs, contact' },
      { name: 'Home', description: 'Home feed aggregator' },
      { name: 'Giving', description: 'Donations, campaigns, pledges, recurring, payment methods, webhooks' },
      { name: 'Groups', description: 'Connect groups, join/leave' },
      { name: 'Community', description: 'Announcements, testimonies, directory, invites' },
      { name: 'Forum', description: 'Categories, threads, replies, likes, bookmarks' },
      { name: 'Prayer', description: 'Prayer requests, interactions' },
      { name: 'Chat', description: 'Conversations, messages, read receipts' },
      { name: 'Notifications', description: 'Push notifications, read/unread, preferences' },
      { name: 'Live', description: 'Live services, streaming, chat' },
      { name: 'Volunteer', description: 'Opportunities, signups, roster, shifts' },
      { name: 'Kids', description: 'Children, rooms, check-in/out' },
      { name: 'Media', description: 'Photo albums, podcasts, worship songs' },
      { name: 'Search', description: 'Global search, trending' },
      { name: 'Attendance', description: 'Service attendance tracking, streaks' },
      { name: 'Milestones', description: 'Spiritual journey milestones' },
      { name: 'Saved Items', description: 'Bookmarks across content types' },
    ],

    // ── Inline path definitions ──────────────────────
    // (Defined here instead of JSDoc comments for maintainability)
    paths: {
      // ═══════════════════════════════════════════════
      //  HEALTH
      // ═══════════════════════════════════════════════
      '/': {
        // Note: swagger-ui will show this under the server base URL
      },

      // ═══════════════════════════════════════════════
      //  AUTH
      // ═══════════════════════════════════════════════
      '/auth/register': {
        post: {
          tags: ['Auth'],
          summary: 'Register a new user',
          description: 'Creates a new account. Sends a verification email. Rate-limited: 10 req / 15 min (prod).',
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { $ref: '#/components/schemas/RegisterInput' } } },
          },
          responses: {
            201: { description: 'User registered', content: { 'application/json': { schema: { $ref: '#/components/schemas/SuccessResponse' } } } },
            400: { $ref: '#/components/responses/ValidationError' },
            409: { description: 'Email already registered' },
            429: { $ref: '#/components/responses/RateLimited' },
          },
        },
      },
      '/auth/login': {
        post: {
          tags: ['Auth'],
          summary: 'Login with email and password',
          description: 'Returns access + refresh JWT tokens. Rate-limited.',
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { $ref: '#/components/schemas/LoginInput' } } },
          },
          responses: {
            200: {
              description: 'Login successful',
              content: { 'application/json': { schema: { allOf: [{ $ref: '#/components/schemas/SuccessResponse' }, { properties: { data: { $ref: '#/components/schemas/AuthTokens' } } }] } } },
            },
            401: { description: 'Invalid credentials' },
            429: { $ref: '#/components/responses/RateLimited' },
          },
        },
      },
      '/auth/verify-email/{token}': {
        get: {
          tags: ['Auth'],
          summary: 'Verify email address',
          parameters: [{ name: 'token', in: 'path', required: true, schema: { type: 'string' } }],
          responses: { 200: { description: 'Email verified' }, 400: { description: 'Invalid or expired token' } },
        },
      },
      '/auth/resend-verification': {
        post: {
          tags: ['Auth'],
          summary: 'Resend verification email',
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/ForgotPasswordInput' } } } },
          responses: { 200: { description: 'Verification email sent' }, 429: { $ref: '#/components/responses/RateLimited' } },
        },
      },
      '/auth/forgot-password': {
        post: {
          tags: ['Auth'],
          summary: 'Request password reset email',
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/ForgotPasswordInput' } } } },
          responses: { 200: { description: 'Reset email sent (always returns 200)' }, 429: { $ref: '#/components/responses/RateLimited' } },
        },
      },
      '/auth/reset-password': {
        post: {
          tags: ['Auth'],
          summary: 'Reset password with token',
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/ResetPasswordInput' } } } },
          responses: { 200: { description: 'Password reset successful' }, 400: { description: 'Invalid or expired token' }, 429: { $ref: '#/components/responses/RateLimited' } },
        },
      },
      '/auth/refresh-token': {
        post: {
          tags: ['Auth'],
          summary: 'Refresh access token',
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/RefreshTokenInput' } } } },
          responses: { 200: { description: 'New token pair returned' }, 401: { description: 'Invalid refresh token' } },
        },
      },
      '/auth/verify-church-code': {
        post: {
          tags: ['Auth'],
          summary: 'Verify and join a church by code',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/VerifyChurchCodeInput' } } } },
          responses: { 200: { description: 'Church joined' }, 404: { description: 'Invalid church code' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },
      '/auth/complete-setup': {
        post: {
          tags: ['Auth'],
          summary: 'Complete account setup (name, bio, department)',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CompleteSetupInput' } } } },
          responses: { 200: { description: 'Setup completed' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },
      '/auth/logout': {
        post: {
          tags: ['Auth'],
          summary: 'Logout (clears refresh token)',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Logged out' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },
      '/auth/account': {
        delete: {
          tags: ['Auth'],
          summary: 'Delete user account',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Account deleted' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  USERS
      // ═══════════════════════════════════════════════
      '/users/me': {
        get: {
          tags: ['Users'],
          summary: 'Get current user profile',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'User profile' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
        put: {
          tags: ['Users'],
          summary: 'Update profile',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/UpdateProfileInput' } } } },
          responses: { 200: { description: 'Profile updated' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },
      '/users/me/avatar': {
        put: {
          tags: ['Users'],
          summary: 'Upload profile picture',
          security: [{ BearerAuth: [] }],
          requestBody: {
            required: true,
            content: { 'multipart/form-data': { schema: { type: 'object', properties: { avatar: { type: 'string', format: 'binary' } } } } },
          },
          responses: { 200: { description: 'Avatar updated with Cloudinary URL' }, 400: { description: 'Invalid file type or size' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },
      '/users/me/notification-prefs': {
        put: {
          tags: ['Users'],
          summary: 'Update notification preferences',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/NotificationPrefsInput' } } } },
          responses: { 200: { description: 'Preferences updated' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },
      '/users/me/fcm-token': {
        put: {
          tags: ['Users'],
          summary: 'Register or update FCM push token',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/FcmTokenInput' } } } },
          responses: { 200: { description: 'Token registered' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },
      '/users/me/attendance': {
        get: {
          tags: ['Users'],
          summary: 'Get user attendance history + streak',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Attendance data with streak' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },
      '/users/me/milestones': {
        get: {
          tags: ['Users'],
          summary: 'Get user spiritual journey milestones',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Milestones summary' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },
      '/users/me/saved-items': {
        get: {
          tags: ['Users'],
          summary: 'Get user saved/bookmarked items',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Saved items list' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
        post: {
          tags: ['Users'],
          summary: 'Save/bookmark an item',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/SaveItemInput' } } } },
          responses: { 201: { description: 'Item saved' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },
      '/users/me/saved-items/{id}': {
        delete: {
          tags: ['Users'],
          summary: 'Remove a saved item',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Item removed' }, 401: { $ref: '#/components/responses/Unauthorized' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  SERMONS
      // ═══════════════════════════════════════════════
      '/sermons': {
        get: {
          tags: ['Sermons'],
          summary: 'List sermons (paginated, filterable)',
          security: [{ BearerAuth: [] }],
          parameters: [
            { $ref: '#/components/parameters/PageParam' },
            { $ref: '#/components/parameters/LimitParam' },
            { name: 'seriesId', in: 'query', schema: { type: 'string', format: 'uuid' } },
            { name: 'search', in: 'query', schema: { type: 'string' } },
          ],
          responses: { 200: { description: 'Paginated sermons', content: { 'application/json': { schema: { $ref: '#/components/schemas/PaginatedResponse' } } } } },
        },
      },
      '/sermons/featured': {
        get: {
          tags: ['Sermons'],
          summary: 'Get featured sermons',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Featured sermons list' } },
        },
      },
      '/sermons/saved': {
        get: {
          tags: ['Sermons'],
          summary: 'Get user\'s saved sermons',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Saved sermons' } },
        },
      },
      '/sermons/{id}': {
        get: {
          tags: ['Sermons'],
          summary: 'Get sermon detail',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Sermon detail' }, 404: { $ref: '#/components/responses/NotFound' } },
        },
      },
      '/sermons/{id}/stream': {
        get: {
          tags: ['Sermons'],
          summary: 'Get streaming URL and increment play count',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Stream URL with playCount' } },
        },
      },
      '/sermons/{id}/progress': {
        post: {
          tags: ['Sermons'],
          summary: 'Save playback progress',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', properties: { position: { type: 'number' }, completed: { type: 'boolean' } } } } },
          },
          responses: { 200: { description: 'Progress saved' } },
        },
      },
      '/sermons/{id}/save': {
        post: {
          tags: ['Sermons'],
          summary: 'Toggle save/unsave sermon',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Toggled (saved/removed)' } },
        },
      },
      '/sermons/{id}/notes': {
        get: {
          tags: ['Sermons'],
          summary: 'Get user notes for a sermon',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'User notes' } },
        },
        put: {
          tags: ['Sermons'],
          summary: 'Save/update user notes for a sermon',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['content'], properties: { content: { type: 'string' } } } } },
          },
          responses: { 200: { description: 'Notes saved' } },
        },
      },
      '/sermons/series/all': {
        get: {
          tags: ['Sermons'],
          summary: 'List all sermon series',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'All series' } },
        },
      },
      '/sermons/series/{id}': {
        get: {
          tags: ['Sermons'],
          summary: 'Get series detail with sermons',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Series with sermons' }, 404: { $ref: '#/components/responses/NotFound' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  EVENTS
      // ═══════════════════════════════════════════════
      '/events': {
        get: {
          tags: ['Events'],
          summary: 'List events (paginated, filterable)',
          security: [{ BearerAuth: [] }],
          parameters: [
            { $ref: '#/components/parameters/PageParam' },
            { $ref: '#/components/parameters/LimitParam' },
            { name: 'upcoming', in: 'query', schema: { type: 'boolean' } },
            { name: 'category', in: 'query', schema: { type: 'string' } },
          ],
          responses: { 200: { description: 'Paginated events' } },
        },
      },
      '/events/featured': {
        get: {
          tags: ['Events'],
          summary: 'Get featured events',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Featured events' } },
        },
      },
      '/events/my': {
        get: {
          tags: ['Events'],
          summary: 'Get user\'s registered events',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Registered events' } },
        },
      },
      '/events/{id}': {
        get: {
          tags: ['Events'],
          summary: 'Get event detail',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Event detail with speakers' }, 404: { $ref: '#/components/responses/NotFound' } },
        },
      },
      '/events/{id}/register': {
        post: {
          tags: ['Events'],
          summary: 'Register for an event (RSVP)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Registered' }, 409: { description: 'Already registered' } },
        },
        delete: {
          tags: ['Events'],
          summary: 'Cancel event registration',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Registration cancelled' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  BIBLE
      // ═══════════════════════════════════════════════
      '/bible/books': {
        get: {
          tags: ['Bible'],
          summary: 'List all Bible books',
          responses: { 200: { description: 'All 66 books with testament and chapter count' } },
        },
      },
      '/bible/{bookId}/{chapter}': {
        get: {
          tags: ['Bible'],
          summary: 'Get Bible chapter with verses',
          security: [{ BearerAuth: [] }],
          parameters: [
            { name: 'bookId', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } },
            { name: 'chapter', in: 'path', required: true, schema: { type: 'integer' } },
          ],
          responses: { 200: { description: 'Chapter with verses and user highlights' } },
        },
      },
      '/bible/search': {
        get: {
          tags: ['Bible'],
          summary: 'Search Bible verses',
          parameters: [{ name: 'q', in: 'query', required: true, schema: { type: 'string' } }],
          responses: { 200: { description: 'Matching verses' } },
        },
      },
      '/bible/highlights': {
        get: {
          tags: ['Bible'],
          summary: 'Get user\'s verse highlights',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'All highlights' } },
        },
        post: {
          tags: ['Bible'],
          summary: 'Highlight a verse',
          security: [{ BearerAuth: [] }],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['verseId', 'color'], properties: { verseId: { type: 'string', format: 'uuid' }, color: { type: 'string' }, note: { type: 'string' } } } } },
          },
          responses: { 201: { description: 'Highlight created' } },
        },
      },
      '/bible/highlights/{id}': {
        delete: {
          tags: ['Bible'],
          summary: 'Remove a highlight',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Highlight removed' } },
        },
      },
      '/bible/devotionals/today': {
        get: {
          tags: ['Bible'],
          summary: 'Get today\'s devotional',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Today\'s devotional' }, 404: { description: 'No devotional for today' } },
        },
      },
      '/bible/devotionals/streak': {
        get: {
          tags: ['Bible'],
          summary: 'Get devotional reading streak',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Streak count and dates' } },
        },
      },
      '/bible/devotionals/{date}': {
        get: {
          tags: ['Bible'],
          summary: 'Get devotional by date',
          security: [{ BearerAuth: [] }],
          parameters: [{ name: 'date', in: 'path', required: true, schema: { type: 'string', format: 'date' }, example: '2026-02-26' }],
          responses: { 200: { description: 'Devotional for given date' } },
        },
      },
      '/bible/devotionals/{id}/read': {
        post: {
          tags: ['Bible'],
          summary: 'Mark devotional as read',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Marked as read' } },
        },
      },
      '/bible/reading-plans': {
        get: {
          tags: ['Bible'],
          summary: 'List available reading plans',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Reading plans list' } },
        },
      },
      '/bible/reading-plans/my': {
        get: {
          tags: ['Bible'],
          summary: 'Get user\'s enrolled reading plans',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'User reading plans with progress' } },
        },
      },
      '/bible/reading-plans/{id}': {
        get: {
          tags: ['Bible'],
          summary: 'Get reading plan detail with days',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Plan detail' }, 404: { $ref: '#/components/responses/NotFound' } },
        },
      },
      '/bible/reading-plans/{id}/enroll': {
        post: {
          tags: ['Bible'],
          summary: 'Enroll in a reading plan',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Enrolled' }, 409: { description: 'Already enrolled' } },
        },
      },
      '/bible/reading-plans/{id}/progress': {
        post: {
          tags: ['Bible'],
          summary: 'Mark a reading plan day as complete',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['day'], properties: { day: { type: 'integer' } } } } },
          },
          responses: { 200: { description: 'Day marked complete' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  CHURCH
      // ═══════════════════════════════════════════════
      '/church/about': {
        get: { tags: ['Church'], summary: 'Get church info', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Church details, service times, core values' } } },
      },
      '/church/staff': {
        get: { tags: ['Church'], summary: 'Get church staff list', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Staff members' } } },
      },
      '/church/campuses': {
        get: { tags: ['Church'], summary: 'Get church campuses', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Campus list' } } },
      },
      '/church/faqs': {
        get: { tags: ['Church'], summary: 'Get FAQs', security: [{ BearerAuth: [] }], responses: { 200: { description: 'FAQ list' } } },
      },
      '/church/contact': {
        post: {
          tags: ['Church'],
          summary: 'Submit contact form',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/ContactInput' } } } },
          responses: { 200: { description: 'Message sent' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  HOME
      // ═══════════════════════════════════════════════
      '/home/feed': {
        get: {
          tags: ['Home'],
          summary: 'Get personalized home feed',
          description: 'Aggregates sermons, events, devotionals, announcements, prayers, campaigns, reading plans, verse of the day.',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Aggregated home feed' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  GIVING
      // ═══════════════════════════════════════════════
      '/giving/categories': {
        get: { tags: ['Giving'], summary: 'List giving categories', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Categories (tithes, offerings, etc.)' } } },
      },
      '/giving/summary': {
        get: { tags: ['Giving'], summary: 'Get user giving summary (totals)', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Summary with totals and recent donations' } } },
      },
      '/giving/donate/paystack': {
        post: {
          tags: ['Giving'],
          summary: 'Initiate Paystack donation',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/DonationInput' } } } },
          responses: { 200: { description: 'Paystack authorization URL' } },
        },
      },
      '/giving/donate/stripe': {
        post: {
          tags: ['Giving'],
          summary: 'Initiate Stripe donation',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/DonationInput' } } } },
          responses: { 200: { description: 'Stripe client secret' } },
        },
      },
      '/giving/history': {
        get: {
          tags: ['Giving'],
          summary: 'Get donation history (paginated)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Paginated donation history' } },
        },
      },
      '/giving/history/{id}': {
        get: {
          tags: ['Giving'],
          summary: 'Get single donation detail',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Donation detail' }, 404: { $ref: '#/components/responses/NotFound' } },
        },
      },
      '/giving/receipts/{id}/download': {
        get: {
          tags: ['Giving'],
          summary: 'Download donation receipt (PDF)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'PDF download URL' }, 404: { $ref: '#/components/responses/NotFound' } },
        },
      },
      '/giving/payment-methods': {
        get: { tags: ['Giving'], summary: 'List saved payment methods', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Payment methods' } } },
        post: {
          tags: ['Giving'],
          summary: 'Add a payment method',
          security: [{ BearerAuth: [] }],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['type', 'last4', 'provider'], properties: { type: { type: 'string', enum: ['CARD', 'BANK'] }, last4: { type: 'string' }, provider: { type: 'string' }, expiryMonth: { type: 'integer' }, expiryYear: { type: 'integer' }, bankName: { type: 'string' }, isDefault: { type: 'boolean' } } } } },
          },
          responses: { 201: { description: 'Payment method added' } },
        },
      },
      '/giving/payment-methods/{id}': {
        delete: {
          tags: ['Giving'],
          summary: 'Remove a payment method',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Removed' } },
        },
      },
      '/giving/campaigns': {
        get: {
          tags: ['Giving'],
          summary: 'List giving campaigns',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Paginated campaigns' } },
        },
      },
      '/giving/campaigns/{id}': {
        get: {
          tags: ['Giving'],
          summary: 'Get campaign detail',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Campaign detail' }, 404: { $ref: '#/components/responses/NotFound' } },
        },
      },
      '/giving/pledges': {
        get: {
          tags: ['Giving'],
          summary: 'Get user pledges',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'User pledges' } },
        },
        post: {
          tags: ['Giving'],
          summary: 'Create a pledge',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/PledgeInput' } } } },
          responses: { 201: { description: 'Pledge created' } },
        },
      },
      '/giving/pledges/{id}/pay': {
        post: {
          tags: ['Giving'],
          summary: 'Make a pledge payment',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['amount', 'paymentMethod'], properties: { amount: { type: 'number' }, paymentMethod: { type: 'string', enum: ['CARD', 'BANK', 'MOBILE', 'WALLET'] } } } } },
          },
          responses: { 200: { description: 'Payment initiated' } },
        },
      },
      '/giving/pledges/{id}': {
        delete: {
          tags: ['Giving'],
          summary: 'Cancel a pledge',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Pledge cancelled' } },
        },
      },
      '/giving/recurring': {
        get: { tags: ['Giving'], summary: 'List recurring donations', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Recurring donations' } } },
        post: {
          tags: ['Giving'],
          summary: 'Set up recurring donation',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/RecurringDonationInput' } } } },
          responses: { 201: { description: 'Recurring donation created' } },
        },
      },
      '/giving/recurring/{id}': {
        put: {
          tags: ['Giving'],
          summary: 'Update recurring donation',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: { required: true, content: { 'application/json': { schema: { type: 'object', properties: { amount: { type: 'number' }, frequency: { type: 'string' }, isActive: { type: 'boolean' } } } } } },
          responses: { 200: { description: 'Updated' } },
        },
        delete: {
          tags: ['Giving'],
          summary: 'Cancel recurring donation',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Cancelled' } },
        },
      },
      '/giving/webhooks/paystack': {
        post: { tags: ['Giving'], summary: 'Paystack webhook (public)', description: 'Receives payment events from Paystack. Validates HMAC signature.', responses: { 200: { description: 'Processed' } } },
      },
      '/giving/webhooks/stripe': {
        post: { tags: ['Giving'], summary: 'Stripe webhook (public)', description: 'Receives payment events from Stripe. Validates webhook signature.', responses: { 200: { description: 'Processed' } } },
      },

      // ═══════════════════════════════════════════════
      //  GROUPS
      // ═══════════════════════════════════════════════
      '/groups': {
        get: {
          tags: ['Groups'],
          summary: 'List connect groups',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }, { name: 'category', in: 'query', schema: { type: 'string' } }],
          responses: { 200: { description: 'Paginated groups' } },
        },
      },
      '/groups/{id}': {
        get: {
          tags: ['Groups'],
          summary: 'Get group detail with members',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Group detail' }, 404: { $ref: '#/components/responses/NotFound' } },
        },
      },
      '/groups/{id}/join': {
        post: {
          tags: ['Groups'],
          summary: 'Join a group',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Joined' }, 409: { description: 'Already a member' } },
        },
      },
      '/groups/{id}/leave': {
        delete: {
          tags: ['Groups'],
          summary: 'Leave a group',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Left group' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  COMMUNITY
      // ═══════════════════════════════════════════════
      '/community/announcements': {
        get: {
          tags: ['Community'],
          summary: 'List announcements (active, not expired)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Announcements list' } },
        },
      },
      '/community/announcements/{id}': {
        get: {
          tags: ['Community'],
          summary: 'Get announcement detail',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Announcement detail' } },
        },
      },
      '/community/announcements/{id}/read': {
        post: {
          tags: ['Community'],
          summary: 'Mark announcement as read',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Marked as read' } },
        },
      },
      '/community/testimonies': {
        get: {
          tags: ['Community'],
          summary: 'List approved testimonies',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Testimonies list' } },
        },
        post: {
          tags: ['Community'],
          summary: 'Submit a testimony',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/TestimonyInput' } } } },
          responses: { 201: { description: 'Testimony submitted (pending approval)' } },
        },
      },
      '/community/testimonies/{id}/react': {
        post: {
          tags: ['Community'],
          summary: 'React to a testimony (like/pray toggle)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/TestimonyReactionInput' } } } },
          responses: { 200: { description: 'Reaction toggled' } },
        },
      },
      '/community/directory': {
        get: {
          tags: ['Community'],
          summary: 'Church member directory',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }, { name: 'search', in: 'query', schema: { type: 'string' } }],
          responses: { 200: { description: 'Directory members' } },
        },
      },
      '/community/invite/generate': {
        post: {
          tags: ['Community'],
          summary: 'Generate invite link code',
          security: [{ BearerAuth: [] }],
          responses: { 201: { description: 'Invite code + link' } },
        },
      },
      '/community/invite/stats': {
        get: {
          tags: ['Community'],
          summary: 'Get user invite stats',
          security: [{ BearerAuth: [] }],
          responses: { 200: { description: 'Invite count, list' } },
        },
      },
      '/community/invite/{code}': {
        get: {
          tags: ['Community'],
          summary: 'Validate an invite code (public)',
          parameters: [{ name: 'code', in: 'path', required: true, schema: { type: 'string' } }],
          responses: { 200: { description: 'Invite details (church name, inviter)' }, 404: { description: 'Invalid code' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  FORUM
      // ═══════════════════════════════════════════════
      '/forum/categories': {
        get: { tags: ['Forum'], summary: 'List forum categories', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Categories with thread counts' } } },
      },
      '/forum/trending': {
        get: { tags: ['Forum'], summary: 'Get trending threads', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Top threads by engagement' } } },
      },
      '/forum/recent': {
        get: {
          tags: ['Forum'],
          summary: 'Get recent threads (paginated)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }, { name: 'sort', in: 'query', schema: { type: 'string', enum: ['recent', 'popular'] } }],
          responses: { 200: { description: 'Paginated threads' } },
        },
      },
      '/forum/categories/{id}/threads': {
        get: {
          tags: ['Forum'],
          summary: 'Get threads in a category',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }, { $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Threads in category' } },
        },
      },
      '/forum/threads': {
        post: {
          tags: ['Forum'],
          summary: 'Create a new thread',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CreateThreadInput' } } } },
          responses: { 201: { description: 'Thread created' } },
        },
      },
      '/forum/threads/{id}': {
        get: {
          tags: ['Forum'],
          summary: 'Get thread detail with replies (paginated)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }, { $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Thread with paginated replies' } },
        },
      },
      '/forum/threads/{id}/replies': {
        post: {
          tags: ['Forum'],
          summary: 'Reply to a thread',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CreateReplyInput' } } } },
          responses: { 201: { description: 'Reply created' } },
        },
      },
      '/forum/threads/{id}/like': {
        post: { tags: ['Forum'], summary: 'Toggle like on thread', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Toggled' } } },
      },
      '/forum/threads/{id}/bookmark': {
        post: { tags: ['Forum'], summary: 'Toggle bookmark on thread', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Toggled' } } },
      },
      '/forum/replies/{id}/like': {
        post: { tags: ['Forum'], summary: 'Toggle like on reply', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Toggled' } } },
      },

      // ═══════════════════════════════════════════════
      //  PRAYER
      // ═══════════════════════════════════════════════
      '/prayer-requests': {
        get: {
          tags: ['Prayer'],
          summary: 'List active prayer requests',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Prayer requests' } },
        },
        post: {
          tags: ['Prayer'],
          summary: 'Create a prayer request',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/PrayerRequestInput' } } } },
          responses: { 201: { description: 'Prayer request created' } },
        },
      },
      '/prayer-requests/my': {
        get: { tags: ['Prayer'], summary: 'Get user\'s own prayer requests', security: [{ BearerAuth: [] }], responses: { 200: { description: 'User requests' } } },
      },
      '/prayer-requests/{id}/pray': {
        post: { tags: ['Prayer'], summary: 'Pray for a request (toggle)', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Prayer recorded' } } },
      },
      '/prayer-requests/{id}/status': {
        put: {
          tags: ['Prayer'],
          summary: 'Update prayer request status',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: { type: 'object', required: ['status'], properties: { status: { type: 'string', enum: ['ACTIVE', 'ANSWERED', 'CLOSED'] } } } } },
          },
          responses: { 200: { description: 'Status updated' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  CHAT
      // ═══════════════════════════════════════════════
      '/chat/conversations': {
        get: { tags: ['Chat'], summary: 'List user conversations', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Conversations with last message' } } },
        post: {
          tags: ['Chat'],
          summary: 'Create a conversation (direct or group)',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CreateConversationInput' } } } },
          responses: { 201: { description: 'Conversation created' } },
        },
      },
      '/chat/conversations/{id}/messages': {
        get: {
          tags: ['Chat'],
          summary: 'Get messages in a conversation (paginated)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }, { $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Paginated messages' } },
        },
        post: {
          tags: ['Chat'],
          summary: 'Send a message',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/SendMessageInput' } } } },
          responses: { 201: { description: 'Message sent' } },
        },
      },
      '/chat/conversations/{id}/read': {
        put: { tags: ['Chat'], summary: 'Mark conversation as read', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Marked read' } } },
      },
      '/chat/conversations/{id}/pin': {
        put: { tags: ['Chat'], summary: 'Toggle pin conversation', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Toggled' } } },
      },
      '/chat/conversations/{id}/mute': {
        put: { tags: ['Chat'], summary: 'Toggle mute conversation', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Toggled' } } },
      },

      // ═══════════════════════════════════════════════
      //  NOTIFICATIONS
      // ═══════════════════════════════════════════════
      '/notifications': {
        get: {
          tags: ['Notifications'],
          summary: 'List notifications (paginated)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Paginated notifications' } },
        },
      },
      '/notifications/unread-count': {
        get: { tags: ['Notifications'], summary: 'Get unread notification count', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Count object' } } },
      },
      '/notifications/read-all': {
        put: { tags: ['Notifications'], summary: 'Mark all notifications as read', security: [{ BearerAuth: [] }], responses: { 200: { description: 'All marked read' } } },
      },
      '/notifications/{id}/read': {
        put: { tags: ['Notifications'], summary: 'Mark single notification as read', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Marked read' } } },
      },
      '/notifications/{id}': {
        delete: { tags: ['Notifications'], summary: 'Delete a notification', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Deleted' } } },
      },

      // ═══════════════════════════════════════════════
      //  LIVE
      // ═══════════════════════════════════════════════
      '/live': {
        get: { tags: ['Live'], summary: 'List live services', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }], responses: { 200: { description: 'Live services list' } } },
      },
      '/live/current': {
        get: { tags: ['Live'], summary: 'Get current or upcoming live service', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Current/upcoming live service' } } },
      },
      '/live/{id}': {
        get: { tags: ['Live'], summary: 'Get live service detail', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Live service detail' } } },
      },
      '/live/{id}/chat': {
        get: {
          tags: ['Live'],
          summary: 'Get live chat messages',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }, { $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Paginated chat messages' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  VOLUNTEER
      // ═══════════════════════════════════════════════
      '/volunteer/opportunities': {
        get: {
          tags: ['Volunteer'],
          summary: 'List volunteer opportunities',
          security: [{ BearerAuth: [] }],
          parameters: [{ name: 'department', in: 'query', schema: { type: 'string' } }, { name: 'active', in: 'query', schema: { type: 'boolean' } }],
          responses: { 200: { description: 'Opportunities list' } },
        },
      },
      '/volunteer/signup': {
        post: {
          tags: ['Volunteer'],
          summary: 'Sign up for an opportunity',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/VolunteerSignupInput' } } } },
          responses: { 201: { description: 'Signed up' }, 409: { description: 'Already signed up' } },
        },
      },
      '/volunteer/roster': {
        get: {
          tags: ['Volunteer'],
          summary: 'Get user shift roster',
          security: [{ BearerAuth: [] }],
          parameters: [{ name: 'upcoming', in: 'query', schema: { type: 'boolean' } }],
          responses: { 200: { description: 'Shifts list' } },
        },
      },
      '/volunteer/roster/{id}/checkin': {
        post: { tags: ['Volunteer'], summary: 'Check in to shift', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Checked in' }, 400: { description: 'Not shift day' } } },
      },
      '/volunteer/roster/{id}/swap': {
        post: {
          tags: ['Volunteer'],
          summary: 'Swap shift with another volunteer',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/ShiftSwapInput' } } } },
          responses: { 200: { description: 'Shift swapped' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  KIDS
      // ═══════════════════════════════════════════════
      '/kids/children': {
        get: { tags: ['Kids'], summary: 'List parent\'s children', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Children list with active check-ins' } } },
        post: {
          tags: ['Kids'],
          summary: 'Register a child',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/RegisterChildInput' } } } },
          responses: { 201: { description: 'Child registered' } },
        },
      },
      '/kids/checkin': {
        post: {
          tags: ['Kids'],
          summary: 'Check in a child to a room',
          description: 'Returns a security code needed for checkout.',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CheckinInput' } } } },
          responses: { 201: { description: 'Child checked in with security code' }, 409: { description: 'Already checked in' } },
        },
      },
      '/kids/checkout': {
        post: {
          tags: ['Kids'],
          summary: 'Check out a child (requires security code)',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CheckoutInput' } } } },
          responses: { 200: { description: 'Child checked out' }, 403: { description: 'Invalid security code' } },
        },
      },
      '/kids/rooms': {
        get: { tags: ['Kids'], summary: 'List rooms with capacity', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Rooms list' } } },
      },

      // ═══════════════════════════════════════════════
      //  MEDIA
      // ═══════════════════════════════════════════════
      '/media/albums': {
        get: {
          tags: ['Media'],
          summary: 'List photo albums',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Albums list' } },
        },
        post: {
          tags: ['Media'],
          summary: 'Create a photo album (admin)',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CreateAlbumInput' } } } },
          responses: { 201: { description: 'Album created' } },
        },
      },
      '/media/albums/{id}': {
        get: {
          tags: ['Media'],
          summary: 'Get album detail with photos',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Album with photos' } },
        },
      },
      '/media/albums/{albumId}/photos': {
        post: {
          tags: ['Media'],
          summary: 'Upload photo to album',
          security: [{ BearerAuth: [] }],
          parameters: [{ name: 'albumId', in: 'path', required: true, schema: { type: 'string', format: 'uuid' } }],
          requestBody: {
            required: true,
            content: { 'multipart/form-data': { schema: { type: 'object', properties: { photo: { type: 'string', format: 'binary' }, caption: { type: 'string' } } } } },
          },
          responses: { 201: { description: 'Photo uploaded' } },
        },
      },
      '/media/podcasts': {
        get: {
          tags: ['Media'],
          summary: 'List podcast episodes',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Paginated podcast episodes' } },
        },
      },
      '/media/podcasts/{id}': {
        get: { tags: ['Media'], summary: 'Get podcast episode detail', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Episode detail' } } },
      },
      '/media/podcasts/{id}/progress': {
        put: {
          tags: ['Media'],
          summary: 'Update podcast playback progress',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/PodcastProgressInput' } } } },
          responses: { 200: { description: 'Progress saved' } },
        },
      },
      '/media/songs': {
        get: {
          tags: ['Media'],
          summary: 'List worship songs',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }, { name: 'key', in: 'query', schema: { type: 'string' } }, { name: 'search', in: 'query', schema: { type: 'string' } }],
          responses: { 200: { description: 'Songs list' } },
        },
      },
      '/media/songs/{id}': {
        get: { tags: ['Media'], summary: 'Get song detail with sections & lyrics', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Song with lyrics' } } },
      },

      // ═══════════════════════════════════════════════
      //  SEARCH
      // ═══════════════════════════════════════════════
      '/search': {
        get: {
          tags: ['Search'],
          summary: 'Global search across all content types',
          security: [{ BearerAuth: [] }],
          parameters: [
            { name: 'q', in: 'query', required: true, schema: { type: 'string' }, description: 'Search query' },
            { name: 'type', in: 'query', schema: { type: 'string', enum: ['all', 'sermons', 'events', 'groups', 'people', 'media', 'forum'] } },
          ],
          responses: { 200: { description: 'Search results grouped by type' }, 400: { description: 'Missing q parameter' } },
        },
      },
      '/search/trending': {
        get: { tags: ['Search'], summary: 'Get trending items', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Trending sermons, events, groups' } } },
      },

      // ═══════════════════════════════════════════════
      //  ATTENDANCE
      // ═══════════════════════════════════════════════
      '/attendance': {
        post: {
          tags: ['Attendance'],
          summary: 'Record attendance',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/RecordAttendanceInput' } } } },
          responses: { 201: { description: 'Attendance recorded' }, 409: { description: 'Already recorded for this service' } },
        },
        get: {
          tags: ['Attendance'],
          summary: 'Get attendance history (paginated)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Attendance history' } },
        },
      },
      '/attendance/streak': {
        get: { tags: ['Attendance'], summary: 'Get attendance streak', security: [{ BearerAuth: [] }], responses: { 200: { description: '{ currentStreak, totalAttendances }' } } },
      },
      '/attendance/{id}': {
        delete: { tags: ['Attendance'], summary: 'Delete attendance record', security: [{ BearerAuth: [] }], parameters: [{ $ref: '#/components/parameters/IdParam' }], responses: { 200: { description: 'Deleted' } } },
      },
      '/attendance/stats': {
        get: {
          tags: ['Attendance'],
          summary: 'Get attendance stats (admin only)',
          security: [{ BearerAuth: [] }],
          description: 'Requires ADMIN or PASTOR role.',
          responses: { 200: { description: 'Attendance stats by service type, trends' }, 403: { $ref: '#/components/responses/Forbidden' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  MILESTONES
      // ═══════════════════════════════════════════════
      '/milestones': {
        get: {
          tags: ['Milestones'],
          summary: 'List user milestones (paginated)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/PageParam' }, { $ref: '#/components/parameters/LimitParam' }],
          responses: { 200: { description: 'Milestones list' } },
        },
        post: {
          tags: ['Milestones'],
          summary: 'Create a milestone (admin only)',
          security: [{ BearerAuth: [] }],
          description: 'Requires ADMIN or PASTOR role.',
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/CreateMilestoneInput' } } } },
          responses: { 201: { description: 'Milestone created' }, 403: { $ref: '#/components/responses/Forbidden' } },
        },
      },
      '/milestones/summary': {
        get: { tags: ['Milestones'], summary: 'Get milestone summary (all types with earned status)', security: [{ BearerAuth: [] }], responses: { 200: { description: 'Summary of all milestone types' } } },
      },
      '/milestones/{id}': {
        delete: {
          tags: ['Milestones'],
          summary: 'Delete a milestone (admin only)',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          description: 'Requires ADMIN or PASTOR role.',
          responses: { 200: { description: 'Deleted' }, 403: { $ref: '#/components/responses/Forbidden' } },
        },
      },

      // ═══════════════════════════════════════════════
      //  SAVED ITEMS
      // ═══════════════════════════════════════════════
      '/saved-items': {
        get: {
          tags: ['Saved Items'],
          summary: 'List saved items (paginated, filterable)',
          security: [{ BearerAuth: [] }],
          parameters: [
            { $ref: '#/components/parameters/PageParam' },
            { $ref: '#/components/parameters/LimitParam' },
            { name: 'entityType', in: 'query', schema: { type: 'string', enum: ['SERMON', 'EVENT', 'DEVOTIONAL', 'READING_PLAN'] } },
          ],
          responses: { 200: { description: 'Paginated saved items' } },
        },
        post: {
          tags: ['Saved Items'],
          summary: 'Save an item',
          security: [{ BearerAuth: [] }],
          requestBody: { required: true, content: { 'application/json': { schema: { $ref: '#/components/schemas/SaveItemInput' } } } },
          responses: { 201: { description: 'Item saved' }, 409: { description: 'Already saved' } },
        },
      },
      '/saved-items/check': {
        get: {
          tags: ['Saved Items'],
          summary: 'Check if an item is saved',
          security: [{ BearerAuth: [] }],
          parameters: [
            { name: 'entityType', in: 'query', required: true, schema: { type: 'string' } },
            { name: 'entityId', in: 'query', required: true, schema: { type: 'string', format: 'uuid' } },
          ],
          responses: { 200: { description: '{ saved: boolean }' } },
        },
      },
      '/saved-items/{id}': {
        delete: {
          tags: ['Saved Items'],
          summary: 'Remove a saved item',
          security: [{ BearerAuth: [] }],
          parameters: [{ $ref: '#/components/parameters/IdParam' }],
          responses: { 200: { description: 'Removed' } },
        },
      },
    },
  },
  // No need for JSDoc file scanning — all paths defined inline above
  apis: [],
};

export const swaggerSpec = swaggerJsdoc(options);
