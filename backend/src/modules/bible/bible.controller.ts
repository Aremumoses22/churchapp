import { Response, NextFunction } from 'express';
import { bibleService } from './bible.service';
import { devotionalsService } from './devotionals.service';
import { readingPlansService } from './readingPlans.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthRequest } from '../../middleware/auth';
import { resolveChurchId } from '../../utils/churchHelper';

export const bibleController = {
  // ════════════════════════════════════════════════════
  // BIBLE
  // ════════════════════════════════════════════════════

  // GET /bible/books
  async getBooks(_req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const books = await bibleService.getBooks();
      ApiResponse.success(res, books);
    } catch (error) {
      next(error);
    }
  },

  // GET /bible/:bookId/:chapter
  async getChapter(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { bookId, chapter } = req.params;
      const result = await bibleService.getChapter(bookId as string, parseInt(chapter as string, 10), req.user?.id);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },

  // GET /bible/search
  async searchVerses(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const verses = await bibleService.searchVerses(req.query as any);
      ApiResponse.success(res, verses);
    } catch (error) {
      next(error);
    }
  },

  // GET /bible/highlights
  async getHighlights(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const highlights = await bibleService.getHighlights(req.user!.id);
      ApiResponse.success(res, highlights);
    } catch (error) {
      next(error);
    }
  },

  // POST /bible/highlights
  async addHighlight(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const highlight = await bibleService.addHighlight(req.user!.id, req.body);
      ApiResponse.created(res, highlight, 'Highlight added');
    } catch (error) {
      next(error);
    }
  },

  // DELETE /bible/highlights/:id
  async removeHighlight(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await bibleService.removeHighlight(req.user!.id, req.params.id as string);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },

  // ════════════════════════════════════════════════════
  // DEVOTIONALS
  // ════════════════════════════════════════════════════

  // GET /bible/devotionals/today
  async getDevotionalToday(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const devotional = await devotionalsService.getToday(churchId, req.user!.id);
      ApiResponse.success(res, devotional);
    } catch (error) {
      next(error);
    }
  },

  // GET /bible/devotionals/:date
  async getDevotionalByDate(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const devotional = await devotionalsService.getByDate(churchId, req.user!.id, req.params.date as string);
      ApiResponse.success(res, devotional);
    } catch (error) {
      next(error);
    }
  },

  // POST /bible/devotionals/:id/read
  async markDevotionalRead(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await devotionalsService.markRead(req.user!.id, req.params.id as string);
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },

  // GET /bible/devotionals/streak
  async getDevotionalStreak(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const streak = await devotionalsService.getStreak(req.user!.id, churchId);
      ApiResponse.success(res, streak);
    } catch (error) {
      next(error);
    }
  },

  // ════════════════════════════════════════════════════
  // READING PLANS
  // ════════════════════════════════════════════════════

  // GET /bible/reading-plans
  async browseReadingPlans(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const plans = await readingPlansService.browse(churchId, req.query.category as string | undefined);
      ApiResponse.success(res, plans);
    } catch (error) {
      next(error);
    }
  },

  // GET /bible/reading-plans/my
  async getMyReadingPlans(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const plans = await readingPlansService.getMyPlans(req.user!.id);
      ApiResponse.success(res, plans);
    } catch (error) {
      next(error);
    }
  },

  // GET /bible/reading-plans/:id
  async getReadingPlanById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const plan = await readingPlansService.getById(req.params.id as string, req.user?.id);
      ApiResponse.success(res, plan);
    } catch (error) {
      next(error);
    }
  },

  // POST /bible/reading-plans/:id/enroll
  async enrollInPlan(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const enrollment = await readingPlansService.enroll(req.user!.id, req.params.id as string);
      ApiResponse.created(res, enrollment, 'Enrolled in reading plan');
    } catch (error) {
      next(error);
    }
  },

  // POST /bible/reading-plans/:id/progress
  async markDayComplete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await readingPlansService.markDayComplete(req.user!.id, req.params.id as string, req.body);
      ApiResponse.success(res, result, 'Day completed');
    } catch (error) {
      next(error);
    }
  },
};
