import { Response, NextFunction } from 'express';
import { attendanceService } from './attendance.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthRequest } from '../../middleware/auth';

export const attendanceController = {
  // POST /attendance
  async recordAttendance(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user?.churchId) {
        return ApiResponse.error(res, 'Church context required', 400);
      }
      const result = await attendanceService.recordAttendance(
        req.user.id,
        req.user.churchId,
        req.body,
      );
      ApiResponse.created(res, result, 'Attendance recorded');
    } catch (error) {
      next(error);
    }
  },

  // GET /attendance
  async getHistory(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await attendanceService.getAttendanceHistory(
        req.user!.id,
        req.query as any,
      );
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },

  // GET /attendance/streak
  async getStreak(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await attendanceService.getAttendanceStreak(req.user!.id);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },

  // DELETE /attendance/:id
  async deleteAttendance(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const result = await attendanceService.deleteAttendance(
        req.user!.id,
        req.params.id as string,
      );
      ApiResponse.success(res, null, result.message);
    } catch (error) {
      next(error);
    }
  },

  // GET /attendance/stats
  async getStats(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user?.churchId) {
        return ApiResponse.error(res, 'Church context required', 400);
      }
      const result = await attendanceService.getAttendanceStats(req.user.churchId);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  },
};
