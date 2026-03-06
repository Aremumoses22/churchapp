import { z } from 'zod/v4';

export const mediaValidation = {
  // Photo Albums
  listAlbums: z.object({
    query: z.object({
      page: z.coerce.number().int().positive().default(1).optional(),
      limit: z.coerce.number().int().positive().max(100).default(20).optional(),
      eventId: z.string().uuid().optional(),
    }),
  }),

  createAlbum: z.object({
    body: z.object({
      title: z.string().min(1).max(255),
      description: z.string().max(2000).optional(),
      coverImageUrl: z.string().url().max(500).optional(),
      eventId: z.string().uuid().optional(),
    }),
  }),

  albumId: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
  }),

  // Photos
  addPhoto: z.object({
    params: z.object({
      albumId: z.string().uuid(),
    }),
    body: z.object({
      imageUrl: z.string().url().max(500),
      thumbnailUrl: z.string().url().max(500).optional(),
      caption: z.string().max(500).optional(),
    }),
  }),

  // Podcasts
  listPodcasts: z.object({
    query: z.object({
      page: z.coerce.number().int().positive().default(1).optional(),
      limit: z.coerce.number().int().positive().max(100).default(20).optional(),
    }),
  }),

  podcastId: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
  }),

  updatePodcastProgress: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
    body: z.object({
      position: z.number().int().min(0),
      completed: z.boolean().optional(),
    }),
  }),

  // Worship Songs
  listSongs: z.object({
    query: z.object({
      page: z.coerce.number().int().positive().default(1).optional(),
      limit: z.coerce.number().int().positive().max(100).default(20).optional(),
      key: z.string().max(10).optional(),
      search: z.string().max(100).optional(),
    }),
  }),

  songId: z.object({
    params: z.object({
      id: z.string().uuid(),
    }),
  }),
};

export type CreateAlbumInput = z.infer<typeof mediaValidation.createAlbum>['body'];
export type AddPhotoInput = z.infer<typeof mediaValidation.addPhoto>['body'];
export type UpdatePodcastProgressInput = z.infer<typeof mediaValidation.updatePodcastProgress>['body'];
