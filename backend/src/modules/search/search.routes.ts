import { Router } from 'express';
import { searchController } from './search.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { searchValidation } from './search.validation';

const router = Router();

router.use(authenticate);

router.get('/', validate(searchValidation.search), searchController.search);
router.get('/trending', validate(searchValidation.trending), searchController.trending);

export default router;
