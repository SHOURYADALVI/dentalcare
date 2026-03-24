import { asyncHandler } from '../../utils/asyncHandler.js';
import { appointmentsService } from './appointments.service.js';

export const bookAppointment = asyncHandler(async (req, res) => {
  const data = await appointmentsService.bookAppointment(req.user.id, req.body);
  res.status(201).json({ success: true, message: 'Appointment booked successfully', data });
});

export const getMyAppointments = asyncHandler(async (req, res) => {
  const data = await appointmentsService.getMyAppointments(req.user.id);
  res.status(200).json({ success: true, data });
});
