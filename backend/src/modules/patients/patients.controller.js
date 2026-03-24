import { asyncHandler } from '../../utils/asyncHandler.js';
import { patientsService } from './patients.service.js';

export const getPatientProfile = asyncHandler(async (req, res) => {
  const profile = await patientsService.getProfile(req.user.id);
  res.status(200).json({ success: true, data: profile });
});

export const getPatientDashboard = asyncHandler(async (req, res) => {
  const dashboard = await patientsService.getDashboard(req.user.id);
  res.status(200).json({ success: true, data: dashboard });
});
