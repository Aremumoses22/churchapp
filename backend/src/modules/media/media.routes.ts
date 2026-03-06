import { Router } from 'express';
import { mediaController } from './media.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { mediaValidation } from './media.validation';

const router = Router();

router.use(authenticate);

// Photo Albums
router.get('/albums', validate(mediaValidation.listAlbums), mediaController.listAlbums);
router.post('/albums', validate(mediaValidation.createAlbum), mediaController.createAlbum);
router.get('/albums/:id', validate(mediaValidation.albumId), mediaController.getAlbum);

// Photos
router.post('/albums/:albumId/photos', validate(mediaValidation.addPhoto), mediaController.addPhoto);

// Podcasts
router.get('/podcasts', validate(mediaValidation.listPodcasts), mediaController.listPodcasts);
router.get('/podcasts/:id', validate(mediaValidation.podcastId), mediaController.getPodcast);
router.put('/podcasts/:id/progress', validate(mediaValidation.updatePodcastProgress), mediaController.updatePodcastProgress);

// Worship Songs
router.get('/songs', validate(mediaValidation.listSongs), mediaController.listSongs);
router.get('/songs/:id', validate(mediaValidation.songId), mediaController.getSong);

export default router;
