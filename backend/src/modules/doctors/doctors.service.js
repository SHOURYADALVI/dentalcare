import { supabase } from '../../config/supabaseClient.js';
import { AppError } from '../../utils/AppError.js';

export const doctorsService = {
  async getDoctors() {
    const { data, error } = await supabase
      .from('doctors')
      .select('id, name, qualification, phone, email, clinic_address')
      .order('name', { ascending: true });

    if (error) throw new AppError(error.message, 400);
    return data;
  },

  async getDoctorById(id) {
    const { data, error } = await supabase
      .from('doctors')
      .select('id, name, qualification, phone, email, clinic_address')
      .eq('id', id)
      .single();

    if (error || !data) throw new AppError('Doctor not found', 404);
    return data;
  },
};
