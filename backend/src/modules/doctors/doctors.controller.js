import { asyncHandler } from '../../utils/asyncHandler.js';
import { doctorsService } from './doctors.service.js';

export const getDoctors = asyncHandler(async (_req, res) => {
  const data = await doctorsService.getDoctors();
  res.status(200).json({ success: true, data });
});

export const getDoctorById = asyncHandler(async (req, res) => {
  const data = await doctorsService.getDoctorById(req.params.id);
  res.status(200).json({ success: true, data });
});
