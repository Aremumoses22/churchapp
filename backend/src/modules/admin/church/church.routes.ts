import { Router } from 'express';
import { churchController } from './church.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

// Info
router.get('/', churchController.get);
router.put('/', churchController.updateInfo);
router.put('/logo', churchController.updateLogo);
router.put('/cover-image', churchController.updateCoverImage);
router.put('/timeline', churchController.updateTimeline);

// Staff
router.get('/staff', churchController.listStaff);
router.post('/staff', churchController.createStaff);
router.put('/staff/:id', churchController.updateStaff);
router.delete('/staff/:id', churchController.deleteStaff);

// Campuses
router.get('/campuses', churchController.listCampuses);
router.post('/campuses', churchController.createCampus);
router.put('/campuses/:id', churchController.updateCampus);
router.delete('/campuses/:id', churchController.deleteCampus);
router.put('/campuses/:id/service-times', churchController.upsertServiceTimes);

// FAQs
router.get('/faqs', churchController.listFaqs);
router.post('/faqs', churchController.createFaq);
router.put('/faqs/:id', churchController.updateFaq);
router.delete('/faqs/:id', churchController.deleteFaq);

// Core Values
router.get('/core-values', churchController.listCoreValues);
router.post('/core-values', churchController.createCoreValue);
router.put('/core-values/:id', churchController.updateCoreValue);
router.delete('/core-values/:id', churchController.deleteCoreValue);

export default router;
