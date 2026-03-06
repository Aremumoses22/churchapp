import { Router } from 'express';
import { volunteerController } from './volunteer.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { volunteerValidation } from './volunteer.validation';

const router = Router();

router.use(authenticate);

router.get('/opportunities', validate(volunteerValidation.listOpportunities), volunteerController.listOpportunities);
router.post('/signup', validate(volunteerValidation.signup), volunteerController.signup);
router.get('/roster', validate(volunteerValidation.listRoster), volunteerController.listRoster);
router.post('/roster/:id/checkin', validate(volunteerValidation.shiftId), volunteerController.checkin);
router.post('/roster/:id/swap', validate(volunteerValidation.swapShift), volunteerController.swapShift);

export default router;
