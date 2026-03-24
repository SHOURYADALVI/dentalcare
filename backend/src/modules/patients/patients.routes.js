import { Router } from 'express';
import { getPatientDashboard, getPatientProfile } from './patients.controller.js';

const router = Router();

router.get('/profile', getPatientProfile);
router.get('/dashboard', getPatientDashboard);

export default router;
