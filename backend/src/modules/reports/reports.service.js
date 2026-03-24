import { supabase } from '../../config/supabaseClient.js';
import { AppError } from '../../utils/AppError.js';

export const reportsService = {
  async getMyReports(patientId) {
    const { data, error } = await supabase
      .from('reports')
      .select(`
        id,
        diagnosis,
        treatment,
        medicines,
        precautions,
        created_at,
        patient:patients(name, age, phone),
        doctor:doctors(id, name, qualification, phone, email, clinic_address)
      `)
      .eq('patient_id', patientId)
      .order('created_at', { ascending: false });

    if (error) throw new AppError(error.message, 400);

    return data.map((report) => ({
      id: report.id,
      patient: report.patient,
      diagnosis: report.diagnosis,
      treatment: report.treatment,
      medicines: report.medicines,
      precautions: report.precautions,
      date: report.created_at,
      doctor: report.doctor,
    }));
  },
};
