import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import {
  idParamSchema,
  listThreadsSchema,
  categoryThreadsSchema,
  createThreadSchema,
  createReplySchema,
  threadDetailSchema,
} from './forum.validation';
import * as forumCtrl from './forum.controller';

const router = Router();

router.get('/categories', authenticate, forumCtrl.getCategories);
router.get('/trending', authenticate, forumCtrl.getTrending);
router.get('/recent', authenticate, validate(listThreadsSchema), forumCtrl.getRecent);
router.get('/categories/:id/threads', authenticate, validate(categoryThreadsSchema), forumCtrl.getCategoryThreads);

// Thread CRUD — order matters: specific routes before :id
router.post('/threads', authenticate, validate(createThreadSchema), forumCtrl.createThread);
router.get('/threads/:id', authenticate, validate(threadDetailSchema), forumCtrl.getThreadDetail);
router.post('/threads/:id/replies', authenticate, validate(createReplySchema), forumCtrl.createReply);
router.post('/threads/:id/like', authenticate, validate(idParamSchema), forumCtrl.toggleThreadLike);
router.post('/threads/:id/bookmark', authenticate, validate(idParamSchema), forumCtrl.toggleBookmark);

// Reply like
router.post('/replies/:id/like', authenticate, validate(idParamSchema), forumCtrl.toggleReplyLike);

export default router;
