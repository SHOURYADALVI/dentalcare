import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/appointment.dart';
import '../../models/doctor_profile.dart';
import '../../models/doctor_report.dart';
import '../../models/patient.dart';
import '../../services/doctor_service.dart';
import '../../services/report_service.dart';
import 'appointment_providers.dart';
import 'patient_providers.dart';
import 'treatment_providers.dart';

final doctorServiceProvider = Provider<DoctorService>((ref) {
  return DoctorService();
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

final doctorProfileProvider = FutureProvider<DoctorProfile>((ref) async {
  final service = ref.watch(doctorServiceProvider);
  return service.getDoctorProfile();
});

final doctorPatientsProvider = FutureProvider<List<Patient>>((ref) async {
  return ref.watch(patientsProvider.future);
});

final doctorSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredDoctorPatientsProvider = FutureProvider<List<Patient>>((ref) async {
  final query = ref.watch(doctorSearchQueryProvider).trim();
  if (query.isEmpty) {
    return ref.watch(doctorPatientsProvider.future);
  }
  return ref.watch(searchPatientsProvider(query).future);
});

final todayDoctorAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  return ref.watch(todayAppointmentsProvider.future);
});

final selectedDoctorPatientProvider = StateProvider<Patient?>((ref) => null);

final patientBillingSummaryProvider = FutureProvider.family<Map<String, double>, String>((ref, patientId) async {
  final treatments = await ref.watch(getPatientTreatmentsProvider(patientId).future);
  final total = treatments.fold<double>(0.0, (sum, t) => sum + t.cost);
  final paid = total * 0.65;
  return {
    'total': total,
    'paid': paid,
    'remaining': total - paid,
  };
});

final patientReportProvider = FutureProvider.family<DoctorReport?, String>((ref, patientId) async {
  final service = ref.watch(reportServiceProvider);
  return service.getLatestReportByPatient(patientId);
});

class SaveReportPayload {
  final String patientId;
  final String doctorId;
  final String diagnosis;
  final String treatment;
  final String medicines;
  final String precautions;

  const SaveReportPayload({
    required this.patientId,
    required this.doctorId,
    required this.diagnosis,
    required this.treatment,
    required this.medicines,
    required this.precautions,
  });
}

final saveReportProvider = FutureProvider.family<DoctorReport, SaveReportPayload>((ref, payload) async {
  final service = ref.watch(reportServiceProvider);
  final report = await service.upsertReport(
    patientId: payload.patientId,
    doctorId: payload.doctorId,
    diagnosis: payload.diagnosis,
    treatment: payload.treatment,
    medicines: payload.medicines,
    precautions: payload.precautions,
  );

  ref.invalidate(patientReportProvider(payload.patientId));
  return report;
});
