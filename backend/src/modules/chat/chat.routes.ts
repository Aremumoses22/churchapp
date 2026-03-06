import { Router } from 'express';
import { chatController } from './chat.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { chatValidation } from './chat.validation';

const router = Router();

// All chat routes require authentication
router.use(authenticate);

// GET /chat/conversations — list user's conversations
router.get('/conversations', validate(chatValidation.listConversations), chatController.listConversations);

// POST /chat/conversations — create a new conversation
router.post('/conversations', validate(chatValidation.createConversation), chatController.createConversation);

// GET /chat/conversations/:id/messages — get messages
router.get('/conversations/:id/messages', validate(chatValidation.getMessages), chatController.getMessages);

// POST /chat/conversations/:id/messages — send a message
router.post('/conversations/:id/messages', validate(chatValidation.sendMessage), chatController.sendMessage);

// PUT /chat/conversations/:id/read — mark conversation as read
router.put('/conversations/:id/read', validate(chatValidation.conversationId), chatController.markAsRead);

// PUT /chat/conversations/:id/pin — toggle pin
router.put('/conversations/:id/pin', validate(chatValidation.conversationId), chatController.togglePin);

// PUT /chat/conversations/:id/mute — toggle mute
router.put('/conversations/:id/mute', validate(chatValidation.conversationId), chatController.toggleMute);

export default router;
