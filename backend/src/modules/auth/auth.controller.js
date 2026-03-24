import { authService } from './auth.service.js';
import { asyncHandler } from '../../utils/asyncHandler.js';

export const loginPatient = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const data = await authService.login(email, password);

  res.status(200).json({
    success: true,
    message: 'Login successful',
    data,
  });
});
