import { Router } from 'express';
import { getDoctorById, getDoctors } from './doctors.controller.js';
import { validateRequest } from '../../middleware/validateRequest.js';
import { doctorIdParamSchema } from './doctors.schema.js';

const router = Router();

router.get('/', getDoctors);
router.get('/:id', validateRequest(doctorIdParamSchema), getDoctorById);

export default router;
