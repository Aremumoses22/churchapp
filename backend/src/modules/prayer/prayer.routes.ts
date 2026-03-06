import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import {
  idParamSchema,
  listPrayerRequestsSchema,
  createPrayerRequestSchema,
  updateStatusSchema,
} from './prayer.validation';
import * as prayerCtrl from './prayer.controller';

const router = Router();

router.get('/', authenticate, validate(listPrayerRequestsSchema), prayerCtrl.listPrayerRequests);
router.get('/my', authenticate, prayerCtrl.getMyRequests);
router.post('/', authenticate, validate(createPrayerRequestSchema), prayerCtrl.createPrayerRequest);
router.post('/:id/pray', authenticate, validate(idParamSchema), prayerCtrl.prayForRequest);
router.put('/:id/status', authenticate, validate(updateStatusSchema), prayerCtrl.updateStatus);

export default router;
