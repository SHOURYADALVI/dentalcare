import { Router } from 'express';
import { getMyPayments } from './payments.controller.js';

const router = Router();

router.get('/my', getMyPayments);

export default router;
