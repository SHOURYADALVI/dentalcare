import '../models/treatment.dart';

/// Mock treatment data repository service
class TreatmentService {
  static final TreatmentService _instance = TreatmentService._internal();

  factory TreatmentService() {
    return _instance;
  }

  TreatmentService._internal();

  // In-memory storage for mock data
  final List<Treatment> _treatments = [
    Treatment(
      id: 'treat-001',
      patientId: 'patient-001',
      patientName: 'John Doe',
      treatmentDate: DateTime.now().subtract(const Duration(days: 5)),
      diagnosis: 'Cavities in molars',
      procedure: 'Cavity filling - 2 teeth',
      notes: 'Completed without complications',
      cost: 200.0,
      dentistName: 'Dr. John Smith',
    ),
    Treatment(
      id: 'treat-002',
      patientId: 'patient-002',
      patientName: 'Jane Smith',
      treatmentDate: DateTime.now().subtract(const Duration(days: 10)),
      diagnosis: 'Plaque buildup',
      procedure: 'Professional cleaning',
      notes: 'Patient advised on flossing',
      cost: 100.0,
      dentistName: 'Dr. John Smith',
    ),
  ];

  /// Get all treatments
  Future<List<Treatment>> getAllTreatments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _treatments;
  }

  /// Get treatments by patient ID
  Future<List<Treatment>> getTreatmentsByPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _treatments
        .where((treatment) => treatment.patientId == patientId)
        .toList();
  }

  /// Get treatments by date range
  Future<List<Treatment>> getTreatmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _treatments
        .where((treatment) =>
            treatment.treatmentDate.isAfter(startDate) &&
            treatment.treatmentDate.isBefore(endDate))
        .toList();
  }

  /// Add new treatment
  Future<Treatment> addTreatment(Treatment treatment) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _treatments.add(treatment);
    return treatment;
  }

  /// Update treatment
  Future<Treatment> updateTreatment(Treatment treatment) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index =
        _treatments.indexWhere((t) => t.id == treatment.id);
    if (index != -1) {
      _treatments[index] = treatment.copyWith(updatedAt: DateTime.now());
      return _treatments[index];
    }
    throw Exception('Treatment not found');
  }

  /// Delete treatment
  Future<void> deleteTreatment(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _treatments.removeWhere((t) => t.id == id);
  }

  /// Get total revenue (sum of all treatment costs)
  Future<double> getTotalRevenue() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _treatments.fold<double>(
      0.0,
      (sum, treatment) => sum + treatment.cost,
    );
  }

  /// Get revenue by date range
  Future<double> getRevenueByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final treatments = await getTreatmentsByDateRange(startDate, endDate);
    return treatments.fold<double>(
      0.0,
      (sum, treatment) => sum + treatment.cost,
    );
  }
}
