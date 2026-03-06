import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { listGroupsSchema, idParamSchema } from './groups.validation';
import * as groupsCtrl from './groups.controller';

const router = Router();

router.get('/', authenticate, validate(listGroupsSchema), groupsCtrl.listGroups);
router.get('/:id', authenticate, validate(idParamSchema), groupsCtrl.getGroupById);
router.post('/:id/join', authenticate, validate(idParamSchema), groupsCtrl.joinGroup);
router.delete('/:id/leave', authenticate, validate(idParamSchema), groupsCtrl.leaveGroup);

export default router;
