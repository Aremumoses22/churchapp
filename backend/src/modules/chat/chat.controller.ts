import type { Response, NextFunction } from 'express';
import { chatService } from './chat.service';
import { ApiResponse } from '../../utils/apiResponse';
import type { AuthRequest } from '../../middleware/auth';
import { resolveChurchId } from '../../utils/churchHelper';

const param = (req: AuthRequest, name: string): string => req.params[name] as string;

export const chatController = {
  // GET /chat/conversations
  async listConversations(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;

      const result = await chatService.listConversations(userId, page, limit);
      ApiResponse.paginated(res, result.conversations, result.meta);
    } catch (error) {
      next(error);
    }
  },

  // POST /chat/conversations
  async createConversation(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);

      const conversation = await chatService.createConversation(userId, churchId, req.body);
      ApiResponse.created(res, conversation);
    } catch (error) {
      next(error);
    }
  },

  // GET /chat/conversations/:id/messages
  async getMessages(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const id = param(req, 'id');
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 30;
      const before = req.query.before as string | undefined;

      const result = await chatService.getMessages(userId, id, page, limit, before);
      ApiResponse.paginated(res, result.messages, result.meta);
    } catch (error) {
      next(error);
    }
  },

  // POST /chat/conversations/:id/messages
  async sendMessage(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const id = param(req, 'id');

      const message = await chatService.sendMessage(userId, id, req.body);
      ApiResponse.created(res, message);
    } catch (error) {
      next(error);
    }
  },

  // PUT /chat/conversations/:id/read
  async markAsRead(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const id = param(req, 'id');

      await chatService.markAsRead(userId, id);
      ApiResponse.success(res, null, 'Conversation marked as read');
    } catch (error) {
      next(error);
    }
  },

  // PUT /chat/conversations/:id/pin
  async togglePin(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const id = param(req, 'id');

      const result = await chatService.togglePin(userId, id);
      ApiResponse.success(res, { isPinned: result.isPinned }, result.isPinned ? 'Conversation pinned' : 'Conversation unpinned');
    } catch (error) {
      next(error);
    }
  },

  // PUT /chat/conversations/:id/mute
  async toggleMute(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const id = param(req, 'id');

      const result = await chatService.toggleMute(userId, id);
      ApiResponse.success(res, { isMuted: result.isMuted }, result.isMuted ? 'Conversation muted' : 'Conversation unmuted');
    } catch (error) {
      next(error);
    }
  },
};
