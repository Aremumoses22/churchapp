import { Router } from 'express';
import { sermonsController } from './sermons.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

router.get('/series', sermonsController.listSeries);
router.post('/series', sermonsController.createSeries);
router.put('/series/:id', sermonsController.updateSeries);
router.delete('/series/:id', sermonsController.deleteSeries);

router.get('/', sermonsController.list);
router.post('/', sermonsController.create);
router.get('/:id', sermonsController.getById);
router.put('/:id', sermonsController.update);
router.delete('/:id', sermonsController.delete);
router.put('/:id/featured', sermonsController.toggleFeatured);

export default router;
