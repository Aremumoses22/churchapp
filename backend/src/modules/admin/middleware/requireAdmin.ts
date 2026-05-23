import { authorize } from '../../../middleware/auth';

/** Shorthand: require ADMIN or SUPER_ADMIN role. Use after `authenticate`. */
export const requireAdmin = authorize('ADMIN', 'SUPER_ADMIN');

/** Shorthand: require SUPER_ADMIN only. Use after `authenticate`. */
export const requireSuperAdmin = authorize('SUPER_ADMIN');
