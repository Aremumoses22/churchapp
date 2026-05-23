import { Router } from 'express';
import { mediaController } from './media.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

// Albums
router.get('/albums', mediaController.listAlbums);
router.post('/albums', mediaController.createAlbum);
router.put('/albums/:id', mediaController.updateAlbum);
router.delete('/albums/:id', mediaController.deleteAlbum);

// Photos (nested under album)
router.get('/albums/:albumId/photos', mediaController.listPhotos);
router.post('/albums/:albumId/photos', mediaController.addPhotos);
router.delete('/photos/:id', mediaController.deletePhoto);

// Podcasts
router.get('/podcasts', mediaController.listPodcasts);
router.post('/podcasts', mediaController.createPodcast);
router.put('/podcasts/:id', mediaController.updatePodcast);
router.delete('/podcasts/:id', mediaController.deletePodcast);

// Worship Songs
router.get('/songs', mediaController.listSongs);
router.post('/songs', mediaController.createSong);
router.put('/songs/:id', mediaController.updateSong);
router.delete('/songs/:id', mediaController.deleteSong);

export default router;
