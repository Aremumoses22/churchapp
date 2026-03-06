import { Router } from 'express';
import { kidsController } from './kids.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { kidsValidation } from './kids.validation';

const router = Router();

router.use(authenticate);

router.get('/children', validate(kidsValidation.listChildren), kidsController.listChildren);
router.post('/children', validate(kidsValidation.registerChild), kidsController.registerChild);
router.post('/checkin', validate(kidsValidation.checkIn), kidsController.checkIn);
router.post('/checkout', validate(kidsValidation.checkOut), kidsController.checkOut);
router.get('/rooms', validate(kidsValidation.listRooms), kidsController.listRooms);

export default router;
