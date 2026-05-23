import { Router } from 'express';
import { membersController } from './members.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';
import { validate } from '../../../middleware/validate';
import { updateMemberSchema, changeRoleSchema, changeStatusSchema, inviteMemberSchema } from './members.validation';

const router = Router();

router.use(authenticate, requireAdmin);

router.get('/', membersController.list);
router.post('/invite', validate(inviteMemberSchema), membersController.invite);
router.get('/export', membersController.exportCsv);
router.get('/:id', membersController.getById);
router.put('/:id', validate(updateMemberSchema), membersController.update);
router.put('/:id/role', validate(changeRoleSchema), membersController.changeRole);
router.put('/:id/status', validate(changeStatusSchema), membersController.setStatus);
router.delete('/:id', membersController.delete);
router.get('/:id/giving-history', membersController.givingHistory);

export default router;
