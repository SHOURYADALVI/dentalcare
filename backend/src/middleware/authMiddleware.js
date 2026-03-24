import { supabaseAuth } from '../config/supabaseClient.js';
import { AppError } from '../utils/AppError.js';

export const protect = async (req, _res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError('Unauthorized: missing Bearer token', 401);
    }

    const token = authHeader.split(' ')[1];
    // Validate Supabase JWT and resolve authenticated user.
    const { data, error } = await supabaseAuth.auth.getUser(token);

    if (error || !data?.user) {
      throw new AppError('Unauthorized: invalid or expired token', 401);
    }

    req.user = data.user;
    next();
  } catch (error) {
    next(error);
  }
};
