import prisma from '../../../config/database';
import { ApiError } from '../../../utils/apiError';

function cw(churchId: string | null | undefined) { return churchId ? { churchId } : {}; }
function requireChurch(churchId: string | null | undefined): string {
  if (!churchId) throw ApiError.badRequest('Church context required');
  return churchId;
}

export const adminMediaService = {
  // ── Photo Albums ─────────────────────────────────────────────
  async listAlbums(churchId: string | null | undefined) {
    return prisma.photoAlbum.findMany({ where: cw(churchId), include: { _count: { select: { photos: true } } }, orderBy: { createdAt: 'desc' } });
  },

  async createAlbum(churchId: string | null | undefined, data: { title: string; description?: string; coverImageUrl?: string }) {
    const id = requireChurch(churchId);
    return prisma.photoAlbum.create({ data: { ...data, churchId: id } });
  },

  async updateAlbum(churchId: string | null | undefined, albumId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.photoAlbum.findFirst({ where: { id: albumId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Album not found');
    return prisma.photoAlbum.update({ where: { id: albumId }, data });
  },

  async deleteAlbum(churchId: string | null | undefined, albumId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.photoAlbum.findFirst({ where: { id: albumId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Album not found');
    await prisma.photoAlbum.delete({ where: { id: albumId } });
  },

  async listPhotos(churchId: string | null | undefined, albumId: string) {
    const cId = requireChurch(churchId);
    const album = await prisma.photoAlbum.findFirst({ where: { id: albumId, churchId: cId } });
    if (!album) throw ApiError.notFound('Album not found');
    return prisma.photo.findMany({ where: { albumId }, orderBy: { createdAt: 'asc' } });
  },

  async addPhotos(churchId: string | null | undefined, albumId: string, uploadedById: string, photos: { imageUrl: string; caption?: string }[]) {
    const cId = requireChurch(churchId);
    const album = await prisma.photoAlbum.findFirst({ where: { id: albumId, churchId: cId } });
    if (!album) throw ApiError.notFound('Album not found');
    const created = await prisma.photo.createMany({
      data: photos.map((p) => ({ ...p, albumId, churchId: cId, uploadedById })),
    });
    await prisma.photoAlbum.update({ where: { id: albumId }, data: { photoCount: { increment: created.count } } });
    return created;
  },

  async deletePhoto(churchId: string | null | undefined, photoId: string) {
    const cId = requireChurch(churchId);
    const photo = await prisma.photo.findFirst({ where: { id: photoId, churchId: cId } });
    if (!photo) throw ApiError.notFound('Photo not found');
    await prisma.photo.delete({ where: { id: photoId } });
    await prisma.photoAlbum.update({ where: { id: photo.albumId }, data: { photoCount: { decrement: 1 } } });
  },

  // ── Podcasts ──────────────────────────────────────────────────
  async listPodcasts(churchId: string | null | undefined, opts: { page: number; limit: number; search?: string }) {
    const where: any = { ...cw(churchId) };
    if (opts.search) where.OR = [{ title: { contains: opts.search, mode: 'insensitive' } }];
    const skip = (opts.page - 1) * opts.limit;
    const [episodes, total] = await Promise.all([
      prisma.podcastEpisode.findMany({ where, orderBy: { publishedAt: 'desc' }, skip, take: opts.limit }),
      prisma.podcastEpisode.count({ where }),
    ]);
    return { episodes, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async createPodcast(churchId: string | null | undefined, data: { title: string; description?: string; audioUrl: string; duration: number; thumbnailUrl?: string; publishedAt?: string }) {
    const id = requireChurch(churchId);
    return prisma.podcastEpisode.create({
      data: { ...data, churchId: id, publishedAt: data.publishedAt ? new Date(data.publishedAt) : new Date() },
    });
  },

  async updatePodcast(churchId: string | null | undefined, episodeId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.podcastEpisode.findFirst({ where: { id: episodeId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Podcast episode not found');
    if (data.publishedAt) data.publishedAt = new Date(data.publishedAt);
    return prisma.podcastEpisode.update({ where: { id: episodeId }, data });
  },

  async deletePodcast(churchId: string | null | undefined, episodeId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.podcastEpisode.findFirst({ where: { id: episodeId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Podcast episode not found');
    await prisma.podcastEpisode.delete({ where: { id: episodeId } });
  },

  // ── Worship Songs ─────────────────────────────────────────────
  async listSongs(churchId: string | null | undefined, opts: { page: number; limit: number; search?: string }) {
    const where: any = { ...cw(churchId) };
    if (opts.search) where.OR = [
      { title: { contains: opts.search, mode: 'insensitive' } },
      { artist: { contains: opts.search, mode: 'insensitive' } },
    ];
    const skip = (opts.page - 1) * opts.limit;
    const [songs, total] = await Promise.all([
      prisma.worshipSong.findMany({ where, orderBy: { title: 'asc' }, skip, take: opts.limit }),
      prisma.worshipSong.count({ where }),
    ]);
    return { songs, total, page: opts.page, limit: opts.limit, totalPages: Math.ceil(total / opts.limit) };
  },

  async createSong(churchId: string | null | undefined, data: { title: string; artist: string; key?: string; tempo?: number; tags?: string[] }) {
    const id = requireChurch(churchId);
    return prisma.worshipSong.create({ data: { ...data, churchId: id } });
  },

  async updateSong(churchId: string | null | undefined, songId: string, data: any) {
    const cId = requireChurch(churchId);
    const existing = await prisma.worshipSong.findFirst({ where: { id: songId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Song not found');
    return prisma.worshipSong.update({ where: { id: songId }, data });
  },

  async deleteSong(churchId: string | null | undefined, songId: string) {
    const cId = requireChurch(churchId);
    const existing = await prisma.worshipSong.findFirst({ where: { id: songId, churchId: cId } });
    if (!existing) throw ApiError.notFound('Song not found');
    await prisma.worshipSong.delete({ where: { id: songId } });
  },
};
