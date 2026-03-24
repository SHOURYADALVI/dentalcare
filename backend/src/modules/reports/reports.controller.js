import { asyncHandler } from '../../utils/asyncHandler.js';
import { reportsService } from './reports.service.js';

export const getMyReports = asyncHandler(async (req, res) => {
  const data = await reportsService.getMyReports(req.user.id);
  res.status(200).json({ success: true, data });
});
