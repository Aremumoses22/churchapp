import jwt from 'jsonwebtoken';
import env from '../config/env';

interface TokenPayload {
  sub: string;
  email: string;
  role: string;
  churchId: string | null;
}

/**
 * JWT Token Service
 * Handles access token and refresh token generation/verification
 */
export const tokenService = {
  /**
   * Generate short-lived access token (15 minutes default)
   */
  generateAccessToken(payload: TokenPayload): string {
    return jwt.sign(
      { ...payload, type: 'access' },
      env.jwtSecret,
      { expiresIn: env.jwtExpiresIn } as any,
    );
  },

  /**
   * Generate long-lived refresh token (30 days default)
   */
  generateRefreshToken(payload: TokenPayload): string {
    return jwt.sign(
      { ...payload, type: 'refresh' },
      env.jwtRefreshSecret,
      { expiresIn: env.jwtRefreshExpiresIn } as any,
    );
  },

  /**
   * Generate both access and refresh tokens
   */
  generateTokenPair(payload: TokenPayload) {
    return {
      accessToken: this.generateAccessToken(payload),
      refreshToken: this.generateRefreshToken(payload),
    };
  },

  /**
   * Verify access token
   */
  verifyAccessToken(token: string) {
    return jwt.verify(token, env.jwtSecret) as TokenPayload & { type: 'access'; iat: number; exp: number };
  },

  /**
   * Verify refresh token
   */
  verifyRefreshToken(token: string) {
    return jwt.verify(token, env.jwtRefreshSecret) as TokenPayload & { type: 'refresh'; iat: number; exp: number };
  },
};
