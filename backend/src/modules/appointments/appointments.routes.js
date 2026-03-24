import { Router } from 'express';
import { bookAppointment, getMyAppointments } from './appointments.controller.js';
import { validateRequest } from '../../middleware/validateRequest.js';
import { bookAppointmentSchema } from './appointments.schema.js';

const router = Router();

router.post('/book', validateRequest(bookAppointmentSchema), bookAppointment);
router.get('/my', getMyAppointments);

export default router;
