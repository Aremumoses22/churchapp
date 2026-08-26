import type { Request, Response, NextFunction } from 'express';
import { adminAnnouncementsService } from './announcements.service';

export const adminAnnouncementsController = {
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const churchId = (req as any).admin?.churchId;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;
      const result = await adminAnnouncementsService.list(churchId, { page, limit });
      res.json(result);
    } catch (err) {
      next(err);
    }
  },

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const churchId = (req as any).admin?.churchId;
      const authorId = (req as any).admin?.id;
      const announcement = await adminAnnouncementsService.create(churchId, authorId, req.body);
      res.status(201).json(announcement);
    } catch (err) {
      next(err);
    }
  },

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const churchId = (req as any).admin?.churchId;
      const announcement = await adminAnnouncementsService.update(req.params.id, churchId, req.body);
      res.json(announcement);
    } catch (err) {
      next(err);
    }
  },

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const churchId = (req as any).admin?.churchId;
      await adminAnnouncementsService.delete(req.params.id, churchId);
      res.json({ deleted: true });
    } catch (err) {
      next(err);
    }
  },
};
