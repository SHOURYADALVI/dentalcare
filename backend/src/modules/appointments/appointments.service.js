import { supabase } from '../../config/supabaseClient.js';
import { AppError } from '../../utils/AppError.js';

const isFutureSlot = (date, time) => {
  const slot = new Date(`${date}T${time}`);
  return !Number.isNaN(slot.getTime()) && slot.getTime() > Date.now();
};

export const appointmentsService = {
  async bookAppointment(patientId, payload) {
    const { doctor_id, date, time, consultation_fee } = payload;

    if (!doctor_id || !date || !time || consultation_fee === undefined) {
      throw new AppError('doctor_id, date, time, consultation_fee are required', 400);
    }

    if (!isFutureSlot(date, time)) {
      throw new AppError('Appointment must be booked for a future date/time', 400);
    }

    // Prevent double booking for the same doctor/date/time unless cancelled.
    const { data: conflict, error: conflictError } = await supabase
      .from('appointments')
      .select('id')
      .eq('doctor_id', doctor_id)
      .eq('date', date)
      .eq('time', time)
      .neq('status', 'Cancelled')
      .limit(1)
      .maybeSingle();

    if (conflictError) throw new AppError(conflictError.message, 400);
    if (conflict) {
      throw new AppError('Doctor already has an appointment in this time slot', 409);
    }

    // Create appointment only after business constraints are satisfied.
    const { data, error } = await supabase
      .from('appointments')
      .insert({
        patient_id: patientId,
        doctor_id,
        date,
        time,
        consultation_fee,
        status: 'Scheduled',
      })
      .select('id, patient_id, doctor_id, date, time, consultation_fee, status')
      .single();

    if (error) throw new AppError(error.message, 400);
    return data;
  },

  async getMyAppointments(patientId) {
    const { data, error } = await supabase
      .from('appointments')
      .select('id, date, time, consultation_fee, status, doctor:doctors(id, name, qualification, phone, email, clinic_address)')
      .eq('patient_id', patientId)
      .order('date', { ascending: true })
      .order('time', { ascending: true });

    if (error) throw new AppError(error.message, 400);
    return data;
  },
};
