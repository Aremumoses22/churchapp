import { Router } from 'express';
import { homeController } from './home.controller';
import { authenticate } from '../../middleware/auth';

const router = Router();

router.get('/feed', authenticate, homeController.getFeed);

export default router;
