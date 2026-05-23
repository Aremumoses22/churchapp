import type { Response, NextFunction } from 'express';
import type { AuthRequest } from '../../middleware/auth';
import { mediaService } from './media.service';
import { ApiResponse } from '../../utils/apiResponse';
import { resolveChurchId } from '../../utils/churchHelper';

export const mediaController = {
  // ── Photo Albums ──────────────────────────────────
  async listAlbums(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const query = req.query as any;
      const page = query.page ?? 1;
      const limit = query.limit ?? 20;
      const eventId = query.eventId as string | undefined;

      const result = await mediaService.listAlbums(churchId, page, limit, eventId);
      return ApiResponse.paginated(
        res,
        result.albums,
        result.meta.page,
        result.meta.limit,
        result.meta.total
      );
    } catch (error) {
      next(error);
    }
  },

  async createAlbum(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const album = await mediaService.createAlbum(churchId, req.body);
      return ApiResponse.created(res, album, 'Album created successfully');
    } catch (error) {
      next(error);
    }
  },

  async getAlbum(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const id = req.params.id as string;

      const album = await mediaService.getAlbum(id, churchId);
      return ApiResponse.success(res, album);
    } catch (error) {
      next(error);
    }
  },

  // ── Photos ────────────────────────────────────────
  async addPhoto(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const albumId = req.params.albumId as string;

      const photo = await mediaService.addPhoto(userId, churchId, albumId, req.body);
      return ApiResponse.created(res, photo, 'Photo added successfully');
    } catch (error) {
      next(error);
    }
  },

  // ── Podcasts ──────────────────────────────────────
  async listPodcasts(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const userId = req.user!.id;
      const query = req.query as any;
      const page = query.page ?? 1;
      const limit = query.limit ?? 20;

      const result = await mediaService.listPodcasts(churchId, userId, page, limit);
      return ApiResponse.paginated(
        res,
        result.episodes,
        result.meta.page,
        result.meta.limit,
        result.meta.total
      );
    } catch (error) {
      next(error);
    }
  },

  async getPodcast(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const userId = req.user!.id;
      const id = req.params.id as string;

      const episode = await mediaService.getPodcast(id, churchId, userId);
      return ApiResponse.success(res, episode);
    } catch (error) {
      next(error);
    }
  },

  async updatePodcastProgress(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const id = req.params.id as string;

      const progress = await mediaService.updatePodcastProgress(userId, id, req.body);
      return ApiResponse.success(res, progress, 'Progress updated');
    } catch (error) {
      next(error);
    }
  },

  // ── Worship Songs ─────────────────────────────────
  async listSongs(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const query = req.query as any;
      const page = query.page ?? 1;
      const limit = query.limit ?? 20;
      const key = query.key as string | undefined;
      const search = query.search as string | undefined;

      const result = await mediaService.listSongs(churchId, page, limit, key, search);
      return ApiResponse.paginated(
        res,
        result.songs,
        result.meta.page,
        result.meta.limit,
        result.meta.total
      );
    } catch (error) {
      next(error);
    }
  },

  async getSong(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const churchId = await resolveChurchId(req);
      if (!churchId) return ApiResponse.error(res, 'Church context required', 400);
      const id = req.params.id as string;

      const song = await mediaService.getSong(id, churchId);
      return ApiResponse.success(res, song);
    } catch (error) {
      next(error);
    }
  },
};
