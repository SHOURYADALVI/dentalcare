import { asyncHandler } from '../../utils/asyncHandler.js';
import { paymentsService } from './payments.service.js';

export const getMyPayments = asyncHandler(async (req, res) => {
  const data = await paymentsService.getMyPaymentSummary(req.user.id);
  res.status(200).json({ success: true, data });
});
