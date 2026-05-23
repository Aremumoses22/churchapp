import prisma from '../config/database';
import type { AuthRequest } from '../middleware/auth';

// Cached fallback for single-church setups where the user has no churchId
let _defaultChurchId: string | null | undefined;

/**
 * Resolves the churchId for a request.
 * 1. Returns req.user.churchId when present.
 * 2. Falls back to the first church in the database (cached per process).
 * 3. Returns null if no church exists yet.
 */
export async function resolveChurchId(req: AuthRequest): Promise<string | null> {
  if (req.user?.churchId) return req.user.churchId;

  if (_defaultChurchId !== undefined) return _defaultChurchId;

  const church = await prisma.church.findFirst({ select: { id: true } });
  _defaultChurchId = church?.id ?? null;
  return _defaultChurchId;
}
