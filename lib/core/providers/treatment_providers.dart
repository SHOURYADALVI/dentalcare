import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/treatment.dart';
import '../../services/treatment_service.dart';

// Treatment service provider
final treatmentServiceProvider = Provider<TreatmentService>((ref) {
  return TreatmentService();
});

/// All treatments list
final treatmentsProvider = FutureProvider<List<Treatment>>((ref) async {
  final treatmentService = ref.watch(treatmentServiceProvider);
  return treatmentService.getAllTreatments();
});

/// Get treatments by patient ID
final getPatientTreatmentsProvider =
    FutureProvider.family<List<Treatment>, String>((ref, patientId) async {
  final treatmentService = ref.watch(treatmentServiceProvider);
  return treatmentService.getTreatmentsByPatient(patientId);
});

/// Get treatments by date range
final getTreatmentsByDateRangeProvider = FutureProvider.family<
    List<Treatment>,
    (DateTime, DateTime)>((ref, dateRange) async {
  final treatmentService = ref.watch(treatmentServiceProvider);
  return treatmentService.getTreatmentsByDateRange(dateRange.$1, dateRange.$2);
});

/// Add treatment
final addTreatmentProvider =
    FutureProvider.family<Treatment, Treatment>((ref, treatment) async {
  final treatmentService = ref.watch(treatmentServiceProvider);
  final newTreatment = await treatmentService.addTreatment(treatment);
  // Invalidate related providers
  ref.invalidate(treatmentsProvider);
  return newTreatment;
});

/// Update treatment
final updateTreatmentProvider =
    FutureProvider.family<Treatment, Treatment>((ref, treatment) async {
  final treatmentService = ref.watch(treatmentServiceProvider);
  final updatedTreatment = await treatmentService.updateTreatment(treatment);
  // Invalidate related providers
  ref.invalidate(treatmentsProvider);
  return updatedTreatment;
});

/// Delete treatment
final deleteTreatmentProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final treatmentService = ref.watch(treatmentServiceProvider);
  await treatmentService.deleteTreatment(id);
  // Invalidate related providers
  ref.invalidate(treatmentsProvider);
});

/// Get total revenue
final totalRevenueProvider = FutureProvider<double>((ref) async {
  final treatmentService = ref.watch(treatmentServiceProvider);
  return treatmentService.getTotalRevenue();
});

/// Get revenue by date range
final revenueByDateRangeProvider = FutureProvider.family<double, (DateTime, DateTime)>(
    (ref, dateRange) async {
  final treatmentService = ref.watch(treatmentServiceProvider);
  return treatmentService.getRevenueByDateRange(dateRange.$1, dateRange.$2);
});
