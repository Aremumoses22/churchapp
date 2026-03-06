import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError, ZodObject } from 'zod';
import { ApiError } from '../utils/apiError';

/**
 * Detect whether a Zod schema is a "compound" schema whose top-level keys
 * are a subset of { body, query, params }. If so, we validate the full
 * request object; otherwise we validate a single source.
 */
function isCompoundSchema(schema: ZodSchema): boolean {
  if (!(schema instanceof ZodObject)) return false;
  const keys = Object.keys((schema as any).shape || {});
  const allowed = new Set(['body', 'query', 'params']);
  return keys.length > 0 && keys.every((k) => allowed.has(k));
}

/**
 * Zod validation middleware
 *
 * Supports two calling conventions:
 *  1. `validate(schema, 'query')` — validates req[source] against a flat schema (Phase 1-3 style)
 *  2. `validate(schema)` — auto-detects:
 *     a. If the schema's top-level keys are body/query/params → compound mode
 *     b. Otherwise → legacy body mode (default)
 */
export function validate(schema: ZodSchema, source?: 'body' | 'query' | 'params') {
  const compound = !source && isCompoundSchema(schema);

  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      if (compound) {
        // ── Compound: schema has { query?, params?, body? } keys ──
        const input: Record<string, unknown> = {
          body: req.body ?? {},
          query: req.query ?? {},
          params: req.params ?? {},
        };

        const parsed = schema.parse(input) as Record<string, unknown>;

        if (parsed.body) (req as any).body = parsed.body;
        if (parsed.query) {
          Object.defineProperty(req, 'query', {
            value: parsed.query,
            writable: true,
            configurable: true,
          });
        }
        if (parsed.params) (req as any).params = parsed.params;
      } else {
        // ── Legacy: single-source (default: body) ────────
        const src = source || 'body';
        const data = schema.parse(req[src]);
        if (src === 'query') {
          Object.defineProperty(req, 'query', { value: data, writable: true, configurable: true });
        } else {
          (req as any)[src] = data;
        }
      }
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const fieldErrors: Record<string, string[]> = {};
        error.issues.forEach((err: any) => {
          const path = (err.path || []).join('.') || 'general';
          if (!fieldErrors[path]) fieldErrors[path] = [];
          fieldErrors[path].push(err.message);
        });
        next(ApiError.badRequest('Validation failed', fieldErrors));
      } else {
        next(error);
      }
    }
  };
}
