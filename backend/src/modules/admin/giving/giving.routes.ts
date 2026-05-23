import { Router } from 'express';
import { givingController } from './giving.controller';
import { authenticate } from '../../../middleware/auth';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate, requireAdmin);

// Donations
router.get('/donations', givingController.listDonations);
router.get('/donations/summary', givingController.getDonationSummary);

// Categories
router.get('/categories', givingController.listCategories);
router.post('/categories', givingController.createCategory);
router.put('/categories/:id', givingController.updateCategory);
router.delete('/categories/:id', givingController.deleteCategory);

// Campaigns
router.get('/campaigns', givingController.listCampaigns);
router.post('/campaigns', givingController.createCampaign);
router.put('/campaigns/:id', givingController.updateCampaign);
router.delete('/campaigns/:id', givingController.deleteCampaign);

export default router;
