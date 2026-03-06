import { Response, NextFunction } from 'express';
import { savedItemsService } from './saved-items.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthRequest } from '../../middleware/auth';

export const savedItemsController = {
  // POST /saved-items
  async saveItem(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await savedItemsService.saveItem(req.user!.id, req.body);
      ApiResponse.created(res, result, 'Item saved');
    } catch (error) {
      next(error);
    }
  },

  // DELETE /saved-items/:id
  async removeSavedItem(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await savedItemsService.removeSavedItem(
        req.user!.id,
        req.params.id as string,
      );
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },

  // GET /saved-items
  async listSavedItems(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await savedItemsService.listSavedItems(
        req.user!.id,
        req.query as any,
      );
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },

  // GET /saved-items/check?entityType=SERMON&entityId=xxx
  async checkSaved(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { entityType, entityId } = req.query as { entityType: string; entityId: string };
      if (!entityType || !entityId) {
        return ApiResponse.error(res, 'entityType and entityId are required', 400);
      }
      const result = await savedItemsService.isItemSaved(req.user!.id, entityType, entityId);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },
};
