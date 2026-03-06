import { Router } from 'express';
import { churchController } from './church.controller';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { contactFormSchema } from './church.validation';

const router = Router();

// All church info routes require authentication (need churchId from user)
router.get('/about', authenticate, churchController.getAbout);
router.get('/staff', authenticate, churchController.getStaff);
router.get('/campuses', authenticate, churchController.getCampuses);
router.get('/faqs', authenticate, churchController.getFAQs);
router.post('/contact', authenticate, validate(contactFormSchema), churchController.submitContact);

export default router;
