import { supabase } from '../../config/supabaseClient.js';
import { AppError } from '../../utils/AppError.js';

export const patientsService = {
  async getProfile(patientId) {
    const { data, error } = await supabase
      .from('patients')
      .select('id, name, age, phone, email, created_at')
      .eq('id', patientId)
      .single();

    if (error || !data) {
      throw new AppError('Patient profile not found', 404);
    }

    return data;
  },

  async getDashboard(patientId) {
    const nowIso = new Date().toISOString();

    const [upcomingResult, paymentResult, reportResult] = await Promise.all([
      supabase
        .from('appointments')
        .select('id, date, time, consultation_fee, status, doctor:doctors(id, name, qualification, phone, email, clinic_address)')
        .eq('patient_id', patientId)
        .gte('date', nowIso.split('T')[0])
        .order('date', { ascending: true })
        .order('time', { ascending: true })
        .limit(1)
        .maybeSingle(),
      supabase
        .from('payments')
        .select('total_amount, paid_amount, remaining_amount')
        .eq('patient_id', patientId)
        .maybeSingle(),
      supabase
        .from('reports')
        .select('id, diagnosis, treatment, medicines, precautions, created_at, doctor:doctors(id, name, qualification, phone, email, clinic_address)')
        .eq('patient_id', patientId)
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle(),
    ]);

    if (upcomingResult.error) throw new AppError(upcomingResult.error.message, 400);
    if (paymentResult.error) throw new AppError(paymentResult.error.message, 400);
    if (reportResult.error) throw new AppError(reportResult.error.message, 400);

    const doctorInfo = upcomingResult.data?.doctor ?? reportResult.data?.doctor ?? null;

    return {
      upcoming_appointment: upcomingResult.data ?? null,
      payment_summary: paymentResult.data ?? { total_amount: 0, paid_amount: 0, remaining_amount: 0 },
      latest_report: reportResult.data ?? null,
      doctor_info: doctorInfo,
    };
  },
};
