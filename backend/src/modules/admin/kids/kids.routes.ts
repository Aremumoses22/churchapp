import { Router } from 'express';
import { kidsController } from './kids.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

router.get('/rooms', kidsController.listRooms);
router.post('/rooms', kidsController.createRoom);
router.put('/rooms/:id', kidsController.updateRoom);
router.delete('/rooms/:id', kidsController.deleteRoom);

router.get('/children', kidsController.listChildren);

router.get('/checkins/today', kidsController.todayCheckins);
router.get('/checkins/history', kidsController.listCheckinHistory);

export default router;
