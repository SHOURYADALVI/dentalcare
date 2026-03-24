import { supabaseAuth } from '../../config/supabaseClient.js';
import { AppError } from '../../utils/AppError.js';

export const authService = {
  async login(email, password) {
    const { data, error } = await supabaseAuth.auth.signInWithPassword({ email, password });
    if (error || !data?.session || !data?.user) {
      throw new AppError(error?.message || 'Invalid credentials', 401);
    }

    return {
      access_token: data.session.access_token,
      refresh_token: data.session.refresh_token,
      user: {
        id: data.user.id,
        email: data.user.email,
      },
    };
  },
};
