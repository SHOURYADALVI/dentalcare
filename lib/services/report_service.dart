import '../models/doctor_report.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();

  factory ReportService() {
    return _instance;
  }

  ReportService._internal();

  final List<DoctorReport> _reports = [
    DoctorReport(
      id: 'report-001',
      patientId: 'patient-001',
      doctorId: 'dentist-001',
      diagnosis: 'Dental caries in lower molar',
      treatment: 'Root canal treatment',
      medicines: 'Ibuprofen 400mg, Amoxicillin 500mg',
      precautions: 'Avoid hard food for 5 days and brush gently twice daily',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Future<List<DoctorReport>> getReportsByPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _reports.where((r) => r.patientId == patientId).toList();
  }

  Future<DoctorReport?> getLatestReportByPatient(String patientId) async {
    final list = await getReportsByPatient(patientId);
    if (list.isEmpty) return null;
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.first;
  }

  Future<DoctorReport> upsertReport({
    required String patientId,
    required String doctorId,
    required String diagnosis,
    required String treatment,
    required String medicines,
    required String precautions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final existingIndex = _reports.indexWhere((r) => r.patientId == patientId);
    if (existingIndex == -1) {
      final newReport = DoctorReport(
        patientId: patientId,
        doctorId: doctorId,
        diagnosis: diagnosis,
        treatment: treatment,
        medicines: medicines,
        precautions: precautions,
      );
      _reports.add(newReport);
      return newReport;
    }

    final updated = _reports[existingIndex].copyWith(
      diagnosis: diagnosis,
      treatment: treatment,
      medicines: medicines,
      precautions: precautions,
    );
    _reports[existingIndex] = updated;
    return updated;
  }
}
