import { supabase } from '../../config/supabaseClient.js';
import { AppError } from '../../utils/AppError.js';

export const paymentsService = {
  async getMyPaymentSummary(patientId) {
    const { data, error } = await supabase
      .from('payments')
      .select('id, total_amount, paid_amount, remaining_amount, created_at, updated_at')
      .eq('patient_id', patientId)
      .maybeSingle();

    if (error) throw new AppError(error.message, 400);

    return data ?? {
      id: null,
      total_amount: 0,
      paid_amount: 0,
      remaining_amount: 0,
      created_at: null,
      updated_at: null,
    };
  },
};
