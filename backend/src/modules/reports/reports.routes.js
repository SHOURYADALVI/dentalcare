import { Router } from 'express';
import { getMyReports } from './reports.controller.js';

const router = Router();

router.get('/my', getMyReports);

export default router;
