import { Response, NextFunction } from 'express';
import { adminMediaService } from './media.service';
import { ApiResponse } from '../../../utils/apiResponse';
import { AuthRequest } from '../../../middleware/auth';

function cid(req: AuthRequest): string | null | undefined {
  if (req.user?.role === 'SUPER_ADMIN') {
    const qId = typeof req.query.churchId === 'string' ? req.query.churchId : undefined;
    return qId || req.user.churchId;
  }
  return req.user?.churchId ?? null;
}

function pid(req: AuthRequest): string { return req.params['id'] as string; }

export const mediaController = {
  // ── Photo Albums ─────────────────────────────────────────────
  async listAlbums(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminMediaService.listAlbums(cid(req))); } catch (e) { next(e); }
  },

  async createAlbum(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminMediaService.createAlbum(cid(req), req.body)); } catch (e) { next(e); }
  },

  async updateAlbum(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminMediaService.updateAlbum(cid(req), pid(req), req.body), 'Album updated'); } catch (e) { next(e); }
  },

  async deleteAlbum(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminMediaService.deleteAlbum(cid(req), pid(req)); ApiResponse.success(res, null, 'Album deleted'); } catch (e) { next(e); }
  },

  // ── Photos ────────────────────────────────────────────────────
  async listPhotos(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const albumId = req.params['albumId'] as string;
      ApiResponse.success(res, await adminMediaService.listPhotos(cid(req), albumId));
    } catch (e) { next(e); }
  },

  async addPhotos(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const albumId = req.params['albumId'] as string;
      const uploadedById = req.user!.id;
      const { photos } = req.body as { photos: { imageUrl: string; caption?: string }[] };
      ApiResponse.created(res, await adminMediaService.addPhotos(cid(req), albumId, uploadedById, photos));
    } catch (e) { next(e); }
  },

  async deletePhoto(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminMediaService.deletePhoto(cid(req), pid(req)); ApiResponse.success(res, null, 'Photo deleted'); } catch (e) { next(e); }
  },

  // ── Podcasts ──────────────────────────────────────────────────
  async listPodcasts(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search } = req.query as Record<string, string>;
      const result = await adminMediaService.listPodcasts(cid(req), { page: +page, limit: +limit, search });
      ApiResponse.paginated(res, result.episodes, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  async createPodcast(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminMediaService.createPodcast(cid(req), req.body)); } catch (e) { next(e); }
  },

  async updatePodcast(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminMediaService.updatePodcast(cid(req), pid(req), req.body), 'Podcast updated'); } catch (e) { next(e); }
  },

  async deletePodcast(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminMediaService.deletePodcast(cid(req), pid(req)); ApiResponse.success(res, null, 'Podcast deleted'); } catch (e) { next(e); }
  },

  // ── Worship Songs ─────────────────────────────────────────────
  async listSongs(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { page = '1', limit = '20', search } = req.query as Record<string, string>;
      const result = await adminMediaService.listSongs(cid(req), { page: +page, limit: +limit, search });
      ApiResponse.paginated(res, result.songs, { page: result.page, limit: result.limit, total: result.total, totalPages: result.totalPages });
    } catch (e) { next(e); }
  },

  async createSong(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.created(res, await adminMediaService.createSong(cid(req), req.body)); } catch (e) { next(e); }
  },

  async updateSong(req: AuthRequest, res: Response, next: NextFunction) {
    try { ApiResponse.success(res, await adminMediaService.updateSong(cid(req), pid(req), req.body), 'Song updated'); } catch (e) { next(e); }
  },

  async deleteSong(req: AuthRequest, res: Response, next: NextFunction) {
    try { await adminMediaService.deleteSong(cid(req), pid(req)); ApiResponse.success(res, null, 'Song deleted'); } catch (e) { next(e); }
  },
};
