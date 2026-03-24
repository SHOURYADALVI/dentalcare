import { Router } from 'express';
import { loginPatient } from './auth.controller.js';
import { validateRequest } from '../../middleware/validateRequest.js';
import { loginSchema } from './auth.schema.js';

const router = Router();

router.post('/login', validateRequest(loginSchema), loginPatient);

export default router;
