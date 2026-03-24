import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/patient.dart';
import '../../services/patient_service.dart';

// Patient service provider
final patientServiceProvider = Provider<PatientService>((ref) {
  return PatientService();
});

/// All patients list
final patientsProvider = FutureProvider<List<Patient>>((ref) async {
  final patientService = ref.watch(patientServiceProvider);
  return patientService.getAllPatients();
});

/// Search patients by query
final searchPatientsProvider =
    FutureProvider.family<List<Patient>, String>((ref, query) async {
  final patientService = ref.watch(patientServiceProvider);
  return patientService.searchPatients(query);
});

/// Get single patient by ID
final getPatientProvider = FutureProvider.family<Patient?, String>((ref, id) async {
  final patientService = ref.watch(patientServiceProvider);
  return patientService.getPatientById(id);
});

/// Add patient
final addPatientProvider =
    FutureProvider.family<Patient, Patient>((ref, patient) async {
  final patientService = ref.watch(patientServiceProvider);
  final newPatient = await patientService.addPatient(patient);
  // Invalidate the patients list to refetch
  ref.invalidate(patientsProvider);
  return newPatient;
});

/// Update patient
final updatePatientProvider =
    FutureProvider.family<Patient, Patient>((ref, patient) async {
  final patientService = ref.watch(patientServiceProvider);
  final updatedPatient = await patientService.updatePatient(patient);
  // Invalidate the patients list to refetch
  ref.invalidate(patientsProvider);
  return updatedPatient;
});

/// Delete patient
final deletePatientProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final patientService = ref.watch(patientServiceProvider);
  await patientService.deletePatient(id);
  // Invalidate the patients list to refetch
  ref.invalidate(patientsProvider);
});

/// Get total patient count
final patientCountProvider = FutureProvider<int>((ref) async {
  final patientService = ref.watch(patientServiceProvider);
  return patientService.getPatientCount();
});

/// Get selected patient ID (for navigation/state)
final selectedPatientIdProvider = StateProvider<String?>((ref) {
  return null;
});

/// Get currently selected patient details
final selectedPatientProvider = FutureProvider<Patient?>((ref) {
  final patientId = ref.watch(selectedPatientIdProvider);
  final patientService = ref.watch(patientServiceProvider);

  if (patientId == null) return null;
  return patientService.getPatientById(patientId);
});
